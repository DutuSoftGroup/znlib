{*******************************************************************************
  ����: dmzn 2007-01-08
  ����: ���ú������һ����Ԫ,(�������)
*******************************************************************************}
unit run_CommonA;

interface

uses
  Windows, SysUtils, IniFiles, Forms, Registry, run_Const;

procedure ShowDlg(const nMsg: string; const nTitle: string = '');
//��Ϣ��
function QueryDlg(const nMsg: string; const nTitle: string = ''): boolean;
//ѯ�ʶԻ���
function QueryDlg2(const nMsg: string; const nTitle: string = ''): Integer;
//��ȡ����ť��ѯ�ʶԻ���

function FixLenStr(const nStr: string; const nLen: integer): string;
//�趨nStr��nLen�ķ�Χ��,��������ü�

procedure LoadFormConfig(const nForm: TForm; const nFile: string = '';
 const nIniF: TIniFile = nil);
//���봰����Ϣ
procedure SaveFormConfig(const nForm: TForm; const nFile: string = '';
 const nIniF: TIniFile = nil);
//�洢������Ϣ

procedure InitSystemEnvironment;
//��ʼ��ϵͳ���л����ı���
function GetSkinFile(var nFile: string): Boolean;
//��ȡͳһƤ���ļ�
function SetSkinFile(const nFile: string): boolean;
//����ͳһƤ���ļ�

implementation

{----------------------------------- �Ի��� -----------------------------------}
//Date: 2006-07-28
//Parm: ��Ϣ����;������
//Desc: ����һ������ΪnTitle,����ΪnMsg����Ϣ��
procedure ShowDlg(const nMsg: string; const nTitle: string = '');
var nStr: string;
begin
  if nTitle = '' then
       nStr := Application.Title
  else nStr := nTitle;
  MessageBox(GetActiveWindow, PChar(nMsg), PChar(nStr), Mb_OK + MB_ICONINFORMATION);
end;

//Date: 2006-07-28
//Parm: ��Ϣ����;������
//Desc: ����ѯ����Ϣ��,���ȷ��������
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
//Parm: ��Ϣ����;������
//Desc: ������ȡ����ť��ѯ����Ϣ��,���ȷ��������
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
//Parm: �ַ���;��󳤶�
//Desc: ��nStr�޶���nLen������
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
  //��õ��ĳ���,������ʡ�Ժ�

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
  //���м��ȡһ�����Բõ����ַ���

  Result := Copy(sStr, 1, nA) + '...' + Copy(sStr, nB, nSLen - nB + 1);
  //�����ַ���
end;

{---------------------------------- ������Ϣ ----------------------------------}
//Date: 2006-09-21
//Desc: ���������ļ�����nForm����Ϣ
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
      //���״̬
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
    //���봰��λ�úͿ��
  finally
    if not Assigned(nIniF) then nIni.Free;
  end;
end;

//Date: 2006-09-21
//Desc: �洢nForm����Ϣ���������ļ�
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
      //���洰��λ�úͿ��
    end;
  finally
    if not Assigned(nIniF) then nIni.Free;
  end;
end;

{---------------------------------- �������л��� ------------------------------}
//Date: 2007-01-09
//Desc: ��ʼ�����л���
procedure InitSystemEnvironment;
begin
  Randomize;
  ShortDateFormat := 'YYYY-MM-DD';
  gPath := ExtractFilePath(Application.ExeName);
end;

{------------------------------------ ͳһƤ�� --------------------------------}
//Date: 2007-01-11
//Desc: ��ȡͳһ��Ƥ���ļ�
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
//Desc: ����ͳһƤ���ļ�
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
