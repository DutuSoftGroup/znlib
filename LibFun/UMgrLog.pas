{*******************************************************************************
  ����: dmzn@163.com 2007-11-02
  ����: ʵ�ֶ���־�Ļ���͹���

  ��ע:
  &.����Ԫʵ����һ����־������LogManager.
  &.������ά��һ��Buffer�б�,�ڲ������־��LogItem.
  &.ʹ��LogManager.AddNewLog�����־��ʱ,�ᴥ��OnNewLog�¼�,���¼�������ͨ��
  ����.��־����ָ�뷽ʽ����,�����¼��п����޸�LogItem.FAction,�Ծ����Ƿ�Ҫ��
  ������.��FAction=[],�򲻻�ַ���"д��־�߳�".
  &."д��־�߳�"��֪����ô������־,����������һ���¼����ⲿ,����OnWriteLog,��
  ����־���б�,�ⲿ����ʵ������������־��δ���.��ʹ��������,��������¼���,��
  ־��Ҳ�ᱻ�ͷŵ�.
  &.ע��: OnWriteLog���̰߳�ȫ,��Ҫʱ��Ҫ�߳�ͬ��.���Ҳ�Ҫ�ֹ�ɾ����־��,����
  ֪����ô�ͷ�.
*******************************************************************************}
unit UMgrLog;

interface

uses
  Windows, Classes, SysUtils, UWaitItem;

type
  TObjectClass = class of TObject;
  TLogTag = set of (ltWriteFile, ltWriteDB, ltWriteCMD);
  //��־���
  TLogType = (ltNull, ltInfo, ltWarn, ltError);
  //��־����:��,��Ϣ,����,����

  TLogWriter = record
    FOjbect: TObjectClass;         //�������
    FDesc: string;                 //������Ϣ
  end;

  PLogItem = ^TLogItem;
  TLogItem = record
    FWriter: TLogWriter;           //��־����
    FLogTag: TLogTag;              //��־���
    FType: TLogType;               //��־����
    FTime: TDateTime;              //��־ʱ��
    FEvent: string;                //��־����
  end;

  //****************************************************************************
  TLogManager = class;

  TLogThread = class(TThread)
  private
    FWaiter: TWaitObject;
    {*�ӳٶ���*}
    FOwner: TLogManager;
    {*ӵ����*}
    FBufferList: TList;
    {*������*}
  protected
    procedure Execute; override;
    {*ִ��*}
    procedure WriteErrorLog(const nList: TList);
    {*д�����*}
  public
    constructor Create(AOwner: TLogManager);
    destructor Destroy; override;
    {*�����ͷ�*}
    procedure Wakeup;
    {*�̻߳���*}
    property Terminated;
    {*�������*}
  end;

  TLogEvent = procedure (const nLogs: PLogItem) of Object;
  TWriteLogProcedure = procedure (const nThread: TLogThread; const nLogs: TList);
  TWriteLogEvent = procedure (const nThread: TLogThread; const nLogs: TList) of Object;
  //��־�¼�,�ص�����
  
  TLogManager = class(TObject)
  private
    FBuffer: TThreadList;
    {*������*}
    FWriter: TLogThread;
    {*д��־�߳�*}
    FOnNewLog: TLogEvent;
    FEvent: TWriteLogEvent;
    FProcedure: TWriteLogProcedure;
    {*�¼�*}
  public
    constructor Create;
    destructor Destroy; override;
    {*�����ͷ�*}
    function NewLogItem: PLogItem;
    {*������Դ*}
    procedure AddNewLog(const nItem: PLogItem);
    {*����־*}
    function HasItem: Boolean;
    {*��δд��*}
    class function Type2Str(nType: TLogType; nLong: Boolean = True): string;
    class function Str2Type(const nStr: string; nLong: Boolean = True): TLogType;
    {*��־����*}
    property OnNewLog: TLogEvent read FOnNewLog write FOnNewLog;
    property WriteEvent: TWriteLogEvent read FEvent write FEvent;
    property WriteProcedure: TWriteLogProcedure read FProcedure write FProcedure;
    {*�����¼�*}
  end;

var
  gLogManager: TLogManager = nil;
  //ȫ��ʹ��,���ֹ�����

implementation

//Date: 2007-11-02
//Parm: ��־�б�
//Desc: �ͷ�nList��־�б�
procedure FreeLogList(const nList: TList); overload;
var i,nCount: integer;
begin
  nCount := nList.Count - 1;
  for i:=0 to nCount do
    Dispose(PLogItem(nList[i]));
  nList.Clear;
end;

//Date: 2007-11-02
//Parm: ��־�б�
//Desc: �ͷ�nList��־�б�
procedure FreeLogList(const nList: TThreadList); overload;
var nTmp: TList;
begin
  nTmp := nList.LockList;
  try
    FreeLogList(nTmp);
  finally
    nList.UnlockList;
  end;
end;

//******************************************************************************
constructor TLogThread.Create(AOwner: TLogManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FBufferList := TList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 500;
end;

destructor TLogThread.Destroy;
begin
  FreeLogList(FBufferList);
  FreeAndNil(FBufferList);

  FWaiter.Free; 
  inherited;
end;

//Desc: ����
procedure TLogThread.Wakeup;
begin
  FWaiter.WakeUP;
end;

//Desc: д��־�߳�
procedure TLogThread.Execute;
var nInt: Integer;
begin
  nInt := 0;
  //init status

  while True do
  try
    if Terminated then
    begin
      if not FOwner.HasItem then Break;
      //try save all when thread terminated
    end else
    begin
      FWaiter.EnterWait;
      if (not FOwner.HasItem) and Terminated then Break;
    end;

    if nInt > 1 then
    begin
      nInt := 0;
      FreeLogList(FBufferList);
    end;

    if FBufferList.Count > 0 then
    try
      if Assigned(FOwner.FEvent) then
         FOwner.FEvent(Self, FBufferList);
      if Assigned(FOwner.FProcedure) then
         FOwner.FProcedure(Self, FBufferList);
      //xxxxx

      nInt := 0;
      FreeLogList(FBufferList);
    except
      if nInt = 0 then
        WriteErrorLog(FBufferList);
      Inc(nInt);
    end;
  except
    Inc(nInt);
    //ignor any error
  end;
end;

//Date: 2007-11-25
//Parm: ��־�б�
//Desc: д��־����
procedure TLogThread.WriteErrorLog(const nList: TList);
var nItem: PLogItem;
begin
  nItem := FOwner.NewLogItem;
  nItem.FLogTag := [ltWriteFile];
  nItem.FType := ltError;
  
  nItem.FWriter.FOjbect := TLogThread;
  nItem.FWriter.FDesc := '��־�߳�';
  nItem.FEvent := Format('��%d����־д��ʧ��,�ٴγ���.', [nList.Count]);
  nList.Insert(0, nItem);
end;

//******************************************************************************
//Desc: ����
constructor TLogManager.Create;
begin
  FBuffer := TThreadList.Create;
  FWriter := TLogThread.Create(Self);
end;

//Desc: �ͷ�
destructor TLogManager.Destroy;
begin
  FWriter.Terminate;
  FWriter.Wakeup;
  FWriter.WaitFor;
  FreeAndNil(FWriter);

  FreeLogList(FBuffer);
  FBuffer.Free;
  inherited;
end;

//Desc: ����ת����
class function TLogManager.Type2Str(nType: TLogType; nLong: Boolean = True): string;
begin
  if nLong then
  begin
    case nType of
     ltInfo: Result := 'INFO';
     ltWarn: Result := 'WARN';
     ltError: Result := 'ERROR' else Result := '';
    end;
  end else
  begin
    case nType of
     ltInfo: Result := 'I';
     ltWarn: Result := 'W';
     ltError: Result := 'E' else Result := '';
    end;
  end;
end;

//Desc: ����ת����
class function TLogManager.Str2Type(const nStr: string; nLong: Boolean = True): TLogType;
var nL: string;
begin
  nL := UpperCase(Trim(nStr));
  //��ʽ��

  if nLong then
  begin
    if nL = 'INFO' then Result := ltInfo else
    if nL = 'WARN' then Result := ltWarn else
    if nL = 'ERROR' then Result := ltError else Result := ltNull;
  end else
  begin
    if nL = 'I' then Result := ltInfo else
    if nL = 'W' then Result := ltWarn else
    if nL = 'E' then Result := ltError else Result := ltNull;
  end;
end;

//Desc: �Ƿ���δд����־��
function TLogManager.HasItem: Boolean;
var nList: TList;
    nIdx,nCount: integer;
begin
  nList := FBuffer.LockList;
  try
    if FWriter.FBufferList.Count < 1 then
    begin
      nCount := nList.Count - 1;
      for nIdx:=0 to nCount do
        FWriter.FBufferList.Add(nList[nIdx]);
      nList.Clear;
    end;
  finally
    Result := FWriter.FBufferList.Count > 0;
    FBuffer.UnlockList;
  end;
end;

//Desc: �����־
procedure TLogManager.AddNewLog(const nItem: PLogItem);
var nList: TList;
begin
  if Assigned(FOnNewLog) then
    FOnNewLog(nItem);
  //��������,�����߳�д��

  if nItem.FLogTag = [] then
  begin
    Dispose(nItem); Exit;
  end;

  nList := FBuffer.LockList;
  try
    nList.Add(nItem);
  finally
    FBuffer.UnlockList;
    FWriter.Wakeup;
  end;
end;

//Desc: ����־��,���ֹ��ͷ�
function TLogManager.NewLogItem: PLogItem;
begin
  New(Result);
  Result.FLogTag := [];
  Result.FTime := Now();
end;

end.
