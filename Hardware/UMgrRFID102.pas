{*******************************************************************************
  ����: dmzn@163.com 2014-10-24
  ����: �������пƻ���Ƽ����޹�˾ RFID102��ȡ������
*******************************************************************************}
unit UMgrRFID102;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, IdTCPClient, IdGlobal,
  UWaitItem, USysLoger, ULibFun, UMgrRFID102_Head;

type
  PRFIDSetRelay = ^TRFIDSetRelay;
  TRFIDSetRelay = record
    FBase      : TRFIDReaderCmd;
    FReaderID  : string;
  end;

const
  cHYReader_Wait_Short     = 150;
  cHYReader_Wait_Long      = 2 * 1000;
  cHYReader_MaxThread      = 10;
  cHYReader_ConnectRelay   = $03;  //�պϼ̵���
  cHYReader_DisConnRelay   = $00;  //�Ͽ��̵���
  cHYReader_Sleep_Short    = 10;   //SOCKET ���

type
  THYReaderVType = (rt900, rt02n);
  //�����ͷ����: 900m,02n

  PHYReaderItem = ^THYReaderItem;
  THYReaderItem = record
    FID     : string;          //��ͷ��ʶ
    FHost   : string;          //��ַ
    FPort   : Integer;         //�˿�

    FCard   : string;          //����
    FTunnel : string;          //ͨ����
    FEnable : Boolean;         //�Ƿ�����
    FLocked : Boolean;         //�Ƿ�����
    FLastActive: Int64;        //�ϴλ

    FVirtual: Boolean;         //�����ͷ
    FVReader: string;          //��ͷ��ʶ
    FVRGroup: string;          //��ͷ����
    FVType  : THYReaderVType;  //��������

    FKeepOnce: Integer;        //���α���
    FKeepPeer: Boolean;        //����ģʽ
    FKeepLast: Int64;          //�ϴλ
    FClient : TIdTCPClient;    //ͨ����·

    FCardLength: Integer;      //���ų���
    FCardPrefix: TStrings;     //ǰ׺����
  end;

  THYReaderThreadType = (ttAll, ttActive);
  //�߳�ģʽ: ȫ��;ֻ���

  THYReaderManager = class;
  THYRFIDReader = class(TThread)
  private
    FOwner: THYReaderManager;
    //ӵ����
    FEPCList: TStrings;
    //���ӱ�ǩ
    FWaiter: TWaitObject;
    //�ȴ�����
    FActiveReader: PHYReaderItem;
    //��ǰ��ͷ
    FThreadType: THYReaderThreadType;
    //�߳�ģʽ
    FSendItem,FRecvItem: TRFIDReaderCmd;
    //����&����ָ��
  protected
    procedure DoExecute;
    procedure Execute; override;
    //ִ���߳�
    procedure ScanActiveReader(const nActive: Boolean);
    //ɨ�����
    function ReadCard(const nReader: PHYReaderItem): Boolean;
    //����Ƭ
    function IsCardValid(const nCard: string; const nReader: PHYReaderItem): Boolean;
    //У�鿨��
    procedure DoReaderCommand;
    //���������ָ��
  public
    constructor Create(AOwner: THYReaderManager; AType: THYReaderThreadType);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  //----------------------------------------------------------------------------
  THYReaderProc = procedure (const nItem: PHYReaderItem);
  THYReaderEvent = procedure (const nItem: PHYReaderItem) of Object;

  THYReaderManager = class(TObject)
  private
    FEnable: Boolean;
    //�Ƿ�����
    FMonitorCount: Integer;
    FThreadCount: Integer;
    //�����߳�
    FReaderIndex: Integer;
    FReaderActive: Integer;
    //��ͷ����
    FReaders: TList;
    //��ͷ�б�
    FBuffData: TList;
    //��ʱ����
    FSyncLock: TCriticalSection;
    //ͬ������
    FThreads: array[0..cHYReader_MaxThread-1] of THYRFIDReader;
    //��������
    FOnProc: THYReaderProc;
    FOnEvent: THYReaderEvent;
    //�¼�����
  protected
    procedure ClearReaders(const nFree: Boolean);
    //������Դ
    procedure CloseReader(const nReader: PHYReaderItem);
    //�رն�ͷ
    procedure ClearBuffer(const nList: TList);
    //������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��������
    procedure StartReader;
    procedure StopReader;
    //��ͣ��ͷ
    procedure ActiveRelay(const nReader: string; nActive: Boolean=True);
    //��ͣ�̵���
    procedure OpenDoor(const nReader: string);
    //�򿪵�բ
    property OnCardProc: THYReaderProc read FOnProc write FOnProc;
    property OnCardEvent: THYReaderEvent read FOnEvent write FOnEvent;
    //�������
  end;

var
  gHYReaderManager: THYReaderManager = nil;
  //ȫ��ʹ��
  
implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(THYReaderManager, '���������', nEvent);
end;

constructor THYReaderManager.Create;
var nIdx: Integer;
begin
  FEnable := False;
  FThreadCount := 1;
  FMonitorCount := 1;  

  for nIdx:=Low(FThreads) to High(FThreads) do
    FThreads[nIdx] := nil;
  //xxxxx
    
  FReaders := TList.Create;
  FBuffData := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor THYReaderManager.Destroy;
begin
  StopReader;
  ClearReaders(True);
  ClearBuffer(FBuffData);
  
  FBuffData.Free;
  FSyncLock.Free;
  inherited;
end;

procedure THYReaderManager.ClearBuffer(const nList: TList);
var nIdx: Integer;
    nBase: PRFIDSetRelay;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    nBase := nList[nIdx];
    Dispose(PRFIDSetRelay(nBase));
    nList.Delete(nIdx);
  end;
end;

procedure THYReaderManager.ClearReaders(const nFree: Boolean);
var nIdx: Integer;
    nItem: PHYReaderItem;
begin
  for nIdx:=FReaders.Count - 1 downto 0 do
  begin
    nItem := FReaders[nIdx];
    nItem.FClient.Free;
    nItem.FClient := nil;

    nItem.FCardPrefix.Free;
    nItem.FCardPrefix := nil;
    
    Dispose(nItem);
    FReaders.Delete(nIdx);
  end;

  if nFree then
    FReaders.Free;
  //xxxxx
end;

procedure THYReaderManager.StartReader;
var nIdx,nNum: Integer;
    nType: THYReaderThreadType;
begin
  if not FEnable then Exit;
  FReaderIndex := 0;
  FReaderActive := 0;

  nNum := 0;
  //init
  
  for nIdx:=Low(FThreads) to High(FThreads) do
  begin
    if (nNum >= FThreadCount) or
       (nNum > FReaders.Count) then Exit;
    //�̲߳��ܳ���Ԥ��ֵ,�򲻶����ͷ����

    if nNum < FMonitorCount then
         nType := ttAll
    else nType := ttActive;

    if not Assigned(FThreads[nIdx]) then
      FThreads[nIdx] := THYRFIDReader.Create(Self, nType);
    Inc(nNum);
  end;
end;

procedure THYReaderManager.CloseReader(const nReader: PHYReaderItem);
begin
  if Assigned(nReader) and Assigned(nReader.FClient) then
  begin 
    nReader.FClient.Disconnect;
    if Assigned(nReader.FClient.IOHandler) then
      nReader.FClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

procedure THYReaderManager.StopReader;
var nIdx: Integer;
begin
  for nIdx:=Low(FThreads) to High(FThreads) do
   if Assigned(FThreads[nIdx]) then
    FThreads[nIdx].Terminate;
  //�����˳����

  for nIdx:=Low(FThreads) to High(FThreads) do
  begin
    if Assigned(FThreads[nIdx]) then
      FThreads[nIdx].StopMe;
    FThreads[nIdx] := nil;
  end;

  FSyncLock.Enter;
  try
    for nIdx:=FReaders.Count - 1 downto 0 do
      CloseReader(FReaders[nIdx]);
    //�رն�ͷ
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: ��nReader��ͷִ�м̵�������
procedure THYReaderManager.ActiveRelay(const nReader: string; nActive: Boolean);
var nIdx: Integer;
    nData: string;
    nPtr: PRFIDSetRelay;
    nBase: TRFIDReaderCmd;
begin
  FSyncLock.Enter;
  try
    if nActive then
         nData := Chr(cHYReader_ConnectRelay)
    else nData := Chr(cHYReader_DisConnRelay);

    for nIdx:=FBuffData.Count - 1 downto 0 do
    begin
      nBase := PRFIDSetRelay(FBuffData[nIdx]).FBase;
      if nBase.FCmd <> tCmd_Reader_SetReLay then Exit;

      nPtr := PRFIDSetRelay(FBuffData[nIdx]);   
      if (CompareText(nReader, nPtr.FReaderID) = 0) and nActive and
         (nPtr.FBase.FData = nData) then Exit;
      //ͬһ��������������ָ���һ��   
    end;

    New(nPtr);
    FBuffData.Add(nPtr);

    nPtr.FBase.FCmd := tCmd_Reader_SetReLay;
    nPtr.FBase.FAddr:= Chr($00);
    nPtr.FBase.FData:= nData;
    nPtr.FReaderID := nReader;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: ��nReader��ͷִ��̧�˲���
procedure THYReaderManager.OpenDoor(const nReader: string);
begin
  ActiveRelay(nReader);
  Sleep(500);
  ActiveRelay(nReader, False);
end;

procedure THYReaderManager.LoadConfig(const nFile: string);
var nIdx: Integer;
    nXML: TNativeXml;  
    nReader: PHYReaderItem;
    nRoot,nNode,nTmp: TXmlNode;
begin
  FEnable := False;
  if not FileExists(nFile) then Exit;

  nXML := nil;
  try
    nXML := TNativeXml.Create;
    nXML.LoadFromFile(nFile);

    nRoot := nXML.Root.FindNode('config');
    if Assigned(nRoot) then
    begin
      nNode := nRoot.FindNode('enable');
      if Assigned(nNode) then
        Self.FEnable := nNode.ValueAsString <> 'N';
      //xxxxx

      nNode := nRoot.FindNode('thread');
      if Assigned(nNode) then
           FThreadCount := nNode.ValueAsInteger
      else FThreadCount := 1;

      if (FThreadCount < 1) or (FThreadCount > cHYReader_MaxThread) then
        raise Exception.Create('RFID102 Reader Thread-Num Need Between 1-10.');
      //xxxxx

      nNode := nRoot.FindNode('monitor');
      if Assigned(nNode) then
           FMonitorCount := nNode.ValueAsInteger
      else FMonitorCount := 1;

      if (FMonitorCount < 1) or (FMonitorCount > FThreadCount) then
        raise Exception.Create(Format(
          'RFID102 Reader Monitor-Num Need Between 1-%d.', [FThreadCount]));
      //xxxxx
    end;

    //--------------------------------------------------------------------------
    nRoot := nXML.Root.FindNode('readers');
    if not Assigned(nRoot) then Exit;
    ClearReaders(False);

    for nIdx:=0 to nRoot.NodeCount - 1 do
    begin
      nNode := nRoot.Nodes[nIdx];
      if CompareText(nNode.Name, 'reader') <> 0 then Continue;

      New(nReader);
      FReaders.Add(nReader);

      with nNode,nReader^ do
      begin
        FLocked := False;
        FKeepLast := 0;
        FLastActive := GetTickCount;

        FID := AttributeByName['id'];
        FHost := NodeByName('ip').ValueAsString;
        FPort := NodeByName('port').ValueAsInteger;
        FEnable := NodeByName('enable').ValueAsString <> 'N';

        nTmp := FindNode('tunnel');
        if Assigned(nTmp) then
          FTunnel := nTmp.ValueAsString;
        //ͨ����

        nTmp := FindNode('virtual');
        if Assigned(nTmp) then
        begin
          FVirtual := nTmp.ValueAsString = 'Y';
          FVReader := nTmp.AttributeByName['reader'];
          FVRGroup := nTmp.AttributeByName['group'];

          if nTmp.AttributeByName['type'] = '900' then
               FVType := rt900
          else FVType := rt02n;
        end else
        begin
          FVirtual := False;
          //Ĭ�ϲ�����
        end;

        nTmp := FindNode('keeponce');
        if Assigned(nTmp) then
        begin
          FKeepOnce := nTmp.ValueAsInteger;
          FKeepPeer := nTmp.AttributeByName['keeppeer'] = 'Y';
        end else
        begin
          FKeepOnce := 0;
          //Ĭ�ϲ��ϲ�
        end;

        FClient := TIdTCPClient.Create;
        with FClient do
        begin
          Host := FHost;
          Port := FPort;
          ReadTimeout := 3 * 1000;
          ConnectTimeout := 3 * 1000;   
        end;

        nTmp := FindNode('cardlen');
        if Assigned(nTmp) then
             FCardLength := nTmp.ValueAsInteger
        else FCardLength := 0;

        FCardPrefix := TStringList.Create;
        nTmp := FindNode('cardprefix');
        if Assigned(nTmp) then
             SplitStr(UpperCase(nTmp.ValueAsString), FCardPrefix, 0, ',')
        else FCardPrefix.Clear;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor THYRFIDReader.Create(AOwner: THYReaderManager;
  AType: THYReaderThreadType);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FThreadType := AType;
  FEPCList:=TStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cHYReader_Wait_Short;
end;

destructor THYRFIDReader.Destroy;
begin
  FreeAndNil(FEPCList);
  FWaiter.Free;
  inherited;
end;

procedure THYRFIDReader.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure THYRFIDReader.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FActiveReader := nil;
    try
      DoExecute;
    finally
      if Assigned(FActiveReader) then
      begin
        FOwner.FSyncLock.Enter;
        FActiveReader.FLocked := False;
        FOwner.FSyncLock.Leave;
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

//Date: 2015-12-06
//Parm: �&�����ͷ
//Desc: ɨ��nActive��ͷ,�����ô���FActiveReader.
procedure THYRFIDReader.ScanActiveReader(const nActive: Boolean);
var nIdx: Integer;
    nReader: PHYReaderItem;
begin
  if nActive then //ɨ����ͷ
  with FOwner do
  begin
    if FReaderActive = 0 then
         nIdx := 1
    else nIdx := 0; //��0��ʼΪ����һ��

    while True do
    begin
      if FReaderActive >= FReaders.Count then
      begin
        FReaderActive := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //ɨ��һ��,��Ч�˳�
      end;

      nReader := FReaders[FReaderActive];
      Inc(FReaderActive);
      if nReader.FLocked or (not nReader.FEnable) then Continue;

      if nReader.FLastActive > 0 then 
      begin
        FActiveReader := nReader;
        FActiveReader.FLocked := True;
        Break;
      end;
    end;
  end else

  with FOwner do //ɨ�費���ͷ
  begin
    if FReaderIndex = 0 then
         nIdx := 1
    else nIdx := 0; //��0��ʼΪ����һ��

    while True do
    begin
      if FReaderIndex >= FReaders.Count then
      begin
        FReaderIndex := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //ɨ��һ��,��Ч�˳�
      end;

      nReader := FReaders[FReaderIndex];
      Inc(FReaderIndex);
      if nReader.FLocked or (not nReader.FEnable) then Continue;

      if nReader.FLastActive = 0 then 
      begin
        FActiveReader := nReader;
        FActiveReader.FLocked := True;
        Break;
      end;
    end;
  end;
end;

procedure THYRFIDReader.DoExecute;
begin
  DoReaderCommand;
  //�����������Ϣ

  FOwner.FSyncLock.Enter;
  try
    if FThreadType = ttAll then
    begin
      ScanActiveReader(False);
      //����ɨ�費���ͷ

      if not Assigned(FActiveReader) then
        ScanActiveReader(True);
      //����ɨ����
    end else

    if FThreadType = ttActive then //ֻɨ��߳�
    begin
      ScanActiveReader(True);
      //����ɨ����ͷ

      if Assigned(FActiveReader) then
      begin
        FWaiter.Interval := cHYReader_Wait_Short;
        //�л��ͷ,����
      end else
      begin
        FWaiter.Interval := cHYReader_Wait_Long;
        //�޻��ͷ,����
        ScanActiveReader(False);
        //����ɨ�費���
      end;
    end;
  finally
    FOwner.FSyncLock.Leave;
  end;

  if Assigned(FActiveReader) and (not Terminated) then
  try
    if ReadCard(FActiveReader) then
    begin
      if FThreadType = ttActive then
        FWaiter.Interval := cHYReader_Wait_Short;
      FActiveReader.FLastActive := GetTickCount;
    end else
    begin
      if (FActiveReader.FLastActive > 0) and
         (GetTickCount - FActiveReader.FLastActive >= 5 * 1000) then
        FActiveReader.FLastActive := 0;
      //�޿�Ƭʱ,�Զ�תΪ���
    end;
  except
    on E:Exception do
    begin
      FActiveReader.FLastActive := 0;
      //��Ϊ���

      WriteLog(Format('Reader:[ %s:%d ] Msg: %s', [FActiveReader.FHost,
        FActiveReader.FPort, E.Message]));
      //xxxxx

      FOwner.CloseReader(FActiveReader);
      //focus reconnect
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015-02-08
//Parm: �ַ�����Ϣ;�ַ�����
//Desc: �ַ���ת����
function Str2Buf(const nStr: string; var nBuf: TIdBytes): Integer;
var nIdx: Integer;
begin
  Result := Length(nStr);;
  SetLength(nBuf, Result);

  for nIdx:=1 to Result do
    nBuf[nIdx-1] := Ord(nStr[nIdx]);
  //xxxxx
end;

//Date: 2015-07-08
//Parm: Ŀ���ַ���;ԭʼ�ַ�����
//Desc: ����ת�ַ���
function Buf2Str(const nBuf: TIdBytes): string;
var nIdx,nLen: Integer;
begin
  nLen := Length(nBuf);
  SetLength(Result, nLen);

  for nIdx:=1 to nLen do
    Result[nIdx] := Char(nBuf[nIdx-1]);
  //xxxxx
end;

//Date: 2015-12-06
//Parm: �����ƴ�
//Desc: ��ʽ��nBinΪʮ�����ƴ�
function HexStr(const nBin: string): string;
var nIdx,nLen: Integer;
begin
  nLen := Length(nBin);
  SetLength(Result, nLen * 2);

  for nIdx:=1 to nLen do
    StrPCopy(@Result[2*nIdx-1], IntToHex(Ord(nBin[nIdx]), 2));
  //xxxxx
end;

//Date: 2015-06-19
//Parm: ԭʼ����(16����);У����ʼ����;У����ֹ��������ʼCRC������ʽ
//Desc: �пƻ�����ӱ�ǩCRC16У���㷨
function Crc16Calc(const nData: string; const nStart,nEnd: Integer;
  nCrcValue: Word=$FFFF; nGenPoly: Word=$8408): Word;
var nIdx,nInt: Integer;
    nCrcTmp: Word;
begin
  Result := 0;
  if (nStart > nEnd) or (nEnd < 1) then Exit;

  nCrcTmp := nCrcValue;
  for nIdx:=nStart to nEnd do
  begin
    nCrcTmp := nCrcTmp xor Ord(nData[nIdx]);

    for nInt:=0 to 7 do
    if (nCrcTmp and $0001)<>0 then
         nCrcTmp := (nCrcTmp shr 1) xor nGenPoly
    else nCrcTmp := nCrcTmp shr 1;
  end;

  Result := nCrcTmp;
end;

//Date: 2015-07-08
//Parm: ����������
//Desc: ����ͨ��Э���װ
function PackSendData(const nData:PRFIDReaderCmd): string;
var nCRC: Word;
begin
  Result := Char(4 + Length(nData.FData)) + nData.FAddr +
            Char(Ord(nData.FCmd)) + nData.FData;
  //len addr cmd data

  nCRC := Crc16Calc(Result, 1, Length(Result));
  Result := Result + Chr(nCRC mod 256) + Chr(nCRC div 256);
end;

//Date: 2015-07-08
//Parm: Ŀ��ṹ;������
//Desc: ����ͨ��Э�����
function UnPackRecvData(const nItem:PRFIDReaderCmd; const nData: string): Boolean;
var nInt,nLen: Integer;
    nCRC: Word;
begin
  Result := False;
  nInt := Length(nData);
  if nInt < 1 then Exit;

  nLen := Ord(nData[1]);
  if nLen >= nInt then Exit;
  //����δ������ȫ

  nCRC := Crc16Calc(nData, 1, nLen - 1);
  if (Ord(nData[nLen]) <> (nCRC mod 256)) or
     (Ord(nData[nLen+1]) <> (nCRC div 256)) then Exit;
  //crc error

  with nItem^ do
  begin
    FLen     := Char(nLen);
    FAddr    := nData[2];
    FCmd     := TReadCmdType(Ord(nData[3]));
    FStatus  := nData[4];

    FData    := Copy(nData, 5, nLen-5);
    FLSB     := nData[nLen];
    FMSB     := nData[nLen+1];

    Result   := FCmd <> tCmd_Err_Cmd;
    //correct command
  end;
end;

//Date: 2015-12-07
//Parm: ����
//Desc: ��֤nCard�Ƿ���Ч
function THYRFIDReader.IsCardValid(const nCard: string;
  const nReader: PHYReaderItem): Boolean;
var nIdx: Integer;
begin
  with FOwner do
  begin
    Result := False;
    nIdx := Length(Trim(nCard));
    if (nIdx < 1) or (
       (nReader.FCardLength > 0) and (nIdx < nReader.FCardLength)) then Exit;
    //leng verify

    Result := nReader.FCardPrefix.Count = 0;
    if Result then Exit;

    for nIdx:=nReader.FCardPrefix.Count - 1 downto 0 do
     if Pos(nReader.FCardPrefix[nIdx], nCard) = 1 then
     begin
       Result := True;
       Exit;
     end;
  end;
end;

function THYRFIDReader.ReadCard(const nReader: PHYReaderItem): Boolean;
var nEPC: string;
    nBuf,nRecv: TIdBytes;
    nStart,nLen: Integer;
    nInt,nIdx: Integer;
begin  
  if not nReader.FClient.Connected then
    nReader.FClient.Connect;
  Result := False;

  FOwner.ActiveRelay(nReader.FID, False);
  //����һ���ͷż̵���ָ��

  with FSendItem do
  begin
    FCmd  := tCmd_G2_Seek;
    FAddr := Chr($FF);
    FData := '';
  end;

  Str2Buf(PackSendData(@FSendItem), nBuf);
  nReader.FClient.IOHandler.Write(nBuf);
  Sleep(cHYReader_Sleep_Short);
  //send data

  nReader.FClient.IOHandler.ReadBytes(nRecv, 1, False);
  if Length(nRecv) < 1 then Exit;
  //get data length first

  nInt := nRecv[0];
  nReader.FClient.IOHandler.ReadBytes(nRecv, nInt, True);
  if not UnPackRecvData(@FRecvItem, Buf2Str(nRecv)) then Exit;

  if FRecvItem.FCmd <> FSendItem.FCmd then Exit;
  //not sample cmd

  if (FRecvItem.FStatus <> #01) and (FRecvItem.FStatus <> #02) and
     (FRecvItem.FStatus <> #03) and (FRecvItem.FStatus <> #04) then Exit;
  //xxxxx

  FEPCList.Clear;
  nStart:=1;
  nInt := Ord(FRecvItem.FData[1]);

  for nIdx:=0 to nInt-1 do
  begin
    nLen := Ord(FRecvItem.FData[nStart+1]);
    nEPC := HexStr(Copy(FRecvItem.FData, nStart+2, nLen));
    nStart := nStart + nLen + 1;

    if IsCardValid(nEPC, nReader) then
      FEPCList.Add(nEPC);
    //xxxxx
  end;
    
  if (not Terminated) and (FEPCList.Count > 0) then
  begin
    Result := True;
    //read success
    
    if nReader.FKeepOnce > 0 then
    begin
      if Pos(FEPCList[0], nReader.FCard) > 0 then
      begin
        if GetTickCount - nReader.FKeepLast < nReader.FKeepOnce then
        begin
          if not nReader.FKeepPeer then
            nReader.FKeepLast := GetTickCount;
          Exit;
        end;
      end;

      nReader.FKeepLast := GetTickCount;
      //ͬ������ˢѹ��
    end;

    nReader.FCard := CombinStr(FEPCList, ',', False);
    //multi card
    
    if Assigned(FOwner.FOnProc) then
      FOwner.FOnProc(nReader);
    //xxxxx

    if Assigned(FOwner.FOnEvent) then
      FOwner.FOnEvent(nReader);
    //xxxxx
  end;
end;

procedure THYRFIDReader.DoReaderCommand;
var nPtr: PRFIDSetRelay;
    nBuf,nRecv: TIdBytes;
    nIdx, nJdx, nInt: Integer;
    nReader, nTmp: PHYReaderItem;
begin
  with FOwner do
  begin
    FSyncLock.Enter;
    try
      nIdx := 0;
      while nIdx < FBuffData.Count do
      begin
        nPtr := FBuffData[nIdx];

        if nPtr.FBase.FCmd <> tCmd_Reader_SetReLay then
        begin
          Dispose(nPtr);
          FBuffData.Delete(nIdx);
          Continue;
        end;
        //�Ǽ̵�������ָ��ɾ��

        nReader := nil;
        for nJdx := 0 to FReaders.Count-1 do
        begin
          nTmp := FReaders[nJdx];

          if (CompareText(nTmp.FID, nPtr.FReaderID) = 0) and
             (nTmp.FEnable) and (not nTmp.FLocked) then
          begin
            nReader := nTmp;
            Break;
          end;  
        end;

        if Assigned(nReader) then
        begin
          try
            if not nReader.FClient.Connected then
              nReader.FClient.Connect;
            //make sure connect

            Str2Buf(PackSendData(@nPtr.FBase), nBuf);
            nReader.FClient.IOHandler.Write(nBuf);
            Sleep(cHYReader_Sleep_Short);
            //send data

            nReader.FClient.IOHandler.ReadBytes(nRecv, 1, False);
            if Length(nRecv) > 0 then    //get data length first
            begin
              nInt := nRecv[0];
              nReader.FClient.IOHandler.ReadBytes(nRecv, nInt, True);
              nReader.FClient.IOHandler.InputBuffer.Clear;

              Dispose(nPtr);
              FBuffData.Delete(nIdx);
              Continue;
            end;
          except
            on E: Exception do
            begin
              WriteLog(Format('Reader:[ %s:%d ] Msg: %s', [nReader.FHost,
                nReader.FPort, E.Message]));
              nReader.FClient.Disconnect;
            end;   
          end;
        end;

        Inc(nIdx);
      end;
    finally
      FSyncLock.Leave;
    end;
  end;  
end;

initialization
  gHYReaderManager := nil;
finalization
  FreeAndNil(gHYReaderManager);
end.
