{*******************************************************************************
  ����: dmzn@163.com 2012-4-12
  ����: �̵������ư�
*******************************************************************************}
unit UMgrERelay;

{$I Link.Inc}
interface

uses
  Windows, Classes, SysUtils, NativeXml, IdTCPConnection, IdTCPClient, IdGlobal,
  UWaitItem, USysLoger;

const
  cERelay_Frame_OC    = $10;       //����֡(open close)
  cERelay_Frame_SH    = $20;       //������(sweet heart)
  cERelay_Frame_DS    = $30;       //��ʾ֡(display)
  cERelay_Frame_IP    = $50;       //����IP
  cERelay_Frame_MAC   = $60;       //����MAC

  cERelay_Ctrl_Begin  = $F0;       //��ʼ��ʶ
  cERelay_Ctrl_Open   = $0F;       //�̵�����
  cERelay_Ctrl_Close  = $00;       //�̵�����
  cERelay_Ctrl_Handle = $88;       //����

  cERelay_LineNum     = 8;         //������ͨ����
  cERelay_DispNum     = 100;       //��ʾ��������

type
  PERelayHost = ^TERelayHost;
  TERelayHost = record
    FName   : string;              //����
    FID     : string;              //��ʶ
    FIP     : string;              //��ַ
    FPort   : Integer;             //�˿�
    FLines  : TList;               //���б�
  end;

  PERelayLine = ^TERelayLine;
  TERelayLine = record
    FID     : string;              //��ʶ
    FLine   : Integer;             //����
    FCard   : Integer;             //����
  end;

  TERelayLines = array [0..cERelay_LineNum - 1] of Byte;
  TERelayDisplay = array[0..cERelay_DispNum - 1] of Byte;

  PERelayFrameHeader = ^TERelayFrameHeader;
  TERelayFrameHeader = record
    FBegin  : Byte;                //��ʼ֡
    FType   : Byte;                //֡����
    FLength : Byte;                //֡����
  end;

  PERelayFrameControl = ^TERelayFrameControl;
  TERelayFrameControl = record
    FHeader : TERelayFrameHeader;  //֡ͷ
    FData   : TERelayLines;        //����
    FVerify : Byte;                //У��λ
  end;

  PERelayFrameDisplay = ^TERelayFrameDisplay;
  TERelayFrameDisplay = record
    FHeader : TERelayFrameHeader;  //֡ͷ
    FData   : TERelayDisplay;      //����
    FVerify : Byte;                //У��λ
  end;

  PERelayFrameSetIP = ^TERelayFrameSetIP;
  TERelayFrameSetIP = record
    FHeader : TERelayFrameHeader;  //֡ͷ
    FIP     : array[0..11] of Char;
    FPort   : array[0..3] of Char; //��ַ
    FVerify : Byte;                //У��λ
  end;

const
  cSize_ERelay_Header   = SizeOf(TERelayFrameHeader);
  cSize_ERelay_Control  = SizeOf(TERelayFrameControl);
  cSize_ERelay_Display  = SizeOf(TERelayFrameDisplay);
  cSize_ERelay_SetIP    = SizeOf(TERelayFrameSetIP);

type
  TERelayControler = class;
  TERelayControlChannel = class(TThread)
  private
    FOwner: TERelayControler;
    //ӵ����
    FBuffer: TList;
    //����������
    FWaiter: TWaitObject;
    //�ȴ�����
    FLastSend: Int64;
    FClient: TIdTCPClient;
    //�ͻ���
  protected
    procedure DoExecute;
    procedure Execute; override;
    //ִ���߳�
    procedure DisconnectClient;
    //�Ͽ���·
  public
    constructor Create(AOwner: TERelayControler);
    destructor Destroy; override;
    //�����ͷ�
    procedure Wakeup;
    procedure StopMe;
    //��ͣͨ��
  end;

  TERelayControler = class(TObject)
  private
    FHost: PERelayHost;
    //����
    FStatus: TERelayLines;
    //״̬
    FData: TThreadList;
    //����
    FChannel: TERelayControlChannel;
    //ͨ��
  protected
    procedure ClearList(const nList: TList);
    //��������
  public
    constructor Create(const nHost: PERelayHost);
    destructor Destroy; override;
    //�����ͷ�
    procedure AddData(const nPtr: Pointer);
    //�������
    property Host: PERelayHost read FHost;
    property Status: TERelayLines read FStatus;
    //�������
  end;

  TERelayManager = class(TObject)
  private
    FFileName: string;
    //�����ļ�
    FHosts: TList;
    //�����б�
    FControler: array of TERelayControler;
    //���ƶ���
  protected
    procedure ClearHost(const nFree: Boolean);
    //������Դ
    function GetLine(const nLineID: string; var nHost: PERelayHost;
     var nLine: PERelayLine): Boolean;
    //����ͨ��
    function GetControler(const nHost: string): Integer;
    //��������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��ɾ����
    procedure LineOpen(const nHost: string; const nLine: Byte); overload;
    procedure LineOpen(const nLineID: string); overload;
    procedure LineClose(const nHost: string; const nLine: Byte); overload;
    procedure LineClose(const nLineID: string); overload;
    procedure LineCtrl(const nHost: string; const nStatus: TERelayLines);
    //����ͨ��
    procedure ShowTxt(const nHost,nTxt: string; const nLine: Byte); overload;
    procedure ShowTxt(const nLineID,nTxt: string); overload;
    //��ʾ����
    procedure ControlStart;
    procedure ControlStop;
    //��ͣ����
    property Hosts: TList read FHosts;
    //�������
  end;

var
  gERelayManager: TERelayManager = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TERelayManager, '�̵���ƹ�����', nEvent);
end;

constructor TERelayManager.Create;
begin
  FHosts := TList.Create;
  SetLength(FControler, 0);
end;

destructor TERelayManager.Destroy;
begin
  ControlStop;
  ClearHost(True);
  inherited;
end;

procedure TERelayManager.ClearHost(const nFree: Boolean);
var i,nIdx: Integer;
    nHost: PERelayHost;
begin
  for nIdx:=FHosts.Count - 1 downto 0 do
  begin
    nHost := FHosts[nIdx];
    for i:=nHost.FLines.Count - 1 downto 0 do
    begin
      Dispose(PERelayLine(nHost.FLines[i]));
      nHost.FLines.Delete(i);
    end;

    nHost.FLines.Free;
    Dispose(nHost);
    FHosts.Delete(nIdx);
  end;

  if nFree then FHosts.Free;
end;

function TERelayManager.GetControler(const nHost: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=Low(FControler) to High(FControler) do
  if CompareText(nHost, FControler[nIdx].FHost.FID) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Desc: ��������
procedure TERelayManager.ControlStart;
var nIdx,nLen: Integer;
begin
  if Length(FControler) > 0 then Exit;

  for nIdx:=0 to FHosts.Count - 1 do
  begin
    nLen := Length(FControler);
    SetLength(FControler, nLen + 1);
    FControler[nLen] := TERelayControler.Create(FHosts[nIdx]);
  end;
end;

//Desc: ֹͣ����
procedure TERelayManager.ControlStop;
var nIdx: Integer;
begin
  for nIdx:=Low(FControler) to High(FControler) do
   if Assigned(FControler) then
    FControler[nIdx].Free;
  SetLength(FControler, 0);
end;

//Desc: ��nPtr�����У��
function VerifyData(const nPtr: Pointer; nLen: Integer): Byte;
var nIdx: Integer;
    nBuf: array of Byte;
begin
  SetLength(nBuf, nLen);
  Move(nPtr^, nBuf[0], nLen);

  Result := nBuf[0];
  for nIdx:=1 to High(nBuf) do
    Result := Result xor nBuf[nIdx];
  //xxxxx
end;

//Date: 2012-4-13
//Parm: ������ʶ;����
//Desc: ��nHost��nLine��
procedure TERelayManager.LineOpen(const nHost: string; const nLine: Byte);
var nIdx: Integer;
    nData: PERelayFrameControl;
begin
  nIdx := GetControler(nHost);
  if nIdx < 0 then Exit;

  New(nData);
  with nData.FHeader do
  begin
    FBegin  := cERelay_Ctrl_Begin;
    FType   := cERelay_Frame_OC;
    FLength := cSize_ERelay_Control - 1;
  end;

  FillChar(nData.FData, cERelay_LineNum, cERelay_Ctrl_Handle);
  nData.FData[nLine] := cERelay_Ctrl_Open;

  nData.FVerify := VerifyData(nData, nData.FHeader.FLength);
  FControler[nIdx].AddData(nData);

  {$IFDEF DEBUG}
  WriteLog(Format('%s:%d����ͨ��.', [nHost, nLine]));
  {$ENDIF}
end;

//Date: 2012-4-13
//Parm: ������ʶ;����
//Desc: �ر�nHost��nLine��
procedure TERelayManager.LineClose(const nHost: string; const nLine: Byte);
var nIdx: Integer;
    nData: PERelayFrameControl;
begin
  nIdx := GetControler(nHost);
  if nIdx < 0 then Exit;

  New(nData);
  with nData.FHeader do
  begin
    FBegin  := cERelay_Ctrl_Begin;
    FType   := cERelay_Frame_OC;
    FLength := cSize_ERelay_Control - 1;
  end;

  FillChar(nData.FData, cERelay_LineNum, cERelay_Ctrl_Handle);
  nData.FData[nLine] := cERelay_Ctrl_Close;

  nData.FVerify := VerifyData(nData, nData.FHeader.FLength);
  FControler[nIdx].AddData(nData);

  {$IFDEF DEBUG}
  WriteLog(Format('%s:%d�ر�ͨ��.', [nHost, nLine]));
  {$ENDIF}
end;

//Date: 2012-4-13
//Parm: ������ʶ;����ʶ
//Desc: ����nHost�ĵ�״̬
procedure TERelayManager.LineCtrl(const nHost: string;
  const nStatus: TERelayLines);
var nIdx: Integer;
    nData: PERelayFrameControl;
begin
  nIdx := GetControler(nHost);
  if nIdx < 0 then Exit;

  New(nData);
  with nData.FHeader do
  begin
    FBegin  := cERelay_Ctrl_Begin;
    FType   := cERelay_Frame_OC;
    FLength := cSize_ERelay_Control - 1;
  end;

  FillChar(nData.FData, cERelay_LineNum, cERelay_Ctrl_Handle);
  nData.FData := nStatus;

  nData.FVerify := VerifyData(nData, nData.FHeader.FLength);
  FControler[nIdx].AddData(nData);
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

    if Result >= cERelay_DispNum then Break;
  end;
end;

//Date: 2012-4-13
//Parm: ������ʶ;�ı�;����
//Desc: ��nHost��nLine����ʾnTxt����
procedure TERelayManager.ShowTxt(const nHost, nTxt: string; const nLine: Byte);
var nIdx: Integer;
    nData: PERelayFrameDisplay;
begin
  nIdx := GetControler(nHost);
  if nIdx < 0 then Exit;

  New(nData);
  with nData.FHeader do
  begin
    FBegin  := cERelay_Ctrl_Begin;
    FType   := cERelay_Frame_DS;
    FLength := ConvertStr(Char($40) + Char(nLine) + nTxt + #13, nData.FData) + 3;
  end;

  nData.FVerify := VerifyData(nData, nData.FHeader.FLength);
  FControler[nIdx].AddData(nData);

  {$IFDEF DEBUG}
  WriteLog(Format('%s:%d ��ʾ����:%s', [nHost, nLine, nTxt]));
  {$ENDIF}
end;

function TERelayManager.GetLine(const nLineID: string; var nHost: PERelayHost;
  var nLine: PERelayLine): Boolean;
var i,nIdx: Integer;
begin
  Result := False;

  for nIdx:=FHosts.Count - 1 downto 0 do
  begin
    nHost := FHosts[nIdx];

    for i:=nHost.FLines.Count - 1 downto 0 do
    begin
      nLine := nHost.FLines[i];
      if CompareText(nLineID, nLine.FID) = 0 then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

procedure TERelayManager.LineOpen(const nLineID: string);
var nHost: PERelayHost;
    nLine: PERelayLine;
begin
  if GetLine(nLineID, nHost, nLine) then LineOpen(nHost.FID, nLine.FLine);
end;

procedure TERelayManager.LineClose(const nLineID: string);
var nHost: PERelayHost;
    nLine: PERelayLine;
begin
  if GetLine(nLineID, nHost, nLine) then LineClose(nHost.FID, nLine.FLine);
end;

procedure TERelayManager.ShowTxt(const nLineID, nTxt: string);
var nHost: PERelayHost;
    nLine: PERelayLine;
begin
  if GetLine(nLineID, nHost, nLine) then ShowTxt(nHost.FID, nTxt, nLine.FCard);
end;

//Date: 2012-4-24
//Parm: �����ļ�
//Desc: ��ȡ�̵�������
procedure TERelayManager.LoadConfig(const nFile: string);
var i,nIdx: Integer;
    nNode,nTmp: TXmlNode;
    nXML: TNativeXml;
    nHost: PERelayHost;
    nLine: PERelayLine;
begin
  FFileName := nFile;
  nXML := TNativeXml.Create;
  try
    ClearHost(False);
    nXML.LoadFromFile(nFile);
    
    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nTmp := nXML.Root.Nodes[nIdx];
      New(nHost);
      FHosts.Add(nHost);

      with nHost^ do
      begin
        FName := nTmp.AttributeByName['name'];
        nNode := nTmp.NodeByName('param');

        FID := nNode.NodeByName('id').ValueAsString;
        FIP := nNode.NodeByName('ip').ValueAsString;
        FPort := nNode.NodeByName('port').ValueAsInteger;
        FLines := TList.Create;
      end;

      nTmp := nTmp.NodeByName('lines');
      for i:=0 to nTmp.NodeCount - 1 do
      begin
        nNode := nTmp.Nodes[i];
        New(nLine);
        nHost.FLines.Add(nLine);

        with nLine^ do
        begin
          FID := nNode.NodeByName('tunnel').ValueAsString;
          FLine := nNode.NodeByName('line').ValueAsInteger;
          FCard := nNode.NodeByName('card').ValueAsInteger;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TERelayControler.Create(const nHost: PERelayHost);
begin
  FHost := nHost;
  FData := TThreadList.Create;
  FChannel := TERelayControlChannel.Create(Self);
end;

destructor TERelayControler.Destroy;
var nList: TList;
begin
  FChannel.StopMe;
  nList := FData.LockList;
  try
    ClearList(nList);
  finally
    FData.UnlockList;
  end;

  FData.Free;
  inherited;
end;

procedure TERelayControler.AddData(const nPtr: Pointer);
begin
  FData.LockList.Add(nPtr);
  FData.UnlockList;
  FChannel.Wakeup;
end;

//Desc: ��������
procedure TERelayControler.ClearList(const nList: TList);
var nIdx: Integer;
    nHeader: PERelayFrameHeader;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    nHeader := nList[nIdx];

    case nHeader.FType of
     cERelay_Frame_OC : Dispose(PERelayFrameControl(nList[nIdx]));
     cERelay_Frame_SH : Dispose(PERelayFrameControl(nList[nIdx]));
     cERelay_Frame_DS : Dispose(PERelayFrameDisplay(nList[nIdx]));
    end;

    nList.Delete(nIdx);
  end;
end;

//------------------------------------------------------------------------------
constructor TERelayControlChannel.Create(AOwner: TERelayControler);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FBuffer := TList.Create;
  
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 3 * 1000;

  FClient := TIdTCPClient.Create(nil);
  FClient.Host := FOwner.FHost.FIP;
  FClient.Port := FOwner.FHost.FPort;
end;

destructor TERelayControlChannel.Destroy;
begin
  FClient.Free;
  FWaiter.Free;

  FOwner.ClearList(FBuffer);
  FBuffer.Free;
  inherited;
end;

procedure TERelayControlChannel.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TERelayControlChannel.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TERelayControlChannel.DisconnectClient;
begin
  FClient.Disconnect;
  if Assigned(FClient.IOHandler) then
    FClient.IOHandler.InputBuffer.Clear;
  //xxxxx
end;

procedure TERelayControlChannel.Execute;
var nList: TList;
    nIdx,nNum: Integer;
begin
  FLastSend := 0;
  //init
  
  nNum := 0;
  //init counter
  
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    try
      if not FClient.Connected then
      begin
        FClient.ReadTimeout := 3 * 1000;
        FClient.ConnectTimeout := 5 * 1000;
        FClient.Connect;
      end;
    except
      WriteLog(Format('����[ %s ]ʧ��.', [FClient.Host]));
      DisconnectClient;
      Continue;
    end;

    nList := FOwner.FData.LockList;
    try
      if nList.Count > 0 then
        nNum := 0;
      //start counter

      for nIdx:=0 to nList.Count - 1 do
        FBuffer.Add(nList[nIdx]);
      nList.Clear;
    finally
      FOwner.FData.UnlockList;
    end;

    try
      DoExecute;
      FOwner.ClearList(FBuffer);
      nNum := 0;
    except
      DisconnectClient;
      //try re-conn

      Inc(nNum);
      if nNum >= 2 then
      begin
        FOwner.ClearList(FBuffer);
        nNum := 0;
      end;

      raise;
      //throw exception
    end;
  except
    on E:Exception do
    begin
      WriteLog(Format('Host:[ %s ] %s', [FClient.Host, E.Message]));
    end;
  end;
end;

procedure TERelayControlChannel.DoExecute;
var nInt: Int64;
    nIdx: Integer;
    nBuf: TIdBytes;
    nHead: PERelayFrameHeader;
    nCtrl: PERelayFrameControl;
begin
  nCtrl := nil;
  for nIdx:=FBuffer.Count - 1 downto 0 do
  begin
    nHead := FBuffer[nIdx];
    if nHead.FType = cERelay_Frame_SH then
    begin
      nCtrl := FBuffer[nIdx];
      Break;
    end;
  end;

  if not Assigned(nCtrl) then
  begin
    New(nCtrl);
    FBuffer.Add(nCtrl);

    with nCtrl.FHeader do
    begin
      FBegin := cERelay_Ctrl_Begin;
      FType  := cERelay_Frame_SH;
      FLength := cSize_ERelay_Control - 1;
    end;

    FillChar(nCtrl.FData, cERelay_LineNum, cERelay_Ctrl_Handle);
    nCtrl.FVerify := VerifyData(nCtrl, nCtrl.FHeader.FLength);
  end; //����֡

  //nCtrl := nil;
  for nIdx:=0 to FBuffer.Count - 1 do
  with FClient.Socket do
  begin
    nInt := GetTickCount - FLastSend;
    if nInt < 420 then
    begin
      nInt := 420 - nInt;
      Sleep(nInt);
    end;

    nHead := FBuffer[nIdx];
    nBuf := RawToBytes(nHead^, nHead.FLength);

    case nHead.FType of
      cERelay_Frame_OC, cERelay_Frame_SH:
      begin
        AppendByte(nBuf, PERelayFrameControl(nHead).FVerify);
        Write(nBuf);

        ReadBytes(nBuf, cSize_ERelay_Control, False);
        FLastSend := GetTickCount;

        {$IFDEF DEBUG}
        case nHead.FType of
         cERelay_Frame_OC: WriteLog(Format('��[ %s ]���Ϳ���ָ��.', [FClient.Host]));
         cERelay_Frame_SH: WriteLog(Format('��[ %s ]��������ָ��.', [FClient.Host]));
        end;
        {$ENDIF}
{
        if Assigned(nCtrl) then Continue;
        if Length(nBuf) < cSize_ERelay_Control then Continue;

        nCtrl := @nBuf[0];
        if nCtrl.FVerify = VerifyData(nCtrl, cSize_ERelay_Control - 1) then
             FOwner.FStatus := nCtrl.FData
        else nCtrl := nil;
}
      end;
      cERelay_Frame_DS:
      begin
        {$IFDEF DEBUG}
        WriteLog('��ʼ������ʾ֡,У����: ' +
                 IntToStr(PERelayFrameDisplay(nHead).FVerify));
        {$ENDIF}

        AppendByte(nBuf, PERelayFrameDisplay(nHead).FVerify);
        Write(nBuf);
        FLastSend := GetTickCount;
      end;
    end;
  end;
end;

initialization
  gERelayManager := TERelayManager.Create;
finalization
  FreeAndNil(gERelayManager);
end.
