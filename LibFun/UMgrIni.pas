{*******************************************************************************
  ����: dmzn@163.com 2009-5-22
  ����: ��Ini�ļ��������и߼���װ

  ��ע:
  &.���������洦��.
  &.���Լ򻯶�д����.
*******************************************************************************}
unit UMgrIni;

interface

uses
  Windows, Classes, Variants, SysUtils, IniFiles;

type
  PIniDataItem = ^TIniDataItem;
  TIniDataItem = record
    FSection: string;        //С��
    FKeyName: string;        //����
    FKeyValue: Variant;      //��ֵ
    FDefValue: Variant;      //Ĭ��ֵ
    FExtValue: Variant;      //��չֵ
  end;

 TIniManager = class(TObject)
 private
   FItems: TList;
   {*�����б�*}
   FIniFile: string;
   {*�ļ���*}
 protected
   procedure ClearList(const nFree: Boolean);
   {*������Դ*}
 public
   constructor Create;
   destructor Destroy; override;
   {*�����ͷ�*}
   function LoadIni(const nFile: string): Boolean;
   function SaveIni(const nFile: string): Boolean;
   {*��д����*}
   procedure AddDef(const nSection,nKey: string; const nDef,nExt: Variant);
   {*Ĭ�ϴ���*}
   function FindItem(const nKey: string; const nSection: string = ''): PIniDataItem;
   {*��������*}
   function GetStr(const nKey: string; const nSection: string = ''): string;
   function GetInt(const nKey: string; const nSection: string = ''): integer;
   function GetFloat(const nKey: string; const nSection: string = ''): Double;
   {*��ȡ����*}
   property Items: TList read FItems;
   property FileName: string read FIniFile;
   {*�������*}
 end;

var
  gIniManager: TIniManager = nil;
  //ȫ��ʹ��

implementation

constructor TIniManager.Create;
begin
  FItems := TList.Create;
end;

destructor TIniManager.Destroy;
begin
  ClearList(True);
  inherited;
end;

//Date: 2009-5-22
//Parm: �Ƿ��ͷ��б�
//Desc: ���������б�
procedure TIniManager.ClearList(const nFree: Boolean);
var nIdx: integer;
begin
  while FItems.Count > 0 do
  begin
    nIdx := FItems.Count - 1;
    Dispose(PIniDataItem(FItems[nIdx]));
    FItems.Delete(nIdx);
  end;

  if nFree then FItems.Free;
end;          

//Date: 2009-5-22
//Parm: С��;��;Ĭ��ֵ;��չֵ
//Desc: ΪnSection.nKey���Ĭ��ֵnDef,�����������
procedure TIniManager.AddDef(const nSection, nKey: string;
  const nDef,nExt: Variant);
var nItem: PIniDataItem;
begin
  nItem := FindItem(nSection, nKey);
  if not Assigned(nItem) then
  begin
    New(nItem);
    FItems.Add(nItem);
    FillChar(nItem^, SizeOf(TIniDataItem), #0);

    nItem.FSection := nSection;
    nItem.FKeyName := nKey;
  end;

  nItem.FDefValue := nDef;
  nItem.FExtValue := nExt;
end;    

//Date: 2009-5-22
//Parm: ����;С��
//Desc: ����nSection.nKey��Ӧ��������
function TIniManager.FindItem(const nKey, nSection: string): PIniDataItem;
var i,nCount: integer;
    nItem: PIniDataItem;
begin
  Result := nil;
  nCount := FItems.Count - 1;

  for i:=0 to nCount do
  begin
    nItem := FItems[i];
    if ((nSection = '') or (CompareText(nSection, nItem.FSection) = 0)) and
       ((CompareText(nKey, nItem.FKeyName) = 0)) then
    begin
      Result := nItem; Break;
    end;
  end;
end;

//Desc: ��ȡ������
function TIniManager.GetFloat(const nKey, nSection: string): Double;
var nItem: PIniDataItem;
begin
  nItem := FindItem(nKey, nSection);
  if Assigned(nItem) and VarIsNumeric(nItem.FKeyValue) then
  begin
    if VarIsEmpty(nItem.FKeyValue) then
    begin
      if VarIsEmpty(nItem.FDefValue) then
           Result := -1
      else Result := nItem.FDefValue;
    end else Result :=nItem.FKeyValue
  end else Result := -1;
end;

//Desc: ��ȡ����ֵ
function TIniManager.GetInt(const nKey, nSection: string): integer;
var nItem: PIniDataItem;
begin
  nItem := FindItem(nKey, nSection);
  if Assigned(nItem) and VarIsOrdinal(nItem.FKeyValue) then
  begin
    if VarIsEmpty(nItem.FKeyValue) then
    begin
      if VarIsEmpty(nItem.FDefValue) then
           Result := -1
      else Result := nItem.FDefValue;
    end else Result :=nItem.FKeyValue
  end else Result := -1;
end;

//Desc: ��ȡ�ַ���
function TIniManager.GetStr(const nKey, nSection: string): string;
var nItem: PIniDataItem;
begin
  nItem := FindItem(nKey, nSection);
  if Assigned(nItem) then
  begin
    if VarIsEmpty(nItem.FKeyValue) then
         Result := nItem.FDefValue
    else Result :=nItem.FKeyValue
  end else Result := '';
end;

//Desc: ����nFile�ļ�
function TIniManager.LoadIni(const nFile: string): Boolean;
var nIni: TIniFile;
    nItem: PIniDataItem;
    nSec,nKey: TStrings;
    i,nCount,nIdx,nLen: integer;
begin
  Result := False;
  if not FileExists(nFile) then Exit;

  nIni := nil;
  nSec := nil;
  nKey := nil;
  try
    nIni := TIniFile.Create(nFile);
    FIniFile := nFile;

    nSec := TStringList.Create;
    nKey := TStringList.Create;
    nIni.ReadSections(nSec);

    nCount := nSec.Count - 1;
    for i:=0 to nCount do
    begin
      nIni.ReadSection(nSec[i], nKey);
      nLen := nKey.Count - 1;

      for nIdx:=0 to nLen do
      begin
        nItem := FindItem(nKey[nIdx], nSec[i]);
        if not Assigned(nItem) then
        begin
          New(nItem);
          FItems.Add(nItem);
          FillChar(nItem^, SizeOf(TIniDataItem), #0);

          nItem.FSection := nSec[i];
          nItem.FKeyName := nKey[nIdx];
        end;

        nItem.FKeyValue := nIni.ReadString(nItem.FSection, nItem.FKeyName,
                                           nItem.FDefValue);
        //��ȡ����
      end;
    end;

    FreeAndNil(nSec);
    FreeAndNil(nKey);
    FreeAndNil(nIni); Result := True;
  except
    if Assigned(nSec) then nSec.Free;
    if Assigned(nKey) then nKey.Free;
    if Assigned(nIni) then nIni.Free;
  end;
end;

//Desc: ���浱ǰ���ݵ�nFile��
function TIniManager.SaveIni(const nFile: string): Boolean;
var nIni: TIniFile;
    i,nCount: integer;
    nItem: PIniDataItem;
begin
  Result := False;
  nIni := nil;
  try
    nIni := TIniFile.Create(nFile);
    nCount := FItems.Count - 1;

    for i:=0 to nCount do
    begin
      nItem := FItems[i];
      nIni.WriteString(nItem.FSection, nItem.FKeyName, nItem.FKeyValue);
    end;

    FreeAndNil(nIni); Result := True;
  except
    if Assigned(nIni) then nIni.Free;
  end;
end;

initialization
  gIniManager := TIniManager.Create;
finalization
  FreeAndNil(gIniManager);
end.
