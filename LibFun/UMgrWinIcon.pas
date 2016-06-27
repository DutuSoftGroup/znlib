{*******************************************************************************
  作者: dmzn 2008-9-5
  描述: 维护一组操作系统图标

  备注:
  &.管理器维护了大小两个图标列表,可以为相关组件提供图标关联.
  &.使用GetIcon可以获取指定文件或扩展名的图标索引,该索引对应图标列表中的一个
    图标.
*******************************************************************************}
unit UMgrWinIcon;

interface

uses
  Windows, Classes, Controls, SysUtils, ShellApi;

type
  PWinIconItemData = ^TWinIconItemData;
  TWinIconItemData = record
    FItemExt: string;             //扩展名
    FLargeIndex: integer;
    FSmallIndex: integer;         //图标索引
  end;

  TWinIconManager = class(TObject)
  private
    FIconBuffer: TList;
    {*索引缓冲*}
    FSmallList: TImageList;
    FLargeList: TImageList;
    {*图标列表*}
    FInited: Boolean;
    {*初始化标记*}
  protected
    procedure ClearIconBuffer;
    {*清理数据*}
    procedure InitSystemImageList;
    {*初始化列表*}
    function IndexInBuffer(const nExt: string): integer;
    {*缓冲索引*}
    function IconOfFile(const nFile: string; const nLarge: Boolean): integer;
    {*图标索引*}
  public
    constructor Create;
    destructor Destroy; override;
    {*创建释放*}
    function GetIcon(const nFileOrExt: string; const nLarge: Boolean): integer;
    {*检索图标*}
    property SmallImage: TImageList read FSmallList;
    property LargeImage: TImageList read FLargeList;
  end;

var
  gWinIconManager: TWinIconManager = nil;
  //全局图标管理器

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

//Desc: 清理数据
procedure TWinIconManager.ClearIconBuffer;
var nIdx: integer;
begin
  for nIdx:=FIconBuffer.Count - 1 downto 0 do
  begin
    Dispose(PWinIconItemData(FIconBuffer[nIdx]));
    FIconBuffer.Delete(nIdx);
  end;
end;

//Desc: 初始化图标列表,关联系统图标列表
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
    FSmallList.Handle := nHwnd;       //指向系统图像句柄
    FSmallList.ShareImages := True;   //防止释放图标句柄
  end else FInited := False;

  nHwnd := SHGetFileInfo('', 0, nInfo, SizeOf(nInfo), nFlag or SHGFI_LARGEICON);
  if nHwnd <> 0 then
  begin
    FInited := True;
    FLargeList.Handle := nHwnd;       //指向系统图像句柄
    FLargeList.ShareImages := True;   //防止释放图标句柄
  end else FInited := False;
end;

//Desc: 获取nFile对应的系统图标索引
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

//Desc: 在缓冲区中检索nExt的图标索引
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

//Desc: 获取nFileOrExt对应的系统图标索引
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
