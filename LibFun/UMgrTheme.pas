{*******************************************************************************
  ����: dmzn@163.com 2008-8-9
  ����: ����������صķ����ͷ�������

  ��ע:
  &.�������������������ļ��غͱ���.
  &.�½�����: NewTheme -> ThemeItems.Addxxx -> SaveTheme
*******************************************************************************}
unit UMgrTheme;

interface

uses
  Windows, Classes, Graphics, SysUtils, Forms, IniFiles;

const
  cTheme_Folder  = 'Theme'; //�����ļ���
  cTheme_FileExt = '.skn';  //������չ��

type
  TThemeSheetType = (stVerticalGrid, stTreeList, stGridTableView,
                     stGridBandedTableView, stGridCardView);
  //����֧�ֵ��������

  TThemeSheetTypeItem = record
    FType: TThemeSheetType;
    FClass: string;
    FStyles: string;
  end;
  //�������Ӧ������

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
  //�������Ͷ���

type
  PThemeInfoItem = ^TThemeInfoItem;
  TThemeInfoItem = record
    FName: string;
    FInfo: string;
  end;
  //��Ϣ��

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
  //�����

  PThemeSheetStyle = ^TThemeSheetStyle;
  TThemeSheetStyle = record
    FStyleName: string;
    FStyleItem: string;
  end;
  //������

  PThemeSheetItem = ^TThemeSheetItem;
  TThemeSheetItem = record
    FSheetName: string;
    FSheetMark: string;
    FSheetType: TThemeSheetType;
    FSheetList: TList;
  end;
  //����

  TThemeItems = class(TObject)
  private
    FThemeName: string;
    {*����*}
    FInfo: TList;
    FStyles: TList;
    FSheets: TList;
    {*����*}
  protected
    procedure LoadSheetSection(const nIni: TIniFile; const nSection: string);
    procedure LoadStyleSection(const nIni: TIniFile; const nSection: string);
    {*��ȡ*}
    procedure FreeInfoItem(const nItem: PThemeInfoItem);
    procedure FreeStyleItem(const nItem: PThemeStyleItem);
    procedure FreeSheetItem(const nItem: PThemeSheetItem);
    procedure FreeSheetStyle(const nItem: PThemeSheetStyle);
    {*�ͷ�*}
  public
    constructor Create;
    destructor Destroy; override;
    {*xxxx*}
    function AddInfo: PThemeInfoItem;
    function AddStyle: PThemeStyleItem;
    function AddSheet: PThemeSheetItem;
    function AddSheetStyle(const nSheet: string): PThemeSheetStyle;
    {*���*}
    function DeleteInfo(const nInfo: string): Boolean;
    function DeleteStyle(const nStyle: string): Boolean;
    function DeleteSheet(const nSheet: string): Boolean;
    function DeleteSheetStyle(const nSheet,nStyle: string): Boolean;
    {*ɾ��*}
    procedure ClearInfo;
    procedure ClearStyles;
    procedure ClearSheets;
    procedure ClearSheetStyle(const nSheet: string);
    {*���*}
    function InfoIndexByName(const nName: string): integer;
    function StyleIndexByName(const nName: string): integer;
    function SheetIndexByName(const nName: string): integer;
    function SheetStyleIndex(const nSheet,nStyle: string): integer;

    function InfoByName(const nName: string): PThemeInfoItem;
    function StyleByName(const nName: string): PThemeStyleItem;
    function SheetByName(const nName: string): PThemeSheetItem;
    function SheetStyle(const nSheet,nStyle: string): PThemeSheetStyle;
    {*����*}
    function SaveToFile(const nFile: string): Boolean;
    function LoadFromFile(const nFile: string): Boolean;
    {*��д*}
    property ThemeName: string read FThemeName;
    property ThemeInfo: TList read FInfo;
    property Styles: TList read FStyles;
    property Sheets: TList read FSheets;
    {*����*}
  end;

  TThemeManager = class(TObject)
  private
    FThemeDir: string;
    {*����Ŀ¼*}
    FThemeList: TStrings;
    {*�����б�*}
    FItems: TThemeItems;
    {������ϸ}
  public
    constructor Create;
    destructor Destroy; override;
    {*�����ͷ�*}
    function NewTheme(const nName: string): Boolean;
    function DeleteTheme(const nName: string): Boolean;
    {*�½�,ɾ��*}
    function OpenTheme(const nName: string): Boolean;
    procedure CloseTheme;
    {*��,�ر�*}
    function SaveTheme: Boolean;
    {*��������*}
    function LoadThemeList: Boolean;
    {*�����б�*}
    class function GetThemeName(const nFile: string): string;
    function GetThemeFile(const nName: string): string;
    {*����,�ļ�*}
    property ThemeDir: string read FThemeDir;
    property ThemeList: TStrings read FThemeList;
    property ThemeItems: TThemeItems read FItems;
    {*����*}
  end;

var
  gThemeManager: TThemeManager = nil;
  //���������

ResourceString
  sTheme_TypeStyle = 'Style_';         //���
  sTheme_TypeSheet = 'Sheet_';         //����
  sTheme_SheetStyle = 'SS_';           //������
  sTheme_InfoTheme = 'ThemeInfo';      //������Ϣ

  sTheme_StyleMark = '�Զ���������'; //Ĭ�ϱ�ע
  sTheme_SheetMark = '�Զ��������'; //Ĭ�ϱ�ע

implementation

//Desc: �ж�nStrA��nStrB�Ƿ�һ��,���Դ�Сд
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

//Desc: ����nName��Ϣ�������
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

//Desc: ����nName�ķ��������
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

//Desc: ����nName�ķ������
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

//Desc: ����nStyle�����nSheet�����е�����
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

//Desc: ��������ΪnName����Ϣ��
function TThemeItems.InfoByName(const nName: string): PThemeInfoItem;
var nIdx: integer;
begin
  nIdx := InfoIndexByName(nName);
  if nIdx < 0 then
       Result := nil
  else Result := FInfo[nIdx];
end;

//Desc: ����nSheet�����е�nStyle���
function TThemeItems.SheetStyle(const nSheet, nStyle: string): PThemeSheetStyle;
var nIdx: integer;
begin
  nIdx := SheetStyleIndex(nSheet, nStyle);
  if nIdx < 0 then
       Result := nil
  else Result := SheetByName(nSheet).FSheetList[nIdx];
end;

//Desc: ����nName�ķ����
function TThemeItems.SheetByName(const nName: string): PThemeSheetItem;
var nIdx: integer;
begin
  nIdx := SheetIndexByName(nName);
  if nIdx < 0 then
       Result := nil
  else Result := FSheets[nIdx];
end;

//Desc: ����nName�ķ��
function TThemeItems.StyleByName(const nName: string): PThemeStyleItem;
var nIdx: integer;
begin
  nIdx := StyleIndexByName(nName);
  if nIdx < 0 then
       Result := nil
  else Result := FStyles[nIdx];
end;

//Desc: �����Ϣ��
function TThemeItems.AddInfo: PThemeInfoItem;
begin
  New(Result);
  FInfo.Add(Result);
  FillChar(Result^, SizeOf(TThemeInfoItem), #0);
end;

//Desc: ��ӷ��
function TThemeItems.AddStyle: PThemeStyleItem;
begin
  New(Result);
  FStyles.Add(Result);
  FillChar(Result^, SizeOf(TThemeStyleItem), #0);
end;

//Desc: ����·����
function TThemeItems.AddSheet: PThemeSheetItem;
begin
  New(Result);
  FSheets.Add(Result);
  FillChar(Result^, SizeOf(TThemeSheetItem), #0);
end;

//Desc: ��nSheet����������һ�������,��Ҫ��ȷ��nSheet����
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

//Desc: �ͷ�nItem��Ϣ��
procedure TThemeItems.FreeInfoItem(const nItem: PThemeInfoItem);
begin
  Dispose(nItem);
end;

//Desc: �ͷ�nItem����
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

//Desc: �ͷ�nItem������
procedure TThemeItems.FreeSheetStyle(const nItem: PThemeSheetStyle);
begin
  Dispose(nItem);
end;

//Desc: �ͷ�nItem�����
procedure TThemeItems.FreeStyleItem(const nItem: PThemeStyleItem);
begin
  Dispose(nItem);
end;

//Desc: ɾ����Ϣ��
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

//Desc: ɾ��nStyle���
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

//Desc: ɾ��nSheet����
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

//Desc: ɾ��nSheet�����е�nStyle��
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

//Desc: �����Ϣ
procedure TThemeItems.ClearInfo;
var i,nCount: integer;
begin
  nCount := FInfo.Count - 1;
  for i:=0 to nCount do
    FreeInfoItem(FInfo[i]);
  FInfo.Clear;
end;

//Desc: ��շ���
procedure TThemeItems.ClearSheets;
var i,nCount: integer;
begin
  nCount := FSheets.Count - 1;
  for i:=0 to nCount do
    FreeSheetItem(FSheets[i]);
  FSheets.Clear;
end;

//Desc: ��շ��
procedure TThemeItems.ClearStyles;
var i,nCount: integer;
begin
  nCount := FStyles.Count - 1;
  for i:=0 to nCount do
    FreeStyleItem(FStyles[i]);
  FStyles.Clear;
end;

//Desc: ���nSheet�����е���
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

//Desc: ������ת����ֵ
function FontStyleToInt(const nFS: TFontStyles): integer;
begin
  Result := 0;
  if fsBold in nFS then Result := 1;
  if fsItalic in nFS then Result := Result or 2;
  if fsUnderline in nFS then Result := Result or 4;
  if fsStrikeOut in nFS then Result := Result or 8;
end;

//Desc: ����ֵת������,�����nFS��
function IntToFontStyle(const nInt: integer): TFontStyles;
begin
  Result := [];
  if nInt and 1 = 1 then Result := [fsBold];
  if nInt and 2 = 2 then Result := Result + [fsItalic];
  if nInt and 4 = 4 then Result := Result + [fsUnderline];
  if nInt and 4 = 8 then Result := Result + [fsStrikeOut];
end;

//Desc: ��nList�е�����д��nSecС����
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

//Desc: ���浽�����ļ�
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
    //��Ϣ��

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
    //�����

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
      //����������
    end;
    //����

    Result := True;
    nIni.Free;
  except
    nIni.Free;
  end;  
end;

//Desc: ��ȡnIni��nSection�ֶεķ������
procedure TThemeItems.LoadStyleSection(const nIni: TIniFile; const nSection: string);
begin
  with AddStyle^ do
  begin
    FStyleName := nIni.ReadString(nSection, 'StyleName', '');
    FStyleMark := nIni.ReadString(nSection, 'StyleMark', '');
    FStyleColor := nIni.ReadInteger(nSection, 'StyleColor', clRed);
    FTextColor := nIni.ReadInteger(nSection, 'TextColor', clRed);
    FFontName := nIni.ReadString(nSection, 'FontName', '����');
    FFontSize := nIni.ReadInteger(nSection, 'FontSize', 9);
    FFontColor := nIni.ReadInteger(nSection, 'FontColor', clBlack);
    FFontStyle := IntToFontStyle(nIni.ReadInteger(nSection, 'FontStyle', 0));
    FFontCharset := nIni.ReadInteger(nSection, 'FontCharset', 134);
  end;
end;

//Desc: ��ȡnIni��nSection�ֶεķ�������
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

//Desc: ��ȡ�����ļ�
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
    //��Ϣ��

    ClearStyles;
    ClearSheets;
    nIni.ReadSections(nList);

    nCount := nList.Count - 1;
    for i:=0 to nCount do
    if Pos(sTheme_TypeStyle, nList[i]) = 1 then
    begin
      LoadStyleSection(nIni, nList[i])
    end else
    //���

    if Pos(sTheme_TypeSheet, nList[i]) = 1 then
    begin
      LoadSheetSection(nIni, nList[i]);
    end;
    //����

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
//Desc: ��ȡnName�����Ӧ���ļ�·��
function TThemeManager.GetThemeFile(const nName: string): string;
begin
  Result := FThemeDir + nName + cTheme_FileExt;
end;

//Desc: ��ȡnFile����������
class function TThemeManager.GetThemeName(const nFile: string): string;
begin
  Result := ExtractFileName(nFile);
  Result := StringReplace(Result, cTheme_FileExt, '', [rfIgnoreCase]);
end;

//Desc: ���������б�FThemeList��
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

//Desc: �½�һ������ΪnName������
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

//Desc: ɾ��nName����
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

//Desc: ����nName����
function TThemeManager.OpenTheme(const nName: string): Boolean;
var nStr: string;
begin
  nStr := GetThemeFile(nName);
  Result := FItems.LoadFromFile(nStr);
end;

//Desc: �رյ�ǰ����
procedure TThemeManager.CloseTheme;
begin
  FItems.ClearInfo;
  FItems.ClearStyles;
  FItems.ClearSheets;
  FItems.FThemeName := '';
end;

//Desc: ��������
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
