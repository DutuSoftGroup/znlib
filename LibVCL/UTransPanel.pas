{*******************************************************************************
  作者: dmzn@163.com 2009-6-30
  描述: 透明控件
*******************************************************************************}
unit UTransPanel;

interface

uses
  Windows, Classes, Controls, SysUtils, Graphics, Messages;

const
  WM_ParentInvalid = WM_User + $0101;

type
  TZnTransPanel = class(TCustomControl)
  private
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CreateWnd; override;
    procedure CreateParams(var nParams: TCreateParams); override;
    procedure WMEraseBkgnd(var nMessage: TMessage); message WM_ERASEBKGND;
    procedure WMParentInvalid(var nMessage: TMessage); message WM_ParentInvalid;
  public
    InvalidRect: TRect;
    //无效区域
    procedure InvalidPanel;
    //更新无效区域
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property BorderWidth;
    property Ctl3D;
    property Enabled;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RunSoft', [TZnTransPanel]);
end;

procedure TZnTransPanel.CreateParams(var nParams: TCreateParams);
begin
  InvalidRect := Rect(0, 0, 0, 0);
  inherited CreateParams(nParams);

  if not (csDesigning in ComponentState) then
  with nParams do
  begin
    ControlStyle := ControlStyle - [csOpaque];
    Style := Style and not WS_CLIPCHILDREN;
    Style := Style and not WS_CLIPSIBLINGS;
    ExStyle := ExStyle + WS_EX_Transparent;
  end;

  ControlStyle := ControlStyle + [csAcceptsControls];
end;

procedure TZnTransPanel.CreateWnd;
begin
  inherited;
  if not (csDesigning in ComponentState) and
     Assigned(Parent) and Parent.HandleAllocated then
  begin
    SetWindowLong(Parent.Handle, GWL_STYLE,
    GetWindowLong(Parent.Handle, GWL_STYLE) and not WS_CLIPCHILDREN);
  end;
end;

//Desc: 更新面板
procedure TZnTransPanel.InvalidPanel;
var nRect: PRect;
begin
  New(nRect);
  if InvalidRect.Left = InvalidRect.Right then
  begin
    nRect.TopLeft := ClientToScreen(ClientRect.TopLeft);
    nRect.BottomRight := ClientToScreen(ClientRect.BottomRight);
  end else
  begin
    nRect.TopLeft := ClientToScreen(InvalidRect.TopLeft);
    nRect.BottomRight := ClientToScreen(InvalidRect.BottomRight);
  end;

  PostMessage(Handle, WM_ParentInvalid, Integer(nRect), 0);
  InvalidRect := Rect(0, 0, 0, 0);
end;

//Desc: 擦出背景
procedure TZnTransPanel.WMEraseBkgnd(var nMessage: TMessage);
begin
  if csDesigning in ComponentState then
       inherited
  else nMessage.Msg := 1;
end;

//Desc: 强制父窗体绘制
procedure TZnTransPanel.WMParentInvalid(var nMessage: TMessage);
var nRect: TRect;
begin
  if Assigned(Parent) and (not (csDesigning in ComponentState)) then
  begin
    if Parent is TZnTransPanel then
    begin
      PostMessage(Parent.Handle, WM_ParentInvalid, nMessage.WParam, 0);
    end else
    begin
      if nMessage.WParam > 0 then
      begin
        nRect := PRect(nMessage.WParam)^;
        Dispose(PRect(nMessage.WParam));

        nRect.TopLeft := Parent.ScreenToClient(nRect.TopLeft);
        nRect.BottomRight := Parent.ScreenToClient(nRect.BottomRight);
      end else nRect := Rect(Left, Top, Left + Width, Top + Height);

      InvalidateRect(Parent.Handle, @nRect, False);
      //RedrawWindow(Parent.Handle, @nRect, 0, RDW_INVALIDATE or RDW_UPDATENOW);
    end;
  end else

  if nMessage.WParam > 0 then
  begin
    Dispose(PRect(nMessage.WParam));
  end;
end;

//Desc; 调整大小
procedure TZnTransPanel.Resize;
begin
  inherited;
  InvalidPanel;
end;

procedure Frame3D(Canvas: TCanvas; var Rect: TRect; TopColor, BottomColor: TColor;
  Width: Integer);

  procedure DoRect;
  var
    TopRight, BottomLeft: TPoint;
  begin
    with Canvas, Rect do
    begin
      TopRight.X := Right;
      TopRight.Y := Top;
      BottomLeft.X := Left;
      BottomLeft.Y := Bottom;
      Pen.Color := TopColor;
      PolyLine([BottomLeft, TopLeft, TopRight]);
      Pen.Color := BottomColor;
      Dec(BottomLeft.X);
      PolyLine([TopRight, BottomRight, BottomLeft]);
    end;
  end;

begin
  Canvas.Pen.Width := 1;
  Dec(Rect.Bottom); Dec(Rect.Right);
  while Width > 0 do
  begin
    Dec(Width);
    DoRect;
    InflateRect(Rect, -1, -1);
  end;
  Inc(Rect.Bottom); Inc(Rect.Right);
end;

//Desc: 绘制
procedure TZnTransPanel.Paint;
var nRect: TRect;
begin
  nRect := Rect(0, 0, Width, Height);

  if csDesigning in ComponentState then
  begin
    Canvas.Brush.Color := clBtnShadow;
    Canvas.FrameRect(nRect); Exit;
  end;

  if Ctl3D then
  begin
    Frame3D(Canvas, nRect, clBtnShadow, clBtnHighlight, 1);
    DrawEdge(Canvas.Handle, nRect, BDR_RAISEDINNER, BF_RECT);
  end;
end;

end.
 