{*******************************************************************************
  作者: dmzn@163.com 2012-3-15
  描述: LED显示组件
*******************************************************************************}
unit ULEDFont;

interface

uses
  Windows, Classes, Controls, Graphics, ExtCtrls, SysUtils, Messages;

type
  TLEDFontNum = class(TCustomControl)
  private
    FAutoSize: Boolean;
    FOffsetX: integer;
    FWordWidth: integer;
    FOffsetY: integer;
    FSpace: integer;
    FWordHeight: integer;
    FThick: integer;
    FText: String;
    FLightColor: TColor;
    FBGColor: TColor;
    FDarkColor: TColor;
    FTransparent: Boolean;
    FDrawDarkColor: Boolean;

    OriginX: Integer;
    OriginY: Integer;
    d:   array [0..9, 0..5] of TPoint;
    LED: array [0..12] of String;

    FMemImage: TBitmap;
    //for double buffer
    procedure SetAutoSize2(const Value: Boolean);
    procedure SetBGColor(const Value: TColor);
    procedure SetDarkColor(const Value: TColor);
    procedure SetLightColor(const Value: TColor);
    procedure SetOffSetX(const Value: integer);
    procedure SetOffSetY(const Value: integer);
    procedure SetSpace(const Value: integer);
    procedure SetText(const Value: String);
    procedure SetThick(const Value: integer);
    procedure SetWordHeight(const Value: integer);
    procedure SetWordWidth(const Value: integer);
    procedure SetifDrawDarkColor(const Value: Boolean);

    procedure MakeMatrix;
    procedure DrawMemory;
    { Private declarations }
  protected
    { Protected declarations }
    procedure Paint; Override;
    procedure WMEraseBkgnd(var nMsg: TMessage); message WM_ERASEBKGND;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property OffSetX: integer read FOffsetX write SetOffSetX default 4;
    property OffSetY: integer read FOffsetY write SetOffSetY default 4;
    property WordWidth: integer read FWordWidth write SetWordWidth
      default 17;
    property WordHeight: integer read FWordHeight write SetWordHeight
      default 29;
    property Thick: integer read FThick write SetThick;
    property Space: integer read FSpace write SetSpace;
    property Text: String read FText write SetText;
    property BGColor: TColor read FBGColor write SetBGColor
      default $004A424A;
    property LightColor: TColor read FLightColor write SetLightColor
      default $0000FFF7;
    property DarkColor: TColor read FDarkColor write SetDarkColor
      default $00636363;
    property AutoSize: Boolean read FAutoSize write SetAutoSize2;
    property DrawDarkColor: Boolean read FDrawDarkColor write SetifDrawDarkColor default True;
    property ShowHint;
    property Visible;
    property PopupMenu;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseUp;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RunSoft', [TLEDFontNum]);
end;

constructor TLEDFontNum.Create(AOwner : TComponent);
begin
  inherited;
  Width := 47;
  Height := 38;

  FOffsetX := 4;
  FOffsetY := 4;
  FThick := 3; //小数点的宽度

  FWordWidth := 17;
  FWordHeight := 29;
  FSpace := 4;
  FText := '00';

  FAutoSize := True;
  FTransparent := False;
  FDrawDarkColor:= False;
  
  FBGColor := $004A424A;
  FLightColor := $0000FFF7;
  FDarkColor := $00636363;

  LED[0] := '012345';
  LED[1] := '12';
  LED[2] := '01643';
  LED[3] := '01623';
  LED[4] := '5612';
  LED[5] := '05623';
  LED[6] := '054326';
  LED[7] := '012';
  LED[8] := '0123456';
  LED[9] := '650123';
  LED[10] := '6';  //"-"
  LED[11] := '7'; //小数点
  LED[12] := '89'; //":" 上点 下点

  FMemImage := TBitmap.Create;
end;

destructor TLEDFontNum.Destroy;
begin
  FreeAndNil(FMemImage);
  inherited;
end;

procedure TLEDFontNum.WMEraseBkgnd(var nMsg: TMessage);
begin
  nMsg.Result := 0;
end;

procedure TLEDFontNum.SetOffsetX(const Value: Integer);
begin
  if FOffsetX <> Value then
  begin
    FOffsetX := Value;
    Invalidate;
  end;
end;

procedure TLEDFontNum.SetOffsetY(const Value: Integer);
begin
  if FOffsetY <> Value then
  begin
    FOffsetY := Value;
    Invalidate;
  end;
end;

procedure TLEDFontNum.SetWordWidth(const Value: Integer);
begin
  if (FWordWidth <> Value) and (FThick * 2 < Value) then
  begin
    FWordWidth := Value;
    Invalidate;
  end;
end;

procedure TLEDFontNum.SetWordHeight(const Value: Integer);
begin
  if (FWordHeight <> Value) and (FThick * 4 - 1 < Value) then
  begin
    if (Value - FThick * 4 + 1) mod 2 = 0 then
      FWordHeight := Value
    else
      FWordHeight := Value + 1;
    Invalidate;
  end;
end;

procedure TLEDFontNum.SetThick(const Value: Integer);
begin
  if (FThick <> Value) and (FWordWidth > Value * 2) and
     (FWordHeight > Value * 4 - 1) and
     ((FWordHeight - Value * 4 + 1) mod 2 = 0) then
  begin
    FThick := Value;
    Invalidate;
  end;
end;

procedure TLEDFontNum.SetSpace(const Value: Integer);
begin
  if FSpace <> Value then
  begin
    FSpace := Value;
    Invalidate;
  end;
end;

procedure TLEDFontNum.SetText(const Value: String);
begin
  if FText <> Value then
  begin
    FText := Value;
    Invalidate;
  end;
end;

procedure TLEDFontNum.SetBGColor(const Value: TColor);
begin
  if FBGColor <> Value then
  begin
    FBGColor := Value;
    Invalidate;
  end;
end;

procedure TLEDFontNum.SetLightColor(const Value: TColor);
begin
  if FLightColor <> Value then
  begin
    FLightColor := Value;
    Invalidate;
  end;
end;

procedure TLEDFontNum.SetDarkColor(const Value: TColor);
begin
  if FDarkColor <> Value then
  begin
    FDarkColor := Value;
    Invalidate;
  end;
end;

procedure TLEDFontNum.SetAutoSize2(const Value: Boolean);
var nNew: string;
begin
  nNew := Text;
  while Pos('.', nNew) > 0 do
    Delete(nNew, Pos('.', nNew), 1);
  //xxxxx

  while Pos(':', nNew) > 0 do
    Delete(nNew, Pos(':',nNew), 1);
  //xxxxx

  if Value <> FAutoSize then
  begin
    FAutoSize := Value;
    if FAutoSize and (Width <> FWordWidth * Length(nNew) +
       FSpace * (Length(nNew) - 1) + OffsetX * 2) then
    begin
      Width := FWordWidth * Length(nNew) +
               FSpace * (Length(nNew) - 1) + OffsetX * 2;
      Height := FWordHeight + OffsetY * 2;
    end;
  end;
end;

procedure TLEDFontNum.SetifDrawDarkColor(const Value: Boolean);
begin
  if FDrawDarkColor <> Value then
  begin
    FDrawDarkColor := Value;
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------
procedure TLEDFontNum.Paint;
begin
  DrawMemory;
  Canvas.Draw(0, 0, FMemImage);
end;

procedure TLEDFontNum.DrawMemory;
var nNew: string;
    i,j,k,kk: Integer;
    nPoint,nColon: array of Integer;
begin
  SetLength(nPoint, 0);
  i := 1;
  nNew := FText;
  
  while i<= Length(nNew) do
  if nNew[i] = '.' then
  begin
    j := Length(nPoint);
    SetLength(nPoint, j + 1);

    nPoint[j] := i - 1;
    System.Delete(nNew, i, 1);
  end else Inc(i);  //得到小数点跟在第几个数字后面的一组数组

  SetLength(nColon, 0);
  i := 1;
  
  while i<=Length(nNew) do
  if nNew[i] = ':' then
  begin
    j := Length(nPoint);
    SetLength(nPoint, j + 1);

    nPoint[j] := i - 1;
    System.Delete(nNew, i, 1);
  end else Inc(i);  //得到冒号跟在第几个数字后面的一组数组

  i := FWordWidth * Length(nNew) + FSpace * (Length(nNew) - 1) + OffsetX * 2;
  if FAutoSize then
  begin
    Width := i;
    OriginX := 0;
  end else OriginX := Width - i;

  OriginY := 0;
  FMemImage.Width := Width;
  FMemImage.Height := Height;
  
  with FMemImage.Canvas do
  begin
    Brush.Color := FBGColor;
    FillRect(ClipRect);

    for i := 1 to Length(nNew) do
    begin
      if i = 1 then //第一位数字
      begin
        Inc(OriginX, FOffsetX);
        Inc(OriginY, FOffsetY);
      end else Inc(OriginX, FWordWidth + FSpace);
      //给OriginX变量加上FOffsetX

      MakeMatrix;
      //给D[]二维数组赋值，以描绘出一个8

      if FDarkColor <> FBGColor then
      begin
        Brush.Color := FDarkColor;
        Pen.Color := FDarkColor;

        if FDrawDarkColor then
        begin
          for j := 1 to Length( LED[8] ) do  //'0123456'
            Polygon( d[ StrToInt( LED[8][j] ) ] );
          //画出从d[0]到d[6],一个"8"

          Polygon(d[7]); //画出d[7] ,小数点
          Polygon(d[8]); //画出d[8]、d[9] ,冒号
          Polygon(d[9]);
        end; //if FDrawDarkColor
      end;

      if (nNew[i] <> ' ') and (FLightColor <> FBGColor) then
      begin
        Brush.Color := FLightColor;
        Pen.Color := FLightColor;

        if nNew[i] = '-' then
        begin
          for j := 1 to Length( LED[10] ) do //'6'
            Polygon( d[ StrToInt( LED[10][j] ) ] );
          //画出d[6]
        end else

        if nNew[i] in ['0'..'9'] then
        begin
          for j := 1 to Length( LED[ StrToInt( nNew[i] ) ] ) do
            Polygon( d[ StrToInt( LED[ StrToInt( nNew[i] ) ][j] ) ] );
          //if i = (iPointPos - 1) then

          for k:=Low(nPoint) to High(nPoint) do
            if i=nPoint[k] then Polygon(d[7]);
          //for k

          for kk:=Low(nColon) to High(nColon) do
          if i=nColon[kk] then
          begin
            Polygon(d[8]);
            Polygon(d[9]);
          end;
        end;
      end;
    end;
  end;
end;

procedure TLEDFontNum.MakeMatrix;
begin
  d[0, 0] := Point(OriginX + 2, OriginY);
  d[0, 1] := Point(OriginX + FThick + 1, OriginY + FThick - 1);
  d[0, 2] := Point(OriginX + FWordWidth - FThick - 2 - FThick - 1+1, OriginY + FThick - 1);
  d[0, 3] := Point(OriginX + FWordWidth - 3 - FThick - 1+1, OriginY);
  d[0, 4] := d[0, 3];
  d[0, 5] := d[0, 3];

  d[1, 0] := Point(OriginX + FWordWidth - 1 - FThick - 1 +1, OriginY + 1);
  d[1, 1] := Point(OriginX + FWordWidth - FThick - FThick - 1+1, OriginY + FThick);
  d[1, 2] := Point(OriginX + FWordWidth - FThick - FThick - 1+1, OriginY + (FWordHeight - 1) div 2 - FThick);
  d[1, 3] := Point(OriginX + FWordWidth - 1 - FThick - 1+1, OriginY + (FWordHeight - 1) div 2 - 1);
  d[1, 4] := d[1, 3];
  d[1, 5] := d[1, 3];

  d[2, 0] := Point(OriginX + FWordWidth - 1 - FThick - 1+1, OriginY + (FWordHeight - 1) div 2 + 1);
  d[2, 1] := Point(OriginX + FWordWidth - FThick - FThick - 1+1, OriginY + (FWordHeight - 1) div 2 + FThick);
  d[2, 2] := Point(OriginX + FWordWidth - FThick - FThick - 1+1, OriginY + FWordHeight - FThick - 1);
  d[2, 3] := Point(OriginX + FWordWidth - 1 - FThick - 1+1, OriginY + FWordHeight - 2);
  d[2, 4] := d[2, 3];
  d[2, 5] := d[2, 3];

  d[3, 0] := Point(OriginX + FWordWidth - 3 - FThick - 1+1, OriginY + FWordHeight - 1);
  d[3, 1] := Point(OriginX + FWordWidth - FThick - 2 - FThick - 1+1, OriginY + FWordHeight - FThick);
  d[3, 2] := Point(OriginX + FThick + 1, OriginY + FWordHeight - FThick);
  d[3, 3] := Point(OriginX + 2, OriginY + FWordHeight - 1);
  d[3, 4] := d[3, 3];
  d[3, 5] := d[3, 3];

  d[4, 0] := Point(OriginX, OriginY + FWordHeight - 2);
  d[4, 1] := Point(OriginX + FThick - 1, OriginY + FWordHeight - FThick - 1);
  d[4, 2] := Point(OriginX + FThick - 1, OriginY + (FWordHeight - 1) div 2 + FThick);
  d[4, 3] := Point(OriginX, OriginY + (FWordHeight - 1) div 2 + 1);
  d[4, 4] := d[4, 3];
  d[4, 5] := d[4, 3];

  d[5, 0] := Point(OriginX, OriginY + (FWordHeight - 1) div 2 - 1);
  d[5, 1] := Point(OriginX + FThick - 1, OriginY + (FWordHeight - 1) div 2 - FThick);
  d[5, 2] := Point(OriginX + FThick - 1, OriginY + FThick);
  d[5, 3] := Point(OriginX, OriginY + 1);
  d[5, 4] := d[5, 3];
  d[5, 5] := d[5, 3];

  d[6, 0] := Point(OriginX + FThick, OriginY + (FWordHeight + 1) div 2 - FThick + 1);
  d[6, 1] := Point(OriginX + 2, OriginY + (FWordHeight + 1) div 2 - 1);
  d[6, 2] := Point(OriginX + FThick, OriginY + (FWordHeight + 1) div 2 + FThick - 3);
  d[6, 3] := Point(OriginX + FWordWidth - FThick - 1 - FThick - 1+1, OriginY + (FWordHeight + 1) div 2 + FThick - 3);
  d[6, 4] := Point(OriginX + FWordWidth - 3 - FThick - 1 +1, OriginY + (FWordHeight + 1) div 2 - 1);
  d[6, 5] := Point(OriginX + FWordWidth - FThick - 1 - FThick - 1+1, OriginY + (FWordHeight + 1) div 2 - FThick + 1);
  if FThick = 1 then
  begin
    d[6, 0] := Point(d[6, 0].X + 1, d[6, 0].Y - 1);
    d[6, 2] := Point(d[6, 2].X + 1, d[6, 2].Y + 1);
    d[6, 3] := Point(d[6, 3].X - 1, d[6, 3].Y + 1);
    d[6, 5] := Point(d[6, 5].X - 1, d[6, 5].Y - 1);
  end;

  d[7, 0] := Point(OriginX + FWordWidth - FThick+1, OriginY + FWordHeight - FThick);
  d[7, 1] := Point(OriginX + FWordWidth - FThick+1, OriginY + FWordHeight);
  d[7, 2] := Point(OriginX + FwordWidth+1, OriginY + FWordHeight);
  d[7, 3] := Point(OriginX + FWordWidth+1, OriginY + FWordHeight - FThick);
  d[7, 4] := d[7, 0];
  d[7, 5] := d[7, 0];

  d[8, 0] := Point(OriginX + FWordWidth - FThick+1, OriginY+(FWordHeight +1) div 4 - 1);
  d[8, 1] := Point(OriginX + FWordWidth +1, OriginY+(FWordHeight +1) div 4 - 1);
  d[8, 2] := Point(OriginX + FWordWidth +1, OriginY+(FWordHeight +1) div 4 - 1+ FThick);
  d[8, 3] := Point(OriginX + FWordWidth - FThick+1, OriginY+(FWordHeight +1) div 4 - 1+ FThick);
  d[8, 4] := d[8, 3];
  d[8, 5] := d[8, 3];

  d[9, 0] := Point(OriginX + FWordWidth - FThick+1, (FWordHeight +OriginY+1) div 2 +(FThick-1)div 2+(FWordHeight +1) div 4-FThick);
  d[9, 1] := Point(OriginX + FWordWidth +1, (FWordHeight +OriginY+1) div 2 +(FThick-1)div 2+(FWordHeight +1) div 4-FThick);
  d[9, 2] := Point(OriginX + FWordWidth +1, (FWordHeight +OriginY+1) div 2 +(FThick-1)div 2+(FWordHeight +1) div 4-FThick+FThick);
  d[9, 3] := Point(OriginX + FWordWidth - FThick+1, (FWordHeight +OriginY+1) div 2 +(FThick-1)div 2+(FWordHeight +1) div 4-FThick+FThick);
  d[9, 4] := d[9, 3];
  d[9, 5] := d[9, 3];
end;

end.
