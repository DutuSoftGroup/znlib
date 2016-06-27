{*******************************************************************************
  作者: dmzn@ylsoft.com 2007-09-28
  描述: 对动态窗体上的控件做数据验证,数据填充等

  备注:
  &.本单元的函数适用于动态载入的窗体,用于特定操作.

  约定:
  &.以下约定用于窗体上的控件,使用特定属性表示其它的信息
  &.HelpContext:0:允许为空,其它不允许为空
  &.Hint:Table.Field
  &.HelpKeyWord:用于标识组件特定的数据要求,具体如下:
    1.可用有单个或多个标识域,使用"|"分割
    2.每个域对应特定的约定
      例如: C|D|>10|<100|,表明该框的内容从数据库取;有效值是浮点型,在10-100之间.

  域标识的约定:
  &.B: 固定关联; 对于ComboBox而言,它的取值在Items属性中;
  &.C: 表关联,需要从数据库读取;对于ComboBox而言,它的SQL可存于Items属性中;
  &.I: 整形; D: 浮点型
  &.>,<,=: 数值类型的取值范围
  &.NI: 表示不参数构建Insert语句;NU: 表示不参与构建Update语句.
  &.当域标识重复时会被覆盖掉,以最后扫描到的域为主.
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
//Parm: 组件;表,字段名
//Desc: 从nCtrl.Hint中取出表和字段名
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
//Parm: 组件;旧表名;新表名
//Desc: 替换nCtrl.Hint中原有nOld表为nNew表
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
//Parm: 父容器控件;旧表名;新表名
//Desc: 修改nPCtrl上所有组件的Hint原有nOld表为nNew表
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

//Desc: 修改nForm上所有组件的Hint原有nOld表为nNew表
function ResetHintAllForm(const nForm: TForm; const nOld,nNew: string): Boolean;
begin
  Result := ResetHintAllCtrl(nForm, nOld, nNew);
end;

//Date: 2007-09-28
//Parm: 控件
//Desc: 使nCtrl获取焦点
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
    //切换页面
    (nTmp.Parent as TTabSheet).PageControl.OnChange(nil);
  end;
  {$ENDIF}

  nTmp.SetFocus;
  //激活
  Result := True;
end;

//------------------------------------------------------------------------------
//Date: 2007-10-08
//Parm: 列表;字符串;扫描范围
//Desc: 检测nStr是否在nList中,不分大小写
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
//Parm: 待扫描字符串[in];返回结果[out]
//Desc: 获取nStr中的运算字符串,若没有则返回False
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
//Parm: 标识
//Desc: 验证nFlag是否有效的标识
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

//Desc: 解析标识域到nList中,标识域格式:C|D|>10|<100|
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
    备注: 类似"|>=100|>10|>=20"这种情况,显然只有">=20"是有效的,所以需要
    进行折叠.上面的代码完整这个动作.
    ------------------------------------------------------------------}
  end;

  Result := nList.Count > 0;
end;

//Date: 2007-10-8
//Parm: 数值;条件列表;提示消息
//Desc: 判断nNum是否满足nList中的条件
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
        nMsg := '取值范围:大于等于' + nStr; Exit;
      end;
    end else

    if nStr = '<=' then
    begin
      nStr := Copy(nList[i], 3, MaxInt);
      if IsNumber(nStr, True) and (nNum > StrToFloat(nStr)) then
      begin
        nMsg := '取值范围:小于等于' + nStr; Exit;
      end;
    end else

    if nStr = '=' then
    begin
      nStr := Copy(nList[i], 2, MaxInt);
      if IsNumber(nStr, True) and (nNum <> StrToFloat(nStr)) then
      begin
        nMsg := '取值范围: 只能等于' + nStr; Exit;
      end;
    end else

    if nStr = '>' then
    begin
      nStr := Copy(nList[i], 2, MaxInt);
      if IsNumber(nStr, True) and (nNum <= StrToFloat(nStr)) then
      begin
        nMsg := '取值范围:大于' + nStr; Exit;
      end;
    end else

    if nStr = '<' then
    begin
      nStr := Copy(nList[i], 2, MaxInt);
      if IsNumber(nStr, True) and (nNum >= StrToFloat(nStr)) then
      begin
        nMsg := '取值范围:小于' + nStr; Exit;
      end;
    end;
  end;

  Result := True;
end;

//------------------------------------------------------------------------------
//Date: 2007-10-8
//Parm: 控件;关联类型(A,B,C)
//Desc: 检测nCtrl是否表特定关联组件
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
//Parm: 父容器控件;表名;数据读取回调
//Desc: 验证nPCtrl上nTable相关的控件数据类型是否合法
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
          ShowHintMsg('不能为空 或 内容不正确', nHint); Exit;
        end;
       //内容允许为空

       nTmp := Trim(nCtrl.HelpKeyword);
       SplitFlagDomain(nTmp, nList);
       //拆分标识域

       if (nList.IndexOf('D') > -1) and (not IsNumber(nStr, True)) then
       begin
         SetCtrlFocus(nCtrl);
         ShowHintMsg('请输入正确的小数数值', nHint); Exit;
       end else

       if (nList.IndexOf('I') > -1) and (not IsNumber(nStr, False)) then
       begin
         SetCtrlFocus(nCtrl);
         ShowHintMsg('请输入正确的整形数值', nHint); Exit;
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
//Parm: 窗体;表名;数据读取回调
//Desc: 验证nForm上nTable相关的控件数据类型是否合法
function IsValidFormData(const nForm: TForm; const nTable: string;
  const nCallBack: TGetDataCallBack = nil): Boolean;
begin
  Result := IsValidCtrlData(nForm, nTable, nCallBack);
end;

//Date: 2007-09-28
//Parm: 数据集;父容器控件;表名;数据写入回调
//Desc: 从数据集nData中载入nPCtrl上nTable相关的数据
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
       //关联到特定表上

       nField := nDataSet.FindField(nTmp);
       if Assigned(nField) then
       begin
         nStr := nField.AsString;
         SetCtrlData(TControl(nList[i]), nStr, nCallBack);
       end;
     end;

    Result := True;
    //载入完毕
  finally
    nList.Free;
  end;
end;

//Date: 2007-09-28
//Parm: 数据集;窗体;表名;数据写入回调
//Desc: 从数据集nData中载入nForm上nTable相关的数据
function LoadDataToForm(const nDataSet: TDataSet; const nForm: TForm;
  const nTable: string = ''; const nCallBack: TSetDataCallBack = nil): Boolean;
begin
  Result := LoadDataToCtrl(nDataSet, nForm, nTable, nCallBack);
end;

//------------------------------------------------------------------------------
//Desc: 统一宽度, SW=StringWidth
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
//Parm: 数据集;列表;前缀;字段宽;字段标记;忽略字段
//Desc: 将nData的每条记录格式化后填充到nList中.
//      若前缀nPrefix<>'',则构建nPrefix=XXX这样的数据
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
      //Ex: Data001=A、显示的友好数据

      nList.Add(nStr);
      nDataSet.Next;
    end;
  end;

  Result := nList.Count > 0;
  //Result没有实质意义
end;

//------------------------------------------------------------------------------
//Date: 2007-09-28
//Parm: 父容器控件;表名;条件;是否添加;附加字段;数据读取回调
//Desc: 依据nPCtrl控件信息组织nTable表的Insert,Update SQL语句
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
       //不参与构建Insert或Update语句

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
  //完整SQL语句
end;

//Date: 2007-09-28
//Parm: 窗体;表名;条件;是否添加;数据读取回调;附加字段
//Desc: 依据nForm控件信息组织nTable表的Insert,Update SQL语句
function MakeSQLByForm(const nForm: TForm; const nTable,nWhere: string;
  const nIsNew: Boolean; const nCallBack: TGetDataCallBack = nil;
  const nExtFields: TStrings = nil): string;
begin
  Result := MakeSQLByCtrl(nForm, nTable, nWhere, nIsNew, nCallBack, nExtFields);
end;

//Date: 2009-09-21
//Parm: 数据;表名;条件;是否田间
//Desc: 依据nData组件nTable表的Insert,nUpdate SQL语句
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
//Parm: 数据;表名;条件;是否田间
//Desc: 依据nData组件nTable表的Insert,nUpdate SQL语句
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
//Parm: 字段;值;类型
//Desc: 构建MakeSQLByStr所需的数据
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
//Parm: 父容器控件;是否启用
//Desc: 设置nPCtrl上不参与构建Update语句组建的Enable属性
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
