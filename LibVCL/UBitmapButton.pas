{*******************************************************************************
  ×÷Õß: dmzn@163.com 2009-7-24
  ÃèÊö: Í¼Æ¬°´Å¥
*******************************************************************************}
unit UBitmapButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TZnBitmapButton = class(TGraphicControl)
  private
    FBitmap: TBitmap;
    FLighter: TBitmap;
    FDarker: Tbitmap;
    FPushDown:boolean;
    FMouseOver:boolean;
    FLatching: boolean;
    FDown: boolean;
    FHotTrack: boolean;
    procedure SetBitmap(const Value: TBitmap);
    procedure MakeDarker;
    procedure MakeLighter;
    procedure SetLatching(const Value: boolean);
    procedure SetDown(const Value: boolean);
    procedure SetHotTrack(const Value: boolean);
    { Private declarations }
  protected
    { Protected declarations }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);override;
    procedure Click;override;
    procedure CMMouseLeave(var Message:TMessage); message CM_MouseLeave;
    procedure Loaded;override;
    procedure Resize;override;
  public
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
    destructor  Destroy;override;
    procedure   Paint; override;
  published
    { Published declarations }
    property Bitmap:TBitmap read FBitmap write SetBitmap;
    property Down:boolean read FDown write SetDown;
    property Latching:boolean read FLatching write SetLatching;
    property HotTrack:boolean read FHotTrack write SetHotTrack;
    property OnClick;
    property OnMouseDown;
    property OnMouseUp;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RunSoft', [TZnBitmapButton]);
end;

//------------------------------------------------------------------------------
constructor TZnBitmapButton.Create(AOwner: TComponent);
begin
  inherited;
  Width := 75;
  Height:= 25;

  FPushDown := False;
  FMouseOver := False;
  FLatching := False;
  FHotTrack := True;
  FDown := False;

  FBitmap := TBitmap.create;
  FBitmap.Width := Width;
  FBitmap.Height := Height;
  FBitmap.Canvas.Brush.color := clgray;
  FBitmap.Canvas.FillRect(Rect(1, 1, Width - 1, Height - 1));

  FLighter := TBitmap.Create;
  FDarker := TBitmap.Create;
end;

destructor TZnBitmapButton.Destroy;
begin
  FBitmap.Free;
  FLighter.Free;
  FDarker.Free;
  inherited;
end;

procedure TZnBitmapButton.Click;
begin
  if FPushDown then
  begin
    if Assigned(OnClick) then OnClick(self);
  end else inherited;
end;

procedure TZnBitmapButton.CMMouseLeave(var Message: TMessage);
begin
  FMouseOver := False;
  Invalidate;
end;

procedure TZnBitmapButton.Loaded;
begin
  inherited;
  if not FBitmap.Empty then
  begin
    MakeDarker;
    MakeLighter;
  end;
end;

procedure TZnBitmapButton.SetLatching(const Value: boolean);
begin
  FLatching  :=  Value;
  if not FLatching then
  begin
    FDown := False;
    Invalidate;
  end;  
end;

procedure TZnBitmapButton.SetDown(const Value: boolean);
begin
  if FLatching then
  begin
    FDown  :=  Value;
    Invalidate;
  end else
  begin
    FDown := False;
    Invalidate;
  end;
end;

procedure TZnBitmapButton.Resize;
begin
  inherited;
  if Assigned(FBitmap) then
  begin
    Width := FBitmap.Width;
    Height := FBitmap.Height;
  end else
  begin
    Width := 75;
    Height := 25;
  end;
end;

procedure TZnBitmapButton.SetHotTrack(const Value: boolean);
begin
  FHotTrack := Value;
end;

procedure TZnBitmapButton.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FBitmap.Canvas.Pixels[X,Y] <> FBitmap.Canvas.Pixels[0,FBitmap.Height-1] then
       FPushDown := True
  else FPushDown := False;

  Paint;
  if Assigned(OnMouseDown) then
    OnMouseDown(Self, Button, Shift, X, Y);
  //xxxxx
end;

procedure TZnBitmapButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var nValue: Boolean;
begin
  inherited;
  nValue := FBitmap.Canvas.Pixels[X, Y] <> FBitmap.Canvas.Pixels[0,FBitmap.Height-1];
  if nValue <> FMouseOver then
  begin
    FMouseOver := nValue;
    Invalidate;
  end;

  if Assigned(OnMouseMove) then
    OnMouseMove(Self, Shift, X, Y);
  //xxxxx
end;

procedure TZnBitmapButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  FPushDown := False;

  if Latching then
       FDown :=  not FDown
  else FDown := False;

  Paint;
  if Assigned(OnMouseUp) then
    OnMouseUp(Self, Button, Shift, X, Y);
  //xxxxx
end;

procedure TZnBitmapButton.SetBitmap(const Value: TBitmap);
begin
  FBitmap.assign(Value);
  FBitmap.transparent := True;
  FBitmap.TransparentColor  := FBitmap.Canvas.pixels[0,FBitmap.Height-1];
  width := FBitmap.Width ;
  height := FBitmap.Height ;
  MakeLighter;
  MakeDarker;
end;

procedure TZnBitmapButton.MakeLighter;
var p1,p2:Pbytearray;
    x,y:integer;
    rt,gt,bt:byte;
    AColor:TColor;
begin
  FLighter.Width  := FBitmap.Width ;
  FLighter.Height  := FBitmap.height;
  Acolor := colortorgb(FBitmap.Canvas.pixels[0,FBitmap.height-1]);

  rt := GetRValue(Acolor);
  gt := GetGValue(AColor);
  bt := getBValue(AColor);

  FBitmap.PixelFormat  := pf24bit;
  FLighter.PixelFormat  := pf24bit;
  
  for y := 0 to Fbitmap.height-1 do
  begin
    p1 := Fbitmap.ScanLine [y];
    p2 := FLighter.ScanLine [y];
    for x := 0 to FBitmap.width-1 do
    begin
      if (p1[x*3]=bt)and (p1[x*3+1]=gt)and (p1[x*3+2]=rt) then
      begin
        p2[x*3] := p1[x*3];
        p2[x*3+1] := p1[x*3+1];
        p2[x*3+2] := p1[x*3+2];
      end else
      begin
        p2[x*3] := $FF-round(0.8*abs($FF-p1[x*3]));
        p2[x*3+1] := $FF-round(0.8*abs($FF-p1[x*3+1]));
        p2[x*3+2] := $FF-round(0.8*abs($FF-p1[x*3+2]));
      end;
    end;
  end;
end;

procedure TZnBitmapButton.MakeDarker;
var p1,p2:Pbytearray;
    x,y:integer;
    rt,gt,bt:byte;
    AColor:TColor;
begin
  FDarker.Width  := FBitmap.Width ;
  FDarker.Height  := FBitmap.height;
  Acolor := colortorgb(FBitmap.Canvas.pixels[0,FBitmap.height-1]);

  rt := GetRValue(Acolor);
  gt := GetGValue(AColor);
  bt := getBValue(AColor);

  FBitmap.PixelFormat  := pf24bit;
  FDarker.PixelFormat  := pf24bit;

  for y := 0 to Fbitmap.height-1 do
  begin
    p1 := Fbitmap.ScanLine [y];
    p2 := FDarker.ScanLine [y];
    for x := 0 to FBitmap.width-1 do
    begin
      if (p1[x*3]=bt)and (p1[x*3+1]=gt)and (p1[x*3+2]=rt) then
      begin
        p2[x*3] := p1[x*3];
        p2[x*3+1] := p1[x*3+1];
        p2[x*3+2] := p1[x*3+2];
      end else
      begin
        p2[x*3] := round(0.7*p1[x*3]);
        p2[x*3+1] := round(0.7*p1[x*3+1]);
        p2[x*3+2] := round(0.7*p1[x*3+2]);
      end
    end;
  end;
end;

procedure TZnBitmapButton.Paint;
var Acolor:TColor;
begin
  inherited;
  if Assigned(FBitmap) then
  begin
    AColor := FBitmap.Canvas.pixels[0,FBitmap.height-1];
    Fbitmap.transparent := False;
    //Fbitmap.transparentcolor := Acolor;

    FLighter.transparent := False;
    //Flighter.TransparentColor  := AColor;
    FDarker.transparent := True;
    FDarker.TransparentColor  := AColor;

    if FPushdown then
    begin
      Canvas.Draw(1,1,FDarker)
    end  else
    begin
      if Down then
        Canvas.Draw(1,1,FDarker)
      else if (FMouseOver and FHotTrack) then
           Canvas.Draw(0,0,FLighter)
      else Canvas.Draw(0,0,FBitmap);
    end;
  end;
end;

end.
