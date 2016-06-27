{*******************************************************************************
  ����: dmzn@163.com 2014-05-22
  ����: ��������ִ��״̬
*******************************************************************************}
unit UTaskMonitor;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, USysLoger, UWaitItem;

const
  cTaskTimeoutLong  = 5 * 1000;  //����ʱ
  cTaskTimeoutShort = 500;       //�̳�ʱ

type
  PTaskItem = ^TTaskItem;
  TTaskItem = record
    FTaskID: Int64;              //�����ʶ
    FDesc: string;               //��������
    FStart: Int64;               //��ʼʱ��
    FTimeOut: Int64;             //��ʱʱ��
    FIsFree: Boolean;            //��������
  end;

  TTaskMonitor = class;
  TMonitorThread = class(TThread)
  private
    FOwner: TTaskMonitor;
    //ӵ����
    FWaiter: TWaitObject;
    //�ȴ�����
  protected
    procedure Execute; override;
    //ִ���߳�
  public
    constructor Create(AOwner: TTaskMonitor);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TTaskMonitor = class(TObject)
  private
    FIDBase: Int64;
    //��ʶ���
    FTasks: TList;
    //�����б�
    FMonitor: TMonitorThread;
    //�����߳�
    FSyncLock: TCriticalSection;
    //ͬ������
  protected
    procedure ClearTask(const nFree: Boolean);
    //������Դ
    function GetTask(const nTaskID: Int64 = 0): PTaskItem;
    //��������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    function AddTask(const nDesc: string;
      const nTimeout: Int64 = cTaskTimeoutShort): Int64;
    procedure DelTask(const nTaskID: Int64; const nLog: Boolean = False);
    //���ɾ��
    procedure StartMon;
    procedure StopMon;
    //��ͣ����
  end;

var
  gTaskMonitor: TTaskMonitor = nil;
  //ȫ��ʹ��
  
implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TTaskMonitor, '�����ط���', nEvent);
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
          WriteLog(Format('����ʱ,��ʱ: %d,����: %s', [nInt, nTask.FDesc]));
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
//Parm: �����ʶ
//Desc: ������ʶΪnTaskID������,Ϊ0ʱΪ��������
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
//Parm: ��������;��ʱʱ��
//Desc: ���һ����������,��nTimeoutû�����ʱ��ӡ��־
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
//Parm: �����ʶ;��¼��־
//Desc: ɾ����ʶΪnTaskID������
procedure TTaskMonitor.DelTask(const nTaskID: Int64; const nLog: Boolean);
var nTask: PTaskItem;
begin
  FSyncLock.Enter;
  try
    nTask := GetTask(nTaskID);
    if not Assigned(nTask) then Exit;

    if nLog and (not nTask.FIsFree) and (nTask.FStart > 0) then
      WriteLog(Format('��ʱ:%d,����:%s', [GetTickCount - nTask.FStart, nTask.FDesc]));
    nTask.FIsFree := True;
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2014-05-22
//Desc: �������
procedure TTaskMonitor.StartMon;
begin
  if not Assigned(FMonitor) then
    FMonitor := TMonitorThread.Create(Self);
  //xxxxx
end;

//Date: 2014-05-22
//Desc: ֹͣ���
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
