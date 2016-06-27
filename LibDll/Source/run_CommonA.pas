{*******************************************************************************
  作者: dmzn 2007-01-08
  描述: 常用函数库第一个单元,(常规操作)
*******************************************************************************}
unit run_CommonA;

interface

uses
  Windows, SysUtils, IniFiles, Forms, Registry, run_Const;

procedure ShowDlg(const nMsg: string; const nTitle: string = '');
//消息框
function QueryDlg(const nMsg: string; const nTitle: string = ''): boolean;
//询问对话框
function QueryDlg2(const nMsg: string; const nTitle: string = ''): Integer;
//带取消按钮的询问对话框

function FixLenStr(const nStr: string; const nLen: integer): string;
//设定nStr在nLen的范围内,若超长则裁减

procedure LoadFormConfig(const nForm: TForm; const nFile: string = '';
 const nIniF: TIniFile = nil);
//载入窗体信息
procedure SaveFormConfig(const nForm: TForm; const nFile: string = '';
 const nIniF: TIniFile = nil);
//存储窗体信息

procedure InitSystemEnvironment;
//初始化系统运行环境的变量
function GetSkinFile(var nFile: string): Boolean;
//获取统一皮肤文件
function SetSkinFile(const nFile: string): boolean;
//设置统一皮肤文件

implementation

{----------------------------------- 对话框 -----------------------------------}
//Date: 2006-07-28
//Parm: 消息内容;标题栏
//Desc: 弹出一个标题为nTitle,内容为nMsg的消息框
procedure ShowDlg(const nMsg: string; const nTitle: string = '');
var nStr: string;
begin
  if nTitle = '' then
       nStr := Application.Title
  else nStr := nTitle;
  MessageBox(GetActiveWindow, PChar(nMsg), PChar(nStr), Mb_OK + MB_ICONINFORMATION);
end;

//Date: 2006-07-28
//Parm: 消息内容;标题栏
//Desc: 弹出询问消息框,点击确定返回真
function QueryDlg(const nMsg: string; const nTitle: string = ''): boolean;
var nStr: string;
begin
  if nTitle = '' then
       nStr := Application.Title
  else nStr := nTitle;

  Result := MessageBox(GetActiveWindow, PChar(nMsg),
              PChar(nStr), Mb_YesNo + MB_ICONQUESTION) = IDYES;
end;

//Date: 2006-11-23
//Parm: 消息内容;标题栏
//Desc: 弹出带取消按钮的询问消息框,点击确定返回真
function QueryDlg2(const nMsg: string; const nTitle: string = ''): Integer;
var nStr: string;
begin
  if nTitle = '' then
       nStr := Application.Title
  else nStr := nTitle;

  Result := MessageBox(GetActiveWindow, PChar(nMsg),
              PChar(nStr), Mb_YesNoCancel + MB_ICONQUESTION);
end;

//Date: 2007-01-08
//Parm: 字符串;最大长度
//Desc: 将nStr限定在nLen长度内
function FixLenStr(const nStr: string; const nLen: integer): string;
var nTmp: string;
    sStr: WideString;
    nA,nB,nSLen,nValue: integer;
begin
  nValue := Length(nStr);
  if nValue <= nLen then
  begin
    Result := nStr; Exit;
  end;

  sStr := nStr;
  nSLen := Length(sStr);
  nValue := nValue - nLen + 3;
  //需裁掉的长度,加三个省略号

  nA := nSLen div 2;
  nB := nA;
  nTmp := Copy(sStr, nA, nB-nA+1);

  while Length(nTmp) < nValue do
  begin
    if nA > 1 then Dec(nA);
    if nB < nSLen then Inc(nB);

    if (nA = 1) or (nB = nSLen) then Break;
    nTmp := Copy(sStr, nA, nB-nA+1);
  end;
  //从中间截取一个可以裁掉的字符串

  Result := Copy(sStr, 1, nA) + '...' + Copy(sStr, nB, nSLen - nB + 1);
  //叠加字符串
end;

{---------------------------------- 窗体信息 ----------------------------------}
//Date: 2006-09-21
//Desc: 从主配置文件载入nForm的信息
procedure LoadFormConfig;
var sStr: string;
    nIni: TIniFile;
    nValue,nMax: integer;
begin
  if Assigned(nIniF) then
     nIni := nIniF else
  begin
    if nFile = '' then
         sStr := ExtractFilePath(Application.ExeName) + 'FormInfo.Ini'
    else sStr := nFile;
    
    if not FileExists(sStr) then Exit;
    nIni := TIniFile.Create(sStr);
  end;

  try
    with nForm do
    begin
      if nIni.ReadBool(Name, 'Maximized', False) = True then
         WindowState := wsMaximized else
      //最大化状态
      begin
        nMax := High(integer);
        nValue := nIni.ReadInteger(Name, 'FormTop', nMax);
        if nValue < nMax then Top := nValue;

        nValue := nIni.ReadInteger(Name, 'FormLeft', nMax);
        if nValue < nMax then Left := nValue;

        if BorderStyle = bsSizeable then
        begin
          nValue := nIni.ReadInteger(Name, 'FormWidth', nMax);
          if nValue < nMax then Width := nValue;

          nValue := nIni.ReadInteger(Name, 'FormHeight', nMax);
          if nValue < nMax then Height := nValue;
        end;
      end;
    end;
    //载入窗体位置和宽高
  finally
    if not Assigned(nIniF) then nIni.Free;
  end;
end;

//Date: 2006-09-21
//Desc: 存储nForm的信息到主配置文件
procedure SaveFormConfig;
var sStr: string;
    nIni: TIniFile;
begin
  if Assigned(nIniF) then
     nIni := nIniF else
  begin
    if nFile = '' then
         sStr := ExtractFilePath(Application.ExeName) + 'FormInfo.Ini'
    else sStr := nFile;
    nIni := TIniFile.Create(sStr);
  end;

  try
    with nForm do
    begin
      nIni.WriteInteger(Name, 'FormTop', Top);
      nIni.WriteInteger(Name, 'FormLeft', Left);
      nIni.WriteInteger(Name, 'FormWidth', Width);
      nIni.WriteInteger(Name, 'FormHeight', Height);
      nIni.WriteBool(Name, 'Maximized', WindowState = wsMaximized);
      //保存窗体位置和宽高
    end;
  finally
    if not Assigned(nIniF) then nIni.Free;
  end;
end;

{---------------------------------- 配置运行环境 ------------------------------}
//Date: 2007-01-09
//Desc: 初始化运行环境
procedure InitSystemEnvironment;
begin
  Randomize;
  ShortDateFormat := 'YYYY-MM-DD';
  gPath := ExtractFilePath(Application.ExeName);
end;

{------------------------------------ 统一皮肤 --------------------------------}
//Date: 2007-01-11
//Desc: 获取统一的皮肤文件
function GetSkinFile(var nFile: string): Boolean;
begin
  Result := False;
  with TRegistry.Create do
  try
    RootKey := HKey_Current_User;
    if OpenKey(sSkinRegKey, False) and ValueExists(sSkinRegValue) then
    begin
      nFile := ReadString(sSkinRegValue);
      if FileExists(nFile) then Result := True;
    end;
  finally
    Free;
  end;

  if not Result then
  begin
    nFile := gPath + sSkinFile;
    if FileExists(nFile) then Result := True;
  end;
end;

//Date: 2007-10-11
//Desc: 设置统一皮肤文件
function SetSkinFile(const nFile: string): boolean;
begin
  Result := False;
  with TRegistry.Create do
  try
    RootKey := HKey_Current_User;
    if OpenKey(sSkinRegKey, True) then
    begin
      WriteString(sSkinRegValue, nFile);
      Result := True;
    end;
  finally
    Free;
  end;
end;

end.
