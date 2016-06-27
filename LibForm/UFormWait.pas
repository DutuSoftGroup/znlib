{*******************************************************************************
  作者: dmzn@ylsoft.com 2007-09-20
  描述: 数据读取时的等待窗口
*******************************************************************************}
unit UFormWait;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, ExtCtrls, Controls, Forms,
  StdCtrls;

type
  TfWaitForm = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FMsg: string;
    FIdx,FLow,FMax: integer;
    procedure WMTimer(var nMsg: TMessage); message WM_Timer;
  public
    { Public declarations }
    property HintMsg: string read FMsg write FMsg;
  end;

//------------------------------------------------------------------------------
procedure ShowWaitForm(const nMsg: string; const nShow: Boolean = True); overload;
//非阻塞
procedure ShowWaitForm(const nPForm: TForm; const nMsg: string = '';
 const nRefresh: Boolean = False); overload;
//阻塞模式
procedure CloseWaitForm;
//入口函数

implementation

{$R *.dfm}
{$R bg.RES}

const
  cLabel : array [0..6] of string = (
           '.%s.',
           '<< .%s. >>',
           '<<<< .%s. >>>>',
           '<<<<<< .%s. >>>>>>',
           '<<<<<<<< .%s. >>>>>>>>',
           '<<<<<<<<<< .%s. >>>>>>>>>>',
           '<<<<<<<<<<<< .%s. >>>>>>>>>>>>');

type
  TWaitThread = class(TThread)
  private
    FMsg: string;
    FOwner: TForm;
    FLow,FMax,FIdx: integer;

    FImage: TBitMap;
    FCanvas: TCanvas;
    FImageRect: TRect;
  protected
    procedure PaintText;
    procedure Execute; override;
  public
    constructor Create(AOwner: TForm);
    destructor Destroy; override;
    property HintMsg: string read FMsg write FMsg;
  end;

var
  gForm: TfWaitForm = nil;
  gThread: TWaitThread = nil;
  //全局使用

//------------------------------------------------------------------------------
//Date: 2007-09-21
//Parm: 父窗体;提示消息;刷新
//Desc: 在nPForm的中间显示一个等待窗体
procedure ShowWaitForm(const nPForm: TForm; const nMsg: string;
  const nRefresh: Boolean);
begin
  if nRefresh then
    Application.ProcessMessages;
  //update ui
  
  if not Assigned(gThread) then
    gThread := TWaitThread.Create(nPForm);
  gThread.HintMsg := nMsg;
end;

//Date: 2007-09-20
//Desc: 弹出等待对话框
procedure ShowWaitForm(const nMsg: string; const nShow: Boolean = True); overload;
begin
  if not Assigned(gForm) then
    gForm := TfWaitForm.Create(Application);
  if nMsg <> '' then gForm.HintMsg := nMsg;

  gForm.FIdx := gForm.FLow;
  gForm.Label1.Caption := Format(cLabel[gForm.FIdx], [nMsg]);

  if nShow then
       gForm.Show
  else gForm.Hide;
  Application.ProcessMessages;
end;  

//Date: 2007-09-21
//Desc: 释放等待窗体
procedure CloseWaitForm;
begin
  if Assigned(gThread) then
  begin
    gThread.Terminate;
    gThread.WaitFor;
    FreeAndNil(gThread);
  end;

  if Assigned(gForm) then
  begin
    FreeAndNil(gForm);
    Application.ProcessMessages;
  end;
end;

//------------------------------------------------------------------------------
constructor TWaitThread.Create;
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FLow := Low(cLabel);
  FMax := High(cLabel);

  FCanvas := TCanvas.Create;
  FCanvas.Handle := GetDC(0);

  FImage := TBitMap.Create;
  FImage.Handle := LoadBitmap(Hinstance, 'BG');

  FImageRect.Left := (FOwner.ClientWidth - FImage.Width ) div 2;
  FImageRect.Top := (FOwner.ClientHeight - FImage.Height) div 2;
  FImageRect.Right := FImageRect.Left + FImage.Width;
  FImageRect.Bottom := FImageRect.Top + FImage.Height;

  FImageRect.TopLeft := FOwner.ClientToScreen(FImageRect.TopLeft);
  FImageRect.BottomRight := FOwner.ClientToScreen(FImageRect.BottomRight);
end;

//Desc: 绘制后台内容
procedure TWaitThread.PaintText;
var nStr: string;
    nH,nW: integer;
begin
  nStr := Format(cLabel[FIdx], [FMsg]);
  Inc(FIdx);
  if FIdx > FMax then FIdx := FLow;

  nW := FCanvas.TextWidth(nStr);
  nH := FCanvas.TextHeight(nStr);

  SetBKMode(FCanvas.Handle, Transparent);
  FCanvas.TextOut((FImageRect.Right + FImageRect.Left - nW) div 2,
                  (FImageRect.Bottom + FImageRect.Top - nH) div 2, nStr);
  //输出文本
end;

//Desc: 绘制
procedure TWaitThread.Execute;
begin
  FIdx := FLow;
  FCanvas.Font.Assign(FOwner.Font);
  FCanvas.Font.Color := clWhite;

  FCanvas.StretchDraw(FImageRect, FImage);
  PaintText;
  //........

  while not Terminated do
  begin
    Sleep(500);
    if GetForegroundWindow = FOwner.Handle then
    begin
      FCanvas.StretchDraw(FImageRect, FImage);
      PaintText;
    end;
  end;
  
  RedrawWindow(0, @FImageRect, 0, RDW_INVALIDATE or RDW_ALLCHILDREN);
  //清理屏幕
end;

destructor TWaitThread.Destroy;
begin
  FImage.Free;
  FCanvas.Free;
  inherited;
end;

//------------------------------------------------------------------------------
procedure TfWaitForm.FormCreate(Sender: TObject);
begin
  FLow := Low(cLabel);
  FMax := High(cLabel);

  DoubleBuffered := True;
  Image1.Picture.Bitmap.Handle := LoadBitmap(Hinstance, 'BG');

  FIdx := FLow;
  SetTimer(Handle, 55, 500, nil);
end;

procedure TfWaitForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  gForm := nil;
  Action := caFree;
  KillTimer(Handle, 55);
end;

procedure TfWaitForm.WMTimer(var nMsg: TMessage);
begin
  FIdx := FIdx + 1;
  if FIdx > FMax then FIdx := FLow;
  Label1.Caption := Format(cLabel[FIdx], [FMsg]);
end;

end.
