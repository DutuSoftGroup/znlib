{*******************************************************************************
  作者: dmzn@163.com 2008-8-13
  描述: 管理与CX控件包相关的主题包

  备注:
  &.单元Uses部分,开关用于确定支持哪几种控件的主题,可依据项目需求来改动.
  &.主题包由两部分组成:风格项,用于描述一个风格;风格包,包含一组风格项.每个风格包
    对应一个类型的控件主题.
  &.例如类型为stVerticalGrid的风格包,将来只能加载到VerticalGrid的Styles对象上.
  &.每个主题包内可能有若干个stVerticalGrid类型的风格包,但只有第一个生效.
*******************************************************************************}
unit UMgrThemeCX;

interface

{$DEFINE VerticalGrid}
{$DEFINE QuantumGrid}
{$DEFINE TreeList}
uses
  Windows, Classes, SysUtils, TypInfo,
  {$IFDEF VerticalGrid}
  cxVGrid,
  {$ENDIF}
  {$IFDEf QuantumGrid}
  cxGridTableView, cxGridBandedTableView, cxGridCardView,
  {$ENDIF}
  {$IFDEF TreeList}
  cxTL,
  {$ENDIF}
  cxStyles, UMgrTheme;     

type
  PcxThemeStyleItem = ^TcxThemeStyleItem;
  TcxThemeStyleItem = record
    FStyleName: string;
    FStyleMark: string;
    FStyleItem: TcxStyle;
  end;
  //风格对象

  PcxThemeSheetItem = ^TcxThemeSheetItem;
  TcxThemeSheetItem = record
    FSheetName: string;
    FSheetMark: string;
    FSheetItem: TcxCustomStyleSheet;
  end;
  //风格对象

  TcxThemeManager = class(TObject)
  private
    FStyles: TList;
    FSheets: TList;
    FSheetClass: TList;
    {主题对象}
  protected
    procedure ClearStyles;
    procedure ClearSheets;
    {*清理对象*}
    procedure LoadStyleItems;
    procedure LoadSheetsItems;
    function LoadSheeItem(const nSheet: TcxCustomStyleSheet;
      const nData: PThemeSheetItem): Boolean;
    function NewSheetByType(const nType: TThemeSheetType): TcxCustomStyleSheet;
    {*生成对象*}
    function StyleByName(const nName: string): TcxStyle;
    function SheetByClass(const nClass: TClass): TcxCustomStyleSheet;
    {*检索对象*}
    function ClassNameBySheetType(const nType: TThemeSheetType): string;
    {*对应类名*}
    function SheetTypeByStyles(const nStyles: string): TThemeSheetType;
    {*风格类型*}
  public
    constructor Create;
    destructor Destroy; override;
    {*创建,释放*}
    function LoadTheme(const nTheme: string): Boolean;
    {*读取主题*}
    function ApplyTheme(const nCtrl: TComponent): Boolean;
    {*应用主题*}
    function SaveCtrlTheme(const nCtrl: TComponent; const nTheme: string): Boolean;
    {*生成主题*}
    function GetSheetByType(const nType: TThemeSheetType): TcxCustomStyleSheet;
    {*检索风格包*}
  end;

var
  gCxThemeManager: TcxThemeManager = nil;
  //cx主题管理器

implementation

constructor TcxThemeManager.Create;
begin
  inherited;
  FStyles := TList.Create;
  FSheets := TList.Create;

  FSheetClass := TList.Create;
  GetRegisteredStyleSheetClasses(FSheetClass);
end;

destructor TcxThemeManager.Destroy;
begin
  ClearSheets;
  ClearStyles;

  FSheets.Free;
  FStyles.Free;
  FSheetClass.Free;
  inherited;
end;

//Desc: 清理风格包对象
procedure TcxThemeManager.ClearSheets;
var nIdx: integer;
    nItem: PcxThemeSheetItem;
begin
  for nIdx:= FSheets.Count - 1 downto 0 do
  begin
    nItem := FSheets[nIdx];
    nItem.FSheetItem.Free;

    Dispose(nItem);
    FSheets.Delete(nIdx);
  end;
end;

//Desc: 清理风格对象
procedure TcxThemeManager.ClearStyles;
var nIdx: integer;
    nItem: PcxThemeStyleItem;
begin
  for nIdx:= FStyles.Count - 1 downto 0 do
  begin
    nItem := FStyles[nIdx];
    nItem.FStyleItem.Free;

    Dispose(nItem);
    FStyles.Delete(nIdx);
  end;
end;

//Desc: 检索nName风格对象
function TcxThemeManager.StyleByName(const nName: string): TcxStyle;
var i,nCount: integer;
    nItem: PcxThemeStyleItem;
begin
  Result := nil;
  nCount := FStyles.Count - 1;

  for i:=0 to nCount do
  begin
    nItem := FStyles[i];
    if CompareText(nName, nItem.FStyleName) = 0 then
    begin
      Result := nItem.FStyleItem; Break;
    end;
  end;
end;

//Desc: 获取nType风格包对应的cx类名称
function TcxThemeManager.ClassNameBySheetType(const nType: TThemeSheetType): string;
var i,nLen: integer;
begin
  Result := '';
  nLen := High(cThemeSheetTypeItem);

  for i:=Low(cThemeSheetTypeItem) to nLen do
  if cThemeSheetTypeItem[i].FType = nType then
  begin
    Result := cThemeSheetTypeItem[i].FClass; Break;
  end;
end;

//Desc: 生成nType类型的风格包对象
function TcxThemeManager.NewSheetByType(const nType: TThemeSheetType): TcxCustomStyleSheet;
var nStr: string;
    i,nCount: integer;
begin
  Result := nil;
  nStr := ClassNameBySheetType(nType);
  if nStr = '' then Exit;

  nCount := FSheetClass.Count - 1;
  for i:=0 to nCount do
  if CompareText(nStr, TClass(FSheetClass[i]).ClassName) = 0 then
  begin
    Result := TcxCustomStyleSheetClass(FSheetClass[i]).Create(nil); Break;
  end;
end;

//Desc: 检索nType类型的风格包对象
function TcxThemeManager.GetSheetByType(const nType: TThemeSheetType): TcxCustomStyleSheet;
var nClass: string;
    i,nCount: integer;
begin
  Result := nil;
  nClass := ClassNameBySheetType(nType);

  if nClass = '' then Exit;
  nCount := FSheets.Count - 1;

  for i:=0 to nCount do
  if CompareText(PcxThemeSheetItem(FSheets[i]).FSheetItem.ClassName, nClass) = 0 then
  begin
    Result := PcxThemeSheetItem(FSheets[i]).FSheetItem; Break;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 生成风格对象
procedure TcxThemeManager.LoadStyleItems;
var i,nCount: integer;
    nList: TList;
    nItem: PThemeStyleItem;
    nCxItem: PcxThemeStyleItem;
begin
  ClearStyles;
  nList := gThemeManager.ThemeItems.Styles;

  nCount := nList.Count - 1;
  for i:=0 to nCount do
  begin
    New(nCxItem);
    FStyles.Add(nCxItem);

    nItem := nList[i];
    nCxItem.FStyleName := nItem.FStyleName;
    nCxItem.FStyleMark := nItem.FStyleMark;

    nCxItem.FStyleItem := TcxStyle.Create(nil);
    with nCxItem^ do
    begin
      FStyleItem.Name := sTheme_TypeStyle + IntToStr(i);
      FStyleItem.Color := nItem.FStyleColor;
      FStyleItem.TextColor := nItem.FTextColor;
      FStyleItem.Font.Name := nItem.FFontName;
      FStyleItem.Font.Size := nItem.FFontSize;
      FStyleItem.Font.Color := nItem.FFontColor;
      FStyleItem.Font.Style := nItem.FFontStyle;
      FStyleItem.Font.Charset := nItem.FFontCharset;
    end;
  end;
end;

//Desc: 获取nObject中属性是对象,且对象类型为nClass的属性名称
function GetObjectNames(const nObject: TObject; const nNames: TStrings;
  const nClass: string = ''): Boolean;
var nProp: PPropList;
    i,nCount: integer;
begin
  nNames.Clear;
  nCount := GetPropList(nObject.ClassInfo, [tkClass],nil);
  GetMem(nProp, nCount * SizeOf(PPropInfo));
  try
    nCount := GetPropList(nObject.ClassInfo, [tkClass], nProp) - 1;

    for i:=0 to nCount do
     if (nClass = '') or (CompareText(nClass, nProp[i]^.PropType^.Name) = 0) then
       nNames.Add(nProp[i]^.Name);
    Result := nNames.Count > 0;
  finally
    FreeMem(nProp, nCount * SizeOf(PPropInfo));
  end;
end;

//Desc: 获取nObject中类型为nClass的属性对象
function GetObjectList(const nObject: TObject; const nClass: TClass;
  const nList: TList): Boolean;
var nCtrl: TObject;
    nNames: TStrings;
    i,nCount: integer;
begin
  nList.Clear;
  Result := False;

  nNames := TStringList.Create;
  try
    if not GetObjectNames(nObject, nNames) then Exit;
    nCount := nNames.Count - 1;

    for i:=0 to nCount do
    begin
      nCtrl := GetObjectProp(nObject, nNames[i]);
      if Assigned(nCtrl) and (nCtrl is nClass) then nList.Add(nCtrl);
    end;

    Result := nList.Count > 0;
  finally
    nNames.Free;
  end;
end;

//Desc: 获取nObject中第一个nClass类型的对象
function GetObjectFirst(const nObject: TObject; const nClass: TClass): TObject;
var nList: TList;
begin
  Result := nil;
  nList := TList.Create;
  try
    if GetObjectList(nObject, nClass, nList) then Result := nList[0];
  finally
    nList.Free;
  end;
end;

//Desc: 依据nData配置nSheet风格包
function TcxThemeManager.LoadSheeItem(const nSheet: TcxCustomStyleSheet;
  const nData: PThemeSheetItem): Boolean;
var nNames: TStrings;
    i,nCount: integer;

    nCtrl: TObject;
    nStyles: TObject;
    nSheetStyle: PThemeSheetStyle;
begin
  Result := False;
  nStyles := GetObjectFirst(nSheet, TcxCustomStyles);
  if not Assigned(nStyles) then Exit;

  nNames := TStringList.Create;
  try
    if not GetObjectNames(nStyles, nNames, 'TcxStyle') then Exit;
    nCount := nNames.Count - 1;

    for i:=0 to nCount do
    begin
      nSheetStyle := gThemeManager.ThemeItems.SheetStyle(nData.FSheetName, nNames[i]);
      if Assigned(nSheetStyle) then
      begin
        nCtrl := StyleByName(nSheetStyle.FStyleItem);
        if Assigned(nCtrl) then SetObjectProp(nStyles, nNames[i], nCtrl); 
      end;
    end;
  finally
    nNames.Free;
  end;
end;

//Desc: 生成风格包对象
procedure TcxThemeManager.LoadSheetsItems;
var i,nCount: integer;
    nList: TList;
    nItem: PThemeSheetItem;
    nCxItem: PcxThemeSheetItem;
    nSheet: TcxCustomStyleSheet;
begin
  ClearSheets;
  nList := gThemeManager.ThemeItems.Sheets;

  nCount := nList.Count - 1;
  for i:=0 to nCount do
  begin
    nItem := nList[i];
    nSheet := NewSheetByType(nItem.FSheetType);
    if not Assigned(nSheet) then Continue;

    New(nCxItem);
    FSheets.Add(nCxItem);

    nCxItem.FSheetName := nItem.FSheetName;
    nCxItem.FSheetMark := nItem.FSheetMark;

    nCxItem.FSheetItem := nSheet;
    nCxItem.FSheetItem.Name := sTheme_TypeSheet + IntToStr(i);

    if Assigned(nCxItem.FSheetItem) then
      LoadSheeItem(nCxItem.FSheetItem, nItem);
    //read data
  end;
end;

//Desc: 载入名称为nTheme的主题
function TcxThemeManager.LoadTheme(const nTheme: string): Boolean;
begin
  Result := False;
  if gThemeManager.OpenTheme(nTheme) then
  begin
    LoadStyleItems;
    LoadSheetsItems;
    Result := FSheets.Count > 0;
  end;
end;

//Desc: 检索Styles类型为nClass的Sheet对象
function TcxThemeManager.SheetByClass(const nClass: TClass): TcxCustomStyleSheet;
var i,nCount: integer;
    nItem: PcxThemeSheetItem;
begin
  Result := nil;
  nCount := FSheets.Count - 1;

  for i:=0 to nCount do
  begin
    nItem := FSheets[i];
    if Assigned(GetObjectFirst(nItem.FSheetItem, nClass)) then
    begin
      Result := nItem.FSheetItem; Break;
    end;
  end;
end;

//Desc: 将当前展开的主题应用到nCtrl及其子对象上
function TcxThemeManager.ApplyTheme(const nCtrl: TComponent): Boolean;
var nObj: TObject;
    i,nCount: integer;  
    nStyles: TcxStyles;
    nSheet: TcxCustomStyleSheet;
begin
  Result := False;
  if FSheets.Count < 1 then Exit;

  nCount := nCtrl.ComponentCount - 1;
  for i:=0 to nCount do
  begin
    nObj := GetObjectFirst(nCtrl.Components[i], TcxStyles);
    if not Assigned(nObj) then Continue;

    nStyles := TcxStyles(nObj);
    nSheet := SheetByClass(nStyles.ClassType);

    if Assigned(nSheet) then
    begin
      nStyles.StyleSheet := nSheet;
    end;
  end;

  Result := True;
end;

//------------------------------------------------------------------------------
//Desc: 返回nStyles风格包的类型
function TcxThemeManager.SheetTypeByStyles(const nStyles: string): TThemeSheetType;
var i,nLen: integer;
begin
  Result := stVerticalGrid;
  nLen := High(cThemeSheetTypeItem);

  for i:=Low(cThemeSheetTypeItem) to nLen do
  if CompareText(cThemeSheetTypeItem[i].FStyles, nStyles) = 0 then
  begin
    Result := cThemeSheetTypeItem[i].FType; Break;
  end;
end;

//Desc: 将nStyles风格列表写入nSheet和主题管理器中
procedure SaveSheetItems(const nSheet: PThemeSheetItem; const nStyles: TObject);
var nCtrl: TObject;
    nNames: TStrings;
    i,nCount: Integer;
    nSheetStyle: PThemeSheetStyle;
begin
  nNames := TStringList.Create;
  try
    if not GetObjectNames(nStyles, nNames, 'TcxStyle') then Exit;
    nCount := nNames.Count - 1;

    for i:=0 to nCount do
    with gThemeManager do
    begin
      nCtrl := GetObjectProp(nStyles, nNames[i]);
      if not Assigned(nCtrl) then Continue;
      //风格对象

      nSheetStyle := ThemeItems.AddSheetStyle(nSheet.FSheetName);
      nSheetStyle.FStyleName := nNames[i];
      nSheetStyle.FStyleItem := TComponent(nCtrl).Name;          

      if ThemeItems.StyleIndexByName(nSheetStyle.FStyleItem) < 0 then
      with ThemeItems.AddStyle^, TcxStyle(nCtrl) do
      begin
        FStyleName := nSheetStyle.FStyleItem;
        FStyleMark := sTheme_StyleMark;
        FStyleColor := Color ;
        FTextColor := TextColor;

        FFontName := Font.Name;
        FFontSize := Font.Size;
        FFontColor := Font.Color;
        FFontStyle := Font.Style;
        FFontCharset := Font.Charset;
      end;
    end;
  finally
    nNames.Free;
  end;
end;

//Desc: 依据nCtrl及其子对象,生成新的nTheme主题
function TcxThemeManager.SaveCtrlTheme(const nCtrl: TComponent;
  const nTheme: string): Boolean;
var nStyles: TObject;
    i,nCount: integer;
    nStyleSheet: TObject;
    nSheetItem: PThemeSheetItem;
begin
  gThemeManager.CloseTheme;
  nCount := nCtrl.ComponentCount - 1;
  
  for i:=0 to nCount do
  begin
    nStyles := GetObjectFirst(nCtrl.Components[i], TcxCustomStyles);
    if not Assigned(nStyles) then Continue;

    nStyleSheet := GetObjectFirst(nStyles, TcxCustomStyleSheet);
    if Assigned(nStyleSheet) then
    begin
      nStyles := GetObjectFirst(nStyleSheet, TcxCustomStyles);
      if not Assigned(nStyles) then Continue;
    end;
    //定位风格列表

    nSheetItem := gThemeManager.ThemeItems.AddSheet;
    nSheetItem.FSheetName := sTheme_TypeSheet + IntToStr(i);
    nSheetItem.FSheetMark := sTheme_SheetMark;
    nSheetItem.FSheetType := SheetTypeByStyles(nStyles.ClassName);

    SaveSheetItems(nSheetItem, nStyles);
    //保存风格包和包内的风格数据
  end;

  with gThemeManager do
  begin
    Result := ThemeItems.SaveToFile(GetThemeFile(nTheme));
  end;
  //存入文件
end;

initialization
  {$IFDEF VerticalGrid}
  RegisterStyleSheetClass(TcxVerticalGridStyleSheet);
  {$ENDIF}

  {$IFDEF QuantumGrid}
  RegisterStyleSheetClass(TcxGridTableViewStyleSheet);
  RegisterStyleSheetClass(TcxGridBandedTableViewStyleSheet);
  RegisterStyleSheetClass(TcxGridCardViewStyleSheet);
  {$ENDIF}

  {$IFDEF TreeList}
  RegisterStyleSheetClass(TcxTreeListStyleSheet);
  {$ENDIF}
  gCxThemeManager := TCxThemeManager.Create;
  
finalization
  FreeAndNil(gCxThemeManager);
  {$IFDEF VerticalGrid}
  UnRegisterStyleSheetClass(TcxVerticalGridStyleSheet);
  {$ENDIF}

  {$IFDEF QuantumGrid}
  UnregisterStyleSheetClass(TcxGridCardViewStyleSheet);
  UnregisterStyleSheetClass(TcxGridBandedTableViewStyleSheet);
  UnregisterStyleSheetClass(TcxGridTableViewStyleSheet);
  {$ENDIF}
  {$IFDEF TreeList}
  UnRegisterStyleSheetClass(TcxTreeListStyleSheet);
  {$ENDIF}
end.
