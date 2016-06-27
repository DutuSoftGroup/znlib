{*******************************************************************************
  作者: dmzn@ylsoft.com 2008-01-03
  描述: 支持权限组,用户两级模式的权限管理器

  备注:
  &.权限项由0-9,A-Z共36个权限标记组成.
  &.用户拥有所在组的权限.
*******************************************************************************}
unit UMgrPopedom;

interface

uses
  Windows, Classes, SysUtils, DB, ULibFun;

const
  cPopedomTable_User    = $0001;
  cPopedomTable_Group   = $0002;
  cPopedomTable_Popedom = $0003;
  cPopedomTable_PopItem = $0005;

  cPopedomUser_Admin    = $0000;  //管理员
  cPopedomUser_User     = $0001;  //普通用户,对应表User.U_Identity

  cPopedomUser_Forbid   = $0000;  //帐户禁用
  cPopedomUser_Normal   = $0001;  //帐户正常,对应表User.U_Status

  cPopedomGroup_CanDel  = $0000;  //可以删除
  cPopedomGroup_NoDel   = $0001;  //不可删除,对应Group.G_CANDEL

type
  PPopedomItemData = ^TPopedomItemData;
  TPopedomItemData = record
    FItem: string;            //对象
    FPopedom: string;         //权限
  end;

  PGroupItemData = ^TGroupItemData;
  TGroupItemData = record
    FID: string;              //组标识
    FName: string;            //组名称
    FDesc: string;            //组描述
    FUser: TStrings;          //所属用户
    FPopedom: TList;          //权限列表
  end;

  THintMsg = procedure (const nMsg: string) of Object;
  //提示信息

  TBasePopedomManager = class(TObject)
  private
    FGroupList: TList;
    {*权限组列表*}
    FHintMsg: THintMsg;
    {事件}
  protected
    procedure HintMsg(const nMsg: string);
    {*提示信息*}
    procedure ClearPopedom(const nList: TList);
    procedure ClearItemList(const nList: TList);
    {*清空组列表*}

    function LoadGroupData(const nList: TList): Boolean;
    function LoadGroupUser(const nGroup: PGroupItemData): Boolean;
    function LoadGroupPopedom(const nGroup: PGroupItemData): Boolean;
    {*载入组数据*}
    
    function SafeQuery(const nSQL,nTable: string;
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
    function CreateUserTable: Boolean;
    function CreateGroupTable: Boolean;
    function CreatePopedomTable: Boolean;
    function CreatePopItemTable: Boolean;
    {*创建表*}
    function LoadGroupFromDB(const nProgID: string): Boolean;
    function LoadPopItemList(const nList: TStrings; const nProgID: string = ''): Boolean;
    {*读取权限*}

    function FindGroupByID(const nGroup: string): PGroupItemData;
    function FindGroupByUser(const nUser: string): PGroupItemData;
    function FindUserPopedom(const nUser,nItem: string): string;
    function FindGroupPopedom(const nGroup,nItem: string): string;
    {*检索*}

    property Groups: TList read FGroupList;
    property OnHintMsg: THintMsg read FHintMsg write FHintMsg;
    {属性,事件}
  end;

implementation

ResourceString
  sCreateUser = 'Create Table $User(' +
                'U_Name VARCHAR(32),' +                   //用户名
                'U_Password VARCHAR(16),' +               //密码
                'U_Mail VARCHAR(25),' +                   //邮件
                'U_Phone VARCHAR(15),' +                  //电话
                'U_Memo VARCHAR(50),' +                   //备注
                'U_Identity SMALLINT DEFAULT 1,' +        //身份标记(0,管理员;其它,一般用户)
                'U_State SMALLINT DEFAULT 1,' +           //状态(0,禁用;其它,正常)
                'U_Group SMALLINT DEFAULT 0)';            //所在组
  //table user's create sql

  sCreateGroup = 'Create Table $Group(' +
                 'G_ID SMALLINT NOT NULL,' +              //组标识
                 'G_PROGID VARCHAR(15) NOT NULL,' +       //程序标识
                 'G_NAME VARCHAR(20) NOT NULL,' +         //组名称
                 'G_DESC VARCHAR(50),' +                  //组描述
                 'G_CANDEL SMALLINT DEFAULT 0)';           //可删除
  //table group's create sql

  sCreatePopedom = 'Create Table $Popedom(' +
                   'P_GROUP SMALLINT NOT NULL,' +         //组标识
                   'P_ITEM VARCHAR(20) NOT NULL,' +       //对象标识
                   'P_POPEDOM VARCHAR(36))';              //权限值
  //table popedom's create sql

  sCreatePopItem = 'Create Table $PopItem(' +
                   'P_ID Char(1),' +                      //权限项标记
                   'P_ProgID VARCHAR(15) NOT NULL,' +     //程序标记
                   'P_Name VARCHAR(20))';                 //权限项名称
  //table popedom's create sql

  sSelectGroup = 'Select * From $Group Where G_PROGID=''$PID'' Order By G_ID';
  //select a program's group items

  sSelectPopedom = 'Select * From $Popedom Where P_GROUP=$Group';
  //select a group's popedom items

  sSelectUser = 'Select U_Name,U_Group From $UserTable Where U_Group=$ID';
  //select a group's all user

  sSelctPopItem = 'Select * From $PopItem Order By P_ID';
  //select all popedom item

  sNoTable = '无法定位到"%s"表';
  sNoRecord = '"%s"表为空,没有数据';
  sQueryError = '查询"%s"表失败,无法读取数据';

//------------------------------------------------------------------------------
constructor TBasePopedomManager.Create;
begin
  FGroupList := TList.Create;
end;

destructor TBasePopedomManager.Destroy;
begin
  ClearItemList(FGroupList);
  FGroupList.Free;
  inherited;
end;

//Date: 2008-01-03
//Parm: 消息内容
//Desc: 出发HintMsg事件,提示nMsg消息
procedure TBasePopedomManager.HintMsg(const nMsg: string);
begin
  if Assigned(FHintMsg) then FHintMsg(nMsg);
end;

//Date: 2008-01-03
//Parm: 列表
//Desc: 释放nList中所有的元素
procedure TBasePopedomManager.ClearPopedom(const nList: TList);
var nIdx: integer;
begin
  for nIdx := nList.Count - 1 downto 0 do
  begin
    Dispose(PPopedomItemData(nList[nIdx]));
    nList.Delete(nIdx);
  end;
end;

//Date: 2008-01-03
//Parm: 列表
//Desc: 释放nList中所有的元素
procedure TBasePopedomManager.ClearItemList(const nList: TList);
var nIdx: integer;
    nGroup: PGroupItemData;
begin
  for nIdx := FGroupList.Count - 1 downto 0 do
  begin
    nGroup := FGroupList[nIdx];
    if Assigned(nGroup.FUser) then
      nGroup.FUser.Free;
    //free user list

    if Assigned(nGroup.FPopedom) then
    begin
      ClearPopedom(nGroup.FPopedom);
      nGroup.FPopedom.Free;
    end;

    Dispose(nGroup);
    FGroupList.Delete(nIdx);
  end;
end;

//Date: 2008-01-03
//Desc: 创建权限组表,若表已存在则直接返回真
function TBasePopedomManager.CreateGroupTable: Boolean;
var nStr: string;
begin
  nStr := GetItemValue(cPopedomTable_Group);
  Result := IsTableExists(nStr);

  if not Result then
  try
    nStr := MacroValue(sCreateGroup, [MI('$Group', nStr)]);
    Result := ExecSQL(nStr) > -1;
  except
    //ignor any error
  end;
end;

//Date: 2008-01-03
//Desc: 创建权限表,若表已存在则直接返回真
function TBasePopedomManager.CreatePopedomTable: Boolean;
var nStr: string;
begin
  nStr := GetItemValue(cPopedomTable_Popedom);
  Result := IsTableExists(nStr);

  if not Result then
  try
    nStr := MacroValue(sCreatePopedom, [MI('$Popedom', nStr)]);
    Result := ExecSQL(nStr) > -1;
  except
    //ignor any error
  end;
end;

//Desc: 创建权限项表
function TBasePopedomManager.CreatePopItemTable: Boolean;
var nStr: string;
begin
  nStr := GetItemValue(cPopedomTable_PopItem);
  Result := IsTableExists(nStr);

  if not Result then
  try
    nStr := MacroValue(sCreatePopItem, [MI('$PopItem', nStr)]);
    Result := ExecSQL(nStr) > -1;
  except
    //ignor any error
  end;
end;

//Desc: 创建用户表
function TBasePopedomManager.CreateUserTable: Boolean;
var nStr: string;
begin
  nStr := GetItemValue(cPopedomTable_User);
  Result := IsTableExists(nStr);

  if not Result then
  try
    nStr := MacroValue(sCreateUser, [MI('$User', nStr)]);
    Result := ExecSQL(nStr) > -1;
  except
    //ignor any error
  end;
end;

//Desc: 释放数据集
procedure TBasePopedomManager.FreeDataSet(const nDS: TDataSet);
begin
  nDS.Free;
end;

//Date: 2008-01-03
//Parm: 查询SQl;表名;数据集;是否自动释放
//Desc: 执行nSQL语句,数据集放置在nDS中
function TBasePopedomManager.SafeQuery(const nSQL,nTable: string;
  var nDS: TDataSet; var nAutoFree: Boolean): Boolean;
begin
  nDS := nil;
  nAutoFree := False;
  Result := QuerySQL(nSQL, nDS, nAutoFree) and Assigned(nDS);

  if not Result then
  begin
    HintMsg(Format(sQueryError, [nTable]));
  end else

  if nDS.RecordCount < 1 then
  begin
    Result := False;
    HintMsg(Format(sNoRecord, [nTable]));
  end;

  if (not Result) and nAutoFree and Assigned(nDS) then
  begin
    FreeDataSet(nDS); nDS := nil;
  end;
end;

//Date: 2008-01-03
//Parm: 程序标识
//Desc: 载入nProgID程序所拥有的组信息
function TBasePopedomManager.LoadGroupFromDB(const nProgID: string): Boolean;
var nStr: string;
    nDS: TDataSet;
    nFree: Boolean;
    nTable: string;
    nGroup: PGroupItemData;
begin
  Result := False;
  ClearItemList(FGroupList);
  //清空原有内容

  nTable := GetItemValue(cPopedomTable_Group);
  nStr := MacroValue(sSelectGroup, [MI('$Group', nTable), MI('$PID', nProgID)]);
  if not SafeQuery(nStr, nTable, nDS, nFree) then Exit;

  nDS.First;
  while not nDS.Eof do
  begin
    New(nGroup);
    FGroupList.Add(nGroup);
    nGroup.FUser := nil;
    nGroup.FPopedom := nil;

    nGroup.FID := nDS.FieldByName('G_ID').AsString;
    nGroup.FName := nDS.FieldByName('G_NAME').AsString;
    nGroup.FDesc := nDS.FieldByName('G_DESC').AsString;

    nDS.Next;
    //下移游标
  end;

  if nFree and Assigned(nDS) then
    FreeDataSet(nDS);
  Result := LoadGroupData(FGroupList);
end;

//Desc: 载入权限组的用户,权限信息
function TBasePopedomManager.LoadGroupData(const nList: TList): Boolean;
var i,nCount: integer;
begin
  Result := True;
  nCount := nList.Count - 1;

  for i:=0 to nCount do
  begin
    LoadGroupUser(nList[i]);
    LoadGroupPopedom(nList[i]);
  end;
end;

//Desc: 载入nGroup的权限信息
function TBasePopedomManager.LoadGroupPopedom(const nGroup: PGroupItemData): Boolean;
var nStr: string;
    nDS: TDataSet;
    nFree: Boolean;
    nTable: string;
    nItem: PPopedomItemData;
begin
  Result := False;
  nTable := GetItemValue(cPopedomTable_Popedom);

  nStr := MacroValue(sSelectPopedom, [MI('$Popedom', nTable), MI('$Group', nGroup.FID)]);
  if not SafeQuery(nStr, nTable, nDS, nFree) then Exit;

  if Assigned(nGroup.FPopedom) then
       ClearPopedom(nGroup.FPopedom)
  else nGroup.FPopedom := TList.Create;
  
  nDS.First;
  while not nDS.Eof do
  begin
    New(nItem);
    nGroup.FPopedom.Add(nItem);

    nItem.FItem := nDS.FieldByName('P_ITEM').AsString;
    nItem.FPopedom := nDS.FieldByName('P_POPEDOM').AsString;

    nDS.Next;
    //下移游标
  end;

  if nFree and Assigned(nDS) then
    FreeDataSet(nDS);
  Result := True;
end;

//Desc: 载入nGroup组的用户信息
function TBasePopedomManager.LoadGroupUser(const nGroup: PGroupItemData): Boolean;
var nStr: string;
    nDS: TDataSet;
    nFree: Boolean;
    nTable: string;
begin
  Result := False;
  nTable := GetItemValue(cPopedomTable_User);

  nStr := MacroValue(sSelectUser, [MI('$UserTable', nTable), MI('$ID', nGroup.FID)]);
  if not SafeQuery(nStr, nTable, nDS, nFree) then Exit;

  if Assigned(nGroup.FUser) then
       nGroup.FUser.Clear
  else nGroup.FUser := TStringList.Create;
  
  nDS.First;
  while not nDS.Eof do
  begin
    nStr := nDS.FieldByName('U_Name').AsString;
    nGroup.FUser.Add(nStr);
    nDS.Next;
  end;

  if nFree and Assigned(nDS) then
    FreeDataSet(nDS);
  Result := True;
end;

//Desc: 载入权限项列表,格式: ID;ProgID;Name
function TBasePopedomManager.LoadPopItemList(const nList: TStrings;
  const nProgID: string): Boolean;
var nStr: string;
    nDS: TDataSet;
    nFree: Boolean;
    nTable: string;
begin
  nList.Clear;
  Result := False;

  nTable := GetItemValue(cPopedomTable_PopItem);
  nStr := MacroValue(sSelctPopItem, [MI('$PopItem', nTable)]);

  if not SafeQuery(nStr, nTable, nDS, nFree) then Exit;

  nDS.First;
  while not nDS.Eof do
  begin
    nStr := nDS.FieldByName('P_ProgID').AsString;
    if (nProgID = '') or (nProgID = nStr) then
    begin
      if nProgID = '' then
           nStr := nDS.FieldByName('P_ID').AsString + ';' + nStr
      else nStr := nDS.FieldByName('P_ID').AsString;
      nStr := nStr + ';' + nDS.FieldByName('P_Name').AsString;
      nList.Add(nStr);
    end;

    nDS.Next;
  end;

  if nFree and Assigned(nDS) then
    FreeDataSet(nDS);
  Result := nList.Count > 0;
end;

//------------------------------------------------------------------------------
//Desc: 查找名称为nGroup的组信息
function TBasePopedomManager.FindGroupByID(const nGroup: string): PGroupItemData;
var i,nCount: integer;
    nItem: PGroupItemData;
begin
  Result := nil;
  nCount := FGroupList.Count - 1;

  for i:=0 to nCount do
  begin
    nItem := FGroupList[i];
    if nItem.FID = nGroup then
    begin
      Result := nItem; Break;
    end;
  end;
end;

//Desc: 查找用户nUser所在的组信息
function TBasePopedomManager.FindGroupByUser(const nUser: string): PGroupItemData;
var i,nCount: integer;
    nGroup: PGroupItemData;
begin
  Result := nil;
  nCount := FGroupList.Count - 1;

  for i:=0 to nCount do
  begin
    nGroup := FGroupList[i];
    if Assigned(nGroup.FUser) and (nGroup.FUser.IndexOf(nUser) > -1) then
    begin
      Result := nGroup; Break;
    end;
  end;
end;

//Desc: 查找用户nUser对nItem对象的权限值
function TBasePopedomManager.FindUserPopedom(const nUser, nItem: string): string;
var i,nCount: integer;
    nGroup: PGroupItemData;
    nPopedom: PPopedomItemData;
begin
  Result := '';
  nGroup := FindGroupByUser(nUser);
  if not (Assigned(nGroup) and Assigned(nGroup.FPopedom)) then Exit;

  nCount := nGroup.FPopedom.Count - 1;
  for i:=0 to nCount do
  begin
    nPopedom := nGroup.FPopedom[i];
    if CompareText(nPopedom.FItem, nItem) = 0 then
    begin
      Result := nPopedom.FPopedom; Break;
    end;
  end;
end;

//Desc: 查找权限组nGroup对nItem对象的权限值
function TBasePopedomManager.FindGroupPopedom(const nGroup, nItem: string): string;
var i,nCount: integer;
    nData: PGroupItemData;
    nPopedom: PPopedomItemData;
begin
  Result := '';
  nData := FindGroupByID(nGroup);
  if not (Assigned(nData) and Assigned(nData.FPopedom)) then Exit;

  nCount := nData.FPopedom.Count - 1;
  for i:=0 to nCount do
  begin
    nPopedom := nData.FPopedom[i];
    if CompareText(nPopedom.FItem, nItem) = 0 then
    begin
      Result := nPopedom.FPopedom; Break;
    end;
  end;
end;

end.
