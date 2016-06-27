{*******************************************************************************
  作者: dmzn 2007-02-25
  描述: 常用函数库第二个单元,(文件与文件夹操作)
*******************************************************************************}
unit run_CommonB;

interface

uses
  Windows, SysUtils;

function File_ShortPath(const nFile: string): string;
//获取短路径
function File_IsSame(const nFile1,nFile2: string): Boolean;
//判断两个文件是否路径相同

implementation

//Date: 2007-02-25
//Parm: 文件全路径
//Desc: 返回nFile的8.3短路径
function File_ShortPath(const nFile: string): string;
begin
  Result := ExtractShortPathName(nFile);
end;

//Date: 2006-02-25
//Parm: 待对比的文件
//Desc: 对比nFile1,nFile2是否为同一个文件
function File_IsSame(const nFile1,nFile2: string): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := ExtractFilePath(nFile1);
  nStr := ExtractRelativePath(nStr, nFile2);

  if ExtractFileName(nStr) = nStr then
  begin
    //只剩下文件名,表明两个文件在同一个目录
    nStr := LowerCase(ExtractFileName(nFile1));
    if nStr = LowerCase(ExtractFileName(nFile2)) then Result := True;
  end;
end;

end.
