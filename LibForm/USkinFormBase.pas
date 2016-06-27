{*******************************************************************************
  作者: dmzn@163.com 2011-10-8
  描述: 支持自定义皮肤的窗体基类
*******************************************************************************}
unit USkinFormBase;

interface

uses
  Windows, Classes, SysUtils, Forms, Messages, UImageButton, USkinManager,
  Controls, ExtCtrls, Graphics, StdCtrls;

const
  CM_CORNER = WM_User + $0001;

type
  TSkinFormBase = class(TForm)
    WordPanel: TPanel;
  private
    FHRGN: THandle;
    //圆角句柄
    FWinCanMax: Boolean;
    //可最大化
    FTitlePos: TPoint;
    //标题坐标
    FMouseDown: Boolean;
    FOldPos: TPoint;
    //窗体移动
  protected
    SkinItem: TSkinItem;
    //皮肤对象
    procedure Paint; override;
    //绘制窗体
    procedure Resize; override;
    //调整大小
    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    //窗体行为
    procedure AdjustClientRect(var Rect: TRect); override;
    //调整区域
    procedure WMNCHitTest(var nMsg: TWMNCHitTest); message WM_NCHITTEST;
    //修正边框
    procedure CMCORNET(var nMsg: TMessage); message CM_CORNER;
    //处理圆角
    procedure WMMAXINFO(var nMsg: TWMGetMinMaxInfo ); message WM_GetMinMaxInfo;
    //处理最大化
    function LoadFixImageButton(const nBtn: TImageButton): Boolean;
    //载入按钮
    function LoadFixImage(const nImage: TBitmap; const nID: string): Boolean;
    //载入图片
    procedure AppendButtons(const nButtons: TSkinParamButtons; nCorner: Byte);
    procedure AppendImages(const nImages: TSkinParamImages; nCorner: Byte);
    procedure ApplySkinOnForm;
    //载入皮肤
    procedure DoButtonClick(Sender: TObject);
    procedure OnButtonClick(const nButtonID: string); virtual;
    //处理事件
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //创建释放
    class function FormSkinID: string; virtual; abstract;
    //皮肤标识
    class function LoadImageButton(nBtn: TImageButton; nItem: TSkinItem): Boolean;
    //载入按钮
    class function LoadImage(nImage: TBitmap; nID: string; nItem: TSkinItem): Boolean;
    //载入图片
  end;

implementation

{$R *.dfm}

const
  cBorderEdge = 3;
  //有效边界

resourcestring
  cBtnMin = 'min';
  cBtnMax = 'max';
  cBtnExit = 'exit';
  //按钮标识

constructor TSkinFormBase.Create(AOwner: TComponent);
begin
  FHRGN := 0;
  //need init at first

  if not Assigned(gSkinManager) then
  begin
    gSkinManager := TSkinManager.Create;
    gSkinManager.LoadDefaultSkinFile(ExtractFilePath(Application.ExeName));
  end;

  SkinItem := gSkinManager.GetSkin(FormSkinID);
  if not Assigned(SkinItem) then
    raise Exception.Create('无法正确加载皮肤数据');
  //xxxxx

  inherited;
  DoubleBuffered := True;
  ApplySkinOnForm;
end;

destructor TSkinFormBase.Destroy;
begin
  if FHRGN > 0 then
    DeleteObject(FHRGN);
  inherited;
end;

procedure TSkinFormBase.AdjustClientRect(var Rect: TRect);
begin
  inherited;
  with SkinItem.Form do
  begin
    Rect.Left := Rect.Left + FEdgeArea.Left;
    Rect.Top := Rect.Top + FEdgeArea.Top;
    Rect.Right := Rect.Right - FEdgeArea.Right;
    Rect.Bottom := Rect.Bottom - FEdgeArea.Bottom;
  end;
end;

//Desc: 载入nItem中指定按钮nBtn的皮肤数据
class function TSkinFormBase.LoadImage(nImage: TBitmap; nID: string;
  nItem: TSkinItem): Boolean;
var nIdx: Integer;
begin
  Result := False;

  with nItem do
   for nIdx:=Low(Images) to High(Images) do
    if CompareText(nID, Images[nIdx].FImgID) = 0 then
    begin
      nImage.Assign(Images[nIdx].FImage.Bitmap);
      Result := True;
      Break;
    end;
  //image data
end;

//Desc: 载入nItem中nID的图片到nImage中
class function TSkinFormBase.LoadImageButton(nBtn: TImageButton;
  nItem: TSkinItem): Boolean;
var nIdx: Integer;
begin
  Result := False;

  with nItem do
   for nIdx:=Low(Buttons) to High(Buttons) do
    if CompareText(nBtn.ButtonID, Buttons[nIdx].FBtnID) = 0 then
    with nBtn,Buttons[nIdx] do
    begin
      PicDisable := FDisable.FImage;
      PicDown := FDown.FImage;
      PicEnter := FEnter.FImage;
      PicNormal := FNormal.FImage;

      AutoSize := True;
      ButtonID :=  FBtnID;
      HotRect := FHotArea;

      Result := True;
      Break;
    end;
  //btn data
end;

//Desc: 载入指定按钮nBtn的皮肤数据
function TSkinFormBase.LoadFixImageButton(const nBtn: TImageButton): Boolean;
begin
  Result := LoadImageButton(nBtn, SkinItem);
end;

//Desc: 载入nID的图片到nImage中
function TSkinFormBase.LoadFixImage(const nImage: TBitmap;
  const nID: string): Boolean;
begin
  Result := LoadImage(nImage, nID, SkinItem);
end;

//------------------------------------------------------------------------------
//Desc: 无边框模式时,处理鼠标调整边框大小
procedure TSkinFormBase.WMNCHitTest(var nMsg: TWMNCHitTest);
var nE: Integer;
    nPos: TPoint;
begin
  inherited; 
  if (WindowState = wsMaximized) or (not SkinItem.Form.FSizeable) then
    Exit;
  //xxxxx

  nE := cBorderEdge;
  nPos := Point(nMsg.XPos, nMsg.YPos);
  nPos := ScreenToClient(nPos);
    
  if PtInRect(Rect(0, 0, nE, nE), nPos) then
    nMsg.Result := HTTOPLEFT 
  //top left

  else if PtInRect(Rect(nE, 0, Width-nE, nE), nPos) then
    nMsg.Result := HTTOP
  //top edge

  else if PtInRect(Rect(Width-nE, 0, Width, nE), nPos) then
    nMsg.Result := HTTOPRIGHT
  //top right

  else if PtInRect(Rect(Width-nE, nE, Width, Height-nE), nPos) then
    nMsg.Result := HTRIGHT
  //right edge

  else if PtInRect(Rect(Width-nE, Height-nE, Width, Height), nPos) then
    nMsg.Result := HTBOTTOMRIGHT
  //bottom right

  else if PtInRect(Rect(nE, Height-nE, Width-nE, Height), nPos) then
    nMsg.Result := HTBOTTOM
  //bottom edge

  else if PtInRect(Rect(0, Height-nE, nE, Height), nPos) then
    nMsg.Result := HTBOTTOMLEFT
  //bottom left 

  else if PtInRect(Rect(0, nE, nE, Height-nE), nPos) then
    nMsg.Result := HTLEFT;
  //left edage
end;

procedure TSkinFormBase.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  FMouseDown := Button = mbLeft;
  FOldPos := Point(X, Y);
end;

procedure TSkinFormBase.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FMouseDown and (WindowState <> wsMaximized) then
  begin
    Left := Left + (X - FOldPos.X);
    Top := Top + (Y - FOldPos.Y);
  end;
end;

procedure TSkinFormBase.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  FMouseDown := False;
end;

//Desc: 双击最大化处理
procedure TSkinFormBase.DblClick;
begin
  inherited;
  if FWinCanMax then OnButtonClick(cBtnMax);
end;

//------------------------------------------------------------------------------
//Desc: 限制最大化时窗体高度
procedure TSkinFormBase.WMMAXINFO(var nMsg: TWMGetMinMaxInfo);
var nRect: TRect;
begin
  if SystemParametersInfo(SPI_GETWORKAREA, 0, @nRect, 0) then
  begin
    with nMsg.MinMaxInfo.ptMaxPosition do
    begin
      X := nRect.Left;
      Y := nRect.Top;
    end;

    with nMsg.MinMaxInfo.ptMaxSize do
    begin
      X := nRect.Right - nRect.Left;
      Y := nRect.Bottom - nRect.Top;
    end;
  end;
end;

procedure TSkinFormBase.OnButtonClick(const nButtonID: string);
begin
  if CompareText(cBtnExit, nButtonID) = 0 then
  begin
    Close;
  end else

  if CompareText(cBtnMax, nButtonID) = 0 then
  begin
    if WindowState = wsMaximized then
         WindowState := wsNormal
    else WindowState := wsMaximized;
  end else

  if CompareText(cBtnMin, nButtonID) = 0 then
  begin
    if Application.MainForm = Self then
         Application.Minimize
    else WindowState := wsMinimized;
  end;
end;

procedure TSkinFormBase.DoButtonClick(Sender: TObject);
begin
  OnButtonClick(TImageButton(Sender).ButtonID);
end;

//Desc: 生成nCorner[0..3]边角的按钮
procedure TSkinFormBase.AppendButtons(const nButtons: TSkinParamButtons;
  nCorner: Byte);
var nAn: TAnchors;
    nIdx,nL,nT: Integer;
begin
  case nCorner of
   0: //left top
    begin
      nL := 0;
      nT := 0;
      nAn := [akLeft, akTop];
    end;
   1: //right top
    begin
      nL := ClientWidth;
      nT := 0;
      nAn := [akRight, akTop];
    end;
   2: //left bottom
    begin
      nL := 0;
      nT := ClientHeight;
      nAn := [akLeft, akBottom];
    end;
   3: //right bottom
    begin
      nL := ClientWidth;
      nT := ClientHeight;
      nAn := [akRight, akBottom];
    end else Exit;
  end;

  for nIdx:=Low(nButtons) to High(nButtons) do
  with nButtons[nIdx] do
  begin             
    if not FEnable then Continue;

    with TImageButton.Create(Self) do
    begin
      Parent := Self;
      case nCorner of
       1,3: Left := nL - FNormal.FImage.Width else Left := nL;
      end;

      case nCorner of
       2,3: Top := nT - FNormal.FImage.Height else Top := nT;
      end;

      PicDisable := FDisable.FImage;
      PicDown := FDown.FImage;
      PicEnter := FEnter.FImage;
      PicNormal := FNormal.FImage;

      Anchors := nAn;
      AutoSize := True;
      ButtonID :=  FBtnID;
      HotRect := FHotArea;
      OnClick := DoButtonClick;

      if CompareText(cBtnMax, FBtnID) = 0 then
        FWinCanMax := True;
      //can max
    end;

    case nCorner of
     0,2: nL := nL + FNormal.FImage.Width; //向右排列
     1,3: nL := nL - FNormal.FImage.Width; //向左排列
    end;
  end;

  if nCorner = 0 then
    FTitlePos.X := nL;
  //xxxxx
end;

//Desc: 在边角nCorner[0..3]绘制nImages图片组
procedure TSkinFormBase.AppendImages(const nImages: TSkinParamImages;
  nCorner: Byte);
var nInt,nL,nT,nX,nY: Integer;
begin
  case nCorner of
   0: //left top
    begin
      nL := 0;
      nT := 0;
    end;
   1: //right top
    begin
      nL := ClientWidth;
      nT := 0;
    end;
   2: //left bottom
    begin
      nL := 0;
      nT := ClientHeight;
    end;
   3: //right bottom
    begin
      nL := ClientWidth;
      nT := ClientHeight;
    end else Exit;
  end;

  for nInt:=Low(nImages) to High(nImages) do
  with nImages[nInt] do
  begin
    if not FEnable then Continue;
    
    case nCorner of
     1,3: nX := nL - FImage.Width else nX := nL;
    end;

    case nCorner of
     2,3: nY := nT - FImage.Height else nY := nT;
    end;

    Canvas.Draw(nX, nY, FImage.Graphic);
    //draw it

    case nCorner of
     0,2: nL := nL + FImage.Width; //向右排列
     1,3: nL := nL - FImage.Width; //向左排列
    end;
  end;
end;

//Desc: 在窗体上应用皮肤
procedure TSkinFormBase.ApplySkinOnForm;
begin
  with Constraints, SkinItem.Form do
  begin
    MinWidth := FMinWidth;
    MaxWidth := FMaxWidth;
    MinHeight := FMinHeight;
    MaxHeight := FMaxHeight;
  end;

  with SkinItem.Title do
  begin
    AppendButtons(FBtnLeft, 0);
    AppendButtons(FBtnRight, 1);
  end;

  with SkinItem.BorderBottom do
  begin
    AppendButtons(FBtnLeft, 2);
    AppendButtons(FBtnRight, 3);
  end;

  BorderStyle := bsNone;
  DoubleBuffered := True;
end;

//------------------------------------------------------------------------------
//Desc: 调整大小时指定区域重绘
procedure TSkinFormBase.Resize;
begin
  inherited;
  PostMessage(Handle, CM_CORNER, 0, 0);
end;

//Desc: 处理窗口圆角
procedure TSkinFormBase.CMCORNET(var nMsg: TMessage);
var nOld: THandle;
begin
  nOld := FHRGN;
  FHRGN := CreateRoundRectRgn(0, 0, Width+1, Height+1, 4, 4);
  SetWindowRgn(Handle, FHRGN, True);

  if nOld > 0 then
    DeleteObject(nOld);
  Invalidate;
end;

//Desc: 绘制窗体
procedure TSkinFormBase.Paint;
var nL,nT: Integer;
begin
  inherited Paint;

  with SkinItem.BorderLeft,SkinItem.Form do
  begin
    nL := 0;
    nT := FEdgeArea.Top;

    while nT < ClientHeight - FEdgeArea.Bottom do
    begin
      Canvas.Draw(nL, nT, FImage.Graphic);
      Inc(nT, FImage.Height);
    end;
  end;

  with SkinItem.BorderRight,SkinItem.Form do
  begin
    nL := ClientWidth - FImage.Width;
    nT := FEdgeArea.Top;

    while nT < ClientHeight - FEdgeArea.Bottom do
    begin
      Canvas.Draw(nL, nT, FImage.Graphic);
      Inc(nT, FImage.Height);
    end;
  end;

  if Assigned(SkinItem.Title.FImgFill.FImage) then
  with SkinItem.Title.FImgFill do
  begin
    nL := 0;
    nT := 0;

    while nL < ClientWidth do
    begin
      Canvas.Draw(nL, nT, FImage.Graphic);
      Inc(nL, FImage.Width);
    end;
  end;

  AppendImages(SkinItem.Title.FImgLeft, 0);
  AppendImages(SkinItem.Title.FImgRight, 1);
  //top -> left,right

  if Assigned(SkinItem.BorderBottom.FImgFill.FImage) then
  with SkinItem.BorderBottom.FImgFill do
  begin
    nL := 0;
    nT := Self.ClientHeight - FImage.Height;

    while nL < ClientWidth do
    begin
      Canvas.Draw(nL, nT, FImage.Graphic);
      Inc(nL, FImage.Width);
    end;
  end;

  AppendImages(SkinItem.BorderBottom.FImgLeft, 2);
  AppendImages(SkinItem.BorderBottom.FImgRight, 3);
  //bottom -> left,right

  with SkinItem.Form,SkinItem.Title do
  begin
    Canvas.Font.Assign(Font);
    Canvas.Font.Color := FTextColor;
    Canvas.Font.Style := Canvas.Font.Style + [fsBold];

    nL := FTitlePos.X + 3;
    nT := Trunc((FEdgeArea.Top - Canvas.TextHeight(Caption)) / 2);

    SetBkMode(Canvas.Handle, TRANSPARENT);
    Canvas.TextOut(nL, nT, Caption);
  end;
end;

end.
