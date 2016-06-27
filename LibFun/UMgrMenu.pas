{*******************************************************************************
  作者: dmzn@163.com 2007-11-08
  描述: 菜单管理器,用于动态菜单的加载

  备注:
  &.本单元实现了菜单管理器MenuManager.
  &.MenuManager主要用于动态菜单的加载和菜单项的查询.
  &.为了实现本单元的最大灵活性,所有与数据库相关的操作(读,写),都使用抽象方法,
  所以MenuManager是一个不完整的类.在具体的项目中,需要有它的子类来实现读写函数.
  &.对于MenuManager.ExecSQL,参数nSQL是一个Insert,Update,Delete语句.
  &.对于MenuManager.QuerySQL,参数nSQL是一个Select语句,参数nDS是返回的记录集,
  参数nAutoFree标识是否自动释放该数据集.
  &.对于MenuMaanger.IsTableExists,父类使用它检索菜单表是否存在.
  &.子类必须实现以上三个抽象方法,以补全基类的功能.
  &.MenuManager.LoadMenuFromDB载入成功后,MenuManager.TopLevelMenu是一个完整的
  菜单树,每个菜单项的FSubMenu中,存放子菜单列表,循环载入就可以了.
  &.MenuManager.TopLevelMenu中有两种元素:实体,顶级菜单,分别使用GetEntityList,
    GetMenuList来获取,参数nList存放实体或菜单的指针,但不用释放.

  &.菜单项约定:
  *.程序标识: FEntity = ''
  *.实体标识: FMenuID = ''
  *.顶级菜单: FPMenu = ''
  *.每个程序多个实体,每个实体多个菜单项
  *.不同实体的菜单标识允许相同,同实体的菜单项不能相同.
*******************************************************************************}
unit UMgrMenu;

interface

uses
  Windows, Classes, SysUtils, DB, ULibFun;

const
  cMenuTable_Menu = $0001;

type
  PMenuItemData = ^TMenuItemData;
  TMenuItemData = record
    FProgID: string;                //程序标识
    FEntity: string;                //实体标识
    FMenuID: string;                //菜单标识
    FPMenu: string;                 //上级菜单
    FTitle: string;                 //菜单标题
    FImgIndex: integer;             //图标索引
    FFlag: string;                  //附加参数(下划线..)
    FAction: string;                //菜单动作
    FFilter: string;                //过滤条件
    FNewOrder: Single;              //创建序列
    FPopedom: string;               //权限项
    FLangID: string;                //语言标识
    FSubMenu: TList;                //子菜单列表
  end;

  THintMsg = procedure (const nMsg: string) of Object;
  //提示信息

  TBaseMenuManager = class(TObject)
  private
    FItemList: TList;
    {*顶级菜单列表*}
    FProList: TList;
    {*程序标识列表*}
    FLangID: string;
    {*语言标识*}
    FHintMsg: THintMsg;
    {事件}
  protected
    procedure HintMsg(const nMsg: string);
    {*提示信息*}
    function FindMenuItem(const nList: TList;
      const nEntity,nMenuID: string): PMenuItemData;
    {*检索菜单项*}
    function BuildMenuTree(const nList: TList): Boolean;
    {*构建层次树*}
    procedure ClearItemList(const nList: TList; const nFree: Boolean = False);
    {*清空菜单项列表,支持多级*}

    function SafeQuery(const nSQL: string;
      var nDS: TDataSet; var nAutoFree: Boolean): Boolean;
    procedure FreeDataSet(const nDS: TDataSet); virtual;
    {*带验证的执行QuerySQL函数*}

    function QuerySQL(const nSQL: string;
      var nDS: TDataSet; var nAutoFree: Boolean): Boolean; virtual; abstract;
    function ExecSQL(const nSQL: string): integer; virtual; abstract;

    function GetItemValue(const nItem: integer): string; virtual; abstract;
    function IsTableExists(const nTable: string): Boolean; virtual; abstract;
    {*子类方法*}
  public
    constructor Create;
    destructor Destroy; override;
    {*创建释放*}
    function CreateMenuTable: Boolean;
    {*创建表*}
    function AddMenuToDB(const nMenu: TMenuItemData): Boolean;
    function DelMenuFromDB(const nProgID: string): integer; overload;
    function DelMenuFromDB(const nProg,nEntity: string): integer; overload;
    function DelMenuFromDB(const nProg,nEntity,nMenu: string): integer; overload;
    {*添加删除*}
    function LoadMenuFromDB(const nProgID: string): Boolean;
    {*读取菜单*}
    function GetProgList: TList;
    {*获取程序标识*}
    function GetEntityList(const nList: TList): Boolean;
    function GetMenuList(const nList: TList; const nEntity: string): Boolean;
    function GetMenuItem(const nEntity,nMenuID: string): PMenuItemData;
    {*检索菜单项*}
    property TopMenus: TList read FItemList;
    property LangID: string read FLangID write FLangID;
    property OnHintMsg: THintMsg read FHintMsg write FHintMsg;
    {属性,事件}
  end;

implementation

const
  cMenuItemDataSize = SizeOf(TMenuItemData);
  //菜单项数据大小

  sDeleteMenu1 = 'Delete From $Table Where M_ProgID=''$ProgID''';
  sDeleteMenu2 = sDeleteMenu1 + ' And M_Entity=''$Entity''';
  sDeleteMenu3 = sDeleteMenu2 + ' And M_MenuID=''$Menu''';
  //Menu Delete SQL

ResourceString
  sNoTable = '无法定位到"菜单"表';
  sNoRecord = '"菜单"表为空,没有菜单数据';
  sQueryError = '查询"菜单"表失败,无法读取菜单数据';

  sCreateMenu = 'Create Table $Table(' +
                'M_MenuID varchar(15),' +                     //菜单标识
                'M_ProgID varchar(15),' +                     //程序标识
                'M_Entity varchar(15),' +                     //实体标识
                'M_PMenu varchar(15),' +                      //上级菜单
                'M_Title varchar(50),' +                      //菜单标题
                'M_ImgIndex integer,' +                       //图标索引
                'M_Flag varchar(20),' +                       //附加参数
                'M_Action varchar(100),' +                    //菜单动作
                'M_Filter varchar(100),' +                    //过滤条件
                'M_Popedom varchar(36),' +                    //权限项
                'M_LangID varchar(12),' +                     //语言标识
                'M_NewOrder float Default -1)';               //创建序列
  //Menu Create SQL

  sInsertMenu = 'Insert $Table Values(''$MenuID'', ''$ProgID'', ''$Entity'',' +
                '''$PMenu'', ''$Title'', $ImgIndex, ''$Flag'', ''$Action'',' +
                '''$Filter'', ''$Popedom'', $LangID, $NewOrder)';
  //Menu Insert SQL

  sSelectMenu = 'Select * from $Table where M_ProgID=''$ID'' and ' +
                'M_NewOrder > -1 $Lang Order by M_NewOrder';
  //Select a Program's Menu's Items

  sSelectProID = 'Select * from $Table Where (M_Entity='''') or (M_Entity Is Null)';
  //Get Program list

//------------------------------------------------------------------------------
constructor TBaseMenuManager.Create;
begin
  FLangID := '';
  FProList := nil;
  FItemList := TList.Create;  
end;

destructor TBaseMenuManager.Destroy;
begin
  ClearItemList(FItemList, True);
  ClearItemList(FProList, True);
  inherited;
end;

//Date: 2007-11-08
//Parm: 消息内容
//Desc: 出发HintMsg事件,提示nMsg消息
procedure TBaseMenuManager.HintMsg(const nMsg: string);
begin
  if Assigned(FHintMsg) then FHintMsg(nMsg);
end;

//Date: 2007-11-08
//Desc: 创建Menu表,若表已存在则直接返回真
function TBaseMenuManager.CreateMenuTable: Boolean;
var nStr: string;
begin
  nStr := GetItemValue(cMenuTable_Menu);
  Result := IsTableExists(nStr);

  if not Result then
  begin
    nStr := MacroValue(sCreateMenu, [MI('$Table', nStr)]);
    Result := ExecSQL(nStr) > -1;
  end;
end;

//Date: 2007-11-08
//Parm: 待释放列表;是否释放列表本身
//Desc: 逐级释放nList中的菜单项数据,或同时释放nList
procedure TBaseMenuManager.ClearItemList(const nList: TList; const nFree: Boolean);
var i,nCount: integer;
    nItem: PMenuItemData;
begin
  if Assigned(nList) then
  begin
    nCount := nList.Count - 1;
    
    for i:=0 to nCount do
    begin
      nItem := nList[i];
      if Assigned(nItem.FSubMenu) then
      begin
        ClearItemList(nItem.FSubMenu);
        FreeAndNil(nItem.FSubMenu);
      end;
      //递规释放子菜单

      Dispose(nItem);
    end;

    if nFree then
         nList.Free
    else nList.Clear;
    //对于不需要释放的列表,只清空即可
  end;
end;

//------------------------------------------------------------------------------
//Desc: 向数据添加新nMenu菜单,若存在则覆盖
function TBaseMenuManager.AddMenuToDB(const nMenu: TMenuItemData): Boolean;
var nSQL,nLang: string;
begin
  DelMenuFromDB(nMenu.FProgID, nMenu.FEntity, nMenu.FMenuID);
  if nMenu.FLangID = '' then
       nLang := 'Null'
  else nLang := Format('''%s''', [nMenu.FLangID]);

  nSQL := MacroValue(sInsertMenu, [MI('$Table', GetItemValue(cMenuTable_Menu)),
                                   MI('$MenuID', nMenu.FMenuID),
                                   MI('$ProgID', nMenu.FProgID),
                                   MI('$Entity', nMenu.FEntity),
                                   MI('$PMenu', nMenu.FPMenu),
                                   MI('$Title', nMenu.FTitle),
                                   MI('$ImgIndex', IntToStr(nMenu.FImgIndex)),
                                   MI('$Flag', nMenu.FFlag),
                                   MI('$Action', nMenu.FAction),
                                   MI('$Filter', nMenu.FFilter),
                                   MI('$Popedom', nMenu.FPopedom),
                                   MI('$LangID', nLang),
                                   MI('$NewOrder', FloatToStr(nMenu.FNewOrder))]);
  Result := ExecSQL(nSQL) > 0;
end;

//Desc: 删除nProgID程序的所有菜单
function TBaseMenuManager.DelMenuFromDB(const nProgID: string): integer;
var nStr,nSQL: string;
begin
  nStr := GetItemValue(cMenuTable_Menu);
  nSQL := MacroValue(sDeleteMenu1, [MI('$Table', nStr), MI('$ProgID', nProgID)]);
  Result := ExecSQL(nSQL);
end;

//Desc: 删除nProg程序下nEntity实体的所有菜单
function TBaseMenuManager.DelMenuFromDB(const nProg, nEntity: string): integer;
var nSQL: string;
begin
  nSQL := MacroValue(sDeleteMenu2,[MI('$Table', GetItemValue(cMenuTable_Menu)),
                                   MI('$ProgID', nProg), MI('$Entity', nEntity)]);
  Result := ExecSQL(nSQL);
end;

//Desc: 删除nProg程序下nEntity实体下的nMenu菜单项
function TBaseMenuManager.DelMenuFromDB(const nProg, nEntity,
  nMenu: string): integer;
var nSQL: string;
begin
  nSQL := MacroValue(sDeleteMenu3,[MI('$Table', GetItemValue(cMenuTable_Menu)),
                                   MI('$ProgID', nProg),
                                   MI('$Entity', nEntity), MI('$Menu', nMenu)]);
  Result := ExecSQL(nSQL);
end;

//------------------------------------------------------------------------------
//Date: 2007-11-08
//Parm: 待检索列表;实体标识;菜单标识
//Desc: 在nList菜单项列表及其子菜单列表中检索nEntity.nMenuID菜单项
function TBaseMenuManager.FindMenuItem(const nList: TList;
  const nEntity,nMenuID: string): PMenuItemData;
var i,nCount: integer;
    nItem: PMenuItemData;
begin
  Result := nil;
  nCount := nList.Count - 1;

  for i:=0 to nCount do
  begin
    nItem := nList[i];
    if (nItem.FEntity = nEntity) and (nItem.FMenuID = nMenuID) then
    begin
      Result := nItem; Break;
    end;

    if Assigned(nItem.FSubMenu) then
    begin
      Result := FindMenuItem(nItem.FSubMenu, nEntity, nMenuID);
      if Assigned(Result) then Break;
    end;
  end;
end;

//Date: 2007-11-08
//Parm: 实体标识;菜单标识
//Desc: 检索标识为nMenuID的菜单项
function TBaseMenuManager.GetMenuItem(const nEntity,nMenuID: string): PMenuItemData;
begin
  Result := FindMenuItem(FItemList, UpperCase(nEntity), UpperCase(nMenuID));
end;

//Date: 2007-11-9
//Parm: 查询SQl;数据集;是否自动释放
//Desc: 执行nSQL语句,数据集放置在nDS中
function TBaseMenuManager.SafeQuery(const nSQL: string; var nDS: TDataSet;
  var nAutoFree: Boolean): Boolean;
begin
  nDS := nil;
  nAutoFree := False;
  Result := QuerySQL(nSQL, nDS, nAutoFree) and Assigned(nDS);

  if not Result then
  begin
    HintMsg(Format(sQueryError, [GetItemValue(cMenuTable_Menu)]));
  end else

  if nDS.RecordCount < 1 then
  begin
    Result := False;
    HintMsg(Format(sNoRecord, [GetItemValue(cMenuTable_Menu)]));
  end;

  if (not Result) and nAutoFree and Assigned(nDS) then
  begin
    FreeDataSet(nDS); nDS := nil;
  end;
end;

//Desc: 释放数据集
procedure TBaseMenuManager.FreeDataSet(const nDS: TDataSet);
begin
  nDS.Free;
end;

//Date: 2007-11-8
//Parm: 程序标识
//Desc: 载入nProID程序的所有实体的菜单项
function TBaseMenuManager.LoadMenuFromDB(const nProgID: string): Boolean;
var nStr,nLang: string;
    nDS: TDataSet;
    nFree: Boolean;
    nItem: PMenuItemData;
begin
  Result := False;
  ClearItemList(FItemList);
  //清空原有内容

  nLang := 'and (M_LangID=''%s'' Or M_LangID='''' or M_LangID Is Null)';
  //语言过滤

  if FLangID = '' then
       nLang := ''
  else nLang := Format(nLang, [FLangID]);

  nStr := GetItemValue(cMenuTable_Menu);
  nStr := MacroValue(sSelectMenu, [MI('$Table', nStr),
          MI('$ID', nProgID), MI('$Lang', nLang)]);
  if not SafeQuery(nStr, nDS, nFree) then Exit;

  nDS.First;
  while not nDS.Eof do
  begin
    New(nItem);
    FItemList.Add(nItem);
    nItem.FSubMenu := nil;

    nItem.FProgID := nDS.FieldByName('M_ProgID').AsString;
    nItem.FEntity := nDS.FieldByName('M_Entity').AsString;
    nItem.FEntity := UpperCase(nItem.FEntity);

    nItem.FMenuID := nDS.FieldByName('M_MenuID').AsString;
    nItem.FMenuID := UpperCase(nItem.FMenuID);
    nItem.FPMenu := nDS.FieldByName('M_PMenu').AsString;
    nItem.FPMenu := UpperCase(nItem.FPMenu);

    nItem.FTitle := nDS.FieldByName('M_Title').AsString;
    nItem.FImgIndex := nDS.FieldByName('M_ImgIndex').AsInteger;
    nItem.FFlag := nDS.FieldByName('M_Flag').AsString;
    nItem.FAction := nDS.FieldByName('M_Action').AsString;
    nItem.FFilter := nDS.FieldByName('M_Filter').AsString;

    nItem.FPopedom := nDS.FieldByName('M_Popedom').AsString;
    nItem.FNewOrder := nDS.FieldByName('M_NewOrder').AsFloat;

    nDS.Next;
    //下移游标
  end;

  if nFree and Assigned(nDS) then
    FreeDataSet(nDS);
  Result := BuildMenuTree(FItemList);
  //构建菜单层次树
end;

//Date: 2007-11-8
//Parm: 未排序的列表
//Desc: 将nList按菜单层次构建一个树
function TBaseMenuManager.BuildMenuTree(const nList: TList): Boolean;
var nIdx: integer;
    nItem,nPItem: PMenuItemData;
begin
  nIdx := 0;
  nPItem := nil;

  while nIdx < nList.Count do
  begin
    nItem := nList[nIdx];
    if nItem.FPMenu = '' then
    begin
      Inc(nIdx); Continue;
    end;
    //没有父节点的是一级菜单或实体标识

    if not (Assigned(nPItem) and (nPItem.FMenuID = nItem.FPMenu) and
       (nPItem.FEntity = nItem.FEntity)) then
      nPItem := FindMenuItem(nList, nItem.FEntity, nItem.FPMenu);
    //寻找父节点

    if not Assigned(nPItem) then
    begin
      if Assigned(nItem.FSubMenu) then
      begin
        ClearItemList(nItem.FSubMenu);
        nItem.FSubMenu.Free;
        //释放子节点
      end;

      Dispose(nItem);
      nList.Delete(nIdx); Continue;
    end;
    //未找到父节点,则释放不予处理

    if not Assigned(nPItem.FSubMenu) then
      nPItem.FSubMenu := TList.Create;
    nPItem.FSubMenu.Add(nItem);
    //追加到父节点下

    nList.Delete(nIdx);
    //从主队列删除
  end;

  Result := nList.Count > 0;
  //没有一级菜单项是不正常的
end;

//------------------------------------------------------------------------------
//Desc: 获取程序标识列表
function TBaseMenuManager.GetProgList: TList;
var nStr: string;
    nDS: TDataSet;
    nFree: Boolean;
    nItem: PMenuItemData;
begin
  if Assigned(FProList) then
       ClearItemList(FProList)
  else FProList := TList.Create;

  Result := FProList;
  nStr := GetItemValue(cMenuTable_Menu);

  nStr := MacroValue(sSelectProID, [MI('$Table', nStr)]);
  if not SafeQuery(nStr, nDS, nFree) then Exit;

  nDS.First;
  while not nDS.Eof do
  begin
    New(nItem);
    FProList.Add(nItem);
    FillChar(nItem^, cMenuItemDataSize, #0);

    nItem.FProgID := nDS.FieldByName('M_ProgID').AsString;
    nItem.FTitle := nDS.FieldByName('M_Title').AsString;
    nDS.Next;
  end;

  if nFree then
    FreeDataSet(nDS);
  //自动释放数据集
end;

//Date: 2007-11-09
//Parm: 结果列表
//Desc: 查询当前程序中的实体列表,有数据返回真
function TBaseMenuManager.GetEntityList(const nList: TList): Boolean;
var i,nCount: integer;
    nItem: PMenuItemData;
begin
  Result := False;
  if Assigned(nList) then
       nList.Clear
  else Exit;

  nCount := FItemList.Count - 1;
  for i:=0 to nCount do
  begin
    nItem := FItemList[i];
    if nItem.FMenuID = '' then nList.Add(nItem);
  end;

  Result := nList.Count > 0;
end;

//Date: 2007-11-9
//Parm: 结果列表;实体标识
//Desc: 查询nEntity实体对应的顶级菜单列表,有数据返回真
function TBaseMenuManager.GetMenuList(const nList: TList; const nEntity: string): Boolean;
var nStr: string;
    i,nCount: integer;
    nItem: PMenuItemData;
begin
  Result := False;
  if Assigned(nList) then
       nList.Clear
  else Exit;

  nStr := UpperCase(nEntity);
  nCount := FItemList.Count - 1;

  for i:=0 to nCount do
  begin
    nItem := FItemList[i];
    if (nItem.FEntity = nStr) and (nItem.FMenuID <> '') then nList.Add(nItem);
  end;

  Result := nList.Count > 0;
end;

end.
