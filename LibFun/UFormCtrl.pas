{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-09-28
  ����: �Զ�̬�����ϵĿؼ���������֤,��������

  ��ע:
  &.����Ԫ�ĺ��������ڶ�̬����Ĵ���,�����ض�����.

  Լ��:
  &.����Լ�����ڴ����ϵĿؼ�,ʹ���ض����Ա�ʾ��������Ϣ
  &.HelpContext:0:����Ϊ��,����������Ϊ��
  &.Hint:Table.Field
  &.HelpKeyWord:���ڱ�ʶ����ض�������Ҫ��,��������:
    1.�����е���������ʶ��,ʹ��"|"�ָ�
    2.ÿ�����Ӧ�ض���Լ��
      ����: C|D|>10|<100|,�����ÿ�����ݴ����ݿ�ȡ;��Чֵ�Ǹ�����,��10-100֮��.

  ���ʶ��Լ��:
  &.B: �̶�����; ����ComboBox����,����ȡֵ��Items������;
  &.C: �����,��Ҫ�����ݿ��ȡ;����ComboBox����,����SQL�ɴ���Items������;
  &.I: ����; D: ������
  &.>,<,=: ��ֵ���͵�ȡֵ��Χ
  &.NI: ��ʾ����������Insert���;NU: ��ʾ�����빹��Update���.
  &.�����ʶ�ظ�ʱ�ᱻ���ǵ�,�����ɨ�赽����Ϊ��.
*******************************************************************************}
unit UFormCtrl;

{$I LibFun.inc} 
interface

uses
  Windows, Classes, ComCtrls, Controls, DB, Forms, SysUtils, TypInfo, Variants,
  UMgrVar, ULibFun, ULibRes, UAdjustForm;

type
  TSQLFieldType = (sfStr, sfVal, sfDate, sfTime, sfDateTime);
  //string, date, time, value

function SF(const nField: string; const nValue: Variant;
 const nType: TSQLFieldType = sfStr): string;
//make sql field
function IsStrInList(const nList: TStrings; const nStr: string;
 const nFrom: integer = 0; nTo: integer = -1): Boolean;
//check if nStr is in nList

function GetTableByHint(const nCtrl: TComponent; var nTable,nField: string): Boolean;
//get Table,Field name from nCtrl.Hint
function ResetHintTable(const nCtrl: TComponent; const nOld,nNew: string): Boolean;
//change hint's table name

function ResetHintAllCtrl(const nPCtrl: TWinControl; const nOld,nNew: string): Boolean;
//change nPCtrl's all component's table name
function ResetHintAllForm(const nForm: TForm; const nOld,nNew: string): Boolean;
//change nform's all component's table name

function SetCtrlFocus(const nCtrl: TComponent): Boolean;
//focus the nCtrl Control
function IsFixRelation(const nCtrl: TComponent; const nFix: string): Boolean;
//check if nCtrl is nFix Relation

function IsValidCtrlData(const nPCtrl: TWinControl; const nTable: string;
  const nCallBack: TGetDataCallBack = nil): Boolean;
//verity all data of ctrl in nPCtrl refer to nTable
function IsValidFormData(const nForm: TForm; const nTable: string;
  const nCallBack: TGetDataCallBack = nil): Boolean;
//verity all data of ctrl in from refer to nTable

function LoadDataToCtrl(const nDataSet: TDataSet; const nPCtrl: TWinControl;
  const nTable: string = ''; const nCallBack: TSetDataCallBack = nil): Boolean;
//load Ctrl's data in nPCtrl where is refer to nTable from nData
function LoadDataToForm(const nDataSet: TDataSet; const nForm: TForm;
  const nTable: string = ''; const nCallBack: TSetDataCallBack = nil): Boolean;
//load Ctrl's data in form where is refer to nTable from nData
function LoadDataToList(const nDataSet: TDataSet; const nList: TStrings;
  const nPrefix: string = ''; const nFieldLen: Integer = 0;
  const nFieldFlag: string = ''; const nExclude: TDynamicStrArray = nil): Boolean;
//format nData's data and fill in nList

function MakeSQLByCtrl(const nPCtrl: TWinControl; const nTable,nWhere: string;
  const nIsNew: Boolean; const nCallBack: TGetDataCallBack = nil;
  const nExtFields: TStrings = nil): string;
//make insert,update SQL by Ctrl in nPCtrl which refer to nTable
function MakeSQLByForm(const nForm: TForm; const nTable,nWhere: string;
  const nIsNew: Boolean; const nCallBack: TGetDataCallBack = nil;
  const nExtFields: TStrings = nil): string;
//make insert,update SQL by Ctrl in nForm which refer to nTable
function MakeSQLByMI(const nData: array of TMacroItem;
  const nTable,nWhere: string; const nIsNew: Boolean): string;
function MakeSQLByStr(const nData: array of string;
  const nTable,nWhere: string; const nIsNew: Boolean): string;
//make insert,update SQL by data


procedure EnableNUComponent(const nPCtrl: TWinControl; const nEnable: Boolean = False);
//Set "not update" component's Enable property

implementation

//------------------------------------------------------------------------------
//Date: 2007-09-28
//Parm: ���;��,�ֶ���
//Desc: ��nCtrl.Hint��ȡ������ֶ���
function GetTableByHint(const nCtrl: TComponent; var nTable,nField: string): Boolean;
var nPos: integer;
begin
  Result := False;
  if nCtrl is TControl then
  begin
    nField := (nCtrl as TControl).Hint;  //Table.Field
    nPos := Pos('.', nField);
    if nPos < 2 then Exit;

    nTable := Copy(nField, 1, nPos - 1);
    System.Delete(nField, 1, nPos);

    nTable := Trim(nTable);
    nField := Trim(nField);
    Result := Length(nField) > 0;
  end;
end;

//Date: 2008-8-20
//Parm: ���;�ɱ���;�±���
//Desc: �滻nCtrl.Hint��ԭ��nOld��ΪnNew��
function ResetHintTable(const nCtrl: TComponent; const nOld,nNew: string): Boolean;
var nT,nF: string;
begin
  Result := False;
  if GetTableByHint(nCtrl, nT, nF) then
  begin
    if CompareText(nT, nOld) = 0 then
      (nCtrl as TControl).Hint := nNew + '.' + nF;
    Result := True;
  end;
end;

//Date: 2009-5-31
//Parm: �������ؼ�;�ɱ���;�±���
//Desc: �޸�nPCtrl�����������Hintԭ��nOld��ΪnNew��
function ResetHintAllCtrl(const nPCtrl: TWinControl; const nOld,nNew: string): Boolean;
var nList: TList;
    i,nCount: integer;
begin
  nList := TList.Create;
  try
    EnumSubCtrlList(nPCtrl, nList);
    nCount := nList.Count - 1;

    for i:=0 to nCount do
      ResetHintTable(nList[i], nOld, nNew);
    Result := True;
  finally
    nList.Free;
  end;
end;

//Desc: �޸�nForm�����������Hintԭ��nOld��ΪnNew��
function ResetHintAllForm(const nForm: TForm; const nOld,nNew: string): Boolean;
begin
  Result := ResetHintAllCtrl(nForm, nOld, nNew);
end;

//Date: 2007-09-28
//Parm: �ؼ�
//Desc: ʹnCtrl��ȡ����
function SetCtrlFocus(const nCtrl: TComponent): Boolean;
var nTmp: TWincontrol;
begin
  Result := False;
  if not (Assigned(nCtrl) and (nCtrl is TWinControl)) then Exit;
  nTmp := nCtrl as TWinControl;
  if not (Assigned(nTmp.Parent) and nTmp.Visible) then Exit;

  {$IFDEF often_vcl}
  if nTmp.Parent is TTabSheet then
  begin
    (nTmp.Parent as TTabSheet).PageControl.ActivePage := nTmp.Parent as TTabSheet;
    //�л�ҳ��
    (nTmp.Parent as TTabSheet).PageControl.OnChange(nil);
  end;
  {$ENDIF}

  nTmp.SetFocus;
  //����
  Result := True;
end;

//------------------------------------------------------------------------------
//Date: 2007-10-08
//Parm: �б�;�ַ���;ɨ�跶Χ
//Desc: ���nStr�Ƿ���nList��,���ִ�Сд
function IsStrInList(const nList: TStrings; const nStr: string;
 const nFrom: integer = 0; nTo: integer = -1): Boolean;
var nTmp: string;
    i,nCount: integer;
begin
  Result := False;
  if (nList.Count < 1) or (nFrom < 0) then Exit;

  if nTo < 0 then
       nCount := nList.Count - 1
  else nCount := nTo;

  nTmp := LowerCase(nStr);
  for i:=nFrom to nCount do
   if Pos(nTmp, LowerCase(nList[i])) > 0 then
   begin
     Result := True; Exit;
   end;
end;

//Date: 2007-10-08
//Parm: ��ɨ���ַ���[in];���ؽ��[out]
//Desc: ��ȡnStr�е������ַ���,��û���򷵻�False
function GetOperateSymbol(var nStr: string): Boolean;
const
  cSymbol : array [0..4] of string = ('>=', '<=', '>', '<', '=');
var i,nHigh: integer;
begin
  Result := False;
  nHigh := High(cSymbol);

  for i:=Low(cSymbol) to nHigh do
   if Pos(cSymbol[i], nStr) = 1 then
   begin
     Result := True;
     nStr := cSymbol[i]; Break;
   end;
end;

//Date: 2007-11-15
//Parm: ��ʶ
//Desc: ��֤nFlag�Ƿ���Ч�ı�ʶ
function IsValidFlag(const nFlag: string): Boolean;
const
  cFlags : array [0..4] of string = ('C','D','I','NI','NU');
var i,nHigh: integer;
begin
  Result := False;
  nHigh := High(cFlags);

  for i:=Low(cFlags) to nHigh do
   if nFlag = cFlags[i] then
   begin
     Result := True; Break;
   end;
end;

//Desc: ������ʶ��nList��,��ʶ���ʽ:C|D|>10|<100|
function SplitFlagDomain(const nStr: string; const nList: TStrings): Boolean;
var nTmp: string;
    nIdx: integer;
begin
  Result := False;
  if not SplitStr(nStr, nList, 0, '|') then Exit;

  nIdx := 0;
  while nIdx < nList.Count do
  begin
    nTmp := nList[nIdx];
    if IsValidFlag(nTmp) then
    begin
      if nList.IndexOf(nTmp) = nIdx then
           Inc(nIdx)
      else nList.Delete(nIdx);

      Continue;
    end;

    if (not GetOperateSymbol(nTmp)) or
       (IsStrInList(nList, nTmp, 0, nIdx - 1) or
        IsStrInList(nList, nTmp, nIdx + 1)) then
         nList.Delete(nIdx)
    else Inc(nIdx);
    {-----------------------+dmzn: 2007-10-08 ------------------------
    ��ע: ����"|>=100|>10|>=20"�������,��Ȼֻ��">=20"����Ч��,������Ҫ
    �����۵�.����Ĵ��������������.
    ------------------------------------------------------------------}
  end;

  Result := nList.Count > 0;
end;

//Date: 2007-10-8
//Parm: ��ֵ;�����б�;��ʾ��Ϣ
//Desc: �ж�nNum�Ƿ�����nList�е�����
function IsValidNumber(const nNum: Double; const nList: TStrings;
  var nMsg: String): Boolean;
var nStr: string;
    i,nCount: integer;
begin
  Result := False;
  nCount := nList.Count - 1;

  for i:=0 to nCount do
  begin
    nStr := nList[i];
    if not GetOperateSymbol(nStr) then Continue;

    if nStr = '>=' then
    begin
      nStr := Copy(nList[i], 3, MaxInt);
      if IsNumber(nStr, True) and (nNum < StrToFloat(nStr)) then
      begin
        nMsg := 'ȡֵ��Χ:���ڵ���' + nStr; Exit;
      end;
    end else

    if nStr = '<=' then
    begin
      nStr := Copy(nList[i], 3, MaxInt);
      if IsNumber(nStr, True) and (nNum > StrToFloat(nStr)) then
      begin
        nMsg := 'ȡֵ��Χ:С�ڵ���' + nStr; Exit;
      end;
    end else

    if nStr = '=' then
    begin
      nStr := Copy(nList[i], 2, MaxInt);
      if IsNumber(nStr, True) and (nNum <> StrToFloat(nStr)) then
      begin
        nMsg := 'ȡֵ��Χ: ֻ�ܵ���' + nStr; Exit;
      end;
    end else

    if nStr = '>' then
    begin
      nStr := Copy(nList[i], 2, MaxInt);
      if IsNumber(nStr, True) and (nNum <= StrToFloat(nStr)) then
      begin
        nMsg := 'ȡֵ��Χ:����' + nStr; Exit;
      end;
    end else

    if nStr = '<' then
    begin
      nStr := Copy(nList[i], 2, MaxInt);
      if IsNumber(nStr, True) and (nNum >= StrToFloat(nStr)) then
      begin
        nMsg := 'ȡֵ��Χ:С��' + nStr; Exit;
      end;
    end;
  end;

  Result := True;
end;

//------------------------------------------------------------------------------
//Date: 2007-10-8
//Parm: �ؼ�;��������(A,B,C)
//Desc: ���nCtrl�Ƿ���ض��������
function IsFixRelation(const nCtrl: TComponent; const nFix: string): Boolean;
var nStr: string;
    nList: TStrings;
begin
  Result := False;
  if nCtrl is TControl then
  begin
    nList := TStringList.Create;
    nStr := Trim((nCtrl as TControl).HelpKeyword);
    
    Result := SplitFlagDomain(nStr, nList) and (nList.IndexOf(nFix) > -1);
    nList.Free;
  end;
end;

//Date: 2009-5-31
//Parm: �������ؼ�;����;���ݶ�ȡ�ص�
//Desc: ��֤nPCtrl��nTable��صĿؼ����������Ƿ�Ϸ�
function IsValidCtrlData(const nPCtrl: TWinControl; const nTable: string;
  const nCallBack: TGetDataCallBack = nil): Boolean;
var nCtrls: TList;
    nCtrl: TControl;
    nList: TStrings;
    i,nCount: integer;
    nStr,nTmp,nHint: string;
begin
  Result := False;
  nHint := gVariantManager.VarStr(sVar_DlgHintStr, sVar_DlgHintStrDef);

  nCtrls := TList.Create;
  nList := TStringList.Create;
  try
    EnumSubCtrlList(nPCtrl, nCtrls);
    nCount := nCtrls.Count - 1;

    for i:=0 to nCount do
     if GetTableByHint(TControl(nCtrls[i]), nTmp, nStr) and
        (CompareText(nTmp, nTable) = 0) then
     begin
       nCtrl := nCtrls[i];
       nStr := GetCtrlData(nCtrl, nCallBack);

       if Trim(nStr) = '' then
        if nCtrl.HelpContext = 0 then
        begin
          Continue;
        end else
        begin
          SetCtrlFocus(nCtrl);
          ShowHintMsg('����Ϊ�� �� ���ݲ���ȷ', nHint); Exit;
        end;
       //��������Ϊ��

       nTmp := Trim(nCtrl.HelpKeyword);
       SplitFlagDomain(nTmp, nList);
       //��ֱ�ʶ��

       if (nList.IndexOf('D') > -1) and (not IsNumber(nStr, True)) then
       begin
         SetCtrlFocus(nCtrl);
         ShowHintMsg('��������ȷ��С����ֵ', nHint); Exit;
       end else

       if (nList.IndexOf('I') > -1) and (not IsNumber(nStr, False)) then
       begin
         SetCtrlFocus(nCtrl);
         ShowHintMsg('��������ȷ��������ֵ', nHint); Exit;
       end;

       if IsNumber(nStr, True) and
          (not IsValidNumber(StrToFloat(nStr), nList, nTmp)) then
       begin
         SetCtrlFocus(nCtrl);
         ShowHintMsg(nTmp, nHint); Exit;
       end;
     end;

    Result := True;
  finally
    nList.Free;
    nCtrls.Free;
  end;
end;

//Date: 2007-09-28
//Parm: ����;����;���ݶ�ȡ�ص�
//Desc: ��֤nForm��nTable��صĿؼ����������Ƿ�Ϸ�
function IsValidFormData(const nForm: TForm; const nTable: string;
  const nCallBack: TGetDataCallBack = nil): Boolean;
begin
  Result := IsValidCtrlData(nForm, nTable, nCallBack);
end;

//Date: 2007-09-28
//Parm: ���ݼ�;�������ؼ�;����;����д��ص�
//Desc: �����ݼ�nData������nPCtrl��nTable��ص�����
function LoadDataToCtrl(const nDataSet: TDataSet; const nPCtrl: TWinControl;
  const nTable: string = ''; const nCallBack: TSetDataCallBack = nil): Boolean;
var nList: TList;
    nField: TField;
    i,nCount: integer;
    nStr,nTmp: string;
begin
  Result := False;
  if not (nDataSet.Active and (nDataSet.RecordCount > 0)) then Exit;

  nList := TList.Create;
  try
    EnumSubCtrlList(nPCtrl, nList);
    nCount := nList.Count - 1;

    for i:=0 to nCount do
     if GetTableByHint(TControl(nList[i]), nStr, nTmp) then
     begin
       if (nTable <> '') and (CompareText(nStr, nTable) <> 0) then Continue;
       //�������ض�����

       nField := nDataSet.FindField(nTmp);
       if Assigned(nField) then
       begin
         nStr := nField.AsString;
         SetCtrlData(TControl(nList[i]), nStr, nCallBack);
       end;
     end;

    Result := True;
    //�������
  finally
    nList.Free;
  end;
end;

//Date: 2007-09-28
//Parm: ���ݼ�;����;����;����д��ص�
//Desc: �����ݼ�nData������nForm��nTable��ص�����
function LoadDataToForm(const nDataSet: TDataSet; const nForm: TForm;
  const nTable: string = ''; const nCallBack: TSetDataCallBack = nil): Boolean;
begin
  Result := LoadDataToCtrl(nDataSet, nForm, nTable, nCallBack);
end;

//------------------------------------------------------------------------------
//Desc: ͳһ���, SW=StringWidth
function AdjustSW(const nStr: string; const nFieldLen: integer): string;
begin
  if nFieldLen > 0 then
  begin
    Result := Format('%%-%dS', [nFieldLen]);
    Result := Format(Result, [nStr]);
  end else

  if nFieldLen = 0 then
       Result := Format('%-8S', [nStr])
  else Result := nStr;
end;

//Date: 2007-10-09
//Parm: ���ݼ�;�б�;ǰ׺;�ֶο�;�ֶα��;�����ֶ�
//Desc: ��nData��ÿ����¼��ʽ������䵽nList��.
//      ��ǰ׺nPrefix<>'',�򹹽�nPrefix=XXX����������
function LoadDataToList(const nDataSet: TDataSet; const nList: TStrings;
  const nPrefix: string = ''; const nFieldLen: Integer = 0;
  const nFieldFlag: string = ''; const nExclude: TDynamicStrArray = nil): Boolean;
var nStr,nFlag: string;
    i,nCount: integer;
begin
  nList.Clear;
  nCount := nDataSet.FieldCount - 1;

  if nDataSet.RecordCount > 0 then
  begin
    if nFieldFlag = '' then
         nFlag := ' | '
    else nFlag := nFieldFlag;

    nDataSet.First;
    while not nDataSet.Eof do
    begin
      nStr := '';
      
      for i:=0 to nCount do
      with nDataSet do
      begin
        if Assigned(nExclude) and
           (StrArrayIndex(Fields[i].FieldName, nExclude) > -1) then Continue;
        //be exclude
                                                         
        if nStr <> '' then
          nStr := nStr + nFlag + AdjustSW(Fields[i].AsString, nFieldLen)
        else nStr := AdjustSW(Fields[i].AsString, nFieldLen);
      end;

      if nPrefix <> '' then
        nStr := nDataSet.FieldByName(nPrefix).AsString + '=' + Trim(nStr);
      //Ex: Data001=A����ʾ���Ѻ�����

      nList.Add(nStr);
      nDataSet.Next;
    end;
  end;

  Result := nList.Count > 0;
  //Resultû��ʵ������
end;

//------------------------------------------------------------------------------
//Date: 2007-09-28
//Parm: �������ؼ�;����;����;�Ƿ����;�����ֶ�;���ݶ�ȡ�ص�
//Desc: ����nPCtrl�ؼ���Ϣ��֯nTable���Insert,Update SQL���
function MakeSQLByCtrl(const nPCtrl: TWinControl; const nTable,nWhere: string;
  const nIsNew: Boolean; const nCallBack: TGetDataCallBack = nil;
  const nExtFields: TStrings = nil): string;
var nCtrls: TList;
    nList: TStrings;
    i,nCount,nPos: integer;
    nStr,nPrefix,nMain,nPostfix,nTmp: string;
begin
  Result := '';

  if nIsNew then
  begin
    nPrefix := 'Insert into ' + nTable + '(';
    nPostfix := '';
  end else
  begin
    nPrefix := 'Update ' + nTable + ' Set ';
    nPostfix := ' Where ' + nWhere;
  end;

  nCtrls := TList.Create;
  nList := TStringList.Create;
  try
    nMain := '';
    if Assigned(nExtFields) then
    begin
      nCount := nExtFields.Count - 1;

      for i:=0 to nCount do
      begin
        nStr := Trim(nExtFields[i]);
        nPos := Pos('=', nStr);
        if nPos < 2 then Continue;

        if nIsNew then
        begin
          nTmp := Copy(nStr, 1, nPos - 1);
          System.Delete(nStr, 1, nPos);

          if nMain = '' then
               nMain := nTmp
          else nMain := nMain + ',' + nTmp;

          if nPostfix = '' then
               nPostfix := nStr
          else nPostfix := nPostfix + ',' + nStr;
        end else
        begin
          if nMain = '' then
               nMain := nStr
          else nMain := nMain + ',' + nStr;
        end;
      end;
    end;

    if Assigned(nPCtrl) then
      EnumSubCtrlList(nPCtrl, nCtrls);
    nCount := nCtrls.Count - 1;

    for i:=0 to nCount do
     if GetTableByHint(TControl(nCtrls[i]), nTmp, nStr) and
        (CompareText(nTmp, nTable) = 0) then
     begin
       nTmp := Trim(TControl(nCtrls[i]).HelpKeyword);
       SplitFlagDomain(nTmp, nList);
       //nStr=Field

       if (nIsNew and (nList.IndexOf('NI') > -1)) or
          ((not nIsNew) and (nList.IndexOf('NU') > -1)) then Continue;
       //�����빹��Insert��Update���

       if nIsNew then
       begin
         if nMain = '' then
              nMain := nStr
         else nMain := nMain + ',' + nStr;

         nStr := GetCtrlData(nCtrls[i], nCallBack);
         if (nList.IndexOf('D') > -1) or (nList.IndexOf('I') > -1) then
         begin
           if Trim(nStr) = '' then nStr := '0';
         end else nStr := '''' + nStr + '''';

         if nPostfix = '' then
              nPostfix := nStr
         else nPostfix := nPostfix + ',' + nStr;
       end else
       begin
         if nMain = '' then
              nMain := nStr + '='
         else nMain := nMain + ',' + nStr + '=';

         nStr := GetCtrlData(nCtrls[i], nCallBack);
         if (nList.IndexOf('D') > -1) or (nList.IndexOf('I') > -1) then
         begin
           if Trim(nStr) = '' then nStr := '0';
           nMain := nMain + nStr;
         end else nMain := nMain + '''' + nStr + '''';
       end;
     end;
  finally
     nList.Free;
     nCtrls.Free;
  end;

  if nIsNew then
  begin
    nMain := nMain + ') Values(';
    nPostfix := nPostfix + ')';
  end;

  Result := nPrefix + nMain + nPostfix;
  //����SQL���
end;

//Date: 2007-09-28
//Parm: ����;����;����;�Ƿ����;���ݶ�ȡ�ص�;�����ֶ�
//Desc: ����nForm�ؼ���Ϣ��֯nTable���Insert,Update SQL���
function MakeSQLByForm(const nForm: TForm; const nTable,nWhere: string;
  const nIsNew: Boolean; const nCallBack: TGetDataCallBack = nil;
  const nExtFields: TStrings = nil): string;
begin
  Result := MakeSQLByCtrl(nForm, nTable, nWhere, nIsNew, nCallBack, nExtFields);
end;

//Date: 2009-09-21
//Parm: ����;����;����;�Ƿ����
//Desc: ����nData���nTable���Insert,nUpdate SQL���
function MakeSQLByMI(const nData: array of TMacroItem;
  const nTable,nWhere: string; const nIsNew: Boolean): string;
var nList: TStrings;
    i,nCount: integer;
begin
  nList := TStringList.Create;
  try
    nCount := High(nData);
    for i:=Low(nData) to nCount do
      nList.Add(nData[i].FMacro + '=' + nData[i].FValue);
    Result := MakeSQLByCtrl(nil, nTable, nWhere, nIsNew, nil, nList);
  finally
    nList.Free;
  end;
end;

//Date: 2009-09-21
//Parm: ����;����;����;�Ƿ����
//Desc: ����nData���nTable���Insert,nUpdate SQL���
function MakeSQLByStr(const nData: array of string;
  const nTable,nWhere: string; const nIsNew: Boolean): string;
var nList: TStrings;
    i,nCount: integer;
begin
  nList := TStringList.Create;
  try
    nCount := High(nData);
    for i:=Low(nData) to nCount do
      nList.Add(nData[i]);
    Result := MakeSQLByCtrl(nil, nTable, nWhere, nIsNew, nil, nList);
  finally
    nList.Free;
  end;
end;

//Date: 2011-6-30
//Parm: �ֶ�;ֵ;����
//Desc: ����MakeSQLByStr���������
function SF(const nField: string; const nValue: Variant;
 const nType: TSQLFieldType): string;
var nVal: string;
begin
  if nType = sfDateTime then
  begin
    Result := FormatDateTime('yyyy-mm-dd hh:nn:ss:zzz', nValue);
    Result := Format('%s=''%s''', [nField, Result]);
    Exit;
  end;

  nVal := VarToStr(nValue);
  //convert type

  case nType of
   sfStr: Result := Format('%s=''%s''', [nField, nVal]);
   sfDate: Result := Format('%s=''%s''', [nField, Date2Str(Str2Date(nVal))]);
   sfTime: Result := Format('%s=''%s''', [nField, Time2Str(Str2Time(nVal))]);
   sfVal:
    begin
      if nVal = '' then
           Result := Format('%s=%d', [nField, 0])
      else Result := Format('%s=%s', [nField, nVal]);
    end
   else Result := '';
  end;
end;

//Date: 2007-11-15
//Parm: �������ؼ�;�Ƿ�����
//Desc: ����nPCtrl�ϲ����빹��Update����齨��Enable����
procedure EnableNUComponent(const nPCtrl: TWinControl; const nEnable: Boolean = False);
var nStr: string;
    nList: TList;
    i,nCount: integer;
    nCtrl: TComponent;
begin
  if nEnable then
       nStr := 'True'
  else nStr := 'False';

  nList := TList.Create;
  try
    EnumSubCtrlList(nPCtrl, nList);
    nCount := nList.Count - 1;

    for i:=0 to nCount do
    begin
      nCtrl := nList[i];
      if IsFixRelation(nCtrl, 'NU') and IsPublishedProp(nCtrl, 'Enabled') and
         (PropType(nCtrl, 'Enabled') = tkEnumeration) then
         SetEnumProp(nCtrl, 'Enabled', nStr);
    end;
  finally
    nList.Free;
  end;
end;

end.
