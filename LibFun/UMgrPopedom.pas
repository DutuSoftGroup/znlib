{*******************************************************************************
  ����: dmzn@ylsoft.com 2008-01-03
  ����: ֧��Ȩ����,�û�����ģʽ��Ȩ�޹�����

  ��ע:
  &.Ȩ������0-9,A-Z��36��Ȩ�ޱ�����.
  &.�û�ӵ���������Ȩ��.
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

  cPopedomUser_Admin    = $0000;  //����Ա
  cPopedomUser_User     = $0001;  //��ͨ�û�,��Ӧ��User.U_Identity

  cPopedomUser_Forbid   = $0000;  //�ʻ�����
  cPopedomUser_Normal   = $0001;  //�ʻ�����,��Ӧ��User.U_Status

  cPopedomGroup_CanDel  = $0000;  //����ɾ��
  cPopedomGroup_NoDel   = $0001;  //����ɾ��,��ӦGroup.G_CANDEL

type
  PPopedomItemData = ^TPopedomItemData;
  TPopedomItemData = record
    FItem: string;            //����
    FPopedom: string;         //Ȩ��
  end;

  PGroupItemData = ^TGroupItemData;
  TGroupItemData = record
    FID: string;              //���ʶ
    FName: string;            //������
    FDesc: string;            //������
    FUser: TStrings;          //�����û�
    FPopedom: TList;          //Ȩ���б�
  end;

  THintMsg = procedure (const nMsg: string) of Object;
  //��ʾ��Ϣ

  TBasePopedomManager = class(TObject)
  private
    FGroupList: TList;
    {*Ȩ�����б�*}
    FHintMsg: THintMsg;
    {�¼�}
  protected
    procedure HintMsg(const nMsg: string);
    {*��ʾ��Ϣ*}
    procedure ClearPopedom(const nList: TList);
    procedure ClearItemList(const nList: TList);
    {*������б�*}

    function LoadGroupData(const nList: TList): Boolean;
    function LoadGroupUser(const nGroup: PGroupItemData): Boolean;
    function LoadGroupPopedom(const nGroup: PGroupItemData): Boolean;
    {*����������*}
    
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
    function CreateUserTable: Boolean;
    function CreateGroupTable: Boolean;
    function CreatePopedomTable: Boolean;
    function CreatePopItemTable: Boolean;
    {*������*}
    function LoadGroupFromDB(const nProgID: string): Boolean;
    function LoadPopItemList(const nList: TStrings; const nProgID: string = ''): Boolean;
    {*��ȡȨ��*}

    function FindGroupByID(const nGroup: string): PGroupItemData;
    function FindGroupByUser(const nUser: string): PGroupItemData;
    function FindUserPopedom(const nUser,nItem: string): string;
    function FindGroupPopedom(const nGroup,nItem: string): string;
    {*����*}

    property Groups: TList read FGroupList;
    property OnHintMsg: THintMsg read FHintMsg write FHintMsg;
    {����,�¼�}
  end;

implementation

ResourceString
  sCreateUser = 'Create Table $User(' +
                'U_Name VARCHAR(32),' +                   //�û���
                'U_Password VARCHAR(16),' +               //����
                'U_Mail VARCHAR(25),' +                   //�ʼ�
                'U_Phone VARCHAR(15),' +                  //�绰
                'U_Memo VARCHAR(50),' +                   //��ע
                'U_Identity SMALLINT DEFAULT 1,' +        //��ݱ��(0,����Ա;����,һ���û�)
                'U_State SMALLINT DEFAULT 1,' +           //״̬(0,����;����,����)
                'U_Group SMALLINT DEFAULT 0)';            //������
  //table user's create sql

  sCreateGroup = 'Create Table $Group(' +
                 'G_ID SMALLINT NOT NULL,' +              //���ʶ
                 'G_PROGID VARCHAR(15) NOT NULL,' +       //�����ʶ
                 'G_NAME VARCHAR(20) NOT NULL,' +         //������
                 'G_DESC VARCHAR(50),' +                  //������
                 'G_CANDEL SMALLINT DEFAULT 0)';           //��ɾ��
  //table group's create sql

  sCreatePopedom = 'Create Table $Popedom(' +
                   'P_GROUP SMALLINT NOT NULL,' +         //���ʶ
                   'P_ITEM VARCHAR(20) NOT NULL,' +       //�����ʶ
                   'P_POPEDOM VARCHAR(36))';              //Ȩ��ֵ
  //table popedom's create sql

  sCreatePopItem = 'Create Table $PopItem(' +
                   'P_ID Char(1),' +                      //Ȩ������
                   'P_ProgID VARCHAR(15) NOT NULL,' +     //������
                   'P_Name VARCHAR(20))';                 //Ȩ��������
  //table popedom's create sql

  sSelectGroup = 'Select * From $Group Where G_PROGID=''$PID'' Order By G_ID';
  //select a program's group items

  sSelectPopedom = 'Select * From $Popedom Where P_GROUP=$Group';
  //select a group's popedom items

  sSelectUser = 'Select U_Name,U_Group From $UserTable Where U_Group=$ID';
  //select a group's all user

  sSelctPopItem = 'Select * From $PopItem Order By P_ID';
  //select all popedom item

  sNoTable = '�޷���λ��"%s"��';
  sNoRecord = '"%s"��Ϊ��,û������';
  sQueryError = '��ѯ"%s"��ʧ��,�޷���ȡ����';

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
//Parm: ��Ϣ����
//Desc: ����HintMsg�¼�,��ʾnMsg��Ϣ
procedure TBasePopedomManager.HintMsg(const nMsg: string);
begin
  if Assigned(FHintMsg) then FHintMsg(nMsg);
end;

//Date: 2008-01-03
//Parm: �б�
//Desc: �ͷ�nList�����е�Ԫ��
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
//Parm: �б�
//Desc: �ͷ�nList�����е�Ԫ��
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
//Desc: ����Ȩ�����,�����Ѵ�����ֱ�ӷ�����
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
//Desc: ����Ȩ�ޱ�,�����Ѵ�����ֱ�ӷ�����
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

//Desc: ����Ȩ�����
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

//Desc: �����û���
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

//Desc: �ͷ����ݼ�
procedure TBasePopedomManager.FreeDataSet(const nDS: TDataSet);
begin
  nDS.Free;
end;

//Date: 2008-01-03
//Parm: ��ѯSQl;����;���ݼ�;�Ƿ��Զ��ͷ�
//Desc: ִ��nSQL���,���ݼ�������nDS��
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
//Parm: �����ʶ
//Desc: ����nProgID������ӵ�е�����Ϣ
function TBasePopedomManager.LoadGroupFromDB(const nProgID: string): Boolean;
var nStr: string;
    nDS: TDataSet;
    nFree: Boolean;
    nTable: string;
    nGroup: PGroupItemData;
begin
  Result := False;
  ClearItemList(FGroupList);
  //���ԭ������

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
    //�����α�
  end;

  if nFree and Assigned(nDS) then
    FreeDataSet(nDS);
  Result := LoadGroupData(FGroupList);
end;

//Desc: ����Ȩ������û�,Ȩ����Ϣ
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

//Desc: ����nGroup��Ȩ����Ϣ
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
    //�����α�
  end;

  if nFree and Assigned(nDS) then
    FreeDataSet(nDS);
  Result := True;
end;

//Desc: ����nGroup����û���Ϣ
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

//Desc: ����Ȩ�����б�,��ʽ: ID;ProgID;Name
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
//Desc: ��������ΪnGroup������Ϣ
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

//Desc: �����û�nUser���ڵ�����Ϣ
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

//Desc: �����û�nUser��nItem�����Ȩ��ֵ
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

//Desc: ����Ȩ����nGroup��nItem�����Ȩ��ֵ
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
