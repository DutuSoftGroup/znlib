{*******************************************************************************
  作者: dmzn dmzn@163.com 2006-02-10
  描述: 使窗体在桌面边沿停靠的组件,类似QQ自动隐藏的样式

  更新:
  &.2006-02-24
  添加AlwaysTop属性,使主窗体可以保持在最顶端.
  &.2006-02-27
  修改SetAlwaysTop过程,原有SWP_SHOWWINDOW改为SWP_NOACTIVATE,解决了非主窗体时
  窗口无法关闭的问题.
  &.2006-03-03
  解决在IsMouseLeave函数中误判鼠标离开窗体的问题.
  &.2010-08-09
  修改鼠标移出窗体时延迟隐藏,看起来不那么生硬.

  声明: 本单元公开源码,个人/商业可免费使用,不过请保留此处的说明文字.如果你
  对本单元作了合理修改,请邮件通知我,谢谢!
*******************************************************************************}
unit ZnHideForm;

interface

uses
  Classes, Controls, ExtCtrls, Forms, Windows, Messages, SysUtils;

type
  TDockPos = (dpNone, dpTop, dpLeft, dpRight);
  TDockEvent = procedure (const nDockPos: TDockPos) of Object;

  TZnHideForm = class(TComponent)
  private
    { Private declarations }
    FWnd: Hwnd;
    FIdle: Cardinal;

    FIsHide: boolean;
    FDockPos: TDockPos;
    FAlwaysTop: boolean;

    FAutoDock: boolean;
    FEdgeSpace: integer;
    FValidSpace: integer;

    FMainForm: TForm;
    FFormRect: TRect;
    FFormProc: TWndMethod;

    FDockEvent: TDockEvent;
    FHideEvent: TDockEvent;
    FShowEvent: TDockEvent;
  protected
    { Protected declarations }
    function FindMainForm: TForm;
    procedure WndProc(var nMsg: TMessage);
    function GetVisible: Boolean;

    procedure CaptureMsg(var Message: TMessage);
    procedure DockFormToEdge(const nRect: PRect);

    procedure SetAutoDock(const nValue: boolean);
    procedure SetAlwaysTop(const nValue: boolean);
    
    procedure SetEdgeSpace(const nSpace: integer);
    procedure SetValidSpace(const nSpace: integer);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;

    procedure SetFormShow;
    procedure SetFormHide;
    function IsMouseLeave: boolean;
  published
    { Published declarations }
    property Visible: Boolean read GetVisible;
    property DockPos: TDockPos read FDockPos;
    property AutoDock: Boolean read FAutoDock write SetAutoDock;
    property AlwaysTop: Boolean read FAlwaysTop write SetAlwaysTop;

    property EdgeSpace: integer read FEdgeSpace write SetEdgeSpace;
    property ValidSpace: integer read FValidSpace write SetValidSpace;

    property DockEvent: TDockEvent read FDockEvent write FDockEvent;
    property OnHideForm: TDockEvent read FHideEvent write FHideEvent;
    property OnShowForm: TDockEvent read FShowEvent write FShowEvent; 
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RunSoft',[TZnHideForm]);
end;

{****************************  TZnHideForm  ****************************}
constructor TZnHideForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMainForm := FindMainForm;
  if not Assigned(FMainForm) then raise Exception.Create('未找到主窗体');

  FIdle := 0;
  FEdgeSpace := 3;
  FValidSpace := 10;
 
  FDockPos := dpNone;  
  FAutoDock := False;
end;

destructor TZnHideForm.Destroy;
begin
  SetAutoDock(False);
  inherited Destroy;
end;

//Desc: 搜索主窗体
function TZnHideForm.FindMainForm: TForm;
var nComponent: TComponent;
begin
  Result := nil;
  nComponent := Self.Owner;

  while Assigned(nComponent) do
  begin
     if (nComponent is TForm) then
     begin
        Result := nComponent as TForm;
        Break;
     end;
     nComponent := nComponent.GetParentComponent;
  end;
end;

//Desc: 开启/关闭Dock
procedure TZnHideForm.SetAutoDock(const nValue: boolean);
begin
  if not (csDesigning in ComponentState) and (FAutoDock <> nValue) then
  begin
     if nValue then
     begin
        FFormRect := FMainForm.BoundsRect;
        FFormProc := FMainForm.WindowProc;
        FMainForm.WindowProc := CaptureMsg;

        FWnd := Classes.AllocateHWnd(WndProc);
        SetTimer(FWnd, 1, 285, nil);
     end else
     begin
        if FWnd > 0 then
        begin
           KillTimer(FWnd, 1);
           Classes.DeallocateHWnd(FWnd);
        end;

        if Assigned(FMainForm) and
           Assigned(FFormProc) then FMainForm.WindowProc := FFormProc;

        FFormProc := nil;
        FWnd := 0; FIdle := 0; FDockPos := dpNone;
      end;
  end;
  FAutoDock := nValue;
end;

//Desc: 保持Z轴最顶端位置,屏蔽"显示桌面".
procedure TZnHideForm.SetAlwaysTop(const nValue: boolean);
begin
  if not (csDesigning in Self.ComponentState) and (FAlwaysTop <> nValue) then
  begin
     if nValue then
     begin
        SetWindowPos( FMainForm.Handle, HWND_TOPMOST,
                      0,0,0,0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

        ShowWindow( Application.Handle, SW_Hide);
        SetWindowLong(Application.Handle,GWL_EXSTYLE,
         GetWindowLong(Application.Handle,GWL_EXSTYLE)
          and (not WS_EX_APPWINDOW) or WS_EX_TOOLWINDOW);
     end else
     begin
        SetWindowPos( FMainForm.Handle, HWND_NOTOPMOST,
                      0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

        SetWindowLong(Application.Handle,GWL_EXSTYLE,
         GetWindowLong(Application.Handle,GWL_EXSTYLE)
          and (not WS_EX_TOOLWINDOW) or WS_EX_APPWINDOW);
        ShowWindow( Application.Handle, SW_Show);
     end;
  end;
  FAlwaysTop := nValue;
end;

//Desc: 计数器在查数,^_^
procedure TZnHideForm.WndProc(var nMsg: TMessage);
begin
  with nMsg do
  begin
     if Msg = WM_TIMER then
     begin
       Inc(FIdle);
       if FIdle = 3 then SetFormHide;
       //鼠标移开延迟
     end else Result := DefWindowProc(FWnd, Msg, wParam, lParam);
  end;
end;

//Name: DockFormToEdge
//Parm: nRect,窗体当前所在区域
//Desc: 依据nRect判断窗口是否需要Dock到边沿
procedure TZnHideForm.DockFormToEdge(const nRect: PRect);
begin
  if (nRect.Top < FValidSpace) and (nRect.Top <= FFormRect.Top) then
  //Top
  begin
     nRect.Bottom := nRect.Bottom - nRect.Top;
     nRect.Top := 0;
  end else

  if (nRect.Left < FValidSpace) and (nRect.Left <= FFormRect.Left) then
  //Left
  begin
     nRect.Right := nRect.Right - nRect.Left;
     nRect.Left := 0;
  end else

  if (Screen.Width - nRect.Right < FValidSpace) and (nRect.Left >= FFormRect.Left) then
  //Right
  begin
     nRect.Left := Screen.Width - (nRect.Right - nRect.Left);
     nRect.Right := Screen.Width;
  end;

  if nRect.Top = 0 then
     FDockPos := dpTop else
  if nRect.Left = 0 then
     FDockPos := dpLeft else
  if nRect.Right = Screen.Width then
     FDockPos := dpRight else FDockPos := dpNone;

  FFormRect := nRect^; //Save MainForm Rects
  if (FDockPos <> dpNone) and Assigned(FDockEvent) then FDockEvent(FDockPos);
end;

//Desc: 判断鼠标是否离开主窗体
function TZnHideForm.IsMouseLeave: boolean;
var nPt: TPoint;
begin
  GetCursorPos(nPt);
  GetWindowRect(FMainForm.Handle, FFormRect);

  if PtInRect(FFormRect, nPt) then
       Result := False
  else Result := True;
end;

function TZnHideForm.GetVisible: Boolean;
begin
  Result := not FIsHide;
end;

procedure TZnHideForm.SetFormHide;
begin
  if IsMouseLeave then
  begin
     FIsHide := True;
     if Assigned(FHideEvent) then
     begin
        FHideEvent(FDockPos); Exit;
     end;

     if FDockPos = dpTop then
        FMainForm.Top := -FMainForm.Height + FEdgeSpace else
     if FDockPos = dpLeft then
        FMainForm.Left := -FMainForm.Width + FEdgeSpace else
     if FDockPos = dpRight then
        FMainForm.Left := Screen.Width - FEdgeSpace;
  end;
end;

procedure TZnHideForm.SetFormShow;
begin
  FIsHide := False;
  if Assigned(FShowEvent) then
  begin
     FShowEvent(FDockPos); Exit;
  end;

  if FDockPos = dpTop then
     FMainForm.Top := 0 else
  if FDockPos = dpLeft then
     FMainForm.Left := 0 else
  if FDockPos = dpRight then
     FMainForm.Left := Screen.Width - FMainForm.Width;
end;

procedure TZnHideForm.SetEdgeSpace(const nSpace: integer);
begin
  if (nSpace > 0) and (nSpace < 51) then
       FEdgeSpace := nSpace
  else raise Exception.Create('请填写1-50以内的数字'); 
end;

procedure TZnHideForm.SetValidSpace(const nSpace: integer);
begin
  if (nSpace > 4) and (nSpace < 51) then
       FValidSpace := nSpace
  else raise Exception.Create('请填写5-50以内的数字'); 
end;

procedure TZnHideForm.CaptureMsg(var Message: TMessage);
begin
  if Assigned(FFormProc) then FFormProc(Message);
  
  if FAutoDock then
  case Message.Msg of
    CM_MOUSEENTER : if FIsHide then SetFormShow;
    CM_MOUSELEAVE : if FDockPos <> dpNone then FIdle := 0;
    WM_MOVING     : DockFormToEdge(PRect(Message.lParam));
  end;
end;

end.
