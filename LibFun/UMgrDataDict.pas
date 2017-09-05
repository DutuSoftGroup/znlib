{*******************************************************************************
  作者: dmzn@163.com 2008-8-22
  描述: 数据字典管理器

  备注:
  &.数据字典主要用于初始化ListView,cxGrid等数据表格,字典管理中维护了一组与之
    相关的配置数据.
  &.字典分两级管理: 程序模块,模块下多个实体,每个实体对应一组数据项.
  &.字典管理器使用ProgID属性,来标识当前所有实体所归属的程序.
  &.字典数据由数据库加载,即用即请求,管理器会缓存,所以每个实体数据只加载一次.
  &.读取时调用LoadEntity,若成功则该实体会被激活,直接读取ActiveEntity就可以了.
*******************************************************************************}
unit UMgrDataDict;

interface

uses
  Windows, Classes, DB, SysUtils, ULibFun;

const
  cDictTable_Entity = $0001;
  cDictTable_DataDict = $0002;

type
  TDictFormatStyle = (fsNone, fsFixed, fsSQL, fsCheckBox);
  //格式化方式: 固定数据,数据库数据

  PDictFormatItem = ^TDictFormatItem;
  TDictFormatItem = record
    FStyle: TDictFormatStyle;       //方式
    FData: string;                  //数据
    FFormat: string;                //格式化
    FExtMemo: string;               //扩展数据
  end;

  PDictDBItem = ^TDictDBItem;
  TDictDBItem = record
    FTable: string;                 //表名
    FField: string;                 //字段
    FIsKey: Boolean;                //主键

    FType: TFieldType;              //数据类型
    FWidth: integer;                //字段宽度
    FDecimal: integer;              //小数位
  end;

  TDictFooterKind = (fkNone, fkSum, fkMin, fkMax, fkCount, fkAverage);
  //统计类型: 无,合计,最小,最大,数目,平均值
  TDictFooterPosition = (fpNone, fpFooter, fpGroup, fpAll);
  //合计位置: 页脚,分组,两者都有

  PDictGroupFooter = ^TDictGroupFooter;
  TDictGroupFooter = record
    FDisplay: string;               //显示文本
    FFormat: string;                //格式化
    FKind: TDictFooterKind;         //合计类型
    FPosition: TDictFooterPosition; //合计位置
  end;

  PDictItemData = ^TDictItemData;
  TDictItemData = record
    FItemID: integer;               //标识
    FTitle: string;                 //标题
    FAlign: TAlignment;             //对齐
    FWidth: integer;                //宽度
    FIndex: integer;                //顺序
    FVisible: Boolean;              //可见
    FLangID: string;                //语言
    FDBItem: TDictDBItem;           //数据库
    FFormat: TDictFormatItem;       //格式化
    FFooter: TDictGroupFooter;      //页脚合计
  end;

  PEntityItemData = ^TEntityItemData;
  TEntityItemData = record
    FProgID: string;               //程序标记
    FEntity: string;               //实体标记
    FTitle: string;                //实体名称
    FDictItem: TList;              //字典数据,一组TDictItemData
  end;

  THintMsg = procedure (const nMsg: string) of Object;
  //提示信息

  TBaseEntityManager = class(TObject)
  private
    FEntityList: TList;
    {*实体列表*}
    FProgList: TList;
    {*程序列表*}
    FProgID: string;
    {*程序标记*}
    FLangID: string;
    {*语言标识*}
    FActiveIndex: integer;
    {*实体索引*}
    FHintMsg: THintMsg;
    {事件}
  protected
    procedure HintMsg(const nMsg: string);
    {*提示信息*}
    function MakeDictEntity(const nEntity: string): string;
    {*字典实体*}

    function LoadEntityFromDB(const nEntity: string): Boolean;
    function LoadDictItemFromDB(const nEntity: string): Boolean;
    {*读取数据*}
    function EntityItemIndex(const nEntity: string): integer;
    procedure FreeEntityItem(const nEntity: string); overload;
    procedure FreeEntityItem(const nIdx: integer); overload;
    {*释放数据*}
    procedure ClearDictItems(const nEntity: PEntityItemData);
    procedure ClearProgList;
    procedure ClearEntityList;
    {*清理数据*}      
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
    function CreateTable: Boolean;
    {*创建表*}
    function AddEntityToDB(const nEntity: TEntityItemData): Boolean;
    function AddDictItemToDB(const nEntity: string; const nDict: TDictItemData): Boolean;
    function DelEntityFromDB(const nProgID,nEntity: string): Boolean;
    function DelDictEntityItem(const nEntity: string): Boolean;
    function DelDictItemFromDB(const nEntity: string; const nID: integer): Boolean;
    {*添加删除*}
    function LoadEntity(const nEntity: string; const nForceDB: Boolean=False): Boolean;
    {*读取数据*}
    function LoadProgList: Boolean;
    {*实体列表*}
    function UpdateActiveDictItem(const nItemID: integer; const nWidth: integer = MaxInt;
      const nIndex: integer = MaxInt): Boolean;
    function GetActiveEntity: PEntityItemData;
    function GetActiveDictItem(const nItemID: integer): PDictItemData;
    {*活动对象*}
    property ActiveEntity: PEntityItemData read GetActiveEntity;
    property ProgList: TList read FProgList;
    property ProgID: string read FProgID write FProgID;
    property LangID: string read FLangID write FLangID;
    property OnHintMsg: THintMsg read FHintMsg write FHintMsg;
    {属性,事件}
  end;   

implementation

ResourceString
  sNoTable = '无法定位到"%s"表';
  sNoRecord = '"%s"表为空,没有数据';
  sQueryError = '查询"%s"表失败,无法读取数据';

  sCreateEntity = 'Create Table $Table(' +
                  'E_ProgID varchar(15),' +                 //程序标识
                  'E_Entity varchar(20),' +                 //实体标识
                  'E_Title varchar(50))';                   //实体标题
  //entity create sql

  sInsertEntity = 'Insert Into $Table Values(''$ProgID'', ''$Entity'', ''$Title'')';
  //entity insert sql
  sDeleteEntity = 'Delete From $Table Where E_ProgID=''$PID'' And E_Entity=''$Entity''';
  //entity delete sql

  sCreateDict = 'Create Table $Table(' +
                'D_ItemID integer,' +                       //数据标记
                'D_Entity varchar(35),' +                   //所属实体
                'D_Title  varchar(30),' +                   //数据标题
                'D_Align smallint,' +                       //标题对齐
                'D_Width integer,' +                        //标题宽度
                'D_Index integer,' +                        //标题顺序
                'D_Visible smallint,' +                     //是否可见
                'D_LangID varchar(12),' +                   //语言标识

                'D_DBTable varchar(32),' +                  //表名称
                'D_DBField varchar(32),' +                  //字段名
                'D_DBIsKey smallint,' +                     //是否主键
                'D_DBType smallint,' +                      //数据类型
                'D_DBWidth smallint,' +                     //字段宽度
                'D_DBDecimal smallint,' +                   //小数位

                'D_FmtStyle smallint,' +                    //格式化方式
                'D_FmtData varchar(200),' +                 //格式化数据
                'D_FmtFormat varchar(100),' +               //格式化内容
                'D_FmtExtMemo varchar(100),' +              //格式化扩展

                'D_FteDisplay varChar(50),' +               //统计显示文本
                'D_FteFormat varChar(50),' +                //统计格式化
                'D_FteKind smallint,' +                     //统计类型
                'D_FtePositon smallint)';                   //统计显示位置
  //datadict create sql

  sInsertDict = 'Insert Into $Dict(D_ItemID,D_Entity,D_Title,D_Align,D_Width,' +
                'D_Index,D_Visible,D_LangID,D_DBTable,D_DBField,D_DBIsKey,' +
                'D_DBType,D_DBWidth,D_DBDecimal,D_FmtStyle,D_FmtData,' +
                'D_FmtFormat,D_FmtExtMemo,D_FteDisplay,D_FteFormat,D_FteKind,' +
                'D_FtePositon' +
                ') Values ($ItemID, ''$Entity'', ''$Title'',' +
                '$Align, $Width, $Index, $Visible, $LangID, ''$DBTable'', ''$DBField'',' +
                '$DBIsKey, $DBType, $DBWidth, $DBDecima, $FmtStyle, ''$FmtData'',' +
                '''$FmtFormat'', ''$FmtExtMemo'', ''$FteDisplay'', ''$FteFormat'',' +
                '$FteKind, $FtePosition)';
  //dict item insert sql

  sSelectDictID = 'Select Max(D_ItemID) From $Dict Where D_Entity=''$Entity''';
  //get item id
  sDeleteEntityItem = 'Delete From $Dict Where D_Entity=''$Entity''';
  //delete entity's all items
  sDeleteDictItem = 'Delete From $Dict Where D_Entity=''$Entity'' And D_ItemID=$ID';
  //delete dict item
  sUpdateDictItem = 'Update $Dict Set $Set Where D_Entity=''$Entity'' And D_ItemID=$ID';
  //update dict item

  sSelectEntitys = 'Select * From $Table';
  //select all entity items

  sSelectEntity = 'Select * From $Table Where E_ProgID=''$ID'' And E_Entity=''$Entity''';
  //select a progrma's fix entity

  sSelectDict = 'Select * From $Table Where D_Entity=''$Entity'' ' +
                '$Lang Order By D_Index';
  //select a entity's data dict items

//------------------------------------------------------------------------------  
constructor TBaseEntityManager.Create;
begin
  FProgID := '';
  FLangID := '';
  FActiveIndex := -1;

  FProgList := TList.Create;
  FEntityList := TList.Create;
end;

destructor TBaseEntityManager.Destroy;
begin
  ClearProgList;
  FProgList.Free;

  ClearEntityList;
  FEntityList.Free;
  inherited;
end;

//Desc: 出发HintMsg事件,提示nMsg消息
procedure TBaseEntityManager.HintMsg(const nMsg: string);
begin
  if Assigned(FHintMsg) then FHintMsg(nMsg);
end;

//Desc: 清空实体列表
procedure TBaseEntityManager.ClearEntityList;
var nIdx: integer;
begin
  for nIdx:=FEntityList.Count - 1 downto 0 do FreeEntityItem(nIdx);
end;

//Desc: 清空程序列表
procedure TBaseEntityManager.ClearProgList;
var nIdx: integer;
begin
  for nIdx:=FProgList.Count - 1 downto 0 do
  begin
    Dispose(PEntityItemData(FProgList[nIdx]));
    FProgList.Delete(nIdx);
  end;
end;

//Desc: 检索标记为nEntity实体的索引
function TBaseEntityManager.EntityItemIndex(const nEntity: string): integer;
var nIdx: integer;
    nItem: PEntityItemData;
begin
  nItem := ActiveEntity;
  if Assigned(nItem) and (CompareText(nEntity, nItem.FEntity) = 0) then
  begin
    Result := FActiveIndex; Exit;
  end else Result := -1;

  for nIdx:=FEntityList.Count - 1 downto 0 do
  if CompareText(PEntityItemData(FEntityList[nIdx]).FEntity, nEntity) = 0 then
  begin
    Result := nIdx; Break;
  end;
end;

//Desc: 释放标记为nEntity的实体
procedure TBaseEntityManager.FreeEntityItem(const nEntity: string);
var nIdx: integer;
begin
  nIdx := EntityItemIndex(nEntity);
  if nIdx > -1 then FreeEntityItem(nIdx);
end;

//Desc: 释放索引为nIdx的实体
procedure TBaseEntityManager.FreeEntityItem(const nIdx: integer);
var nEntity: PEntityItemData;
begin
  nEntity := FEntityList[nIdx];
  if Assigned(nEntity.FDictItem) then
  begin
    ClearDictItems(nEntity);
    nEntity.FDictItem.Free;
  end;

  Dispose(nEntity);
  FEntityList.Delete(nIdx);
  if nIdx = FActiveIndex then FActiveIndex := -1;
end;

//Desc: 释放nEntity的字典项
procedure TBaseEntityManager.ClearDictItems(const nEntity: PEntityItemData);
var nIdx: integer;
begin
  if Assigned(nEntity.FDictItem) then
   for nIdx:=nEntity.FDictItem.Count - 1 downto 0 do
   begin
     Dispose(PDictItemData(nEntity.FDictItem[nIdx]));
     nEntity.FDictItem.Delete(nIdx);
   end;
end;

//Desc: 获取当前活动的实体
function TBaseEntityManager.GetActiveEntity: PEntityItemData;
begin
  if (FActiveIndex > -1) and (FActiveIndex < FEntityList.Count) then
       Result := FEntityList[FActiveIndex]
  else Result := nil;
end;

//Desc: 获取当前活动实体中标记为nItemID的字典项
function TBaseEntityManager.GetActiveDictItem(const nItemID: integer): PDictItemData;
var nList: TList;
    i,nCount: integer;
begin
  Result := nil;
  if Assigned(ActiveEntity) and Assigned(ActiveEntity.FDictItem) then
  begin
    nList := ActiveEntity.FDictItem;
    nCount := nList.Count - 1;

    for i:=0 to nCount do
    if PDictItemData(nList[i]).FItemID = nItemID then
    begin
      Result := nList[i]; Break;
    end;
  end;
end;

//Desc: 更新当前活动实体中标记为nItemID的字典项的标题宽度和顺序索引
function TBaseEntityManager.UpdateActiveDictItem(const nItemID, nWidth,
  nIndex: integer): Boolean;
var nStr: string;
    nTable: string;
begin
  Result := False;
  if not Assigned(ActiveEntity) then Exit;

  nStr := '';
  if nWidth < MaxInt then nStr := 'D_Width=' + IntToStr(nWidth);
  if nIndex < MaxInt then
  begin
    if nStr <> '' then nStr := nStr + ',';
    nStr := nStr + 'D_Index=' + IntToStr(nIndex);
  end;

  if nStr = '' then Exit;
  nTable := GetItemValue(cDictTable_DataDict);
  nStr := MacroValue(sUpdateDictItem, [MI('$Dict', nTable), MI('$Set', nStr),
                            MI('$Entity', MakeDictEntity(ActiveEntity.FEntity)),
                            MI('$ID', IntToStr(nItemID))]);
  Result := ExecSQL(nStr) > 0;
end;

//------------------------------------------------------------------------------
//Desc: 释放数据集
procedure TBaseEntityManager.FreeDataSet(const nDS: TDataSet);
begin
  nDS.Free;
end;

//Desc: 创建字典所需表
function TBaseEntityManager.CreateTable: Boolean;
var nStr: string;
begin
  nStr := GetItemValue(cDictTable_Entity);
  Result := IsTableExists(nStr);

  if not Result then
  begin
    nStr := MacroValue(sCreateEntity, [MI('$Table', nStr)]);
    Result := ExecSQL(nStr) > -1;
  end;

  if not Result then Exit;
  nStr := GetItemValue(cDictTable_DataDict);
  Result := IsTableExists(nStr);

  if not Result then
  begin
    nStr := MacroValue(sCreateDict, [MI('$Table', nStr)]);
    Result := ExecSQL(nStr) > -1;
  end;
end;

//Date: 2007-11-9
//Parm: 查询SQl;数据集;是否自动释放
//Desc: 执行nSQL语句,数据集放置在nDS中
function TBaseEntityManager.SafeQuery(const nSQL,nTable: string;
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

//------------------------------------------------------------------------------
//Desc: 构件nEntity实体对应的字典项实体
function TBaseEntityManager.MakeDictEntity(const nEntity: string): string;
begin
  Result := FProgID + '_' + nEntity;
end;

//Date: 2008-8-23
//Parm: 实体;字典项
//Desc: 向数据库添加nEntity实体的字典项
function TBaseEntityManager.AddDictItemToDB(const nEntity: string;
  const nDict: TDictItemData): Boolean;
var nStr,nLang: string;
    nIdx: integer;
    nDS: TDataSet;
    nFree: Boolean;
    nTable,nItemID: string;
    nDictItem: PDictItemData;
begin
  Result := False;
  nIdx := EntityItemIndex(nEntity);
  if nIdx < 0 then Exit;

  nTable := GetItemValue(cDictTable_DataDict);
  if nDict.FItemID < 1 then
  begin
    nStr := MacroValue(sSelectDictID, [MI('$Dict', nTable),
                                       MI('$Entity', MakeDictEntity(nEntity))]);
    if not SafeQuery(nStr, nTable, nDS, nFree) then Exit;

    nItemID := IntToStr(nDS.Fields[0].AsInteger + 1);
    if nFree then FreeDataset(nDS);
  end else
  begin
    nItemID := IntToStr(nDict.FItemID);
    DelDictItemFromDB(nEntity, nDict.FItemID);
  end;

  if nDict.FLangID = '' then
       nLang := 'Null'
  else nLang := Format('''%s''', [nDict.FLangID]);

  nStr := MacroValue(sInsertDict, [MI('$Dict', nTable), MI('$ItemID', nItemID),
            MI('$Entity', MakeDictEntity(nEntity)), MI('$Title', nDict.FTitle),
            MI('$Align', IntToStr(Ord(nDict.FAlign))),
            MI('$Width', IntToStr(nDict.FWidth)),
            MI('$Index', IntToStr(nDict.FIndex)),
            MI('$Visible', BoolToStr(nDict.FVisible)),
            MI('$LangID', nLang),
            MI('$DBTable', nDict.FDBItem.FTable),
            MI('$DBField', nDict.FDBItem.FField),
            MI('$DBIsKey', BoolToStr(nDict.FDBItem.FIsKey)),
            MI('$DBType', IntToStr(Ord(nDict.FDBItem.FType))),
            MI('$DBWidth', IntToStr(nDict.FDBItem.FWidth)),
            MI('$DBDecima', IntToStr(nDict.FDBItem.FDecimal)),
            MI('$FmtStyle', IntToStr(Ord(nDict.FFormat.FStyle))),
            MI('$FmtData', nDict.FFormat.FData),
            MI('$FmtFormat', nDict.FFormat.FFormat),
            MI('$FmtExtMemo', nDict.FFormat.FExtMemo),
            MI('$FteDisplay', nDict.FFooter.FDisplay),
            MI('$FteFormat', nDict.FFooter.FFormat),
            MI('$FteKind', IntToStr(Ord(nDict.FFooter.FKind))),
            MI('$FtePosition', IntToStr(Ord(nDict.FFooter.FPosition)))]);
  Result := ExecSQL(nStr) > -1;

  if Result then
  with PEntityItemData(FEntityList[nIdx])^ do
  begin
    if not Assigned(FDictItem) then
      FDictItem := TList.Create;
    New(nDictItem);
    FDictItem.Add(nDictItem);

    nDictItem.FItemID := StrToInt(nItemID);
    nDictItem.FTitle := nDict.FTitle;
    nDictItem.FAlign := nDict.FAlign;
    nDictItem.FWidth := nDict.FWidth;
    nDictItem.FIndex := nDict.FIndex;
    nDictItem.FVisible := nDict.FVisible;
    nDictItem.FLangID := nDict.FLangID;

    nDictItem.FDBItem.FTable := nDict.FDBItem.FTable;
    nDictItem.FDBItem.FField := nDict.FDBItem.FField;
    nDictItem.FDBItem.FIsKey := nDict.FDBItem.FIsKey;
    nDictItem.FDBItem.FType := nDict.FDBItem.FType;
    nDictItem.FDBItem.FWidth := nDict.FDBItem.FWidth;
    nDictItem.FDBItem.FDecimal := nDict.FDBItem.FDecimal;

    nDictItem.FFormat.FStyle := nDict.FFormat.FStyle;
    nDictItem.FFormat.FData := nDict.FFormat.FData;
    nDictItem.FFormat.FFormat := nDict.FFormat.FFormat;
    nDictItem.FFormat.FExtMemo := nDict.FFormat.FExtMemo;

    nDictItem.FFooter.FDisplay := nDict.FFooter.FDisplay;
    nDictItem.FFooter.FFormat := nDict.FFooter.FFormat;
    nDictItem.FFooter.FKind := nDict.FFooter.FKind;
    nDictItem.FFooter.FPosition := nDict.FFooter.FPosition;
  end;
end;

//Date: 2008-8-23
//Parm: 实体项
//Desc: 向数据库添加nEntity实体项
function TBaseEntityManager.AddEntityToDB(const nEntity: TEntityItemData): Boolean;
var nStr: string;
    nIdx: integer;
    nTable: string;
    nEntityItem: PEntityItemData;
begin
  Result := False;
  if not DelEntityFromDB(nEntity.FProgID, nEntity.FEntity) then Exit;
  nTable := GetItemValue(cDictTable_Entity);
  
  nStr := MacroValue(sInsertEntity, [MI('$Table', nTable),
            MI('$ProgID', nEntity.FProgID),
            MI('$Entity', nEntity.FEntity),
            MI('$Title', nEntity.FTitle)]);
  Result := ExecSQL(nStr) > -1;

  if Result and (CompareText(nEntity.FProgID, FProgID) = 0) then
  begin
    nIdx := EntityItemIndex(nEntity.FEntity);
    if nIdx < 0 then
    begin
      New(nEntityItem);
      nEntityItem.FDictItem := nil;
      FEntityList.Add(nEntityItem);
    end else nEntityItem := FEntityList[nIdx];

    nEntityItem.FProgID := nEntity.FProgID;
    nEntityItem.FEntity := nEntity.FEntity;
    nEntityItem.FTitle := nEntity.FTitle;
  end;
end;

//Desc: 从实体nEntity中删除标记为nID的字典项
function TBaseEntityManager.DelDictItemFromDB(const nEntity: string;
  const nID: integer): Boolean;
var nStr: string;
    nTable: string;
    i,nIdx: integer;
    nDictItem: PDictItemData;
begin
  nTable := GetItemValue(cDictTable_DataDict);
  nStr := MacroValue(sDeleteDictItem, [MI('$Dict', nTable),
                          MI('$Entity', MakeDictEntity(nEntity)), MI('$ID', IntToStr(nID))]);
  Result := ExecSQL(nStr) > -1;

  if Result then
  begin
    nIdx := EntityItemIndex(nEntity);
    if nIdx < 0 then Exit;

    with PEntityItemData(FEntityList[nIdx])^ do
     if Assigned(FDictItem) then
      for i:=FDictItem.Count - 1 downto 0 do
      begin
        nDictItem := FDictItem[i];
        if nDictItem.FItemID = nID then
        begin
          Dispose(nDictItem);
          FDictItem.Delete(i); Break;
        end;
      end;
  end;
end;

//Desc: 从数据库删除nEntity实体
function TBaseEntityManager.DelEntityFromDB(const nProgID,nEntity: string): Boolean;
var nStr: string;
    nIdx: integer;
    nTable: string;
begin
  nTable := GetItemValue(cDictTable_Entity);
  nStr := MacroValue(sDeleteEntity, [MI('$Table', nTable),
            MI('$PID', nProgID), MI('$Entity', nEntity)]);
  Result := ExecSQL(nStr) > -1;

  if Result and (CompareText(nProgID, FProgID) = 0) then
  begin
    nIdx := EntityItemIndex(nEntity);
    if nIdx > -1 then FreeEntityItem(nIdx);
  end;
end;

//Desc: 删除nEntity的所有字典项
function TBaseEntityManager.DelDictEntityItem(const nEntity: string): Boolean;
var nStr: string;
    nIdx: integer;
    nTable: string;
begin
  nTable := GetItemValue(cDictTable_DataDict);
  nStr := MacroValue(sDeleteEntityItem, [MI('$Dict', nTable),
            MI('$Entity', MakeDictEntity(nEntity))]);
  Result := ExecSQL(nStr) > -1;

  if Result then
  begin
    nIdx := EntityItemIndex(nEntity);
    if nIdx > -1 then ClearDictItems(FEntityList[nIdx]);
  end;
end;

//------------------------------------------------------------------------------
//Desc: 从数据库载入,或者从缓存读取nEntity实体的字典数据
function TBaseEntityManager.LoadEntity(const nEntity: string;
  const nForceDB: Boolean): Boolean;
var nIdx: integer;
begin
  nIdx := EntityItemIndex(nEntity);
  if (nIdx > -1) and (not nForceDB) then
   begin
     FActiveIndex := nIdx;
     Result := True; Exit;
   end;

  Result := LoadEntityFromDB(nEntity);
  if Result then
  begin
    Result := LoadDictItemFromDB(nEntity);
  end;
end;

//Desc: 从数据库读取nEntity实体
function TBaseEntityManager.LoadEntityFromDB(const nEntity: string): Boolean;
var nStr: string;
    nDS: TDataSet;
    nFree: Boolean;

    nIdx: integer;
    nTable: string;
    nItem: PEntityItemData;
begin
  Result := False;
  nIdx := EntityItemIndex(nEntity);
  if nIdx > -1 then FreeEntityItem(nIdx);

  nTable := GetItemValue(cDictTable_Entity);
  nStr := MacroValue(sSelectEntity, [MI('$Table', nTable), MI('$ID', FProgID),
                                     MI('$Entity', nEntity)]);
  if not SafeQuery(nStr, nTable, nDS, nFree) then Exit;

  New(nItem);
  FActiveIndex := FEntityList.Add(nItem);

  nDS.First;
  nItem.FProgID := FProgID;
  nItem.FEntity := nEntity;
  nItem.FTitle := nDS.FieldByName('E_Title').AsString;
  nItem.FDictItem := nil;

  if nFree then
    FreeDataSet(nDS);
  Result := True;
end;

//Desc: 从数据库读取nEntity的字典项
function TBaseEntityManager.LoadDictItemFromDB(const nEntity: string): Boolean;
var nStr,nLang: string;
    nDS: TDataSet;
    nFree: Boolean;
    nTable: string;

    nIdx: integer;
    nDict: PDictItemData;
    nItem: PEntityItemData;
begin
  Result := False;
  nIdx := EntityItemIndex(nEntity);
  if nIdx < 0 then Exit;

  nLang := 'and (D_LangID=''%s'' Or D_LangID='''' or D_LangID Is Null)';
  //语言过滤

  if FLangID = '' then
       nLang := ''
  else nLang := Format(nLang, [FLangID]);

  nTable := GetItemValue(cDictTable_DataDict);
  nStr := MacroValue(sSelectDict, [MI('$Table', nTable),
          MI('$Entity', MakeDictEntity(nEntity)), MI('$Lang', nLang)]);
  if not SafeQuery(nStr, nTable, nDS, nFree) then Exit;

  nItem := FEntityList[nIdx];
  if Assigned(nItem.FDictItem) then
       ClearDictItems(nItem)
  else nItem.FDictItem := TList.Create;
  
  nDS.First;
  while not nDS.Eof do
  begin
    New(nDict);
    nItem.FDictItem.Add(nDict);
    
    nDict.FItemID := nDS.FieldByName('D_ItemID').AsInteger;
    nDict.FTitle := nDS.FieldByName('D_Title').AsString;
    nDict.FAlign := TAlignment(nDS.FieldByName('D_Align').AsInteger);
    nDict.FWidth := nDS.FieldByName('D_Width').AsInteger;
    nDict.FIndex := nDS.FieldByName('D_Index').AsInteger;
    nDict.FVisible := StrToBool(nDS.FieldByName('D_Visible').AsString);

    if Assigned(nDS.FindField('D_LangID')) then
      nDict.FLangID := nDS.FieldByName('D_LangID').AsString;
    //for multi lanuage

    nDict.FDBItem.FTable := nDS.FieldByName('D_DBTable').AsString;
    nDict.FDBItem.FField := nDS.FieldByName('D_DBField').AsString;
    nDict.FDBItem.FIsKey := StrToBool(nDS.FieldByName('D_DBIsKey').AsString);
    nDict.FDBItem.FType := TFieldType(nDS.FieldByName('D_DBType').AsInteger);
    nDict.FDBItem.FWidth := nDS.FieldByName('D_DBWidth').AsInteger;
    nDict.FDBItem.FDecimal := nDS.FieldByName('D_DBDecimal').AsInteger;
    nDict.FFormat.FStyle := TDictFormatStyle(nDS.FieldByName('D_FmtStyle').AsInteger);
    nDict.FFormat.FData := nDS.FieldByName('D_FmtData').AsString;
    nDict.FFormat.FFormat := nDS.FieldByName('D_FmtFormat').AsString;
    nDict.FFormat.FExtMemo := nDS.FieldByName('D_FmtExtMemo').AsString;
    nDict.FFooter.FDisplay := nDS.FieldByName('D_FteDisplay').AsString;
    nDict.FFooter.FFormat := nDS.FieldByName('D_FteFormat').AsString;
    nDict.FFooter.FKind := TDictFooterKind(nDS.FieldByName('D_FteKind').AsInteger);
    nDict.FFooter.FPosition := TDictFooterPosition(nDS.FieldByName('D_FtePositon').AsInteger);

    nDS.Next;
  end;

  if nFree then
    FreeDataSet(nDS);
  Result := True;
end;

//Desc: 载入程序列表
function TBaseEntityManager.LoadProgList: Boolean;
var nStr: string;
    nDS: TDataSet;
    nFree: Boolean;
    nTable: string;
    nItem: PEntityItemData;
begin
  ClearProgList;
  Result := False;

  nTable := GetItemValue(cDictTable_Entity);
  nStr := MacroValue(sSelectEntitys, [MI('$Table', nTable)]);
  if not SafeQuery(nStr, nTable, nDS, nFree) then Exit;

  nDS.First;
  while not nDS.Eof do
  begin
    New(nItem);
    FProgList.Add(nItem);

    nItem.FProgID := nDS.FieldByName('E_ProgID').AsString;
    nItem.FEntity := nDS.FieldByName('E_Entity').AsString;
    nItem.FTitle := nDS.FieldByName('E_Title').AsString;
    nItem.FDictItem := nil;
    nDS.Next;
  end;

  if nFree then
    FreeDataSet(nDS);
  Result := FProgList.Count > 0;
end;

end.
