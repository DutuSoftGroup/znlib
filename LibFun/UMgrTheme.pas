{*******************************************************************************
  作者: dmzn@163.com 2008-8-9
  描述: 管理主题相关的风格项和风格包数据

  备注:
  &.主题管理器负责主题包的加载和保存.
  &.新建主题: NewTheme -> ThemeItems.Addxxx -> SaveTheme
*******************************************************************************}
unit UMgrTheme;

interface

uses
  Windows, Classes, Graphics, SysUtils, Forms, IniFiles;

const
  cTheme_Folder  = 'Theme'; //主题文件夹
  cTheme_FileExt = '.skn';  //主题扩展名

type
  TThemeSheetType = (stVerticalGrid, stTreeList, stGridTableView,
                     stGridBandedTableView, stGridCardView);
  //风格包支持的组件类型

  TThemeSheetTypeItem = record
    FType: TThemeSheetType;
    FClass: string;
    FStyles: string;
  end;
  //类型与对应的类名

const
  cThemeSheetTypeItem: array[1..5] of TThemeSheetTypeItem = (
     (FType: stVerticalGrid;
      FClass: 'TcxVerticalGridStyleSheet';
      FStyles: 'TcxVerticalGridStyles'),
     (FType: stTreeList;
      FClass: 'TcxTreeListStyleSheet';
      FStyles: 'TcxTreeListStyles'),
     (FType: stGridTableView;
      FClass: 'TcxGridTableViewStyleSheet';
      FStyles: 'TcxGridTableViewStyles'),
     (FType: stGridBandedTableView;
      FClass: 'TcxGridBandedTableViewStyleSheet';
      FStyles: 'TcxGridBandedTableViewStyles'),
     (FType: stGridCardView;
      FClass: 'TcxGridCardViewStyleSheet';
      FStyles: 'TcxGridCardViewStyles'));
  //风格包类型定义

type
  PThemeInfoItem = ^TThemeInfoItem;
  TThemeInfoItem = record
    FName: string;
    FInfo: string;
  end;
  //信息项

  PThemeStyleItem = ^TThemeStyleItem;
  TThemeStyleItem = record
    FStyleName: string;
    FStyleMark: string;
    FStyleColor: TColor;
    FTextColor: TColor;

    FFontName: string;
    FFontSize: integer;
    FFontColor: TColor;
    FFontStyle: TFontStyles;
    FFontCharset: TFontCharset;
  end;
  //风格项

  PThemeSheetStyle = ^TThemeSheetStyle;
  TThemeSheetStyle = record
    FStyleName: string;
    FStyleItem: string;
  end;
  //风格包项

  PThemeSheetItem = ^TThemeSheetItem;
  TThemeSheetItem = record
    FSheetName: string;
    FSheetMark: string;
    FSheetType: TThemeSheetType;
    FSheetList: TList;
  end;
  //风格包

  TThemeItems = class(TObject)
  private
    FThemeName: string;
    {*主题*}
    FInfo: TList;
    FStyles: TList;
    FSheets: TList;
    {*数据*}
  protected
    procedure LoadSheetSection(const nIni: TIniFile; const nSection: string);
    procedure LoadStyleSection(const nIni: TIniFile; const nSection: string);
    {*读取*}
    procedure FreeInfoItem(const nItem: PThemeInfoItem);
    procedure FreeStyleItem(const nItem: PThemeStyleItem);
    procedure FreeSheetItem(const nItem: PThemeSheetItem);
    procedure FreeSheetStyle(const nItem: PThemeSheetStyle);
    {*释放*}
  public
    constructor Create;
    destructor Destroy; override;
    {*xxxx*}
    function AddInfo: PThemeInfoItem;
    function AddStyle: PThemeStyleItem;
    function AddSheet: PThemeSheetItem;
    function AddSheetStyle(const nSheet: string): PThemeSheetStyle;
    {*添加*}
    function DeleteInfo(const nInfo: string): Boolean;
    function DeleteStyle(const nStyle: string): Boolean;
    function DeleteSheet(const nSheet: string): Boolean;
    function DeleteSheetStyle(const nSheet,nStyle: string): Boolean;
    {*删除*}
    procedure ClearInfo;
    procedure ClearStyles;
    procedure ClearSheets;
    procedure ClearSheetStyle(const nSheet: string);
    {*清空*}
    function InfoIndexByName(const nName: string): integer;
    function StyleIndexByName(const nName: string): integer;
    function SheetIndexByName(const nName: string): integer;
    function SheetStyleIndex(const nSheet,nStyle: string): integer;

    function InfoByName(const nName: string): PThemeInfoItem;
    function StyleByName(const nName: string): PThemeStyleItem;
    function SheetByName(const nName: string): PThemeSheetItem;
    function SheetStyle(const nSheet,nStyle: string): PThemeSheetStyle;
    {*检索*}
    function SaveToFile(const nFile: string): Boolean;
    function LoadFromFile(const nFile: string): Boolean;
    {*读写*}
    property ThemeName: string read FThemeName;
    property ThemeInfo: TList read FInfo;
    property Styles: TList read FStyles;
    property Sheets: TList read FSheets;
    {*属性*}
  end;

  TThemeManager = class(TObject)
  private
    FThemeDir: string;
    {*主题目录*}
    FThemeList: TStrings;
    {*主题列表*}
    FItems: TThemeItems;
    {主题明细}
  public
    constructor Create;
    destructor Destroy; override;
    {*创建释放*}
    function NewTheme(const nName: string): Boolean;
    function DeleteTheme(const nName: string): Boolean;
    {*新建,删除*}
    function OpenTheme(const nName: string): Boolean;
    procedure CloseTheme;
    {*打开,关闭*}
    function SaveTheme: Boolean;
    {*保存主题*}
    function LoadThemeList: Boolean;
    {*主题列表*}
    class function GetThemeName(const nFile: string): string;
    function GetThemeFile(const nName: string): string;
    {*主题,文件*}
    property ThemeDir: string read FThemeDir;
    property ThemeList: TStrings read FThemeList;
    property ThemeItems: TThemeItems read FItems;
    {*属性*}
  end;

var
  gThemeManager: TThemeManager = nil;
  //主题管理器

ResourceString
  sTheme_TypeStyle = 'Style_';         //风格
  sTheme_TypeSheet = 'Sheet_';         //风格包
  sTheme_SheetStyle = 'SS_';           //风格包项
  sTheme_InfoTheme = 'ThemeInfo';      //主题信息

  sTheme_StyleMark = '自动保存风格项'; //默认备注
  sTheme_SheetMark = '自动保存风格包'; //默认备注

implementation

//Desc: 判定nStrA与nStrB是否一致,忽略大小写
function IsSameStr(const nStrA,nStrB: string): Boolean;
begin
  Result := CompareText(nStrA, nStrB) = 0;
end;

//------------------------------------------------------------------------------
constructor TThemeItems.Create;
begin
  inherited;
  FInfo := TList.Create;  
  FStyles := TList.Create;
  FSheets := TList.Create;
end;

destructor TThemeItems.Destroy;
begin
  ClearInfo;
  ClearStyles;
  ClearSheets;

  FInfo.Free;
  FStyles.Free;
  FSheets.Free;
  inherited;
end;

//Desc: 检索nName信息项的索引
function TThemeItems.InfoIndexByName(const nName: string): integer;
var i,nCount: integer;
begin
  Result := -1;
  nCount := FInfo.Count - 1;

  for i:=0 to nCount do
  if IsSameStr(PThemeInfoItem(FInfo[i]).FName, nName) then
  begin
    Result := i; Break;
  end;
end;

//Desc: 检索nName的风格组索引
function TThemeItems.SheetIndexByName(const nName: string): integer;
var i,nCount: integer;
begin
  Result := -1;
  nCount := FSheets.Count - 1;

  for i:=0 to nCount do
  if IsSameStr(PThemeSheetItem(FSheets[i]).FSheetName, nName) then
  begin
    Result := i; Break;
  end;
end;

//Desc: 检索nName的风格索引
function TThemeItems.StyleIndexByName(const nName: string): integer;
var i,nCount: integer;
begin
  Result := -1;
  nCount := FStyles.Count - 1;

  for i:=0 to nCount do
  if IsSameStr(PThemeStyleItem(FStyles[i]).FStyleName, nName) then
  begin
    Result := i; Break;
  end;
end;

//Desc: 检索nStyle风格在nSheet风格包中的索引
function TThemeItems.SheetStyleIndex(const nSheet,nStyle: string): integer;
var i,nCount: integer;
    nItem: PThemeSheetItem;
begin
  Result := -1;
  nItem := SheetByName(nSheet);

  if not (Assigned(nItem) and Assigned(nItem.FSheetList)) then Exit;
  nCount := nItem.FSheetList.Count - 1;

  for i:=0 to nCount do
  if IsSameStr(PThemeSheetStyle(nItem.FSheetList[i]).FStyleName, nStyle) then
  begin
    Result := i; Break;
  end;
end;

//Desc: 检索名称为nName的信息项
function TThemeItems.InfoByName(const nName: string): PThemeInfoItem;
var nIdx: integer;
begin
  nIdx := InfoIndexByName(nName);
  if nIdx < 0 then
       Result := nil
  else Result := FInfo[nIdx];
end;

//Desc: 检索nSheet风格包中的nStyle风格
function TThemeItems.SheetStyle(const nSheet, nStyle: string): PThemeSheetStyle;
var nIdx: integer;
begin
  nIdx := SheetStyleIndex(nSheet, nStyle);
  if nIdx < 0 then
       Result := nil
  else Result := SheetByName(nSheet).FSheetList[nIdx];
end;

//Desc: 检索nName的风格组
function TThemeItems.SheetByName(const nName: string): PThemeSheetItem;
var nIdx: integer;
begin
  nIdx := SheetIndexByName(nName);
  if nIdx < 0 then
       Result := nil
  else Result := FSheets[nIdx];
end;

//Desc: 检索nName的风格
function TThemeItems.StyleByName(const nName: string): PThemeStyleItem;
var nIdx: integer;
begin
  nIdx := StyleIndexByName(nName);
  if nIdx < 0 then
       Result := nil
  else Result := FStyles[nIdx];
end;

//Desc: 添加信息项
function TThemeItems.AddInfo: PThemeInfoItem;
begin
  New(Result);
  FInfo.Add(Result);
  FillChar(Result^, SizeOf(TThemeInfoItem), #0);
end;

//Desc: 添加风格
function TThemeItems.AddStyle: PThemeStyleItem;
begin
  New(Result);
  FStyles.Add(Result);
  FillChar(Result^, SizeOf(TThemeStyleItem), #0);
end;

//Desc: 添加新风格组
function TThemeItems.AddSheet: PThemeSheetItem;
begin
  New(Result);
  FSheets.Add(Result);
  FillChar(Result^, SizeOf(TThemeSheetItem), #0);
end;

//Desc: 在nSheet风格组中添加一个风格项,需要先确定nSheet存在
function TThemeItems.AddSheetStyle(const nSheet: string): PThemeSheetStyle;
var nItem: PThemeSheetItem;
begin
  Result := nil;
  nItem := SheetByName(nSheet);

  if Assigned(nItem) then
  begin
    if not Assigned(nItem.FSheetList) then
      nItem.FSheetList := TList.Create;
    //xxxxx

    New(Result);
    nItem.FSheetList.Add(Result);
    FillChar(Result^, SizeOf(PThemeSheetStyle), #0);
  end;
end;

//Desc: 释放nItem信息项
procedure TThemeItems.FreeInfoItem(const nItem: PThemeInfoItem);
begin
  Dispose(nItem);
end;

//Desc: 释放nItem风格包
procedure TThemeItems.FreeSheetItem(const nItem: PThemeSheetItem);
var i,nCount: integer;
begin
  if Assigned(nItem.FSheetList) then
  begin
    nCount := nItem.FSheetList.Count - 1;
    for i:=0 to nCount do
      FreeSheetStyle(nItem.FSheetList[i]);
    nItem.FSheetList.Free;
  end;

  Dispose(nItem);
end;

//Desc: 释放nItem风格包项
procedure TThemeItems.FreeSheetStyle(const nItem: PThemeSheetStyle);
begin
  Dispose(nItem);
end;

//Desc: 释放nItem风格项
procedure TThemeItems.FreeStyleItem(const nItem: PThemeStyleItem);
begin
  Dispose(nItem);
end;

//Desc: 删除信息项
function TThemeItems.DeleteInfo(const nInfo: string): Boolean;
var nIdx: integer;
begin
  nIdx := InfoIndexByName(nInfo);
  Result := nIdx < 0;

  if not Result then
  begin
    FreeInfoItem(FInfo[nIdx]);
    FInfo.Delete(nIdx);
    Result := True;
  end;
end;

//Desc: 删除nStyle风格
function TThemeItems.DeleteStyle(const nStyle: string): Boolean;
var nIdx: integer;
begin
  nIdx := StyleIndexByName(nStyle);
  Result := nIdx < 0;

  if not Result then
  begin
    FreeStyleItem(FStyles[nIdx]);
    FStyles.Delete(nIdx);
    Result := True;
  end;
end;

//Desc: 删除nSheet风格包
function TThemeItems.DeleteSheet(const nSheet: string): Boolean;
var nIdx: integer;
begin
  nIdx := SheetIndexByName(nSheet);
  Result := nIdx < 0;

  if not Result then
  begin
    FreeSheetItem(FSheets[nIdx]);
    FSheets.Delete(nIdx);
    Result := True;
  end;
end;

//Desc: 删除nSheet风格包中的nStyle项
function TThemeItems.DeleteSheetStyle(const nSheet,nStyle: string): Boolean;
var nIdx: integer;
begin
  nIdx := SheetStyleIndex(nSheet, nStyle);
  Result := nIdx < 0;

  if not Result then
  begin
    FreeSheetStyle(SheetByName(nSheet).FSheetList[nIdx]);
    SheetByName(nSheet).FSheetList.Delete(nIdx);
    Result := True;
  end;
end;

//Desc: 清空信息
procedure TThemeItems.ClearInfo;
var i,nCount: integer;
begin
  nCount := FInfo.Count - 1;
  for i:=0 to nCount do
    FreeInfoItem(FInfo[i]);
  FInfo.Clear;
end;

//Desc: 清空风格包
procedure TThemeItems.ClearSheets;
var i,nCount: integer;
begin
  nCount := FSheets.Count - 1;
  for i:=0 to nCount do
    FreeSheetItem(FSheets[i]);
  FSheets.Clear;
end;

//Desc: 清空风格
procedure TThemeItems.ClearStyles;
var i,nCount: integer;
begin
  nCount := FStyles.Count - 1;
  for i:=0 to nCount do
    FreeStyleItem(FStyles[i]);
  FStyles.Clear;
end;

//Desc: 清空nSheet风格包中的项
procedure TThemeItems.ClearSheetStyle(const nSheet: string);
var i,nCount: integer;
    nItem: PThemeSheetItem;
begin
  nItem := SheetByName(nSheet);
  if Assigned(nItem) and Assigned(nItem.FSheetList) then
  begin
    nCount := nItem.FSheetList.Count - 1;
    for i:=0 to nCount do
      FreeSheetStyle(nItem.FSheetList[i]);
    nItem.FSheetList.Clear;
  end;
end;

//Desc: 字体风格转整型值
function FontStyleToInt(const nFS: TFontStyles): integer;
begin
  Result := 0;
  if fsBold in nFS then Result := 1;
  if fsItalic in nFS then Result := Result or 2;
  if fsUnderline in nFS then Result := Result or 4;
  if fsStrikeOut in nFS then Result := Result or 8;
end;

//Desc: 整型值转字体风格,填充至nFS中
function IntToFontStyle(const nInt: integer): TFontStyles;
begin
  Result := [];
  if nInt and 1 = 1 then Result := [fsBold];
  if nInt and 2 = 2 then Result := Result + [fsItalic];
  if nInt and 4 = 4 then Result := Result + [fsUnderline];
  if nInt and 4 = 8 then Result := Result + [fsStrikeOut];
end;

//Desc: 将nList中的数据写入nSec小节中
procedure WriteSheetStyleList(const nIni: TIniFile; const nSec: string;
  const nList: TList);
var i,nCount: integer;
    nItem: PThemeSheetStyle;
begin
  nCount := nList.Count - 1;
  for i:=0 to nCount do
  begin
    nItem := nList[i];
    nIni.WriteString(nSec, sTheme_SheetStyle + nItem.FStyleName, nItem.FStyleItem);
  end;
end;

//Desc: 保存到主题文件
function TThemeItems.SaveToFile(const nFile: string): Boolean;
var nStr: string;
    nIni: TIniFile;
    i,nCount: integer;

    nInfo: PThemeInfoItem;
    nStyle: PThemeStyleItem;
    nSheet: PThemeSheetItem;
begin
  Result := False;
  if FileExists(nFile) and (not DeleteFile(nFile)) then Exit;

  nIni := TIniFile.Create(nFile);
  try
    nCount := FInfo.Count - 1;
    for i:=0 to nCount do
    begin
      nInfo := FInfo[i];
      nIni.WriteString(sTheme_InfoTheme, nInfo.FName, nInfo.FInfo);
    end;
    //信息项

    nCount := FStyles.Count - 1;
    for i:=0 to nCount do
    begin
      nStyle := FStyles[i];
      nStr := sTheme_TypeStyle + IntToStr(i);

      nIni.WriteString(nStr, 'StyleName', nStyle.FStyleName);
      nIni.WriteString(nStr, 'StyleMark', nStyle.FStyleMark);
      nIni.WriteInteger(nStr, 'StyleColor', nStyle.FStyleColor);
      nIni.WriteInteger(nStr, 'TextColor', nStyle.FTextColor);
      nIni.WriteString(nStr, 'FontName', nStyle.FFontName);
      nIni.WriteInteger(nStr, 'FontSize', nStyle.FFontSize);
      nIni.WriteInteger(nStr, 'FontColor', nStyle.FFontColor);
      nIni.WriteInteger(nStr, 'FontStyle', FontStyleToInt(nStyle.FFontStyle));
      nIni.WriteInteger(nStr, 'FontCharset', nStyle.FFontCharset);
    end;
    //风格项

    nCount := FSheets.Count - 1;
    for i:=0 to nCount do
    begin
      nSheet := FSheets[i];
      nStr := sTheme_TypeSheet + IntToStr(i);

      nIni.WriteString(nStr, 'SheetName', nSheet.FSheetName);
      nIni.WriteString(nStr, 'SheetMark', nSheet.FSheetMark);
      nIni.WriteInteger(nStr, 'SheetType', Ord(nSheet.FSheetType));

      if Assigned(nSheet.FSheetList) then
        WriteSheetStyleList(nIni, nStr, nSheet.FSheetList);
      //风格包数据项
    end;
    //风格包

    Result := True;
    nIni.Free;
  except
    nIni.Free;
  end;  
end;

//Desc: 读取nIni的nSection字段的风格数据
procedure TThemeItems.LoadStyleSection(const nIni: TIniFile; const nSection: string);
begin
  with AddStyle^ do
  begin
    FStyleName := nIni.ReadString(nSection, 'StyleName', '');
    FStyleMark := nIni.ReadString(nSection, 'StyleMark', '');
    FStyleColor := nIni.ReadInteger(nSection, 'StyleColor', clRed);
    FTextColor := nIni.ReadInteger(nSection, 'TextColor', clRed);
    FFontName := nIni.ReadString(nSection, 'FontName', '宋体');
    FFontSize := nIni.ReadInteger(nSection, 'FontSize', 9);
    FFontColor := nIni.ReadInteger(nSection, 'FontColor', clBlack);
    FFontStyle := IntToFontStyle(nIni.ReadInteger(nSection, 'FontStyle', 0));
    FFontCharset := nIni.ReadInteger(nSection, 'FontCharset', 134);
  end;
end;

//Desc: 读取nIni的nSection字段的风格包数据
procedure TThemeItems.LoadSheetSection(const nIni: TIniFile; const nSection: string);
var nStr: string;
    nSheet: string;
    nList: TStrings;
    i,nCount: integer;
begin
  with AddSheet^ do
  begin
    nSheet := nIni.ReadString(nSection, 'SheetName', '');
    FSheetName := nSheet;

    FSheetMark := nIni.ReadString(nSection, 'SheetMark', '');
    FSheetType := TThemeSheetType(nIni.ReadInteger(nSection, 'SheetType', 0));
  end;

  nList := TStringList.Create;
  try
    nIni.ReadSection(nSection, nList);
    nCount := nList.Count - 1;

    for i:=0 to nCount do
    if Pos(sTheme_SheetStyle, nList[i]) = 1 then
    begin
      nStr := nList[i];
      System.Delete(nStr, 1, Length(sTheme_SheetStyle));

      with AddSheetStyle(nSheet)^ do
      begin
        FStyleName := nStr;
        FStyleItem := nIni.ReadString(nSection, nList[i], '');
      end;
    end;
  finally
    nList.Free;
  end;
end;

//Desc: 读取主题文件
function TThemeItems.LoadFromFile(const nFile: string): Boolean;
var nIni: TIniFile;
    nList: TStrings;
    i,nCount: integer;
begin
  Result := False;
  if not FileExists(nFile) then Exit;

  nIni := TIniFile.Create(nFile);
  nList := TStringList.Create;
  try
    ClearInfo;
    nIni.ReadSection(sTheme_InfoTheme, nList);

    nCount := nList.Count - 1;
    for i:=0 to nCount do
    with AddInfo^ do
    begin
      FName := nList[i];
      FInfo := nIni.ReadString(sTheme_InfoTheme, nList[i], '');
    end;
    //信息项

    ClearStyles;
    ClearSheets;
    nIni.ReadSections(nList);

    nCount := nList.Count - 1;
    for i:=0 to nCount do
    if Pos(sTheme_TypeStyle, nList[i]) = 1 then
    begin
      LoadStyleSection(nIni, nList[i])
    end else
    //风格

    if Pos(sTheme_TypeSheet, nList[i]) = 1 then
    begin
      LoadSheetSection(nIni, nList[i]);
    end;
    //风格包

    Result := True;
    FThemeName := TThemeManager.GetThemeName(nFile);
    
    nList.Free;
    nIni.Free;
  except
    nList.Free;
    nIni.Free;
  end;
end;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
constructor TThemeManager.Create;
begin
  inherited;
  FThemeDir := ExtractFilePath(Application.ExeName) + cTheme_Folder + '\';

  FItems := TThemeItems.Create;
  FThemeList := TStringList.Create;
  LoadThemeList;
end;

destructor TThemeManager.Destroy;
begin
  FThemeList.Free;
  FItems.Free;
  inherited;
end;

//------------------------------------------------------------------------------
//Desc: 获取nName主题对应的文件路径
function TThemeManager.GetThemeFile(const nName: string): string;
begin
  Result := FThemeDir + nName + cTheme_FileExt;
end;

//Desc: 获取nFile的主题名称
class function TThemeManager.GetThemeName(const nFile: string): string;
begin
  Result := ExtractFileName(nFile);
  Result := StringReplace(Result, cTheme_FileExt, '', [rfIgnoreCase]);
end;

//Desc: 载入主题列表到FThemeList中
function TThemeManager.LoadThemeList: Boolean;
var nRes: Integer;
    nSR: TSearchRec;
begin
  FThemeList.Clear;
  nRes := FindFirst(FThemeDir + '*' + cTheme_FileExt, faAnyFile, nSR);

  while nRes = 0 do
  begin
    FThemeList.Add(GetThemeName(nSR.Name));
    nRes := FindNext(nSR);
  end;

  FindClose(nSR);
  Result := FThemeList.Count > 0;
end;

//Desc: 新建一个名称为nName的主题
function TThemeManager.NewTheme(const nName: string): Boolean;
var nFile: TextFile;
begin
  Result := FThemeList.IndexOf(nName) > -1;
  if Result then Exit;

  if not DirectoryExists(FThemeDir) then
    ForceDirectories(FThemeDir);
  //dir must exists

  AssignFile(nFile, GetThemeFile(nName));
  try
    ReWrite(nFile);
    CloseFile(nFile);
    FThemeList.Add(nName);
  except
    //ignore any error
  end;
end;

//Desc: 删除nName主题
function TThemeManager.DeleteTheme(const nName: string): Boolean;
var nStr: string;
    nIdx: integer;
begin
  nStr := GetThemeFile(nName);
  if FileExists(nStr) then
       Result := DeleteFile(nStr)
  else Result := True;

  if Result then
  begin
    nIdx := FThemeList.IndexOf(nName);
    if nIdx > -1 then FThemeList.Delete(nIdx);
  end;
end;

//Desc: 载入nName主题
function TThemeManager.OpenTheme(const nName: string): Boolean;
var nStr: string;
begin
  nStr := GetThemeFile(nName);
  Result := FItems.LoadFromFile(nStr);
end;

//Desc: 关闭当前主题
procedure TThemeManager.CloseTheme;
begin
  FItems.ClearInfo;
  FItems.ClearStyles;
  FItems.ClearSheets;
  FItems.FThemeName := '';
end;

//Desc: 保存主题
function TThemeManager.SaveTheme: Boolean;
var nStr: string;
begin
  if FItems.FThemeName <> '' then
  begin
    nStr := GetThemeFile(FItems.FThemeName);
    Result := FItems.SaveToFile(nStr);
  end else Result := False;
end;

initialization
  gThemeManager := TThemeManager.Create;
finalization
  FreeAndNil(gThemeManager);
end.
