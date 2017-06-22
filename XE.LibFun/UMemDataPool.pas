{*******************************************************************************
  ����: dmzn@163.com 2017-04-15
  ����: ����new/getmem������ڴ�������

  ��ע:
  *.ʹ�÷���:
    1.NewType: ע����������.
    2.LockData: ��������,����������������,�п����򷵻�,�޿����򴴽�.
    3.Release: �ͷ�����,��LockData���ʹ��.
  *.����LockData����һЩ�߼�,��ֱ��new/getmem�������ܶ�.������������,���ڼ�
    �ڴ����,�ṩӦ�õ��ڴ����״��,�����ڴ���Ƭ(����).
  *.�̰߳�ȫ.
*******************************************************************************}
unit UMemDataPool;

interface

uses
  System.Classes, System.SysUtils, UBaseObject;

type
  TMPDataNew = reference to function(): Pointer;
  //�����ڴ�ص�
  TMPDataDispose = reference to procedure (const nData: Pointer);
  //�ͷ��ڴ�ص�

  PMPDataMain = ^TMPDataMain;
  TMPDataMain = record
    FType: Int64;                        //��������
    FFlag: string;                       //���ݱ�ʾ
    FDesc: string;                       //��������
    FNumOnce: Byte;                      //���η���
    FNumAll: Cardinal;                   //������
    FNumLocked: Cardinal;                //������
    FNumLockAll: Int64;                  //�������

    FDataFirst: Pointer;                 //�����б�
    FDataNew: TMPDataNew;                //�����ڴ�
    FDataDispose: TMPDataDispose;        //�ͷ��ڴ�
  end;

  PMPDataItem = ^TMPDataItem;
  TMPDataItem = record
    FData: Pointer;                      //���ݽڵ�
    FNext: Pointer;                      //��һ�ڵ�
    FUsed: Boolean;                      //�Ƿ�ʹ��
  end;

  TMPDataUsed = record
    FItem: PMPDataItem;                  //������
    FMain: PMPDataMain;                  //��������
    FUsed: Boolean;                      //�Ƿ�ʹ��
  end;

  TMPDataUsedItems = array of TMPDataUsed;

  TMemDataManager = class(TManagerBase)
  private const
    cDataUsedMax = 10000;
    //�����б��С
  private
    FNumLocked: Int64;
    FNumLockAll: Int64;
    //��������
    FDataList: TList;
    FDataUsed: TMPDataUsedItems;
    //�����б�
    FSrvClosed: Integer;
    //����ر� 
  protected
    procedure ClearData(const nData: PMPDataMain);
    procedure ClearList(const nFree: Boolean);
    //��������
    procedure SetUsedFlag(const nItem,nMain: Pointer);
    //ʹ�ñ��
    function GetDataByMain(const nMain: PMPDataMain): Pointer;
    //��ȡ����
    function FindDataMain(const nType: Int64 = 0;
     const nFlag: string = ''): Integer;
    //��������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    class procedure RegistMe(const nReg: Boolean); override;
    //ע�������    
    function NewType(const nFlag,nDesc: string; const nNew: TMPDataNew;
     const nDispose: TMPDataDispose; const nNumOnce: Byte = 1): Int64;
    procedure DeleteType(const nType: Int64); overload;
    procedure DeleteType(const nFlag: string); overload;
    //ע���ͷ�
    function LockData(const nType: Int64): Pointer; overload;
    function LockData(const nFlag: string): Pointer; overload;
    procedure Release(const nData: Pointer);
    //�����ͷ� 
    procedure GetStatus(const nList: TStrings;
      const nFriendly: Boolean = True); override;
    function GetHealth(const nList: TStrings = nil): TObjectHealth; override;
    //��ȡ״̬ 
  end;

var
  gMemDataManager: TMemDataManager = nil;
  //ȫ��ʹ��

implementation

uses
  UManagerGroup;

const
  cYes  = $0002;
  cNo   = $0005;
  
constructor TMemDataManager.Create;
begin
  inherited; 
  FNumLocked := 0;
  FNumLockAll := 0;

  FSrvClosed := cNo;                    
  SetLength(FDataUsed, 0);  
  FDataList := TList.Create;
end;

destructor TMemDataManager.Destroy;
begin
  SyncEnter;
  FSrvClosed := cYes; //set close flag  
  SyncLeave;
  
  if FNumLocked > 0 then
  begin
    while FNumLocked > 0 do
      Sleep(1);
    //wait for relese
  end;
  
  ClearList(True);
  inherited;
end;

//Date: 2017-04-15
//Parm: �Ƿ�ע��
//Desc: ��ϵͳע�����������
class procedure TMemDataManager.RegistMe(const nReg: Boolean);
var nIdx: Integer;
begin
  nIdx := GetMe(TMemDataManager);
  if nReg then
  begin     
    if not Assigned(FManagers[nIdx].FManager) then
      FManagers[nIdx].FManager := TMemDataManager.Create;
    gMG.FMemDataManager := FManagers[nIdx].FManager as TMemDataManager; 
  end else
  begin
    gMG.FMemDataManager := nil;
    FreeAndNil(FManagers[nIdx].FManager);    
  end;
end;

//Desc: �ͷ��б�
procedure TMemDataManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
    nData: PMPDataMain;
begin
  for nIdx:=FDataList.Count - 1 downto 0 do
  begin
    nData := FDataList[nIdx];
    ClearData(nData);
    FDataList.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FDataList);
  //xxxxx
end;

//Desc: ����nData����
procedure TMemDataManager.ClearData(const nData: PMPDataMain);
var nIdx: Integer;
    nItem,nTmp: PMPDataItem;
begin
  nItem := nData.FDataFirst;
  if Assigned(nItem) then
  begin
    while True do
    begin
      nTmp := nItem;
      nItem := nItem.FNext;

      nData.FDataDispose(nTmp.FData);
      Dispose(nTmp);
      if not Assigned(nItem) then Break;
    end;
  end;

  for nIdx:=Low(FDataUsed) to High(FDataUsed) do
   if FDataUsed[nIdx].FMain = nData then
    FDataUsed[nIdx].FUsed := False;
  //�������ñ��

  Dispose(nData);
  //�ͷ����ڵ�
end;

//Date: 2017-04-14
//Parm: ���ͱ��;���ͱ�ʶ
//Desc: ��������ΪnType������
function TMemDataManager.FindDataMain(const nType: Int64;
 const nFlag: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FDataList.Count - 1 downto 0 do
  if ((nType > 0) and (PMPDataMain(FDataList[nIdx]).FType = nType)) or
     ((nFlag <> '') and (PMPDataMain(FDataList[nIdx]).FFlag = nFlag)) then
  begin
    Result := nIdx;
    Exit;
  end;
end;

//Date: 2017-04-14
//Parm: ��ʶ;����;����,�ͷŻص�;ÿ�η������
//Desc: ע��һ������ΪnDesc����������,�������ͱ��
function TMemDataManager.NewType(const nFlag,nDesc: string;
  const nNew: TMPDataNew; const nDispose: TMPDataDispose;
  const nNumOnce: Byte): Int64;
var nMain: PMPDataMain;
begin
  if not (Assigned(nNew) and Assigned(nDispose)) then
    raise Exception.Create(ClassName + ': New/Free Function Is Null.');
  //xxxxx

  if (nNumOnce < 1) or (nNumOnce > 220) then
    raise Exception.Create(ClassName + ': NumOnce Parameter Invalid.');
  //xxxxx

  if (nFlag <> '') and (FindDataMain(0, nFlag) > -1) then
    raise Exception.Create(ClassName + ': Flag Has Exists.');
  //xxxxx
                      
  gMG.CheckSupport(ClassName, 'FSerialIDManager', gMG.FSerialIDManager);
  //check manager

  SyncEnter;
  try
    Result := gMG.FSerialIDManager.GetID;
    //serial id

    New(nMain);
    FDataList.Add(nMain);
    FillChar(nMain^, SizeOf(TMPDataMain), #0);

    nMain.FType := Result;
    nMain.FFlag := nFlag;
    nMain.FDesc := nDesc;

    nMain.FNumOnce := nNumOnce;
    nMain.FDataNew := nNew;
    nMain.FDataDispose := nDispose;
  finally
    SyncLeave;
  end;   
end;

//Date: 2017-04-15
//Parm: ���ͱ��
//Desc: ע�����ΪnType����������
procedure TMemDataManager.DeleteType(const nType: Int64);
var nIdx: Integer;
begin
  SyncEnter;
  try
    nIdx := FindDataMain(nType);
    if nIdx > -1 then
    begin
      ClearData(FDataList[nIdx]);
      FDataList.Delete(nIdx);
    end;
  finally
    SyncLeave;
  end;   
end;

//Date: 2017-04-15
//Parm: ���ͱ�ʶ
//Desc: ע����ʶΪnType����������
procedure TMemDataManager.DeleteType(const nFlag: string);
var nIdx: Integer;
begin
  SyncEnter;
  try
    nIdx := FindDataMain(0, nFlag);
    if nIdx > -1 then
    begin
      ClearData(FDataList[nIdx]);
      FDataList.Delete(nIdx);
    end;
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-15
//Parm: ������;����
//Desc: �������б���,���һ���¼
procedure TMemDataManager.SetUsedFlag(const nItem, nMain: Pointer);
var nIdx,nInt: Integer;

  procedure SetFlag;
  begin
    with FDataUsed[nIdx] do
    begin
      FUsed := True;
      FItem := nItem;
      FMain := nMain;

      FItem.FUsed := True;
      Inc(FMain.FNumLocked);
      Inc(Self.FNumLocked);
    end;
  end;
begin
  for nIdx:=Low(FDataUsed) to High(FDataUsed) do
  if not FDataUsed[nIdx].FUsed then
  begin
    SetFlag;
    Exit;
  end;

  nInt := Length(FDataUsed);
  if nInt >= cDataUsedMax then
    raise Exception.Create(ClassName + ': DataUsed Array Is Full.');
  //xxxxx

  SetLength(FDataUsed, nInt + 10);
  for nIdx:=nInt to High(FDataUsed) do
    FDataUsed[nIdx].FUsed := False;
  //init flag

  nIdx := nInt;
  SetFlag;
end;

//Date: 2017-04-15
//Parm: ����
//Desc: ����nMain�еĿ���������
function TMemDataManager.GetDataByMain(const nMain: PMPDataMain): Pointer;
var nIdx: Integer;
    nItem: PMPDataItem;
begin
  if FNumLockAll < High(Int64) then  
       Inc(FNumLockAll)
  else FNumLockAll := 1;
  
  if nMain.FNumLockAll < High(Int64) then  
       Inc(nMain.FNumLockAll)
  else nMain.FNumLockAll := 1;
  
  nItem := nMain.FDataFirst;
  while Assigned(nItem) do
  begin
    if not nItem.FUsed then
    begin
      SetUsedFlag(nItem, nMain);
      Result := nItem.FData;
      Exit;
    end;

    nItem := nItem.FNext;
    //next item
  end;

  if nMain.FNumAll >= High(Cardinal) - nMain.FNumOnce then
    raise Exception.Create(ClassName + ': Data List Is Full.');
  //xxxxx

  for nIdx:=1 to nMain.FNumOnce do
  begin
    New(nItem);
    FillChar(nItem^, SizeOf(TMPDataItem), #0);

    nItem.FNext := nMain.FDataFirst; //�����������
    nMain.FDataFirst := nItem;
    nItem.FData := nMain.FDataNew();

    Inc(nMain.FNumAll);
    //+1
  end;

  SetUsedFlag(nItem, nMain);
  Result := nItem.FData; //��������
end;

//Date: 2017-04-15
//Parm: ���ͱ��
//Desc: ��������ΪnType��һ��������,�ӻ�����ȡ����,���·���
function TMemDataManager.LockData(const nType: Int64): Pointer;
var nIdx: Integer;
begin
  SyncEnter;
  try
    Result := nil;
    if FSrvClosed = cYes then
      raise Exception.Create(ClassName + ': Not Support "Lock" When Closing.');
    //pool will close
    
    
    nIdx := FindDataMain(nType);
    if nIdx < 0 then
      raise Exception.Create(ClassName + ': Invalid Data Type.');
    Result := GetDataByMain(FDataList[nIdx]);
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-15
//Parm: ���ͱ��
//Desc: ���ر�ʶΪnFlag��һ��������,�ӻ�����ȡ����,���·���
function TMemDataManager.LockData(const nFlag: string): Pointer;
var nIdx: Integer;
begin
  SyncEnter;
  try
    Result := nil;
    if FSrvClosed = cYes then
      raise Exception.Create(ClassName + ': Not Support "Lock" When Closing.');
    //pool will close

    nIdx := FindDataMain(0, nFlag); 
    if nIdx < 0 then
      raise Exception.Create(ClassName + ': Invalid Data Flag.');
    Result := GetDataByMain(FDataList[nIdx]);
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-15
//Parm: ���ͱ��;������
//Desc: ��nData��״̬��Ϊ����
procedure TMemDataManager.Release(const nData: Pointer);
var nIdx: Integer;
begin
  if not Assigned(nData) then Exit;
  //not match
  
  SyncEnter;
  try    
    for nIdx:=Low(FDataUsed) to High(FDataUsed) do
     with FDataUsed[nIdx] do
      if FUsed and (FItem.FData = nData) then
      begin
        FUsed := False;
        FItem.FUsed := False;

        Dec(FMain.FNumLocked);
        Dec(Self.FNumLocked);
        Exit;
      end;
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-15
//Parm: �б�;�Ƿ��Ѻ���ʾ
//Desc: ��������״̬���ݴ���nList��
procedure TMemDataManager.GetStatus(const nList: TStrings; 
  const nFriendly: Boolean);
var nIdx: Integer;
    nMain: PMPDataMain;
begin
  with TObjectStatusHelper do
  try
    SyncEnter;
    inherited GetStatus(nList, nFriendly);
    
    if not nFriendly then
    begin
      nList.Add('DataUsed=' + Length(FDataUsed).ToString);
      nList.Add('NumLocked=' +  FNumLocked.ToString);
      nList.Add('NumLockAll=' + FNumLockAll.ToString);
      Exit;
    end;
    
    nList.Add(FixData('DataUsed:', Length(FDataUsed).ToString));
    nList.Add(FixData('NumLocked:', FNumLocked));
    nList.Add(FixData('NumLockAll:', FNumLockAll));
                                  
    for nIdx:=0 to FDataList.Count - 1 do
    begin
      nList.Add('');
      nMain := FDataList[nIdx];

      nList.Add(FixData(nMain.FFlag + '.' + 
                        nMain.FDesc + '.NumAll', nMain.FNumAll));
      nList.Add(FixData(nMain.FFlag + '.' + 
                        nMain.FDesc + '.NumLocked', nMain.FNumLocked));
      nList.Add(FixData(nMain.FFlag + '.' + 
                        nMain.FDesc + '.NumLockAll', nMain.FNumLockAll));
      //xxxxx
    end;
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-16
//Desc: ��ȡ������������ 
function TMemDataManager.GetHealth(const nList: TStrings): TObjectHealth;
var nStr: string;
    nInt: Integer;
begin
  SyncEnter;
  try
    Result := hlNormal;
    nInt := Length(FDataUsed);
     
    if ((nInt >= cDataUsedMax / 2) and (nInt < cDataUsedMax - 500)) and 
        (Result < hlLow) then
    begin
      if Assigned(nList) then
      begin
        nStr := '������[DataUsed: %d%%]ռ�ù���.';
        nList.Add(Format(nStr, [Trunc(nInt / cDataUsedMax) * 100]));
      end;
        
      Result := hlLow;
    end;        

    if (nInt >= cDataUsedMax - 500) and (Result < hlBad) then
    begin
      if Assigned(nList) then
      begin
        nStr := '������[DataUsed: %d%%]�Ѳ���.';
        nList.Add(Format(nStr, [Trunc(nInt / cDataUsedMax) * 100]));
      end;

      Result := hlBad;
    end;
      

    if (FNumLocked >= cDataUsedMax / 10) and (Result < hlLow) then
    begin
      if Assigned(nList) then
      begin
        nStr := '����������[NumLocked: %d]����,�ȴ��ͷ�.';
        nList.Add(Format(nStr, [FNumLocked]));
      end;

      Result := hlLow;
    end;

    if (FNumLocked >= cDataUsedMax / 2) and (Result < hlBad) then
    begin
      if Assigned(nList) then
      begin
        nStr := '����������[NumLocked: %d]�ﵽ����ֵ,�����ͷ��߼�.';
        nList.Add(Format(nStr, [FNumLocked]));
      end;

      Result := hlBad;
    end;
  finally
    SyncLeave;
  end;
end;

initialization
  //nothing
finalization
  //nothing
end.
