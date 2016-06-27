{*******************************************************************************
  ����: dmzn 2007-02-02
  ����: ����(�ļ�)�ָ�����
*******************************************************************************}
unit run_ResData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bsSkinCtrls, ComCtrls, ImgList, ZnZip, ZnCRC, bsSkinManager,
  bsSkinData, BusinessSkinForm, jpeg, ExtCtrls, StdCtrls, bsSkinBoxCtrls,
  Mask;

type
  TfResData = class(TForm)
    ZnCRC1: TZnCRC;
    ZnZip1: TZnZip;
    Image1: TImage;
    MEdit1: TbsSkinEdit;
    MEdit3: TbsSkinEdit;
    MEdit4: TbsSkinEdit;
    MEdit2: TbsSkinEdit;
    Panel3: TbsSkinPanel;
    MEdit5: TbsSkinMemo;
    MLabel1: TbsSkinStdLabel;
    MLabel3: TbsSkinStdLabel;
    MLabel4: TbsSkinStdLabel;
    MLabel2: TbsSkinStdLabel;
    MLabel5: TbsSkinStdLabel;
    SBar2: TbsSkinScrollBar;
    PEdit1: TbsSkinPasswordEdit;
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
    ImageList1: TImageList;
    Panel2: TbsSkinPanel;
    List1: TbsSkinListView;
    SBar1: TbsSkinScrollBar;
    HintLabel1: TbsSkinStdLabel;
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
    procedure BtnExitClick(Sender: TObject);
    procedure List1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FSDir,FDDir: string;
    //Դ&Ŀ��Ŀ¼
    FSFile,FDFile: string;
    //Դ&Ŀ���ļ�
    FCRC: Cardinal;
    //У��ֵ
    FPassword: string;
    //����
    procedure DoStep1(const nBack: Boolean);
    procedure DoStep2(const nBack: Boolean);
    procedure DoStep3(const nBack: Boolean);
    procedure DoStep4(const nBack: Boolean);
    procedure DoStep5(const nBack: Boolean);
    //ҳ����ת
    procedure SetSourceAndDest(const nSource,nDest: string);
    //���ñ���Դ��Ŀ��
    procedure LoadBackList(const nFile: string);
    //���뱸���б�
    procedure LoadMarkInfo(const nFile: string; const nIndex: integer);
    //����������Ϣ    
  public
    { Public declarations }
  end;

function Data_ShowRestore(const nTitle,nIdxFile,nDest: PChar): Boolean; stdcall;
procedure Data_CloseResForm;
//��ں���

implementation

{$R *.dfm}
uses
  IniFiles, ZLibEx, UDataFile, ULibFun, ULibDLL, run_CommonA, run_CommonB,
  run_Const, run_DataRes;

var
  gForm: TfResData = nil;

//Desc: ��ʾ���ݴ���
function Data_ShowRestore;
begin
  if not Assigned(gForm) then
  begin
    gForm := TfResData.Create(Application);
    gForm.Caption := StrPas(nTitle);
  end;

  gForm.SetSourceAndDest(nIdxFile, nDest);
  Result := gForm.ShowModal = mrOK;
  FreeAndNil(gForm);
end;

//Desc: �ͷű���
procedure Data_CloseResForm;
begin
  FreeAndNil(gForm);
end;

//Date: 2007-02-02
//Desc: ����Դ�ļ���Ŀ���ļ�
procedure TfResData.SetSourceAndDest(const nSource, nDest: string);
begin
  if FileExists(nSource) then
  begin
    SEdit1.Text := nSource;
    DEdit1.Text := nDest;
    DoStep1(False);
  end;
end;

{---------------------------------- �������ͷ� --------------------------------}
procedure TfResData.FormCreate(Sender: TObject);
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

procedure TfResData.FormClose(Sender: TObject; var Action: TCloseAction);
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

  if ZnZip1.Busy or ZnCRC1.IsBusy then
  begin
    ZnCRC1.StopCRC;
    ZnZip1.StopZnZip;
    if FileExists(ZnZip1.DestFile) then DeleteFile(ZnZip1.DestFile);
  end;
end;

procedure TfResData.BtnExitClick(Sender: TObject);
begin
  if ZnZip1.Busy or ZnCRC1.IsBusy then
    if not QueryDlg('���ݻ�δ�ָ����,�Ƿ��˳�?') then Exit;
  ModalResult := mrCancel;
end;

{----------------------------------- ������� ---------------------------------}
function FormatFileName(const nStr: string): string;
begin
  Result := ExtractFileName(nStr);
  Result := Copy(Result, 1, Pos('.', Result) - 1);
end;

//Desc: ����nFile���������ļ�
procedure TfResData.LoadBackList(const nFile: string);
var nStr: string;
    nIni: TDataFile;
    nList: TStrings;
    i,nCount: integer;
begin
  nIni := TDataFile.Create(nFile);
  nList := TStringList.Create;
  try
    List1.Clear;
    nIni.CodeKey := sCodeKey;
    nIni.GetSectionNames(nList);
    nCount := nList.Count - 1;

    for i:=0 to nCount do
    with List1.Items.Add do
    begin
      nStr := nIni.ReadString(nList[i], 'Source', '');
      if Trim(nStr) = '' then nStr := 'BackData.Zn';
      Caption := FormatFileName(nStr);
      //��������

      if nIni.ReadBoolean(nList[i], 'CRCOk', False) then
           SubItems.Add(cYes)
      else SubItems.Add(cNo);
      //�Ƿ�У��

      if nIni.ReadBoolean(nList[i], 'PWDOk', False) then
      begin
        ImageIndex := 1;
        SubItems.Add(cYes);
      end else
      begin
        ImageIndex := 0;
        SubItems.Add(cNo);
      end;
      //�Ƿ����
      SubItems.Add(DateTimeToStr(StrToFloat(nList[i])));
      //����
    end;   
  finally
    nList.Free;
    nIni.Free; 
  end;
end;

//Date: 2007-02-08
//Parm: �����ļ�;����
//Desc: ����nFile��nIndex��¼����Ϣ
procedure TfResData.LoadMarkInfo(const nFile: string; const nIndex: integer);
var nIni: TDataFile;
    nList: TStrings;
begin
  if nIndex < 0 then Exit;
  nIni := TDataFile.Create(nFile);
  nList := TStringList.Create;
  try
    nIni.CodeKey := sCodeKey;
    nIni.GetSectionNames(nList);

    if nIndex < nList.Count then
    begin
      FCRC := nIni.ReadInteger(nList[nIndex], 'CRC', 1);
      FPassword := nIni.ReadString(nList[nIndex], 'PWD', 'dmzn');
      
      MEdit1.Text := DateTimeToStr(StrToFloat(nList[nIndex]));
      MEdit2.Text := FloatToStr(Round(nIni.ReadDouble(nList[nIndex], 'ZipRate', 0)));
      MEdit3.Text := nIni.ReadString(nList[nIndex], 'Source', '');
      MEdit4.Text := nIni.ReadString(nList[nIndex], 'Dest', '');;
      nIni.ReadStrings(nList[nIndex], 'Mark', nList);
      MEdit5.Lines.Assign(nList);

      FSFile := ExtractFilePath(FSFile) + ExtractFileName(MEdit4.Text);
      //���������������ļ���ͬһ���ļ�����
    end;
  finally
    nList.Free;
    nIni.Free; 
  end;
end;

procedure TfResData.Panel1PanelPaint(Cnvs: TCanvas; R: TRect);
begin
  Cnvs.Brush.Color := clWhite;
  Cnvs.FillRect(R);
end;

//Desc: ɾ��ָ������
procedure TfResData.List1KeyPress(Sender: TObject; var Key: Char);
var nStr: string;
    nList: TStrings;
    nIni: TDataFile;
begin
  if Lowercase(Key) <> 'd' then Exit;
  if not Assigned(List1.Selected) then Exit;
  if not QueryDlg('ȷ��Ҫɾ��ָ��������?', 'ѯ��') then Exit;

  nIni := TDataFile.Create(SEdit1.Text);
  nList := TStringList.Create;
  try
    nIni.CodeKey := sCodeKey;
    nIni.GetSectionNames(nList);
    if List1.ItemIndex >= nList.Count then Exit;

    nStr := nList[List1.ItemIndex];
    if nIni.ReadBoolean(nStr, 'PWDOk', False) then
    begin
      SetLength(nStr, 11);
      if not Dlg_InputPWDBox(Application, Screen, '�����뱸��ʱ����֤����:',
         PChar(@nStr[1]), 10) then Exit;

      nStr := StrPas(@nStr[1]);
      if nStr <> nIni.ReadString(nList[List1.ItemIndex], 'PWD', '') then
      begin
        ShowMsg('�������,������', '��ʾ'); Exit;
      end;
    end;

    nStr := nList[List1.ItemIndex];
    nStr := nIni.ReadString(nStr, 'Dest', '');
    nStr := ExtractFilePath(SEdit1.Text) + ExtractFileName(nStr);

    if FileExists(nStr) then
    begin
      if not DeleteFile(nStr) then
      begin
        ShowMsg('�޷�ɾ�������ļ�', '��ʾ'); Exit;
      end;
    end;

    nIni.DeleteSection(nList[List1.ItemIndex]);
    Key := #0;
    List1.Selected.Delete;
  finally
    nList.Free;
    nIni.Free;
  end;
end;

//Desc: ��һ��
procedure TfResData.BtnBackClick(Sender: TObject);
begin
  case wPage.PageIndex of
   1: DoStep1(True);
   2: DoStep2(True);
   3: DoStep3(True);
   4: DoStep4(True);
  end;
end;

//Desc: ��һ��
procedure TfResData.BtnNextClick(Sender: TObject);
begin
  case wPage.PageIndex of
   0: DoStep1(False);
   1: DoStep2(False);
   2: DoStep3(False);
   3: DoStep4(False);
   4: DoStep5(False);
  end;
end;

//Desc: ����nDir�ļ���
function CreateDir(const nDir: string): Boolean;
begin
  Result := False;
  if not DirectoryExists(nDir) then
   if not QueryDlg('ָ����λ��(Ŀ¼)������,�Ƿ񴴽�?') then Exit;
   try
     if not ForceDirectories(nDir) then Exit;
   except
     ShowMsg('�޷�����ָ��Ŀ¼', '��ʾ'); Exit;
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
procedure TfResData.DoStep1(const nBack: Boolean);
begin
  if nBack then
  begin
    wPage.PageIndex := 0;
    BtnBack.Enabled := False;
    Hint1.Caption := Res_Welcome; Exit;
  end;

  if FileExists(SEdit1.Text) then
     FSFile := SEdit1.Text else
  begin
    ShowMsg(PChar(Res_Source), '��ʾ'); Exit;
  end;

  if Trim(DEdit1.Text) = '' then
  begin
    ShowMsg(PChar(Res_Dest), '��ʾ'); Exit;
  end else

  if FileExists(DEdit1.Text) then
     FDFile := DEdit1.Text else
  if IsValidFile(DEdit1.Text) then
  begin
    if CreateDir(ExtractFilePath(DEdit1.Text)) then
         FDFile := Dedit1.Text
    else Exit;
  end else
  begin
    ShowMsg(PChar(Res_DestErr), '��ʾ'); Exit;
  end;

  if File_IsSame(FDFile, Back_IndexFile) then
  begin
    ShowMsg(PChar(Res_DestErr), '��ʾ'); Exit;
  end;

  if FileExists(FDFile) then
  begin
    if not QueryDlg(Res_OverWrite) then Exit;
  end;

  LoadBackList(FSFile);
  DoStep2(True);
  //��ҳ��ת
end;

//Desc: �ڶ���ҳ��
procedure TfResData.DoStep2(const nBack: Boolean);
begin
  if nBack then
  begin
    wPage.PageIndex := 1;
    BtnBack.Enabled := True;
    Hint1.Caption := Res_Options;

    FSFile := SEdit1.Text; Exit;
    //Դ�ļ���ԭ
  end;

  if List1.ItemIndex = -1 then
  begin
    ShowMsg('��ѡ��Ҫ�ָ�������', '��ʾ'); Exit;
  end;

  LoadMarkInfo(FSFile, List1.ItemIndex);
  DoStep3(True);
end;

//Desc: ������ҳ��
procedure TfResData.DoStep3(const nBack: Boolean);
begin
  if nBack then
  begin
   wPage.PageIndex := 2;
   Hint1.Caption := Res_MarkStr; Exit;
  end;

  if File_IsSame(MEdit4.Text, FDFile) then
  begin
    if QueryDlg('�ָ�Ŀ���ļ��Ƿ�,�Ƿ��޸�?') then DoStep1(True);
    Exit;
  end;
  //���ݵ�Ŀ���ļ��ǻָ�ʱ��Դ�ļ�,���ָ�ʱ��Ŀ���ļ��뱸��ʱ��Ŀ��һ��,
  //��ָ�ʱ��Ŀ��&Դ�ļ���ͬһ���ļ�,��Ц��!

  if List1.Items[List1.ItemIndex].SubItems[1] = cYes then
       DoStep4(True)        //��ת��������ҳ
  else DoStep5(True);       //��ת�ָ�����ҳ
end;

//Desc: ���ĸ�ҳ��
procedure TfResData.DoStep4(const nBack: Boolean);
begin
  if nBack then
  begin
    if List1.Items[List1.ItemIndex].SubItems[1] = cYes then
    begin
      PEdit1.Clear;
      wPage.PageIndex := 3;
      Hint1.Caption := Res_Passwod;
    end else DoStep3(True);

    BtnNext.Caption := '��һ��'; Exit;
  end;

  BtnNext.Enabled := False;
  Sleep(550);
  BtnNext.Enabled := True;

  if PEdit1.Text = FPassword then
       DoStep5(True)
  else ShowMsg('�������,������', '��ʾ');
end;

//Desc: �����ҳ��
procedure TfResData.DoStep5(const nBack: Boolean);
begin
  if nBack then
  begin
    PBar1.Value := 0;
    BtnNext.Caption := '��ʼ';
    HintLabel1.Caption := '������ʾ:';

    wPage.PageIndex := 4;
    Hint1.Caption := Res_StaBack; Exit;
  end;

  if FileExists(FSFile) then
  begin
    BtnBack.Enabled := False;
    BtnNext.Enabled := False;
    //������ť
    ZnZip1.SourceFile := FSFile;
    ZnZip1.DestFile := FDFile;
    ZnZip1.UnZipFile;
    //��ѹ��
    HintLabel1.Caption := UnZip_Start;
  end else ShowMsg('�������ݶ�ʧ', '��ʾ');
end;

//Desc: ѡ�񱸷������ļ�
procedure TfResData.SEdit1ButtonClick(Sender: TObject);
begin
  with TOpenDialog.Create(Application) do
  begin
    Title := '���ݻָ�';
    Filter := '�����ļ�|' + Back_IndexFile;
    InitialDir := FSDir;
    Options := Options + [ofFileMustExist];

    if Execute then
    begin
      SEdit1.Text := FileName; FSDir := ExtractFilePath(FileName);
    end;
    Free;
  end;
end;

//Desc: ѡ��Ŀ��λ��
procedure TfResData.DEdit1ButtonClick(Sender: TObject);
begin
  with TOpenDialog.Create(Application) do
  begin
    Title := 'Ŀ��λ��';
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
procedure TfResData.ZnCRC1Begin(const nMax: Cardinal);
begin
  PBar1.MaxValue := nMax;
  HintLabel1.Caption := CRC_Running;
end;

procedure TfResData.ZnCRC1Process(const nHasDone: Cardinal);
begin
  PBar1.Value := nHasDone;
end;

procedure TfResData.ZnCRC1Message(const nMsg: String);
begin
  ShowDlg(nMsg, 'У��');
end;

procedure TfResData.ZnCRC1End(const nCRC: Cardinal;
  const IsNormal: Boolean);
begin
  if IsNormal then
  begin
    if FCRC = nCRC then
    begin
      ShowMsg('���ݻָ��ɹ�', '��ʾ');
      ModalResult := MrOK;
    end else ShowDlg('�ļ�У��ʧ��,�����Ѿ���!', '��ʾ');
  end else ShowMsg('�ļ�У��δ���', '��ʾ');
end;

{------------------------------------- Zip ------------------------------------}
procedure TfResData.ZnZip1Begin(const nMax: Cardinal);
begin
  PBar1.MaxValue := nMax;
  HintLabel1.Caption := UnZip_Running;
end;

procedure TfResData.ZnZip1Process(const nHasDone: Cardinal);
begin
  PBar1.Value := nHasDone;
end;

procedure TfResData.ZnZip1End(const nNormal: Boolean; nZipRate: Single);
begin
  if nNormal then
  begin
    if List1.Items[List1.ItemIndex].SubItems[0] = cYes then
    begin
      HintLabel1.Caption := CRC_Start;
      ZnCRC1.CRC_File(FDFile);
    end else
    begin
      ShowMsg('���ݻָ��ɹ�', '��ʾ');
      ModalResult := MrOK;
    end;
  end else ShowMsg('��ѹ������δ���', '��ʾ');
end;

end.
