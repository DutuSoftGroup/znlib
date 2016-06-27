{*******************************************************************************
  作者: dmzn@163.com 2009-6-28
  描述: 玻璃透明效果
*******************************************************************************}
unit UTransGlass;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TGlassStyle = (
    gsBlackness, gsDstInvert, gsMergeCopy, gsMergePaint, gsNotSrcCopy,
    gsNotSrcErase, gsPatCopy, gsPatInvert, gsPatPaint, gsSrcAnd,
    gsSrcCopy, gsSrcErase, gsSrcInvert, gsSrcPaint, gsWhiteness);

  TZnGlassControl = class(TCustomControl)
  private
    FColor: TColor;
    FStyle: TGlassStyle;
    FOnPaint: TNotifyEvent;

    procedure SetColor(Value: TColor);
    procedure SetStyle(Value: TGlassStyle);
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
  protected
    FBuffer: TBitmap;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Canvas;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property BorderWidth;
    property Color: TColor read FColor write SetColor;
    property Ctl3D;
    property Enabled;
    property Style: TGlassStyle read FStyle write SetStyle default gsSrcAnd;
    property Visible;

    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RunSoft', [TZnGlassControl]);
end;

function GlassStyleToInt(gs: TGlassStyle): LongInt;
begin
  Result := -1;

  case gs of
    gsBlackness  : Result := cmBlackness;
    gsDstInvert  : Result := cmDstInvert;
    gsMergeCopy  : Result := cmMergeCopy;
    gsMergePaint : Result := cmMergePaint;
    gsNotSrcCopy : Result := cmNotSrcCopy;
    gsNotSrcErase: Result := cmNotSrcErase;
    gsPatCopy    : Result := cmPatCopy;
    gsPatInvert  : Result := cmPatInvert;
    gsPatPaint   : Result := cmPatPaint;
    gsSrcAnd     : Result := cmSrcAnd;
    gsSrcCopy    : Result := cmSrcCopy;
    gsSrcErase   : Result := cmSrcErase;
    gsSrcInvert  : Result := cmSrcInvert;
    gsSrcPaint   : Result := cmSrcPaint;
    gsWhiteness  : Result := cmWhiteness;
  end;
end;

constructor TZnGlassControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 100;
  Height := 100;     

  Ctl3D := False;
  ParentCtl3d := False;
  ParentColor := False;

  FColor := clWhite;
  FStyle := gsSrcAnd;
  FBuffer := TBitmap.Create;
end;

procedure TZnGlassControl.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  
  if not (csDesigning in ComponentState) then
  begin
    Params.ExStyle := Params.ExStyle + WS_EX_Transparent;
    ControlStyle := ControlStyle - [csOpaque];
  end;

  ControlStyle := ControlStyle + [csAcceptsControls];
end;

destructor TZnGlassControl.Destroy;
begin
  FBuffer.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------
procedure TZnGlassControl.SetColor(Value: TColor);
begin
  if Value <> FColor then
  begin
    FColor := Value;
    RecreateWnd;
  end;
end;

procedure TZnGlassControl.WMWindowPosChanging(var Message: TWMWindowPosChanging);
begin
  Invalidate;
  inherited;
end;

procedure TZnGlassControl.WMEraseBkgnd(var Message: TMessage);
begin
  Message.Result := 0;
end;

procedure TZnGlassControl.Resize;
begin
  Invalidate;
  inherited;
end;

procedure TZnGlassControl.CMCtl3DChanged(var Message: TMessage);
begin
  inherited; 
  RecreateWnd;
end;

procedure TZnGlassControl.SetStyle(Value: TGlassStyle);
begin
  if Value <> FStyle then
  begin
    FStyle := Value;
    RecreateWnd;
  end;
end;

//Desc: 透明绘制
procedure TZnGlassControl.Paint;
var nRect: TRect;
    nRop: LongInt;
begin
  if csDesigning in ComponentState then
  begin
    Canvas.Brush.Color := FColor;
    Canvas.FillRect(ClientRect); Exit;
  end;

  FBuffer.Width := Width;
  FBuffer.Height := Height;

  FBuffer.Canvas.Brush.Style := bsSolid;
  FBuffer.Canvas.Brush.Color := FColor;
  FBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));

  nRop := GlassStyleToInt(FStyle);
  StretchBlt(FBuffer.Canvas.Handle, 0, 0, Width, Height,
             Canvas.Handle, 0, 0, Width, Height, nRop);
  //xxxxx

  nRect := Rect(0, 0, Width, Height);
  if Ctl3D then
    DrawEdge(FBuffer.Canvas.Handle, nRect, BDR_RAISEDINNER, BF_RECT);
  //xxxxx

  FBuffer.Canvas.Pen.Mode := pmCopy;
  FBuffer.Canvas.Pen.Style := psSolid;
  Canvas.Draw(0, 0, FBuffer);
  if Assigned(FOnPaint) then FOnPaint(Self);
end;

end.
