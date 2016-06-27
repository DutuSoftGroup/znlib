{*******************************************************************************
  作者: dmzn@163.com 2014-05-22
  描述: 监控任务的执行状态
*******************************************************************************}
unit UTaskMonitor;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, USysLoger, UWaitItem;

const
  cTaskTimeoutLong  = 5 * 1000;  //长超时
  cTaskTimeoutShort = 500;       //短超时

type
  PTaskItem = ^TTaskItem;
  TTaskItem = record
    FTaskID: Int64;              //任务标识
    FDesc: string;               //任务描述
    FStart: Int64;               //开始时间
    FTimeOut: Int64;             //超时时间
    FIsFree: Boolean;            //空闲任务
  end;

  TTaskMonitor = class;
  TMonitorThread = class(TThread)
  private
    FOwner: TTaskMonitor;
    //拥有者
    FWaiter: TWaitObject;
    //等待对象
  protected
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TTaskMonitor);
    destructor Destroy; override;
    //创建释放
    procedure StopMe;
    //停止线程
  end;

  TTaskMonitor = class(TObject)
  private
    FIDBase: Int64;
    //标识编号
    FTasks: TList;
    //任务列表
    FMonitor: TMonitorThread;
    //监视线程
    FSyncLock: TCriticalSection;
    //同步锁定
  protected
    procedure ClearTask(const nFree: Boolean);
    //清理资源
    function GetTask(const nTaskID: Int64 = 0): PTaskItem;
    //检索任务
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    function AddTask(const nDesc: string;
      const nTimeout: Int64 = cTaskTimeoutShort): Int64;
    procedure DelTask(const nTaskID: Int64; const nLog: Boolean = False);
    //添加删除
    procedure StartMon;
    procedure StopMon;
    //起停服务
  end;

var
  gTaskMonitor: TTaskMonitor = nil;
  //全局使用
  
implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TTaskMonitor, '任务监控服务', nEvent);
end;

constructor TMonitorThread.Create(AOwner: TTaskMonitor);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 100;
end;

destructor TMonitorThread.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TMonitorThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;
  
  WaitFor;
  Free;
end;

procedure TMonitorThread.Execute;
var nIdx: Integer;
    nInt: Int64;
    nTask: PTaskItem;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    with FOwner do
    try
      FSyncLock.Enter;
      //lock task list

      for nIdx:=FTasks.Count - 1 downto 0 do
      begin
        nTask := FTasks[nIdx];
        if nTask.FIsFree then continue;
        //free task

        if nTask.FStart = 0 then
        begin
          nTask.FStart := GetTickCount;
          continue;
        end;

        nInt := GetTickCount - nTask.FStart;
        if nInt > nTask.FTimeOut then
        begin
          WriteLog(Format('任务超时,耗时: %d,描述: %s', [nInt, nTask.FDesc]));
          nTask.FIsFree := True;
        end;
      end;
    finally
      FSyncLock.Leave;
    end;
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
    end;
  end;   
end;

//------------------------------------------------------------------------------
constructor TTaskMonitor.Create;
begin
  FIDBase := 0;
  FTasks := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TTaskMonitor.Destroy;
begin
  StopMon;
  ClearTask(True);

  FSyncLock.Free;
  inherited;
end;

procedure TTaskMonitor.ClearTask(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FTasks.Count - 1 downto 0 do
  begin
    Dispose(PTaskItem(FTasks[nIdx]));
    FTasks.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FTasks);
  //xxxxx
end;

//Date: 2014-05-22
//Parm: 任务标识
//Desc: 检索标识为nTaskID的任务,为0时为空闲任务
function TTaskMonitor.GetTask(const nTaskID: Int64): PTaskItem;
var nIdx,nLen: Integer;
begin
  Result := nil;
  nLen := FTasks.Count - 1;

  for nIdx:=0 to nLen do
  begin
    Result := FTasks[nIdx];
    if (Result.FTaskID = nTaskID) or ((nTaskID = 0) and Result.FIsFree) then
         Exit
    else Result := nil;
  end;
end;

//Date: 2014-05-22
//Parm: 任务描述;超时时长
//Desc: 添加一个监视任务,在nTimeout没有完成时打印日志
function TTaskMonitor.AddTask(const nDesc: string; const nTimeout: Int64): Int64;
var nTask: PTaskItem;
begin
  FSyncLock.Enter;
  try
    Inc(FIDBase);
    Result := FIDBase;
    nTask := GetTask;
    
    if not Assigned(nTask) then
    begin
      New(nTask);
      nTask.FIsFree := False;
      FTasks.Add(nTask);
    end;

    with nTask^ do
    begin
      FTaskID := Result;
      FDesc := nDesc;

      FStart := 0;
      FTimeOut := nTimeout;
      FIsFree := False;
    end;
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2014-05-22
//Parm: 任务标识;记录日志
//Desc: 删除标识为nTaskID的任务
procedure TTaskMonitor.DelTask(const nTaskID: Int64; const nLog: Boolean);
var nTask: PTaskItem;
begin
  FSyncLock.Enter;
  try
    nTask := GetTask(nTaskID);
    if not Assigned(nTask) then Exit;

    if nLog and (not nTask.FIsFree) and (nTask.FStart > 0) then
      WriteLog(Format('耗时:%d,任务:%s', [GetTickCount - nTask.FStart, nTask.FDesc]));
    nTask.FIsFree := True;
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2014-05-22
//Desc: 启动监控
procedure TTaskMonitor.StartMon;
begin
  if not Assigned(FMonitor) then
    FMonitor := TMonitorThread.Create(Self);
  //xxxxx
end;

//Date: 2014-05-22
//Desc: 停止监控
procedure TTaskMonitor.StopMon;
begin
  if Assigned(FMonitor) then
    FMonitor.StopMe;
  FMonitor := nil;
end;

initialization
  gTaskMonitor := nil;
finalization
  FreeAndNil(gTaskMonitor);
end.
