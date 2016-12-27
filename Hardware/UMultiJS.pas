{*******************************************************************************
  ����: dmzn@163.com 2010-11-22
  ����: �������������

  ��ע:
  *.����Ԫʵ����TCPģʽ��һ����װ�����ļ���������.
*******************************************************************************}
unit UMultiJS;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, UMgrSync, UWaitItem, ULibFun,
  USysLoger, IdGlobal, IdTCPConnection, IdTCPClient;

const   
  cMultiJS_Truck           = 8;         //���Ƴ���
  cMultiJS_DaiNum          = 5;         //��������
  cMultiJS_Delay           = 9;         //����ӳ�
  cMultiJS_Tunnel          = 10;        //������
  cMultiJS_FreshInterval   = 1200;      //ˢ��Ƶ��
  cMultiJS_SaveInterval    = 20 * 1000; //����Ƶ��

  cFrame_Control           = $05;       //����֡
  cFrame_Pasuse            = $06;       //��ͣ֡
  cFrame_Query             = $12;       //��ѯ֡
  cFrame_Clear             = $27;       //����֡

type
  TMultiJSManager = class;
  TMultJSItem = class;

  PMultiJSTunnel = ^TMultiJSTunnel;
  TMultiJSTunnel = record
    FID: string;
    FName: string;    
    //ͨ����ʶ
    FTunnel: Word;
    //�������
    FDelay: Word;
    //�ӳ�ʱ��
    FGroup: string;
    //ͨ������
    FReader: string;
    //��ͷ��ַ
    FTruck: array[0..cMultiJS_Truck - 1] of Char;
    //���ƺ�
    FDaiNum: Word;
    //��װ����
    FHasDone: Word;
    //��װ����
    FIsRun: Boolean;
    //���б��
    FLastBill: string;
    FLastSaveDai: Word;
    //�ϴα���
  end;

  PMultiJSHost= ^TMultiJSHost;
  TMultiJSHost = record
    FName: string;
    FHostIP: string;
    FHostPort: Integer;
    //������Ϣ
    F485Addr: Byte;
    //��·��ַ
    FTunnelNum: Byte;
    //��Ч����
    FTunnel: TList;
    //��������
    FReader: TMultJSItem;
    //�����߳�
  end;

  TMultiJSPeerSend = record
    FAddr: Byte;
    FDelay: Byte;
    FTruck: array[0..cMultiJS_Truck - 1] of Char;
    FDai: array[0..cMultiJS_DaiNum - 1] of Char;
  end;

  PMultiJSDataSend = ^TMultiJSDataSend;
  TMultiJSDataSend = record
    FHeader : array[0..1] of Byte;    //֡ͷ
    FAddr   : Byte;                   //485��ַ
    FType   : Byte;                   //����,��ѯ
    FData   : TMultiJSPeerSend;       //��Ч����
    FEnd    : Byte;                   //����֡
  end;

  TMultiJSPeerRecv = record
    FAddr: Byte;
    FDai: array[0..cMultiJS_DaiNum - 1] of Char;
  end;

  PMultiJSDataRecv = ^TMultiJSDataRecv;
  TMultiJSDataRecv = record
    FHeader : array[0..1] of Char;    //֡ͷ
    FAddr   : Byte;                   //485��ַ
    FType   : Byte;                   //����,��ѯ
    FData   : array[0..cMultiJS_Tunnel - 1] of TMultiJSPeerRecv;
    FEnd    : Byte;                   //����֡
  end;

  TMultJSItem = class(TThread)
  private
    FOwner: TMultiJSManager;
    //ӵ����
    FHost: PMultiJSHost;
    //������
    FClient: TIdTCPClient;
    //�ͻ���
    FTmpList: TList;
    FBuffer: TList;
    //���ͻ���
    FRecv: TMultiJSDataRecv;
    //���ջ���
    FNowTunnel: PMultiJSTunnel;
    //��ǰͨ��
    FWaiter: TWaitObject;
    //�ȴ�����
    FLastSave: Int64;
    //�ϴα���
  protected
    procedure Execute; override;
    //�߳���
    procedure ClearBuffer(const nList: TList; const nFree: Boolean = False);
    //��ջ���
    procedure DeleteFromBuffer(nAddr: Byte; nList: TList);
    //ɾ��ָ��
    procedure AddQueryFrame(const nList: TList);
    //��ѯָ��
    procedure SendDataFrame(const nData: PMultiJSDataSend);
    //��������
    procedure ApplyRespondData;
    //���´���
    function GetTunnel(const nTunnel: Byte): PMultiJSTunnel;
    //����ͨ��
    procedure SyncNowTunnel;
    //ͬ��ͨ��
  public
    constructor Create(AOwner: TMultiJSManager; nHost: PMultiJSHost);
    destructor Destroy; override;
    //�����ͷ�
    procedure Wakeup;
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TMultiJSEvent = procedure (const nTunnel: PMultiJSTunnel) of object;
  //�¼�
  TMultiJSProc = procedure (const nTunnel: PMultiJSTunnel);
  //����
  TMultiJSGetTruck = function (const nTruck,nBill: string): string;
  //��ȡ����

  TMultiJSManager = class(TObject)
  private
    FEnableQuery: Boolean;
    //������ѯ
    FEnableCount: Boolean;
    //��������
    FEnableChain: Boolean;
    //��������
    FHosts: TList;
    //�����б�
    FFileName: string;
    //�����ļ�
    FLogCtrlFrame: Boolean;
    //��¼����֡
    FSyncLock: TCriticalSection;
    //ͬ������
    FChangeThread: TMultiJSEvent;
    FChangeSync: TMultiJSEvent;
    FSaveDataProc: TMultiJSProc;
    FSaveDataEvent: TMultiJSEvent;
    FGetTruck: TMultiJSGetTruck;
    //�¼����
  protected
    procedure DisposeHost(const nHost: PMultiJSHost);
    procedure ClearHost(const nFree: Boolean);
    //��������
    function GetTunnel(const nID: string; var nHost: PMultiJSHost;
      var nTunnel: PMultiJSTunnel): Boolean;
    //����ͨ��
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadFile(const nFile: string);
    //��ȡ����
    procedure StartJS;
    procedure StopJS;
    //��ͣ����
    function AddJS(const nTunnel,nTruck,nBill:string; nDaiNum: Integer;
      const nDelJS: Boolean = False): Boolean;
    //��Ӽ���
    function PauseJS(const nTunnel: string): Boolean;
    //��ͣ����
    function DelJS(const nTunnel: string; const nBuf: TList = nil): Boolean;
    //ɾ������
    function IsJSRun(const nTunnel: string): Boolean;
    //������
    function GetJSDai(const nBill: string): Integer;
    //��װ����
    function GetJSStatus(const nList: TStrings): Boolean;
    //����״̬
    property Hosts: TList read FHosts;
    property FileName: string read FFileName;
    property QueryEnable: Boolean read FEnableQuery write FEnableQuery;
    property CountEnable: Boolean read FEnableCount write FEnableCount;
    property ChainEnable: Boolean read FEnableChain write FEnableChain;
    property ChangeSync: TMultiJSEvent read FChangeSync write FChangeSync;
    property ChangeThread: TMultiJSEvent read FChangeThread write FChangeThread;
    property SaveDataProc: TMultiJSProc read FSaveDataProc write FSaveDataProc;
    property SaveDataEvent: TMultiJSEvent read FSaveDataEvent write FSaveDataEvent;
    property GetTruckProc: TMultiJSGetTruck read FGetTruck write FGetTruck;
    property LogControlFrame: Boolean read FLogCtrlFrame write FLogCtrlFrame;
    //�������
  end;

var
  gMultiJSManager: TMultiJSManager = nil;
  //ȫ��ʹ��

implementation

const
  cSizeHost         = SizeOf(TMultiJSHost);
  cSizeTunnel       = SizeOf(TMultiJSTunnel);
  cSizeDataSend     = SizeOf(TMultiJSDataSend);
  cSizeDataRecv     = SizeOf(TMultiJSDataRecv);
  cSizePeerRecv     = SizeOf(TMultiJSPeerRecv);
                                             
//------------------------------------------------------------------------------
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMultiJSManager, '�������������', nEvent);
end;  

constructor TMultJSItem.Create(AOwner: TMultiJSManager; nHost: PMultiJSHost);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FHost := nHost;
  FLastSave := 0;
  
  FTmpList := TList.Create;
  FBuffer := TList.Create;
  
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cMultiJS_FreshInterval;

  FClient := TIdTCPClient.Create;
  FClient.ReadTimeout := 5 * 1000;
  FClient.ConnectTimeout := 5 * 1000;
end;

destructor TMultJSItem.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;

  ClearBuffer(FBuffer, True);
  ClearBuffer(FTmpList, True);

  FWaiter.Free;
  inherited;
end;

procedure TMultJSItem.ClearBuffer(const nList: TList; const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    Dispose(PMultiJSDataSend(nList[nIdx]));
    nList.Delete(nIdx);
  end;

  if nFree then
    nList.Free;
  //xxxx
end;

//Date: 2012-4-23
//Parm: ͨ�����;�б�
//Desc: ��nList��ɾ����ʶΪnTunnel������
procedure TMultJSItem.DeleteFromBuffer(nAddr: Byte; nList: TList);
var nIdx: Integer;
    nData: PMultiJSDataSend;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    nData := nList[nIdx];
    if nData.FData.FAddr = nAddr then
    begin
      Dispose(nData);
      nList.Delete(nIdx);
    end;
  end;
end;

//Desc: �ͷ��߳�
procedure TMultJSItem.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

//Desc: �����߳�
procedure TMultJSItem.Wakeup;
begin
  FWaiter.Wakeup;
end;

//Desc: �߳���
procedure TMultJSItem.Execute;
var nIdx: Integer;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    try
      if not FClient.Connected then
      begin
        FClient.Host := FHost.FHostIP;
        FClient.Port := FHost.FHostPort;
        FClient.Connect;
      end;
    except
      WriteLog(Format('���Ӽ�����[ %s ]ʧ��', [FHost.FHostIP]));
      FClient.Disconnect;
      Continue;
    end;

    FOwner.FSyncLock.Enter;
    try
      for nIdx:=0 to FBuffer.Count - 1 do
        FTmpList.Add(FBuffer[nIdx]);
      FBuffer.Clear;
    finally
      FOwner.FSyncLock.Leave;
    end;

    if (FTmpList.Count < 1) and FOwner.FEnableQuery then
      AddQueryFrame(FTmpList);
    //��Ӳ�ѯ֡

    if FTmpList.Count > 0 then
    try
      FClient.Socket.InputBuffer.Clear;
      //��ջ���

      for nIdx:=0 to FTmpList.Count - 1 do
      begin
        SendDataFrame(FTmpList[nIdx]);
        //��������֡

        if nIdx < FTmpList.Count - 1 then
          Sleep(cMultiJS_FreshInterval);
        //��֡����ʱ����ʱ
      end;
         
      ClearBuffer(FTmpList);
    except
      ClearBuffer(FTmpList);
      FClient.Disconnect;
      
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      raise;
    end;
  except
    On E:Exception do
    begin
      WriteLog(Format('Host:[ %s ] %s', [FHost.FHostIP, E.Message]));
    end;
  end;
end;

//Desc: ��nList����Ӳ�ѯ֡
procedure TMultJSItem.AddQueryFrame(const nList: TList);
var nSend: PMultiJSDataSend;
begin
  New(nSend);
  nList.Add(nSend);
  FillChar(nSend^, cSizeDataSend, #0);

  with nSend^ do
  begin
    FHeader[0] := $0A;
    FHeader[1] := $55;
    FAddr := FHost.F485Addr;

    FType := cFrame_Query;
    FEnd := $0D;
  end;
end;

//Desc: ��������
procedure TMultJSItem.SendDataFrame(const nData: PMultiJSDataSend);
var nBuf: TIdBytes;
    nSize: Integer;
begin
  nBuf := RawToBytes(nData^, cSizeDataSend);
  FClient.Socket.Write(nBuf);

  if (nData.FType = cFrame_Control) and FOwner.FLogCtrlFrame then
    WriteLog(ToHex(nBuf));
  if nData.FType <> cFrame_Query then Exit;

  nSize := cSizeDataRecv - (cMultiJS_Tunnel - FHost.FTunnelNum) * cSizePeerRecv;
  FClient.Socket.ReadBytes(nBuf, nSize, False);
  BytesToRaw(nBuf, FRecv, nSize);

  ApplyRespondData;
  //apply data
end;

//Desc: ͬ����ǰͨ��
procedure TMultJSItem.SyncNowTunnel;
begin
  FOwner.FChangeSync(FNowTunnel);
end;

//Desc: ���´���������
procedure TMultJSItem.ApplyRespondData;
var nBool: Boolean;
    nIdx,nInt: Integer;
    nTunnel: PMultiJSTunnel;
begin
  nBool := GetTickCount - FLastSave >= cMultiJS_SaveInterval;
  if nBool then
    FLastSave := GetTickCount;
  //reset save time

  for nIdx:=0 to FHost.FTunnelNum - 1 do
  begin
    nTunnel := GetTunnel(FRecv.FData[nIdx].FAddr);
    if not Assigned(nTunnel) then Continue;

    try
      nInt := StrToInt(FRecv.FData[nIdx].FDai);
      //tunnel's num
      
      if nTunnel.FHasDone < nInt then
      begin
        FOwner.FSyncLock.Enter;
        try
          if nInt >= nTunnel.FDaiNum then
               nTunnel.FIsRun := False
          else nTunnel.FIsRun := True;
          
          nTunnel.FHasDone := nInt;
          //now dai num
        finally
          FOwner.FSyncLock.Leave;
        end;

        if Assigned(FOwner.FChangeThread) then
          FOwner.FChangeThread(nTunnel);
        //thread event

        if Assigned(FOwner.FChangeSync) then
        begin
          FNowTunnel := nTunnel;
          Synchronize(SyncNowTunnel);
        end;
      end;

      if nBool and FOwner.FEnableQuery then
      begin
        if Assigned(FOwner.FSaveDataEvent) then
          FOwner.FSaveDataEvent(nTunnel);
        //xxxxx

        if Assigned(FOwner.FSaveDataProc) then
          FOwner.FSaveDataProc(nTunnel);
        //xxxxx

        nTunnel.FLastSaveDai := nTunnel.FHasDone;
        //enable query means enable auto_save
      end;
    except
      on E: Exception do
      begin
        WriteLog(Format('Host:[ %s.%s ] %s', [FHost.FHostIP, nTunnel.FID, E.Message]));
      end;
    end;
  end;
end;

//Date: 2012-4-23
//Parm: ͨ����
//Desc: ����nTunnelͨ��
function TMultJSItem.GetTunnel(const nTunnel: Byte): PMultiJSTunnel;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=0 to FHost.FTunnel.Count - 1 do
  if PMultiJSTunnel(FHost.FTunnel[nIdx]).FTunnel = nTunnel then
  begin
    Result := FHost.FTunnel[nIdx];
    Exit;
  end;
end;

//------------------------------------------------------------------------------
constructor TMultiJSManager.Create;
begin
  FEnableQuery := False;
  FEnableCount := False;
  FEnableChain := True;
  FLogCtrlFrame := False;

  FHosts := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TMultiJSManager.Destroy;
begin
  StopJS;
  ClearHost(True);

  FSyncLock.Free;
  inherited;
end;

//Desc: �ͷ�nData�˿�
procedure TMultiJSManager.DisposeHost(const nHost: PMultiJSHost);
var nIdx: Integer;
begin
  for nIdx:=nHost.FTunnel.Count - 1 downto 0 do
  begin
    Dispose(PMultiJSTunnel(nHost.FTunnel[nIdx]));
    nHost.FTunnel.Delete(nIdx);
  end;

  nHost.FTunnel.Free;
  Dispose(nHost);
end;

//Desc: ����˿�����
procedure TMultiJSManager.ClearHost(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FHosts.Count - 1 downto 0 do
  begin
    DisposeHost(FHosts[nIdx]);
    FHosts.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FHosts);
  //xxxxx
end;

//Desc: ��������
procedure TMultiJSManager.StartJS;
var nIdx: Integer;
    nHost: PMultiJSHost;
begin
  if FEnableCount then
  begin
    for nIdx:=0 to FHosts.Count - 1 do
    begin
      nHost := FHosts[nIdx];
      if Assigned(nHost.FReader) then Continue;

      nHost.FReader := TMultJSItem.Create(Self, nHost);
      //new reader
    end;
  end;
end;

//Desc: ֹͣ����
procedure TMultiJSManager.StopJS;
var nIdx: Integer;
    nHost: PMultiJSHost;
begin
  for nIdx:=0 to FHosts.Count - 1 do
  begin
    nHost := FHosts[nIdx];
    if Assigned(nHost.FReader) then
    begin
      nHost.FReader.StopMe;
      nHost.FReader := nil;
    end;
  end;
end;

//Desc: ��ȡ��������
procedure TMultiJSManager.LoadFile(const nFile: string);
var i,nIdx: Integer;
    nNode,nTmp,nTN: TXmlNode;
    nXML: TNativeXml;
    nHost: PMultiJSHost;
    nTunnel: PMultiJSTunnel;
begin
  FFileName := nFile;
  nXML := TNativeXml.Create;
  try
    ClearHost(False);
    nXML.LoadFromFile(nFile);

    nTmp := nXML.Root.FindNode('config');
    if Assigned(nTmp) then
    begin
      nIdx := nTmp.NodeByName('query').ValueAsInteger;
      FEnableQuery := nIdx = 1;

      nIdx := nTmp.NodeByName('count').ValueAsInteger;
      FEnableCount := nIdx = 1;

      nNode := nTmp.NodeByName('chain');
      if Assigned(nNode) then
        FEnableChain := nNode.ValueAsInteger <> 0;
      //xxxxx
    end;

    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nTmp := nXML.Root.Nodes[nIdx];
      if nTmp.Name <> 'item' then Continue;
      
      New(nHost);
      FHosts.Add(nHost);

      with nHost^ do
      begin
        FName := nTmp.AttributeByName['name'];
        nNode := nTmp.NodeByName('param');

        FHostIP := nNode.NodeByName('ip').ValueAsString;
        FHostPort := nNode.NodeByName('port').ValueAsInteger;
        F485Addr := nNode.NodeByName('addr').ValueAsInteger;

        FTunnelNum := nNode.NodeByName('linenum').ValueAsInteger;
        if FTunnelNum > cMultiJS_Tunnel then
          FTunnelNum := cMultiJS_Tunnel;
        //has max

        FTunnel := TList.Create;
        FReader := nil;
      end;

      nTmp := nTmp.NodeByName('lines');
      for i:=0 to nTmp.NodeCount - 1 do
      begin
        nNode := nTmp.Nodes[i];
        New(nTunnel);
        nHost.FTunnel.Add(nTunnel);

        FillChar(nTunnel^, cSizeTunnel, #0);
        //init
        
        with nTunnel^ do
        begin
          FID := nNode.NodeByName('id').ValueAsString;
          FName := nNode.NodeByName('name').ValueAsString;
          FTunnel := nNode.NodeByName('tunnel').ValueAsInteger;
          FDelay := nNode.NodeByName('delay').ValueAsInteger;

          nTN := nNode.FindNode('group');
          if Assigned(nTN) then
               FGroup := nTN.ValueAsString
          else FGroup := '';
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-23
//Parm: ͨ����ʶ
//Desc: ����nIDͨ��
function TMultiJSManager.GetTunnel(const nID: string; var nHost: PMultiJSHost;
  var nTunnel: PMultiJSTunnel): Boolean;
var i,nIdx: Integer;
    nPHost: PMultiJSHost;
    nPTunnel: PMultiJSTunnel;
begin
  Result := False;
  nHost := nil;
  nTunnel := nil; 

  for i:=0 to FHosts.Count - 1 do
  begin
    nPHost := FHosts[i];
    for nIdx:=0 to nPHost.FTunnel.Count - 1 do
    begin
      nPTunnel := nPHost.FTunnel[nIdx];
      if CompareText(nID, nPTunnel.FID) = 0 then
      begin
        nHost := nPHost;
        nTunnel := nPTunnel;

        Result := True;
        Exit;
      end;
    end;
  end;
end;

//Date: 2012-4-23
//Parm: ͨ����ʶ;����;����
//Desc: ��nTunnel���һ����������
function TMultiJSManager.AddJS(const nTunnel, nTruck, nBill: string;
  nDaiNum: Integer; const nDelJS: Boolean): Boolean;
var nStr: string;
    nPH: PMultiJSHost;
    nPT: PMultiJSTunnel;
    nSend: PMultiJSDataSend;
begin
  Result := False;
  if not FEnableCount then Exit;

  FSyncLock.Enter;
  try
    if not (GetTunnel(nTunnel, nPH, nPT) and Assigned(nPH.FReader)) then Exit;
    //ͨ����Ч

    nPH.FReader.DeleteFromBuffer(nPT.FTunnel, nPH.FReader.FBuffer);
    //����δִ������

    if (not FEnableChain) or nDelJS then
    begin
      DelJS(nTunnel, nPH.FReader.FBuffer);
      DelJS(nTunnel, nPH.FReader.FBuffer);
      //ֹͣ����
    end;

    New(nSend);
    nPH.FReader.FBuffer.Add(nSend);
    FillChar(nSend^, cSizeDataSend, #0);

    with nSend^ do
    begin
      FHeader[0] := $0A;
      FHeader[1] := $55;
      FAddr := nPH.F485Addr;
      FType := cFrame_Control;

      with FData do
      begin
        FAddr := nPT.FTunnel;
        FDelay := nPT.FDelay;

        if Assigned(FGetTruck) then
             nStr := FGetTruck(nTruck, Trim(nBill))
        else nStr := nTruck;

        nStr := Copy(nStr, 1, cMultiJS_Truck);
        nStr := nStr + StringOfChar(' ', cMultiJS_Truck - Length(nStr));
        StrPCopy(@FTruck[0], nStr);

        //if (not nPT.FIsRun) or
        //   (nPT.FLastBill <> nBill) or (nPT.FDaiNum <> nDaiNum) then
        //begin
          nPT.FHasDone := 0;
          nPT.FLastSaveDai := 0;
          nPT.FLastBill := nBill;

          nPT.FDaiNum := nDaiNum;
          nPT.FIsRun := nPT.FGroup <> '';
          //����ʱ�����������б��
        //end; //ͬ����������Ϊ��ͣ

        nStr := IntToStr(nDaiNum);
        nStr := StringOfChar('0', cMultiJS_DaiNum - Length(nStr)) + nStr;
        StrPCopy(@FDai[0], nStr);
      end;

      FEnd := $0D;
      Result := True;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-07-16
//Parm: ͨ����ʶ
//Desc: ��ͣnTunnelͨ��
function TMultiJSManager.PauseJS(const nTunnel: string): Boolean;
var nPH: PMultiJSHost;
    nPT: PMultiJSTunnel;
    nSend: PMultiJSDataSend;
begin
  FSyncLock.Enter;
  try
    Result := False;
    if not (GetTunnel(nTunnel, nPH, nPT) and Assigned(nPH.FReader)) then Exit;
    //ͨ����Ч

    nPH.FReader.DeleteFromBuffer(nPT.FTunnel, nPH.FReader.FBuffer);
    //����δִ������

    New(nSend);
    nPH.FReader.FBuffer.Add(nSend);
    FillChar(nSend^, cSizeDataSend, #0);

    with nSend^ do
    begin
      FHeader[0] := $0A;
      FHeader[1] := $55;
      FAddr := nPH.F485Addr;
      FType := cFRame_Pasuse;

      FData.FAddr := nPT.FTunnel;
      FEnd := $0D;
    end;

    Result := True;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2012-4-23
//Parm: ͨ����
//Desc: ֹͣnTunnel����
function TMultiJSManager.DelJS(const nTunnel: string; const nBuf: TList): Boolean;
var nStr: string;
    i,nIdx: Integer;
    nList: TList;
    nPH: PMultiJSHost;
    nPT: PMultiJSTunnel;
    nSend: PMultiJSDataSend;
begin
  FSyncLock.Enter;
  try
    Result := False;
    //default

    if not (GetTunnel(nTunnel, nPH, nPT) and Assigned(nPH.FReader)) then Exit;
    //ͨ��������Ч

    if Assigned(nBuf) then
    begin
      nList := nBuf;
    end else
    begin
      nList := nPH.FReader.FBuffer;
      nPH.FReader.DeleteFromBuffer(nPT.FTunnel, nList);
      //����δִ������
    end;

    nPT.FIsRun := False;
    //���б��

    New(nSend);
    nList.Add(nSend);
    FillChar(nSend^, cSizeDataSend, #0);
     
    with nSend^ do
    begin
      FHeader[0] := $0A;
      FHeader[1] := $55;
      FAddr := nPH.F485Addr;
      FType := cFrame_Clear;

      FData.FAddr := nPT.FTunnel;
      FEnd := $0D;
    end;

    Result := True;
    if nPT.FGroup = '' then Exit;
    nStr := nPT.FGroup;

    for i:=0 to FHosts.Count - 1 do
    begin
      nPH := FHosts[i];
      for nIdx:=0 to nPH.FTunnel.Count - 1 do
      begin
        nPT := nPH.FTunnel[nIdx];
        //xxxxx

        if (CompareText(nStr, nPT.FGroup) = 0) and Assigned(nPH.FReader) then
          nPT.FIsRun := False;
        //����ͬһ��������б��
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-07-17
//Parm: ͨ����ʶ;����Ϊ��ѯ;ֵ
//Desc: �ж�nTunnel�Ƿ�������
function TMultiJSManager.IsJSRun(const nTunnel: string): Boolean;
var nStr: string;
    i,nIdx: Integer;
    nPH: PMultiJSHost;
    nPT: PMultiJSTunnel;
begin
  if not FEnableChain then
  begin
    Result := False;
    Exit;
  end; //����������,�򲻴���״̬

  FSyncLock.Enter;
  try
    if GetTunnel(nTunnel, nPH, nPT) and Assigned(nPH.FReader) then
         Result := nPT.FIsRun
    else Result := False;

    if Result or (not Assigned(nPT)) then Exit;
    //run,or no tunnel

    if nPT.FGroup = '' then
      Exit; //no group    
    nStr := nPT.FGroup;

    for i:=0 to FHosts.Count - 1 do
    begin
      nPH := FHosts[i];
      for nIdx:=0 to nPH.FTunnel.Count - 1 do
      begin
        nPT := nPH.FTunnel[nIdx];
        if (CompareText(nStr, nPT.FGroup) = 0) and Assigned(nPH.FReader) then
        begin
          Result := nPT.FIsRun;
          if Result then
            Exit;
          //run tunnel exists
        end;
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-07-17
//Parm: ������
//Desc: ��ȡnBill����������װ����
function TMultiJSManager.GetJSDai(const nBill: string): Integer;
var i,nIdx: Integer;
    nPHost: PMultiJSHost;
    nPTunnel: PMultiJSTunnel;
begin
  FSyncLock.Enter;
  try
    Result := 0;
    //default

    for i:=0 to FHosts.Count - 1 do
    begin
      nPHost := FHosts[i];
      for nIdx:=0 to nPHost.FTunnel.Count - 1 do
      begin
        nPTunnel := nPHost.FTunnel[nIdx];
        if CompareText(nBill, nPTunnel.FLastBill) <> 0 then Continue;

        Result := nPTunnel.FHasDone;
        Exit;
      end
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-07-22
//Parm: ����б�(tunnel=dai)
//Desc: ��ȡ��ͨ���ļ������
function TMultiJSManager.GetJSStatus(const nList: TStrings): Boolean;
var i,nIdx: Integer;
    nPHost: PMultiJSHost;
    nPTunnel: PMultiJSTunnel;
begin
  FSyncLock.Enter;
  try
    Result := True;
    nList.Clear;

    for i:=0 to FHosts.Count - 1 do
    begin
      nPHost := FHosts[i];
      for nIdx:=0 to nPHost.FTunnel.Count - 1 do
      begin
        nPTunnel := nPHost.FTunnel[nIdx];
        if FEnableChain then
        begin
          //if nPTunnel.FIsRun then
               nList.Values[nPTunnel.FID] := IntToStr(nPTunnel.FHasDone)
          //else nList.Values[nPTunnel.FID] := '0';
        end else
        begin
          nList.Values[nPTunnel.FID] := IntToStr(nPTunnel.FHasDone);
        end;
      end
    end;
  finally
    FSyncLock.Leave;
  end;
end;

initialization
  gMultiJSManager := TMultiJSManager.Create;
finalization
  FreeAndNil(gMultiJSManager);
end.
