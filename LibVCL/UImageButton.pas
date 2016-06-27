{*******************************************************************************
  作者: dmzn@163.com 2011-10-7
  描述: 图片按钮
*******************************************************************************}
unit UImageButton;

interface

uses
  Windows, Controls, Messages, SysUtils, Classes, Graphics, ExtCtrls;

type
  TOnMouseEvent = procedure(const nMsg: TWMMouse) of object;
  //事件定义

  TImageButton = class(TImage)
  private
    FButtonID: string;
    //按钮标识
    FHotRect: TRect;
    //热点区域
    FPicNormal: TPicture;
    FPicDisable: TPicture;
    FPicDown : TPicture;
    FPicEnter: TPicture;
    FPicActive: TPicture;
    //图像对象
    FChecked: Boolean;
    FBtnDown: Boolean;
    //状态标记
    FOnMouseEnter : TOnMouseEvent;
    FOnMouseLeave : TOnMouseEvent;
    //事件变量
  protected
    function GetMousePos: TPoint;
    function InHotRect(const nPoint: TPoint): Boolean;
    //热区判定
    procedure UpdatePicture(const nInHot: Boolean);
    procedure ActivePicture(const nPicture: TPicture);
    //激活图像
    procedure SetPicNormal(nValue: TPicture);
    procedure SetPicDown(nValue: TPicture);
    procedure SetPicEnter(nValue: TPicture);
    procedure SetPicDisable(nValue: TPicture);
    procedure SetChecked(nValue: Boolean);
    //set action
    procedure WMMouseEnter(var nMsg: TWMMouse); message CM_MOUSEENTER;
    procedure WMMouseLeave(var nMsg: TWMMouse); message CM_MOUSELEAVE;
    procedure WMEnabledChanged(var nMsg: TMessage); message CM_ENABLEDCHANGED;
    //消息处理
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    //鼠标事件
  public
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
    //创建释放
    procedure ResetHotRect;
    //重置热区
    property HotRect: TRect read FHotRect write FHotRect;
  published
    property ButtonID: string read FButtonID write FButtonID;
    property Checked: Boolean read FChecked write SetChecked;
    property PicNormal: TPicture read FPicNormal write SetPicNormal;
    property PicDisable: TPicture read FPicDisable write SetPicDisable;
    property PicDown: TPicture read FPicDown write SetPicDown;
    property PicEnter: TPicture read FPicEnter write SetPicEnter;
    //属性相关
    property OnMouseEnter : TOnMouseEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave : TOnMouseEvent read FOnMouseLeave write FOnMouseLeave;
    //事件相关
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RunSoft', [TImageButton]);
end;

constructor TImageButton.Create(AOwner: TComponent);
begin
  inherited;
  FChecked := False;
  FBtnDown := False;

  ResetHotRect;
  //默认全按钮有效

  FPicNormal := TPicture.Create;
  FPicDisable := TPicture.Create;
  FPicDown := TPicture.Create;
  FPicEnter := TPicture.Create;
end;

destructor TImageButton.Destroy;
begin
  FPicNormal.Free;
  FPicDisable.Free;
  FPicDown.Free;
  FPicEnter.Free;
  inherited;
end;

//Desc: 重置热区为全按钮
procedure TImageButton.ResetHotRect;
begin
  FHotRect := Rect(0, 0, 0, 0);
end;

//Desc: 当前鼠标坐标
function TImageButton.GetMousePos: TPoint;
begin
  GetCursorPos(Result);
  Result := ScreenToClient(Result);
end;

//Desc: 判断nPoint是否进入热区
function TImageButton.InHotRect(const nPoint: TPoint): Boolean;
begin
  if Enabled then
  begin
    Result := (FHotRect.Right - FHotRect.Left <= 0) or
              (FHotRect.Bottom - FHotRect.Top <= 0);
    //xxxxx

    if Result then
         Result := PtInRect(ClientRect, nPoint)
    else Result := PtInRect(FHotRect, nPoint);
  end else Result := False;
end;

//Desc: 更新图像状态
procedure TImageButton.UpdatePicture(const nInHot: Boolean);
begin
  if not Enabled then
  begin
    ActivePicture(FPicDisable); Exit;
  end;

  if nInHot then
  begin
    if csDesigning in ComponentState then Exit;
    //设计时不处理热区
    
    if FBtnDown then
         ActivePicture(FPicDown)
    else ActivePicture(FPicEnter);
  end else

  begin
    if FChecked then
         ActivePicture(FPicDown)
    else ActivePicture(FPicNormal);
  end;
end;

//Desc: 激活nPicture图像
procedure TImageButton.ActivePicture(const nPicture: TPicture);
begin
  if FPicActive <> nPicture then
  begin
    Picture := nPicture;
    FPicActive := nPicture;
  end;
end;

procedure TImageButton.WMEnabledChanged(var nMsg: TMessage);
begin
  inherited;
  UpdatePicture(InHotRect(GetMousePos));
end;

procedure TImageButton.WMMouseEnter(var nMsg: TWMMouse);
begin
  inherited;
  UpdatePicture(InHotRect(GetMousePos));

  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(nMsg);
  //xxxxx
end;

procedure TImageButton.WMMouseLeave(var nMsg: TWMMouse);
begin
  inherited;
  UpdatePicture(False);

  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(nMsg);
  //xxxxx
end;

procedure TImageButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  FBtnDown := (Button = mbLeft) and InHotRect(Point(X, Y));
  UpdatePicture(InHotRect(GetMousePos));
end;

procedure TImageButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  UpdatePicture(InHotRect(Point(X, Y)));
end;

procedure TImageButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  FBtnDown := False;
  UpdatePicture(InHotRect(Point(X, Y)));
end;

procedure TImageButton.SetChecked(nValue: Boolean);
begin
  if nValue <> FChecked then
  begin
    FChecked := nValue;
    UpdatePicture(InHotRect(GetMousePos));
  end;
end;

procedure TImageButton.SetPicDisable(nValue: TPicture);
begin
  FPicDisable.Assign(nValue);
  if FPicActive = FPicDisable then
    FPicActive := nil;
  UpdatePicture(InHotRect(GetMousePos));
end;

procedure TImageButton.SetPicDown(nValue: TPicture);
begin
  FPicDown.Assign(nValue);
  if FPicActive = FPicDown then
    FPicActive := nil;
  UpdatePicture(InHotRect(GetMousePos));
end;

procedure TImageButton.SetPicEnter(nValue: TPicture);
begin
  FPicEnter.Assign(nValue);
  if FPicActive = FPicEnter then
    FPicActive := nil;
  UpdatePicture(InHotRect(GetMousePos));
end;

procedure TImageButton.SetPicNormal(nValue: TPicture);
begin
  FPicNormal.Assign(nValue);
  if FPicActive = FPicNormal then
    FPicActive := nil;
  UpdatePicture(InHotRect(GetMousePos));
end;

end.

