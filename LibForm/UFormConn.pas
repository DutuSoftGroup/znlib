{*******************************************************************************
  作者: dmzn@163.com 2008-8-6
  描述: 支持多种数据库连接的设置窗体

  备注:
  &.数据库配置文件大致如下:
    [FileLink]
    ;配置文件跳转,启用其它的链接配置
    ;支持$Path变量
    ConfigFile=$Path\DBConn.ini

    [DBConn]
    DBName=Access
    DBList=DB2 Oracle Access SQLServer

    [Access]
    DBType=1
    DBMemo=isbk
    DBUser=sa
    DBPwd=c2E=
    DBCatalog=HXDelivery
    DBSource=127.0.0.1
    DBPath=D:\MyWork\HX_Delivery\Bin\DL_Client\
    DBFile=$Path\HRMS.MDB
    DBHost=
    DBPort=0

    [DBConnRes]
    ;$User=用户名 $Pwd=密码 $File=文件名 $Path=程序路径 $Host=主机名 $Port=端口
    ;$DB=数据库名 $DS=数据源名
    Access=Provider=Microsoft.Jet.OLEDB.4.0;Password=$Pwd;Data Source=$File
    SQLServer=Provider=SQLOLEDB.1;User ID=$User;Initial Catalog=$DB;Data Source=$DS

  &.使用本单元,需要先初始化全局变量ULibRes.sVar_ConnDBConfig,指定一个配置文件
    路径.
  &.需要初始化变量还包括:
    *.sVar_AppPath: 程序路径
    *.sVar_FormConfig: 窗体配置文件
*******************************************************************************}
unit UFormConn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles, StdCtrls, ExtCtrls, ComCtrls;

type
  TConnTestCallBack = function (const nConnStr: string): Boolean;
  //连接测试回调函数

  TfFormConnDB = class(TForm)
    wPage: TPageControl;
    Sheet1: TTabSheet;
    BtnOK: TButton;
    BtnExit: TButton;
    Group1: TGroupBox;
    DBName: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Edit_User: TEdit;
    Edit_Pwd: TEdit;
    Edit_File: TEdit;
    Edit_DB: TEdit;
    Edit_DS: TEdit;
    Bevel1: TBevel;
    BtnTest: TButton;
    Label7: TLabel;
    Label8: TLabel;
    Edit_Host: TEdit;
    Edit_Port: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure DBNameChange(Sender: TObject);
    procedure BtnTestClick(Sender: TObject);
    procedure Edit_UserKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FCallBack: TConnTestCallBack;
    {*回调函数*}  
    procedure LoadDataByType(const nDBName: string = '');
    {*载入数据*}
    function IsDataValidConn: Boolean;
    {*校验连接*}
  public
    { Public declarations }
  end;

function ShowConnectDBSetupForm(const nCallBack: TConnTestCallBack): Boolean;
function BuildConnectDBStr(const nParam: TStrings = nil;
 const nDBName: string = ''; const nFile: string = ''): string;
function BuildFixedConnStr(const nMemo: string; nFullMatch: Boolean): string;
function LoadConnecteDBConfig(const nList: TStrings; const nFile: string = '';
 const nDBName: string = ''): Boolean;
//入口函数

ResourceString
  {*数据源连接宏定义*}
  sConn_User          = '$User';                     //用户名
  sConn_Pwd           = '$Pwd';                      //密码
  sConn_File          = '$File';                     //文件名
  sConn_Path          = '$Path';                     //程序路径
  sConn_Host          = '$Host';                     //主机名
  sConn_Port          = '$Port';                     //端口
  sConn_DB            = '$DB';                       //数据库名
  sConn_DS            = '$DS';                       //数据源名

  {*数据源连接配置文件中宏对应的小节*}
  sConn_Sec_FileLink  = 'FileLink';                  //文件跳转
  sConn_Sec_DBConn    = 'DBConn';                    //配置参数
  sConn_Sec_DBConnRes = 'DBConnRes';                 //可用连接资源

  sConn_Key_LinkFile  = 'ConfigFile';                //跳转文件
  sConn_Key_PathValue = 'DBPath';                    //$Path变量值
  sConn_Key_DBType    = 'DBType';                    //数据库类型
  sConn_Key_DBMemo    = 'DBMemo';                    //数据库描述
  sConn_Key_DBName    = 'DBName';                    //已选中数据库名称
  sConn_Key_DBList    = 'DBList';                    //可选数据库类名称
  sConn_Key_ConnStr   = 'DBConn';                    //连接字符串
  sConn_Key_User      = 'DBUser';
  sConn_Key_DBPwd     = 'DBPwd';
  sConn_Key_DBFile    = 'DBFile';
  sConn_Key_DBHost    = 'DBHost';
  sConn_Key_DBPort    = 'DBPort';
  sConn_Key_DBCatalog = 'DBCatalog';
  sConn_Key_DBSource  = 'DBSource';

implementation

{$R *.dfm}
uses
  UBase64, UFormWait, UMgrVar, ULibFun, ULibRes;

var
  gHasFileLinked: Boolean = False;
  //配置文件是否已跳转

//------------------------------------------------------------------------------
//Desc: 显示设置窗口
function ShowConnectDBSetupForm(const nCallBack: TConnTestCallBack): Boolean;
begin
  with TfFormConnDB.Create(Application) do
  begin
    Caption := '设置';
    FCallBack := nCallBack;

    LoadDataByType;
    Result := ShowModal = mrOK;
    Free;
  end;
end;

//Desc: 获取nDBName数据库类型的连接字符串
function GetDBConnStr(const nDBName: string): string;
var nStr: string;
    nIni: TIniFile;
begin
  Result := '';
  nStr := gVariantManager.VarStr(sVar_ConnDBConfig);
  if not FileExists(nStr) then Exit;

  nIni := TIniFile.Create(nStr);
  try
    Result := nIni.ReadString(sConn_Sec_DBConnRes, nDBName, '');
    Result := Trim(Result);
  finally
    nIni.Free;
  end;
end;

//Desc: 跳转,使全局变量sVar_ConnDBConfig指向新的配置文件
procedure ReLinkDBConfigFile;
var nIni: TIniFile;
    nStr,nFile: string;
begin
  if gHasFileLinked then Exit;
  nFile := gVariantManager.VarStr(sVar_ConnDBConfig);
  if not FileExists(nFile) then Exit;

  nIni := TIniFile.Create(nFile);
  try
    nFile := nIni.ReadString(sConn_Sec_FileLink, sConn_Key_LinkFile, '');
    if Pos(sConn_Path, nFile) > 0 then
    begin
      nStr := gVariantManager.VarStr(sVar_AppPath);
      if nStr = '' then
        raise Exception.Create('Invalidate AppPath Variant!');
      //xxxxx

      if Copy(nStr, Length(nStr), 1) = '\' then System.Delete(nStr, Length(nStr), 1);
      nFile := StringReplace(nFile, sConn_Path, nStr, [rfReplaceAll, rfIgnoreCase]);
    end;

    if FileExists(nFile) then
    begin
      gVariantManager.AddVarStr(sVar_ConnDBConfig, nFile);
      gHasFileLinked := True;
    end;
  finally
    nIni.Free;
  end;
end;

//Desc: 载入配置
function LoadConnecteDBConfig(const nList: TStrings; const nFile,nDBName: string ): Boolean;
var nIni: TIniFile;
    nStr,nSection: string;
begin
  Result := False;
  if nFile = '' then
  begin
    ReLinkDBConfigFile;
    nStr := gVariantManager.VarStr(sVar_ConnDBConfig);
  end else nStr := nFile;
  if not FileExists(nStr) then Exit;

  nIni := TIniFile.Create(nStr);
  try
    if not gHasFileLinked then
    begin
      nStr := gVariantManager.VarStr(sVar_AppPath);
      nIni.WriteString(sConn_Sec_DBConn, sConn_Key_PathValue, nStr);
    end;

    nList.Clear;
    nStr := nIni.ReadString(sConn_Sec_DBConn, sConn_Key_DBList, '');
    nList.Add(sConn_Key_DBList + '=' + Trim(nStr));

    nStr := nIni.ReadString(sConn_Sec_DBConn, sConn_Key_PathValue, '');
    nList.Add(sConn_Key_PathValue + '=' + Trim(nStr));

    if nDBName = '' then
         nSection := Trim(nIni.ReadString(sConn_Sec_DBConn, sConn_Key_DBName, ''))
    else nSection := nDBName;
    nList.Add(sConn_Key_DBName + '=' + nSection);  

    //--------------------------------------------------------------------------
    nStr := nIni.ReadString(nSection, sConn_Key_DBType, '');
    nList.Add(sConn_Key_DBType + '=' + Trim(nStr));

    nStr := nIni.ReadString(nSection, sConn_Key_DBMemo, '');
    nList.Add(sConn_Key_DBMemo + '=' + Trim(nStr));

    nStr := nIni.ReadString(nSection, sConn_Key_User, '');
    nList.Add(sConn_Key_User + '=' + Trim(nStr));

    nStr := nIni.ReadString(nSection, sConn_Key_DBPwd, '');
    nList.Add(sConn_Key_DBPwd + '=' + Trim(DecodeBase64(nStr)));

    nStr := nIni.ReadString(nSection, sConn_Key_DBFile, '');
    nList.Add(sConn_Key_DBFile + '=' + Trim(nStr));

    nStr := nIni.ReadString(nSection, sConn_Key_DBHost, '');
    nList.Add(sConn_Key_DBHost + '=' + Trim(nStr));

    nStr := IntToStr(nIni.ReadInteger(nSection, sConn_Key_DBPort, 0));
    nList.Add(sConn_Key_DBPort + '=' + nStr);

    nStr := nIni.ReadString(nSection, sConn_Key_DBCatalog, '');
    nList.Add(sConn_Key_DBCatalog + '=' + Trim(nStr));

    nStr := nIni.ReadString(nSection, sConn_Key_DBSource, '');
    nList.Add(sConn_Key_DBSource + '=' + Trim(nStr));
    Result := True;
  finally
    nIni.Free;
  end;
end;

//Desc: 构建特定类型数据库的连接字符串
function BuildConnectDBStr(const nParam: TStrings = nil;
 const nDBName: string = ''; const nFile: string = ''): string;
var nStr: string;
    nList: TStrings;
begin
  Result := '';
  if Assigned(nParam) then
       nList := nParam
  else nList := TStringList.Create;

  try
    if not (Assigned(nParam) or
            LoadConnecteDBConfig(nList, nFile, nDBName)) then Exit;
    //xxxxx
    
    if nDBName = '' then
         nStr := nList.Values[sConn_Key_DBName]
    else nStr := nDBName;
    Result := GetDBConnStr(nStr);

    nStr := nList.Values[sConn_Key_User];
    Result := StringReplace(Result, sConn_User, nStr, [rfReplaceAll, rfIgnoreCase]);

    nStr := nList.Values[sConn_Key_DBPwd];
    Result := StringReplace(Result, sConn_Pwd, nStr, [rfReplaceAll, rfIgnoreCase]);

    nStr := nList.Values[sConn_Key_DBFile];
    Result := StringReplace(Result, sConn_File, nStr, [rfReplaceAll, rfIgnoreCase]);

    nStr := nList.Values[sConn_Key_DBHost];
    Result := StringReplace(Result, sConn_Host, nStr, [rfReplaceAll, rfIgnoreCase]);

    nStr := nList.Values[sConn_Key_DBPort];
    Result := StringReplace(Result, sConn_Port, nStr, [rfReplaceAll, rfIgnoreCase]);

    nStr := nList.Values[sConn_Key_DBCatalog];
    Result := StringReplace(Result, sConn_DB, nStr, [rfReplaceAll, rfIgnoreCase]);

    nStr := nList.Values[sConn_Key_DBSource];
    Result := StringReplace(Result, sConn_DS, nStr, [rfReplaceAll, rfIgnoreCase]);

    nStr := nList.Values[sConn_Key_PathValue];
    if nStr = '' then nStr := gVariantManager.VarStr(sVar_AppPath);
    
    if nStr = '' then
      raise Exception.Create('Invalidate AppPath Variant!');
    //xxxxx

    if Copy(nStr, Length(nStr), 1) = '\' then System.Delete(nStr, Length(nStr), 1);
    Result := StringReplace(Result, sConn_Path, nStr, [rfReplaceAll, rfIgnoreCase]);
  finally
    if not Assigned(nParam) then nList.Free;
  end;
end;

//Desc: 按指定备注构建数据库连接
function BuildFixedConnStr(const nMemo: string; nFullMatch: Boolean): string;
var nStr: string;
    nIdx: Integer;
    nListA,nListB: TStrings;
begin   
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    Result := '';
    LoadConnecteDBConfig(nListA);

    nStr := nListA.Values[sConn_Key_DBList];
    nListA.Text := StringReplace(nStr, ' ', #13#10, [rfReplaceAll]);

    for nIdx:=0 to nListA.Count - 1 do
    begin
      LoadConnecteDBConfig(nListB, '', nListA[nIdx]);
      nStr := nListB.Values[sConn_Key_DBMemo];

      if nFullMatch then
      begin
        if LowerCase(nMemo) = LowerCase(nStr) then
        begin
          Result := BuildConnectDBStr(nListB);
          Exit;
        end;
      end else

      if Pos(LowerCase(nMemo), LowerCase(nStr)) > 0 then
      begin
        Result := BuildConnectDBStr(nListB);
        Exit;
      end;
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormConnDB.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormConnDB.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

//------------------------------------------------------------------------------
//Desc: 切换焦点
procedure TfFormConnDB.Edit_UserKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN,VK_DOWN: SwitchFocusCtrl(Self, True);
    VK_UP: SwitchFocusCtrl(Self, False);
  end;
end;

//Desc: 调整相应数据库的必填项
procedure TfFormConnDB.DBNameChange(Sender: TObject);
var nStr: string;
    nIni: TIniFile;
    i,nCount: integer;
begin
  nStr := gVariantManager.VarStr(sVar_ConnDBConfig);
  if not FileExists(nStr) then Exit;

  nIni := TIniFile.Create(nStr);
  try
    nStr := nIni.ReadString(sConn_Sec_DBConnRes, DBName.Text, '');
  finally
    nIni.Free;
  end;

  nCount := Group1.ControlCount - 1;
  if nStr = '' then
  begin
    for i:=0 to nCount do
     if Group1.Controls[i] is TEdit then
      TEdit(Group1.Controls[i]).Enabled := False;
  end else
  begin
    nStr := LowerCase(nStr);
    Edit_User.Enabled := Pos(LowerCase(sConn_User), nStr) > 0;
    Edit_Pwd.Enabled := Pos(LowerCase(sConn_Pwd), nStr) > 0;
    Edit_File.Enabled := Pos(LowerCase(sConn_File), nStr) > 0;
    Edit_Host.Enabled := Pos(LowerCase(sConn_Host), nStr) > 0;
    Edit_Port.Enabled := Pos(LowerCase(sConn_Port), nStr) > 0;
    Edit_DB.Enabled := Pos(LowerCase(sConn_DB), nStr) > 0;
    Edit_DS.Enabled := Pos(LowerCase(sConn_DS), nStr) > 0;
  end;

  for i:=0 to nCount do
   if Group1.Controls[i] is TEdit then
    with TEdit(Group1.Controls[i]) do
    begin
      if Enabled then Color := clInfoBk else Color := clWindow;
    end;

  if ActiveControl = DBName then
    LoadDataByType(DBName.Text);
  //xxxxx
end;

//Desc: 测试连接
procedure TfFormConnDB.BtnTestClick(Sender: TObject);
var nStr: string;
    nRes: Boolean;
    nList: TStrings;
begin
  if not IsDataValidConn then Exit;
  nStr := GetDBConnStr(DBName.Text);
  
  if nStr = '' then
  begin
    nStr := gVariantManager.VarStr(sVar_DlgHintStr, sVar_DlgHintStrDef);
    ShowDlg('暂时不支持该类型的数据库', nStr, Handle); Exit;
  end;

  nList := TStringList.Create;
  try
    nList.Add(sConn_Key_ConnStr + '=' + nStr);
    nList.Add(sConn_Key_DBName + '=' + Trim(DBName.Text));
    nList.Add(sConn_Key_User + '=' + Trim(Edit_User.Text));
    nList.Add(sConn_Key_DBPwd + '=' + Trim(Edit_Pwd.Text));
    nList.Add(sConn_Key_DBFile + '=' + Trim(Edit_File.Text));
    nList.Add(sConn_Key_DBHost + '=' + Trim(Edit_Host.Text));
    nList.Add(sConn_Key_DBPort + '=' + Edit_Port.Text);
    nList.Add(sConn_Key_DBCatalog + '=' + Trim(Edit_DB.Text));
    nList.Add(sConn_Key_DBSource + '=' + Trim(Edit_DS.Text));

    nStr := BuildConnectDBStr(nList);
  finally
    nList.Free;
  end;

  nRes := False;
  ShowWaitForm(Self, '正在连接');
  try
    nRes := FCallBack(nStr);
    CloseWaitForm;
  except
    CloseWaitForm;
  end;

  if nRes then
  begin
    nStr := gVariantManager.VarStr(sVar_DlgHintStr, sVar_DlgHintStrDef);
    ShowHintMsg('测试成功', nStr, Handle)
  end else
  begin
    nStr := gVariantManager.VarStr(sVar_DlgWarnStr, sVar_DlgWarnStrDef);
    ShowDlg('测试失败,无法连接到指定数据库', nStr, Handle);
  end;
end;

//------------------------------------------------------------------------------
//Desc: 载入指定配置
procedure TfFormConnDB.LoadDataByType(const nDBName: string);
var nStr: string;
    nList: THashedStringList;
begin
  nList := THashedStringList.Create;
  try
    if not LoadConnecteDBConfig(nList, '', nDBName) then Exit;
    //load error

    if nDBName = '' then
    begin
      nStr := nList.Values[sConn_Key_DBList];
      nStr := StringReplace(nStr, ' ', #13#10, [rfReplaceAll]);
      DBName.Items.Text := nStr;
    end;

    nStr := nList.Values[sConn_Key_DBName]; 
    DBName.ItemIndex := DBName.Items.IndexOf(nStr);

    if (nDBName = '') and (DBName.ItemIndex > -1) then
      DBNameChange(nil);
    //xxxxx
    
    Edit_User.Text := nList.Values[sConn_Key_User];
    Edit_Pwd.Text := nList.Values[sConn_Key_DBPwd];
    Edit_File.Text := nList.Values[sConn_Key_DBFile];
    Edit_Host.Text := nList.Values[sConn_Key_DBHost];
    Edit_Port.Text := nList.Values[sConn_Key_DBPort];
    Edit_DB.Text := nList.Values[sConn_Key_DBCatalog];
    Edit_DS.Text := nList.Values[sConn_Key_DBSource];
  finally
    nList.Free;
  end;
end;

//Desc: 校验连接数据是否正确
function TfFormConnDB.IsDataValidConn: Boolean;
var nHint: string;
begin
  Result := False;
  nHint := gVariantManager.VarStr(sVar_DlgHintStr, sVar_DlgHintStrDef);

  if DBName.ItemIndex < 0 then
  begin
    DBName.SetFocus;
    ShowHintMsg('请选择正确的数据库类型', nHint, Handle); Exit;
  end;

  if Edit_User.Enabled and (Trim(Edit_User.Text) = '') then
  begin
    Edit_User.SetFocus;
    ShowHintMsg('请填写正确的用户名', nHint, Handle); Exit;
  end;

  if Edit_File.Enabled and (Trim(Edit_File.Text) = '') then
  begin
    Edit_File.SetFocus;
    ShowHintMsg('请填写正确的文件名', nHint, Handle); Exit;
  end;

  if Edit_Host.Enabled and (Trim(Edit_Host.Text) = '') then
  begin
    Edit_Host.SetFocus;
    ShowHintMsg('请填写正确的主机地址', nHint, Handle); Exit;
  end;

  if Edit_Port.Enabled and (not IsNumber(Edit_Port.Text, False)) then
  begin
    Edit_Port.SetFocus;
    ShowHintMsg('请填写正确的连接端口', nHint, Handle); Exit;
  end;

  if Edit_DB.Enabled and (Trim(Edit_DB.Text) = '') then
  begin
    Edit_DB.SetFocus;
    ShowHintMsg('请填写正确的数据库名', nHint, Handle); Exit;
  end;

  if Edit_DS.Enabled and (Trim(Edit_DS.Text) = '') then
  begin
    Edit_DS.SetFocus;
    ShowHintMsg('请填写正确的数据源', nHint, Handle); Exit;
  end;

  Result := True;
end;

//Desc: 保存
procedure TfFormConnDB.BtnOKClick(Sender: TObject);
var nIni: TIniFile;
    nStr,nSection: string;
begin
  if not IsDataValidConn then Exit;
  nIni := TIniFile.Create(gVariantManager.VarStr(sVar_ConnDBConfig));
  try
    nSection := Trim(DBName.Text);
    nIni.WriteString(sConn_Sec_DBConn, sConn_Key_DBName, nSection);

    nIni.WriteString(nSection, sConn_Key_User, Edit_User.Text);
    nIni.WriteString(nSection, sConn_Key_DBPwd, EncodeBase64(Edit_Pwd.Text));

    nIni.WriteString(nSection, sConn_Key_DBFile, Edit_File.Text);
    nIni.WriteString(nSection, sConn_Key_DBHost, Edit_Host.Text);
    nIni.WriteString(nSection, sConn_Key_DBPort, Edit_Port.Text);
    
    nIni.WriteString(nSection, sConn_Key_DBCatalog, Edit_DB.Text);
    nIni.WriteString(nSection, sConn_Key_DBSource, Edit_DS.Text);

    if not gHasFileLinked then
    begin
      nStr := gVariantManager.VarStr(sVar_AppPath);
      nIni.WriteString(sConn_Sec_DBConn, sConn_Key_PathValue, nStr);
    end;

    ModalResult := mrOK;
    Visible := False;
  finally
    nIni.Free;
  end;
end;

end.
