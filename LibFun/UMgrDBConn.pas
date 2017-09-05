{*******************************************************************************
  ����: dmzn@163.com 2011-10-22
  ����: ���ݿ����ӹ�����

  ��ע:
  *.�������ӹ�����,ά��һ�����ݿ����Ӳ���,����̬�������Ӷ���.
  *.ÿ�����Ӳ���ʹ��һ��ID��ʶ,����ڸ��ٹ�ϣ����.
  *.ÿ�����Ӷ���ʹ��һ��ID��ʶ,��ʾ��ͬһ�����ݿ�,���ж����������.
  *.ÿ�����Ӷ�Ӧһ�����ݿ�,ÿ��������ӦN��Workerʵ�ʸ���Connection,������
    ����
*******************************************************************************}
unit UMgrDBConn;

interface

uses
  ActiveX, ADODB, Classes, DB, Windows, SysUtils, SyncObjs, UMgrHashDict,
  UWaitItem, USysLoger, UBaseObject;

const
  cErr_GetConn_NoParam     = $0001;            //�����Ӳ���
  cErr_GetConn_NoAllowed   = $0002;            //��ֹ����
  cErr_GetConn_Closing     = $0003;            //�������Ͽ�
  cErr_GetConn_MaxConn     = $0005;            //���������
  cErr_GetConn_BuildFail   = $0006;            //����ʧ��

type
  PDBParam = ^TDBParam;
  TDBParam = record
    FID        : string;                       //������ʶ
    FName      : string;                       //��ʶ����
    FHost      : string;                       //������ַ
    FPort      : Integer;                      //����˿�
    FDB        : string;                       //���ݿ���
    FUser      : string;                       //�û���
    FPwd       : string;                       //�û�����
    FConn      : string;                       //�����ַ�
    
    FEnable    : Boolean;                      //���ò���
    FNumWorker : Integer;                      //����������
  end;

  PDBWorker = ^TDBWorker;
  TDBWorker = record
    FIdle : Boolean;                            //δ����
    FConn : TADOConnection;                     //���Ӷ���
    FQuery: TADOQuery;                          //��ѯ����
    FExec : TADOQuery;                          //��������

    FWaiter: TWaitObject;                       //�ӳٶ���
    FUsed : Integer;                            //�ŶӼ���
    FLock : TCriticalSection;                   //ͬ������

    FThreadID: THandle;                         //�����߳�
    FCallNum: Integer;                          //���ü���
    FConnItem: Pointer;                         //����������(ר��)
  end;

  PDBConnItem = ^TDBConnItem;
  TDBConnItem = record
    FID   : string;                             //���ӱ�ʶ
    FUsed : Integer;                            //�ŶӼ���
    FLast : Cardinal;                           //�ϴ�ʹ��
    FWorker: array of PDBWorker;                //��������
  end;

  PDBConnStatus = ^TDBConnStatus;
  TDBConnStatus = record
    FNumConnParam: Integer;                     //���������ݿ����
    FNumConnItem: Integer;                      //������(���ݿ�)����
    FNumConnObj: Integer;                       //���Ӷ���(Connection)����
    FNumObjConned: Integer;                     //�����Ӷ���(Connection)����
    FNumObjReUsed: Cardinal;                    //�����ظ�ʹ�ô���
    FNumObjRequest: Cardinal;                   //������������
    FNumObjRequestErr: Cardinal;                //����������
    FNumObjWait: Integer;                       //�Ŷ��ж���(Worker.FUsed)����
    FNumWaitMax: Integer;                       //�Ŷ�����������ж������
    FNumMaxTime: TDateTime;                     //�Ŷ����ʱ��
  end;

  TDBActionCallback = function (const nWorker: PDBWorker;
    const nData: Pointer): Boolean;
  TDBActionCallbackObj = function (const nWorker: PDBWorker;
    const nData: Pointer): Boolean of object;
  //�ص�����

  TDBConnManager = class(TCommonObjectBase)
  private
    FWorkers: TList;
    //��������
    FConnDef: string;
    FConnItems: TList;
    //�����б�
    FParams: THashDictionary;
    //�����б�
    FConnClosing: Integer;
    FAllowedRequest: Integer;
    FSyncLock: TCriticalSection;
    //ͬ����
    FStatus: TDBConnStatus;
    //����״̬
  protected
    procedure DoFreeDict(const nType: Word; const nData: Pointer);
    //�ͷ��ֵ�
    procedure FreeDBConnItem(const nItem: PDBConnItem);
    procedure ClearConnItems(const nFreeMe: Boolean);
    //��������
    procedure ClearWorkers(const nFreeMe: Boolean);
    //�������
    procedure WorkerAction(const nWorker: PDBWorker; const nIdx: Integer = -1;
     const nFree: Boolean = True);
    function GetIdleWorker(const nLocked: Boolean): PDBWorker;
    //�������
    function CloseWorkerConnection(const nWorker: PDBWorker): Boolean;
    function CloseConnection(const nID: string; const nLock: Boolean): Integer;
    //�ر�����
    procedure DoAfterConnection(Sender: TObject);
    procedure DoAfterDisconnection(Sender: TObject);
    //ʱ���
    function GetRunStatus: TDBConnStatus;
    //��ȡ״̬
    function GetMaxConn: Integer;
    procedure SetMaxConn(const nValue: Integer);
    //����������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure AddParam(const nParam: TDBParam);
    procedure DelParam(const nID: string = '');
    procedure ClearParam;
    //��������
    function GetConnectionStr(const nID: string): string;
    class function MakeDBConnection(const nParam: TDBParam): string;
    //�����ַ���
    function GetConnection(const nID: string; var nErrCode: Integer;
     const nThreadUnion: Boolean = False): PDBWorker;
    procedure ReleaseConnection(const nWorker: PDBWorker);
    //ʹ������
    function Disconnection(const nID: string = ''): Integer;
    //�Ͽ�����
    function WorkerQuery(const nWorker: PDBWorker; const nSQL: string): TDataSet;
    function WorkerExec(const nWorker: PDBWorker; const nSQL: string): Integer;
    //��������
    function SQLQuery(const nSQL: string; var nWorker: PDBWorker;
      nID: string = ''): TDataSet;
    function ExecSQLs(const nSQLs: TStrings; const nTrans: Boolean;
      nID: string = ''): Boolean;
    function ExecSQL(const nSQL: string; nID: string = ''): Integer;
    //��д����
    function DBAction(const nAction: TDBActionCallback;
      const nData: Pointer = nil; nID: string = ''): Boolean; overload;
    function DBAction(const nAction: TDBActionCallbackObj;
      const nData: Pointer = nil; nID: string = ''): Boolean; overload;
    //��д�ص�ģʽ
    procedure GetStatus(const nList: TStrings); override;
    //����״̬
    property Status: TDBConnStatus read GetRunStatus;
    property MaxConn: Integer read GetMaxConn write SetMaxConn;
    property DefaultConnection: string read FConnDef write FConnDef;
    //�������
  end;

var
  gDBConnManager: TDBConnManager = nil;
  //ȫ��ʹ��

implementation

const
  cTrue  = $1101;
  cFalse = $1105;
  //��������

resourcestring
  sNoAllowedWhenRequest = '���ӳض����ͷ�ʱ�յ�����,�Ѿܾ�.';
  sClosingWhenRequest   = '���ӳض���ر�ʱ�յ�����,�Ѿܾ�.';
  sNoParamWhenRequest   = '���ӳض����յ�����,����ƥ�����.';
  sBuildWorkerFailure   = '���ӳض��󴴽�DBWorkerʧ��.';

//------------------------------------------------------------------------------
//Desc: ��¼��־
procedure WriteLog(const nMsg: string);
begin
  if Assigned(gSysLoger) then
    gSysLoger.AddLog(TDBConnManager, '���ݿ����ӳ�', nMsg);
  //xxxxx
end;

constructor TDBConnManager.Create;
begin
  inherited;
  FConnClosing := cFalse;
  FAllowedRequest := cTrue;

  FConnDef := '';
  FConnItems := TList.Create;

  FWorkers := TList.Create;
  FSyncLock := TCriticalSection.Create;
  
  FParams := THashDictionary.Create(3);
  FParams.OnDataFree := DoFreeDict;
end;

destructor TDBConnManager.Destroy;
begin
  ClearConnItems(True);
  ClearWorkers(True);

  FParams.Free;
  FSyncLock.Free;
  inherited;
end;

//Desc: ��ȡ���������
function TDBConnManager.GetMaxConn: Integer;
begin
  Result := FWorkers.Count;
end;

//Desc: ������������������(����ǰ����)
procedure TDBConnManager.SetMaxConn(const nValue: Integer);
var nIdx: Integer;
    nItem: PDBWorker;
begin
  FSyncLock.Enter;
  try
    if FWorkers.Count <= nValue then
    begin
      for nIdx:=FWorkers.Count to nValue-1  do
      begin
        New(nItem);
        FWorkers.Add(nItem);
        FillChar(nItem^, SizeOf(TDBWorker), #0);

        with nItem^ do
        begin
          if not Assigned(FConn) then
          begin
            FConn := TADOConnection.Create(nil);
            InterlockedIncrement(FStatus.FNumConnObj);

            with FConn do
            begin
              ConnectionTimeout := 7;
              LoginPrompt := False;
              AfterConnect := DoAfterConnection;
              AfterDisconnect := DoAfterDisconnection;
            end;
          end;

          if not Assigned(FQuery) then
          begin
            FQuery := TADOQuery.Create(nil);
            FQuery.Connection := FConn;
          end;

          if not Assigned(FExec) then
          begin
            FExec := TADOQuery.Create(nil);
            FExec.Connection := FConn;
          end;

          if not Assigned(FWaiter) then
          begin
            FWaiter := TWaitObject.Create;
            FWaiter.Interval := 2 * 10;
          end;

          if not Assigned(FLock) then
            FLock := TCriticalSection.Create;
          FIdle := True;
        end;
      end; //add

      Exit;
    end;

    try
      InterlockedExchange(FConnClosing, cTrue);
      //close flag

      for nIdx:=FWorkers.Count - 1 downto nValue do
        WorkerAction(nil, nIdx, True);
      //delete 
    finally
      InterlockedExchange(FConnClosing, cFalse);
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2012-4-1
//Parm: ��������;����;�ͷ�,����
//Desc: ��nWorker��nIdx�����Ķ������ͷŻ���������
procedure TDBConnManager.WorkerAction(const nWorker: PDBWorker;
 const nIdx: Integer; const nFree: Boolean);
var i: Integer;
    nItem: PDBWorker;
begin
  if Assigned(nWorker) then
       i := FWorkers.IndexOf(nWorker)
  else i := nIdx;

  if i < 0 then Exit;
  nItem := FWorkers[i];
  if not Assigned(nItem) then Exit;

  if not nFree then
  begin
    nItem.FIdle := True;
    nItem.FUsed := 0;
    Exit;
  end;

  with nItem^ do
  begin
    FreeAndNil(FQuery);
    FreeAndNil(FExec);
    FreeAndNil(FConn);
    FreeAndNil(FLock);
    FreeAndNil(FWaiter);
  end;

  Dispose(nItem);
  FWorkers.Delete(nIdx);
end;

//Desc: ��ȡ���ж���
function TDBConnManager.GetIdleWorker(const nLocked: Boolean): PDBWorker;
var nIdx: Integer;
    nItem: PDBWorker;
begin
  Result := nil;

  for nIdx:=FWorkers.Count - 1 downto 0 do
  begin
    nItem := FWorkers[nIdx];
    if not nItem.FIdle then Continue;

    nItem.FIdle := not nLocked;
    Result := nItem;
    Break;
  end;
end;

//Desc: ��չ���������
procedure TDBConnManager.ClearWorkers(const nFreeMe: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FWorkers.Count - 1 downto 0 do
    WorkerAction(nil, nIdx, True);
  //clear

  if nFreeMe then
    FWorkers.Free;
  //free
end;

//Desc: �ͷ��ֵ���
procedure TDBConnManager.DoFreeDict(const nType: Word; const nData: Pointer);
begin
  Dispose(PDBParam(nData));
end;

//Desc: �ͷ����Ӷ���
procedure TDBConnManager.FreeDBConnItem(const nItem: PDBConnItem);
var nIdx: Integer;
begin
  for nIdx:=Low(nItem.FWorker) to High(nItem.FWorker) do
  begin
    WorkerAction(nItem.FWorker[nIdx], -1, False);
    nItem.FWorker[nIdx] := nil;
  end;

  Dispose(nItem);
end;

//Desc: �������Ӷ���
procedure TDBConnManager.ClearConnItems(const nFreeMe: Boolean);
var nIdx: Integer;
begin
  if nFreeMe then
    InterlockedExchange(FAllowedRequest, cFalse);
  //����ر�

  FSyncLock.Enter;
  try
    CloseConnection('', False);
    //�Ͽ�ȫ������

    for nIdx:=FConnItems.Count - 1 downto 0 do
    begin
      FreeDBConnItem(FConnItems[nIdx]);
      FConnItems.Delete(nIdx);
    end;

    if nFreeMe then
      FreeAndNil(FConnItems);
    FillChar(FStatus, SizeOf(FStatus), #0);
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: �Ͽ������ݿ������
function TDBConnManager.Disconnection(const nID: string): Integer;
begin
  Result := CloseConnection(nID, True);
end;

//Desc: �Ͽ�nWorker����������,�Ͽ��ɹ�����True.
function TDBConnManager.CloseWorkerConnection(const nWorker: PDBWorker): Boolean;
begin
  //�ó���,�ȴ����������ͷ�
  FSyncLock.Leave;
  try
    while nWorker.FUsed > 0 do
      nWorker.FWaiter.EnterWait;
    //�ȴ������˳�
  finally
    FSyncLock.Enter;
  end;

  try
    nWorker.FConn.Connected := False;
  except
    //ignor any error
  end;

  Result := not nWorker.FConn.Connected;
end;

//Desc: �ر�ָ������,���عرո���.
function TDBConnManager.CloseConnection(const nID: string;
  const nLock: Boolean): Integer;
var nIdx,nInt: Integer;
    nItem: PDBConnItem;
begin
  Result := 0;
  if InterlockedExchange(FConnClosing, cTrue) = cTrue then Exit;

  if nLock then FSyncLock.Enter;
  try
    for nIdx:=FConnItems.Count - 1 downto 0 do
    begin
      nItem := FConnItems[nIdx];
      if (nID <> '') and (CompareText(nItem.FID, nID) <> 0) then Continue;

      nItem.FUsed := 0;
      //���ü���

      for nInt:=Low(nItem.FWorker) to High(nItem.FWorker) do
      if Assigned(nItem.FWorker[nInt]) then
      begin
        if CloseWorkerConnection(nItem.FWorker[nInt]) then
          Inc(Result);
        nItem.FWorker[nInt].FUsed := 0;
      end;
    end;
  finally
    InterlockedExchange(FConnClosing, cFalse);
    if nLock then FSyncLock.Leave;
  end;
end;

//Desc: �������ӳɹ�
procedure TDBConnManager.DoAfterConnection(Sender: TObject);
begin
  InterlockedIncrement(FStatus.FNumObjConned);
end;

//Desc: ���ݶϿ��ɹ�
procedure TDBConnManager.DoAfterDisconnection(Sender: TObject);
begin
  InterlockedDecrement(FStatus.FNumObjConned);
end;

//------------------------------------------------------------------------------
//Desc: ���ɱ��������ݿ�����
class function TDBConnManager.MakeDBConnection(const nParam: TDBParam): string;
begin
  with nParam do
  begin
    Result := FConn;
    Result := StringReplace(Result, '$DBName', FDB, [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '$Host', FHost, [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '$User', FUser, [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '$Pwd', FPwd, [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '$Port', IntToStr(FPort), [rfReplaceAll, rfIgnoreCase]);
  end;
end;

//Desc: ��Ӳ���
procedure TDBConnManager.AddParam(const nParam: TDBParam);
var nPtr: PDBParam;
    nData: PDictData;
begin
  if nParam.FID = '' then Exit;

  FSyncLock.Enter;
  try
    nData := FParams.FindItem(nParam.FID);
    if not Assigned(nData) then
    begin
      New(nPtr);
      FParams.AddItem(nParam.FID, nPtr, 0, False);
      Inc(FStatus.FNumConnParam);
    end else nPtr := nData.FData;

    nPtr^ := nParam;
    nPtr.FConn := MakeDBConnection(nParam);

    if nPtr.FNumWorker < 1 then
      nPtr.FNumWorker := 3;
    //xxxxx

    if FConnDef = '' then
      FConnDef := nParam.FID;
    //first is default
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: ɾ������
procedure TDBConnManager.DelParam(const nID: string);
begin
  FSyncLock.Enter;
  try
    if FParams.DelItem(nID) then
      Dec(FStatus.FNumConnParam);
    //xxxxx
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: �������
procedure TDBConnManager.ClearParam;
begin
  FSyncLock.Enter;
  try
    FParams.ClearItem;
    FStatus.FNumConnParam := 0;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: ��ȡnID�����������ַ���
function TDBConnManager.GetConnectionStr(const nID: string): string;
var nPtr: PDBParam;
    nData: PDictData;
begin
  FSyncLock.Enter;
  try
    nData := FParams.FindItem(nID);
    if Assigned(nData) then
    begin
      nPtr := nData.FData;
      Result := nPtr.FConn;
    end else Result := '';
  finally
    FSyncLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2011-10-23
//Parm: ���ӱ�ʶ;������;ͬ�߳�ʹ����ͬ��·
//Desc: ����nID���õ��������Ӷ���
function TDBConnManager.GetConnection(const nID: string; var nErrCode: Integer;
 const nThreadUnion: Boolean): PDBWorker;
var nIdx: Integer;
    nParam: PDictData;
    nWorker: PDBWorker;
    nItem,nIdle,nTmp: PDBConnItem;
begin
  Result := nil;
  nErrCode := cErr_GetConn_NoAllowed;

  if FAllowedRequest = cFalse then
  begin
    WriteLog(sNoAllowedWhenRequest);
    Exit;
  end;

  nErrCode := cErr_GetConn_Closing;
  if FConnClosing = cTrue then
  begin
    WriteLog(sClosingWhenRequest);
    Exit;
  end;

  FSyncLock.Enter;
  try
    nErrCode := cErr_GetConn_NoAllowed;
    if FAllowedRequest = cFalse then
    begin
      WriteLog(sNoAllowedWhenRequest);
      Exit;
    end;

    nErrCode := cErr_GetConn_Closing;
    if FConnClosing = cTrue then
    begin
      WriteLog(sClosingWhenRequest);
      Exit;
    end;
    //�ظ��ж�,����Get��close���������ص�(get.enter��close.enter�������ȴ�)

    Inc(FStatus.FNumObjRequest);
    nErrCode := cErr_GetConn_NoParam;
    nParam := FParams.FindItem(nID);
    
    if not Assigned(nParam) then
    begin
      WriteLog(sNoParamWhenRequest);
      Exit;
    end;

    //--------------------------------------------------------------------------
    nItem := nil;
    nIdle := nil;

    for nIdx:=FConnItems.Count - 1 downto 0 do
    begin
      nTmp := FConnItems[nIdx];
      if CompareText(nID, nTmp.FID) = 0 then
      begin
        nItem := nTmp; Break;
      end;

      if nTmp.FUsed < 1 then
       if (not Assigned(nIdle)) or (nIdle.FLast > nTmp.FLast) then
        nIdle := nTmp;
      //����ʱ�������
    end;

    if not Assigned(nItem) then
    begin
      nWorker := GetIdleWorker(False);
      if (not Assigned(nIdle)) and (not Assigned(nWorker)) then
      begin
        nErrCode := cErr_GetConn_MaxConn; Exit;
      end;

      if Assigned(nWorker) then
      begin
        New(nItem);
        FConnItems.Add(nItem);
        Inc(FStatus.FNumConnItem);

        nItem.FID := nID;
        nItem.FUsed := 0;
        SetLength(nItem.FWorker, PDBParam(nParam.FData).FNumWorker);

        for nIdx:=Low(nItem.FWorker) to High(nItem.FWorker) do
          nItem.FWorker[nIdx] := nil;
        //xxxxx
      end else
      begin
        nItem := nIdle;
        nItem.FID := nID;
        nItem.FUsed := 1;

        try
          for nIdx:=Low(nItem.FWorker) to High(nItem.FWorker) do
           if Assigned(nItem.FWorker[nIdx]) then
            CloseWorkerConnection(nItem.Fworker[nIdx]);
          Inc(FStatus.FNumObjReUsed);
        finally
          nItem.FUsed := 0;
        end;
      end;
    end;

    //--------------------------------------------------------------------------
    with nItem^ do
    begin
      for nIdx:=Low(FWorker) to High(FWorker) do
      begin
        if (Assigned(FWorker[nIdx])) and
           (FWorker[nIdx].FThreadID > 0) and
           (FWorker[nIdx].FThreadID = GetCurrentThreadId) then
        begin
          Result := FWorker[nIdx];
          Inc(Result.FCallNum);
          Break;
        end;
      end; //����ɨ��ͬ�߳���·

      if not Assigned(Result) then
      begin
        for nIdx:=Low(FWorker) to High(FWorker) do
        begin
          if Assigned(FWorker[nIdx]) then
          begin
            if FWorker[nIdx].FUsed < 1 then
            begin
              Result := FWorker[nIdx];
              Break;
            end;

            //�Ŷ����ٵĹ�������
            if (not Assigned(Result)) or
               (FWorker[nIdx].FUsed < Result.FUsed) then
            begin
              Result := FWorker[nIdx];
            end;
          end else
          begin
            Result := GetIdleWorker(True);
            FWorker[nIdx] := Result;
            if Assigned(Result) then Break;
          end; //�¹�������
        end;
      end; //ɨ�������·

      if Assigned(Result) then
      begin
        Inc(Result.FUsed);
        Inc(nItem.FUsed);
        Inc(FStatus.FNumObjWait);

        if nThreadUnion and (Result.FThreadID < 1) then
        begin
          Inc(Result.FCallNum);
          Result.FThreadID := GetCurrentThreadId;
        end;
        {-----------------------------------------------------------------------
        ԭ��:
        1.���÷�����Worker���ڵ�ThreadID.
        2.���ڱ����÷����ȼ���ͬ�̵߳�Worker,�����ɹ������ӵ��ü���.
        3.���÷�ʹ����Ϻ�,ɾ��ThreadID.
        -----------------------------------------------------------------------}

        if nItem.FUsed > FStatus.FNumWaitMax then
        begin
          FStatus.FNumWaitMax := nItem.FUsed;
          FStatus.FNumMaxTime := Now;
        end;

        if not Result.FConn.Connected then
          Result.FConn.ConnectionString := PDBParam(nParam.FData).FConn;
        Result.FConnItem := nItem;
      end;
    end;
  finally
    if not Assigned(Result) then
      Inc(FStatus.FNumObjRequestErr);
    FSyncLock.Leave;
  end;

  if Assigned(Result) then
  with Result^ do
  begin
    if Result.FCallNum <= 1 then
      FLock.Enter;
    //������������Ŷ�

    if FConnClosing = cTrue then
    try
      Result := nil;
      nErrCode := cErr_GetConn_Closing;

      InterlockedDecrement(FUsed);
      InterlockedDecrement(FStatus.FNumObjWait);
      FWaiter.Wakeup;
    finally
      FLock.Leave;
    end;

    if Result.FCallNum <= 1 then
      CoInitialize(nil);
    //��ʼ��COM����
  end;
end;

//Date: 2011-10-23
//Parm: ���ݶ���
//Desc: �ͷ�nWorker���Ӷ���
procedure TDBConnManager.ReleaseConnection(const nWorker: PDBWorker);
var nItem: PDBConnItem;
begin
  if not Assigned(nWorker) then Exit;
  //invalid worker to release

  FSyncLock.Enter;
  try
    if nWorker.FCallNum > 0 then
      Dec(nWorker.FCallNum);
    //ͬ�̵߳��ü���

    if nWorker.FCallNum < 1 then
    try
      nWorker.FThreadID := 0;
      //ͬ�̵߳��ý���,ɾ���̱߳�ʶ
      
      if nWorker.FQuery.Active then
        nWorker.FQuery.Close;
      //xxxxx
    except
      on E:Exception do
      begin
        WriteLog(E.Message);
      end;
    end;

    nItem := nWorker.FConnItem;
    Dec(nItem.FUsed);
    nItem.FLast := GetTickCount;

    Dec(nWorker.FUsed);
    if nWorker.FCallNum < 1 then
      nWorker.FLock.Leave;
    Dec(FStatus.FNumObjWait);

    if FConnClosing = cTrue then
      nWorker.FWaiter.Wakeup;
    //xxxxx
  finally
    if nWorker.FCallNum < 1 then
      CoUnInitialize; //�ͷ�COM����    
    FSyncLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ȡ����״̬
function TDBConnManager.GetRunStatus: TDBConnStatus;
begin
  FSyncLock.Enter;
  try
    Result := FStatus;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: ִ��д�������
function TDBConnManager.WorkerExec(const nWorker: PDBWorker;
  const nSQL: string): Integer;
var nStep: Integer;
    nException: string;
begin
  Result := -1;
  nException := '';
  nStep := 0;

  while nStep <= 2 do
  try
    if nStep = 1 then
    begin
      nWorker.FQuery.Close;
      nWorker.FQuery.SQL.Text := 'select 1';
      nWorker.FQuery.Open;

      nWorker.FQuery.Close;
      Break;
      //connection is ok
    end else

    if nStep = 2 then
    begin
      nWorker.FConn.Close;
      nWorker.FConn.Open;
    end; //reconnnect
           
    nWorker.FExec.Close;
    nWorker.FExec.SQL.Text := nSQL;
    Result := nWorker.FExec.ExecSQL;

    nException := '';
    Break;
  except
    on E:Exception do
    begin
      Inc(nStep);
      nException := E.Message;
    end;
  end;

  if nException <> '' then
  begin
    WriteLog('SQL: ' + nSQL + ' ::: ' + nException);
    raise Exception.Create(nException);
  end;
end;

//Desc: ִ�в�ѯ���
function TDBConnManager.WorkerQuery(const nWorker: PDBWorker;
  const nSQL: string): TDataSet;
var nStep: Integer;
    nException: string;
begin
  Result := nWorker.FQuery;
  nException := '';
  nStep := 0;

  while nStep <= 2 do
  try
    if nStep = 1 then
    begin
      nWorker.FQuery.Close;
      nWorker.FQuery.SQL.Text := 'select 1';
      nWorker.FQuery.Open;

      nWorker.FQuery.Close;
      Break;
      //connection is ok
    end else

    if nStep = 2 then
    begin
      nWorker.FConn.Close;
      nWorker.FConn.Open;
    end; //reconnnect
    
    nWorker.FQuery.Close;
    nWorker.FQuery.SQL.Text := nSQL;
    nWorker.FQuery.Open;

    nException := '';
    Break;
  except
    on E:Exception do
    begin
      Inc(nStep);
      nException := E.Message;
    end;
  end;

  if nException <> '' then
  begin
    WriteLog('SQL: ' + nSQL + ' ::: ' + nException);
    raise Exception.Create(nException);
  end;
end;

//Date: 2013-07-26
//Parm: ���;��������;���ӱ�ʶ
//Desc: ��nID���ݿ���ִ��nSQL��ѯ,���ؽ��.���ֶ��ͷ�nWorker.
function TDBConnManager.SQLQuery(const nSQL: string; var nWorker: PDBWorker;
  nID: string): TDataSet;
var nErrNum: Integer;
begin
  if nID = '' then
    nID := FConnDef;
  nWorker := GetConnection(nID, nErrNum);

  if not Assigned(nWorker) then
  begin
    nID := Format('����[ %s ]���ݿ�ʧ��(ErrCode: %d).', [nID, nErrNum]);
    WriteLog(nID);
    raise Exception.Create(nID);
  end;

  if not nWorker.FConn.Connected then
    nWorker.FConn.Connected := True;
  //conn db

  Result := WorkerQuery(nWorker, nSQL);
  //do query
end;

//Date: 2013-07-23
//Parm: ���;���ӱ�ʶ
//Desc: ��nID���ݿ���ִ��nSQL���
function TDBConnManager.ExecSQL(const nSQL: string; nID: string): Integer;
var nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  try
    Result := -1;
    if nID = '' then nID := FConnDef;
    nDBConn := GetConnection(nID, nErrNum);

    if not Assigned(nDBConn) then
    begin
      nID := Format('����[ %s ]���ݿ�ʧ��(ErrCode: %d).', [nID, nErrNum]);
      WriteLog(nID);
      raise Exception.Create(nID);
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    Result := WorkerExec(nDBConn, nSQL);
    //do exec
  finally
    ReleaseConnection(nDBConn);
  end;
end;

//Date: 2013-07-23
//Parm: ����б�;�Ƿ�����;���ӱ�ʶ
//Desc: ��nID���ݿ���ִ��nSQLs���
function TDBConnManager.ExecSQLs(const nSQLs: TStrings; const nTrans: Boolean;
  nID: string): Boolean;
var nIdx: Integer;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  try
    Result := False;
    if nID = '' then nID := FConnDef;
    nDBConn := GetConnection(nID, nErrNum);

    if not Assigned(nDBConn) then
    begin
      nID := Format('����[ %s ]���ݿ�ʧ��(ErrCode: %d).', [nID, nErrNum]);
      WriteLog(nID);
      raise Exception.Create(nID);
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    if nTrans then
      nDBConn.FConn.BeginTrans;
    //trans
    try
      for nIdx:=0 to nSQLs.Count - 1 do
        WorkerExec(nDBConn, nSQLs[nIdx]);
      //execute sql list

      if nTrans then
        nDBConn.FConn.CommitTrans;
      Result := True;
    except
      on E:Exception do
      begin
        if nTrans then
          nDBConn.FConn.RollbackTrans;
        WriteLog('SQL: ' + nSQLs.Text + ' ::: ' + E.Message);
      end;
    end;
  finally
    ReleaseConnection(nDBConn);
  end;
end;

//Date: 2013-07-27
//Parm: ����;����;���ӱ�ʶ
//Desc: ��nID���ݿ���ִ��nAction�����ҵ��
function TDBConnManager.DBAction(const nAction: TDBActionCallback;
  const nData: Pointer; nID: string): Boolean;
var nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  try
    Result := False;
    if nID = '' then nID := FConnDef;
    nDBConn := GetConnection(nID, nErrNum);

    if not Assigned(nDBConn) then
    begin
      nID := Format('����[ %s ]���ݿ�ʧ��(ErrCode: %d).', [nID, nErrNum]);
      WriteLog(nID);
      raise Exception.Create(nID);
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    Result := nAction(nDBConn, nData);
    //do action
  finally
    ReleaseConnection(nDBConn);
  end;
end;

//Date: 2013-07-27
//Parm: ����;���ӱ�ʶ
//Desc: ��nID���ݿ���ִ��nAction�����ҵ��
function TDBConnManager.DBAction(const nAction: TDBActionCallbackObj;
  const nData: Pointer; nID: string): Boolean;
var nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  try
    Result := False;
    if nID = '' then nID := FConnDef;
    nDBConn := GetConnection(nID, nErrNum);

    if not Assigned(nDBConn) then
    begin
      nID := Format('����[ %s ]���ݿ�ʧ��(ErrCode: %d).', [nID, nErrNum]);
      WriteLog(nID);
      raise Exception.Create(nID);
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    Result := nAction(nDBConn, nData);
    //do action
  finally
    ReleaseConnection(nDBConn);
  end;
end;

procedure TDBConnManager.GetStatus(const nList: TStrings);
begin
  with GetRunStatus do
  begin
    nList.Add('NumConnParam: ' + #9 + IntToStr(FNumConnParam));
    nList.Add('NumConnItem: ' + #9 + IntToStr(FNumConnItem));
    nList.Add('NumConnObj: ' + #9 + IntToStr(FNumConnObj));
    nList.Add('NumObjConned: ' + #9 + IntToStr(FNumObjConned));
    nList.Add('NumObjReUsed: ' + #9 + IntToStr(FNumObjReUsed));
    nList.Add('NumObjRequest: ' + #9 + IntToStr(FNumObjRequest));
    nList.Add('NumObjReqErr: ' + #9 + IntToStr(FNumObjRequestErr));
    nList.Add('NumObjWait: ' + #9 + IntToStr(FNumObjWait));
    nList.Add('NumWaitMax: ' + #9 + IntToStr(FNumWaitMax));
    nList.Add('NumMaxTime: ' + #9 + DateTimeToStr(FNumMaxTime));
  end;
end;

initialization
  gDBConnManager := nil;
finalization
  FreeAndNil(gDBConnManager);
end.
