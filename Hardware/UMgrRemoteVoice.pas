{*******************************************************************************
  ����: dmzn@163.com 2012-4-21
  ����: Զ�������ϳɷ���
*******************************************************************************}
unit UMgrRemoteVoice;

{$I Link.Inc}
interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, IdComponent, IdTCPConnection,
  IdTCPClient, IdUDPServer, IdGlobal, IdSocketHandle, USysLoger, UWaitItem,
  ULibFun, UBase64;

type
  PVCDataBase = ^TVCDataBase;
  TVCDataBase = record
    FCommand   : Byte;     //������
    FDataLen   : Word;     //���ݳ�
  end;

  PVCPlaySound = ^TVCPlaySound;
  TVCPlaySound = record
    FBase      : TVCDataBase;
    FContent   : string;
  end;

const
  cVCCmd_PlaySound  = $17;  //��������
  cSizeVCBase       = SizeOf(TVCDataBase);
  
type
  TVoiceItem = record
    FID        : string;
    FName      : string;
    FHost      : string;
    FPort      : Integer;
    FEnable    : Boolean;
  end;

  TVoiceItems = array of TVoiceItem;
  //array of item

  TVoiceHelper = class;
  TVoiceConnector = class(TThread)
  private
    FOwner: TVoiceHelper;
    //ӵ����
    FBuffer: TList;
    //���ͻ���
    FWaiter: TWaitObject;
    //�ȴ�����
    FClient: TIdTCPClient;
    //�������
  protected
    procedure DoExuecte(const nHost: TVoiceItem);
    procedure Execute; override;
    //ִ���߳�
  public
    constructor Create(AOwner: TVoiceHelper);
    destructor Destroy; override;
    //�����ͷ�
    procedure WakupMe;
    //�����߳�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TVoiceHelper = class(TObject)
  private
    FHosts: TVoiceItems;
    FVoicer: TVoiceConnector;
    //��������
    FBuffData: TList;
    //��ʱ����
    FSyncLock: TCriticalSection;
    //ͬ����
  protected
    procedure ClearBuffer(const nList: TList);
    //������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��ȡ����
    procedure StartVoice;
    procedure StopVoice;
    //��ͣ��ȡ
    procedure PlayVoice(const nContent: string);
    //��������
  end;

var
  gVoiceHelper: TVoiceHelper = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TVoiceHelper, '�ϳ���������', nEvent);
end;

constructor TVoiceHelper.Create;
begin
  FBuffData := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TVoiceHelper.Destroy;
begin
  StopVoice;
  ClearBuffer(FBuffData);
  FBuffData.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TVoiceHelper.ClearBuffer(const nList: TList);
var nIdx: Integer;
    nBase: PVCDataBase;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    nBase := nList[nIdx];

    case nBase.FCommand of
     cVCCmd_PlaySound : Dispose(PVCPlaySound(nBase));
    end;

    nList.Delete(nIdx);
  end;
end;

procedure TVoiceHelper.StartVoice;
begin
  if not Assigned(FVoicer) then
    FVoicer := TVoiceConnector.Create(Self);
  FVoicer.WakupMe;
end;

procedure TVoiceHelper.StopVoice;
begin
  if Assigned(FVoicer) then
    FVoicer.StopMe;
  FVoicer := nil;
end;

//Desc: ����nContent����
procedure TVoiceHelper.PlayVoice(const nContent: string);
var nPtr: PVCPlaySound;
begin
  FSyncLock.Enter;
  try
    ClearBuffer(FBuffData);
    //clear

    New(nPtr);
    FBuffData.Add(nPtr);

    nPtr.FBase.FCommand := cVCCmd_PlaySound;
    nPtr.FContent := nContent;

    if Assigned(FVoicer) then
      FVoicer.WakupMe;
    //xxxxx
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: ����nFile�����ļ�
procedure TVoiceHelper.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode: TXmlNode;
    nIdx,nNum: Integer;
begin
  SetLength(FHosts, 0);
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    //load config

    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nNode := nXML.Root.Nodes[nIdx];
      if CompareText(nNode.Name, 'item') <> 0 then Continue;
      //not valid item

      nNum := Length(FHosts);
      SetLength(FHosts, nNum + 1);

      with FHosts[nNum] do
      begin
        FID    := nNode.NodeByName('id').ValueAsString;
        FName  := nNode.NodeByName('name').ValueAsString;
        FHost  := nNode.NodeByName('ip').ValueAsString;
        FPort  := nNode.NodeByName('port').ValueAsInteger;
        FEnable := nNode.NodeByName('enable').ValueAsInteger = 1;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TVoiceConnector.Create(AOwner: TVoiceHelper);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;
  
  FBuffer := TList.Create;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2000;

  FClient := TIdTCPClient.Create;
  FClient.ReadTimeout := 5 * 1000;
  FClient.ConnectTimeout := 5 * 1000;
end;

destructor TVoiceConnector.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;

  FOwner.ClearBuffer(FBuffer);
  FBuffer.Free;

  FWaiter.Free;
  inherited;
end;

procedure TVoiceConnector.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TVoiceConnector.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TVoiceConnector.Execute;
var nIdx: Integer;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FOwner.FSyncLock.Enter;
    try
      for nIdx:=0 to FOwner.FBuffData.Count - 1 do
        FBuffer.Add(FOwner.FBuffData[nIdx]);
      FOwner.FBuffData.Clear;
    finally
      FOwner.FSyncLock.Leave;
    end;

    if FBuffer.Count > 0 then
    try
      for nIdx:=Low(FOwner.FHosts) to High(FOwner.FHosts) do
       if FOwner.FHosts[nIdx].FEnable then
        DoExuecte(FOwner.FHosts[nIdx]);
      //send voice command
    finally
      FOwner.ClearBuffer(FBuffer);
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

procedure TVoiceConnector.DoExuecte(const nHost: TVoiceItem);
var nIdx: Integer;
    nBuf,nTmp: TIdBytes;
    nPBase: PVCDataBase;
begin
  try
    if FClient.Connected and ((FClient.Host <> nHost.FHost) or (
       FClient.Port <> nHost.FPort)) then
    begin
      FClient.Disconnect;
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      //try to swtich connection
    end;

    if not FClient.Connected then
    begin
      FClient.Host := nHost.FHost;
      FClient.Port := nHost.FPort;
      FClient.Connect;
    end;

    for nIdx:=FBuffer.Count - 1 downto 0 do
    begin
      nPBase := FBuffer[nIdx];

      if nPBase.FCommand = cVCCmd_PlaySound then
      begin
        SetLength(nTmp, 0);
        nTmp := ToBytes(EncodeBase64(PVCPlaySound(nPBase).FContent));
        nPBase.FDataLen := Length(nTmp);

        nBuf := RawToBytes(nPBase^, cSizeVCBase);
        AppendBytes(nBuf, nTmp);
        FClient.Socket.Write(nBuf);
      end;
    end;
  except
    WriteLog(Format('������[ %s ]������������ʧ��.', [nHost.FHost]));
    //loged

    FClient.Disconnect;
    if Assigned(FClient.IOHandler) then
      FClient.IOHandler.InputBuffer.Clear;
    //close connection
  end;
end;

initialization
  gVoiceHelper := TVoiceHelper.Create;
finalization
  FreeAndNil(gVoiceHelper);
end.
