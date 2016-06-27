{*******************************************************************************
  作者: dmzn 2008-10-11
  描述: 动作延迟执行管理器

  备注:
  &.该对象以某个精度循环探测,直到延迟间隔(N个精度)后,执行延迟事件
  &.在延迟间隔内,每有一个新的延迟请求,会将计数器置零.
*******************************************************************************}
unit UMgrDelay;

interface

uses
  Windows, Classes;

type
  TDelayManager = class;

  TDelayThread = class(TThread)
  private
    FOwner: TDelayManager;
    {*拥有者*}
    FEvent: THandle;
    {*等待事件*}
  protected
    procedure Execute; override;
    procedure DoDelayEvent;
    {*延迟动作*}
  public
    constructor Create(AOwner: TDelayManager);
    destructor Destroy; override;
    {*创建释放*}
    procedure NewDelay;
    {*执行延迟*}
    procedure CloseThread;
    {*关闭线程*}
  end;

  TDelayEvent = procedure of Object;
  TDelayProcedure = procedure;

  TDelayManager = class(TObject)
  private
    FPricision: integer;
    {*探测精度*}
    FNumber: integer;
    {*探测次数*}
    FThread: TDelayThread;
    {*延迟线程*}
    FDelayEvent: TDelayEvent;
    FDelayProc: TDelayProcedure;
    {*延迟动作*}
  public
    constructor Create;
    destructor Destroy; override;
    {*创建释放*}
    procedure NewDelay;
    {*新延迟*}
    property DelayEvent: TDelayEvent read FDelayEvent write FDelayEvent;
    property DelayProcedure: TDelayProcedure read FDelayProc write FDelayProc;
  end;

implementation

constructor TDelayThread.Create(AOwner: TDelayManager);
begin
  inherited Create(False);
  FOwner := AOwner;
  FEvent := CreateEvent(nil, False, False, nil);
end;

destructor TDelayThread.Destroy;
begin
  CloseHandle(FEvent);
  inherited;
end;

//Desc: 关闭线程
procedure TDelayThread.CloseThread;
begin
  Terminate;
  SetEvent(FEvent);
  WaitFor;
  Free;
end;

//Desc: 延迟动作
procedure TDelayThread.DoDelayEvent;
begin
  if Assigned(FOwner.FDelayEvent) then FOwner.FDelayEvent;
  if Assigned(FOwner.FDelayProc) then FOwner.FDelayProc;
end;

//Desc: 新延迟
procedure TDelayThread.NewDelay;
begin
  SetEvent(FEvent);
end;

procedure TDelayThread.Execute;
var nNum: integer;
    nDelay: Boolean;
begin
  nNum := 0;
  nDelay := False;

  while not Terminated do
  begin
    if WaitForSingleObject(FEvent, FOwner.FPricision) <> Wait_TimeOut then
    begin
      nDelay := True; nNum := 0;
    end else Inc(nNum);

    if nDelay and (nNum >=FOwner.FNumber) and (not Terminated) then
    begin
      nNum := 0;
      nDelay := False;
      Synchronize(DoDelayEvent);
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TDelayManager.Create;
begin
  FPricision := 112;
  FNumber := 6;
  FThread := TDelayThread.Create(Self);
end;

destructor TDelayManager.Destroy;
begin
  FThread.CloseThread;
  inherited;
end;

//Desc: 新建延迟
procedure TDelayManager.NewDelay;
begin
  FThread.NewDelay;
end;

end.
