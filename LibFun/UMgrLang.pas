{*******************************************************************************
  作者: dmzn@163.com 2010-4-22
  描述: 多语言管理器

  备注:
  *.多语言以xml格式存放,结构如下:

  <?xml version="1.0" encoding="UTF-16"?>
  <MultiLang>
    <Config>
      <default>en</default>
    </Config>
    <Langs>
      <Lang Name="简体中文" ID="cn"/>
      <Lang Name="繁体中文" ID="tw"/>
      <Lang Name="English" ID="en"/>
    </Langs>
    <Sections>
      <Section Name="test">
        <Item>
          <cn>文件</cn>
          <tw>文件</tw>
          <en>file</en>
        </Item>
        <Item>
          <cn>编辑</cn>
          <tw>编辑</tw>
          <en>edit</en>
        </Item>
      </Section>
    </Sections>
  </MultiLang>

  *.使用方法:
    1.使用LoadLangFile载入语言文件.
    2.设置NowLang指定当前正在使用的语言标记.
    3.设置LangID指定需要翻译的语言标记.
    4.设置SectionID指定使用的资源区域.
    5.使用TranslateAllCtrl翻译指定组件
*******************************************************************************}
unit UMgrLang;

interface

uses
  Windows, Classes, Controls, ComCtrls, SysUtils, Menus, NativeXml, ULibFun,
  UAdjustForm, TypInfo, ZnMD5;

type
  TMultiLangItem = record
    FName: string;
    FLangID: string;
  end;

  TDynamicLangItem = array of TMultiLangItem;
  //语言项

  TMultiLangPropertyItem = record
    FClassName: string;
    FProperty: string;
  end;
  //需翻译的对象

  TOnTransItem = procedure (const nItem: TComponent; var nNext: Boolean) of object;
  //事件

  TMultiLangManager = class(TObject)
  private
    FXML: TNativeXml;
    //操作对象
    FLang: string;
    //语言标识
    FLangFile: string;
    //语言文件
    FLangItems: TDynamicLangItem;
    //语言列表
    FNowLang: string;
    //当前语言
    FNowSection: string;
    //选中区域
    FNowNode: TXmlNode;
    //选中节点
    FHasChanged: Boolean;
    FHasItemID: Boolean;
    FNewNode: Boolean;
    //自动新建
    FPropItems: array of TMultiLangPropertyItem;
    //特定属性
    FOnTrans: TOnTransItem;
    //事件相关
  protected
    procedure GetLangItems;
    procedure DefaultLang(var nLang: string; nGet: Boolean);
    //默认语言
    procedure SetLangID(const nID: string);
    //设置语言
    procedure SetNowSection(const nSection: string);
    //激活区域
    procedure NewLangItem(const nItemID,nLang: string);
    //新建节点
    function TranslateMenu(const nMenu: TComponent): Boolean;
    function TranslateToolBar(const nBar: TComponent): Boolean;
    function TranslateStatusBar(const nBar: TComponent): Boolean;
    function TranslateLableEdit(const nEdit: TComponent): Boolean;
    function TranslateCommCtrl(const nCtrl: TComponent): Boolean;
    function TranslateCollectionCtrl(const nCtrl: TComponent): Boolean;
    //翻译相关
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    function LoadLangFile(const nFile: string): Boolean;
    function SaveLangFile(const nFile: string = ''): Boolean;
    //载入保存
    procedure RegItem(const nClassName,nProp: string);
    //注册对象
    procedure TranslateAllCtrl(const nItem: TComponent);
    //翻译组件
    function GetTextByText(const nText: string; nFrom: string = '';
      nTarget: string = ''; const nStrict: Boolean = True): string;
    function GetTextByID(const nID: string; nTarget: string = ''): string;
    //特定翻译
    class function EncodeText(const nValue: string;
      const nEncode: Boolean): string;
    //字符编码
    property XMLObj: TNativeXml read FXML;
    property LangFile: string read FLangFile;
    property LangItems: TDynamicLangItem read FLangItems;
    property LangID: string read FLang write SetLangID;
    property NowLang: string read FNowLang write FNowLang;
    property AutoNewNode: Boolean read FNewNode write FNewNode;
    property HasItemID: Boolean read FHasItemID write FHasItemID;
    property SectionID: string read FNowSection write SetNowSection;
    property OnTransItem: TOnTransItem read FOnTrans write FOnTrans;
    //属性相关
  end;

var
  gMultiLangManager: TMultiLangManager = nil;
  //全局使用

function ML(const nStr: string; const nSecton: string = ''; const nID: string = '';
 const nRestore: Boolean = False; const nDefault: string = ''): string;
//多语言翻译

implementation

const
  cHasText: array[0..2] of string = ('TEdit', 'TcxTextEdit', 'TcxButtonEdit');
  //has text property

  cHasTitle: array[0..0] of string = ('TZnTitleBar');
  //has title property

  cHasCaption: array[0..21] of string = ('TButton', 'TBitBtn', 'TSpeedButton',
    'TLabel', 'TStaticText', 'TPanel', 'TGroupbox', 'TRadioGroup',
    'TCheckbox', 'TRadioButton', 'TTabSheet',
    'TcxLabel', 'TcxRadioGroup', 'TcxCheckBox', 'TcxRadioButton',
    'TcxGroupBox', 'TdxNavBarGroup', 'TdxNavBarItem', 'TcxTabSheet',
    'TdxLayoutGroup', 'TdxLayoutItem', 'TcxButton');
  //has caption property

//------------------------------------------------------------------------------
//Date: 2010-4-23
//Parm: 待翻译;所在段;标记;默认
//Desc: 使用全局多语言翻译器解释nStr的内容
function ML(const nStr: string; const nSecton,nID: string; const nRestore: Boolean;
 const nDefault: string): string;
var nRID: string;
begin
  with gMultiLangManager do
  try
    nRID := SectionID; 
    if nSecton <> '' then
      SectionID := nSecton;
    //xxxxx

    if nID <> '' then
         Result := GetTextByID(nID)
    else Result := '';

    if Result = '' then
      Result := GetTextByText(nStr, NowLang);
    //xxxxx
    
    if Result = '' then
    begin
      if nDefault = '' then
           Result := nStr
      else Result := nDefault;

      NewLangItem(nID, nStr);
    end;
  finally
    if nRestore and (nRID <> '') then SectionID := nRID;
  end;
end;

//------------------------------------------------------------------------------
constructor TMultiLangManager.Create;
var i,nLen,nIdx: Integer;
begin
  FXML := nil;
  FLang := '';

  FNewNode := True;
  HasItemID := True;
  FNowNode := nil;
  FNowSection := '';

  nIdx := 0;
  nLen := Length(cHasCaption) + Length(cHasTitle) + Length(cHasText);
  SetLength(FPropItems, nLen);

  nLen := High(cHasCaption);
  for i:=Low(cHasCaption) to nLen do
  begin
    FPropItems[nIdx].FClassName := cHasCaption[i];
    FPropItems[nIdx].FProperty := 'Caption';
    Inc(nIdx);
  end;

  nLen := High(cHasTitle);
  for i:=Low(cHasTitle) to nLen do
  begin
    FPropItems[nIdx].FClassName := cHasTitle[i];
    FPropItems[nIdx].FProperty := 'Title';
    Inc(nIdx);
  end;

  nLen := High(cHasText);
  for i:=Low(cHasText) to nLen do
  begin
    FPropItems[nIdx].FClassName := cHasText[i];
    FPropItems[nIdx].FProperty := 'Text';
    Inc(nIdx);
  end;
end;

destructor TMultiLangManager.Destroy;
begin
  if Assigned(FXML) then
  begin
    SaveLangFile;
    FXML.Free;
  end;  

  inherited;
end;

//Desc: 注册nClassName对象,翻译其nProp属性
procedure TMultiLangManager.RegItem(const nClassName,nProp: string);
var i,nLen: Integer;
begin
  nLen := High(FPropItems);
  for i:=Low(FPropItems) to nLen do
   if (CompareText(nClassName, FPropItems[i].FClassName) = 0) and
      (CompareText(nProp, FPropItems[i].FProperty) = 0) then Exit;
  //xxxxx

  Inc(nLen);
  SetLength(FPropItems, nLen + 1);
  FPropItems[nLen].FClassName := nClassName;
  FPropItems[nLen].FProperty := nProp;
end;

//Desc: 读取nFile语言文件
function TMultiLangManager.LoadLangFile(const nFile: string): Boolean;
begin
  Result := True;
  try
    if not Assigned(FXML) then
      FXML := TNativeXml.Create;
    FXML.LoadFromFile(nFile);

    FHasChanged := False;
    FLangFile := nFile;
    SectionID := '';

    GetLangItems;
    DefaultLang(FLang, True);

    if FHasChanged then
      SaveLangFile(FLangFile);
    //xxxxx
  except
    FreeAndNil(FXML);
    Result := False;
  end;
end;

//Desc: 保存到nFile文件
function TMultiLangManager.SaveLangFile(const nFile: string): Boolean;
begin
  Result := True;
  if nFile = '' then
  begin
    if not FHasChanged then Exit;
    if not FileExists(FLangFile) then Exit;
    
    FXML.XmlFormat := xfReadable;
    FXML.SaveToFile(FLangFile);

    FHasChanged := False;
    Exit;
  end;

  if Assigned(FXML) then
  try
    FHasChanged := False;
    FXML.XmlFormat := xfReadable;
    FXML.SaveToFile(FLangFile);
  except
    Result := False;
  end;
end;

//Desc: 支持的语言列表
procedure TMultiLangManager.GetLangItems;
var i,nCount: Integer;
    nNode,nTmp: TXmlNode;
begin
  nNode := FXML.Root.FindNode('Langs');
  SetLength(FLangItems, nNode.NodeCount);

  i := 0;
  nCount := nNode.NodeCount - 1;
  while i <= nCount do
  begin
    nTmp := nNode.Nodes[i];
    FLangItems[i].FName := nTmp.AttributeByName['Name'];
    FLangItems[i].FLangID := nTmp.AttributeByName['ID'];

    Inc(i);
  end;
end;

//Desc: 默认语言
procedure TMultiLangManager.DefaultLang(var nLang: string; nGet: Boolean);
var nNode: TXmlNode;
begin
  nNode := FXML.Root.FindNode('Config').FindNode('default');
  if nGet then
       nLang := nNode.ValueAsString
  else nNode.ValueAsString := nLang;
end;

//Desc: 设置语言标识
procedure TMultiLangManager.SetLangID(const nID: string);
begin
  if Assigned(FXML) and (nID <> FLang) then
  begin
    FLang := nID;
    DefaultLang(FLang, False);
    FHasChanged := True;
  end;
end;

//Desc: 激活nSection区域
procedure TMultiLangManager.SetNowSection(const nSection: string);
var nIdx: Integer;
    nNode,nTmp: TXmlNode;
begin
  if Assigned(FXML) and (nSection <> FNowSection) then
  begin
    FNowSection := nSection;
    FNowNode := nil;
    if nSection = '' then Exit;

    nNode := FXML.Root.FindNode('Sections');
    for nIdx:=nNode.NodeCount - 1 downto 0 do
    begin
      nTmp := nNode.Nodes[nIdx];
      if CompareText(nSection, nTmp.AttributeByName['Name']) = 0 then
      begin
        FNowNode := nTmp; Exit;
      end;
    end;

    if FNewNode then
    begin
      FNowNode := nNode.NodeNew('Section');
      FNowNode.AttributeAdd('Name', nSection);
      FHasChanged := True;
    end;
  end;
end;

//Date: 2015-11-11
//Parm: 字符串;编码/解码
//Desc: 对nValue进行编码处理,过滤回车符或其它特殊字符
function RegularValue(const nValue: string; const nEncode: Boolean): string;
begin
  if nEncode then
  begin
    Result := StringReplace(nValue, #13#10, '$DA;', [rfReplaceAll]);
    Result := StringReplace(Result, #13, '$D;', [rfReplaceAll]);
    Result := StringReplace(Result, #10, '$A;', [rfReplaceAll]);
    Result := StringReplace(Result, #32, '$B;', [rfReplaceAll]);
    Result := StringReplace(Result, '<', '$L;', [rfReplaceAll]);
    Result := StringReplace(Result, '>', '$G;', [rfReplaceAll]);
    Result := StringReplace(Result, '&', '$M;', [rfReplaceAll]);
    Result := StringReplace(Result, '''', '$P;', [rfReplaceAll]);
  end else
  begin
    Result := StringReplace(nValue, '$DA;', #13#10, [rfReplaceAll]);
    Result := StringReplace(Result, '$D;', #13, [rfReplaceAll]);
    Result := StringReplace(Result, '$A;', #10, [rfReplaceAll]);
    Result := StringReplace(Result, '$B;', #32, [rfReplaceAll]);
    Result := StringReplace(Result, '$L;', '<', [rfReplaceAll]);
    Result := StringReplace(Result, '$G;', '>', [rfReplaceAll]);
    Result := StringReplace(Result, '$M;', '&', [rfReplaceAll]);
    Result := StringReplace(Result, '$P;', '''', [rfReplaceAll]);
  end;
end;

//Date: 2015-11-09
//Parm: 源字符串;格式化后;填充字符
//Desc: 判断nFixed是否为nNormal执行Format函数后的内容
function IsFormatText(var nNormal,nFixed: string; const nFill: Byte=0): Boolean;
var nWNor,nWFix: WideString;
    n,f,nInt,nLenN,nLenF,nKeep: Integer;
begin
  Result := False;
  nWNor := nNormal;
  nWFix := nFixed;

  nLenN := Length(nWNor);
  if nLenN < 1 then Exit;
  nLenF := Length(nWFix);

  nInt := 0;
  //未匹配计数
  nKeep := 0;
  //连续匹配计数

  n := 1;
  f := 1;
            
  while n <= nLenN do //匹配源和目标串
  begin
    if f > nLenF then
      f := 1;
    //circle

    while f <= nLenF do
    begin
      if (nWFix[f] = nWNor[n]) and ((nKeep > 0) or          
         ((f=nLenF) and (n=nLenN)) or
         ((f<nLenF) and (n<nLenN) and (nWFix[f+1] = nWNor[n+1]))) then
      begin
        Break;
        {tip:
         1.当前字符一致.
         2.前面字符已一致(nKeep > 0)
         3.最后一个字符.
         4.后面字符一致.
        }
      end else
      begin
        Inc(f);
        nKeep := 0;
      end;
    end;

    if f > nLenF then
    begin
      Inc(n);
      Inc(nInt);
      
      nKeep := 0;
      Continue;
    end; //源没有匹配成功

    if nWFix[f] = nWNor[n] then
    begin
      nWFix[f] := WideChar(nFill);
      nWNor[n] := WideChar(nFill);

      Inc(f);
      Inc(n);
      Inc(nKeep);
    end;
  end;

  Result := nInt / nLenN < 0.5;
  //匹配不成功小于50%

  if Result then
  begin
    nNormal := nWNor;
    nFixed := nWFix;
  end;
end;

//Date: 2015-11-09
//Parm: 源字符串;格式化后;目标字符串
//Desc: 替换nTarget中nNormal的内容为nFixed
function FixFormatText(const nNormal,nFixed,nTarget: string): string;
var nIdx: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    Result := nTarget;
    nListA.Text := nNormal;
    nListB.Text := nFixed;

    for nIdx:=nListA.Count - 1 downto 0 do
    begin
      if Trim(nListA[nIdx]) = '' then
      begin
        nListA.Delete(nIdx);
        Continue;
      end;
    end;

    for nIdx:=nListB.Count - 1 downto 0 do
    begin
      if Trim(nListB[nIdx]) = '' then
      begin
        nListB.Delete(nIdx);
        Continue;
      end;
    end;

    for nIdx:=0 to nListA.Count - 1 do
    begin
      if nIdx >= nListB.Count then Break;
      Result := StringReplace(Result, nListA[nIdx], nListB[nIdx], [rfIgnoreCase]);
    end;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

//Desc: 获取nID对应的nTarget语言
function TMultiLangManager.GetTextByID(const nID: string; nTarget: string): string;
var nNode: TXmlNode;
    i,nCount: integer;
begin
  Result := '';
  if not Assigned(FNowNode) then Exit;

  if nTarget = '' then
    nTarget := FLang;
  nCount := FNowNode.NodeCount - 1;

  for i:=0 to nCount do
  begin
    nNode := FNowNode.Nodes[i];
    if CompareText(nID, nNode.AttributeByName['ID']) = 0 then
    begin
      nNode := nNode.FindNode(nTarget);
      if Assigned(nNode) then
        Result := RegularValue(nNode.ValueAsString, False);
      Exit;
    end;
  end;
end;

//Date: 2010-4-22
//Parm: 内容;当前;翻译为;严格匹配
//Desc: 将nForm.nText翻译为指定的nTarget.nText
function TMultiLangManager.GetTextByText(const nText: string;
 nFrom,nTarget: string; const nStrict: Boolean): string;
var nTrim,nS,nT: string;
    i,nCount: integer;
    nNode,nTmp: TXmlNode;
begin
  Result := '';
  if not Assigned(FNowNode) then Exit;

  nTrim := RegularValue(nText, True);
  if nTrim = '' then Exit;

  if nFrom = '' then
    nFrom := FNowLang;
  //当前语言

  if nTarget = '' then
    nTarget := FLang;
  //当前待翻译语言

  nCount := FNowNode.NodeCount - 1;
  for i:=0 to nCount do
  begin
    nNode := FNowNode.Nodes[i];
    nTmp := nNode.FindNode(nFrom);
    if not Assigned(nTmp) then Continue;

    if CompareText(nTrim, nTmp.ValueAsString) = 0 then
    begin
      nNode := nNode.FindNode(nTarget);
      if Assigned(nNode) then
        Result := RegularValue(nNode.ValueAsString, False);
      Exit;
    end;
  end;

  if not nStrict then //非严格匹配: AAA%sBBB 和 AAA..BBB
  begin
    for i:=0 to nCount do
    begin
      nNode := FNowNode.Nodes[i];
      nTmp := nNode.FindNode(nFrom);
      if not Assigned(nTmp) then Continue;
      
      nT := nTrim;
      nS := nTmp.ValueAsString;
      if not IsFormatText(nS, nT, 10) then Continue;
      //模糊匹配不成功

      nNode := nNode.FindNode(nTarget);
      if Assigned(nNode) then
      begin
        Result := FixFormatText(nS, nT, nNode.ValueAsString);
        Result := RegularValue(Result, False);
      end;

      Exit;
    end;
  end;

  Result := nText;
  nTrim := MD5Print(MD5String(nText));
  NewLangItem(nTrim, nText);
end;

//Date: 2010-4-28
//Parm: 节点;内容
//Desc: 在nItem下创建所支持的多语言节点,内容为nLang
procedure TMultiLangManager.NewLangItem(const nItemID,nLang: string);
var nIdx: Integer;
    nNode: TXmlNode;
begin
  if FNewNode and (Trim(nLang) <> '') and Assigned(FNowNode)then
  begin
    nNode := FNowNode.NodeNew('Item');
    if FHasItemID then
      nNode.AttributeAdd('ID', nItemID);
    //xxxxx

    for nIdx:=Low(FLangItems) to High(FLangItems) do
      nNode.NodeNew(FLangItems[nIdx].FLangID).ValueAsString := RegularValue(nLang, True);
    FHasChanged := True;
  end;
end;

//Desc: 格式化字符串
class function TMultiLangManager.EncodeText(const nValue: string;
  const nEncode: Boolean): string;
begin
  Result := RegularValue(nValue, nEncode);
end;

//------------------------------------------------------------------------------
//Desc: 枚举nPItem下的所有组件
procedure EnumSubComponentList(const nPItem: TComponent; const nList: TList);
var i,nCount: integer;
begin
  with nPItem do
  begin
    nCount := ComponentCount - 1;

    for i:=0 to nCount do
    if nList.IndexOf(Components[i]) < 1 then
    begin
      nList.Add(Components[i]);
      EnumSubComponentList(Components[i], nList);
    end;
  end;
end;

//Desc: 翻译nItem元素到当前语言,包括子元素
procedure TMultiLangManager.TranslateAllCtrl(const nItem: TComponent);
var nList: TList;
    nNext: Boolean;
    nTemp: TComponent;
    i,nCount: Integer;
begin
  if Assigned(FXML) and Assigned(FNowNode) then
       FHasChanged := False
  else Exit;

  nList := TList.Create;
  try
    nList.Add(nItem);
    if nItem is TWinControl then
      EnumSubCtrlList(TWinControl(nItem), nList);
    EnumSubComponentList(nItem, nList);

    nCount := nList.Count - 1;
    for i:=0 to nCount do
    begin
      nTemp := TComponent(nList[i]);

      if Assigned(FOnTrans) then
      begin
        nNext := True;
        FOnTrans(nTemp, nNext);
        if not nNext then Continue;
      end;

      if TranslateMenu(nTemp) then Continue;
      if TranslateToolBar(nTemp) then Continue;
      if TranslateLableEdit(nTemp) then Continue;
      if TranslateStatusBar(nTemp) then Continue;

      TranslateCommCtrl(nTemp);
      TranslateCollectionCtrl(nTemp);
      //通用多属性翻译
    end;
  finally
    nList.Free;
    if FHasChanged and Assigned(FXML) then SaveLangFile(FLangFile);
  end;
end;

//Desc: 构建以nPrefix为前缀,nSuffix为后缀的节点ID
function MakeID(const nPrefix,nName: string; const nSuffix: string = ''): string;
begin
  if nSuffix = '' then
       Result := Format('%s_%s', [nPrefix, nName])
  else Result := Format('%s_%s:%s', [nPrefix, nName, nSuffix]);
end;

//Desc: 枚举nPMenu的所有子菜单项
procedure EnumSubMenuItem(const nPMenu: TMenuItem; const nList: TList);
var i,nCount: integer;
begin
  nCount := nPMenu.Count - 1;
  for i:=0 to nCount do
  begin
    nList.Add(nPMenu.Items[i]);
    if nPMenu.Items[i].Count > 0 then
      EnumSubMenuItem(nPMenu.Items[i], nList);
    //xxxxx
  end;
end;

//Desc: 翻译菜单
function TMultiLangManager.TranslateMenu(const nMenu: TComponent): Boolean;
var nStr: string;
    nList: TList;
    nItem: TMenuItem;
    i,nCount: integer;
begin
  Result := nMenu is TMenu;
  if not Result then Exit;

  nList := TList.Create;
  try
    nCount := TMenu(nMenu).Items.Count - 1;
    for i:=0 to nCount do
    begin
      nList.Add(TMenu(nMenu).Items[i]);
      EnumSubMenuItem(TMenu(nMenu).Items[i], nList);
    end;

    nCount := nList.Count - 1;
    for i:=0 to nCount do
    begin
      nItem := TMenuItem(nList[i]);
      nStr := GetTextByID(MakeID(nMenu.Name, nItem.Name));

      if nStr = '' then
        nStr := GetTextByText(nItem.Caption, FNowLang);
      //xxxxx

      if nStr = '' then
           NewLangItem(MakeID(nMenu.Name, nItem.Name), nItem.Caption)
      else nItem.Caption := nStr;
    end;
  finally
    nList.Free;
  end;
end;

//Desc: 翻译工具栏
function TMultiLangManager.TranslateToolBar(const nBar: TComponent): Boolean;
var nStr: string;
    nList: TList;
    nBtn: TToolButton;
    i,nCount: integer;
begin
  Result := nBar is TToolBar;
  if not Result then Exit;

  nList := TList.Create;
  try
    nCount := TToolBar(nBar).ButtonCount - 1;
    for i:=0 to nCount do nList.Add(TToolBar(nBar).Buttons[i]);

    nCount := nList.Count - 1;
    for i:=0 to nCount do
    begin
      nBtn := TToolButton(nList[i]);
      nStr := GetTextByID(MakeID(nBar.Name, nBtn.Name));

      if nStr = '' then
        nStr := GetTextByText(nBtn.Caption, FNowLang);
      //xxxxx

      if nStr = '' then
           NewLangItem(MakeID(nBar.Name, nBtn.Name), nBtn.Caption)
      else nBtn.Caption := nStr;
    end;
  finally
    nList.Free;
  end;
end;

//Desc: 翻译状态栏
function TMultiLangManager.TranslateStatusBar(const nBar: TComponent): Boolean;
var nStr: string;
    nP: TStatusPanel;
    i,nCount: integer;
begin
  Result := nBar is TStatusBar;
  if not Result then Exit;

  nCount := TStatusBar(nBar).Panels.Count - 1;
  for i:=0 to nCount do
  begin
    nP := TStatusBar(nBar).Panels[i];
    nStr := GetTextByID(MakeID(nBar.Name, IntToStr(i)));

    if nStr = '' then
      nStr := GetTextByText(nP.Text, FNowLang);
    //xxxxx

    if nStr = '' then
         NewLangItem(MakeID(nBar.Name, IntToStr(i)), nP.Text)
    else nP.Text := nStr;
  end;
end;

//Desc: 翻译标签文本框
function TMultiLangManager.TranslateLableEdit(const nEdit: TComponent): Boolean;
var nStr,nVal: string;
    nObj: TObject;
begin
  Result := CompareText(nEdit.ClassName, 'TLabeledEdit') = 0;
  if not Result then Exit;

  nStr := GetTextByID(MakeID('Edt', nEdit.Name));
  if nStr = '' then
  begin
    nVal := GetStrProp(nEdit, 'Text');
    nStr := GetTextByText(nVal, FNowLang);
  end;

  if nStr = '' then
       NewLangItem(MakeID('Edt', nEdit.Name), nVal)
  else SetStrProp(nEdit, 'Text', nStr);

  nObj := GetObjectProp(nEdit, 'EditLabel');
  nStr := GetTextByID(MakeID('Lbl', nEdit.Name));

  if nStr = '' then
  begin
    nVal := GetStrProp(nObj, 'Caption');
    nStr := GetTextByText(nVal, FNowLang);
  end;

  if nStr = '' then
       NewLangItem(MakeID('Lbl', nEdit.Name), nVal)
  else SetStrProp(nObj, 'Caption', nStr);
end;

//------------------------------------------------------------------------------
//Date: 2010-9-1
//Parm: 对象;属性(Ex:a.b.c);最后一级属性有效
//Desc: 查找nProp属性所在的对象,支持连级属性(Ex:c在b对象上,返回b)
function FindPropObj(const nCtrl: TObject; var nProp: string;
 const nLastValid: Boolean = True): TObject;
var nObj: TObject;
    nList: TStrings;
begin
  Result := nil;

  if Pos('.', nProp) < 2 then
  begin
    if IsPublishedProp(nCtrl, nProp) then
      Result := nCtrl;
    Exit;
  end;

  nList := TStringList.Create;
  try
    if SplitStr(nProp, nList, 0, '.') and IsPublishedProp(nCtrl, nList[0]) and
       (PropType(nCtrl, nList[0]) = tkClass) then
    begin
      nObj := GetObjectProp(nCtrl, nList[0]);
      //property is object

      if not Assigned(nObj) then Exit;
      nList.Delete(0);

      if (nList.Count > 1) or nLastValid then
      begin
        nProp := CombinStr(nList, '.', False);
        Result := FindPropObj(nObj, nProp, nLastValid);
      end else

      if nList.Count = 1 then
      begin
        nProp := nList[0];
        Result := nObj;
      end;
    end;
  finally
    nList.Free;
  end;
end;

//Desc: 将nValue赋予nList.Text,直接等值会导致nList.Objects[]丢失
procedure SetStringsValue(const nList: TStrings; const nValue: string);
var nIdx: Integer;
    nTmp: TStrings;
begin
  nTmp := TStringList.Create;
  try
    nIdx := 0;
    nTmp.Text := nValue;

    while (nIdx < nTmp.Count) and (nIdx < nList.Count) do
    begin
      nList[nIdx] := nTmp[nIdx];
      Inc(nIdx);
    end;
  finally
    nTmp.Free;
  end;
end;

//Date: 2010-9-1
//Parm: 对象;属性;值;读or写
//Desc: 读写nCtrl.nProg的值
procedure DoCtrlProg(const nCtrl: TObject; const nProg: string;
 var nValue: string; const nGet: Boolean = True);
var nObj: TObject;
begin
  if PropType(nCtrl, nProg) = tkClass then
  begin
    nObj := GetObjectProp(nCtrl, nProg);
    if nObj is TStrings then
    begin
      if nGet then
           nValue := (nObj as TStrings).Text
      else SetStringsValue(nObj as TStrings, RegularValue(nValue, False));
    end;

    Exit;
  end;

  if nGet then
       nValue := GetStrProp(nCtrl, nProg)
  else SetStrProp(nCtrl, nProg, nValue);
end;

//Desc: 翻译公共常用组件
function TMultiLangManager.TranslateCommCtrl(const nCtrl: TComponent): Boolean;
var nObj: TObject;
    i,nCount: Integer;
    nStr,nVal,nID,nProp: string;
begin
  Result := False;
  nCount := High(FPropItems);

  for i:=Low(FPropItems) to nCount do
  if CompareText(nCtrl.ClassName, FPropItems[i].FClassName) = 0 then
  begin
    nProp := FPropItems[i].FProperty;
    nObj := FindPropObj(nCtrl, nProp);
    if not Assigned(nObj) then Continue;

    nID := MakeID('COM', nCtrl.Name, FPropItems[i].FProperty);
    nStr := GetTextByID(nID);

    if nStr = '' then
    begin
      DoCtrlProg(nObj, nProp, nVal, True);
      if FHasItemID then
      begin
        NewLangItem(nID, nVal); Continue;
      end;

      nStr := GetTextByText(nVal, FNowLang);
    end;

    if nStr = '' then
         NewLangItem(nID, nVal)
    else DoCtrlProg(nObj, nProp, nStr, False);

    Result := True;
    //同组件多属性,不予退出
  end;
end;

//Desc: 翻译a.collection[0].text类型的组件
function TMultiLangManager.TranslateCollectionCtrl(
  const nCtrl: TComponent): Boolean;
var nObj: TObject;
    nCln: TCollection;
    nIdx,i,nCount: Integer;
    nStr,nVal,nID,nProp: string;
begin
  Result := False;
  nCount := High(FPropItems);

  for i:=Low(FPropItems) to nCount do
  if CompareText(nCtrl.ClassName, FPropItems[i].FClassName) = 0 then
  begin
    nProp := FPropItems[i].FProperty;
    nObj := FindPropObj(nCtrl, nProp, False);
    if not Assigned(nObj) then Continue;

    if not (nObj is TCollection) then Continue;
    nCln := nObj as TCollection;

    for nIdx:=0 to nCln.Count - 1 do
    begin
      nID := StringReplace(FPropItems[i].FProperty, '.', '_', [rfReplaceAll]);
      nID := MakeID(nCtrl.Name, nID, IntToStr(nIdx));
      nStr := GetTextByID(nID);

      if nStr = '' then
      begin
        DoCtrlProg(nCln.Items[nIdx], nProp, nVal, True);
        if FHasItemID then
        begin
          NewLangItem(nID, nVal); Continue;
        end;

        nStr := GetTextByText(nVal, FNowLang);
      end;

      if nStr = '' then
           NewLangItem(nID, nVal)
      else DoCtrlProg(nCln.Items[nIdx], nProp, nStr, False);
    end;

    Result := True;
    //同组件多属性,不予退出
  end;
end;

initialization
  gMultiLangManager := nil;
finalization
  FreeAndNil(gMultiLangManager);
end.
