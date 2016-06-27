{*******************************************************************************
  ����: dmzn@163.com 2007-11-08
  ����: �˵�������,���ڶ�̬�˵��ļ���

  ��ע:
  &.����Ԫʵ���˲˵�������MenuManager.
  &.MenuManager��Ҫ���ڶ�̬�˵��ļ��غͲ˵���Ĳ�ѯ.
  &.Ϊ��ʵ�ֱ���Ԫ����������,���������ݿ���صĲ���(��,д),��ʹ�ó��󷽷�,
  ����MenuManager��һ������������.�ھ������Ŀ��,��Ҫ������������ʵ�ֶ�д����.
  &.����MenuManager.ExecSQL,����nSQL��һ��Insert,Update,Delete���.
  &.����MenuManager.QuerySQL,����nSQL��һ��Select���,����nDS�Ƿ��صļ�¼��,
  ����nAutoFree��ʶ�Ƿ��Զ��ͷŸ����ݼ�.
  &.����MenuMaanger.IsTableExists,����ʹ���������˵����Ƿ����.
  &.�������ʵ�������������󷽷�,�Բ�ȫ����Ĺ���.
  &.MenuManager.LoadMenuFromDB����ɹ���,MenuManager.TopLevelMenu��һ��������
  �˵���,ÿ���˵����FSubMenu��,����Ӳ˵��б�,ѭ������Ϳ�����.
  &.MenuManager.TopLevelMenu��������Ԫ��:ʵ��,�����˵�,�ֱ�ʹ��GetEntityList,
    GetMenuList����ȡ,����nList���ʵ���˵���ָ��,�������ͷ�.

  &.�˵���Լ��:
  *.�����ʶ: FEntity = ''
  *.ʵ���ʶ: FMenuID = ''
  *.�����˵�: FPMenu = ''
  *.ÿ��������ʵ��,ÿ��ʵ�����˵���
  *.��ͬʵ��Ĳ˵���ʶ������ͬ,ͬʵ��Ĳ˵������ͬ.
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
    FProgID: string;                //�����ʶ
    FEntity: string;                //ʵ���ʶ
    FMenuID: string;                //�˵���ʶ
    FPMenu: string;                 //�ϼ��˵�
    FTitle: string;                 //�˵�����
    FImgIndex: integer;             //ͼ������
    FFlag: string;                  //���Ӳ���(�»���..)
    FAction: string;                //�˵�����
    FFilter: string;                //��������
    FNewOrder: Single;              //��������
    FPopedom: string;               //Ȩ����
    FLangID: string;                //���Ա�ʶ
    FSubMenu: TList;                //�Ӳ˵��б�
  end;

  THintMsg = procedure (const nMsg: string) of Object;
  //��ʾ��Ϣ

  TBaseMenuManager = class(TObject)
  private
    FItemList: TList;
    {*�����˵��б�*}
    FProList: TList;
    {*�����ʶ�б�*}
    FLangID: string;
    {*���Ա�ʶ*}
    FHintMsg: THintMsg;
    {�¼�}
  protected
    procedure HintMsg(const nMsg: string);
    {*��ʾ��Ϣ*}
    function FindMenuItem(const nList: TList;
      const nEntity,nMenuID: string): PMenuItemData;
    {*�����˵���*}
    function BuildMenuTree(const nList: TList): Boolean;
    {*���������*}
    procedure ClearItemList(const nList: TList; const nFree: Boolean = False);
    {*��ղ˵����б�,֧�ֶ༶*}

    function SafeQuery(const nSQL: string;
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
    function CreateMenuTable: Boolean;
    {*������*}
    function AddMenuToDB(const nMenu: TMenuItemData): Boolean;
    function DelMenuFromDB(const nProgID: string): integer; overload;
    function DelMenuFromDB(const nProg,nEntity: string): integer; overload;
    function DelMenuFromDB(const nProg,nEntity,nMenu: string): integer; overload;
    {*���ɾ��*}
    function LoadMenuFromDB(const nProgID: string): Boolean;
    {*��ȡ�˵�*}
    function GetProgList: TList;
    {*��ȡ�����ʶ*}
    function GetEntityList(const nList: TList): Boolean;
    function GetMenuList(const nList: TList; const nEntity: string): Boolean;
    function GetMenuItem(const nEntity,nMenuID: string): PMenuItemData;
    {*�����˵���*}
    property TopMenus: TList read FItemList;
    property LangID: string read FLangID write FLangID;
    property OnHintMsg: THintMsg read FHintMsg write FHintMsg;
    {����,�¼�}
  end;

implementation

const
  cMenuItemDataSize = SizeOf(TMenuItemData);
  //�˵������ݴ�С

  sDeleteMenu1 = 'Delete From $Table Where M_ProgID=''$ProgID''';
  sDeleteMenu2 = sDeleteMenu1 + ' And M_Entity=''$Entity''';
  sDeleteMenu3 = sDeleteMenu2 + ' And M_MenuID=''$Menu''';
  //Menu Delete SQL

ResourceString
  sNoTable = '�޷���λ��"�˵�"��';
  sNoRecord = '"�˵�"��Ϊ��,û�в˵�����';
  sQueryError = '��ѯ"�˵�"��ʧ��,�޷���ȡ�˵�����';

  sCreateMenu = 'Create Table $Table(' +
                'M_MenuID varchar(15),' +                     //�˵���ʶ
                'M_ProgID varchar(15),' +                     //�����ʶ
                'M_Entity varchar(15),' +                     //ʵ���ʶ
                'M_PMenu varchar(15),' +                      //�ϼ��˵�
                'M_Title varchar(50),' +                      //�˵�����
                'M_ImgIndex integer,' +                       //ͼ������
                'M_Flag varchar(20),' +                       //���Ӳ���
                'M_Action varchar(100),' +                    //�˵�����
                'M_Filter varchar(100),' +                    //��������
                'M_Popedom varchar(36),' +                    //Ȩ����
                'M_LangID varchar(12),' +                     //���Ա�ʶ
                'M_NewOrder float Default -1)';               //��������
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
//Parm: ��Ϣ����
//Desc: ����HintMsg�¼�,��ʾnMsg��Ϣ
procedure TBaseMenuManager.HintMsg(const nMsg: string);
begin
  if Assigned(FHintMsg) then FHintMsg(nMsg);
end;

//Date: 2007-11-08
//Desc: ����Menu��,�����Ѵ�����ֱ�ӷ�����
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
//Parm: ���ͷ��б�;�Ƿ��ͷ��б���
//Desc: ���ͷ�nList�еĲ˵�������,��ͬʱ�ͷ�nList
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
      //�ݹ��ͷ��Ӳ˵�

      Dispose(nItem);
    end;

    if nFree then
         nList.Free
    else nList.Clear;
    //���ڲ���Ҫ�ͷŵ��б�,ֻ��ռ���
  end;
end;

//------------------------------------------------------------------------------
//Desc: �����������nMenu�˵�,�������򸲸�
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

//Desc: ɾ��nProgID��������в˵�
function TBaseMenuManager.DelMenuFromDB(const nProgID: string): integer;
var nStr,nSQL: string;
begin
  nStr := GetItemValue(cMenuTable_Menu);
  nSQL := MacroValue(sDeleteMenu1, [MI('$Table', nStr), MI('$ProgID', nProgID)]);
  Result := ExecSQL(nSQL);
end;

//Desc: ɾ��nProg������nEntityʵ������в˵�
function TBaseMenuManager.DelMenuFromDB(const nProg, nEntity: string): integer;
var nSQL: string;
begin
  nSQL := MacroValue(sDeleteMenu2,[MI('$Table', GetItemValue(cMenuTable_Menu)),
                                   MI('$ProgID', nProg), MI('$Entity', nEntity)]);
  Result := ExecSQL(nSQL);
end;

//Desc: ɾ��nProg������nEntityʵ���µ�nMenu�˵���
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
//Parm: �������б�;ʵ���ʶ;�˵���ʶ
//Desc: ��nList�˵����б����Ӳ˵��б��м���nEntity.nMenuID�˵���
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
//Parm: ʵ���ʶ;�˵���ʶ
//Desc: ������ʶΪnMenuID�Ĳ˵���
function TBaseMenuManager.GetMenuItem(const nEntity,nMenuID: string): PMenuItemData;
begin
  Result := FindMenuItem(FItemList, UpperCase(nEntity), UpperCase(nMenuID));
end;

//Date: 2007-11-9
//Parm: ��ѯSQl;���ݼ�;�Ƿ��Զ��ͷ�
//Desc: ִ��nSQL���,���ݼ�������nDS��
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

//Desc: �ͷ����ݼ�
procedure TBaseMenuManager.FreeDataSet(const nDS: TDataSet);
begin
  nDS.Free;
end;

//Date: 2007-11-8
//Parm: �����ʶ
//Desc: ����nProID���������ʵ��Ĳ˵���
function TBaseMenuManager.LoadMenuFromDB(const nProgID: string): Boolean;
var nStr,nLang: string;
    nDS: TDataSet;
    nFree: Boolean;
    nItem: PMenuItemData;
begin
  Result := False;
  ClearItemList(FItemList);
  //���ԭ������

  nLang := 'and (M_LangID=''%s'' Or M_LangID='''' or M_LangID Is Null)';
  //���Թ���

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
    //�����α�
  end;

  if nFree and Assigned(nDS) then
    FreeDataSet(nDS);
  Result := BuildMenuTree(FItemList);
  //�����˵������
end;

//Date: 2007-11-8
//Parm: δ������б�
//Desc: ��nList���˵���ι���һ����
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
    //û�и��ڵ����һ���˵���ʵ���ʶ

    if not (Assigned(nPItem) and (nPItem.FMenuID = nItem.FPMenu) and
       (nPItem.FEntity = nItem.FEntity)) then
      nPItem := FindMenuItem(nList, nItem.FEntity, nItem.FPMenu);
    //Ѱ�Ҹ��ڵ�

    if not Assigned(nPItem) then
    begin
      if Assigned(nItem.FSubMenu) then
      begin
        ClearItemList(nItem.FSubMenu);
        nItem.FSubMenu.Free;
        //�ͷ��ӽڵ�
      end;

      Dispose(nItem);
      nList.Delete(nIdx); Continue;
    end;
    //δ�ҵ����ڵ�,���ͷŲ��账��

    if not Assigned(nPItem.FSubMenu) then
      nPItem.FSubMenu := TList.Create;
    nPItem.FSubMenu.Add(nItem);
    //׷�ӵ����ڵ���

    nList.Delete(nIdx);
    //��������ɾ��
  end;

  Result := nList.Count > 0;
  //û��һ���˵����ǲ�������
end;

//------------------------------------------------------------------------------
//Desc: ��ȡ�����ʶ�б�
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
  //�Զ��ͷ����ݼ�
end;

//Date: 2007-11-09
//Parm: ����б�
//Desc: ��ѯ��ǰ�����е�ʵ���б�,�����ݷ�����
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
//Parm: ����б�;ʵ���ʶ
//Desc: ��ѯnEntityʵ���Ӧ�Ķ����˵��б�,�����ݷ�����
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
