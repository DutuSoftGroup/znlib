unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, StdCtrls, ULibFun, ULibDLL, run_CommonA;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    procedure ToolButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ToolButton12Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure ToolButton14Click(Sender: TObject);
    procedure ToolButton15Click(Sender: TObject);
    procedure ToolButton16Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  gPath: string;

implementation

{$R *.dfm}

procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  Data_ShowBackup(Application, Screen, '����', '', '');
end;

procedure TForm1.ToolButton2Click(Sender: TObject);
begin
  Data_ShowRestore(Application, Screen, '�ָ�', '', '');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  InitSystemEnvironment;
  LoadFormConfig(Self);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveformConfig(Self);
end;

procedure TForm1.ToolButton3Click(Sender: TObject);
begin
  Process_ShowForm(Application, Screen, '���Խ��ȴ���', 100);
end;

procedure TForm1.ToolButton4Click(Sender: TObject);
begin
  Process_CloseForm;  
end;

procedure TForm1.ToolButton5Click(Sender: TObject);
var n: integer;
    s: string;
begin
  n := random(100);
  s := 'Value = ' + inttostr(n);
  Process_SetHint(PChar(s));
  Process_SetPos(n);
end;

procedure TForm1.ToolButton6Click(Sender: TObject);
begin
  PopMsg_Init(Application, Screen);
end;

procedure TForm1.ToolButton7Click(Sender: TObject);
begin
  PopMsg_Free;
end;

procedure TForm1.ToolButton8Click(Sender: TObject);
begin
  PopMsg_ShowMsg('��ʾ����', '����');
end;

procedure TForm1.ToolButton9Click(Sender: TObject);
var nBuf: PChar;
begin
  nBuf := AllocMem(255);
  StrPCopy(nBuf, 'hello, text');
  if Dlg_InputBox(Application, Screen, '����������:', nBuf, 255) then
       ShowDlg(nBuf, 'hint')
  else ShowDlg('Cancel', '');
  FreeMem(nBuf);
end;

procedure TForm1.ToolButton10Click(Sender: TObject);
var nBuf: PChar;
begin
  nBuf := AllocMem(13);
  StrPCopy(nBuf, 'hello, text');
  if Dlg_InputPWDBox(Application, Screen, '����������:', nBuf, 12) then
       ShowDlg(nBuf, 'hint')
  else ShowDlg('Cancel', '');
  FreeMem(nBuf);
end;

procedure TForm1.ToolButton11Click(Sender: TObject);
begin
  if Data_ShowBackup(Application, Screen, '�а��칫', PChar(gPath), PChar(gPath)) then
       ShowDlg('�������', '')
  else ShowDlg('�жϻ��˳�', '');
end;

procedure TForm1.ToolButton12Click(Sender: TObject);
begin
  if Data_ShowRestore(Application, Screen, '�а��칫', PChar(gPath), PChar(gPath)) then
       ShowDlg('��ԭ���', '')
  else ShowDlg('�жϻ��˳�', '');
end;

procedure TForm1.ToolButton13Click(Sender: TObject);
begin
  Zip_SetParam( Application, Screen );
  if Zip_ZipFile('����ѹ���ļ�,���Ժ�...', 'c:\a.chm', 'c:\a.zip') then
     ShowDlg('ѹ�����')
  else ShowDlg('�жϻ��쳣');
end;

procedure TForm1.ToolButton14Click(Sender: TObject);
begin
  Zip_SetParam( Application, Screen );
  if Zip_UnZipFile( '���ڽ�ѹ���ļ�,���Ժ�...', 'c:\a.zip', 'c:\b.chm') then
     ShowDlg('��ѹ�����')
  else ShowDlg('�жϻ��쳣');
end;

procedure TForm1.ToolButton15Click(Sender: TObject);
var nFrom,nDest: TFileStream;
begin
  Zip_SetParam( Application, Screen );
  nFrom := TFileStream.Create('c:\a.chm', fmOpenRead);
  nDest := TFileStream.Create('c:\s.zip', fmCreate);
  if Zip_ZipStream( '����ѹ��������,���Ժ�...', nFrom, nDest) then
       ShowDlg('ѹ�����')
  else ShowDlg('�жϻ��쳣');

  nFrom.Free; nDest.Free;
end;

procedure TForm1.ToolButton16Click(Sender: TObject);
var nFrom,nDest: TFileStream;
begin
  Zip_SetParam( Application, Screen );
  nFrom := TFileStream.Create('c:\s.zip', fmOpenRead);
  nDest := TFileStream.Create('c:\s.chm', fmCreate);

  if Zip_UnZipStream('���ڽ�ѹ��������,���Ժ�...', nFrom, nDest) then
       ShowDlg('��ѹ�����')
  else ShowDlg('�жϻ��쳣');

  nFrom.Free; nDest.Free;
end;

end.
 