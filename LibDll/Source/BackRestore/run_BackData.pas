{*******************************************************************************
  ����: dmzn 2007-02-02
  ����: ����(�ļ�)���ݴ���
*******************************************************************************}
unit run_BackData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ZnZip, ZnCRC, bsSkinManager, bsSkinData, BusinessSkinForm,
  bsSkinCtrls, jpeg, ExtCtrls, StdCtrls, bsSkinBoxCtrls, Mask;

type
  TfBackData = class(TForm)
    ZnCRC1: TZnCRC;
    ZnZip1: TZnZip;
    Image1: TImage;     
    Memo1: TbsSkinMemo;
    PBar1: TbsSkinGauge;
    Labe3: TbsSkinStdLabel;
    BtnBack: TbsSkinButton;
    BtnNext: TbsSkinButton;
    BtnExit: TbsSkinButton;
    Bevel1: TbsSkinBevel;
    wPage: TbsSkinNotebook;
    Panel1: TbsSkinPaintPanel;
    MainLabel1: TbsSkinStdLabel;
    Hint1: TbsSkinStdLabel;
    BtnAbout: TbsSkinButtonLabel;
    Label1: TbsSkinStdLabel;
    SEdit1: TbsSkinEdit;
    Label2: TbsSkinStdLabel;
    DEdit1: TbsSkinEdit;
    Group2: TbsSkinGroupBox;
    Radio2: TbsSkinCheckRadioBox;
    Radio1: TbsSkinCheckRadioBox;
    Radio3: TbsSkinCheckRadioBox;
    Group1: TbsSkinGroupBox;
    Check1: TbsSkinCheckRadioBox;
    Check2: TbsSkinCheckRadioBox;
    Check3: TbsSkinCheckRadioBox;
    Group3: TbsSkinGroupBox;
    Label3: TbsSkinStdLabel;
    Label4: TbsSkinStdLabel;
    HintLabel1: TbsSkinStdLabel;
    PEdit1: TbsSkinPasswordEdit;
    PEdit2: TbsSkinPasswordEdit;
    bsData1: TbsSkinData;
    SkinManager1: TSkinManager;
    bsForm1: TbsBusinessSkinForm;
    bsSkin1: TbsCompressedStoredSkin;
    procedure Panel1PanelPaint(Cnvs: TCanvas; R: TRect);
    procedure BtnBackClick(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SEdit1ButtonClick(Sender: TObject);
    procedure DEdit1ButtonClick(Sender: TObject);
    procedure ZnCRC1Begin(const nMax: Cardinal);
    procedure ZnCRC1Process(const nHasDone: Cardinal);
    procedure ZnCRC1Message(const nMsg: String);
    procedure ZnCRC1End(const nCRC: Cardinal; const IsNormal: Boolean);
    procedure ZnZip1Begin(const nMax: Cardinal);
    procedure ZnZip1Process(const nHasDone: Cardinal);
    procedure ZnZip1End(const nNormal: Boolean; nZipRate: Single);
    procedure Radio1Click(Sender: TObject);
    procedure Check2Click(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
  private
    { Private declarations }
    FSDir,FDDir: string;
    //Դ&Ŀ��Ŀ¼
    FSFile,FDFile: string;
    //Դ&Ŀ���ļ�
    FCRC: Cardinal;
    //У��ֵ
    procedure DoStep1(const nBack: Boolean);
    procedure DoStep2(const nBack: Boolean);
    procedure DoStep3(const nBack: Boolean);
    procedure DoStep4(const nBack: Boolean);
    procedure DoStep5(const nBack: Boolean);
    //ҳ����ת
    procedure SetSourceAndDest(const nSource,nDest: string);
    //���ñ���Դ��Ŀ��
  public
    { Public declarations }
  end;

function Data_ShowBackup(const nTitle,nSource,nDest: PChar): Boolean; stdcall;
procedure Data_CloseBackForm;
//��ں���

implementation

{$R *.dfm}
uses
  IniFiles, ZLibEx, UDataFile, ULibFun, run_CommonA, run_CommonB, run_Const, 
  run_DataRes;

var
  gForm: TfBackData = nil;

//Desc: ��ʾ���ݴ���
function Data_ShowBackup;
begin
  if not Assigned(gForm) then
  begin
    gForm := TfBackData.Create(Application);
    gForm.Caption := StrPas(nTitle);
  end;

  gForm.SetSourceAndDest(nSource, nDest);
  Result := gForm.ShowModal = mrOK;
  FreeAndNil(gForm);
end;

//Desc: �ͷű���
procedure Data_CloseBackForm;
begin
  FreeAndNil(gForm);
end;

//Date: 2007-02-02
//Desc: ����Դ�ļ���Ŀ���ļ�
procedure TfBackData.SetSourceAndDest(const nSource, nDest: string);
begin
  if FileExists(nSource) then
  begin
    SEdit1.Text := nSource;
    DEdit1.Text := nDest;
    DoStep1(False);
  end;
end;

{---------------------------------- �������ͷ� --------------------------------}
procedure TfBackData.FormCreate(Sender: TObject);
var nStr: string;
    nIni: TIniFile;
begin
  InitSystemEnvironment;
  DoStep1(True);

  nIni := TIniFile.Create(gConfigFile);
  try
    FSDir := nIni.ReadString(Name, 'SourceDir', gPath);
    FDDir := nIni.ReadString(Name, 'DestDir', gPath);
    LoadFormConfig(Self, '', nIni);
  finally
    nIni.Free;
  end;

  if GetSkinFile(nStr) then
  begin
    bsData1.LoadFromCompressedFile(nStr);
  end;
end;

procedure TfBackData.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gConfigFile);
  try
    nIni.WriteString(Name, 'SourceDir', FSDir);
    nIni.WriteString(Name, 'DestDir', FDDir);
    SaveFormConfig(Self, '', nIni);
  finally
    nIni.Free;
  end;

  if ZnZip1.Busy then
  begin
    ZnZip1.StopZnZip;
    if FileExists(ZnZip1.DestFile) then DeleteFile(ZnZip1.DestFile);
  end;
end;

procedure TfBackData.BtnExitClick(Sender: TObject);
begin
  if ZnZip1.Busy or ZnCRC1.IsBusy then
    if not QueryDlg(Back_IsBusy) then Exit;
  ModalResult := mrCancel;
end;

{----------------------------------- ������� ---------------------------------}
procedure TfBackData.Panel1PanelPaint(Cnvs: TCanvas; R: TRect);
begin
  Cnvs.Brush.Color := clWhite;
  Cnvs.FillRect(R);
end;

//Desc: ѹ������
procedure TfBackData.Radio1Click(Sender: TObject);
begin
  case (Sender as TComponent).Tag of
   1: ZnZip1.ZipLevel := zcFastest;
   2: ZnZip1.ZipLevel := zcDefault;
   3: ZnZip1.ZipLevel := zcMax;
  end;
end;

//Desc: Ĭ��ѹ������
procedure TfBackData.Check2Click(Sender: TObject);
begin
  if Check2.Checked then
  begin
    ZnZip1.ZipLevel := zcDefault;
    Radio2.Checked := True;
  end else ZnZip1.ZipLevel := zcNone;
end;

//Desc: ��һ��
procedure TfBackData.BtnBackClick(Sender: TObject);
begin
  case wPage.PageIndex of
   1: DoStep1(True);
   2: DoStep2(True);
   3: DoStep3(True);
   4: DoStep4(True);
  end;
end;

//Desc: ��һ��
procedure TfBackData.BtnNextClick(Sender: TObject);
begin
  case wPage.PageIndex of
   0: DoStep1(False);
   1: DoStep2(False);
   2: DoStep3(False);
   3: DoStep4(False);
   4: DoStep5(False);
  end;
end;

//Desc: ʹ��nDir+nFileName�ķ����ϳ����ļ�·��
function CombineFile(const nDir,nFile: string): string;
begin
  if Copy(nDir, Length(nDir), 1) = '\' then
       Result := nDir + ExtractFileName(nFile)
  else Result := nDir + '\' + ExtractFileName(nFile);
end;

//Desc: ����nDir�ļ���
function CreateDir(const nDir: string): Boolean;
begin
  Result := False;
  if not DirectoryExists(nDir) then
   if not QueryDlg(Back_MakeDir) then Exit;
   try
     if not ForceDirectories(nDir) then Exit;
   except
     ShowMsg(Back_MDError, '��ʾ'); Exit;
   end;

  Result := True;
end;

//Desc: �Ƿ�Ϸ����ļ���
function IsValidFile(const nFile: string): Boolean;
var nExt: string;
begin
  Result := False;
  nExt := ExtractFileExt(nFile);
  if (Length(nExt) > 1) and (nExt[1] = '.') and
     (Pos('.', ExtractFileName(nFile)) > 1) then Result := True;
  //�ļ������Ϸ�:1.û��չ��;2û�ļ���
end;

//Desc: ��һ��ҳ��
procedure TfBackData.DoStep1(const nBack: Boolean);
begin
  if nBack then
  begin
    wPage.PageIndex := 0;
    BtnBack.Enabled := False;
    Hint1.Caption := Back_Welcome; Exit;
  end;

  if FileExists(SEdit1.Text) then
     FSFile := SEdit1.Text else
  begin
    ShowMsg(Back_Source, '��ʾ'); Exit;
  end;

  if Trim(DEdit1.Text) = '' then
  begin
    ShowMsg(Back_Dest, '��ʾ'); Exit;
  end else

  if FileExists(DEdit1.Text) then
     FDFile := DEdit1.Text else
  if IsValidFile(DEdit1.Text) then
  begin
    if CreateDir(ExtractFilePath(DEdit1.Text)) then
         FDFile := Dedit1.Text
    else Exit;
  end else
  if DirectoryExists(DEdit1.Text) then
     FDFile := CombineFile(DEdit1.Text, FSFile) else
  begin
    if CreateDir(DEdit1.Text) then
         FDFile := CombineFile(DEdit1.Text, FSFile)
    else Exit;
  end;

  if File_IsSame(FSFile, FDFile) then
  begin
    ShowMsg(Back_DestErr, '��ʾ'); Exit;
  end;

  if FileExists(FDFile) then
  begin
    if not QueryDlg(Back_OverWrite) then Exit;
  end;

  DoStep2(True);
  //��ҳ��ת
end;

//Desc: �ڶ���ҳ��
procedure TfBackData.DoStep2(const nBack: Boolean);
begin
  if nBack then
  begin
   wPage.PageIndex := 1;
   BtnBack.Enabled := True;
   Hint1.Caption := Back_Options; Exit;
  end;

  if Check2.Checked or Check3.Checked then
  begin
    if Check2.Checked then
    begin
      Group2.Enabled := True;
      Group2.Caption := 'ѹ��ǿ��';
    end else
    begin
      Group2.Enabled := False;
      Group2.Caption := 'ѹ��ǿ��:(��)';
    end;

    if Check3.Checked then
    begin
      Group3.Enabled := True;
      Group3.Caption := '����';
    end else
    begin
      Group3.Enabled := False;
      Group3.Caption := '����:(��)';
    end;

    DoStep3(True);
    //��ת��������ҳ
  end else DoStep4(True);
  //��ת���ݽ���ҳ
end;

//Desc: ������ҳ��
procedure TfBackData.DoStep3(const nBack: Boolean);
begin
  if nBack then
  begin
    if Check2.Checked or Check3.Checked then
    begin
      wPage.PageIndex := 2;
      Hint1.Caption := Back_Passwod;
    end else DoStep2(True);

    Exit;
  end;

  if Group3.Enabled then
   if (PEdit1.Text = '') or (PEdit1.Text <> PEdit2.Text) then
   begin
     ShowMsg(Back_InputPWD, '��ʾ'); Exit;
   end;

  DoStep4(True);
  //��ת������ҳ
end;

//Desc: ���ĸ�ҳ��
procedure TfBackData.DoStep4(const nBack: Boolean);
begin
  if nBack then
  begin
    wPage.PageIndex := 3;
    BtnNext.Caption := '��һ��';
    Hint1.Caption := Back_MarkStr;
  end else DoStep5(True);
end;

//Desc: �����ҳ��
procedure TfBackData.DoStep5(const nBack: Boolean);
begin
  if nBack then
  begin
    PBar1.Value := 0;
    BtnNext.Caption := '��ʼ';
    HintLabel1.Caption := '������ʾ:';

    wPage.PageIndex := 4;
    Hint1.Caption := Back_StaBack; Exit;
  end;

  BtnBack.Enabled := False;
  BtnNext.Enabled := False;
  //������ť
  if Check1.Checked then
  begin
    HintLabel1.Caption := CRC_Start;
    ZnCRC1.CRC_File(FSFile);
  end else
  begin
    HintLabel1.Caption := Zip_Start;
    ZnZip1.SourceFile := FSFile;
    ZnZip1.DestFile := FDFile;
    ZnZip1.ZipFile;
  end;
end;

//Desc: ѡ�񱸷��ļ�
procedure TfBackData.SEdit1ButtonClick(Sender: TObject);
begin
  with TOpenDialog.Create(Application) do
  begin
    Title := '�����ļ�';
    Filter := '�����ļ�|*.*';
    InitialDir := FSDir;

    if Execute then
    begin
      SEdit1.Text := FileName; FSDir := ExtractFilePath(FileName);
    end;
    Free;
  end;
end;

//Desc: ѡ�񱸷ݴ��λ��
procedure TfBackData.DEdit1ButtonClick(Sender: TObject);
begin
  with TOpenDialog.Create(Application) do
  begin
    Title := '����λ��';
    Filter := '�����ļ�|*.*';
    InitialDir := FDDir;

    if Execute then
    begin
      DEdit1.Text := FileName; FDDir := ExtractFilePath(FileName);
    end;
    Free;
  end;
end;

{----------------------------------- CRC --------------------------------------}
procedure TfBackData.ZnCRC1Begin(const nMax: Cardinal);
begin
  PBar1.MaxValue := nMax;
  HintLabel1.Caption := CRC_Running;
end;

procedure TfBackData.ZnCRC1Process(const nHasDone: Cardinal);
begin
  PBar1.Value := nHasDone;
end;

procedure TfBackData.ZnCRC1Message(const nMsg: String);
begin
  ShowDlg(nMsg, 'У��');
end;

procedure TfBackData.ZnCRC1End(const nCRC: Cardinal;
  const IsNormal: Boolean);
begin
  if IsNormal then
  begin
    FCRC := nCRC;
    HintLabel1.Caption := Zip_Start;

    ZnZip1.SourceFile := FSFile;
    ZnZip1.DestFile := FDFile;
    ZnZip1.ZipFile;
  end else ShowMsg('�ļ�У��δ���', '��ʾ');
end;

{------------------------------------- Zip ------------------------------------}
procedure TfBackData.ZnZip1Begin(const nMax: Cardinal);
begin
  PBar1.MaxValue := nMax;
  HintLabel1.Caption := Zip_Running;
end;

procedure TfBackData.ZnZip1Process(const nHasDone: Cardinal);
begin
  PBar1.Value := nHasDone;
end;

procedure TfBackData.ZnZip1End(const nNormal: Boolean; nZipRate: Single);
var nSec: string;
    nIni: TDataFile;
begin
  if not nNormal then
  begin
    ShowMsg('ѹ��������ֹ', '��ʾ');
    Exit;
  end;

  nIni := TDataFile.Create(ExtractFilePath(FDFile) + Back_IndexFile);
  try
    nIni.CodeKey := sCodeKey;
    nSec := FloatToStr(Now);
    //��������
    nIni.WriteBoolean(nSec, 'CRCOk', Check1.Checked);
    nIni.WriteInteger(nSec, 'CRC', FCRC);
    //У��ֵ
    nIni.WriteBoolean(nSec, 'PWDOk', Check3.Checked);
    nIni.WriteString(nSec, 'PWD', PEdit1.Text);
    //��������
    nIni.WriteDouble(nSec, 'ZipRate', nZipRate);
    //ѹ������
    nIni.WriteString(nSec, 'Source', FSFile);
    nIni.WriteString(nSec, 'Dest', FDFile);
    //�ļ���Ϣ
    nIni.WriteStrings(nSec, 'Mark', Memo1.Lines);
    //��ע��Ϣ
  finally
    nIni.Free;
  end;

  ShowMsg('���ݳɹ�', '��ʾ');
  ModalResult := MrOK;
end;

end.
