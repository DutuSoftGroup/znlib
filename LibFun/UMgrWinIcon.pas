{*******************************************************************************
  ����: dmzn 2008-9-5
  ����: ά��һ�����ϵͳͼ��

  ��ע:
  &.������ά���˴�С����ͼ���б�,����Ϊ�������ṩͼ�����.
  &.ʹ��GetIcon���Ի�ȡָ���ļ�����չ����ͼ������,��������Ӧͼ���б��е�һ��
    ͼ��.
*******************************************************************************}
unit UMgrWinIcon;

interface

uses
  Windows, Classes, Controls, SysUtils, ShellApi;

type
  PWinIconItemData = ^TWinIconItemData;
  TWinIconItemData = record
    FItemExt: string;             //��չ��
    FLargeIndex: integer;
    FSmallIndex: integer;         //ͼ������
  end;

  TWinIconManager = class(TObject)
  private
    FIconBuffer: TList;
    {*��������*}
    FSmallList: TImageList;
    FLargeList: TImageList;
    {*ͼ���б�*}
    FInited: Boolean;
    {*��ʼ�����*}
  protected
    procedure ClearIconBuffer;
    {*��������*}
    procedure InitSystemImageList;
    {*��ʼ���б�*}
    function IndexInBuffer(const nExt: string): integer;
    {*��������*}
    function IconOfFile(const nFile: string; const nLarge: Boolean): integer;
    {*ͼ������*}
  public
    constructor Create;
    destructor Destroy; override;
    {*�����ͷ�*}
    function GetIcon(const nFileOrExt: string; const nLarge: Boolean): integer;
    {*����ͼ��*}
    property SmallImage: TImageList read FSmallList;
    property LargeImage: TImageList read FLargeList;
  end;

var
  gWinIconManager: TWinIconManager = nil;
  //ȫ��ͼ�������

implementation

constructor TWinIconManager.Create;
begin
  FInited := False;
  FIconBuffer := TList.Create;
  
  FSmallList := TImageList.Create(nil);
  FLargeList := TImageList.Create(nil);
end;

destructor TWinIconManager.Destroy;
begin
  ClearIconBuffer;
  FIconBuffer.Free;

  FSmallList.Free;
  FLargeList.Free;
  inherited;
end;

//Desc: ��������
procedure TWinIconManager.ClearIconBuffer;
var nIdx: integer;
begin
  for nIdx:=FIconBuffer.Count - 1 downto 0 do
  begin
    Dispose(PWinIconItemData(FIconBuffer[nIdx]));
    FIconBuffer.Delete(nIdx);
  end;
end;

//Desc: ��ʼ��ͼ���б�,����ϵͳͼ���б�
procedure TWinIconManager.InitSystemImageList;
var nFlag: integer;
    nHwnd: THandle;
    nInfo: TSHFileInfo;
begin
  nFlag := SHGFI_SYSICONINDEX or SHGFI_TYPENAME or SHGFI_USEFILEATTRIBUTES;
  nHwnd := SHGetFileInfo('', 0, nInfo, SizeOf(nInfo), nFlag or SHGFI_SMALLICON);

  if nHwnd <> 0 then
  begin
    FInited := True;
    FSmallList.Handle := nHwnd;       //ָ��ϵͳͼ����
    FSmallList.ShareImages := True;   //��ֹ�ͷ�ͼ����
  end else FInited := False;

  nHwnd := SHGetFileInfo('', 0, nInfo, SizeOf(nInfo), nFlag or SHGFI_LARGEICON);
  if nHwnd <> 0 then
  begin
    FInited := True;
    FLargeList.Handle := nHwnd;       //ָ��ϵͳͼ����
    FLargeList.ShareImages := True;   //��ֹ�ͷ�ͼ����
  end else FInited := False;
end;

//Desc: ��ȡnFile��Ӧ��ϵͳͼ������
function TWinIconManager.IconOfFile(const nFile: string;
  const nLarge: Boolean): integer;
var nFlag: Integer;
    nInfo: TSHFileInfo;
begin
  nFlag := SHGFI_SYSICONINDEX or SHGFI_TYPENAME or SHGFI_USEFILEATTRIBUTES;
  if nLarge then
       nFlag := nFlag or SHGFI_LARGEICON
  else nFlag := nFlag or SHGFI_SMALLICON;

  SHGetFileInfo(PChar(nFile), 0, nInfo, SizeOf(nInfo), nFlag);
  Result := nInfo.iIcon;
end;

//Desc: �ڻ������м���nExt��ͼ������
function TWinIconManager.IndexInBuffer(const nExt: string): integer;
var i,nCount: integer;
begin
  Result := -1;
  nCount := FIconBuffer.Count - 1;

  for i:=0 to nCount do
  if PWinIconItemData(FIconBuffer[i]).FItemExt = nExt then
  begin
    Result := i; Break;
  end;
end;

//Desc: ��ȡnFileOrExt��Ӧ��ϵͳͼ������
function TWinIconManager.GetIcon(const nFileOrExt: string;
  const nLarge: Boolean): integer;
var nExt: string;
    nIdx: integer;
    nItem: PWinIconItemData;
begin
  if not FInited then InitSystemImageList;
  nExt := LowerCase(ExtractFileExt(nFileOrExt));
  nIdx := IndexInBuffer(nExt);

  if nIdx < 0 then
  begin
    New(nItem);
    FIconBuffer.Add(nItem);

    nItem.FLargeIndex := -1;
    nItem.FSmallIndex := -1;
    Result := IconOfFile(nFileOrExt, nLarge);

    nItem.FItemExt := nExt;
    if nLarge then
         nItem.FLargeIndex := Result
    else nItem.FSmallIndex := Result;
  end else
  begin
    nItem := FIconBuffer[nIdx];
    if nLarge then
         Result := nItem.FLargeIndex
    else Result := nItem.FSmallIndex;

    if Result < 0 then
    begin
      Result := IconOfFile(nFileOrExt, nLarge);
      if nLarge then
           nItem.FLargeIndex := Result
      else nItem.FSmallIndex := Result;
    end;
  end;
end;

initialization
  gWinIconManager := TWinIconManager.Create;
finalization
  FreeAndNil(gWinIconManager);
end.
