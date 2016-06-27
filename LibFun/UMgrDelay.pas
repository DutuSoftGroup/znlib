{*******************************************************************************
  ����: dmzn 2008-10-11
  ����: �����ӳ�ִ�й�����

  ��ע:
  &.�ö�����ĳ������ѭ��̽��,ֱ���ӳټ��(N������)��,ִ���ӳ��¼�
  &.���ӳټ����,ÿ��һ���µ��ӳ�����,�Ὣ����������.
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
    {*ӵ����*}
    FEvent: THandle;
    {*�ȴ��¼�*}
  protected
    procedure Execute; override;
    procedure DoDelayEvent;
    {*�ӳٶ���*}
  public
    constructor Create(AOwner: TDelayManager);
    destructor Destroy; override;
    {*�����ͷ�*}
    procedure NewDelay;
    {*ִ���ӳ�*}
    procedure CloseThread;
    {*�ر��߳�*}
  end;

  TDelayEvent = procedure of Object;
  TDelayProcedure = procedure;

  TDelayManager = class(TObject)
  private
    FPricision: integer;
    {*̽�⾫��*}
    FNumber: integer;
    {*̽�����*}
    FThread: TDelayThread;
    {*�ӳ��߳�*}
    FDelayEvent: TDelayEvent;
    FDelayProc: TDelayProcedure;
    {*�ӳٶ���*}
  public
    constructor Create;
    destructor Destroy; override;
    {*�����ͷ�*}
    procedure NewDelay;
    {*���ӳ�*}
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

//Desc: �ر��߳�
procedure TDelayThread.CloseThread;
begin
  Terminate;
  SetEvent(FEvent);
  WaitFor;
  Free;
end;

//Desc: �ӳٶ���
procedure TDelayThread.DoDelayEvent;
begin
  if Assigned(FOwner.FDelayEvent) then FOwner.FDelayEvent;
  if Assigned(FOwner.FDelayProc) then FOwner.FDelayProc;
end;

//Desc: ���ӳ�
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

//Desc: �½��ӳ�
procedure TDelayManager.NewDelay;
begin
  FThread.NewDelay;
end;

end.
