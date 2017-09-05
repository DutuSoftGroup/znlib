{*******************************************************************************
  ����: dmzn@163.com 2008-8-22
  ����: �����ֵ������

  ��ע:
  &.�����ֵ���Ҫ���ڳ�ʼ��ListView,cxGrid�����ݱ��,�ֵ������ά����һ����֮
    ��ص���������.
  &.�ֵ����������: ����ģ��,ģ���¶��ʵ��,ÿ��ʵ���Ӧһ��������.
  &.�ֵ������ʹ��ProgID����,����ʶ��ǰ����ʵ���������ĳ���.
  &.�ֵ����������ݿ����,���ü�����,�������Ỻ��,����ÿ��ʵ������ֻ����һ��.
  &.��ȡʱ����LoadEntity,���ɹ����ʵ��ᱻ����,ֱ�Ӷ�ȡActiveEntity�Ϳ�����.
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
  //��ʽ����ʽ: �̶�����,���ݿ�����

  PDictFormatItem = ^TDictFormatItem;
  TDictFormatItem = record
    FStyle: TDictFormatStyle;       //��ʽ
    FData: string;                  //����
    FFormat: string;                //��ʽ��
    FExtMemo: string;               //��չ����
  end;

  PDictDBItem = ^TDictDBItem;
  TDictDBItem = record
    FTable: string;                 //����
    FField: string;                 //�ֶ�
    FIsKey: Boolean;                //����

    FType: TFieldType;              //��������
    FWidth: integer;                //�ֶο��
    FDecimal: integer;              //С��λ
  end;

  TDictFooterKind = (fkNone, fkSum, fkMin, fkMax, fkCount, fkAverage);
  //ͳ������: ��,�ϼ�,��С,���,��Ŀ,ƽ��ֵ
  TDictFooterPosition = (fpNone, fpFooter, fpGroup, fpAll);
  //�ϼ�λ��: ҳ��,����,���߶���

  PDictGroupFooter = ^TDictGroupFooter;
  TDictGroupFooter = record
    FDisplay: string;               //��ʾ�ı�
    FFormat: string;                //��ʽ��
    FKind: TDictFooterKind;         //�ϼ�����
    FPosition: TDictFooterPosition; //�ϼ�λ��
  end;

  PDictItemData = ^TDictItemData;
  TDictItemData = record
    FItemID: integer;               //��ʶ
    FTitle: string;                 //����
    FAlign: TAlignment;             //����
    FWidth: integer;                //���
    FIndex: integer;                //˳��
    FVisible: Boolean;              //�ɼ�
    FLangID: string;                //����
    FDBItem: TDictDBItem;           //���ݿ�
    FFormat: TDictFormatItem;       //��ʽ��
    FFooter: TDictGroupFooter;      //ҳ�źϼ�
  end;

  PEntityItemData = ^TEntityItemData;
  TEntityItemData = record
    FProgID: string;               //������
    FEntity: string;               //ʵ����
    FTitle: string;                //ʵ������
    FDictItem: TList;              //�ֵ�����,һ��TDictItemData
  end;

  THintMsg = procedure (const nMsg: string) of Object;
  //��ʾ��Ϣ

  TBaseEntityManager = class(TObject)
  private
    FEntityList: TList;
    {*ʵ���б�*}
    FProgList: TList;
    {*�����б�*}
    FProgID: string;
    {*������*}
    FLangID: string;
    {*���Ա�ʶ*}
    FActiveIndex: integer;
    {*ʵ������*}
    FHintMsg: THintMsg;
    {�¼�}
  protected
    procedure HintMsg(const nMsg: string);
    {*��ʾ��Ϣ*}
    function MakeDictEntity(const nEntity: string): string;
    {*�ֵ�ʵ��*}

    function LoadEntityFromDB(const nEntity: string): Boolean;
    function LoadDictItemFromDB(const nEntity: string): Boolean;
    {*��ȡ����*}
    function EntityItemIndex(const nEntity: string): integer;
    procedure FreeEntityItem(const nEntity: string); overload;
    procedure FreeEntityItem(const nIdx: integer); overload;
    {*�ͷ�����*}
    procedure ClearDictItems(const nEntity: PEntityItemData);
    procedure ClearProgList;
    procedure ClearEntityList;
    {*��������*}      
    function SafeQuery(const nSQL,nTable: string;
      var nDS: TDataSet; var nAutoFree: Boolean): Boolean;
    procedure FreeDataSet(const nDS: TDataSet); virtual;
    {*����֤��ִ��QuerySQL����*}

    function QuerySQL(const nSQL: string;
      var nDS: TDataSet; var nAutoFree: Boolean): Boolean; virtual; abstract;
    function ExecSQL(const nSQL: string): integer; virtual; abstract;

    function GetItemValue(const nItem: integer): string; virtual; abstract;
    function IsTableExists(const nTable: string): Boolean; virtual; abstract;
    {*���෽��*}
  public
    constructor Create;
    destructor Destroy; override;
    {*�����ͷ�*}
    function CreateTable: Boolean;
    {*������*}
    function AddEntityToDB(const nEntity: TEntityItemData): Boolean;
    function AddDictItemToDB(const nEntity: string; const nDict: TDictItemData): Boolean;
    function DelEntityFromDB(const nProgID,nEntity: string): Boolean;
    function DelDictEntityItem(const nEntity: string): Boolean;
    function DelDictItemFromDB(const nEntity: string; const nID: integer): Boolean;
    {*���ɾ��*}
    function LoadEntity(const nEntity: string; const nForceDB: Boolean=False): Boolean;
    {*��ȡ����*}
    function LoadProgList: Boolean;
    {*ʵ���б�*}
    function UpdateActiveDictItem(const nItemID: integer; const nWidth: integer = MaxInt;
      const nIndex: integer = MaxInt): Boolean;
    function GetActiveEntity: PEntityItemData;
    function GetActiveDictItem(const nItemID: integer): PDictItemData;
    {*�����*}
    property ActiveEntity: PEntityItemData read GetActiveEntity;
    property ProgList: TList read FProgList;
    property ProgID: string read FProgID write FProgID;
    property LangID: string read FLangID write FLangID;
    property OnHintMsg: THintMsg read FHintMsg write FHintMsg;
    {����,�¼�}
  end;   

implementation

ResourceString
  sNoTable = '�޷���λ��"%s"��';
  sNoRecord = '"%s"��Ϊ��,û������';
  sQueryError = '��ѯ"%s"��ʧ��,�޷���ȡ����';

  sCreateEntity = 'Create Table $Table(' +
                  'E_ProgID varchar(15),' +                 //�����ʶ
                  'E_Entity varchar(20),' +                 //ʵ���ʶ
                  'E_Title varchar(50))';                   //ʵ�����
  //entity create sql

  sInsertEntity = 'Insert Into $Table Values(''$ProgID'', ''$Entity'', ''$Title'')';
  //entity insert sql
  sDeleteEntity = 'Delete From $Table Where E_ProgID=''$PID'' And E_Entity=''$Entity''';
  //entity delete sql

  sCreateDict = 'Create Table $Table(' +
                'D_ItemID integer,' +                       //���ݱ��
                'D_Entity varchar(35),' +                   //����ʵ��
                'D_Title  varchar(30),' +                   //���ݱ���
                'D_Align smallint,' +                       //�������
                'D_Width integer,' +                        //������
                'D_Index integer,' +                        //����˳��
                'D_Visible smallint,' +                     //�Ƿ�ɼ�
                'D_LangID varchar(12),' +                   //���Ա�ʶ

                'D_DBTable varchar(32),' +                  //������
                'D_DBField varchar(32),' +                  //�ֶ���
                'D_DBIsKey smallint,' +                     //�Ƿ�����
                'D_DBType smallint,' +                      //��������
                'D_DBWidth smallint,' +                     //�ֶο��
                'D_DBDecimal smallint,' +                   //С��λ

                'D_FmtStyle smallint,' +                    //��ʽ����ʽ
                'D_FmtData varchar(200),' +                 //��ʽ������
                'D_FmtFormat varchar(100),' +               //��ʽ������
                'D_FmtExtMemo varchar(100),' +              //��ʽ����չ

                'D_FteDisplay varChar(50),' +               //ͳ����ʾ�ı�
                'D_FteFormat varChar(50),' +                //ͳ�Ƹ�ʽ��
                'D_FteKind smallint,' +                     //ͳ������
                'D_FtePositon smallint)';                   //ͳ����ʾλ��
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

//Desc: ����HintMsg�¼�,��ʾnMsg��Ϣ
procedure TBaseEntityManager.HintMsg(const nMsg: string);
begin
  if Assigned(FHintMsg) then FHintMsg(nMsg);
end;

//Desc: ���ʵ���б�
procedure TBaseEntityManager.ClearEntityList;
var nIdx: integer;
begin
  for nIdx:=FEntityList.Count - 1 downto 0 do FreeEntityItem(nIdx);
end;

//Desc: ��ճ����б�
procedure TBaseEntityManager.ClearProgList;
var nIdx: integer;
begin
  for nIdx:=FProgList.Count - 1 downto 0 do
  begin
    Dispose(PEntityItemData(FProgList[nIdx]));
    FProgList.Delete(nIdx);
  end;
end;

//Desc: �������ΪnEntityʵ�������
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

//Desc: �ͷű��ΪnEntity��ʵ��
procedure TBaseEntityManager.FreeEntityItem(const nEntity: string);
var nIdx: integer;
begin
  nIdx := EntityItemIndex(nEntity);
  if nIdx > -1 then FreeEntityItem(nIdx);
end;

//Desc: �ͷ�����ΪnIdx��ʵ��
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

//Desc: �ͷ�nEntity���ֵ���
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

//Desc: ��ȡ��ǰ���ʵ��
function TBaseEntityManager.GetActiveEntity: PEntityItemData;
begin
  if (FActiveIndex > -1) and (FActiveIndex < FEntityList.Count) then
       Result := FEntityList[FActiveIndex]
  else Result := nil;
end;

//Desc: ��ȡ��ǰ�ʵ���б��ΪnItemID���ֵ���
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

//Desc: ���µ�ǰ�ʵ���б��ΪnItemID���ֵ���ı����Ⱥ�˳������
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
//Desc: �ͷ����ݼ�
procedure TBaseEntityManager.FreeDataSet(const nDS: TDataSet);
begin
  nDS.Free;
end;

//Desc: �����ֵ������
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
//Parm: ��ѯSQl;���ݼ�;�Ƿ��Զ��ͷ�
//Desc: ִ��nSQL���,���ݼ�������nDS��
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
//Desc: ����nEntityʵ���Ӧ���ֵ���ʵ��
function TBaseEntityManager.MakeDictEntity(const nEntity: string): string;
begin
  Result := FProgID + '_' + nEntity;
end;

//Date: 2008-8-23
//Parm: ʵ��;�ֵ���
//Desc: �����ݿ����nEntityʵ����ֵ���
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
//Parm: ʵ����
//Desc: �����ݿ����nEntityʵ����
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

//Desc: ��ʵ��nEntity��ɾ�����ΪnID���ֵ���
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

//Desc: �����ݿ�ɾ��nEntityʵ��
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

//Desc: ɾ��nEntity�������ֵ���
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
//Desc: �����ݿ�����,���ߴӻ����ȡnEntityʵ����ֵ�����
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

//Desc: �����ݿ��ȡnEntityʵ��
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

//Desc: �����ݿ��ȡnEntity���ֵ���
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
  //���Թ���

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

//Desc: ��������б�
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
