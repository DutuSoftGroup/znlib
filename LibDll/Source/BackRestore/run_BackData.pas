{*******************************************************************************
  作者: dmzn 2007-02-02
  描述: 数据(文件)备份窗口
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
    //源&目标目录
    FSFile,FDFile: string;
    //源&目标文件
    FCRC: Cardinal;
    //校验值
    procedure DoStep1(const nBack: Boolean);
    procedure DoStep2(const nBack: Boolean);
    procedure DoStep3(const nBack: Boolean);
    procedure DoStep4(const nBack: Boolean);
    procedure DoStep5(const nBack: Boolean);
    //页面跳转
    procedure SetSourceAndDest(const nSource,nDest: string);
    //设置备份源和目标
  public
    { Public declarations }
  end;

function Data_ShowBackup(const nTitle,nSource,nDest: PChar): Boolean; stdcall;
procedure Data_CloseBackForm;
//入口函数

implementation

{$R *.dfm}
uses
  IniFiles, ZLibEx, UDataFile, ULibFun, run_CommonA, run_CommonB, run_Const, 
  run_DataRes;

var
  gForm: TfBackData = nil;

//Desc: 显示备份窗口
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

//Desc: 释放备份
procedure Data_CloseBackForm;
begin
  FreeAndNil(gForm);
end;

//Date: 2007-02-02
//Desc: 设置源文件和目标文件
procedure TfBackData.SetSourceAndDest(const nSource, nDest: string);
begin
  if FileExists(nSource) then
  begin
    SEdit1.Text := nSource;
    DEdit1.Text := nDest;
    DoStep1(False);
  end;
end;

{---------------------------------- 创建与释放 --------------------------------}
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

{----------------------------------- 窗体过程 ---------------------------------}
procedure TfBackData.Panel1PanelPaint(Cnvs: TCanvas; R: TRect);
begin
  Cnvs.Brush.Color := clWhite;
  Cnvs.FillRect(R);
end;

//Desc: 压缩比率
procedure TfBackData.Radio1Click(Sender: TObject);
begin
  case (Sender as TComponent).Tag of
   1: ZnZip1.ZipLevel := zcFastest;
   2: ZnZip1.ZipLevel := zcDefault;
   3: ZnZip1.ZipLevel := zcMax;
  end;
end;

//Desc: 默认压缩比率
procedure TfBackData.Check2Click(Sender: TObject);
begin
  if Check2.Checked then
  begin
    ZnZip1.ZipLevel := zcDefault;
    Radio2.Checked := True;
  end else ZnZip1.ZipLevel := zcNone;
end;

//Desc: 上一步
procedure TfBackData.BtnBackClick(Sender: TObject);
begin
  case wPage.PageIndex of
   1: DoStep1(True);
   2: DoStep2(True);
   3: DoStep3(True);
   4: DoStep4(True);
  end;
end;

//Desc: 下一步
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

//Desc: 使用nDir+nFileName的方法合成新文件路径
function CombineFile(const nDir,nFile: string): string;
begin
  if Copy(nDir, Length(nDir), 1) = '\' then
       Result := nDir + ExtractFileName(nFile)
  else Result := nDir + '\' + ExtractFileName(nFile);
end;

//Desc: 创建nDir文件夹
function CreateDir(const nDir: string): Boolean;
begin
  Result := False;
  if not DirectoryExists(nDir) then
   if not QueryDlg(Back_MakeDir) then Exit;
   try
     if not ForceDirectories(nDir) then Exit;
   except
     ShowMsg(Back_MDError, '提示'); Exit;
   end;

  Result := True;
end;

//Desc: 是否合法的文件名
function IsValidFile(const nFile: string): Boolean;
var nExt: string;
begin
  Result := False;
  nExt := ExtractFileExt(nFile);
  if (Length(nExt) > 1) and (nExt[1] = '.') and
     (Pos('.', ExtractFileName(nFile)) > 1) then Result := True;
  //文件名不合法:1.没扩展名;2没文件名
end;

//Desc: 第一个页面
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
    ShowMsg(Back_Source, '提示'); Exit;
  end;

  if Trim(DEdit1.Text) = '' then
  begin
    ShowMsg(Back_Dest, '提示'); Exit;
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
    ShowMsg(Back_DestErr, '提示'); Exit;
  end;

  if FileExists(FDFile) then
  begin
    if not QueryDlg(Back_OverWrite) then Exit;
  end;

  DoStep2(True);
  //下页跳转
end;

//Desc: 第二个页面
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
      Group2.Caption := '压缩强度';
    end else
    begin
      Group2.Enabled := False;
      Group2.Caption := '压缩强度:(无)';
    end;

    if Check3.Checked then
    begin
      Group3.Enabled := True;
      Group3.Caption := '密码';
    end else
    begin
      Group3.Enabled := False;
      Group3.Caption := '密码:(空)';
    end;

    DoStep3(True);
    //跳转设置密码页
  end else DoStep4(True);
  //跳转备份进度页
end;

//Desc: 第三个页面
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
     ShowMsg(Back_InputPWD, '提示'); Exit;
   end;

  DoStep4(True);
  //跳转到备份页
end;

//Desc: 第四个页面
procedure TfBackData.DoStep4(const nBack: Boolean);
begin
  if nBack then
  begin
    wPage.PageIndex := 3;
    BtnNext.Caption := '下一步';
    Hint1.Caption := Back_MarkStr;
  end else DoStep5(True);
end;

//Desc: 第五个页面
procedure TfBackData.DoStep5(const nBack: Boolean);
begin
  if nBack then
  begin
    PBar1.Value := 0;
    BtnNext.Caption := '开始';
    HintLabel1.Caption := '进度提示:';

    wPage.PageIndex := 4;
    Hint1.Caption := Back_StaBack; Exit;
  end;

  BtnBack.Enabled := False;
  BtnNext.Enabled := False;
  //锁定按钮
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

//Desc: 选择备份文件
procedure TfBackData.SEdit1ButtonClick(Sender: TObject);
begin
  with TOpenDialog.Create(Application) do
  begin
    Title := '备份文件';
    Filter := '所有文件|*.*';
    InitialDir := FSDir;

    if Execute then
    begin
      SEdit1.Text := FileName; FSDir := ExtractFilePath(FileName);
    end;
    Free;
  end;
end;

//Desc: 选择备份存放位置
procedure TfBackData.DEdit1ButtonClick(Sender: TObject);
begin
  with TOpenDialog.Create(Application) do
  begin
    Title := '备份位置';
    Filter := '所有文件|*.*';
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
  ShowDlg(nMsg, '校验');
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
  end else ShowMsg('文件校验未完成', '提示');
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
    ShowMsg('压缩操作中止', '提示');
    Exit;
  end;

  nIni := TDataFile.Create(ExtractFilePath(FDFile) + Back_IndexFile);
  try
    nIni.CodeKey := sCodeKey;
    nSec := FloatToStr(Now);
    //备份日期
    nIni.WriteBoolean(nSec, 'CRCOk', Check1.Checked);
    nIni.WriteInteger(nSec, 'CRC', FCRC);
    //校验值
    nIni.WriteBoolean(nSec, 'PWDOk', Check3.Checked);
    nIni.WriteString(nSec, 'PWD', PEdit1.Text);
    //备份密码
    nIni.WriteDouble(nSec, 'ZipRate', nZipRate);
    //压缩比例
    nIni.WriteString(nSec, 'Source', FSFile);
    nIni.WriteString(nSec, 'Dest', FDFile);
    //文件信息
    nIni.WriteStrings(nSec, 'Mark', Memo1.Lines);
    //备注信息
  finally
    nIni.Free;
  end;

  ShowMsg('备份成功', '提示');
  ModalResult := MrOK;
end;

end.
