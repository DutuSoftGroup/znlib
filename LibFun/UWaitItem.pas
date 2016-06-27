{*******************************************************************************
  ����: dmzn@163.com 2007-11-23
  ����: ʵ�ֵȴ�����͸����ܵȴ�������

  ����:
  &.TWaitObject��EnterWait���������,ֱ��Wakeup����.
  &.�ö�����̰߳�ȫ,��A�߳�EnterWait,B�߳�Wakeup.
  &.TWaitTimerʵ��΢�뼶�������.
*******************************************************************************}
unit UWaitItem;

interface

uses
  Windows, Classes, SysUtils;

type
  TWaitObject = class(TObject)
  private
    FEvent: THandle;
    {*�ȴ��¼�*}
    FInterval: Cardinal;
    {*�ȴ����*}
    FStatus: Integer;
    {*�ȴ�״̬*}
    FWaitResult: Cardinal;
    {*�ȴ����*}
  public
    constructor Create;
    destructor Destroy; override;
    {*�����ͷ�*}
    function EnterWait: Cardinal;
    procedure Wakeup(const nForce: Boolean = False);
    {*�ȴ�.����*}
    function IsWaiting: Boolean;
    function IsTimeout: Boolean;
    function IsWakeup: Boolean;
    {*�ȴ�״̬*}
    property WaitResult: Cardinal read FWaitResult;
    property Interval: Cardinal read FInterval write FInterval;
  end;

  TCrossProcWaitObject = class(TObject)
  private
    FEvent: THandle;
    {*ͬ���¼�*}
    FLockStatus: Boolean;
    {*����״̬*}
  public
    constructor Create(const nEventName: PChar);
    destructor Destroy; override;
    {*�����ͷ�*}
    function SyncLockEnter(const nWaitFor: Boolean = False): Boolean;
    procedure SyncLockLeave(const nOnlyMe: Boolean = True);
    {*ͬ������*}
  end;

  TWaitTimer = class(TObject)
  private
    FFrequency: Int64;
    {*CPUƵ��*}
    FFlagFirst: Int64;
    {*��ʼ���*}
    FTimeResult: Int64;
    {*��ʱ���*}
  public
    constructor Create;
    procedure StartTime;
    {*��ʼ��ʱ*}
    function EndTime: Int64;
    {*������ʱ*}
    property TimeResult: Int64 read FTimeResult;
    {*�������*}
  end;

procedure StartHighResolutionTimer;
//��ʼ����
function GetHighResolutionTimerResult: Int64;
//��ȡ΢��������

implementation

const
  cIsIdle    = $02;
  cIsWaiting = $27;

constructor TWaitObject.Create;
begin
  inherited Create;
  FStatus := cIsIdle;

  FInterval := INFINITE;
  FEvent := CreateEvent(nil, False, False, nil);

  if FEvent = 0 then
    raise Exception.Create('Create TCrossProcWaitObject.FEvent Failure');
  //xxxxx
end;

destructor TWaitObject.Destroy;
begin
  if FEvent > 0 then
    CloseHandle(FEvent);
  inherited;
end;

function TWaitObject.IsWaiting: Boolean;
begin
  Result := FStatus = cIsWaiting;
end;

function TWaitObject.IsTimeout: Boolean;
begin
  if IsWaiting then
       Result := False
  else Result := FWaitResult = WAIT_TIMEOUT;
end;

function TWaitObject.IsWakeup: Boolean;
begin
  if IsWaiting then
       Result := False
  else Result := FWaitResult = WAIT_OBJECT_0;
end;

function TWaitObject.EnterWait: Cardinal;
begin
  InterlockedExchange(FStatus, cIsWaiting);
  Result := WaitForSingleObject(FEvent, FInterval);

  FWaitResult := Result;
  InterlockedExchange(FStatus, cIsIdle);
end;

procedure TWaitObject.Wakeup(const nForce: Boolean);
begin
  if (FStatus = cIsWaiting) or nForce then
    SetEvent(FEvent);
  //xxxxx
end;

//------------------------------------------------------------------------------
constructor TCrossProcWaitObject.Create(const nEventName: PChar);
var nStr: string;
begin
  if nEventName = nil then
    raise Exception.Create('TCrossProcWaitObject must have event name.');
  //xxxxx

  inherited Create;
  FLockStatus := False;
  FEvent := CreateEvent(nil, False, True, nEventName);

  if FEvent = 0 then
  begin
    nStr := 'Create TCrossProcWaitObject.FSyncEvent Failure.';
    if GetLastError = ERROR_INVALID_HANDLE then
    begin
      nStr := nStr + #13#10#13#10 +
              'The name of an existing semaphore,mutex,or file-mapping object.';
      //xxxxx
    end;

    raise Exception.Create(nStr);
  end;
end;

destructor TCrossProcWaitObject.Destroy;
begin
  SyncLockLeave(True);
  //unlock
  
  if FEvent > 0 then
    CloseHandle(FEvent);
  inherited;
end;

//Date: 2013-5-23
//Parm: �ȴ��ź�
//Desc: ����ͬ���ź���,�����ɹ�����True
function TCrossProcWaitObject.SyncLockEnter(const nWaitFor: Boolean): Boolean;
begin
  if nWaitFor then
       Result := WaitForSingleObject(FEvent, INFINITE) = WAIT_OBJECT_0
  else Result := WaitForSingleObject(FEvent, 0) = WAIT_OBJECT_0;
  {*
    a.FEvent��ʼ״̬ΪTrue.
    b.�״�WaitFor����WAIT_OBJECT_0,�����ɹ�.
    c.FEvent��λ��ʽΪFalse,WaitFor���óɹ����Զ���Ϊ"���ź�".
    d.����WaitFor���᷵��WAIT_TIMEOUT,����ʧ��.
    e.LockRelease��,����.
  *}

  FLockStatus := Result;
  {*�Ƿ񱾶�������*}
end;

//Date: 2013-5-23
//Parm: ֻ���������������ź�
//Desc: ����ͬ���ź�
procedure TCrossProcWaitObject.SyncLockLeave(const nOnlyMe: Boolean);
begin
  if (not nOnlyMe) or FLockStatus then
    SetEvent(FEvent);
  //set event signal
end;

//------------------------------------------------------------------------------
constructor TWaitTimer.Create;
begin
  FTimeResult := 0;
  if not QueryPerformanceFrequency(FFrequency) then
    raise Exception.Create('not support high-resolution performance counter');
  //xxxxx
end;

procedure TWaitTimer.StartTime;
begin
  QueryPerformanceCounter(FFlagFirst);
end;

function TWaitTimer.EndTime: Int64;
var nNow: Int64;
begin
  QueryPerformanceCounter(nNow);
  Result := Trunc((nNow - FFlagFirst) / FFrequency * 1000 * 1000);
  FTimeResult := Result;
end;

//------------------------------------------------------------------------------
var
  gTimer: TWaitTimer = nil;
  //�����ܼ�����

//Desc: ��ʼһ������
procedure StartHighResolutionTimer;
begin
  if not Assigned(gTimer) then
    gTimer := TWaitTimer.Create;
  gTimer.StartTime;
end;

//Desc: ���ؼ������
function GetHighResolutionTimerResult: Int64;
begin
  if Assigned(gTimer) then
       Result := gTimer.EndTime
  else Result := 0;
end;

initialization

finalization
  FreeAndNil(gTimer);
end.
