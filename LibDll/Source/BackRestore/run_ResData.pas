{*******************************************************************************
  作者: dmzn 2007-02-02
  描述: 数据(文件)恢复窗口
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
    //源&目标目录
    FSFile,FDFile: string;
    //源&目标文件
    FCRC: Cardinal;
    //校验值
    FPassword: string;
    //密码
    procedure DoStep1(const nBack: Boolean);
    procedure DoStep2(const nBack: Boolean);
    procedure DoStep3(const nBack: Boolean);
    procedure DoStep4(const nBack: Boolean);
    procedure DoStep5(const nBack: Boolean);
    //页面跳转
    procedure SetSourceAndDest(const nSource,nDest: string);
    //设置备份源和目标
    procedure LoadBackList(const nFile: string);
    //载入备份列表
    procedure LoadMarkInfo(const nFile: string; const nIndex: integer);
    //载入描述信息    
  public
    { Public declarations }
  end;

function Data_ShowRestore(const nTitle,nIdxFile,nDest: PChar): Boolean; stdcall;
procedure Data_CloseResForm;
//入口函数

implementation

{$R *.dfm}
uses
  IniFiles, ZLibEx, UDataFile, ULibFun, ULibDLL, run_CommonA, run_CommonB,
  run_Const, run_DataRes;

var
  gForm: TfResData = nil;

//Desc: 显示备份窗口
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

//Desc: 释放备份
procedure Data_CloseResForm;
begin
  FreeAndNil(gForm);
end;

//Date: 2007-02-02
//Desc: 设置源文件和目标文件
procedure TfResData.SetSourceAndDest(const nSource, nDest: string);
begin
  if FileExists(nSource) then
  begin
    SEdit1.Text := nSource;
    DEdit1.Text := nDest;
    DoStep1(False);
  end;
end;

{---------------------------------- 创建与释放 --------------------------------}
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
    if not QueryDlg('数据还未恢复完毕,是否退出?') then Exit;
  ModalResult := mrCancel;
end;

{----------------------------------- 窗体过程 ---------------------------------}
function FormatFileName(const nStr: string): string;
begin
  Result := ExtractFileName(nStr);
  Result := Copy(Result, 1, Pos('.', Result) - 1);
end;

//Desc: 载入nFile备份索引文件
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
      //备份名称

      if nIni.ReadBoolean(nList[i], 'CRCOk', False) then
           SubItems.Add(cYes)
      else SubItems.Add(cNo);
      //是否校验

      if nIni.ReadBoolean(nList[i], 'PWDOk', False) then
      begin
        ImageIndex := 1;
        SubItems.Add(cYes);
      end else
      begin
        ImageIndex := 0;
        SubItems.Add(cNo);
      end;
      //是否加密
      SubItems.Add(DateTimeToStr(StrToFloat(nList[i])));
      //日期
    end;   
  finally
    nList.Free;
    nIni.Free; 
  end;
end;

//Date: 2007-02-08
//Parm: 索引文件;索引
//Desc: 载入nFile中nIndex记录的信息
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
      //备份数据与索引文件在同一个文件夹下
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

//Desc: 删除指定备份
procedure TfResData.List1KeyPress(Sender: TObject; var Key: Char);
var nStr: string;
    nList: TStrings;
    nIni: TDataFile;
begin
  if Lowercase(Key) <> 'd' then Exit;
  if not Assigned(List1.Selected) then Exit;
  if not QueryDlg('确定要删除指定备份吗?', '询问') then Exit;

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
      if not Dlg_InputPWDBox(Application, Screen, '请输入备份时的验证密码:',
         PChar(@nStr[1]), 10) then Exit;

      nStr := StrPas(@nStr[1]);
      if nStr <> nIni.ReadString(nList[List1.ItemIndex], 'PWD', '') then
      begin
        ShowMsg('密码错误,请重试', '提示'); Exit;
      end;
    end;

    nStr := nList[List1.ItemIndex];
    nStr := nIni.ReadString(nStr, 'Dest', '');
    nStr := ExtractFilePath(SEdit1.Text) + ExtractFileName(nStr);

    if FileExists(nStr) then
    begin
      if not DeleteFile(nStr) then
      begin
        ShowMsg('无法删除备份文件', '提示'); Exit;
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

//Desc: 上一步
procedure TfResData.BtnBackClick(Sender: TObject);
begin
  case wPage.PageIndex of
   1: DoStep1(True);
   2: DoStep2(True);
   3: DoStep3(True);
   4: DoStep4(True);
  end;
end;

//Desc: 下一步
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

//Desc: 创建nDir文件夹
function CreateDir(const nDir: string): Boolean;
begin
  Result := False;
  if not DirectoryExists(nDir) then
   if not QueryDlg('指定的位置(目录)不存在,是否创建?') then Exit;
   try
     if not ForceDirectories(nDir) then Exit;
   except
     ShowMsg('无法创建指定目录', '提示'); Exit;
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
    ShowMsg(PChar(Res_Source), '提示'); Exit;
  end;

  if Trim(DEdit1.Text) = '' then
  begin
    ShowMsg(PChar(Res_Dest), '提示'); Exit;
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
    ShowMsg(PChar(Res_DestErr), '提示'); Exit;
  end;

  if File_IsSame(FDFile, Back_IndexFile) then
  begin
    ShowMsg(PChar(Res_DestErr), '提示'); Exit;
  end;

  if FileExists(FDFile) then
  begin
    if not QueryDlg(Res_OverWrite) then Exit;
  end;

  LoadBackList(FSFile);
  DoStep2(True);
  //下页跳转
end;

//Desc: 第二个页面
procedure TfResData.DoStep2(const nBack: Boolean);
begin
  if nBack then
  begin
    wPage.PageIndex := 1;
    BtnBack.Enabled := True;
    Hint1.Caption := Res_Options;

    FSFile := SEdit1.Text; Exit;
    //源文件还原
  end;

  if List1.ItemIndex = -1 then
  begin
    ShowMsg('请选择要恢复的数据', '提示'); Exit;
  end;

  LoadMarkInfo(FSFile, List1.ItemIndex);
  DoStep3(True);
end;

//Desc: 第三个页面
procedure TfResData.DoStep3(const nBack: Boolean);
begin
  if nBack then
  begin
   wPage.PageIndex := 2;
   Hint1.Caption := Res_MarkStr; Exit;
  end;

  if File_IsSame(MEdit4.Text, FDFile) then
  begin
    if QueryDlg('恢复目标文件非法,是否修改?') then DoStep1(True);
    Exit;
  end;
  //备份的目标文件是恢复时的源文件,若恢复时的目标文件与备份时的目标一致,
  //则恢复时的目标&源文件是同一个文件,可笑吧!

  if List1.Items[List1.ItemIndex].SubItems[1] = cYes then
       DoStep4(True)        //跳转设置密码页
  else DoStep5(True);       //跳转恢复进度页
end;

//Desc: 第四个页面
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

    BtnNext.Caption := '下一步'; Exit;
  end;

  BtnNext.Enabled := False;
  Sleep(550);
  BtnNext.Enabled := True;

  if PEdit1.Text = FPassword then
       DoStep5(True)
  else ShowMsg('密码错误,请重试', '提示');
end;

//Desc: 第五个页面
procedure TfResData.DoStep5(const nBack: Boolean);
begin
  if nBack then
  begin
    PBar1.Value := 0;
    BtnNext.Caption := '开始';
    HintLabel1.Caption := '进度提示:';

    wPage.PageIndex := 4;
    Hint1.Caption := Res_StaBack; Exit;
  end;

  if FileExists(FSFile) then
  begin
    BtnBack.Enabled := False;
    BtnNext.Enabled := False;
    //锁定按钮
    ZnZip1.SourceFile := FSFile;
    ZnZip1.DestFile := FDFile;
    ZnZip1.UnZipFile;
    //解压缩
    HintLabel1.Caption := UnZip_Start;
  end else ShowMsg('备份数据丢失', '提示');
end;

//Desc: 选择备份索引文件
procedure TfResData.SEdit1ButtonClick(Sender: TObject);
begin
  with TOpenDialog.Create(Application) do
  begin
    Title := '数据恢复';
    Filter := '索引文件|' + Back_IndexFile;
    InitialDir := FSDir;
    Options := Options + [ofFileMustExist];

    if Execute then
    begin
      SEdit1.Text := FileName; FSDir := ExtractFilePath(FileName);
    end;
    Free;
  end;
end;

//Desc: 选择目标位置
procedure TfResData.DEdit1ButtonClick(Sender: TObject);
begin
  with TOpenDialog.Create(Application) do
  begin
    Title := '目标位置';
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
  ShowDlg(nMsg, '校验');
end;

procedure TfResData.ZnCRC1End(const nCRC: Cardinal;
  const IsNormal: Boolean);
begin
  if IsNormal then
  begin
    if FCRC = nCRC then
    begin
      ShowMsg('数据恢复成功', '提示');
      ModalResult := MrOK;
    end else ShowDlg('文件校验失败,可能已经损坏!', '提示');
  end else ShowMsg('文件校验未完成', '提示');
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
      ShowMsg('数据恢复成功', '提示');
      ModalResult := MrOK;
    end;
  end else ShowMsg('解压缩操作未完成', '提示');
end;

end.
