{*******************************************************************************
  作者: dmzn@163.com 2010-2-26
  描述: 支持图片背景的容器
*******************************************************************************}
unit UBitmapPanel;

interface

uses
  Windows, Classes, Controls, SysUtils, Graphics, Messages;

type
  TZnBitmapPanel = class(TCustomControl)
  private
    FBitmap: TBitmap;
  protected
    procedure SetBitmap(const nValue: TBitmap);
    procedure Paint; override;
    procedure CreateParams(var nParams: TCreateParams); override;
    procedure WMEraseBkgnd(var nMessage: TMessage); message WM_ERASEBKGND;
  public
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
    destructor Destroy;override;
    procedure LoadBitmap(const nFile: string);
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property BorderWidth;
    property Ctl3D;
    property Color;
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
    {*基类属性*}
    property Bitmap:TBitmap read FBitmap write SetBitmap;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RunSoft', [TZnBitmapPanel]);
end;

constructor TZnBitmapPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DoubleBuffered := True;
  FBitmap := TBitmap.Create;
end;

procedure TZnBitmapPanel.CreateParams(var nParams: TCreateParams);
begin
  inherited CreateParams(nParams);
  ControlStyle := ControlStyle + [csAcceptsControls];
end;

destructor TZnBitmapPanel.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure TZnBitmapPanel.SetBitmap(const nValue: TBitmap);
begin
  if Assigned(nValue) then
  begin
    if not Assigned(FBitmap) then
      FBitmap := TBitmap.Create;
    FBitmap.Assign(nValue);
  end else FreeAndNil(FBitmap); 

  Invalidate;
end;

procedure TZnBitmapPanel.LoadBitmap(const nFile: string);
var nBmp: TBitmap;
begin
  nBmp := TBitmap.Create;
  try
    nBmp.LoadFromFile(nFile);
    SetBitmap(nBmp);
  except
    //ignor any error
  end;

  nBmp.Free;
end;

procedure TZnBitmapPanel.WMEraseBkgnd(var nMessage: TMessage);
begin
  if csDesigning in ComponentState then
       inherited
  else nMessage.Msg := 1;
end;

procedure TZnBitmapPanel.Paint;
var nX,nY: integer;
begin
  if Assigned(FBitmap) and (FBitmap.Width > 0) then
  begin
    nX := 0;
    while nX < Width do
    begin
      nY := 0;

      while nY < Height do
      begin
        Canvas.Draw(nX, nY, FBitmap);
        Inc(nY, FBitmap.Height);
      end;

      Inc(nX, FBitmap.Width);
    end;
  end else
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ClientRect);
  end;
end;

end.
