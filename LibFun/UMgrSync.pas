{*******************************************************************************
  作者: dmzn@ylsoft.com 2007-12-7
  描述: 以消息机制实现线程与界面组件的同步

  备注:
  &.同步的原理很简单,同步对象维护一个消息队列,当线程数据写入缓冲后,由系统调用
    消息来触发数据处理过程.而消息是由主进程维护的,这就将数据切回主进程了.
  &.为解决浅复制问题,所有数据需要在外部先申请好,然后调用AddData添加到同步队列
    中,最后调用ApplySync开启数据同步.
  &.由于数据在外部申请,所以需要释放在外部实现,必须为SyncFreeEvent或
    SyncFreeProcedure其一赋值.
*******************************************************************************}
unit UMgrSync;

interface

uses
  Windows, Classes, SysUtils, Messages;

type
  PSyncItemData = ^TSyncItemData;
  TSyncItemData = record
    FData: Pointer;              //同步数据
    FSize: Cardinal;             //数据大小
  end;
  
  TCustomDataSynchronizer = class(TObject)
  private
    FBuffer: TThreadList;
    {*缓冲区*}
    FDataList: TList;
    {*数据列表*}
    FHandle: THandle;
    {*窗口句柄*}
    FMaxRecord: Integer;
    {*最大记录*}
  protected
    procedure WndProc(var nMsg: TMessage);
    {*消息链*}
    procedure ClearBufferList; overload;
    procedure ClearDataList(const nList: TList); overload;
    {*清理资源*}
    procedure DoSync(const nData: Pointer; const nSize: Cardinal); virtual; abstract;
    procedure DoDataFree(const nData: Pointer; const nSize: Cardinal); virtual; abstract;
    {*抽象方法*}
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    {*创建释放*}
    procedure AddData(const nData: Pointer; const nSize: Cardinal);
    {*添加数据*}
    procedure ApplySync;
    {*开启同步*}
    property MaxRecord: Integer read FMaxRecord write FMaxRecord;
    {*属性相关*}
  end;

  TSyncProcedure = procedure (const nData: Pointer; const nSize: Cardinal);
  TSyncEvent = procedure (const nData: Pointer; const nSize: Cardinal) of object;
  TSyncFreeProcedure = procedure (const nData: Pointer; const nSize: Cardinal);
  TSyncFreeEvent = procedure (const nData: Pointer; const nSize: Cardinal) of Object;

  TDataSynchronizer = class(TCustomDataSynchronizer)
  private
    FEvent: TSyncEvent;
    FProcedure: TsyncProcedure;
    FFreeEvent: TSyncFreeEvent;
    FFreeProcedure: TSyncFreeProcedure;
    {*数据处理过程*}
  protected
    procedure DoSync(const nData: Pointer; const nSize: Cardinal); override;
    procedure DoDataFree(const nData: Pointer; const nSize: Cardinal); override;
  public
    property SyncEvent: TSyncEvent read FEvent write FEvent;
    property SyncProcedure: TsyncProcedure read FProcedure write FProcedure;
    property SyncFreeEvent: TSyncFreeEvent read FFreeEvent write FFreeEvent;
    property SyncFreeProcedure: TSyncFreeProcedure read FFreeProcedure write FFreeProcedure;
  end;

var
  gSynchronizer: TDataSynchronizer = nil;
  //全局使用线程同步对象

implementation

const
  cMaxRecord = 5000;
  WM_LParam  = $27;
  WM_NewData = WM_User + $22;

//------------------------------------------------------------------------------
constructor TCustomDataSynchronizer.Create;
begin
  inherited Create;
  FMaxRecord := cMaxRecord;

  FDataList := TList.Create;
  FBuffer := TThreadList.Create;
  FHandle := Classes.AllocateHWnd(WndProc);
end;

destructor TCustomDataSynchronizer.Destroy;
begin
  Classes.DeAllocateHwnd(FHandle);
  ClearBufferList;
  FBuffer.Free;

  ClearDataList(FDataList);
  FDataList.Free;
  inherited;
end;

//Desc: 释放缓冲
procedure TCustomDataSynchronizer.ClearBufferList;
var nList: TList;    
begin
  nList := FBuffer.LockList;
  try
    ClearDataList(nList);
  finally
    FBuffer.UnlockList;
  end;
end;

//Desc: 释放nList缓冲
procedure TCustomDataSynchronizer.ClearDataList(const nList: TList);
var nIdx: integer;
    nData: PSyncItemData;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    nData := nList[nIdx];
    DoDataFree(nData.FData, nData.FSize);

    Dispose(nData);
    nList.Delete(nIdx);
  end;
end;

//Desc: 处理消息队列
procedure TCustomDataSynchronizer.WndProc(var nMsg: TMessage);
var nList: TList;
    i,nCount: integer;
    nItem: PSyncItemData;
begin
  if (nMsg.Msg = WM_NewData) and (nMsg.LParam = WM_LParam) then
  begin
    nList := FBuffer.LockList;
    try
      nCount := nList.Count - 1;
      for i:=0 to nCount do
        FDataList.Add(nList[i]);
      nList.Clear;
    finally
      FBuffer.UnlockList;
    end;

    if FDataList.Count < 1 then Exit;
    nCount := FDataList.Count - 1;

    for i:=0 to nCount do
    try
      nItem := FDataList[i];
      DoSync(nItem.FData, nItem.FSize);
    except
      //ignor any error
    end;

    ClearDataList(FDataList);
    //xxxxx
  end;
end;

//Desc: 添加数据
procedure TCustomDataSynchronizer.AddData(const nData: Pointer;const nSize: Cardinal);
var nList: TList;
    nItem: PSyncItemData;
begin
  nList := FBuffer.LockList;
  try
    if (FMaxRecord > 0) and (nList.Count >= FMaxRecord) then
    begin
      DoDataFree(nData, nSize); Exit;
    end;
    //超过最大记录数则丢掉

    New(nItem);
    nList.Add(nItem);

    nItem.FData := nData;
    nItem.FSize := nSize;
  finally
    FBuffer.UnlockList;
  end;
end;

//Desc: 开启同步
procedure TCustomDataSynchronizer.ApplySync;
begin
  PostMessage(FHandle, WM_NewData, 0, WM_LParam);
end;

//------------------------------------------------------------------------------
//Desc: 主进程处理同步后的数据
procedure TDataSynchronizer.DoSync(const nData: Pointer; const nSize: Cardinal);
begin
  if Assigned(FEvent) then FEvent(nData, nSize);
  if Assigned(FProcedure) then FProcedure(nData, nSize);
end;

//Desc: 释放数据
procedure TDataSynchronizer.DoDataFree(const nData: Pointer; const nSize: Cardinal);
begin
  if Assigned(FFreeEvent) then
    FFreeEvent(nData, nSize) else

  if Assigned(FFreeProcedure) then
       FFreeProcedure(nData, nSize)
  else raise Exception.Create('Invalidate DataFree function!');
end;

initialization
  gSynchronizer := TDataSynchronizer.Create;
finalization
  FreeAndNil(gSynchronizer);
end.
