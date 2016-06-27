{*******************************************************************************
  作者: dmzn@163.com 2012-2-20
  描述: 系统共享内存,用于跨进程通讯

  备注:
  *.共享内存管理器使用相同MemName映射相同内存空间.
  *.为了同步读写,使用相同LockName同步锁定.
  *.LockData,UnLockData必须成对使用,否则死锁.
  *.同享内存分单元片,每片大小一样.可用索引访问,索引从1开始.
*******************************************************************************}
unit UMgrShareMem;

interface

uses
  Windows, Classes, SysUtils;

type
  TShareMemoryManager = class(TObject)
  private
    FMapFile: THandle;
    //映射文件
    FFilePtr: Pointer;
    //文件指针
    FMemName: string;
    //内存标识
    FMemNew: Boolean;
    //是否新建
    FCellNum: Cardinal;
    //单元个数
    FCellSize: Cardinal;
    //单元大小
    FCellIndex: Cardinal;
    //单元索引
    FSyncLock: THandle;
    //同步锁定
  protected
    procedure ClearAllHandle;
    //清理句柄
    function GetMemSize: Cardinal;
    //计算内存
    function GetMemValid: Boolean;
    //内存有效
    procedure MemoryLock(const nLock: Boolean; nHandle: THandle = 0);
    //同步锁定
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    function InitMem(const nMemName,nLockName: string; const nCellNum,
      nCellSize,nCellIndex: Cardinal; const nHost: Boolean = True): Boolean;
    //初始化
    function LockData(var nBuf: Pointer; nCellIndex: Cardinal = 0): Boolean;
    procedure UnLockData;
    //读写内存
    property MemNew: Boolean read FMemNew;
    property MemName: string read FMemName;
    property MemSize: Cardinal read GetMemSize;
    property MemValid: Boolean read GetMemValid;
    property CellNum: Cardinal read FCellNum;
    property CellSize: Cardinal read FCellSize;
    property CellIndex: Cardinal read FCellIndex write FCellIndex;
    //属性相关
  end;

var
  gShareMemoryManager: TShareMemoryManager = nil;
  //全局使用

implementation

constructor TShareMemoryManager.Create;
begin
  FMapFile := INVALID_HANDLE_VALUE;
  FFilePtr := nil;
  FSyncLock := INVALID_HANDLE_VALUE;
end;

destructor TShareMemoryManager.Destroy;
begin
  ClearAllHandle;
  inherited;
end;

//Desc: 清理系统句柄
procedure TShareMemoryManager.ClearAllHandle;
var nLock: THandle;
begin
  try
    if FSyncLock <> INVALID_HANDLE_VALUE then
      MemoryLock(True);
    //lock memory

    if Assigned(FFilePtr) then
    begin
      UnmapViewOfFile(FFilePtr);
      FFilePtr := nil;
    end; //unmap file

    if FMapFile <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(FMapFile);
      FMapFile := INVALID_HANDLE_VALUE;
    end; //close map file

    if FSyncLock <> INVALID_HANDLE_VALUE then
    begin
      nLock := FSyncLock;
      FSyncLock := INVALID_HANDLE_VALUE;

      MemoryLock(False, nLock);
      CloseHandle(nLock);
    end; //lock free
  finally
    if FSyncLock <> INVALID_HANDLE_VALUE then
      MemoryLock(False);
    //unlock memory
  end;
end;

//Date: 2012-2-22
//Desc: 计算共享内存大小
function TShareMemoryManager.GetMemSize: Cardinal;
begin
  if Assigned(FFilePtr) then
       Result := FCellNum * FCellSize
  else Result := 0;
end;

//Date: 2012-2-22
//Desc: 内存是否有效
function TShareMemoryManager.GetMemValid: Boolean;
begin
  Result := Assigned(FFilePtr);
end;

//Date: 2012-2-20
//Parm: 内存名称;同步锁名;单元数;单元大小;单元索引;是否宿主
//Desc: 创建nMemName的共享内存.宿主申请内存空间,非宿主映射空间地址
function TShareMemoryManager.InitMem(const nMemName,nLockName: string;
  const nCellNum,nCellSize,nCellIndex: Cardinal; const nHost: Boolean): Boolean;
begin
  Result := False;
  try
    ClearAllHandle;
    FSyncLock := CreateEvent(nil, False, True, PChar(nLockName));
    if FSyncLock = 0 then Exit;

    FMemName := nMemName;
    FCellNum := nCellNum;
    FCellSize := nCellSize;
    FCellIndex := nCellIndex;

    if nHost then
    begin
      FMapFile := CreateFileMapping(
                   $FFFFFFFF,                      //特殊内存映射句柄
                   nil,                            //安全属性
                   PAGE_READWRITE or SEC_COMMIT,   //操作模式
                   0,                              //内存大小(高位)
                   FCellNum * FCellSize,             //内存大小(低位)
                   PChar(FMemName));               //内存名称标识
      FMemNew := GetLastError <> ERROR_ALREADY_EXISTS;
    end else
    begin
      FMapFile := OpenFileMapping(
                   FILE_MAP_WRITE,                 //操作模式
                   True,                           //
                   PChar(FMemName));               //内存名称标识
      FMemNew := False;
    end;

    if FMapFile = 0 then Exit;
    FFilePtr := MapViewOfFile(
                 FMapFile,                         //内存映射句柄
                 FILE_MAP_WRITE,                   //操作模式
                 0, 0,                             //映射起始位置
                 FCellNum * FCellSize);            //映射内存大小
    //xxxxx

    if not Assigned(FFilePtr) then Exit;
    Result := True;
  finally
    if FSyncLock = 0 then
      FSyncLock := INVALID_HANDLE_VALUE;
    //lock invalid

    if FMapFile = 0 then
      FMapFile := INVALID_HANDLE_VALUE;
    //map invalid

    if (not Result) and (FMapFile <> INVALID_HANDLE_VALUE) then
    begin
      CloseHandle(FMapFile);
      FMapFile := INVALID_HANDLE_VALUE;
    end;
  end;
end;

//Desc: 锁定内存
procedure TShareMemoryManager.MemoryLock(const nLock: Boolean; nHandle: THandle);
begin
  if nHandle < 1 then
    nHandle := FSyncLock;
  //fix handle

  if (nHandle <> INVALID_HANDLE_VALUE) and (nHandle > 0) then
  begin
    if nLock then
         WaitForSingleObject(nHandle, INFINITE)
    else SetEvent(nHandle);
  end;
end;

//Date: 2012-2-20
//Parm: 接收指针;单元索引
//Desc: 返回索引为nCellIndex的单元起始位置指针
function TShareMemoryManager.LockData(var nBuf: Pointer;
  nCellIndex: Cardinal): Boolean;
begin
  nBuf := nil;
  MemoryLock(True);

  if nCellIndex < 1 then nCellIndex := FCellIndex;
  Result := Assigned(FFilePtr) and (nCellIndex > 0) and (nCellIndex <= FCellNum);

  if Result then
    nBuf := Pointer(Cardinal(FFilePtr) + FCellSize * (nCellIndex - 1));
  //fix buffer position
end;

//Desc: 释放内存锁
procedure TShareMemoryManager.UnLockData;
begin
  MemoryLock(False);
end;

initialization
  gShareMemoryManager := TShareMemoryManager.Create;
finalization
  FreeAndNil(gShareMemoryManager);
end.
