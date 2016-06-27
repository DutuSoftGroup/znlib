{*******************************************************************************
  ����: dmzn@163.com 2012-2-22
  ����: ϵͳģ�鹲���ڴ�,���ڽ����ػ���

  ��ע:
  *.�����ػ�ԭ��: ����˺Ϳͻ��˶�ʱ���¹����ڴ�,��KeepInterval��Interval��
    �ͻ����޸���,����Ϊ�ѹ�.�����Kill��Ŀ�겢����.
*******************************************************************************}
unit USysShareMem;

interface

uses
  Windows, Classes, SysUtils, Messages, UMgrShareMem;

const
  cPM_ProgID_Size      = 15;  //pm=Process monitor
  cPM_MonBase_MaxCell  = 20;  //�����ػ����Ԫ��
  cPM_SAPMIT_MAXCell   = 10;  //SAP-MIT�ػ����Ԫ��
  cPM_Update_Interval  = 100; //��С���¼��

type
  TPMStatus = (psUnknow, psClosed, psRun, psRestart);
  //Process status

  PPMDataBase = ^TPMDataBase;
  TPMDataBase = record
    FStatus : TPMStatus;                                   //��ǰ״̬
    FLastUpdate: Cardinal;                                 //�ϴθ���
    FUpdateInterval: Cardinal;                             //���¼��

    FExecuteTime: Byte;                                    //��������
    FHandleForm: THandle;                                  //��ȫ���
    FHandleProg: THandle;                                  //ǿ�ƾ��

    FProgID : array[0..cPM_ProgID_Size-1] of Char;         //�����ʶ
    FProgPath: array[0..MAX_PATH-1] of Char;               //����·��
  end;

  PPMDataSapMIT = ^TPMDataSapMIT;
  TPMDataSapMIT = record
    FBase: TPMDataBase;                                    //��������
    //FSAPConnStatus: TSAPConnStatus;                      //����״̬
  end;

  TPMRunCounter = record
    FNumIn: Cardinal;                                      //�������
    FNumFind: Cardinal;                                    //��Ч����
    FNumSucc: Cardinal;                                    //�ɹ�����
  end;

  TPMType = (ptServer, ptClient);
  //monitor type

  TProcessMonitorBase = class(TObject)
  private
    FType: TPMType;
    //��������
    FClientID: string;
    //�ͻ����
    FInterval: Integer;
    //���¼��
    FKeepInterval: Cardinal;
    //�����
    FCounter: TPMRunCounter;
    //���м���
    FMonThread: TThread;
    //����߳�
    FShareMem: TShareMemoryManager;
    //�ڴ����
  protected
    procedure WriteLog(const nLog: string);
    //��¼��־
    procedure InitSharedMemory(const nSize: Integer);
    //��ʼ��
    function SetCellIndexByID(const nProgID: string): Boolean;
    //ö������
    function DoWriteClientData(const nData: Pointer): Boolean; virtual;
    //�ͻ�����
    function GetMonStatus: Boolean;
    //���״̬
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    function AddProcess(const nProgID,nProgPath: string;
      var nHint: string; const nInit: TPMStatus = psClosed): Boolean;
    function DelProcess(const nProgID: string): Boolean;
    //��ɾ����
    function UpdateHandle(const nHandleForm,nHandleProg: THandle;
      var nHint: string): Boolean;
    //���¾��
    function StartMonitor(var nHint: string; nInterval: Integer = -1): Boolean;
    procedure StopMonitor(const nCloseFlag: Boolean = False);
    //��ͣ����
    property IsBusy: Boolean read GetMonStatus;
    property Counter: TPMRunCounter read FCounter;
    property ShareMem: TShareMemoryManager read FShareMem;
    //�������
  end;

  TProcessMonitorServer = class(TProcessMonitorBase)
  public
    constructor Create(const nMemName,nEventName: string);
    //��������
  end;

  TProcessMonitorClient = class(TProcessMonitorBase)
  public
    constructor Create(const nProgID: string; nMemName: string = '';
      nEventName: string = '');
    //��������
  end;

  TProcessMonitorSapMITServer = class(TProcessMonitorBase)
  public
    constructor Create;
    //��������
  end;

  TProcessMonitorSapMITClient = class(TProcessMonitorBase)
  protected
    FLastUpdate: Cardinal;
    //�ϴθ���
    function DoWriteClientData(const nData: Pointer): Boolean; override;
  public
    constructor Create(const nProgID: string);
    //��������
  end;

var
  gProcessMonitorServer: TProcessMonitorServer = nil;
  gProcessMonitorClient: TProcessMonitorClient = nil;

  gProcessMonitorSapMITServer: TProcessMonitorSapMITServer = nil;
  gProcessMonitorSapMITClient: TProcessMonitorSapMITClient = nil;
  //ȫ��ʹ��

resourcestring
  sPM_BaseMemName     = 'APP_MON_SharedMemory';
  sPM_BaseEventName   = 'APP_MON_SyncEvent';

  sPM_SAPMITShareMem  = 'SAP_MIT_Mon_SharedMemory';
  sPM_SAPMITSyncEvent = 'SAP_MIT_Mon_SyncEvent';

implementation

uses
  ShellAPI, UWaitItem, UMgrLog, USysLoger;

const
  cSize_PMDataBase    = SizeOf(TPMDataBase);
  cSize_PMDataSapMIT  = SizeOf(TPMDataSapMIT);

resourcestring
  sDescServer           = '�����ػ������';
  sDescClient           = '�����ػ��ͻ���';

  sErr_InvalidParam     = 'ִ�к���[ %s ]ʱ������Ч.';
  sErr_NoInitWhenStart  = '���������ػ�,���ڴ滹δ��ʼ��.';
  sErr_FileNotExists    = '����ӵ��ػ����еĳ����ļ�������.';
  sErr_NoInitWhenAdd    = '��Ӵ��ػ�����,���ڴ滹δ��ʼ��.';
  sErr_NoMemoryWhenAdd  = '��Ӵ��ػ�����,���ڴ��ѱ���ȫռ��.';
  sErr_InitMemFailure   = '��ʼ�������ڴ�ʧ��.';
  sErr_InvalidProgID    = '���ػ����̱�ʶ����Ч.';

  sMon_TrySafeClose     = '���԰�ȫ�ر�[ %s ]����.';
  sMon_TryFoceClose     = '����ǿ�ƹر�[ %s ]����.';
  sMon_TryExecProg      = '���Ե�[ %d ]������[ %s ]����.';

//------------------------------------------------------------------------------
type
  TMonThread = class(TThread)
  private
    FOwner: TProcessMonitorBase;
    //ӵ����
    FWaiter: TWaitObject;
    //�ȴ�����
  protected
    procedure Execute; override;
    function DoServerExecute: Boolean;
    function DoClientExecute: Boolean;
    //�߳���
  public
    constructor Create(AOwner: TProcessMonitorBase);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

constructor TMonThread.Create(AOwner: TProcessMonitorBase);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := FOwner.FInterval;
end;

destructor TMonThread.Destroy;
begin
  FreeAndNil(FWaiter);
  inherited;
end;

//Desc: ֹͣ�߳�
procedure TMonThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TMonThread.Execute;
var nVal: Cardinal;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    if FOwner.FInterval > 0 then
    begin
      nVal := FOwner.FInterval;
      if FWaiter.Interval <> nVal then
        FWaiter.Interval := nVal;
      //xxxxx
    end;

    case FOwner.FType of
     ptServer: if not DoServerExecute then Exit;
     ptClient: if not DoClientExecute then Exit;
    end;
    //thread body
  except
    on E:Exception do
    begin
      FOwner.WriteLog(E.Message);
    end;
  end;
end;

//Desc: �����ػ��ͻ�
function TMonThread.DoClientExecute: Boolean;
var nP: Pointer;
begin
  with FOwner do
  begin
    Result := True;
    Inc(FCounter.FNumIn);

    try
      FShareMem.LockData(nP);
      if not Assigned(nP) then Exit;

      Inc(FCounter.FNumFind);
      Inc(FCounter.FNumSucc);

      with PPMDataBase(nP)^ do
      begin
        Result := CompareStr(FOwner.FClientID, FProgID) = 0;
        if not Result then Exit;

        if DoWriteClientData(nP) then
        begin
          FStatus := psRun;
          FLastUpdate := GetTickCount;
          FUpdateInterval := FInterval;
        end;
      end;
    finally
      FShareMem.UnLockData;
    end;
  end;
end;

//Desc: �ػ��ͻ���д�Զ�������,������True��ִ��Ĭ�ϲ���
function TProcessMonitorBase.DoWriteClientData(const nData: Pointer): Boolean;
begin
  Result := True;
end;

//Desc: �����ػ�����
function TMonThread.DoServerExecute: Boolean;
var nP: Pointer;
    nIdx: Integer;
    nHwnd: THandle;
    nData: PPMDataBase;
begin
  with FOwner do
  begin
    Result := True;
    Inc(FCounter.FNumIn);

    for nIdx:=FShareMem.CellNum downto 1 do
    try
      FShareMem.LockData(nP, nIdx);
      if not Assigned(nP) then Continue;

      nData := nP;
      if nData.FStatus = psRun then
      begin
        if (GetTickCount - nData.FLastUpdate) <
           nData.FUpdateInterval * FKeepInterval then Continue;
        //�ϴθ���ʱ��δ����FKeepInterval��FUpdateInterval

        Inc(FCounter.FNumFind);
        with nData^ do
        begin
          FStatus := psRestart;
          FLastUpdate := GetTickCount;
          FExecuteTime := 0;
        end;

        WriteLog(Format(sMon_TrySafeClose, [nData.FProgID]));
        PostMessage(nData.FHandleForm, WM_CLOSE, 0, 0);
      end else

      if nData.FStatus = psRestart then
      begin
        nHwnd := OpenProcess(PROCESS_TERMINATE, False, nData.FHandleProg);
        if nHwnd > 0 then
        try
          if (GetTickCount - nData.FLastUpdate) <
             nData.FUpdateInterval * FKeepInterval then Continue;
          //�ȴ�WM_Close�㹻��ʱ��

          WriteLog(Format(sMon_TryFoceClose, [nData.FProgID]));
          TerminateProcess(nData.FHandleProg, 0);
          Exit;
        finally
          CloseHandle(nHwnd);
        end;                   

        Inc(FCounter.FNumSucc);
        with nData^ do
        begin
          nHwnd := FExecuteTime * 10 * 1000;
          if (GetTickCount - nData.FLastUpdate) < nHwnd then Continue;

          Inc(FExecuteTime);
          WriteLog(Format(sMon_TryExecProg, [FExecuteTime, nData.FProgID]));

          if FExecuteTime >= 3 then
            FStatus := psClosed;
          FLastUpdate := GetTickCount;
        end;

        if FileExists(nData.FProgPath) then
          ShellExecute(0, 'open', nData.FProgPath, nData.FProgID, nil,
                         SW_SHOWNORMAL);
        //to execute program
      end;
    finally
      FShareMem.UnLockData;
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TProcessMonitorBase.Create;
begin
  FInterval := cPM_Update_Interval;
  FMonThread := nil;
  FShareMem := TShareMemoryManager.Create;
end;

destructor TProcessMonitorBase.Destroy;
begin
  StopMonitor;
  FreeAndNil(FShareMem);
  inherited;
end;

//Date: 2012-2-22
//Parm: ��־
//Desc: ��¼�����־
procedure TProcessMonitorBase.WriteLog(const nLog: string);
begin
  if Assigned(gSysLoger) then
  begin
    case FType of
     ptServer: gSysLoger.AddLog(ClassType, sDescServer, nLog);
     ptClient: gSysLoger.AddLog(ClassType, sDescClient, nLog);
    end;
  end;
end;

//Date: 2012-2-22
//Parm: ������ʾ;�ػ����¼��(ms)
//Desc: �����ػ�
function TProcessMonitorBase.StartMonitor(var nHint: string;
  nInterval: Integer): Boolean;
begin
  Result := FShareMem.MemValid;
  if not Result then
  begin
    nHint := sErr_NoInitWhenStart;
    WriteLog(nHint);
    Exit;
  end;

  if nInterval > 0 then
  begin
    if nInterval < cPM_Update_Interval then
      nInterval := cPM_Update_Interval;
    InterlockedExchange(FInterval, nInterval);
  end;

  Result := Assigned(FMonThread);
  if not Result then 
  begin
    FMonThread := TMonThread.Create(Self);
    Result := True;
  end;
end;

//Desc: ֹͣ�ػ�
procedure TProcessMonitorBase.StopMonitor(const nCloseFlag: Boolean);
var nP: Pointer;
begin
  if Assigned(FMonThread) then
  begin
    TMonThread(FMonThread).StopMe;
    FMonThread := nil;
  end;

  if nCloseFlag and (FType = ptClient) then
  try
    FShareMem.LockData(nP);
    if Assigned(nP) then
      PPMDataBase(nP).FStatus := psClosed;
    //close flag
  finally
    FShareMem.UnLockData;
  end;
end;

//Desc: ��ȡ���״̬
function TProcessMonitorBase.GetMonStatus: Boolean;
begin
  Result := Assigned(FMonThread);
end;

//Date: 2012-2-22
//Parm: �����ʶ;����·��;��ʾ��Ϣ;Ĭ��״̬
//Desc: ���һ����ʶΪnProgID,·��ΪnProgPath�ĳ����ػ�����
function TProcessMonitorBase.AddProcess(const nProgID,
  nProgPath: string; var nHint: string; const nInit: TPMStatus): Boolean;
var nP: Pointer;
    nIdx: Integer;

    //Desc: ��������
    procedure UpdateData(const nData: PPMDataBase);
    begin
      with nData^ do
      begin
        FillChar(FProgID, cPM_ProgID_Size, #0);
        StrPLCopy(@FProgID, nProgID, cPM_ProgID_Size);

        FillChar(FProgPath, MAX_PATH, #0);
        StrPLCopy(@FProgPath, nProgPath, MAX_PATH);
      end;
    end;
begin
  Result := FileExists(nProgPath) and (Length(nProgPath) < MAX_PATH);
  if not Result then
  begin
    nHint := sErr_FileNotExists;
    WriteLog(nHint);
    Exit;
  end;

  Result := FShareMem.MemValid;
  if not Result then
  begin
    nHint := sErr_NoInitWhenAdd;
    WriteLog(nHint);
    Exit;
  end;

  Result := False;
  for nIdx:=FShareMem.CellNum downto 1 do
  try
    FShareMem.LockData(nP, nIdx);
    if not Assigned(nP) then Continue;

    with PPMDataBase(nP)^ do
    if CompareStr(nProgID, FProgID) = 0 then
    begin
      FStatus := nInit;
      UpdateData(nP);
      
      Result := True;
      Exit;
    end;
  finally
    FShareMem.UnLockData;
  end;

  for nIdx:=1 to FShareMem.CellNum do
  try
    FShareMem.LockData(nP, nIdx);
    if not Assigned(nP) then Continue;

    with PPMDataBase(nP)^ do
    if FStatus = psUnknow then
    begin
      FStatus := nInit;
      UpdateData(nP);

      Result := True;
      Break;
    end;
  finally
    FShareMem.UnLockData;
  end;

  if not Result then
  begin
    nHint := sErr_NoMemoryWhenAdd;
    WriteLog(nHint);
    Exit;
  end;
end;

//Date: 2012-2-22
//Parm: ��ȫ���;ǿ�ƾ��;������ʾ
//Desc: ���¿ͻ��˾��(Client����)
function TProcessMonitorBase.UpdateHandle(const nHandleForm,
  nHandleProg: THandle; var nHint: string): Boolean;
var nP: Pointer;
begin
  Result := FShareMem.MemValid;
  if not Result then
  begin
    nHint := sErr_InitMemFailure;
    WriteLog(nHint);
    Exit;
  end;

  Result := (FType = ptClient) and (FShareMem.CellIndex > 0);
  if not Result then
  begin
    nHint := Format(sErr_InvalidParam, ['UpdateHandle']);
    WriteLog(nHint);
    Exit;
  end;

  try
    FShareMem.LockData(nP);
    if Assigned(nP) then
     with PPMDataBase(nP)^ do
     begin
       FHandleForm := nHandleForm;
       FHandleProg := nHandleProg;
     end;
  finally
    FShareMem.UnLockData;
  end;
end;

//Date: 2012-2-22
//Parm: �����ʶ
//Desc: ����ʶΪnProgID�ĳ����Ƴ��ػ�����
function TProcessMonitorBase.DelProcess(const nProgID: string): Boolean;
var nP: Pointer;
    nIdx: Integer;
begin
  Result := True;
  if not FShareMem.MemValid then Exit;

  for nIdx:=FShareMem.CellNum downto 1 do
  try
    FShareMem.LockData(nP, nIdx);
    if not Assigned(nP) then Continue;

    with PPMDataBase(nP)^ do
    if CompareStr(nProgID, FProgID) = 0 then
    begin
      FillChar(nP^, cSize_PMDataBase, #0);
      FStatus := psUnknow;
      Exit;
    end;
  finally
    FShareMem.UnLockData;
  end;
end;

//Date: 2012-2-23
//Parm: ��Ԫ��С
//Desc: ��ʼ���ػ��ͻ��˵��ڴ�
procedure TProcessMonitorBase.InitSharedMemory(const nSize: Integer);
var nP: Pointer;
    nID,nPath: string;
begin
  try
    FShareMem.LockData(nP);
    if not Assigned(nP) then Exit;

    with PPMDataBase(nP)^ do
    begin
      if FType = ptClient then
      begin
        nID := FProgID;
        nPath := FProgPath;
      end;

      if (FType <> ptServer) or FShareMem.MemNew then
        FillChar(nP^, nSize, #0);
      //fill #0

      if FType = ptClient then
      begin
        StrPLCopy(@FProgID, nID, cPM_ProgID_Size);
        StrPLCopy(@FProgPath, nPath, MAX_PATH);
      end;
    end;
  finally
    FShareMem.UnLockData;
  end;
end;

//Date: 2012-2-23
//Parm: �����ʶ
//Desc: ����nProgID���õ�Ԫ����
function TProcessMonitorBase.SetCellIndexByID(const nProgID: string): Boolean;
var nP: Pointer;
    nIdx: Integer;
begin
  Result := False;
  //default value

  for nIdx:=FShareMem.CellNum downto 1 do
  try
    FShareMem.LockData(nP, nIdx);
    if not Assigned(nP) then Continue;

    with PPMDataBase(nP)^ do
    if CompareStr(nProgID, FProgID) = 0 then
    begin
      FShareMem.CellIndex := nIdx;
      Result := True;
      Break;
    end;
  finally
    FShareMem.UnLockData;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��׼�ػ�����
constructor TProcessMonitorServer.Create(const nMemName,nEventName: string);
begin
  inherited Create;
  FType := ptServer;
  FKeepInterval := 5;

  FShareMem.InitMem(
     nMemName,             //memory name
     nEventName,           //event name
     cPM_MonBase_MaxCell,  //max Process num
     cSize_PMDataBase,     //size of per
     1, True);             //first cell
  //xxxxx

  if not FShareMem.MemValid then
  begin
    WriteLog(sErr_InitMemFailure);
    raise Exception.Create(sErr_InitMemFailure);
  end;

  InitSharedMemory(FShareMem.MemSize);
  //init memory
end;

//Desc: ��׼�ͻ���
constructor TProcessMonitorClient.Create(const nProgID: string; nMemName,
  nEventName: string);
begin
  inherited Create;
  FType := ptClient;
  FClientID := nProgID;

  FInterval := 500;
  if nMemName = '' then nMemName := sPM_BaseMemName;
  if nEventName = '' then nEventName := sPM_BaseEventName;

  FShareMem.InitMem(
     nMemName,              //memory name
     nEventName,            //event name
     cPM_MonBase_MaxCell,   //max Process num
     cSize_PMDataBase,      //size of per
     0, False);             //none cell
  //xxxxx

  if not FShareMem.MemValid then
  begin
    WriteLog(sErr_InitMemFailure);
    raise Exception.Create(sErr_InitMemFailure);
  end;

  if not SetCellIndexByID(nProgID) then
  begin
    WriteLog(sErr_InvalidProgID);
    raise Exception.Create(sErr_InvalidProgID);
  end;

  InitSharedMemory(cSize_PMDataBase);
  //init memory
end;

//Desc: SAP-MIT�ػ�����
constructor TProcessMonitorSapMITServer.Create;
begin
  inherited Create;
  FType := ptServer;
  FKeepInterval := 5;

  FShareMem.InitMem(
     sPM_SAPMITShareMem,    //memory name
     sPM_SAPMITSyncEvent,   //event name
     cPM_SAPMIT_MAXCell,    //max Process num
     cSize_PMDataSapMIT,    //size of per
     1, True);              //first cell
  //xxxxx

  if not FShareMem.MemValid then
  begin
    WriteLog(sErr_InitMemFailure);
    raise Exception.Create(sErr_InitMemFailure);
  end;

  InitSharedMemory(FShareMem.MemSize);
  //init memory
end;

//Desc: SAP-MIT�ͻ���
constructor TProcessMonitorSapMITClient.Create(const nProgID: string);
begin
  inherited Create;
  FType := ptClient;
  FClientID := nProgID;

  FInterval := 500;
  FKeepInterval := 3;

  FShareMem.InitMem(
     sPM_SAPMITShareMem,    //memory name
     sPM_SAPMITSyncEvent,   //event name
     cPM_SAPMIT_MAXCell,    //max Process num
     cSize_PMDataSapMIT,    //size of per
     0, False);             //none cell
  //xxxxx

  if not FShareMem.MemValid then
  begin
    WriteLog(sErr_InitMemFailure);
    raise Exception.Create(sErr_InitMemFailure);
  end;

  if not SetCellIndexByID(nProgID) then
  begin
    WriteLog(sErr_InvalidProgID);
    raise Exception.Create(sErr_InvalidProgID);
  end;

  InitSharedMemory(cSize_PMDataSapMIT);
  //init memory
end;

//Date: 2012-2-23
//Parm: ����ָ��
//Desc: ���¹����ڴ��е�SAP���ӳ���Ϣ
function TProcessMonitorSapMITClient.DoWriteClientData(
  const nData: Pointer): Boolean;
var nVal: Cardinal;
begin
  Result := True;
  nVal := FInterval;

  if (GetTickCount - FLastUpdate) > nVal * FKeepInterval then
  begin
    {if Assigned(gSAPConnectionManager) then
      PPMDataSapMIT(nData).FSAPConnStatus := gSAPConnectionManager.Status;
    FLastUpdate := GetTickCount;}
  end;
end;

initialization
  gProcessMonitorServer := nil;
  gProcessMonitorClient := nil;

  gProcessMonitorSapMITServer := nil;
  gProcessMonitorSapMITClient := nil;

finalization
  FreeAndNil(gProcessMonitorServer);
  FreeAndNil(gProcessMonitorClient);

  FreeAndNil(gProcessMonitorSapMITClient);
  FreeAndNil(gProcessMonitorSapMITServer);
end.
