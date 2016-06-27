{*******************************************************************************
  作者: dmzn@163.com 2009-5-22
  描述: 对Ini文件操作进行高级封装

  备注:
  &.数据做缓存处理.
  &.可以简化读写操作.
*******************************************************************************}
unit UMgrIni;

interface

uses
  Windows, Classes, Variants, SysUtils, IniFiles;

type
  PIniDataItem = ^TIniDataItem;
  TIniDataItem = record
    FSection: string;        //小节
    FKeyName: string;        //键名
    FKeyValue: Variant;      //键值
    FDefValue: Variant;      //默认值
    FExtValue: Variant;      //扩展值
  end;

 TIniManager = class(TObject)
 private
   FItems: TList;
   {*数据列表*}
   FIniFile: string;
   {*文件名*}
 protected
   procedure ClearList(const nFree: Boolean);
   {*清理资源*}
 public
   constructor Create;
   destructor Destroy; override;
   {*创建释放*}
   function LoadIni(const nFile: string): Boolean;
   function SaveIni(const nFile: string): Boolean;
   {*读写数据*}
   procedure AddDef(const nSection,nKey: string; const nDef,nExt: Variant);
   {*默认处理*}
   function FindItem(const nKey: string; const nSection: string = ''): PIniDataItem;
   {*检索对象*}
   function GetStr(const nKey: string; const nSection: string = ''): string;
   function GetInt(const nKey: string; const nSection: string = ''): integer;
   function GetFloat(const nKey: string; const nSection: string = ''): Double;
   {*获取数据*}
   property Items: TList read FItems;
   property FileName: string read FIniFile;
   {*属性相关*}
 end;

var
  gIniManager: TIniManager = nil;
  //全局使用

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
//Parm: 是否释放列表
//Desc: 清理数据列表
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
//Parm: 小节;键;默认值;扩展值
//Desc: 为nSection.nKey添加默认值nDef,不存在则添加
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
//Parm: 键名;小节
//Desc: 查找nSection.nKey对应的数据项
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

//Desc: 获取浮点数
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

//Desc: 获取整数值
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

//Desc: 获取字符串
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

//Desc: 载入nFile文件
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
        //读取数据
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

//Desc: 保存当前数据到nFile中
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
