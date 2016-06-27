{*******************************************************************************
  ���ߣ�dmzn@163.com 2014-5-28
  ������������������ͨѶ��Ԫ
*******************************************************************************}
unit UMgrTruckProbe;

{.$DEFINE DEBUG}
interface

uses
  Windows, Classes, SysUtils, SyncObjs, IdTCPConnection, IdTCPClient, IdGlobal,
  NativeXml, UWaitItem, UMemDataPool, USysLoger, ULibFun;

const
  cProber_NullASCII           = $30;       //ASCII���ֽ�
  cProber_Flag_Begin          = $F0;       //��ʼ��ʶ
  
  cProber_Frame_QueryIO       = $10;       //״̬��ѯ(in out)
  cProber_Frame_RelaysOC      = $20;       //ͨ������(open close)
  cProber_Frame_DataForward   = $30;       //485����ת��
  cProber_Frame_IP            = $50;       //����IP
  cProber_Frame_MAC           = $60;       //����MAC

  cProber_Query_All           = $00;       //��ѯȫ��
  cProber_Query_In            = $01;       //��ѯ����
  cProber_Query_Out           = $02;       //��ѯ���
  cProber_Query_Interval      = 1200;      //��ѯ���

  cProber_Len_Frame           = $14;       //��ͨ֡��
  cProber_Len_FrameData       = 16;        //��ͨ��������
  cProber_Len_485Data         = 100;       //485ת������
    
type
  TProberIOAddress = array[0..7] of Byte;
  //in-out address

  TProberFrameData = array [0..cProber_Len_FrameData - 1] of Byte;
  TProber485Data   = array [0..cProber_Len_485Data - 1] of Byte;

  PProberFrameHeader = ^TProberFrameHeader;
  TProberFrameHeader = record
    FBegin  : Byte;                //��ʼ֡
    FLength : Byte;                //֡����
    FType   : Byte;                //֡����
    FExtend : Byte;                //֡��չ
  end;

  PProberFrameControl = ^TProberFrameControl;
  TProberFrameControl = record
    FHeader : TProberFrameHeader;   //֡ͷ
    FData   : TProberFrameData;     //����
    FVerify : Byte;                //У��λ
  end;

  PProberFrameDataForward = ^TProberFrameDataForward;
  TProberFrameDataForward = record
    FHeader : TProberFrameHeader;   //֡ͷ
    FData   : TProber485Data;       //����
    FVerify : Byte;                //У��λ
  end;  

  PProberHost = ^TProberHost;
  TProberHost = record
    FID      : string;               //��ʶ
    FName    : string;               //����
    FHost    : string;               //IP
    FPort    : Integer;              //�˿�
    FStatusI : TProberIOAddress;     //����״̬
    FStatusO : TProberIOAddress;     //���״̬
    FStatusL : Int64;                //״̬ʱ��

    FInSignalOn: Byte;
    FInSignalOff: Byte;              //�����ź�
    FOutSignalOn: Byte;
    FOutSignalOff: Byte;             //����ź�

    FClient : TIdTCPClient;          //ͨ����·
    FLocked : Boolean;               //�Ƿ�����
    FLastActive: Int64;              //�ϴλ
    FEnable  : Boolean;              //�Ƿ�����
  end;  

  PProberTunnel = ^TProberTunnel;
  TProberTunnel = record
    FID      : string;               //��ʶ
    FName    : string;               //����
    FHost    : PProberHost;          //��������
    FIn      : TProberIOAddress;     //�����ַ

    FOut     : TProberIOAddress;     //�����ַ
    FAutoOFF : Integer;              //�Զ��ر�
    FLastOn  : Int64;                //�ϴδ�
    FEnable  : Boolean;              //�Ƿ�����
  end;

  PProberTunnelCommand = ^TProberTunnelCommand;
  TProberTunnelCommand = record
    FTunnel  : PProberTunnel;
    FCommand : Integer;
    FData    : Pointer;
  end;

  TProberHosts = array of TProberHost;
  //array of host
  TProberTunnels = array of TProberTunnel;
  //array of tunnel

const
  cSize_Prober_IOAddr   = SizeOf(TProberIOAddress);
  cSize_Prober_Control  = SizeOf(TProberFrameControl);
  cSize_Prober_Display  = SizeOf(TProberFrameDataForward);

type
  TProberThreadType = (ttAll, ttActive);
  //�߳�ģʽ: ȫ��;ֻ���

  TProberManager = class;
  TProberThread = class(TThread)
  private
    FOwner: TProberManager;
    //ӵ����
    FBuffer: TList;
    //����������
    FWaiter: TWaitObject;
    //�ȴ�����
    FThreadType: TProberThreadType;
    //�߳�ģʽ
    FActiveHost: PProberHost;
    //��ǰ��ͷ
    FQueryFrame: TProberFrameControl;
    //״̬��ѯ
  protected
    procedure Execute; override;
    procedure DoExecute;
    //ִ���߳�
    procedure ScanActiveHost(const nActive: Boolean);
    //ɨ�����
    procedure SendHostCommand(const nHost: PProberHost);
    function SendData(const nHost: PProberHost; var nData: TIdBytes;
      const nRecvLen: Integer): string;
    //��������
  public
    constructor Create(AOwner: TProberManager; AType: TProberThreadType);
    destructor Destroy; override;
    //�����ͷ�
    procedure Wakeup;
    procedure StopMe;
    //��ͣͨ��
  end;

  TProberManager = class(TObject)
  private
    FRetry: Byte;
    //���Դ���
    FCommand: TList;
    //�����б�
    FHosts: TList;
    FTunnels: TProberTunnels;
    //ͨ���б�
    FHostIndex: Integer;
    FHostActive: Integer;
    //��ͷ����
    FIDCommand: Integer;
    FIDControl: Integer;
    FIDForward: Integer;
    //���ݱ�ʶ
    FReaders: array[0..1] of TProberThread;
    //���Ӷ���
    FSyncLock: TCriticalSection;
    //ͬ������
  protected
    procedure ClearCommandList(nList: TList; nFree: Boolean);
    procedure ClearHost(const nFree: Boolean);
    //��������
    procedure CloseHostConn(const nHost: PProberHost);
    //�ر�����
    procedure RegisterDataType;
    //ע������
    procedure WakeupReaders;
    //�����߳�
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure StartProber;
    procedure StopProber;
    //��ͣ�����
    procedure LoadConfig(const nFile: string);
    //��ȡ����
    function OpenTunnel(const nTunnel: string): Boolean;
    function CloseTunnel(const nTunnel: string): Boolean;
    function TunnelOC(const nTunnel: string; nOC: Boolean): string;
    //����ͨ��
    function GetTunnel(const nTunnel: string): PProberTunnel;
    procedure EnableTunnel(const nTunnel: string; const nEnabled: Boolean);
    function QueryStatus(const nHost: PProberHost;
      var nIn,nOut: TProberIOAddress): string;
    function IsTunnelOK(const nTunnel: string): Boolean;
    //��ѯ״̬
    property Hosts: TList read FHosts;
    property RetryOnError: Byte read FRetry write FRetry;
    //�������
  end;

var
  gProberManager: TProberManager = nil;
  //ȫ��ʹ��

function ProberVerifyData(var nData: TIdBytes; const nDataLen: Integer;
  const nLast: Boolean): Byte;
procedure ProberStr2Data(const nStr: string; var nData: TProberFrameData);
//��ں���

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TProberManager, '����������', nEvent);
end;

//Desc: ��nData�����У��
function ProberVerifyData(var nData: TIdBytes; const nDataLen: Integer;
  const nLast: Boolean): Byte;
var nIdx,nLen: Integer;
begin
  Result := 0;
  if nDataLen < 1 then Exit;

  nLen := nDataLen - 2;
  //ĩλ���������
  Result := nData[0];

  for nIdx:=1 to nLen do
    Result := Result xor nData[nIdx];
  //xxxxx

  if nLast then
    nData[nDataLen - 1] := Result;
  //���ӵ�ĩβ
end;

//Date: 2014-05-30
//Parm: �ַ���;����
//Desc: ��nStr��䵽nData��
procedure ProberStr2Data(const nStr: string; var nData: TProberFrameData);
var nIdx,nLen: Integer;
begin
  nLen := Length(nStr);
  if nLen > cProber_Len_FrameData then
    nLen := cProber_Len_FrameData;
  //���Ƚ���

  for nIdx:=1 to nLen do
    nData[nIdx-1] := Ord(nStr[nIdx]);
  //xxxxx
end;

//Date: 2012-4-13
//Parm: �ַ�
//Desc: ��ȡnTxt������
function ConvertStr(const nTxt: WideString; var nBuf: array of Byte): Integer;
var nStr: string;
    nIdx: Integer;
begin
  Result := 0;
  for nIdx:=1 to Length(nTxt) do
  begin
    nStr := nTxt[nIdx];
    nBuf[Result] := Ord(nStr[1]);
    Inc(Result);

    if Length(nStr) = 2 then
    begin
      nBuf[Result] := Ord(nStr[2]);
      Inc(Result);
    end;

    if Result >= cProber_Len_485Data then Break;
  end;
end;

//Date��2014-5-13
//Parm����ַ�ṹ;��ַ�ַ���,����: 1,2,3
//Desc����nStr��,����nAddr�ṹ��
procedure SplitAddr(var nAddr: TProberIOAddress; const nStr: string);
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    SplitStr(nStr, nList, 0 , ',');
    //���
    
    for nIdx:=Low(nAddr) to High(nAddr) do
    begin
      if nIdx < nList.Count then
           nAddr[nIdx] := StrToInt(nList[nIdx])
      else nAddr[nIdx] := cProber_NullASCII;
    end;
  finally
    nList.Free;
  end;
end;

{$IFDEF DEBUG}
procedure LogHex(const nData: TIdBytes);
var nStr: string;
    nIdx: Integer;
begin
  nStr := '';
  for nIdx:=Low(nData) to High(nData) do
    nStr := nStr + IntToHex(nData[nIdx], 1) + ' ';
  WriteLog(nStr);
end;
{$ENDIF}

procedure OnNew(const nFlag: string; const nType: Word; var nData: Pointer);
var nCtr: PProberFrameControl;
    nCmd: PProberTunnelCommand;
    nFrw: PProberFrameDataForward;
begin
  if nFlag = 'ProberCTR' then
  begin
    New(nCtr);
    nData := nCtr;
  end else

  if nFlag = 'ProberCMD' then
  begin
    New(nCmd);
    nData := nCmd;
  end else

  if nFlag = 'ProberFwd' then
  begin
    New(nFrw);
    nData := nFrw;
  end;
end;

procedure OnFree(const nFlag: string; const nType: Word; const nData: Pointer);
begin
  if nFlag = 'ProberCTR' then
  begin
    Dispose(PProberFrameControl(nData));
  end else

  if nFlag = 'ProberCMD' then
  begin
    Dispose(PProberTunnelCommand(nData));
  end else

  if nFlag = 'ProberFwd' then
  begin
    Dispose(PProberFrameDataForward(nData));
  end;
end;

//------------------------------------------------------------------------------
constructor TProberManager.Create;
begin
  FRetry := 2;
  FHosts := TList.Create;
  FCommand := TList.Create;
  FSyncLock := TCriticalSection.Create;

  RegisterDataType;
  //���ڴ��������
end;

destructor TProberManager.Destroy;
begin
  StopProber;
  ClearCommandList(FCommand, True);
  ClearHost(True);

  FSyncLock.Free;
  inherited;
end;

//Desc: ��������
procedure TProberManager.ClearCommandList(nList: TList; nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    gMemDataManager.UnLockData(PProberTunnelCommand(nList[nIdx]).FData);
    gMemDataManager.UnLockData(nList[nIdx]);
    nList.Delete(nIdx);
  end;

  if nFree then
    nList.Free;
  //xxxxx
end;

//Desc: ��������
procedure TProberManager.ClearHost(const nFree: Boolean);
var nIdx: Integer;
    nItem: PProberHost;
begin
  for nIdx:=FHosts.Count - 1 downto 0 do
  begin
    nItem := FHosts[nIdx];
    nItem.FClient.Free;
    nItem.FClient := nil;
    
    Dispose(nItem);
    FHosts.Delete(nIdx);
  end;

  if nFree then
    FHosts.Free;
  //xxxxx
end;

//Desc: ע����������
procedure TProberManager.RegisterDataType;
begin
  if not Assigned(gMemDataManager) then
    raise Exception.Create('ProberManager Needs MemDataManager Support.');
  //xxxxx

  with gMemDataManager do
  begin
    FIDCommand := RegDataType('ProberCMD', 'TunnelCommand', OnNew, OnFree, 2);
    FIDControl := RegDataType('ProberCTR', 'FrameControl', OnNew, OnFree, 2);
    FIDForward := RegDataType('ProberFwd', 'DataForward', OnNew, OnFree, 1); 
  end;
end;

//Desc: ����
procedure TProberManager.StartProber;
var nIdx,nInt: Integer;
    nType: TProberThreadType;
begin
  nInt := 0;
  for nIdx:=FHosts.Count - 1 downto 0 do
   if PProberHost(FHosts[nIdx]).FEnable then
    Inc(nInt);
  //count enable host
                            
  if nInt < 1 then Exit;
  FHostIndex := 0;
  FHostActive := 0;

  for nIdx:=Low(FReaders) to High(FReaders) do
  begin
    if nIdx >= nInt then Exit;
    //�̲߳���������������

    if nIdx = 0 then
         nType := ttAll
    else nType := ttActive;

    if not Assigned(FReaders[nIdx]) then
      FReaders[nIdx] := TProberThread.Create(Self, nType);
    //xxxxx
  end;
end;

//Desc: ֹͣ
procedure TProberManager.StopProber;
var nIdx: Integer;
begin
  for nIdx:=Low(FReaders) to High(FReaders) do
   if Assigned(FReaders[nIdx]) then
    FReaders[nIdx].Terminate;
  //�����˳����

  for nIdx:=Low(FReaders) to High(FReaders) do
  begin
    if Assigned(FReaders[nIdx]) then
      FReaders[nIdx].StopMe;
    FReaders[nIdx] := nil;
  end;

  FSyncLock.Enter;
  try
    for nIdx:=FHosts.Count - 1 downto 0 do
      CloseHostConn(FHosts[nIdx]);
    //�ر���·
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: ����ȫ���߳�
procedure TProberManager.WakeupReaders;
var nIdx: Integer;
begin
  for nIdx:=Low(FReaders) to High(FReaders) do
   if Assigned(FReaders[nIdx]) then
    FReaders[nIdx].Wakeup;
  //xxxxx
end;

//Desc: �ر�������·
procedure TProberManager.CloseHostConn(const nHost: PProberHost);
begin
  if Assigned(nHost) and Assigned(nHost.FClient) then
  begin
    nHost.FClient.Disconnect;
    if Assigned(nHost.FClient.IOHandler) then
      nHost.FClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

//Desc: ����nFile�����ļ�
procedure TProberManager.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nHost: PProberHost;
    nRoot,nNode,nTmp: TXmlNode;
    i,nIdx,nNum: Integer;
begin
  ClearHost(False);
  SetLength(FTunnels, 0);
  
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    //load config

    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nRoot := nXML.Root.Nodes[nIdx];
      //prober node

      New(nHost);
      FHosts.Add(nHost);

      with nHost^,nRoot do
      begin
        FID    := AttributeByName['id'];
        FName  := AttributeByName['name'];
        FHost  := NodeByName('ip').ValueAsString;
        FPort  := NodeByName('port').ValueAsInteger;
        FEnable := NodeByName('enable').ValueAsInteger = 1;

        FStatusL := 0;
        //���һ�β�ѯ״̬ʱ��,��ʱϵͳ�᲻�Ͽɵ�ǰ״̬

        FLocked := False;
        FLastActive := GetTickCount;
        //�״̬

        nTmp := nRoot.FindNode('signal_in');
        if Assigned(nTmp) then
        begin
          FInSignalOn := StrToInt(nTmp.AttributeByName['on']);
          FInSignalOff := StrToInt(nTmp.AttributeByName['off']);
        end else
        begin
          FInSignalOn := $00;
          FInSignalOff := $01;
        end;

        nTmp := nRoot.FindNode('signal_out');
        if Assigned(nTmp) then
        begin
          FOutSignalOn := StrToInt(nTmp.AttributeByName['on']);
          FOutSignalOff := StrToInt(nTmp.AttributeByName['off']);
        end else
        begin
          FOutSignalOn := $01;
          FOutSignalOff := $02;
        end;

        if FEnable then
        begin
          FClient := TIdTCPClient.Create;
          //socket
          
          with FClient do
          begin
            Host := FHost;
            Port := FPort;
            ReadTimeout := 3 * 1000;
            ConnectTimeout := 3 * 1000;   
          end;
        end else FClient := nil;
      end;

      nRoot := nRoot.FindNode('tunnels');
      if not Assigned(nRoot) then Continue;

      for i:=0 to nRoot.NodeCount - 1 do
      begin
        nNode := nRoot.Nodes[i];
        nNum := Length(FTunnels);
        SetLength(FTunnels, nNum + 1);

        with FTunnels[nNum],nNode do
        begin
          FID    := AttributeByName['id'];
          FName  := AttributeByName['name'];
          FHost  := nHost;
          
          SplitAddr(FIn, NodeByName('in').ValueAsString);
          SplitAddr(FOut, NodeByName('out').ValueAsString);

          nTmp := nNode.FindNode('enable');
          FEnable := (not Assigned(nTmp)) or (nTmp.ValueAsString <> '0');
          FLastOn := 0;

          nTmp := nNode.FindNode('auto_off');           
          if Assigned(nTmp) then
               FAutoOFF := nTmp.ValueAsInteger
          else FAutoOFF := 0;
        end;
      end
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
//Date��2014-5-14
//Parm��ͨ����
//Desc����ȡnTunnel��ͨ������
function TProberManager.GetTunnel(const nTunnel: string): PProberTunnel;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=Low(FTunnels) to High(FTunnels) do
  if CompareText(nTunnel, FTunnels[nIdx].FID) = 0 then
  begin
    Result := @FTunnels[nIdx];
    Break;
  end;
end;

//Date��2014-5-13
//Parm��ͨ����;True=Open,False=Close
//Desc����nTunnelִ�п��ϲ���,���д����򷵻�
function TProberManager.TunnelOC(const nTunnel: string; nOC: Boolean): string;
var i,j,nIdx: Integer;
    nPTunnel: PProberTunnel;
    nCmd: PProberTunnelCommand;
    nData: PProberFrameControl;
begin
  Result := '';
  if not Assigned(FReaders[0]) then Exit;
  nPTunnel := GetTunnel(nTunnel);

  if not Assigned(nPTunnel) then
  begin
    Result := 'ͨ��[ %s ]�����Ч.';
    Result := Format(Result, [nTunnel]); Exit;
  end;

  if not (nPTunnel.FEnable and nPTunnel.FHost.FEnable ) then Exit;
  //������,������

  i := 0;
  for nIdx:=Low(nPTunnel.FOut) to High(nPTunnel.FOut) do
    if nPTunnel.FOut[nIdx] <> cProber_NullASCII then Inc(i);
  //xxxxx

  if i < 1 then Exit;
  //�������ַ,��ʾ��ʹ���������

  FSyncLock.Enter;
  try
    nCmd := gMemDataManager.LockData(FIDCommand);
    FCommand.Add(nCmd);
    nCmd.FTunnel := nPTunnel;
    nCmd.FCommand := cProber_Frame_RelaysOC;

    nData := gMemDataManager.LockData(FIDControl);
    nCmd.FData := nData;
    FillChar(nData^, cSize_Prober_Control, cProber_NullASCII);

    with nData.FHeader do
    begin
      FBegin := cProber_Flag_Begin;
      FLength := cProber_Len_Frame;
      FType := cProber_Frame_RelaysOC;

      if nOC then
           FExtend := nPTunnel.FHost.FOutSignalOn
      else FExtend := nPTunnel.FHost.FOutSignalOff;
    end;

    j := 0;
    for i:=Low(nPTunnel.FOut) to High(nPTunnel.FOut) do
    begin
      if nPTunnel.FOut[i] = cProber_NullASCII then Continue;
      //invalid out address

      nData.FData[j] := nPTunnel.FOut[i];
      Inc(j);
    end;

    WakeupReaders;
    //wake up thread
  finally  
    FSyncLock.Leave;
  end;
end;

//Date��2014-5-13
//Parm��ͨ����
//Desc����nTunnelִ�����ϲ���
function TProberManager.OpenTunnel(const nTunnel: string): Boolean;
var nStr: string;
begin
  nStr := TunnelOC(nTunnel, False);
  Result := nStr = '';

  if not Result then
    WriteLog(nStr);
  //xxxxxx
end;

//Date��2014-5-13
//Parm��ͨ����
//Desc����nTunnelִ�жϿ�����
function TProberManager.CloseTunnel(const nTunnel: string): Boolean;
var nStr: string;
begin
  nStr := TunnelOC(nTunnel, True);
  Result := nStr = '';

  if not Result then
    WriteLog(nStr);
  //xxxxxx
end;

//Date: 2014-07-03
//Parm: ͨ����;����
//Desc: �Ƿ�����nTunnelͨ��
procedure TProberManager.EnableTunnel(const nTunnel: string;
  const nEnabled: Boolean);
var nPT: PProberTunnel;
begin
  nPT := GetTunnel(nTunnel);
  if Assigned(nPT) then
    nPT.FEnable := nEnabled;
  //xxxxx
end;

//Date��2014-5-14
//Parm������;��ѯ����;����������
//Desc����ѯnHost���������״̬,����nIn nOut.
function TProberManager.QueryStatus(const nHost: PProberHost;
  var nIn, nOut: TProberIOAddress): string;
var nIdx: Integer;
    nPH: PProberHost;
begin
  for nIdx:=Low(TProberIOAddress) to High(TProberIOAddress) do
  begin
    nIn[nIdx]  := nHost.FInSignalOn;
    nOut[nIdx] := nHost.FInSignalOn;
  end;

  FSyncLock.Enter;
  try
    for nIdx:=FHosts.Count - 1 downto 0 do
    begin
      nPH := FHosts[nIdx];
      //xxxxx

      if GetTickCount - nPH.FStatusL >= 2 * cProber_Query_Interval then
      begin
        Result := Format('���������[ %s ]״̬��ѯ��ʱ.', [nHost.FName]);
        Exit;
      end;

      nIn := nPH.FStatusI;
      nOut := nPH.FStatusO;
      Result := ''; Exit;
    end;
  finally
    FSyncLock.Leave;
  end;

  Result := Format('���������[ %s ]����Ч.', [nHost.FID]);
end;

//Date��2014-5-14
//Parm��ͨ����
//Desc����ѯnTunnel�������Ƿ�ȫ��Ϊ���ź�
function TProberManager.IsTunnelOK(const nTunnel: string): Boolean;
var nIdx,nNum: Integer;
    nPT: PProberTunnel;
begin
  if Trim(nTunnel) = '' then
  begin
    Result := True;
    Exit;
  end; //��ͨ��Ĭ������

  Result := False;
  nPT := GetTunnel(nTunnel);

  if not Assigned(nPT) then
  begin
    WriteLog(Format('ͨ��[ %s ]��Ч.',  [nTunnel]));
    Exit;
  end;

  if not (nPT.FEnable and nPT.FHost.FEnable) then
  begin
    Result := True;
    Exit;
  end;

  nNum := 0;
  for nIdx:=Low(nPT.FIn) to High(nPT.FIn) do
   if nPT.FIn[nIdx] <> cProber_NullASCII then Inc(nNum);
  //xxxxx

  if nNum < 1 then //�������ַ,��ʶ��ʹ��������
  begin
    Result := True;
    Exit;
  end;

  FSyncLock.Enter;
  try
    if GetTickCount - nPT.FHost.FStatusL >= 2 * cProber_Query_Interval then
    begin
      WriteLog(Format('���������[ %s ]״̬��ѯ��ʱ.', [nPT.FHost.FName]));
      Exit;
    end;

    for nIdx:=Low(nPT.FIn) to High(nPT.FIn) do
    begin
      if nPT.FIn[nIdx] = cProber_NullASCII then Continue;
      //invalid addr

      if nPT.FHost.FStatusI[nPT.FIn[nIdx] - 1] = nPT.FHost.FInSignalOn then Exit;
      //ĳ·�������ź�,��Ϊ����δͣ��
    end;

    Result := True;
  finally
    FSyncLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
constructor TProberThread.Create(AOwner: TProberManager; AType: TProberThreadType);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FThreadType := AType;

  FBuffer := TList.Create;   
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cProber_Query_Interval;
end;

destructor TProberThread.Destroy;
begin
  FOwner.ClearCommandList(FBuffer, True);
  FWaiter.Free;
  inherited;
end;

procedure TProberThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TProberThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TProberThread.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FActiveHost := nil;
    try
      Doexecute;
    finally
      with FOwner do
      try
        FSyncLock.Enter;
        //lock

        if Assigned(FActiveHost) then
          FActiveHost.FLocked := False;
        //xxxxx

        if FThreadType = ttActive then
        begin
          if FCommand.Count > 0 then
               FWaiter.Interval := 0
          else FWaiter.Interval := cProber_Query_Interval;
        end; //�̼߳���
      finally
        FSyncLock.Leave;
      end;

      if FBuffer.Count > 0 then
        FOwner.ClearCommandList(FBuffer, False);
      //clear buffer
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Date: 2015-12-06
//Parm: �&�����ͷ
//Desc: ɨ��nActive��ͷ,�����ô���FActiveReader.
procedure TProberThread.ScanActiveHost(const nActive: Boolean);
var nIdx: Integer;
    nHost: PProberHost;
begin
  if nActive then //ɨ����ͷ
  with FOwner do
  begin
    if FHostActive = 0 then
         nIdx := 1
    else nIdx := 0; //��0��ʼΪ����һ��

    while True do
    begin
      if FHostActive >= FHosts.Count then
      begin
        FHostActive := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //ɨ��һ��,��Ч�˳�
      end;

      nHost := FHosts[FHostActive];
      Inc(FHostActive);
      if nHost.FLocked or (not nHost.FEnable) then Continue;

      if nHost.FLastActive > 0 then
      begin
        FActiveHost := nHost;
        FActiveHost.FLocked := True;
        Break;
      end;
    end;
  end else

  with FOwner do //ɨ�費���ͷ
  begin
    if FHostIndex = 0 then
         nIdx := 1
    else nIdx := 0; //��0��ʼΪ����һ��

    while True do
    begin
      if FHostIndex >= FHosts.Count then
      begin
        FHostIndex := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //ɨ��һ��,��Ч�˳�
      end;

      nHost := FHosts[FHostIndex];
      Inc(FHostIndex);
      if nHost.FLocked or (not nHost.FEnable) then Continue;

      if nHost.FLastActive = 0 then
      begin
        FActiveHost := nHost;
        FActiveHost.FLocked := True;
        Break;
      end;
    end;
  end;
end;

procedure TProberThread.DoExecute;
var nIdx: Integer;
    nCmd: PProberTunnelCommand;
begin
  with FOwner do
  try
    FSyncLock.Enter;
    //lock

    if FThreadType = ttAll then
    begin
      ScanActiveHost(False);
      //����ɨ�費���ͷ

      if not Assigned(FActiveHost) then
        ScanActiveHost(True);
      //����ɨ����
    end else

    if FThreadType = ttActive then //ֻɨ��߳�
    begin
      ScanActiveHost(True);
      //����ɨ����ͷ

      if not Assigned(FActiveHost) then
        ScanActiveHost(False);
      //����ɨ�費���
    end;

    if Terminated or (not Assigned(FActiveHost)) then Exit;
    //invalid host

    for nIdx:=Low(FTunnels) to High(FTunnels) do
    with FTunnels[nIdx] do
    begin
      if FHost <> FActiveHost then Continue;
      //not match

      if (FLastOn > 0) and (GetTickCount - FLastOn >= FAutoOFF) then
      begin
        FLastOn := 0;
        TunnelOC(FTunnels[nIdx].FID, True);
      end;
    end; //auto off tunnel-out

    nIdx := 0;
    while nIdx < FCommand.Count do
    begin
      nCmd := FCommand[nIdx];
      if nCmd.FTunnel.FHost = FActiveHost then
      begin
        FBuffer.Add(nCmd);
        FCommand.Delete(nIdx);
      end else Inc(nIdx);
    end;
  finally
    FSyncLock.Leave;
  end;

  with FOwner do
  try
    SendHostCommand(FActiveHost);
    FActiveHost.FLastActive := GetTickCount;
  except
    on E:Exception do
    begin
      FActiveHost.FLastActive := 0;
      //��Ϊ���

      WriteLog(Format('Host:[ %s:%d ] Msg: %s', [FActiveHost.FHost,
        FActiveHost.FPort, E.Message]));
      //xxxxx

      CloseHostConn(FActiveHost);
      //force reconn
    end;
  end;
end;

procedure TProberThread.SendHostCommand(const nHost: PProberHost);
var nStr: string;
    nIdx,nSize: Integer;
    nBuf: TIdBytes;
    nCmd: PProberTunnelCommand;
begin
  if not nHost.FClient.Connected then
    nHost.FClient.Connect;
  //xxxxx
  
  if GetTickCount - nHost.FStatusL >= cProber_Query_Interval - 500 then
  begin
    FillChar(FQueryFrame, cSize_Prober_Control, cProber_NullASCII);
    //init

    with FQueryFrame.FHeader do
    begin
      FBegin  := cProber_Flag_Begin;
      FLength := cProber_Len_Frame;
      FType   := cProber_Frame_QueryIO;
      FExtend := cProber_Query_All;
    end;

    nBuf := RawToBytes(FQueryFrame, cSize_Prober_Control);
    nStr := SendData(nHost, nBuf, cSize_Prober_Control);
    //��ѯ״̬

    if nStr <> '' then
    begin
      WriteLog(nStr);
      Exit;
    end;

    with FQueryFrame do
    try
      FOwner.FSyncLock.Enter;
      BytesToRaw(nBuf, FQueryFrame, cSize_Prober_Control);

      Move(FData[0], nHost.FStatusI[0], cSize_Prober_IOAddr);
      Move(FData[cSize_Prober_IOAddr], nHost.FStatusO[0], cSize_Prober_IOAddr);

      nHost.FStatusL := GetTickCount;
      //����ʱ��
    finally
      FOwner.FSyncLock.Leave;
    end;
  end;

  for nIdx:=FBuffer.Count - 1 downto 0 do
  begin
    nCmd := FBuffer[nIdx];
    if nCmd.FTunnel.FHost <> nHost then Continue;

    if nCmd.FCommand = cProber_Frame_DataForward then
    begin
      nSize := cSize_Prober_Display;
      nBuf := RawToBytes(PProberFrameDataForward(nCmd.FData)^, nSize);
    end else
    begin
      if (nCmd.FTunnel.FLastOn > 0) and
         (PProberFrameControl(nCmd.FData).FHeader.FExtend =
                              nCmd.FTunnel.FHost.FOutSignalOn) then
      begin
        Continue;
        //�����Զ��ر�,�����ֶ��ر�ָ��
      end;

      nSize := cSize_Prober_Control;
      nBuf := RawToBytes(PProberFrameControl(nCmd.FData)^, nSize);
    end;

    nStr := SendData(nHost, nBuf, cSize_Prober_Control);
    if nStr <> '' then
    begin
      WriteLog(nStr);
      Exit;
    end;

    if (nCmd.FTunnel.FAutoOFF > 0) and
       (nCmd.FCommand = cProber_Frame_RelaysOC) then
    begin
      if PProberFrameControl(nCmd.FData).FHeader.FExtend =
                             nCmd.FTunnel.FHost.FOutSignalOff then
        nCmd.FTunnel.FLastOn := GetTickCount;
      //ͨ�����������ʱ��
    end;
  end;
end;

//Date��2014-5-13
//Parm������;��������[in],Ӧ������[out];�����ճ���
//Desc����nHost����nData����,������Ӧ��
function TProberThread.SendData(const nHost: PProberHost; var nData: TIdBytes;
  const nRecvLen: Integer): string;
var nBuf: TIdBytes;
    nIdx,nLen: Integer;
begin
  Result := '';
  nLen := Length(nData);
  ProberVerifyData(nData, nLen, True);
  //������У��

  SetLength(nBuf, nLen);
  CopyTIdBytes(nData, 0, nBuf, 0, nLen);
  //���ݴ���������

  nIdx := 0;
  while nIdx < FOwner.FRetry do
  try
    {$IFDEF DEBUG}
    LogHex(nBuf);
    {$ENDIF}

    Inc(nIdx);
    nHost.FClient.IOHandler.Write(nBuf);
    //send data

    Sleep(120);
    //wait for

    if nRecvLen < 1 then Exit;
    //no data to receive

    nHost.FClient.IOHandler.ReadBytes(nData, nRecvLen, False);
    //read respond
      
    {$IFDEF DEBUG}
    LogHex(nData);
    {$ENDIF}

    nLen := Length(nData);
    if (nLen = nRecvLen) and
       (nData[nLen-1] = ProberVerifyData(nData, nLen, False)) then Exit;
    //У��ͨ��

    if nIdx = FOwner.FRetry then
    begin
      Result := 'δ��[ %s:%s.%d ]�յ���ͨ��У���Ӧ������.';
      Result := Format(Result, [nHost.FName, nHost.FHost, nHost.FPort]);
    end;
  except
    on E: Exception do
    begin
      FOwner.CloseHostConn(nHost);
      //�Ͽ�����

      Inc(nIdx);
      if nIdx >= FOwner.FRetry then
        raise;
      //xxxxx
    end;
  end;
end;

initialization
  gProberManager := nil;
finalization
  FreeAndNil(gProberManager);
end.
