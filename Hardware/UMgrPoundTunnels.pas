{*******************************************************************************
  ����: dmzn@163.com 2014-06-11
  ����: ��վͨ��������
*******************************************************************************}
unit UMgrPoundTunnels;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, CPort, CPortTypes, IdComponent,
  IdTCPConnection, IdTCPClient, IdGlobal, IdSocketHandle, NativeXml, ULibFun,
  UWaitItem, USysLoger;

const
  cPTMaxCameraTunnel = 5;
  //֧�ֵ������ͨ����

  cPTWait_Short = 320;
  cPTWait_Long  = 2 * 1000; //����ͨѶʱˢ��Ƶ��

type
  TPoundTunnelManager = class;
  TPoundTunnelConnector = class;

  PPTPortItem = ^TPTPortItem;
  PPTCameraItem = ^TPTCameraItem;
  PPTTunnelItem = ^TPTTunnelItem;

  TOnTunnelDataEvent = procedure (const nValue: Double) of object;
  TOnTunnelDataEventEx = procedure (const nValue: Double;
    const nPort: PPTPortItem) of object;
  //�¼�����
  
  TPTTunnelItem = record
    FID: string;                     //��ʶ
    FName: string;                   //����
    FPort: PPTPortItem;              //ͨѶ�˿�
    FProber: string;                 //������
    FReader: string;                 //�ſ���ͷ
    FUserInput: Boolean;             //�ֹ�����
    FAutoWeight: Boolean;            //�Զ�����

    FFactoryID: string;              //������ʶ
    FCardInterval: Integer;          //�������
    FSampleNum: Integer;             //��������
    FSampleFloat: Integer;           //��������
    FOptions: TStrings;              //���Ӳ���

    FCamera: PPTCameraItem;          //�����
    FCameraTunnels: array[0..cPTMaxCameraTunnel-1] of Byte;
                                     //����ͨ��                                     
    FOnData: TOnTunnelDataEvent;
    FOnDataEx:TOnTunnelDataEventEx;  //�����¼�
    FOldEventTunnel: PPTTunnelItem;  //ԭ����ͨ��
  end;

  TPTCameraItem = record
    FID: string;                     //��ʶ
    FType: string;                   //����
    FHost: string;                   //������ַ
    FPort: Integer;                  //�˿�
    FUser: string;                   //�û���
    FPwd: string;                    //����
    FPicSize: Integer;               //ͼ���С
    FPicQuality: Integer;            //ͼ������
  end;

  TPTConnType = (ctTCP, ctCOM);
  //��·����: ����,����
         
  TPTPortItem = record
    FID: string;                     //��ʶ
    FName: string;                   //����
    FType: string;                   //����
    FConn: TPTConnType;              //��·
    FPort: string;                   //�˿�
    FRate: TBaudRate;                //������
    FDatabit: TDataBits;             //����λ
    FStopbit: TStopBits;             //��ͣλ
    FParitybit: TParityBits;         //У��λ
    FParityCheck: Boolean;           //����У��
    FCharBegin: Char;                //��ʼ���
    FCharEnd: Char;                  //�������
    FPackLen: Integer;               //���ݰ���
    FSplitTag: string;               //�ֶα�ʶ
    FSplitPos: Integer;              //��Ч��
    FInvalidBegin: Integer;          //���׳���
    FInvalidEnd: Integer;            //��β����
    FDataMirror: Boolean;            //��������
    FDataEnlarge: Single;            //�Ŵ���
    FMaxValue: Double;               //��վ����
    FMaxValid: Double;               //����ȡֵ
    FMinValue: Double;               //��վ����

    FHostIP: string;
    FHostPort: Integer;              //������·
    FClient: TIdTCPClient;           //�׽���
    FClientActive: Boolean;          //��·����

    FCOMPort: TComPort;              //��д����
    FCOMBuff: string;                //ͨѶ����
    FCOMData: string;                //ͨѶ����
    FCOMDataEx: string;              //ԭʼ����
    
    FEventTunnel: PPTTunnelItem;     //����ͨ��
    FOptions: TStrings;              //���Ӳ���
  end;

  TPoundTunnelConnector = class(TThread)
  private
    FOwner: TPoundTunnelManager;
    //ӵ����
    FActiveClient: TIdTCPClient;
    FActivePort: PPTPortItem;
    FActiveTunnel: PPTTunnelItem;
    //��ǰͨ��
    FWaiter: TWaitObject;
    //�ȴ�����
  protected
    procedure Execute; override;
    //ִ���߳�
    function ReadPound: Boolean;
    //��ȡ����
    procedure DoSyncEvent;
    //�����¼�
  public
    constructor Create(AOwner: TPoundTunnelManager);
    destructor Destroy; override;
    //�����ͷ�
    procedure WakupMe;
    //�����߳�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TPoundTunnelManager = class(TObject)
  private
    FPorts: TList;
    //�˿��б�
    FCameras: TList;
    //�����
    FTunnels: TList;
    //ͨ���б�
    FStrList: TStrings;
    //�ַ��б�
    FSyncLock: TCriticalSection;
    //ͬ������
    FConnector: TPoundTunnelConnector;
    //�׽�����·
  protected
    procedure ClearList(const nFree: Boolean);
    //������Դ
    function ParseWeight(const nPort: PPTPortItem): Boolean;
    procedure OnComData(Sender: TObject; Count: Integer);
    //��ȡ����
    procedure DisconnectClient(const nClient: TIdTCPClient);
    //�ر���·
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��ȡ����
    function ActivePort(const nTunnel: string; const nEvent: TOnTunnelDataEvent;
      const nOpenPort: Boolean = False;
      const nEventEx: TOnTunnelDataEventEx = nil): Boolean;
    procedure ClosePort(const nTunnel: string);
    //��ͣ�˿�
    function GetPort(const nID: string): PPTPortItem;
    function GetCamera(const nID: string): PPTCameraItem;
    function GetTunnel(const nID: string): PPTTunnelItem;
    //��������
    property Tunnels: TList read FTunnels;
    //�������
  end;

var
  gPoundTunnelManager: TPoundTunnelManager = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TPoundTunnelManager, '��վͨ������', nEvent);
end;

constructor TPoundTunnelManager.Create;
begin
  FConnector := nil;
  FPorts := TList.Create;
  FCameras := TList.Create;

  FTunnels := TList.Create;
  FStrList := TStringList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TPoundTunnelManager.Destroy;
begin
  if Assigned(FConnector) then
    FConnector.StopMe;
  //xxxxx
  
  ClearList(True);
  FStrList.Free;
  FSyncLock.Free;
  inherited;
end;

//Date: 2014-06-12
//Parm: �Ƿ��ͷ�
//Desc: �����б���Դ
procedure TPoundTunnelManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
    nPort: PPTPortItem;
    nTunnel: PPTTunnelItem;
begin
  for nIdx:=FPorts.Count - 1 downto 0 do
  begin
    nPort := FPorts[nIdx];
    if Assigned(nPort.FCOMPort) then
    begin
      nPort.FCOMPort.Close;
      nPort.FCOMPort.Free;
    end;

    if Assigned(nPort.FClient) then
    begin
      nPort.FClient.Disconnect;
      nPort.FClient.Free;
    end;

    FreeAndNil(nPort.FOptions);
    Dispose(nPort);
    FPorts.Delete(nIdx);
  end;

  for nIdx:=FCameras.Count - 1 downto 0 do
  begin
    Dispose(PPTCameraItem(FCameras[nIdx]));
    FCameras.Delete(nIdx);
  end;

  for nIdx:=FTunnels.Count - 1 downto 0 do
  begin
    nTunnel := FTunnels[nIdx];
    FreeAndNil(nTunnel.FOptions);
    
    Dispose(nTunnel);
    FTunnels.Delete(nIdx);
  end;

  if nFree then
  begin
    FPorts.Free;
    FCameras.Free;
    FTunnels.Free;
  end;
end;

//Date: 2016-11-26
//Parm: �׽���
//Desc: ����nClient��·
procedure TPoundTunnelManager.DisconnectClient(const nClient: TIdTCPClient);
begin
  if Assigned(nClient) then
  begin
    nClient.Disconnect;
    if Assigned(nClient.IOHandler) then
      nClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

//Date��2014-6-18
//Parm��ͨ��;��ַ�ַ���,����: 1,2,3
//Desc����nStr��,����nTunnel.FCameraTunnels�ṹ��
procedure SplitCameraTunnel(const nTunnel: PPTTunnelItem; const nStr: string);
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
      nTunnel.FCameraTunnels[nIdx] := MAXBYTE;
    //Ĭ��ֵ

    SplitStr(nStr, nList, 0 , ',');
    if nList.Count < 1 then Exit;

    nIdx := nList.Count - 1;
    if nIdx > High(nTunnel.FCameraTunnels) then
      nIdx := High(nTunnel.FCameraTunnels);
    //���߽�

    while nIdx>=Low(nTunnel.FCameraTunnels) do
    begin
      nTunnel.FCameraTunnels[nIdx] := StrToInt(nList[nIdx]);
      Dec(nIdx);
    end;
  finally
    nList.Free;
  end;
end;

//Date: 2014-06-12
//Parm: �����ļ�
//Desc: ����nFile����
procedure TPoundTunnelManager.LoadConfig(const nFile: string);
var nStr: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
    nPort: PPTPortItem;
    nCamera: PPTCameraItem;
    nTunnel: PPTTunnelItem;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.FindNode('ports');

    for nIdx:=0 to nNode.NodeCount - 1 do
    with nNode.Nodes[nIdx] do
    begin
      New(nPort);
      FPorts.Add(nPort);
      FillChar(nPort^, SizeOf(TPTPortItem), #0);

      with nPort^ do
      begin
        FID := AttributeByName['id'];
        FName := AttributeByName['name'];
        FType := NodeByName('type').ValueAsString;

        nTmp := FindNode('conn');
        if Assigned(nTmp) then
             nStr := nTmp.ValueAsString
        else nStr := 'com';

        if CompareText('tcp', nStr) = 0 then
             nPort.FConn := ctTCP
        else nPort.FConn := ctCOM;

        FPort := NodeByName('port').ValueAsString;
        FRate := StrToBaudRate(NodeByName('rate').ValueAsString);
        FDatabit := StrToDataBits(NodeByName('databit').ValueAsString);
        FStopbit := StrToStopBits(NodeByName('stopbit').ValueAsString);
        FParitybit := StrToParity(NodeByName('paritybit').ValueAsString);
        FParityCheck := NodeByName('paritycheck').ValueAsString = 'Y';

        FCharBegin := Char(StrToInt(NodeByName('charbegin').ValueAsString));
        FCharEnd := Char(StrToInt(NodeByName('charend').ValueAsString));
        FPackLen := NodeByName('packlen').ValueAsInteger;

        nTmp := FindNode('invalidlen');
        if Assigned(nTmp) then //ֱ��ָ����ȡ����
        begin
          FInvalidBegin := 0;
          FInvalidEnd := nTmp.ValueAsInteger;
        end else
        begin
          FInvalidBegin := NodeByName('invalidbegin').ValueAsInteger;
          FInvalidEnd := NodeByName('invalidend').ValueAsInteger;
        end;

        FSplitTag := Char(StrToInt(NodeByName('splittag').ValueAsString));
        FSplitPos := NodeByName('splitpos').ValueAsInteger;
        FDataMirror := NodeByName('datamirror').ValueAsInteger = 1;
        FDataEnlarge := NodeByName('dataenlarge').ValueAsFloat;

        nTmp := FindNode('maxval');
        if Assigned(nTmp) and (nTmp.AttributeByName['enable'] = 'y') then
        begin
          FMaxValue := nTmp.ValueAsFloat;
          FMaxValid := StrToFloat(nTmp.AttributeByName['valid']);

          FMaxValue := Float2Float(FMaxValue, 100, False);
          FMaxValid := Float2Float(FMaxValid, 100, False);
        end else
        begin
          FMaxValue := 0;
          FMaxValid := 0;
        end;

        nTmp := FindNode('minval');
        if Assigned(nTmp) and (nTmp.AttributeByName['enable'] = 'y') then
             FMinValue := Float2Float(nTmp.ValueAsFloat, 100, False)
        else FMinValue :=0;

        nTmp := FindNode('hostip');
        if Assigned(nTmp) then
          FHostIP := nTmp.ValueAsString;
        //xxxxx

        nTmp := FindNode('hostport');
        if Assigned(nTmp) then
          FHostPort := nTmp.ValueAsInteger;
        //xxxxx

        nTmp := FindNode('options');
        if Assigned(nTmp) then
        begin
          FOptions := TStringList.Create;
          SplitStr(nTmp.ValueAsString, FOptions, 0, ';');
        end else FOptions := nil;
      end;

      nPort.FClient := nil;
      nPort.FClientActive := False;
      //Ĭ������·
      
      nPort.FCOMPort := nil;
      //Ĭ�ϲ�����
      nPort.FEventTunnel := nil;
    end;

    nNode := nXML.Root.FindNode('cameras');
    if Assigned(nNode) then
    begin
      for nIdx:=0 to nNode.NodeCount - 1 do
      with nNode.Nodes[nIdx] do
      begin
        New(nCamera);
        FCameras.Add(nCamera);
        FillChar(nCamera^, SizeOf(TPTCameraItem), #0);

        with nCamera^ do
        begin
          FID := AttributeByName['id'];
          FHost := NodeByName('host').ValueAsString;
          FPort := NodeByName('port').ValueAsInteger;
          FUser := NodeByName('user').ValueAsString;
          FPwd := NodeByName('password').ValueAsString;
          FPicSize := NodeByName('picsize').ValueAsInteger;
          FPicQuality := NodeByName('picquality').ValueAsInteger;
        end;

        nTmp := FindNode('type');
        if Assigned(nTmp) then
             nCamera.FType := nTmp.ValueAsString
        else nCamera.FType := 'HKV';
      end;
    end;

    nNode := nXML.Root.FindNode('tunnels');
    for nIdx:=0 to nNode.NodeCount - 1 do
    with nNode.Nodes[nIdx] do
    begin
      New(nTunnel);
      FTunnels.Add(nTunnel);
      FillChar(nTunnel^, SizeOf(TPTTunnelItem), #0);

      nStr := NodeByName('port').ValueAsString;
      nTunnel.FPort := GetPort(nStr);
      if not Assigned(nTunnel.FPort) then
        raise Exception.Create(Format('ͨ��[ %s.Port ]��Ч.', [nTunnel.FName]));
      //xxxxxx

      with nTunnel^ do
      begin
        FID := AttributeByName['id'];
        FName := AttributeByName['name'];
        FProber := NodeByName('prober').ValueAsString;
        FReader := NodeByName('reader').ValueAsString;
        FUserInput := NodeByName('userinput').ValueAsString = 'Y';

        FFactoryID := NodeByName('factory').ValueAsString;
        FCardInterval := NodeByName('cardInterval').ValueAsInteger;
        FSampleNum := NodeByName('sampleNum').ValueAsInteger;
        FSampleFloat := NodeByName('sampleFloat').ValueAsInteger;

        nTmp := FindNode('options');
        if Assigned(nTmp) then
        begin
          FOptions := TStringList.Create;
          SplitStr(nTmp.ValueAsString, FOptions, 0, ';');
        end else FOptions := nil;

        nTmp := FindNode('autoweight');
        if Assigned(nTmp) then
             FAutoWeight := nTmp.ValueAsString = 'Y'
        else FAutoWeight := False; //�Ϸ�����,������Ҫ��

        nTmp := FindNode('camera');
        if Assigned(nTmp) then
        begin
          nStr := nTmp.AttributeByName['id'];
          FCamera := GetCamera(nStr);
          SplitCameraTunnel(nTunnel, nTmp.ValueAsString);
        end else
        begin
          FCamera := nil;
          //no camera
        end;
      end;
    end;
  finally
    nXML.Free;
  end;   
end;

//------------------------------------------------------------------------------
//Desc: ������ʶΪnID�Ķ˿�
function TPoundTunnelManager.GetPort(const nID: string): PPTPortItem;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FPorts.Count - 1 downto 0 do
  if CompareText(nID, PPTPortItem(FPorts[nIdx]).FID) = 0 then
  begin
    Result := FPorts[nIdx];
    Exit;
  end;
end;

//Desc: ������ʶΪnID�������
function TPoundTunnelManager.GetCamera(const nID: string): PPTCameraItem;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FCameras.Count - 1 downto 0 do
  if CompareText(nID, PPTCameraItem(FCameras[nIdx]).FID) = 0 then
  begin
    Result := FCameras[nIdx];
    Exit;
  end;
end;

//Desc: ������ʶΪnID��ͨ��
function TPoundTunnelManager.GetTunnel(const nID: string): PPTTunnelItem;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FTunnels.Count - 1 downto 0 do
  if CompareText(nID, PPTTunnelItem(FTunnels[nIdx]).FID) = 0 then
  begin
    Result := FTunnels[nIdx];
    Exit;
  end;
end;

//Date: 2014-06-11
//Parm: ͨ����;�����¼�
//Desc: ����nTunnelͨ����д�˿�
function TPoundTunnelManager.ActivePort(const nTunnel: string;
  const nEvent: TOnTunnelDataEvent; const nOpenPort: Boolean;
  const nEventEx: TOnTunnelDataEventEx): Boolean;
var nStr: string;
    nPT: PPTTunnelItem;
begin
  Result := False;
  //xxxxx

  FSyncLock.Enter;
  try
    nPT := GetTunnel(nTunnel);
    if not Assigned(nPT) then Exit;

    nPT.FOnData := nEvent;
    nPT.FOnDataEx := nEventEx;
    
    nPT.FOldEventTunnel := nPT.FPort.FEventTunnel;
    nPT.FPort.FEventTunnel := nPT;
    
    if nPT.FPort.FConn = ctTCP then
    begin
      if not Assigned(nPT.FPort.FClient) then
      begin
        nPT.FPort.FClient := TIdTCPClient.Create;
        //new socket
        
        with nPT.FPort.FClient do
        begin
          Host := nPT.FPort.FHostIP;
          Port := nPT.fPort.FHostPort;
          
          ReadTimeout := 5 * 1000;
          ConnectTimeout := 5 * 1000;
        end;
      end;

      with nPT.FPort.FClient do
      try
        if not Connected then
          Connect;
        //��������
      except
        nStr := '���ӵذ�[ %s:%d ]ʧ��';
        nStr := Format(nStr, [nPT.FPort.FHostIP, nPT.FPort.FHostPort]);

        raise Exception.Create(nStr);
        Exit;
      end;

      if not Assigned(FConnector) then
        FConnector := TPoundTunnelConnector.Create(Self);
      FConnector.WakupMe; //����������
                                  
      nPT.FPort.FClientActive := True;
      Exit;
    end; //�׽�����·

    if not Assigned(nPT.FPort.FCOMPort) then
    begin
      nPT.FPort.FCOMPort := TComPort.Create(nil);
      with nPT.FPort.FCOMPort do
      begin
        Tag := FPorts.IndexOf(nPT.FPort);
        OnRxChar := OnComData;

        with Timeouts do
        begin
          ReadTotalConstant := 100;
          ReadTotalMultiplier := 10;
        end;

        with Parity do
        begin
          Bits := nPT.FPort.FParitybit;
          Check := nPT.FPort.FParityCheck;
        end;

        Port := nPT.FPort.FPort;
        BaudRate := nPT.FPort.FRate;
        DataBits := nPT.FPort.FDatabit;
        StopBits := nPT.FPort.FStopbit;
      end;
    end;

    try
      if nOpenPort then
        nPT.FPort.FCOMPort.Open;
      //�����˿�
    except
      on E: Exception do
      begin
        WriteLog(E.Message);
      end;
    end;

    Result := True;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2014-06-11
//Parm: ͨ����
//Desc: �ر�nTunnelͨ����д�˿�
procedure TPoundTunnelManager.ClosePort(const nTunnel: string);
var nPT: PPTTunnelItem;
begin
  FSyncLock.Enter;
  try
    nPT := GetTunnel(nTunnel);
    if not Assigned(nPT) then Exit;

    nPT.FPort.FClientActive := False;
    nPT.FOnData := nil;

    if nPT.FPort.FEventTunnel = nPT then
    begin
      nPT.FPort.FEventTunnel := nPT.FOldEventTunnel;
      //��ԭ����ͨ��

      if Assigned(nPT.FPort.FCOMPort) then
        nPT.FPort.FCOMPort.Close;
      //ͨ��������ر�

      DisconnectClient(nPT.FPort.FClient);
      //�ر���·
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2014-06-11
//Desc: ��ȡ����
procedure TPoundTunnelManager.OnComData(Sender: TObject; Count: Integer);
var nVal: Double;
    nPort: PPTPortItem;
begin
  with TComPort(Sender) do
  begin
    nPort := FPorts[Tag];
    ReadStr(nPort.FCOMBuff, Count);
  end;

  FSyncLock.Enter;
  try
    if not (Assigned(nPort.FEventTunnel) and
            Assigned(nPort.FEventTunnel.FOnData)) then Exit;
    //�޽����¼�

    nPort.FCOMData := nPort.FCOMData + nPort.FCOMBuff;
    //�ϲ�����

    try
      if ParseWeight(nPort) then
      begin
        nVal := StrToFloat(nPort.FCOMData) * nPort.FDataEnlarge;
        nPort.FEventTunnel.FOnData(nVal);
        nPort.FCOMData := '';

        if Assigned(nPort.FEventTunnel.FOnDataEx) then
          nPort.FEventTunnel.FOnDataEx(nVal, nPort);
        //xxxxx
      end;
    except
      on E: Exception do
      begin
        WriteLog(E.Message);
      end;
    end;
  finally
    FSyncLock.Leave;
  end;

  if Length(nPort.FCOMData) >= 5 * nPort.FPackLen then
  begin
    System.Delete(nPort.FCOMData, 1, 4 * nPort.FPackLen);
    WriteLog('��Ч���ݹ���,�Ѳü�.')
  end;
end;

//Date: 2014-06-12
//Parm: �˿�
//Desc: ����nPort�ϵĳ�������
function TPoundTunnelManager.ParseWeight(const nPort: PPTPortItem): Boolean;
var nIdx,nPos,nEnd: Integer;
    nVal: Double;
begin
  Result := False;
  if Length(nPort.FCOMData) < nPort.FPackLen then Exit;
  //���ݲ�����������

  nEnd := -1;
  for nIdx:=Length(nPort.FCOMData) downto 1 do
  begin
    if (nEnd < 1) and (nPort.FCOMData[nIdx] = nPort.FCharEnd) then
    begin
      nEnd := nIdx;
      Continue;
    end;

    if (nEnd < 1) or (nPort.FCOMData[nIdx] <> nPort.FCharBegin) then Continue;
    //�����ݽ������,���ǿ�ʼ���

    nPort.FCOMData := Copy(nPort.FCOMData, nIdx + 1, nEnd - nIdx - 1);
    //�������ͷ������
    nPort.FCOMDataEx := nPort.FCOMData;

    if nPort.FSplitPos > 0 then
    begin
      SplitStr(nPort.FCOMData, FStrList, 0, nPort.FSplitTag);
      //�������

      for nPos:=FStrList.Count - 1 downto 0 do
      begin
        FStrList[nPos] := Trim(FStrList[nPos]);
        if FStrList[nPos] = '' then FStrList.Delete(nPos);
      end; //��������

      if FStrList.Count < nPort.FSplitPos then
      begin
        nPort.FCOMData := '';
        Exit;
      end; //�ֶ�����Խ��

      nPort.FCOMData := FStrList[nPort.FSplitPos - 1];
      //��Ч����
    end;

    if nPort.FInvalidBegin > 0 then
      System.Delete(nPort.FCOMData, 1, nPort.FInvalidBegin);
    //�ײ���Ч����

    if nPort.FInvalidEnd > 0 then
      System.Delete(nPort.FCOMData, Length(nPort.FCOMData)-nPort.FInvalidEnd+1,
                    nPort.FInvalidEnd);
    //β����Ч����

    if nPort.FDataMirror then
      nPort.FCOMData := MirrorStr(nPort.FCOMData);
    //���ݷ�ת

    nPort.FCOMData := Trim(nPort.FCOMData);
    Result := IsNumber(nPort.FCOMData, True);

    if Result and (nPort.FMaxValue > 0) then
    begin
      nVal := StrToFloat(nPort.FCOMData);
      if FloatRelation(nVal, nPort.FMaxValue, rtGE, 1000) then
        nPort.FCOMData := FloatToStr(nPort.FMaxValid);
      //����ȡ��Чֵ
    end;

    Exit;
    //end loop
  end;
end;

//------------------------------------------------------------------------------
constructor TPoundTunnelConnector.Create(AOwner: TPoundTunnelManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cPTWait_Short;
end;

destructor TPoundTunnelConnector.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TPoundTunnelConnector.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TPoundTunnelConnector.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TPoundTunnelConnector.Execute;
var nIdx: Integer;
    nTunnel: PPTTunnelItem;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    with FOwner do
    begin
      FSyncLock.Enter;
      try
        for nIdx:=FTunnels.Count - 1 downto 0 do
        begin
          nTunnel := FTunnels[nIdx];
          if not nTunnel.FPort.FClientActive then Continue;

          FActiveTunnel := nTunnel;
          FActivePort   := nTunnel.FPort;
          FActiveClient := nTunnel.FPort.FClient;

          FSyncLock.Leave; //�ⲿ�����¼�          
          try
            ReadPound;
          finally
            FSyncLock.Enter;
          end;
        end;
      finally
        FSyncLock.Leave;
      end;
    end;
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
      Sleep(500);
    end;
  end; 
end;

//Desc: ��ȡ����
function TPoundTunnelConnector.ReadPound: Boolean;
var nBuf: TIdBytes;
begin
  Result := False;
  try
    if not FActiveClient.Connected then
      FActiveClient.Connect;
    //xxxxx
    
    with FActiveClient do
    begin
      if IOHandler.InputBuffer.Size < 1 then Exit;
      IOHandler.ReadBytes(nBuf, IOHandler.InputBuffer.Size, False);
      //�׽�������
                         
      FActivePort.FCOMBuff := BytesToString(nBuf);
      FActivePort.FCOMData := FActivePort.FCOMData + FActivePort.FCOMBuff;
      //���ݺϲ�
    end;

    if not FOwner.ParseWeight(FActiveTunnel.FPort) then
    begin
      if Length(FActivePort.FCOMData) >= 5 * FActivePort.FPackLen then
      begin
        System.Delete(FActivePort.FCOMData, 1, 4 * FActivePort.FPackLen);
        WriteLog('��Ч���ݹ���,�Ѳü�.')
      end;

      Exit;
    end;

    Synchronize(DoSyncEvent);
    Result := True;
  except
    FOwner.DisconnectClient(FActiveClient);
    //�ر���·
    raise;
  end;
end;

//Desc: �����������¼�
procedure TPoundTunnelConnector.DoSyncEvent;
var nVal: Double;
begin
  if Assigned(FActivePort.FEventTunnel) and
     Assigned(FActivePort.FEventTunnel.FOnData) then
  begin
    nVal := StrToFloat(FActivePort.FCOMData) * FActivePort.FDataEnlarge;
    //pound data

    FActiveTunnel.FOnData(nVal);
    FActiveTunnel.FPort.FCOMData := '';

    if Assigned(FActiveTunnel.FOnDataEx) then
      FActiveTunnel.FOnDataEx(nVal, FActivePort);
    //xxxxx
  end;
end;

initialization
  gPoundTunnelManager := nil;
finalization
  FreeAndNil(gPoundTunnelManager);
end.
