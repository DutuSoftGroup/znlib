{*******************************************************************************
  作者: dmzn@163.com 2010-10-25
  描述: 数据库操作相关函数
*******************************************************************************}
unit UMgrDB;

interface

uses
  Windows, Classes, DB, SysUtils, ULibFun;

type
  TMakeInsertProgress = procedure (const nPos: Cardinal) of Object;
  //构建进度

function DB_MakeInsertSQL(const nTable: string; const nDS: TDataSet;
 const nList: TStrings; const nProgress: TMakeInsertProgress = nil;
 const nSingleLine: Boolean = False): Boolean;
//构建Insert语句
function DB_SingleLineSQL(const nSQL: string; const nEncrypt: Boolean): string;
//单行sql

implementation

const
  cFieldStr: set of TFieldType = [ftString, ftWideString];           
  //字符类型

  cFieldInt: set of TFieldType = [ftSmallint, ftInteger, ftWord, ftFloat,
          ftBCD, ftLargeint];
  //数值类型

  cValidFieldType: set of TFieldType = [ftString, ftSmallint, ftInteger,
          ftWord, ftBoolean, ftFloat, ftBCD, ftDate, ftTime, ftDateTime,
          ftWideString, ftLargeint];
  //支持类型

//------------------------------------------------------------------------------
//Date: 2010-12-8
//Parm: sql语句;True:将内容处理为单行,False:还原内容
//Desc: 处理SQL语句中内容有回车等特殊字符
function DB_SingleLineSQL(const nSQL: string; const nEncrypt: Boolean): string;
begin
  if nEncrypt then
  begin
    Result := StringReplace(nSQL, #9, '&9;', [rfReplaceAll]);
    Result := StringReplace(Result, #10, '&a;', [rfReplaceAll]);
    Result := StringReplace(Result, #13, '&c;', [rfReplaceAll]);
    Result := StringReplace(Result, '''', '&p;', [rfReplaceAll]);
  end else
  begin
    Result := StringReplace(nSQL, '&9;', #9, [rfReplaceAll]);
    Result := StringReplace(Result, '&a;', #10, [rfReplaceAll]);
    Result := StringReplace(Result, '&c;', #13, [rfReplaceAll]);
    Result := StringReplace(Result, '&p;', '''', [rfReplaceAll]);
  end;
end;

//Date: 2010-10-25
//Parm: 表名称;数据集;单行SQL
//Desc: 将nDS当前数据整理成Insert语句
function BuildInsertSQL(const nTable: string; const nDS: TDataSet;
 const nSingleLine: Boolean): string;
var nType: TFieldType;
    i,nCount: Integer;
    nStr,nPrefix,nSuffix: string;
begin
  nSuffix := '';
  nPrefix := 'Insert Into ' + nTable + '(';
  nCount := nDS.FieldCount - 1;
  
  for i:=0 to nCount do
  begin
    nType := nDS.Fields[i].DataType;
    if not (nType in cValidFieldType) then Continue;

    nPrefix := nPrefix + nDS.Fields[i].FieldName + ',';
    if nType in cFieldStr then
    begin
      nStr := Trim(nDS.Fields[i].AsString);
      if nSingleLine then
        nStr := DB_SingleLineSQL(nStr, True);
      nSuffix := nSuffix + Format('''%s'',', [nStr]);
    end else //字符类型

    if nType in cFieldInt then
    begin
      nStr := nDS.Fields[i].AsString;
      if not IsNumber(nStr, True) then
        nStr := '0';
      nSuffix := nSuffix + Format('%s,', [nStr]);
    end else //数值类型

    if nType = ftDate then
      nSuffix := nSuffix + Format('''%s'',', [Date2Str(nDS.Fields[i].AsDateTime)])
    else //日期类型

    if nType = ftTime then
      nSuffix := nSuffix + Format('''%s'',', [Time2Str(nDS.Fields[i].AsDateTime)])
    else //时间类型

    if nType = ftDateTime then
      nSuffix := nSuffix + Format('''%s'',', [DateTime2Str(nDS.Fields[i].AsDateTime)]);
    //日期时间
  end;

  nCount := Length(nPrefix);
  if Copy(nPrefix, nCount, 1) = ',' then
    System.Delete(nPrefix, nCount, 1);
  //处理前缀

  nCount := Length(nSuffix);
  if Copy(nSuffix, nCount, 1) = ',' then
    System.Delete(nSuffix, nCount, 1);
  //处理后缀

  Result := Format('%s) Values(%s)', [nPrefix, nSuffix]);
  //合并结果
end;

//Date: 2010-10-25
//Parm: 表名称;数据集;结果列表;进度回调;单行SQL
//Desc: 将nDS中的数据整理成Insert语句,存入nList中
function DB_MakeInsertSQL(const nTable: string; const nDS: TDataSet;
 const nList: TStrings; const nProgress: TMakeInsertProgress;
 const nSingleLine: Boolean): Boolean;
var nPos: Cardinal;
begin
  Result := nDS.Active and (nDS.RecordCount > 0);
  if not Result then Exit;

  nPos := 0;
  nDS.First;

  while not nDS.Eof do
  begin
    nList.Add(BuildInsertSQL(nTable, nDS, nSingleLine));
    nDS.Next;

    Inc(nPos);
    if Assigned(nProgress) then nProgress(nPos);
  end;
end;

end.
