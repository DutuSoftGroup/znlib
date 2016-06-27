{*******************************************************************************
  作者: dmzn@163.com 2009-7-1
  描述: 图像预览控件
*******************************************************************************}
unit UImageViewer;

interface

uses
  Windows, Classes, Controls, ExtCtrls, Forms, Graphics, Messages, StdCtrls,
  SysUtils;

type
  TImageViewItem = class;
  TImageViewBgStyle = (bsTile, bsStretch);
  //背景处理风格

  TImageViewContain = class(TCustomControl)
  private
    FLable: TLabel;
    FOwner: TImageViewItem;
  protected
    procedure Paint; override;
    procedure WMERASEBKGND(var nMsg: TWMERASEBKGND);message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TImageViewItem); reintroduce;
  end;

  TImageOnBeginDrag = procedure (Sender: TObject; var nCanDrag: Boolean) of Object;
  //是否开启拖放

  TImageViewItem = class(TCustomControl)
  private
    FTitle: string;
    //标题文本
    FTitlePos: TPoint;
    //标题坐标
    FImage: TImage;
    //浏览图像
    FContainer: TImageViewContain;
    //图片容器
    FValidRect: TRect;
    //容器边界
    FBgColor: TColor;
    FBgImage: TGraphic;
    //背景图片
    FBgStyle: TImageViewBgStyle;
    //背景风格
    FBorderSelected: TGraphic;
    FBorderUnSelected: TGraphic;
    //边框图像
    FSelected: Boolean;
    //选中状态
    FCanSelected: Boolean;
    //可以选中
    FOnSelected: TNotifyEvent;
    //选中事件
    FOnBeginDrag: TImageOnBeginDrag;
    //开始拖放

    FCanMove: Boolean;
    //是否可移动
    FOldPoint: TPoint;
    //旧坐标位置
  protected
    procedure SetTitle(nValue: string);
    procedure SetTitlePos(nValue: TPoint);
    procedure SetSelected(nValue: Boolean);
    procedure SetImage(nValue: TImage);
    procedure SetValidRect(nValue: TRect);
    procedure SetBgColor(nValue: TColor);
    procedure SetBgImage(nValue: TGraphic);
    procedure SetBorderSelected(nValue: TGraphic);
    procedure SetBorderUnSelected(nValue: TGraphic);
    //设置函数
    procedure Paint; override;
    procedure Resize; override;
    procedure WMERASEBKGND(var nMsg: TWMERASEBKGND);message WM_ERASEBKGND;
    //重载函数
    procedure OnItemClick(Sender: TObject);
    procedure OnItemDBClick(Sender: TObject);
    //被选中
    procedure OnImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnImageMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure OnImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    //移动过程
    procedure OnItemDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure OnItemDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure OnItemEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure OnItemEndDrag(Sender, Target: TObject; X, Y: Integer);
    //拖放过程
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //创建释放
    procedure SetFitSize;
    procedure SetNormalSize;
    procedure SetPercentSize(const nPercent: Single);
    //显示比例
    procedure InvalidateItem;
    //更新显示
    property Title: string read FTitle write SetTitle;
    property TitlePos: TPoint read FTitlePos write SetTitlePos;
    property Image: TImage read FImage write SetImage;
    property ValidRect: TRect read FValidRect write SetValidRect;
    property BgColor: TColor read FBgColor write SetBgColor;
    property BgImage: TGraphic read FBgImage write SetBgImage;
    property BgStyle: TImageViewBgStyle read FBgStyle write FBgStyle;
    property BorderSelected: TGraphic read FBorderSelected write SetBorderSelected;
    property BorderUnSelected: TGraphic read FBorderUnSelected write SetBorderUnSelected;
    property Selected: Boolean read FSelected write SetSelected;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property BorderWidth;
    property Ctl3D;
    property Enabled;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnResize;
    property CanSelected: Boolean read FCanSelected write FCanSelected;
    property OnSelected: TNotifyEvent read FOnSelected write FOnSelected;
    property OnBeginDrag: TImageOnBeginDrag read FOnBeginDrag write FOnBeginDrag;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RunSoft', [TImageViewItem]);
end;

//------------------------------------------------------------------------------
constructor TImageViewContain.Create(AOwner: TImageViewItem);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls];

  FOwner := AOwner;
  Parent := AOwner;
  DoubleBuffered := True;

  FLable := TLabel.Create(Self);
  FLable.Parent := Self;
  FLable.Transparent := True;
end;

procedure TImageViewContain.WMERASEBKGND(var nMsg: TWMERASEBKGND);
begin
  nMsg.Result := LResult(False);
end;

procedure TImageViewContain.Paint;
var nX,nY: integer;
begin
  if not Assigned(FOwner.FBgImage) then
  begin
    Canvas.Brush.Color := FOwner.FBgColor;
    Canvas.FillRect(ClientRect); Exit;
  end;

  if FOwner.FBgStyle = bsStretch then
  begin
    Canvas.StretchDraw(ClientRect, FOwner.FBgImage);
  end else
  begin
    nX := 0;

    while nX < Width do
    begin
      nY := 0;

      while nY < Height do
      begin
        Canvas.Draw(nX, nY, FOwner.FBgImage);
        Inc(nY, FOwner.FBgImage.Height);
      end;

      Inc(nX, FOwner.FBgImage.Width);
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TImageViewItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls];
  
  Width := 300;
  Height := 150;
  DoubleBuffered := True;

  FCanMove := False;
  FSelected := False;
  FTitlePos := Point(1, 1);

  FBgColor := clGray;
  FBgImage := nil;
  FBgStyle := bsTile;
  FCanSelected := True;
  
  FBorderSelected := nil;
  FBorderUnSelected := nil;

  FContainer := TImageViewContain.Create(Self);
  FContainer.OnClick := OnItemClick;
  FContainer.OnDblClick := OnItemDBClick;
  FContainer.OnDragDrop := OnItemDragDrop;
  FContainer.OnDragOver := OnItemDragOver;
  FContainer.OnEndDock := OnItemEndDock;
  FContainer.OnEndDrag := OnItemEndDrag;

  SetValidRect(Rect(0, 0, 0, 0));
  FImage := TImage.Create(Self);
  
  with FImage do
  begin
    Parent := FContainer;
    OnClick := OnItemClick;
    OnDblClick := OnItemDBClick;
    
    OnMouseDown := OnImageMouseDown;
    OnMouseMove := OnImageMouseMove;
    OnMouseUp := OnImageMouseUp;

    OnDragDrop := OnItemDragDrop;
    OnDragOver := OnItemDragOver;
    OnEndDock := OnItemEndDock;
    OnEndDrag := OnItemEndDrag;
  end;
end;

destructor TImageViewItem.Destroy;
begin
  if Assigned(FBgImage) then FBgImage.Free;
  if Assigned(FBorderSelected) then FBorderSelected.Free;
  if Assigned(FBorderUnSelected) then FBorderUnSelected.Free;
  inherited;
end;

//Desc: 调整大小
procedure TImageViewItem.Resize;
begin
  inherited;
  SetValidRect(FValidRect);
end;

procedure TImageViewItem.WMERASEBKGND(var nMsg: TWMERASEBKGND);
begin
  nMsg.Result := LResult(False);
end;

//------------------------------------------------------------------------------
//Desc: 选中
procedure TImageViewItem.OnItemClick(Sender: TObject);
begin
  Selected := True;
  if Assigned(OnClick) then OnClick(Self);
end;

procedure TImageViewItem.OnItemDBClick(Sender: TObject);
begin
  if Assigned(OnDblClick) then OnDblClick(Self);
end;

procedure TImageViewItem.OnItemDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  if Assigned(OnDragDrop) then OnDragDrop(Self, Source, X, Y);
end;

procedure TImageViewItem.OnItemDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if Assigned(OnDragOver) then OnDragOver(Self, Source, X, Y, State, Accept);
end;

procedure TImageViewItem.OnItemEndDock(Sender, Target: TObject; X,
  Y: Integer);
begin
  if Assigned(OnEndDock) then OnEndDock(Self, Target, X, Y);
end;

procedure TImageViewItem.OnItemEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  if Assigned(OnEndDrag) then OnEndDrag(Self, Target, X, Y);
end;

//------------------------------------------------------------------------------
//Desc: 设置标题
procedure TImageViewItem.SetTitle(nValue: string);
begin
  if nValue <> FTitle then
  with FContainer do
  begin
    FTitle := nValue;
    FLable.BringToFront;

    FLable.Left := FTitlePos.X;
    FLable.Top := FTitlePos.Y;
    FLable.Caption := nValue;
  end;
end;

//Desc: 设置位置
procedure TImageViewItem.SetTitlePos(nValue: TPoint);
begin
  FTitlePos := nValue;
  with FContainer do
  begin
    FLable.BringToFront; 
    FLable.Left := FTitlePos.X;
    FLable.Top := FTitlePos.Y;
  end;
end;

//Desc: 更新显示
procedure TImageViewItem.InvalidateItem;
begin
  Invalidate;
  FContainer.Invalidate;
end;

//Desc: 背景色
procedure TImageViewItem.SetBgColor(nValue: TColor);
begin
  if nValue <> FBgColor then
  begin
    FBgColor := nValue;
    InvalidateItem;
  end;
end;

//Desc: 背景
procedure TImageViewItem.SetBgImage(nValue: TGraphic);
begin
  if Assigned(nValue) then
  begin
    if not Assigned(FBgImage) then
      FBgImage := TGraphicClass(nValue.ClassType).Create;
    FBgImage.Assign(nValue);
  end else FreeAndNil(FBgImage);

  Invalidate;
end;

//Desc: 选中边框
procedure TImageViewItem.SetBorderSelected(nValue: TGraphic);
begin
  if Assigned(nValue) then
  begin
    if not Assigned(FBorderSelected) then
      FBorderSelected := TGraphicClass(nValue.ClassType).Create;
    FBorderSelected.Assign(nValue);
  end else FreeAndNil(FBorderSelected);

  Invalidate;
end;

//Desc: 非选中边框
procedure TImageViewItem.SetBorderUnSelected(nValue: TGraphic);
begin
  if Assigned(nValue) then
  begin
    if not Assigned(FBorderUnSelected) then
      FBorderUnSelected := TGraphicClass(nValue.ClassType).Create;
    FBorderUnSelected.Assign(nValue);
  end else FreeAndNil(FBorderUnSelected);

  Invalidate;
end;

//Desc: 设置图片
procedure TImageViewItem.SetImage(nValue: TImage);
begin
  if Assigned(nValue) then
  begin
    FImage.Picture.Assign(nValue.Picture);
    SetFitSize;
  end else FImage.Picture.Graphic := nil;
end;

//Desc: 设置有效区域
procedure TImageViewItem.SetValidRect(nValue: TRect);
begin
  FValidRect := nValue;
  FContainer.Left := FValidRect.Left;
  FContainer.Top := FValidRect.Top;
  FContainer.Width := Width - FValidRect.Left - FValidRect.Right;
  FContainer.Height := Height - FValidRect.Top - FValidRect.Bottom;
end;

//Desc: 设置选中
procedure TImageViewItem.SetSelected(nValue: Boolean);
var nS: Boolean;
begin
  nS := FSelected;

  if nValue and FCanSelected then
  begin
    FSelected := True;
    
    if nS <> True then
    begin
      Invalidate;
      if Assigned(FOnSelected) then FOnSelected(Self);
    end;
  end else
  begin
    FSelected := False;

    if nS <> False then
    begin
      Invalidate;
      if Assigned(FOnSelected) then FOnSelected(Self);
    end;
  end;
end;

//Desc: 绘制
procedure TImageViewItem.Paint;
var nBorder: TGraphic;
begin
  if FSelected then
       nBorder := FBorderSelected
  else nBorder := FBorderUnSelected;

  if Assigned(nBorder) then
  begin
    Canvas.StretchDraw(ClientRect, nBorder);
  end else
  begin
    Canvas.Brush.Color := FBgColor;
    Canvas.FillRect(ClientRect);
  end;
end;

//------------------------------------------------------------------------------
//Desc: 适合大小,全部显示
procedure TImageViewItem.SetFitSize;
begin
  with FImage do
  begin
    Align := alClient;
    Center := True;
    Proportional := True;
  end;
end;

//Desc: 正常大小
procedure TImageViewItem.SetNormalSize;
begin
  with FImage do
  begin
    Align := alNone;
    AutoSize := True;
    Application.ProcessMessages;

    if Width < FContainer.Width then
         Left := Round((FContainer.Width - Width) / 2)
    else Left := 0;

    if Height < FContainer.Height then
         Top := Round((FContainer.Height - Height) / 2)
    else Top := 0;
  end;
end;

//Desc: 比例缩放
procedure TImageViewItem.SetPercentSize(const nPercent: Single);
begin
  with FImage do
  if Assigned(Picture) then
  begin
    Align := alNone;
    Left := 0;
    Top := 0;
    AutoSize := False;
    
    Stretch := True;
    Width := Round(Picture.Width * nPercent);
    Height := Round(Picture.Height * nPercent);

    if Width < FContainer.Width then
      Left := Round((FContainer.Width - Width) / 2);
    if Height < FContainer.Height then
      Top := Round((FContainer.Height - Height) / 2);
  end;
end;

//------------------------------------------------------------------------------
procedure TImageViewItem.OnImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var nDrag: Boolean;
begin
  nDrag := ssCtrl in Shift;
  if Assigned(FOnBeginDrag) then
    FOnBeginDrag(Self, nDrag);
  //xxxxx

  if nDrag then
  begin
    FImage.BeginDrag(False, 5); Exit;
  end;
  
  if Button = mbLeft then
  begin
    FCanMove := True;
    FOldPoint := Point(X, Y);
  end else FCanMove := False;
end;

procedure TImageViewItem.OnImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var nNew: TPoint;
    nCtrl: TControl;
begin
  nCtrl := TControl(Sender);

  if FCanMove then
  begin
    nNew.X := nCtrl.Left + X - FOldPoint.X;
    nNew.Y := nCtrl.Top + Y - FOldPoint.Y;
  end else Exit;

  if X > FOldPoint.X then //右移
  begin
    if nNew.X + nCtrl.Width > FContainer.Width then
     if  nCtrl.Width < FContainer.Width then
       nNew.X := FContainer.Width - nCtrl.Width
     else if nNew.X > 0 then nNew.X := 0;
  end else
  begin
    if nNew.X < 0 then
     if nCtrl.Width < FContainer.Width then
       nNew.X := 0
     else if nNew.X + nCtrl.Width < FContainer.Width then
       nNew.X := FContainer.Width - nCtrl.Width;
  end;

  if Y > FOldPoint.Y then //下移
  begin
    if nNew.Y + nCtrl.Height > FContainer.Height then
     if nCtrl.Height < FContainer.Height then
          nNew.Y := FContainer.Height - nCtrl.Height
     else if nNew.Y > 0 then nNew.Y := 0;
  end else
  begin
    if nNew.Y < 0 then
     if nCtrl.Height < FContainer.Height then
       nNew.Y := 0
     else if nNew.Y + nCtrl.Height < FContainer.Height then
       nNew.Y := FContainer.Height - nCtrl.Height;
  end;

  nCtrl.Left := nNew.X;
  nCtrl.Top := nNew.Y;
end;

procedure TImageViewItem.OnImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FCanMove := False;
end;

end.
