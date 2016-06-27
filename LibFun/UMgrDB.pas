{*******************************************************************************
  ����: dmzn@163.com 2010-10-25
  ����: ���ݿ������غ���
*******************************************************************************}
unit UMgrDB;

interface

uses
  Windows, Classes, DB, SysUtils, ULibFun;

type
  TMakeInsertProgress = procedure (const nPos: Cardinal) of Object;
  //��������

function DB_MakeInsertSQL(const nTable: string; const nDS: TDataSet;
 const nList: TStrings; const nProgress: TMakeInsertProgress = nil;
 const nSingleLine: Boolean = False): Boolean;
//����Insert���
function DB_SingleLineSQL(const nSQL: string; const nEncrypt: Boolean): string;
//����sql

implementation

const
  cFieldStr: set of TFieldType = [ftString, ftWideString];           
  //�ַ�����

  cFieldInt: set of TFieldType = [ftSmallint, ftInteger, ftWord, ftFloat,
          ftBCD, ftLargeint];
  //��ֵ����

  cValidFieldType: set of TFieldType = [ftString, ftSmallint, ftInteger,
          ftWord, ftBoolean, ftFloat, ftBCD, ftDate, ftTime, ftDateTime,
          ftWideString, ftLargeint];
  //֧������

//------------------------------------------------------------------------------
//Date: 2010-12-8
//Parm: sql���;True:�����ݴ���Ϊ����,False:��ԭ����
//Desc: ����SQL����������лس��������ַ�
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
//Parm: ������;���ݼ�;����SQL
//Desc: ��nDS��ǰ���������Insert���
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
    end else //�ַ�����

    if nType in cFieldInt then
    begin
      nStr := nDS.Fields[i].AsString;
      if not IsNumber(nStr, True) then
        nStr := '0';
      nSuffix := nSuffix + Format('%s,', [nStr]);
    end else //��ֵ����

    if nType = ftDate then
      nSuffix := nSuffix + Format('''%s'',', [Date2Str(nDS.Fields[i].AsDateTime)])
    else //��������

    if nType = ftTime then
      nSuffix := nSuffix + Format('''%s'',', [Time2Str(nDS.Fields[i].AsDateTime)])
    else //ʱ������

    if nType = ftDateTime then
      nSuffix := nSuffix + Format('''%s'',', [DateTime2Str(nDS.Fields[i].AsDateTime)]);
    //����ʱ��
  end;

  nCount := Length(nPrefix);
  if Copy(nPrefix, nCount, 1) = ',' then
    System.Delete(nPrefix, nCount, 1);
  //����ǰ׺

  nCount := Length(nSuffix);
  if Copy(nSuffix, nCount, 1) = ',' then
    System.Delete(nSuffix, nCount, 1);
  //�����׺

  Result := Format('%s) Values(%s)', [nPrefix, nSuffix]);
  //�ϲ����
end;

//Date: 2010-10-25
//Parm: ������;���ݼ�;����б�;���Ȼص�;����SQL
//Desc: ��nDS�е����������Insert���,����nList��
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
