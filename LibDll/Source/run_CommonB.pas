{*******************************************************************************
  ����: dmzn 2007-02-25
  ����: ���ú�����ڶ�����Ԫ,(�ļ����ļ��в���)
*******************************************************************************}
unit run_CommonB;

interface

uses
  Windows, SysUtils;

function File_ShortPath(const nFile: string): string;
//��ȡ��·��
function File_IsSame(const nFile1,nFile2: string): Boolean;
//�ж������ļ��Ƿ�·����ͬ

implementation

//Date: 2007-02-25
//Parm: �ļ�ȫ·��
//Desc: ����nFile��8.3��·��
function File_ShortPath(const nFile: string): string;
begin
  Result := ExtractShortPathName(nFile);
end;

//Date: 2006-02-25
//Parm: ���Աȵ��ļ�
//Desc: �Ա�nFile1,nFile2�Ƿ�Ϊͬһ���ļ�
function File_IsSame(const nFile1,nFile2: string): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := ExtractFilePath(nFile1);
  nStr := ExtractRelativePath(nStr, nFile2);

  if ExtractFileName(nStr) = nStr then
  begin
    //ֻʣ���ļ���,���������ļ���ͬһ��Ŀ¼
    nStr := LowerCase(ExtractFileName(nFile1));
    if nStr = LowerCase(ExtractFileName(nFile2)) then Result := True;
  end;
end;

end.
