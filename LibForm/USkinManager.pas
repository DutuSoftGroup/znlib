{*******************************************************************************
  ����: dmzn@163.com 2011-10-8
  ����: Ƥ��������

  ����:
  *.SkinManager������غ�����Ƥ���ļ�.
  *.SkinManagerά��һ�������ֱ�ʶ��Ƥ������,ÿ�������ʶƤ������.
*******************************************************************************}
unit USkinManager;

interface

uses
  Windows, Classes, Graphics, SysUtils, NativeXml, IniFiles, ULibFun;

const
  cSkinStringBufLen = 50;
  //�ַ����峤��
  cSkinObjectBufLen = 10;
  //���󻺳峤��

type
  PSkinParamForm = ^TSkinParamForm;
  TSkinParamForm = record
    FSizeable: Boolean;  //��С�ɱ�
    FMinWidth: Integer;
    FMaxWidth: Integer;
    FMinHeight: Integer;
    FMaxHeight: Integer; //��������
    FEdgeArea: TRect;    //�߽�����
  end;

  PSkinParamImage = ^TSkinParamImage;
  TSkinParamImage = record
    FEnable: Boolean;
    FImgID: string[cSkinStringBufLen];
    FImage: TPicture;
    FFile: string[cSkinStringBufLen];
  end;

  PSkinParamButton = ^TSkinParamButton;
  TSkinParamButton = record
    FEnable: Boolean;
    FBtnID: string[cSkinStringBufLen];
    FHotArea: TRect;
    FNormal: TSkinParamImage;
    FEnter: TSkinParamImage;
    FDown: TSkinParamImage;
    FDisable: TSkinParamImage;
  end;

  TSkinParamImages = array[0..cSkinObjectBufLen-1] of TSkinParamImage;
  TSkinParamButtons = array[0..cSkinObjectBufLen-1] of TSkinParamButton;
  TSkinParamBtnArray = array of TSkinParamButton;
  TSkinParamImgArray = array of TSkinParamImage;

  PSkinParamCaption = ^TSkinParamCaption;
  TSkinParamCaption = record
    FHeight: Integer;
    FTextColor: TColor;
    FMaskLeft: TSkinParamImage;
    FMaskRight: TSkinParamImage;
    FImgFill: TSkinParamImage;
    FImgLeft: TSkinParamImages;
    FImgRight: TSkinParamImages;
    FBtnLeft: TSkinParamButtons;
    FBtnRight: TSkinParamButtons;
  end;

  PSkinParamBottom = ^TSkinParamBottom;
  TSkinParamBottom = record
    FMaskLeft: TSkinParamImage;
    FMaskRight: TSkinParamImage;
    FImgFill: TSkinParamImage;
    FImgLeft: TSkinParamImages;
    FImgRight: TSkinParamImages;
    FBtnLeft: TSkinParamButtons;
    FBtnRight: TSkinParamButtons;
  end;

  TSkinManager = class;
  TSkinItem = class(TObject)
  private
    FOwner: TSkinManager;
    //��������
    FDir: string;
    //�ļ�·��
  protected
    procedure ResetAllData(const nNeedFree: Boolean);
    //��������
    procedure FreeImage(const nImage: TSkinParamImage);
    //�ͷ�ͼƬ
    procedure FreeButton(const nButton: TSkinParamButton);
    //�ͷŰ�ť
    procedure ActionImage(var nImage: TSkinParamImage; const nNode: TXmlNode;
      const nRead: Boolean = True);
    procedure ActionImages(var nImages: TSkinParamImages; const nNode: TXmlNode;
      const nRead: Boolean = True);
    //ͼƬ����
    procedure ActionButton(var nButton: TSkinParamButton; const nNode: TXmlNode;
      const nRead: Boolean = True);
    procedure ActionButtons(var nButtons: TSkinParamButtons;
      const nNode: TXmlNode; const nRead: Boolean = True);
    //��ť����
    procedure ActionForm(var nForm: TSkinParamForm; const nNode: TXmlNode;
      const nRead: Boolean = True);
    //���嶯��
    procedure ActionCaption(var nTitle: TSkinParamCaption; const nNode: TXmlNode;
      const nRead: Boolean = True);
    //���⶯��
    procedure ActionBottom(var nBottom: TSkinParamBottom; const nNode: TXmlNode;
      const nRead: Boolean = True);
    //�׶˶���
    procedure ActionButtonArray(var nButtons: TSkinParamBtnArray;
      const nNode: TXmlNode; const nRead: Boolean = True);
    //��ť��
    procedure ActionImageArray(var nImages: TSkinParamImgArray;
      const nNode: TXmlNode; const nRead: Boolean = True);
    //ͼƬ��
  public
    SkinID: string;
    Form: TSkinParamForm;
    Title: TSkinParamCaption;
    BorderLeft: TSkinParamImage;
    BorderRight: TSkinParamImage;
    BorderBottom: TSkinParamBottom;
    //�������
    Buttons: TSkinParamBtnArray;
    Images: TSkinParamImgArray;
    //�������
    constructor Create(const nOwner: TSkinManager);
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadItem(const nRoot: TXmlNode);
    procedure SaveItem(const nRoot: TXmlNode);
    //��ȡ����
  end;

  TSkinManager = class(TObject)
  private
    FFileName: string;
    //Ƥ���ļ�
    FReader: TNativeXml;
    //�ļ�����
    FItems: TList;
    //�����б�
  protected
    procedure ClearList(const nFree: Boolean);
    //������Դ
    function FindItem(const nName: string): Integer;
    //��������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    function LoadSkin(const nFile: string): Boolean;
    function SaveSkin(const nFile: string): Boolean;
    //��ȡ����
    function LoadDefaultSkinFile(const nDir: string): Boolean;
    //����Ĭ��
    function NewSkin(const nName: string): TSkinItem;
    function DelSkin(const nName: string): Boolean;
    //���ɾ��
    function GetSkin(const nName: string): TSkinItem;
    //��ȡ����
    property SkinFile: string read FFileName;
    //�������
  end;

var
  gSkinManager: TSkinManager = nil;
  //ȫ��ʹ��

implementation

const
  cSizeForm = SizeOf(TSkinParamForm);
  cSizeTitle = SizeOf(TSkinParamCaption);
  cSizeImage = SizeOf(TSkinParamImage);
  cSizeBottom = SizeOf(TSkinParamBottom);

resourcestring
  sSkinConfig = 'skin.ini';
  //Ƥ�������ļ�

constructor TSkinItem.Create(const nOwner: TSkinManager);
begin
  inherited Create;
  SkinID := '';
  
  FOwner := nOwner;
  ResetAllData(False);
end;

destructor TSkinItem.Destroy;
begin
  ResetAllData(True);
  inherited;
end;

//Desc: �ͷ�ͼ��
procedure TSkinItem.FreeImage(const nImage: TSkinParamImage);
begin
  if Assigned(nImage.FImage) then
    nImage.FImage.Free;
  //xxxxx
end;

//Desc: �ͷ�nButton��ť
procedure TSkinItem.FreeButton(const nButton: TSkinParamButton);
begin
  with nButton do
  begin
    FreeImage(FNormal);
    FreeImage(FEnter);
    FreeImage(FDown);
    FreeImage(FDisable);
  end;
end;

//Desc: ��������
procedure TSkinItem.ResetAllData(const nNeedFree: Boolean);
var nInt: Integer;
begin
  if nNeedFree then
  begin
    with Title do
    begin
      FreeImage(FMaskLeft);
      FreeImage(FMaskRight);
      FreeImage(FImgFill);

      for nInt:=Low(FImgLeft) to High(FImgLeft) do
        FreeImage(FImgLeft[nInt]);
      //xxxxx

      for nInt:=Low(FImgRight) to High(FImgRight) do
        FreeImage(FImgRight[nInt]);
      //xxxxx

      for nInt:=Low(FBtnLeft) to High(FBtnLeft) do
        FreeButton(FBtnLeft[nInt]);
      //xxxxx

      for nInt:=Low(FBtnRight) to High(FBtnRight) do
        FreeButton(FBtnRight[nInt]);
      //xxxxx
    end;

    with BorderBottom do
    begin
      FreeImage(FMaskLeft);
      FreeImage(FMaskRight);
      FreeImage(FImgFill);

      for nInt:=Low(FImgLeft) to High(FImgLeft) do
        FreeImage(FImgLeft[nInt]);
      //xxxxx

      for nInt:=Low(FImgRight) to High(FImgRight) do
        FreeImage(FImgRight[nInt]);
      //xxxxx

      for nInt:=Low(FBtnLeft) to High(FBtnLeft) do
        FreeButton(FBtnLeft[nInt]);
      //xxxxx

      for nInt:=Low(FBtnRight) to High(FBtnRight) do
        FreeButton(FBtnRight[nInt]);
      //xxxxx
    end;

    FreeImage(BorderLeft);
    FreeImage(BorderRight);

    for nInt:=Low(Buttons) to High(Buttons) do
      FreeButton(Buttons[nInt]);
    //xxxxx

    for nInt:=Low(Images) to High(Images) do
      FreeImage(Images[nInt]);
    //xxxxx
  end;

  FillChar(Form, cSizeForm, #0);
  Form.FSizeable := True;

  FillChar(Title, cSizeTitle, #0);
  Title.FTextColor := clBlack;

  FillChar(BorderBottom, cSizeBottom, #0);
  FillChar(BorderLeft, cSizeImage, #0);
  FillChar(BorderRight, cSizeImage, #0);
  SetLength(Buttons, 0);
  SetLength(Images, 0);
end;

//------------------------------------------------------------------------------
//Desc: ��дnButton�ڵ�
procedure TSkinItem.ActionButton(var nButton: TSkinParamButton;
  const nNode: TXmlNode; const nRead: Boolean);
var nList: TStrings;
begin
  if Assigned(nNode) then
  with nButton do
  begin
    if nRead then
    begin
      nList := TStringList.Create;
      try
        SplitStr(nNode.AttributeByName['hotarea'], nList, 0, ',');
        if nList.Count <> 4 then Exit;
        FHotArea := Rect(StrToInt(nList[0]), StrToInt(nList[1]),
                         StrToInt(nList[2]), StrToInt(nList[3]));
        //xxxxx
      finally
        nList.Free;
      end;

      FEnable := True;
      FBtnID := nNode.AttributeByName['id'];
      ActionImage(FNormal, nNode.FindNode('img_normal'), True);
      ActionImage(FEnter, nNode.FindNode('img_enter'), True);
      ActionImage(FDown, nNode.FindNode('img_down'), True);
      ActionImage(FDisable, nNode.FindNode('img_disable'), True);
    end else
    begin
      nNode.NodesClear;
      nNode.AttributesClear;

      nNode.AttributeAdd('id', FBtnID);
      with FHotArea do
      nNode.AttributeAdd('hotarea', Format('%d,%d,%d,%d', [Left, Top, Right,
                                                           Bottom]));
      //xxxxx

      ActionImage(FNormal, nNode.NodeNew('img_normal'), False);
      ActionImage(FEnter, nNode.NodeNew('img_enter'), False);
      ActionImage(FDown, nNode.NodeNew('img_down'), False);
      ActionImage(FDisable, nNode.NodeNew('img_disable'), False);
    end;
  end;
end;

//Desc: ��дnNode�µ�Button�б�
procedure TSkinItem.ActionButtons(var nButtons: TSkinParamButtons;
  const nNode: TXmlNode; const nRead: Boolean);
var nInt,nIdx: Integer;
begin
  if Assigned(nNode) then
  begin
    if nRead then
    begin
      nInt := Low(nButtons);

      for nIdx:=0 to nNode.NodeCount - 1 do
      if CompareText(nNode.Nodes[nIdx].Name, 'btn') = 0 then
      begin
        if nInt <= High(nButtons) then
        begin
          ActionButton(nButtons[nInt], nNode.Nodes[nIdx], True);
          Inc(nInt);
        end else Break;
      end;
    end else
    begin
      for nIdx:=Low(nButtons) to High(nButtons) do
       if nButtons[nIdx].FEnable then
        ActionButton(nButtons[nIdx], nNode.NodeNew('btn'), False);
      //xxxxx
    end;
  end;
end;

//Desc: ��дͼƬ����
procedure TSkinItem.ActionImage(var nImage: TSkinParamImage;
  const nNode: TXmlNode; const nRead: Boolean);
var nStr: string;
begin
  if Assigned(nNode) then
  with nImage do
  begin
    if nRead then
    begin
      nStr := nNode.ValueAsString;
      if FileExists(FDir + nStr) then
      begin
        FImage := TPicture.Create;
        FImage.LoadFromFile(FDir + nStr);

        FFile := nStr;
        FEnable := True;
        FImgID := nNode.AttributeByName['id'];
      end;
    end else
    begin
      nNode.ValueAsString := FFile
    end;
  end;
end;

//Desc: ��дnNode�µ�ͼƬ�б�
procedure TSkinItem.ActionImages(var nImages: TSkinParamImages;
  const nNode: TXmlNode; const nRead: Boolean);
var nInt,nIdx: Integer;
begin
  if Assigned(nNode) then
  begin
    if nRead then
    begin
      nInt := Low(nImages);

      for nIdx:=0 to nNode.NodeCount - 1 do
      if CompareText(nNode.Nodes[nIdx].Name, 'img') = 0 then
      begin
        if nInt <= High(nImages) then
        begin
          ActionImage(nImages[nInt], nNode.Nodes[nIdx], True);
          Inc(nInt);
        end else Break;
      end;
    end else
    begin
      for nIdx:=Low(nImages) to High(nImages) do
       if nImages[nIdx].FFile <> '' then
        ActionImage(nImages[nIdx], nNode.NodeNew('img'), False);
      //xxxxx
    end;
  end;
end;

//Desc: ��дnForm��������
procedure TSkinItem.ActionForm(var nForm: TSkinParamForm;
  const nNode: TXmlNode; const nRead: Boolean);
var nSub: TXmlNode;
begin
  if Assigned(nNode) then
  with nForm do
  begin
    if nRead then
    begin
      nSub := nNode.NodeByName('sizeable');
      FSizeable := nSub.ValueAsBoolDef(True);

      nSub := nNode.NodeByName('arealimite');
      FMinWidth := StrToInt(nSub.AttributeByName['minw']);
      FMinHeight := StrToInt(nSub.AttributeByName['minh']);
      FMaxWidth := StrToInt(nSub.AttributeByName['maxw']);
      FMaxHeight := StrToInt(nSub.AttributeByName['maxh']);

      nSub := nNode.NodeByName('edgewidth');
      FEdgeArea := Rect(StrToInt(nSub.AttributeByName['left']),
                        StrToInt(nSub.AttributeByName['top']),
                        StrToInt(nSub.AttributeByName['right']),
                        StrToInt(nSub.AttributeByName['bottom']));
      //xxxxx
    end else
    begin
      nNode.NodeNew('sizeable').ValueAsBool := FSizeable;
      nSub := nNode.NodeNew('arealimite');

      with nSub do
      begin
        AttributeAdd('minw', FMinWidth);
        AttributeAdd('minh', FMinHeight);
        AttributeAdd('maxw', FMaxWidth);
        AttributeAdd('maxh', FMaxHeight);
      end;

      nSub := nNode.NodeNew('edgewidth');
      with nSub,FEdgeArea do
      begin
        AttributeAdd('left', Left);
        AttributeAdd('top', Top);
        AttributeAdd('right', Right);
        AttributeAdd('bottom', Bottom);
      end;
    end;
  end;
end;

//Desc: ��дnTitle����
procedure TSkinItem.ActionCaption(var nTitle: TSkinParamCaption;
  const nNode: TXmlNode; const nRead: Boolean);
var nSub: TXmlNode;
begin
  if Assigned(nNode) then
  with Title do
  begin
    if nRead then
    begin
      FHeight := StrToInt(nNode.AttributeByName['height']);
      FTextColor := StrToInt(nNode.AttributeByName['textcolor']);

      nSub := nNode.NodeByName('left');
      ActionImage(FMaskLeft, nSub.FindNode('img_mask'), True);
      ActionImages(FImgLeft, nSub, True);
      ActionButtons(FBtnLeft, nSub, True);

      ActionImage(FImgFill, nNode.FindNode('mid'));
      nSub := nNode.NodeByName('right');
      ActionImage(FMaskRight, nSub.FindNode('img_mask'), True);
      ActionImages(FImgRight, nSub, True);
      ActionButtons(FBtnRight, nSub, True);
    end else
    begin
      nNode.AttributeAdd('height', FHeight);
      nNode.AttributeAdd('textcolor', FTextColor);
      nSub := nNode.NodeNew('left');

      ActionImage(FMaskLeft, nSub.NodeNew('img_mask'), False);
      ActionImages(FImgLeft, nSub, False);
      ActionButtons(FBtnLeft, nSub, False);

      ActionImage(FImgFill, nNode.NodeNew('mid'), False);
      nSub := nNode.NodeNew('right');
      ActionImage(FMaskRight, nSub.NodeNew('img_mask'), False);
      ActionImages(FImgRight, nSub, False);
      ActionButtons(FBtnRight, nSub, False);
    end;
  end;
end;

//Desc: ��дnBottom����
procedure TSkinItem.ActionBottom(var nBottom: TSkinParamBottom;
  const nNode: TXmlNode; const nRead: Boolean);
var nSub: TXmlNode;
begin
  if Assigned(nNode) then
  with nBottom do
  begin
    if nRead then
    begin
      nSub := nNode.NodeByName('left');
      ActionImage(FMaskLeft, nSub.FindNode('img_mask'), True);
      ActionImages(FImgLeft, nSub, True);
      ActionButtons(FBtnLeft, nSub, True);

      ActionImage(FImgFill, nNode.FindNode('mid'));
      nSub := nNode.NodeByName('right');
      ActionImage(FMaskRight, nSub.FindNode('img_mask'), True);
      ActionImages(FImgRight, nSub, True);
      ActionButtons(FBtnRight, nSub, True);
    end else
    begin
      nSub := nNode.NodeNew('left');
      ActionImage(FMaskLeft, nSub.NodeNew('img_mask'), False);
      ActionImages(FImgLeft, nSub, False);
      ActionButtons(FBtnLeft, nSub, False);

      ActionImage(FImgFill, nNode.NodeNew('mid'), False);
      nSub := nNode.NodeNew('right');
      ActionImage(FMaskRight, nSub.NodeNew('img_mask'), False);
      ActionImages(FImgRight, nSub, False);
      ActionButtons(FBtnRight, nSub, False);
    end;
  end;
end;

//Desc: ��дnButtons��ť������
procedure TSkinItem.ActionButtonArray(var nButtons: TSkinParamBtnArray;
  const nNode: TXmlNode; const nRead: Boolean);
var nInt,nIdx: Integer;
begin
  if Assigned(nNode) then
  begin
    if nRead then
    begin 
      for nIdx:=0 to nNode.NodeCount - 1 do
      if CompareText(nNode.Nodes[nIdx].Name, 'btn') = 0 then
      begin
        nInt := Length(nButtons);
        SetLength(nButtons, nInt+1);
        ActionButton(nButtons[nInt], nNode.Nodes[nIdx], True);
      end;
    end else
    begin
      for nIdx:=Low(nButtons) to High(nButtons) do
       if nButtons[nIdx].FEnable then
        ActionButton(nButtons[nIdx], nNode.NodeNew('btn'), False);
      //xxxxx
    end;
  end;
end;

//Desc: ��дnImages��ť������
procedure TSkinItem.ActionImageArray(var nImages: TSkinParamImgArray;
  const nNode: TXmlNode; const nRead: Boolean);
var nInt,nIdx: Integer;
begin
  if Assigned(nNode) then
  begin
    if nRead then
    begin 
      for nIdx:=0 to nNode.NodeCount - 1 do
      if CompareText(nNode.Nodes[nIdx].Name, 'img') = 0 then
      begin
        nInt := Length(nImages);
        SetLength(nImages, nInt+1);
        ActionImage(nImages[nInt], nNode.Nodes[nIdx], True);
      end;
    end else
    begin
      for nIdx:=Low(nImages) to High(nImages) do
       if nImages[nIdx].FEnable then
        ActionImage(nImages[nIdx], nNode.NodeNew('img'), False);
      //xxxxx
    end;
  end;
end;

//Desc: ��nRoot�ڵ�����Ƥ������
procedure TSkinItem.LoadItem(const nRoot: TXmlNode);
begin
  ResetAllData(True);
  FDir := ExtractFilePath(FOwner.FFileName);
  SkinID := nRoot.NodeByName('name').ValueAsString;

  ActionForm(Form, nRoot.NodeByName('form'));
  ActionCaption(Title, nRoot.NodeByName('caption'));
  ActionImage(BorderLeft, nRoot.FindNode('border_left'));
  ActionImage(BorderRight, nRoot.FindNode('border_right'));
  ActionBottom(BorderBottom, nRoot.FindNode('border_bottom'));
  ActionButtonArray(Buttons, nRoot.FindNode('buttons'));
  ActionImageArray(Images, nRoot.FindNode('images'));
end;

//Desc: ����
procedure TSkinItem.SaveItem(const nRoot: TXmlNode);
begin
  nRoot.NodesClear;
  nRoot.NodeNew('name').ValueAsString := SkinID;

  ActionForm(Form, nRoot.NodeNew('form'), False);
  ActionCaption(Title, nRoot.NodeNew('caption'), False);
  ActionImage(BorderLeft, nRoot.NodeNew('border_left'), False);
  ActionImage(BorderRight, nRoot.NodeNew('border_right'), False);
  ActionBottom(BorderBottom, nRoot.NodeNew('border_bottom'), False);
  ActionButtonArray(Buttons, nRoot.NodeNew('buttons'), False);
  ActionImageArray(Images, nRoot.FindNode('images'), False);
end;

//------------------------------------------------------------------------------
constructor TSkinManager.Create;
begin
  FItems := TList.Create;
  inherited;
end;

destructor TSkinManager.Destroy;
begin
  ClearList(True);
  FReader.Free;
  inherited;
end;

procedure TSkinManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FItems.Count - 1 downto 0 do
  begin
    TSkinItem(FItems[nIdx]).Free;
    FItems.Delete(nIdx);
  end;

  if nFree then FItems.Free;
end;

//Desc: ��������ΪnName��Ƥ��
function TSkinManager.FindItem(const nName: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FItems.Count - 1 downto 0 do
  if CompareText(TSkinItem(FItems[nIdx]).SkinID, nName) = 0 then
  begin
    Result := nIdx; Break;
  end;
end;

//Desc: ��ȡ����ΪnName��Ƥ������
function TSkinManager.GetSkin(const nName: string): TSkinItem;
var nIdx: Integer;
begin   
  nIdx := FindItem(nName);
  if nIdx > -1 then
       Result := TSkinItem(FItems[nIdx])
  else Result := nil;
end;

//Desc: �½�nNameƤ������
function TSkinManager.NewSkin(const nName: string): TSkinItem;
var nIdx: Integer;
begin
  nIdx := FindItem(nName);
  if nIdx > -1 then
  begin
    Result := TSkinItem(FItems[nIdx]);
    Exit;
  end;

  Result := TSkinItem.Create(Self);
  FItems.Add(Result);
  Result.SkinID := nName;
end;

//Desc: ɾ��nNameƤ��
function TSkinManager.DelSkin(const nName: string): Boolean;
var nIdx: Integer;
begin
  nIdx := FindItem(nName);
  Result := nIdx < 0;

  if not Result then
  begin
    TSkinItem(FItems[nIdx]).Free;
    FItems.Delete(nIdx);
    Result := True;
  end;
end;

//Desc: ����nFileƤ���ļ�
function TSkinManager.LoadSkin(const nFile: string): Boolean;
var nIdx: Integer;
    nNode: TXmlNode;
    nItem: TSkinItem;
begin
  Result := FileExists(nFile);
  if not Result then Exit;

  if not Assigned(FReader) then
    FReader := TNativeXml.Create;
  //xxxxx
  
  FReader.LoadFromFile(nFile);
  FFileName := nFile;
  ClearList(False);

  for nIdx:=0 to FReader.Root.NodeCount-1 do
  try
    nNode := FReader.Root.Nodes[nIdx];
    if CompareText(nNode.Name, 'skin') = 0 then
    begin
      nItem := NewSkin(nNode.Name);
      nItem.LoadItem(nNode);
    end;
  except
    //ignor any error
  end;

  Result := FItems.Count > 0;
  FreeAndNil(FReader);
end;

//Desc: ����Ƥ����nFile��
function TSkinManager.SaveSkin(const nFile: string): Boolean;
var nIdx: Integer;
    nItem: TSkinItem;
begin
  if not Assigned(FReader) then
    FReader := TNativeXml.Create;
  //xxxxx

  with FReader do
  begin
    XmlFormat := xfReadable;
    EncodingString := 'gb2312';
    VersionString := '1.0';
    Root.Name := 'skinlist';

    for nIdx:=0 to FItems.Count - 1 do
    begin
      nItem := TSkinItem(FItems[nIdx]);
      nItem.SaveItem(Root.NodeNew('skin'));
    end;
  end;

  FReader.SaveToFile(nFile);
  FreeAndNil(FReader);
  FFileName := nFile;
  Result := True;
end;

//Desc: �����������ļ�ָ����Ĭ��Ƥ��
function TSkinManager.LoadDefaultSkinFile(const nDir: string): Boolean;
var nStr: string;
    nIni: TIniFile;
begin
  nIni := TIniFile.Create(nDir + sSkinConfig);
  try
    nStr := nIni.ReadString('Skin', 'Active', '');
    nStr := StringReplace(nStr, '$Path', nDir, [rfIgnoreCase]);
    nStr := StringReplace(nStr, '\\', '\', [rfReplaceAll]);
    Result := LoadSkin(nStr);
  finally
    nIni.Free;
  end;
end;

initialization

finalization
  FreeAndNil(gSkinManager);
end.
