{*******************************************************************************
  ����: dmzn 2007-05-17
  ����: �ṩ�ļ��������ݵ�ѹ��,��ѹ���ӿ�

  ��ע:
  &.Ϊ��֤���ȴ������������ں�,����ʹ��Zip_SetParam����ȫ�ֵ�Application����.
  &.2007-06-29
  ���Zip_HasZipped����,�����ж������Ƿ��Ѿ�ѹ����.

  ����: ����Ԫ����Դ��,����/��ҵ�����ʹ��,�����뱣���˴���˵������.�����
  �Ա���Ԫ���˺����޸�,���ʼ�֪ͨ��,лл!
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
    //����

    procedure ZipFile(const nSource,nDest: string);
    procedure UnZipFile(const nSource,nDest: string);
    //ѹ��&��ѹ��
  public
    { Public declarations }
  end;

procedure Zip_SetParam(const nApp: TApplication; const nScreen: TScreen); stdcall;
//���ò���

function Zip_HasZipped(const nStream: TStream): Boolean; stdcall;
//����nStream�Ƿ�ѹ����

function Zip_ZipFile(const nTitle,nSource,nDest: PChar;
 const nZipLevel: TZCompressionLevel): Boolean; stdcall;
//ѹ���ļ�nSource,�����nDest

function Zip_UnZipFile(const nTitle,nSource,nDest: PChar): Boolean; stdcall;
//��ѹ��nSource�ļ�,�����nDest

function Zip_ZipStream(const nTitle: PChar; const nSource,nDest: TStream;
 const nZipLevel: TZCompressionLevel): Boolean; stdcall;
//ѹ����nStream

function Zip_UnZipStream(const nTitle: PChar;
 const nSource,nDest: TStream): Boolean; stdcall;
//��ѹ����nStream

procedure Zip_CloseZip;
//�رմ���

implementation

{$R *.dfm}
var gForm: TznProcess = nil;

//Desc: ���ò���
procedure Zip_SetParam;
begin
  if Assigned(nApp) then Application := nApp;
  if Assigned(nScreen) then Screen := nScreen;
end;

//Desc: ����nStream�Ƿ�ѹ����
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

//Desc: ѹ���ļ�
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

//Desc: ��ѹ���ļ�
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

//Desc: ѹ����
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

//Desc: ��ѹ����
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

{--------------------------------- �������ͷ� ---------------------------------}
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
  //ֻ��ѹ���ļ���û����������ʱFFileName <> ''
end;

{---------------------------------- �ƶ����� ----------------------------------}
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

{---------------------------------- ������� ----------------------------------}
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
  ��ע:
  &.ѹ����ʱFFileNameΪ��,ѹ���ļ�ʱFFileNameΪĿ���ļ�·��.
  &.ѹ����������ʱ,�رմ��彫���ᴥ��ZipEnd�¼�.
  &.���Լ���FfileName <> '',��ʾѹ���ļ���û����������,�ڴ���
  �ر��¼���ɾ��δ��ɵ�Ŀ���ļ�
  ----------------------------------------------------------------}
end;

//Desc: ѹ���ļ�
procedure TznProcess.ZipFile(const nSource, nDest: string);
begin
  FFileName := nDest;
  FFrom := TFileStream.Create(nSource, fmOpenRead or fmShareDenyNone);
  FDest := TFileStream.Create(nDest, fmCreate);

  FDest.Size := 0;
  FZnZip.ZipStream(FFrom, FDest);
end;

//Desc: ��ѹ���ļ�
procedure TznProcess.UnZipFile(const nSource, nDest: string);
begin
  FFileName := nDest;
  FFrom := TFileStream.Create(nSource, fmOpenRead or fmShareDenyNone);
  FDest := TFileStream.Create(nDest, fmCreate);

  FDest.Size := 0;
  FZnZip.UnZipStream(FFrom, FDest);
end;

end.
