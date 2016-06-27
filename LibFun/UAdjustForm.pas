{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-08-08
  ����: ΢�������Ͽؼ������ݸ�ʽ,����ĳЩ�����Ӧ��

  ��ע:
  &.����Combox�ؼ�,��Items������ʽΪ:aaa=bbb,��aaa������Items[i].object��,
    ��ʾ��Ϊbbb.�����û�ѡ��bbb����ʱ,��������Ч����Ϊaaa.
  &.��������AdjustCtrlData��ReleaseCtrlData��Գ���,��֤�������ڴ�й©.
  &.��GetCtrlData,SetCtrlDataʱ,�ص����������Զ�������ݵĴ���,����True��ʾ�ص�
    �ɹ�,������ִ��Ĭ�ϵĲ���.
*******************************************************************************}
unit UAdjustForm;

{$I LibFun.inc}      
interface

uses
  Windows, Forms, Classes, Controls, StdCtrls, SysUtils, TypInfo, ComCtrls,
  ULibFun;

type
  PStringsItemData = ^TStringsItemData;
  TStringsItemData = record
    FString: string;
    FInteger: Integer;
    FPointer: Pointer;
    FVariant: Variant;
  end;
  //data combin with tstrings

  TGetDataCallBack = procedure (Sender: TObject; var nData: string) of Object;
  //get sender's data
  TSetDataCallBack = function (Sender: TObject; const nData: string): Boolean of Object;
  //set sender's data
  TAdjustCallBack = procedure (Sender: TObject; var nCanAdjust: Boolean) of Object;
  //ask for adjust sender

procedure EnumSubCtrlList(const nPCtrl: TWinControl; const nList: TList);
//enum all sub controls

procedure AdjustCtrlData(const nPCtrl: TWinControl;
  const nCallBack: TAdjustCallBack = nil);
procedure ReleaseCtrlData(const nPCtrl: TWinControl;
  const nCallBack: TAdjustCallBack = nil);
//adjust control's data in nForm window

procedure AdjustStringsItem(const nList: TStrings; const nRelease: Boolean);
//adjust TStrings
function InsertStringsItem(const nList: TStrings; const nStr: string;
  const nIdx: integer = -1): Integer;
//new item
function GetStringsItemData(const nList: TStrings; const nIdx: integer): string;
function GetStringsItemData2(const nList: TStrings;
  const nIdx: Integer): PStringsItemData;
function GetStringsItemIndex(const nList: TStrings; const nValue: string): Integer;
//get or set value

procedure AdjustComboBox(const nCtrl: TComboBox; const nRelease: Boolean);
//adjust combox's data
procedure AdjustCXComboBoxItem(const nCtrl: TObject; const nRelease: Boolean);
//adjust cxCombobox's data
function GetCtrlByName(const nForm: TForm; const nCtrl: string;
  const nType: TComponentClass ): TComponent;
//get nCtrl component in nForm window

function GetCtrlData(const nCtrl: TComponent;
  const nCallBack: TGetDataCallBack = nil): string;
//get nCtrl's data
function GetCtrlDataByName(const nForm: TForm; const nCtrl: string): string;
//get nCtrl's data in nForm window

function SetCtrlData(const nCtrl: TComponent; const nValue: string;
  const nCallBack: TSetDataCallBack = nil): Boolean;
//set nCtrl's data as nValue
function SetCtrlDataByName(const nForm: TForm;const nCtrl,nValue: string): Boolean;
//set nCtrl's data in nForm window

function SetCtrlMaxLen(const nCtrl: TComponent; const nMaxLen: integer): Boolean;
//set nCtrl's MaxLength property
function SetCtrlCharCase(const nCtrl: TComponent): Boolean;
//set nCtrl's CharCase property

implementation

//Date: 2009-5-31
//Parm: �������ؼ�;�б�
//Desc: ö��nPCtrl�������ӿؼ�,����nList��
procedure EnumSubCtrlList(const nPCtrl: TWinControl; const nList: TList);
var i,nCount: integer;
begin
  nCount := nPCtrl.ControlCount - 1;
  for i:=0 to nCount do
  begin
    nList.Add(nPCtrl.Controls[i]);
    if nPCtrl.Controls[i] is TWinControl then
      EnumSubCtrlList(nPCtrl.Controls[i] as TWinControl, nList);
    //enum sub ctrls
  end;
end;

//------------------------------------------------------------------------------
//Date: 2009-6-2
//Parm: �б�;�Ƿ��ͷ�
//Desc: ����nList������Ԫ��
procedure AdjustStringsItem(const nList: TStrings; const nRelease: Boolean);
var nStr: string;
    i,nCount,nPos: integer;
    nData: PStringsItemData;
begin
  nCount := nList.Count - 1;
  if nCount < 0 then Exit;

  for i:=0 to nCount do
  begin
    if nRelease then
    begin
      if Assigned(nList.Objects[i]) then
      begin
        nData := Pointer(nList.Objects[i]);
        Dispose(nData);
        nList.Objects[i] := nil;
      end;

      Continue;
    end;

    nStr := nList[i];
    nPos := Pos('=', nStr);

    if (nPos > 1) and (not Assigned(nList.Objects[i])) then
    begin
      New(nData);
      nList.Objects[i] := TObject(nData);
    end;
    nData := Pointer(nList.Objects[i]);
    
    if nPos > 1 then
    begin
      nData.FString := Trim(Copy(nStr, 1, nPos - 1));
      System.Delete(nStr, 1, nPos);
      nList[i] := Trim(nStr);
    end else
    begin
     if Assigned(nData) then nData.FString := nStr;
    end;
  end;

  if nRelease then
    nList.Clear;
  //Release means no items
end;

//Date: 2010-3-12
//Parm: �б�;����;����
//Desc: ��nList��nIdx����nStr��
function InsertStringsItem(const nList: TStrings; const nStr: string;
  const nIdx: integer = -1): Integer;
var nTmp: string;
    nPos: integer;
    nData: PStringsItemData;
begin
  if (nIdx > -1) and (nIdx < nList.Count) then
  begin
    Result := nIdx;
    nList.Insert(nIdx, nStr);
  end else Result := nList.Add(nStr);

  New(nData);
  nList.Objects[Result] := TObject(nData);

  nTmp := nStr;
  nPos := Pos('=', nTmp);

  if nPos > 1 then
  begin
    nData.FString := Trim(Copy(nTmp, 1, nPos - 1));
    System.Delete(nTmp, 1, nPos);
    nList[Result] := Trim(nTmp);
  end else nData.FString := nTmp;
end;

//Date: 2009-6-2
//Parm: �б�;����
//Desc: ��ȡnList������ΪnIdx������
function GetStringsItemData(const nList: TStrings; const nIdx: integer): string;
begin
  if (nIdx > -1) and (nIdx < nList.Count) then
  begin
    if Assigned(nList.Objects[nIdx]) then
         Result := PStringsItemData(nList.Objects[nIdx]).FString
    else Result := nList[nIdx];
  end else Result := '';
end;

//Date: 2010-3-13
//Parm: �б�;����
//Desc: ��ȡnList������ΪnIdx������
function GetStringsItemData2(const nList: TStrings;
  const nIdx: Integer): PStringsItemData;
begin
  if (nIdx > -1) and (nIdx < nList.Count) then
       Result := Pointer(nList.Objects[nIdx])
  else Result := nil;
end;

//Date: 2009-6-2
//Parm: �б�;ֵ
//Desc: ��ȡnValueֵ��nList�е�����λ��
function GetStringsItemIndex(const nList: TStrings; const nValue: string): Integer;
var i,nCount: integer;
begin
  Result := -1;
  if nValue = '' then
       Exit
  else nCount := nList.Count - 1;
  
  for i:=0 to nCount do
  begin
    if Assigned(nList.Objects[i]) then
    begin
      if PStringsItemData(nList.Objects[i]).FString = nValue then Result := i;
    end else

    if CompareText(nValue, nList[i]) = 0 then
    begin
      Result := i;
    end;
    
    if Result > -1 then Exit;
  end;
end;

//------------------------------------------------------------------------------
//Desc: �ж�nType�Ƿ��ַ���
function IsTypeStr(const nType: TTypeKind): Boolean;
begin
  Result := nType in [tkString, tkLString, tkWString];
end;

//Desc: �ж�nType�Ƿ�Ϊ��ֵ��
function IsTypeInteger(const nType: TTypeKind): Boolean;
begin
  Result := nType in [tkInteger, tkInt64];
end;

//Date: 2007-08-08
//Parm: �б�ؼ�
//Desc: ����nCtrl�����ݸ�ʽ
procedure AdjustComboBox(const nCtrl: TComboBox; const nRelease: Boolean);
var nIdx: integer;
begin
  nIdx := nCtrl.ItemIndex;
  AdjustStringsItem(nCtrl.Items, nRelease);

  if nCtrl.Items.Count > 0  then
  begin
    if nIdx = -1 then nIdx := 0;
    nCtrl.ItemIndex := nIdx;
  end;
  //default value;
end;

//Date: 2009-6-3
//Parm: cxComboBox����
//Desc: ����nCtrl�����ݸ�ʽ
procedure AdjustCXComboBoxItem(const nCtrl: TObject; const nRelease: Boolean);
var nIdx: integer;
    nObj: TObject;
    nList: TStrings;
    nIdxValid: Boolean;
begin
  if IsPublishedProp(nCtrl, 'ItemIndex') and
     IsTypeInteger(PropType(nCtrl, 'ItemIndex')) then
  begin
    nIdxValid := True;
    nIdx := GetOrdProp(nCtrl, 'ItemIndex');
  end else
  begin
    nIdxValid := False; nIdx := -1;
  end;

  nList := nil;
  if IsPublishedProp(nCtrl, 'Properties') and
     (PropType(nCtrl, 'Properties') = tkClass) then
  begin
    nObj := GetObjectProp(nCtrl, 'Properties');
    if IsPublishedProp(nObj, 'Items') and (PropType(nObj, 'Items') = tkClass) then
    begin
      nObj := GetObjectProp(nObj, 'Items');
      if nObj is TStrings then nList := nObj as TStrings;
    end;
  end;

  if Assigned(nList) then
  begin
    AdjustStringsItem(nList, nRelease);
    //��������

    if (nList.Count > 0) and nIdxValid then
    begin
      if nIdx = -1 then nIdx := 0;
      SetOrdProp(nCtrl, 'ItemIndex', nIdx);
    end;
    //default value;
  end;
end;

//Date: 2007-08-08
//Parm: �������ؼ�;�Ƿ��ͷ�;�Ƿ�����ص�����
//Desc: ����nPCtrl�ϵĿؼ����ݸ�ʽ,���ͷű�Ҫ����Դ
procedure AdjustData(const nPCtrl: TWinControl; const nRelease: Boolean;
  const nCallBack: TAdjustCallBack = nil);
var nList: TList;
    nObj: TObject;
    i,nCount: integer;
    nCanAdjust: Boolean;
begin
  nList := TList.Create;
  try
    nList.Add(nPCtrl);
    EnumSubCtrlList(nPCtrl, nList);
    nCount := nList.Count - 1;

    for i:=0 to nCount do
    begin
      nObj := nList[i];
      nCanAdjust := True;
      if Assigned(nCallBack) then nCallBack(nObj, nCanAdjust);

      if nCanAdjust then
      begin
        if nObj is TComboBox then
          AdjustComboBox(nObj as TComboBox, nRelease) else
        if CompareText(nObj.ClassName, 'TcxComboBox') = 0 then
          AdjustCXComboBoxItem(nObj, nRelease);
      end;
    end;
  finally
    nList.Free;
  end;
end;

//Desc: ����nForm�Ͽؼ�������
procedure AdjustCtrlData(const nPCtrl: TWinControl;
  const nCallBack: TAdjustCallBack = nil);
begin
  AdjustData(nPCtrl, False, nCallBack);
end;

//Desc: �ͷ�nForm�ϵ�������Դ
procedure ReleaseCtrlData(const nPCtrl: TWinControl;
  const nCallBack: TAdjustCallBack = nil);
begin
  AdjustData(nPCtrl, True, nCallBack);
end;

{------------------------------------------------------------------------------}
//Date: 2009-06-11
//Parm: cxComboBox����
//Desc: ��ȡnCtrl����Ч����
function GetCXComboBoxData(const nCtrl: TComponent): string;
var nIdx: integer;
    nObj: TObject;
    nStyle: string;
    nList: TStrings;
begin
  Result := '';

  if IsPublishedProp(nCtrl, 'ItemIndex') and
     IsTypeInteger(PropType(nCtrl, 'ItemIndex')) then
  begin
    nIdx := GetOrdProp(nCtrl, 'ItemIndex');
  end else Exit;

  nList := nil;
  nStyle := '';

  if IsPublishedProp(nCtrl, 'Properties') and
     (PropType(nCtrl, 'Properties') = tkClass) then
  begin
    nObj := GetObjectProp(nCtrl, 'Properties');
    if IsPublishedProp(nObj, 'DropDownListStyle') and
       (PropType(nObj, 'DropDownListStyle') = tkEnumeration) then
         nStyle := GetEnumProp(nObj, 'DropDownListStyle');
    //xxxxx

    if IsPublishedProp(nObj, 'Items') and (PropType(nObj, 'Items') = tkClass) then
    begin
      nObj := GetObjectProp(nObj, 'Items');
      if nObj is TStrings then nList := nObj as TStrings;
    end;
  end;

  if Assigned(nList) then
  begin
    Result := GetStringsItemData(nList, nIdx);
    if (Result <> '') or (nStyle <> 'lsEditList') then Exit;

    if IsPublishedProp(nCtrl, 'Text') and IsTypeStr(PropType(nCtrl, 'Text')) then
      Result := GetStrProp(nCtrl, 'Text');
    //xxxxx
  end;
end;

//Desc: ����nCtrl����Чֵ
function GetCtrlData(const nCtrl: TComponent; const nCallBack: TGetDataCallBack = nil): string;
var nObj: TObject;
begin
  Result := '';
  if nCtrl is TComboBox then
  with nCtrl as TComboBox do
  begin
    Result := GetStringsItemData(Items, ItemIndex);
    if Assigned(nCallBack) then nCallBack(nCtrl, Result); Exit;
  end;

  if CompareText(nCtrl.ClassName, 'TcxComboBox') = 0 then
  begin
    Result := GetCXComboBoxData(nCtrl);
    if Assigned(nCallBack) then nCallBack(nCtrl, Result); Exit;
  end;

  if IsPublishedProp(nCtrl, 'Text') and IsTypeStr(PropType(nCtrl, 'Text')) then
     Result := GetStrProp(nCtrl, 'Text') else
  if IsPublishedProp(nCtrl, 'Caption') and IsTypeStr(PropType(nCtrl, 'Caption')) then
     Result := GetStrProp(nCtrl, 'Caption') else

  if IsPublishedProp(nCtrl, 'Lines')  and (PropType(nCtrl, 'Lines') = tkClass) then
  begin
    nObj := GetObjectProp(nCtrl, 'Lines');
    if nObj is TStrings then Result := (nObj as TStrings).Text;
  end else

  if IsPublishedProp(nCtrl, 'Items')  and (PropType(nCtrl, 'Items') = tkClass) then
  begin
    nObj := GetObjectProp(nCtrl, 'Items');
    if nObj is TStrings then Result := (nObj as TStrings).Text;
  end;

  if Assigned(nCallBack) then nCallBack(nCtrl, Result);
end;

//Desc: ����nForm��һ������ΪnType,����ΪnCtrl�����
function GetCtrlByName(const nForm: TForm; const nCtrl: string;
  const nType: TComponentClass ): TComponent;
begin
  Result := nForm.FindComponent(nCtrl);
  if Assigned(Result) and (not (Result is nType)) then Result := nil;
end;

//Desc: ����nForm��nCtrl�ؼ�����Чֵ
function GetCtrlDataByName(const nForm: TForm; const nCtrl: string): string;
var nTmp: TComponent;
begin
  Result := '';
  nTmp := nForm.FindComponent(nCtrl);
  if Assigned(nTmp) and (nTmp is TControl) then Result := GetCtrlData(nTmp);
end;

//------------------------------------------------------------------------------
//Date: 2009-6-11
//Parm: cxComboBox����
//Desc: ����nCtrl������ΪnValue
procedure SetCXComboBoxData(const nCtrl: TComponent; const nValue: string);
var nIdx: integer;
    nObj: TObject;
    nStyle: string;
    nList: TStrings;
begin
  nList := nil;
  if IsPublishedProp(nCtrl, 'Properties') and
     (PropType(nCtrl, 'Properties') = tkClass) then
  begin
    nObj := GetObjectProp(nCtrl, 'Properties');
    if IsPublishedProp(nObj, 'DropDownListStyle') and
       (PropType(nObj, 'DropDownListStyle') = tkEnumeration) then
         nStyle := GetEnumProp(nObj, 'DropDownListStyle');
    //xxxxx

    if IsPublishedProp(nObj, 'Items') and (PropType(nObj, 'Items') = tkClass) then
    begin
      nObj := GetObjectProp(nObj, 'Items');
      if nObj is TStrings then nList := nObj as TStrings;
    end;
  end;

  if Assigned(nList) then
  begin
    nIdx := GetStringsItemIndex(nList, nValue);
    if (nIdx < 0) and (nStyle = 'lsEditList') then
    begin
      if IsPublishedProp(nCtrl, 'Text') and IsTypeStr(PropType(nCtrl, 'Text')) then
        SetStrProp(nCtrl, 'Text', nValue);
      Exit;
    end;

    if IsPublishedProp(nCtrl, 'ItemIndex') and
       IsTypeInteger(PropType(nCtrl, 'ItemIndex')) then
    begin
      SetOrdProp(nCtrl, 'ItemIndex', nIdx);
    end;
  end;
end;

//Desc: ����nCtrl���ַ�������ֵΪnValue
function SetCtrlData(const nCtrl: TComponent; const nValue: string;
  const nCallBack: TSetDataCallBack = nil): Boolean;
var nObj: TObject;
begin
  if Assigned(nCallBack) then
  begin
    Result := nCallBack(nCtrl, nValue);
    if Result then Exit;
  end else Result := True;
  
  if nCtrl is TComboBox then
  with nCtrl as TComboBox do
  begin
    ItemIndex := GetStringsItemIndex(Items, nValue); Exit;
  end;

  if CompareText(nCtrl.ClassName, 'TcxComboBox') = 0 then
  begin
    SetCXComboBoxData(nCtrl, nValue); Exit;
  end;

  if IsPublishedProp(nCtrl, 'Text') and IsTypeStr(PropType(nCtrl, 'Text')) then
     SetStrProp(nCtrl, 'Text', nValue) else
  if IsPublishedProp(nCtrl, 'Caption') and IsTypeStr(PropType(nCtrl, 'Caption')) then
     SetStrProp(nCtrl, 'Caption', nValue) else

  if IsPublishedProp(nCtrl, 'Lines')  and (PropType(nCtrl, 'Lines') = tkClass) then
  begin
    nObj := GetObjectProp(nCtrl, 'Lines');
    if nObj is TStrings then (nObj as TStrings).Text := nValue;
  end else

  if IsPublishedProp(nCtrl, 'Items')  and (PropType(nCtrl, 'Items') = tkClass) then
  begin
    nObj := GetObjectProp(nCtrl, 'Items');
    if nObj is TStrings then (nObj as TStrings).Text := nValue;
  end else Result := False;
end;

//Desc: ����nForm��nCtrl���ַ�������ֵΪnValue
function SetCtrlDataByName(const nForm: TForm;const nCtrl,nValue: string): Boolean;
var nTmp: TComponent;
begin
  nTmp := nForm.FindComponent(nCtrl);
  Result := Assigned(nTmp);
  if Result and (nTmp is TControl) then Result := SetCtrlData(nTmp, nValue);
end;

//Date: 2007-08-22
//Parm: �ؼ�;��󳤶�ֵ
//Desc: ����nCtrl�ؼ���MaxLengthֵ
function SetCtrlMaxLen(const nCtrl: TComponent; const nMaxLen: integer): Boolean;
begin
  if (nMaxLen > 0) and IsPublishedProp(nCtrl, 'MaxLength') and
     IsTypeInteger(PropType(nCtrl, 'MaxLength')) then
  begin
    if GetOrdProp(nCtrl, 'MaxLength') = 0 then
      SetOrdProp(nCtrl, 'MaxLength', nMaxLen);
    Result := True;
  end else Result := False;
end;

//Date: 2007-08-29
//Parm: �ؼ�
//Desc: ����nCtrl�ؼ���ecUpperCaseֵ
function SetCtrlCharCase(const nCtrl: TComponent): Boolean;
begin
  if IsPublishedProp(nCtrl, 'CharCase') and
     (PropType(nCtrl, 'CharCase') = tkEnumeration) then
  begin
    SetEnumProp(nCtrl, 'CharCase', 'ecUpperCase'); Result := True;
  end else Result := False;
end;

end.
