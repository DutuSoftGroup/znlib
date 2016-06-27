{*******************************************************************************
  作者: dmzn 2007-05-17
  描述: 提供文件和流数据的压缩,解压缩接口

  备注:
  &.为保证进度窗体与主程序融合,首先使用Zip_SetParam设置全局的Application对象.
  &.2007-06-29
  添加Zip_HasZipped方法,用于判断数据是否已经压缩过.

  声明: 本单元公开源码,个人/商业可免费使用,不过请保留此处的说明文字.如果你
  对本单元作了合理修改,请邮件通知我,谢谢!
*******************************************************************************}
unit run_Process;

interface

uses
  Windows, Messages, Graphics, Forms, Gauges, Controls, StdCtrls, SysUtils,
  Classes, ExtCtrls, Buttons, run_Zip, ZlibEx;

type
  TznProcess = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Gauge1: TGauge;
    BtnExit: TSpeedButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FOx,FOy: integer;
    FCanMove: Boolean;
    FFileName: string;
    FFrom,FDest: TFileStream;

    FZnZip: TZnZip;
    procedure DoZipBegin(const nMax: Cardinal);
    procedure DoZipProcess(const nHasDone: Cardinal);
    procedure DoZipEnd(const nNormal: boolean; nZipRate: Single);
    //进度

    procedure ZipFile(const nSource,nDest: string);
    procedure UnZipFile(const nSource,nDest: string);
    //压缩&解压缩
  public
    { Public declarations }
  end;

procedure Zip_SetParam(const nApp: TApplication; const nScreen: TScreen); stdcall;
//设置参数

function Zip_HasZipped(const nStream: TStream): Boolean; stdcall;
//测试nStream是否压缩过

function Zip_ZipFile(const nTitle,nSource,nDest: PChar;
 const nZipLevel: TZCompressionLevel): Boolean; stdcall;
//压缩文件nSource,存放至nDest

function Zip_UnZipFile(const nTitle,nSource,nDest: PChar): Boolean; stdcall;
//解压缩nSource文件,存放至nDest

function Zip_ZipStream(const nTitle: PChar; const nSource,nDest: TStream;
 const nZipLevel: TZCompressionLevel): Boolean; stdcall;
//压缩流nStream

function Zip_UnZipStream(const nTitle: PChar;
 const nSource,nDest: TStream): Boolean; stdcall;
//解压缩流nStream

procedure Zip_CloseZip;
//关闭窗口

implementation

{$R *.dfm}
var gForm: TznProcess = nil;

//Desc: 设置参数
procedure Zip_SetParam;
begin
  if Assigned(nApp) then Application := nApp;
  if Assigned(nScreen) then Screen := nScreen;
end;

//Desc: 测试nStream是否压缩过
function Zip_HasZipped(const nStream: TStream): Boolean;
var nRec: TZStreamRec;
    nIn,nOut: array[0..1024] of Char;
begin
  Result := False;
  FillChar(nRec, SizeOf(nRec), #0);
  if InflateInit_(nRec, ZLIB_VERSION, SizeOf(TZStreamRec)) > -1 then
  try
    nRec.next_in := nIn;
    nRec.avail_in := nStream.Read(nIn, 1024);

    nRec.next_out := nOut;
    nRec.avail_out := 1024;
    Result := Inflate(nRec, 0) > -1;
  finally
    inflateEnd(nRec);
  end;
end;

//Desc: 压缩文件
function Zip_ZipFile;
begin
  Result := False;
  if not Assigned(gForm) then
    gForm := TznProcess.Create(Application);
    
  if not gForm.FZnZip.Busy then
  try
    gForm.FZnZip.ZipLevel := nZipLevel;
    gForm.Label1.Caption := StrPas(nTitle);
        
    gForm.ZipFile(nSource, nDest);
    Result := gForm.ShowModal = mrOK;
  finally
    FreeAndNil(gForm);
  end;
end;

//Desc: 解压缩文件
function Zip_UnZipFile;
begin
  Result := False;
  if not Assigned(gForm) then
    gForm := TznProcess.Create(Application);

  if not gForm.FZnZip.Busy then
  try
    gForm.Label1.Caption := StrPas(nTitle);
    gForm.UnZipFile(nSource, nDest);
    Result := gForm.ShowModal = mrOK;
  finally
    FreeAndNil(gForm);
  end;
end;

//Desc: 压缩流
function Zip_ZipStream;
begin
  Result := False;
  if not Assigned(gForm) then
    gForm := TznProcess.Create(Application);

  if not gForm.FZnZip.Busy then
  try
    gForm.FFileName := '';
    gForm.Label1.Caption := StrPas(nTitle);

    gForm.FZnZip.ZipLevel := nZipLevel;
    gForm.FZnZip.ZipStream(nSource, nDest);
    Result := gForm.ShowModal = mrOK;
  finally
    FreeAndNil(gForm);
  end;
end;

//Desc: 解压缩流
function Zip_UnZipStream;
begin
  Result := False;
  if not Assigned(gForm) then
    gForm := TznProcess.Create(Application);

  if not gForm.FZnZip.Busy then
  try
    gForm.FFileName := '';
    gForm.Label1.Caption := StrPas(nTitle);

    gForm.FZnZip.UnZipStream(nSource, nDest);
    Result := gForm.ShowModal = mrOK;
  finally
    FreeAndNil(gForm);
  end;
end;

procedure Zip_CloseZip;
begin
  if Assigned(gForm) then FreeAndNil(gForm);
end;

{--------------------------------- 创建与释放 ---------------------------------}
procedure TznProcess.FormCreate(Sender: TObject);
begin
  AlphaBlend := True;
  AlphaBlendValue := 210;
  BorderStyle := bsNone;

  Color := clMoneyGreen;
  FormStyle := fsStayOnTop;
  Position := poDesktopCenter;

  FZnZip := TZnZip.Create(Self);
  FZnZip.OnBegin := DoZipBegin;
  FZnZip.OnProcess := DoZipProcess;
  FZnZip.OnEnd := DoZipEnd;
end;

procedure TznProcess.FormDestroy(Sender: TObject);
begin
  gForm := nil;
  FZnZip.Free;
  FFrom.Free; FDest.Free;
  if FileExists(FFileName) then DeleteFile(FFileName);
  //只有压缩文件且没有正常结束时FFileName <> ''
end;

{---------------------------------- 移动窗体 ----------------------------------}
procedure TznProcess.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FCanMove := True;
    FOx := X; FOy := Y;
  end;
end;

procedure TznProcess.Panel1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if FCanMove then
  begin
    Top := Top + Y - FOy;
    Left := Left + X - FOx;
  end;
end;

procedure TznProcess.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FCanMove := False;
end;

{---------------------------------- 窗体过程 ----------------------------------}
procedure TznProcess.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TznProcess.DoZipBegin(const nMax: Cardinal);
begin
  Gauge1.MaxValue := nMax;
end;

procedure TznProcess.DoZipProcess(const nHasDone: Cardinal);
begin
  Gauge1.Progress := nHasDone;
end;

procedure TznProcess.DoZipEnd(const nNormal: boolean; nZipRate: Single);
begin
  FreeAndNil(FFrom);
  FreeAndNil(FDest);
  Application.ProcessMessages; Sleep(1000);
  
  if nNormal then
     ModalResult := mrOK else
  begin
    if FileExists(FFileName) then
       DeleteFile(FFileName);
    ModalResult := mrCancel;
  end;

  FFileName := '';
  {------------------------- +Dmzn: 2007-05-18 --------------------
  备注:
  &.压缩流时FFileName为空,压缩文件时FFileName为目标文件路径.
  &.压缩正在运行时,关闭窗体将不会触发ZipEnd事件.
  &.所以假若FfileName <> '',表示压缩文件且没有正常结束,在窗体
  关闭事件里删除未完成的目标文件
  ----------------------------------------------------------------}
end;

//Desc: 压缩文件
procedure TznProcess.ZipFile(const nSource, nDest: string);
begin
  FFileName := nDest;
  FFrom := TFileStream.Create(nSource, fmOpenRead or fmShareDenyNone);
  FDest := TFileStream.Create(nDest, fmCreate);

  FDest.Size := 0;
  FZnZip.ZipStream(FFrom, FDest);
end;

//Desc: 解压缩文件
procedure TznProcess.UnZipFile(const nSource, nDest: string);
begin
  FFileName := nDest;
  FFrom := TFileStream.Create(nSource, fmOpenRead or fmShareDenyNone);
  FDest := TFileStream.Create(nDest, fmCreate);

  FDest.Size := 0;
  FZnZip.UnZipStream(FFrom, FDest);
end;

end.
