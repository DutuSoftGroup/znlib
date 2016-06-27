{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-12-7
  ����: ����Ϣ����ʵ���߳�����������ͬ��

  ��ע:
  &.ͬ����ԭ��ܼ�,ͬ������ά��һ����Ϣ����,���߳�����д�뻺���,��ϵͳ����
    ��Ϣ���������ݴ������.����Ϣ����������ά����,��ͽ������л���������.
  &.Ϊ���ǳ��������,����������Ҫ���ⲿ�������,Ȼ�����AddData��ӵ�ͬ������
    ��,������ApplySync��������ͬ��.
  &.�����������ⲿ����,������Ҫ�ͷ����ⲿʵ��,����ΪSyncFreeEvent��
    SyncFreeProcedure��һ��ֵ.
*******************************************************************************}
unit UMgrSync;

interface

uses
  Windows, Classes, SysUtils, Messages;

type
  PSyncItemData = ^TSyncItemData;
  TSyncItemData = record
    FData: Pointer;              //ͬ������
    FSize: Cardinal;             //���ݴ�С
  end;
  
  TCustomDataSynchronizer = class(TObject)
  private
    FBuffer: TThreadList;
    {*������*}
    FDataList: TList;
    {*�����б�*}
    FHandle: THandle;
    {*���ھ��*}
    FMaxRecord: Integer;
    {*����¼*}
  protected
    procedure WndProc(var nMsg: TMessage);
    {*��Ϣ��*}
    procedure ClearBufferList; overload;
    procedure ClearDataList(const nList: TList); overload;
    {*������Դ*}
    procedure DoSync(const nData: Pointer; const nSize: Cardinal); virtual; abstract;
    procedure DoDataFree(const nData: Pointer; const nSize: Cardinal); virtual; abstract;
    {*���󷽷�*}
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    {*�����ͷ�*}
    procedure AddData(const nData: Pointer; const nSize: Cardinal);
    {*�������*}
    procedure ApplySync;
    {*����ͬ��*}
    property MaxRecord: Integer read FMaxRecord write FMaxRecord;
    {*�������*}
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
    {*���ݴ������*}
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
  //ȫ��ʹ���߳�ͬ������

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

//Desc: �ͷŻ���
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

//Desc: �ͷ�nList����
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

//Desc: ������Ϣ����
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

//Desc: �������
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
    //��������¼���򶪵�

    New(nItem);
    nList.Add(nItem);

    nItem.FData := nData;
    nItem.FSize := nSize;
  finally
    FBuffer.UnlockList;
  end;
end;

//Desc: ����ͬ��
procedure TCustomDataSynchronizer.ApplySync;
begin
  PostMessage(FHandle, WM_NewData, 0, WM_LParam);
end;

//------------------------------------------------------------------------------
//Desc: �����̴���ͬ���������
procedure TDataSynchronizer.DoSync(const nData: Pointer; const nSize: Cardinal);
begin
  if Assigned(FEvent) then FEvent(nData, nSize);
  if Assigned(FProcedure) then FProcedure(nData, nSize);
end;

//Desc: �ͷ�����
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
