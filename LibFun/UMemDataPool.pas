{*******************************************************************************
  ����: dmzn@163.com 2015-08-04
  ����: ����new/getmem������ڴ�������

  ��ע:
  *.ʹ�÷���:
    1.RegDataType: ע����������.
    2.LockData: ��������,����������������,�п����򷵻�,�޿����򴴽�.
    3.UnlockData: �ͷ�����,��LockData���ʹ��.
  *.����LockData����һЩ�߼�,��ֱ��new/getmem�������ܶ�.
  *.������������,���ڼ��ڴ����,�ṩӦ�õ��ڴ����״��,�����ڴ���Ƭ(����).
  *.�̰߳�ȫ.
*******************************************************************************}
unit UMemDataPool;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, UBaseObject;

type
  TMPDataNew = procedure (const nFlag: string; const nType: Word;
    var nData: Pointer);
  //�����ڴ�ص�
  TMPDataDispose = procedure (const nFlag: string; const nType: Word;
    const nData: Pointer);
  //�ͷ��ڴ�ص�
  TMPDataEnumCallback = function (const nData: Pointer; const nResult: TList): Boolean;
  //����ö�ٻص�

  PMPDataMain = ^TMPDataMain;
  TMPDataMain = record
    FType: Word;                         //��������
    FFlag: string;                       //���ݱ�ʾ
    FDesc: string;                       //��������
    FNumOnce: Byte;                      //���η���
    FNumAll: Word;                       //������
    FNumFree: Word;                      //��������
    FNumLock: Int64;                     //�������

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

  TMemDataManager = class(TCommonObjectBase)
  private
    FLockCounter: Int64;
    //��������
    FSerialBase: Word;
    //�������
    FDataList: TList;
    FDataUsed: TMPDataUsedItems;
    //�����б�
    FSyncLock: TCriticalSection;
    //ͬ������
  protected
    procedure ClearData(const nData: PMPDataMain);
    procedure ClearList(const nFree: Boolean);
    //��������
    procedure SetUsedFlag(const nItem,nMain: Pointer);
    //ʹ�ñ��
    function GetDataByMain(const nMain: PMPDataMain): Pointer;
    //��ȡ����
    function FindDataMain(const nType: Word = 0;
     const nFlag: string = ''): Integer;
    //��������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    function RegDataType(const nFlag,nDesc: string; const nNew: TMPDataNew;
     const nDispose: TMPDataDispose; const nNumOnce: Byte = 1): Word;
    procedure UnregType(const nType: Word); overload;
    procedure UnregType(const nFlag: string); overload;
    //ע���ͷ�
    function LockData(const nType: Word): Pointer; overload;
    function LockData(const nFlag: string): Pointer; overload;
    procedure UnLockData(const nData: Pointer);
    //�����ͷ�
    procedure EnumData(const nType: Word; const nFlag: string;
      const nCallback: TMPDataEnumCallback; const nResult: TList = nil);
    //ö������
    procedure GetStatus(const nList: TStrings); override;
    //��ȡ״̬
  end;

var
  gMemDataManager: TMemDataManager = nil;
  //ȫ��ʹ��

implementation

constructor TMemDataManager.Create;
begin
  inherited;
  FLockCounter := 0;
  FSerialBase := 0;

  SetLength(FDataUsed, 0);  
  FDataList := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TMemDataManager.Destroy;
begin
  ClearList(True);
  FSyncLock.Free;
  inherited;
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

      nData.FDataDispose(nData.FFlag, nData.FType, nTmp.FData);
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

//Date: 2015-08-04
//Parm: ���ͱ��;���ͱ�ʶ
//Desc: ��������ΪnType������
function TMemDataManager.FindDataMain(const nType: Word;
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

//Date: 2015-08-04
//Parm: ��ʶ;����;����,�ͷŻص�;ÿ�η������
//Desc: ע��һ������ΪnDesc����������,�������ͱ��
function TMemDataManager.RegDataType(const nFlag,nDesc: string;
  const nNew: TMPDataNew; const nDispose: TMPDataDispose;
  const nNumOnce: Byte): Word;
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

  FSyncLock.Enter;
  try
    Inc(FSerialBase);
    Result := FSerialBase;

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
    FSyncLock.Leave;
  end;   
end;

//Date: 2015-08-04
//Parm: ���ͱ��
//Desc: ע�����ΪnType����������
procedure TMemDataManager.UnregType(const nType: Word);
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    nIdx := FindDataMain(nType);
    if nIdx > -1 then
    begin
      ClearData(FDataList[nIdx]);
      FDataList.Delete(nIdx);
    end;
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2015-08-05
//Parm: ���ͱ�ʶ
//Desc: ע����ʶΪnType����������
procedure TMemDataManager.UnregType(const nFlag: string);
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    nIdx := FindDataMain(0, nFlag);
    if nIdx > -1 then
    begin
      ClearData(FDataList[nIdx]);
      FDataList.Delete(nIdx);
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2015-08-05
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
      Dec(FMain.FNumFree);
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
  if nInt >= 10000 then
    raise Exception.Create(ClassName + ': DataUsed Array Is Full.');
  //xxxxx

  SetLength(FDataUsed, nInt + 10);
  for nIdx:=nInt to High(FDataUsed) do
    FDataUsed[nIdx].FUsed := False;
  //init flag

  nIdx := nInt;
  SetFlag;
end;

//Date: 2015-08-05
//Parm: ����
//Desc: ����nMain�еĿ���������
function TMemDataManager.GetDataByMain(const nMain: PMPDataMain): Pointer;
var nIdx: Integer;
    nItem: PMPDataItem;
begin
  Inc(FLockCounter);
  Inc(nMain.FNumLock);
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

  if nMain.FNumAll >= High(Word) - nMain.FNumOnce then
    raise Exception.Create(ClassName + ': Data List Is Full.');
  //xxxxx

  for nIdx:=1 to nMain.FNumOnce do
  begin
    New(nItem);
    FillChar(nItem^, SizeOf(TMPDataItem), #0);

    nItem.FNext := nMain.FDataFirst; //�����������
    nMain.FDataFirst := nItem;
    nMain.FDataNew(nMain.FFlag, nMain.FType, nItem.FData);

    Inc(nMain.FNumAll);
    Inc(nMain.FNumFree);
  end;

  SetUsedFlag(nItem, nMain);
  Result := nItem.FData; //��������
end;

//Date: 2015-08-04
//Parm: ���ͱ��
//Desc: ��������ΪnType��һ��������,�ӻ�����ȡ����,���·���
function TMemDataManager.LockData(const nType: Word): Pointer;
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    Result := nil;
    nIdx := FindDataMain(nType);

    if nIdx < 0 then
      raise Exception.Create(ClassName + ': Invalid Data Type.');
    Result := GetDataByMain(FDataList[nIdx]);
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2015-08-05
//Parm: ���ͱ��
//Desc: ���ر�ʶΪnFlag��һ��������,�ӻ�����ȡ����,���·���
function TMemDataManager.LockData(const nFlag: string): Pointer;
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    Result := nil;
    nIdx := FindDataMain(0, nFlag);

    if nIdx < 0 then
      raise Exception.Create(ClassName + ': Invalid Data Flag.');
    Result := GetDataByMain(FDataList[nIdx]);
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2015-08-04
//Parm: ���ͱ��;������
//Desc: ��nData��״̬��Ϊ����
procedure TMemDataManager.UnLockData(const nData: Pointer);
var nIdx: Integer;
begin
  if Assigned(nData) then
  try
    FSyncLock.Enter;
    //locked
    
    for nIdx:=Low(FDataUsed) to High(FDataUsed) do
     with FDataUsed[nIdx] do
      if FUsed and (FItem.FData = nData) then
      begin
        FUsed := False;
        FItem.FUsed := False;

        Inc(FMain.FNumFree);
        Exit;
      end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2015-11-19
//Parm: ���ͱ��;���ͱ�ʶ;�ص�;�����
//Desc: ö�ٱ��ΪnType,���ʶΪnFlag���б�
procedure TMemDataManager.EnumData(const nType: Word; const nFlag: string; 
  const nCallback: TMPDataEnumCallback; const nResult: TList);
var nIdx: Integer;
    nItem: PMPDataItem;
begin
  FSyncLock.Enter;
  try
    if nType > 0 then
      nIdx := FindDataMain(nType) else
    if nFlag <> '' then
         nIdx := FindDataMain(0, nFlag)
    else nIdx := -1;
    if nIdx < 0 then Exit;

    nItem := PMPDataMain(FDataList[nIdx]).FDataFirst;
    while Assigned(nItem) do
    begin
      if nItem.FUsed and (not nCallback(nItem.FData, nResult)) then
        Break;
      nItem := nItem.FNext;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2015-08-05
//Parm: ����б�
//Desc: ��ȡ����״̬,����nList��
procedure TMemDataManager.GetStatus(const nList: TStrings);
var nStr: string;
    nIdx: Integer;
    nMain: PMPDataMain;
begin
  FSyncLock.Enter;
  try
    nList.Add('DataUsed: ' + #9 + IntToStr(Length(FDataUsed)));
    nList.Add('LockCounter: ' + #9 + IntToStr(FLockCounter));
                                  
    for nIdx:=0 to FDataList.Count - 1 do
    begin
      nList.Add('');
      nMain := FDataList[nIdx];
      nStr := '%s.%s.%s:' + #9 + '%d';

      nList.Add(Format(nStr, [nMain.FFlag, nMain.FDesc, 'NumAll', nMain.FNumAll]));
      nList.Add(Format(nStr, [nMain.FFlag, nMain.FDesc, 'NumFree', nMain.FNumFree]));
      nList.Add(Format(nStr, [nMain.FFlag, nMain.FDesc, 'NumLock', nMain.FNumLock]));
    end;
  finally
    FSyncLock.Leave;
  end;
end;

initialization
  gMemDataManager := nil;
finalization
  FreeAndNil(gMemDataManager);
end.
