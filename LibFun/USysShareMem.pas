{*******************************************************************************
  作者: dmzn@163.com 2012-2-22
  描述: 系统模块共享内存,用于进程守护等

  备注:
  *.进程守护原理: 服务端和客户端定时更新共享内存,若KeepInterval个Interval内
    客户端无更新,则认为已挂.服务端Kill掉目标并重启.
*******************************************************************************}
unit USysShareMem;

interface

uses
  Windows, Classes, SysUtils, Messages, UMgrShareMem;

const
  cPM_ProgID_Size      = 15;  //pm=Process monitor
  cPM_MonBase_MaxCell  = 20;  //基本守护最大单元数
  cPM_SAPMIT_MAXCell   = 10;  //SAP-MIT守护最大单元数
  cPM_Update_Interval  = 100; //最小更新间隔

type
  TPMStatus = (psUnknow, psClosed, psRun, psRestart);
  //Process status

  PPMDataBase = ^TPMDataBase;
  TPMDataBase = record
    FStatus : TPMStatus;                                   //当前状态
    FLastUpdate: Cardinal;                                 //上次更新
    FUpdateInterval: Cardinal;                             //更新间隔

    FExecuteTime: Byte;                                    //重启次数
    FHandleForm: THandle;                                  //安全句柄
    FHandleProg: THandle;                                  //强制句柄

    FProgID : array[0..cPM_ProgID_Size-1] of Char;         //程序标识
    FProgPath: array[0..MAX_PATH-1] of Char;               //程序路径
  end;

  PPMDataSapMIT = ^TPMDataSapMIT;
  TPMDataSapMIT = record
    FBase: TPMDataBase;                                    //基础数据
    //FSAPConnStatus: TSAPConnStatus;                      //连接状态
  end;

  TPMRunCounter = record
    FNumIn: Cardinal;                                      //进入次数
    FNumFind: Cardinal;                                    //生效次数
    FNumSucc: Cardinal;                                    //成功次数
  end;

  TPMType = (ptServer, ptClient);
  //monitor type

  TProcessMonitorBase = class(TObject)
  private
    FType: TPMType;
    //对象类型
    FClientID: string;
    //客户编号
    FInterval: Integer;
    //更新间隔
    FKeepInterval: Cardinal;
    //存活间隔
    FCounter: TPMRunCounter;
    //运行计数
    FMonThread: TThread;
    //监控线程
    FShareMem: TShareMemoryManager;
    //内存管理
  protected
    procedure WriteLog(const nLog: string);
    //记录日志
    procedure InitSharedMemory(const nSize: Integer);
    //初始化
    function SetCellIndexByID(const nProgID: string): Boolean;
    //枚举索引
    function DoWriteClientData(const nData: Pointer): Boolean; virtual;
    //客户数据
    function GetMonStatus: Boolean;
    //检控状态
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    function AddProcess(const nProgID,nProgPath: string;
      var nHint: string; const nInit: TPMStatus = psClosed): Boolean;
    function DelProcess(const nProgID: string): Boolean;
    //增删程序
    function UpdateHandle(const nHandleForm,nHandleProg: THandle;
      var nHint: string): Boolean;
    //更新句柄
    function StartMonitor(var nHint: string; nInterval: Integer = -1): Boolean;
    procedure StopMonitor(const nCloseFlag: Boolean = False);
    //起停服务
    property IsBusy: Boolean read GetMonStatus;
    property Counter: TPMRunCounter read FCounter;
    property ShareMem: TShareMemoryManager read FShareMem;
    //属性相关
  end;

  TProcessMonitorServer = class(TProcessMonitorBase)
  public
    constructor Create(const nMemName,nEventName: string);
    //创建对象
  end;

  TProcessMonitorClient = class(TProcessMonitorBase)
  public
    constructor Create(const nProgID: string; nMemName: string = '';
      nEventName: string = '');
    //创建对象
  end;

  TProcessMonitorSapMITServer = class(TProcessMonitorBase)
  public
    constructor Create;
    //创建对象
  end;

  TProcessMonitorSapMITClient = class(TProcessMonitorBase)
  protected
    FLastUpdate: Cardinal;
    //上次更新
    function DoWriteClientData(const nData: Pointer): Boolean; override;
  public
    constructor Create(const nProgID: string);
    //创建对象
  end;

var
  gProcessMonitorServer: TProcessMonitorServer = nil;
  gProcessMonitorClient: TProcessMonitorClient = nil;

  gProcessMonitorSapMITServer: TProcessMonitorSapMITServer = nil;
  gProcessMonitorSapMITClient: TProcessMonitorSapMITClient = nil;
  //全局使用

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
  sDescServer           = '进程守护服务端';
  sDescClient           = '进程守护客户端';

  sErr_InvalidParam     = '执行函数[ %s ]时参数无效.';
  sErr_NoInitWhenStart  = '启动进程守护,但内存还未初始化.';
  sErr_FileNotExists    = '待添加到守护队列的程序文件不存在.';
  sErr_NoInitWhenAdd    = '添加待守护进程,但内存还未初始化.';
  sErr_NoMemoryWhenAdd  = '添加待守护进程,但内存已被完全占用.';
  sErr_InitMemFailure   = '初始化共享内存失败.';
  sErr_InvalidProgID    = '待守护进程标识号无效.';

  sMon_TrySafeClose     = '尝试安全关闭[ %s ]进程.';
  sMon_TryFoceClose     = '尝试强制关闭[ %s ]进程.';
  sMon_TryExecProg      = '尝试第[ %d ]次启动[ %s ]进程.';

//------------------------------------------------------------------------------
type
  TMonThread = class(TThread)
  private
    FOwner: TProcessMonitorBase;
    //拥有者
    FWaiter: TWaitObject;
    //等待对象
  protected
    procedure Execute; override;
    function DoServerExecute: Boolean;
    function DoClientExecute: Boolean;
    //线程体
  public
    constructor Create(AOwner: TProcessMonitorBase);
    destructor Destroy; override;
    //创建释放
    procedure StopMe;
    //停止线程
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

//Desc: 停止线程
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

//Desc: 进程守护客户
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

//Desc: 守护客户端写自定义数据,若返回True则执行默认操作
function TProcessMonitorBase.DoWriteClientData(const nData: Pointer): Boolean;
begin
  Result := True;
end;

//Desc: 进程守护服务
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
        //上次更新时间未超过FKeepInterval个FUpdateInterval

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
          //等待WM_Close足够长时间

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
//Parm: 日志
//Desc: 记录检控日志
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
//Parm: 错误提示;守护更新间隔(ms)
//Desc: 启动守护
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

//Desc: 停止守护
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

//Desc: 获取监控状态
function TProcessMonitorBase.GetMonStatus: Boolean;
begin
  Result := Assigned(FMonThread);
end;

//Date: 2012-2-22
//Parm: 程序标识;程序路径;提示信息;默认状态
//Desc: 添加一个标识为nProgID,路径为nProgPath的程序到守护队列
function TProcessMonitorBase.AddProcess(const nProgID,
  nProgPath: string; var nHint: string; const nInit: TPMStatus): Boolean;
var nP: Pointer;
    nIdx: Integer;

    //Desc: 更新数据
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
//Parm: 安全句柄;强制句柄;错误提示
//Desc: 更新客户端句柄(Client调用)
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
//Parm: 程序标识
//Desc: 将标识为nProgID的程序移出守护队列
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
//Parm: 单元大小
//Desc: 初始化守护客户端的内存
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
//Parm: 程序标识
//Desc: 根据nProgID设置单元索引
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
//Desc: 标准守护服务
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

//Desc: 标准客户端
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

//Desc: SAP-MIT守护服务
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

//Desc: SAP-MIT客户端
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
//Parm: 数据指针
//Desc: 更新共享内存中的SAP连接池信息
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
