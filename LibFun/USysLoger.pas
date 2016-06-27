{*******************************************************************************
  ����: dmzn@163.com 2012-2-13
  ����: ���ڼ�¼ϵͳ�����еĵ�����־

  ��ע:
  *.��־���ļ���ʽ�����ڱ���.
  *.��־�ļ�����������.
  *.��־������֧��д�ļ��ͽ������,�̰߳�ȫ.
*******************************************************************************}
unit USysLoger;

interface

uses
  Windows, SysUtils, Classes, SyncObjs, UMgrSync, UMgrLog, ULibFun, UWaitItem;

type
  TSysLogEvent = procedure (const nStr: string) of object;
  //��־�¼�

  PSysLogReceiver = ^TSysLogReceiver;
  TSysLogReceiver = record
    FID: Integer;
    FEvent: TSysLogEvent;
  end;

  TSysLoger = class(TObject)
  private
    FPath: string;
    //��־·��
    FSyncLog: Boolean;
    //�Ƿ�ͬ��
    FSyner: TDataSynchronizer;
    //ͬ������
    FLoger: TLogManager;
    //��־����
    FSyncSection: TCriticalSection;
    FSyncLock: TCrossProcWaitObject;
    //ͬ������
    FReceiverIDBase: Integer;
    FReceivers: TList;
    //�¼�������
    FSyncEvent: TSysLogEvent;
    FAsyncEvent: TWriteLogEvent;
    FAsyncProc: TWriteLogProcedure;
    //�¼����
  protected
    procedure ClearReceivers(const nFree: Boolean);
    //������Դ
    procedure OnLog(const nThread: TLogThread; const nLogs: TList);
    procedure OnSync(const nData: Pointer; const nSize: Cardinal);
    procedure OnFree(const nData: Pointer; const nSize: Cardinal);
  public
    constructor Create(const nPath: string; const nSyncLock: string = '');
    destructor Destroy; override;
    //�����ͷ�
    procedure AddLog(const nEvent: string;
     const nType: TLogType = ltNull); overload;
    procedure AddLog(const nObj: TObjectClass; const nDesc,nEvent: string;
     const nType: TLogType = ltNull); overload;
    procedure AddLog(const nLogItem: PLogItem); overload;
    //�����־
    function HasItem: Boolean;
    //��δд��
    function AddReceiver(const nEvent: TSysLogEvent): Integer;
    procedure DelReceiver(const nReceiverID: Integer);
    //��־������
    property LogSync: Boolean read FSyncLog write FSyncLog;
    property LogEvent: TSysLogEvent read FSyncEvent write FSyncEvent;
    property AsyncEvent: TWriteLogEvent read FAsyncEvent write FAsyncEvent;
    property AsyncProc: TWriteLogProcedure read FAsyncProc write FAsyncProc;
    //�������
  end;

var
  gSysLoger: TSysLoger = nil;
  //ȫ��ʹ��

implementation

resourcestring
  sFileExt   = '.log';
  sLogField  = #9;

//------------------------------------------------------------------------------
constructor TSysLoger.Create(const nPath,nSyncLock: string);
begin
  FSyncLock := TCrossProcWaitObject.Create(PChar(nSyncLock));
  //for thread or process sync
  
  FReceiverIDBase := 0;
  FReceivers := TList.Create;
  FSyncSection := TCriticalSection.Create;

  FLoger := TLogManager.Create;
  FLoger.WriteEvent := OnLog;
  FSyncLog := False;

  FSyner := TDataSynchronizer.Create;
  FSyner.SyncEvent := OnSync;
  FSyner.SyncFreeEvent := OnFree;

  if not DirectoryExists(nPath) then
    ForceDirectories(nPath);
  FPath := nPath;
end;

destructor TSysLoger.Destroy;
begin
  ClearReceivers(True);
  FLoger.Free;
  FSyner.Free;

  FSyncSection.Free;
  FSyncLock.Free;
  inherited;
end;

procedure TSysLoger.ClearReceivers(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FReceivers.Count - 1 downto 0 do
  begin
    Dispose(PSysLogReceiver(FReceivers[nIdx]));
    FReceivers.Delete(nIdx);
  end;

  if nFree then
    FReceivers.Free;
  //xxxxx
end;

//------------------------------------------------------------------------------
function TSysLoger.HasItem: Boolean;
begin
  Result := FLoger.HasItem;
end;

procedure TSysLoger.AddLog(const nLogItem: PLogItem);
begin
  FLoger.AddNewLog(nLogItem);
end;

//Desc: Ĭ����־
procedure TSysLoger.AddLog(const nEvent: string; const nType: TLogType);
begin
  AddLog(TSysLoger, 'Ĭ����־����', nEvent, nType);
end;

//Desc: ���һ��nObj��nEvent�¼�
procedure TSysLoger.AddLog(const nObj: TObjectClass; const nDesc, nEvent: string;
 const nType: TLogType);
var nItem: PLogItem;
begin
  New(nItem);

  with nItem^ do
  begin
    FWriter.FOjbect := nObj;
    FWriter.FDesc := nDesc;

    FType := nType;
    FLogTag := [ltWriteFile];
    FTime := Now();
    FEvent := nEvent;
  end;

  FLoger.AddNewLog(nItem);
end;

//Date: 2012-2-13
//Parm: ��־�߳�;��־�б�
//Desc: ��nThread.nLogsд����־�ļ�
procedure TSysLoger.OnLog(const nThread: TLogThread; const nLogs: TList);
var nStr: string;
    nBuf: PChar;
    nFile: TextFile;
    nItem: PLogItem;
    i,nCount,nLen,nNum: integer;
begin
  FSyncLock.SyncLockEnter(True);
  try
    nStr := FPath + Date2Str(Now) + sFileExt;
    AssignFile(nFile, nStr);
  
    if FileExists(nStr) then
         Append(nFile)
    else Rewrite(nFile);

    nNum := 0;
    nCount := nLogs.Count - 1;

    for i:=0 to nCount do
    begin
      //if nThread.Terminated then Exit;
      nItem := nLogs[i];

      nStr := Copy(nItem.FWriter.FOjbect.ClassName, 1, 15);
      nStr := DateTime2Str(nItem.FTime) + ' ' +
              TLogManager.Type2Str(nItem.FType, False) + sLogField +
              nStr + sLogField;
      //ʱ��,����

      if nItem.FWriter.FDesc <> '' then
        nStr := nStr + nItem.FWriter.FDesc + sLogField;      //����
      nStr := nStr + nItem.FEvent;                           //�¼�
      WriteLn(nFile, nStr);

      if FSyncLog then
      begin
        nLen := Length(nStr) + 1;
        nBuf := GetMemory(nLen);

        StrPCopy(nBuf, nStr + #0);
        FSyner.AddData(nBuf, nLen);
        Inc(nNum);
      end;
    end;

    if nNum > 0 then
      FSyner.ApplySync;
    //xxxxx
  finally  
    CloseFile(nFile);
    FSyncLock.SyncLockLeave(True);
  end;

  if Assigned(FAsyncEvent) then
    FAsyncEvent(nThread, nLogs);
  //xxxxx

  if Assigned(FAsyncProc) then
    FAsyncProc(nThread, nLogs);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2013-12-07
//Parm: �����¼�
//Desc: ���nEvent�����¼�
function TSysLoger.AddReceiver(const nEvent: TSysLogEvent): Integer;
var nItem: PSysLogReceiver;
begin
  FSyncSection.Enter;
  try
    New(nItem);
    FReceivers.Add(nItem);

    Inc(FReceiverIDBase);
    Result := FReceiverIDBase;
    
    nItem.FID := FReceiverIDBase;
    nItem.FEvent := nEvent;
  finally
    FSyncSection.Leave;
  end;
end;

//Date: 2013-12-07
//Parm: ��ʶ
//Desc: �Ƴ�nReceiverID�����¼�
procedure TSysLoger.DelReceiver(const nReceiverID: Integer);
var nIdx: Integer;
    nItem: PSysLogReceiver;
begin
  FSyncSection.Enter;
  try
    for nIdx:=FReceivers.Count - 1 downto 0 do
    begin
      nItem := FReceivers[nIdx];
      if nItem.FID <> nReceiverID then continue;

      Dispose(nItem);
      FReceivers.Delete(nIdx);
    end;
  finally
    FSyncSection.Leave;
  end;
end;

procedure TSysLoger.OnSync(const nData: Pointer; const nSize: Cardinal);
var nIdx: Integer;
begin
  if Assigned(FSyncEvent) then
    FSyncEvent(PChar(nData));
  //xxxxx

  FSyncSection.Enter;
  try
    for nIdx:=FReceivers.Count - 1 downto 0 do
      PSysLogReceiver(FReceivers[nIdx]).FEvent(PChar(nData));
    //xxxxx
  finally
    FSyncSection.Leave;
  end;
end;

procedure TSysLoger.OnFree(const nData: Pointer; const nSize: Cardinal);
begin
  FreeMem(nData, nSize);
end;

initialization
  gSysLoger := nil;
finalization
  FreeAndNil(gSysLoger);
end.
