{*******************************************************************************
  ����: dmzn@163.com 2012-09-07
  ����: �����(����)������
*******************************************************************************}
unit UMgrCodePrinter;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, UWaitItem, IdComponent, IdGlobal,
  IdTCPConnection, IdTCPClient, NativeXml, ULibFun, USysLoger;

const
  cCP_KeepOnLine = 3 * 1000;     //���߱���ʱ��
  //CP=code printer
  
type
  PCodePrinter = ^TCodePrinter;
  TCodePrinter = record
    FID        : string;            //��ʶ
    FIP        : string;            //��ַ
    FPort      : Integer;           //�˿�
    FTunnel    : string;            //ͨ��

    FDriver    : string;            //����
    FEnable    : Boolean;           //����
    FResponse  : Boolean;           //��Ӧ��
    FOnline    : Boolean;           //����
    FLastOn    : Int64;             //�ϴ�����
    FOptions   : TStrings;          //����ѡ��
  end;

  TCodePrinterManager = class;
  //define manager object
  
  TCodePrinterBase = class(TObject)
  protected
    FPrinter: PCodePrinter;
    //�����
    FClient: TIdTCPClient;
    //�ͻ���
    FFlagLock: Boolean;
    //�������
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; virtual; abstract;
    //��ӡ����
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    class function DriverName: string; virtual; abstract;
    //��������
    function Print(const nPrinter: PCodePrinter; const nCode: string;
     var nHint: string): Boolean;
    //��ӡ����
    function IsOnline(const nPrinter: PCodePrinter): Boolean;
    //�Ƿ�����
    procedure LockMe;
    procedure UnlockMe;
    function IsLocked: Boolean;
    //����״̬
  end;

  TCodePrinterMonitor = class(TThread)
  private
    FOwner: TCodePrinterManager;
    //ӵ����
    FWaiter: TWaitObject;
    //�ȴ�����
  protected
    procedure Execute; override;
    //ִ���߳�
  public
    constructor Create(AOwner: TCodePrinterManager);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TCodePrinterDriverClass = class of TCodePrinterBase;
  //the driver class define

  TCodePrinterManager = class(TObject)
  private
    FDriverClass: array of TCodePrinterDriverClass;
    FDrivers: array of TCodePrinterBase;
    //�����б�
    FPrinters: TList;
    //������б�
    FMonIdx: Integer;
    FMonitor: array[0..1]of TCodePrinterMonitor;
    //����߳�
    FTunnelCode: TStrings;
    //ͨ������
    FSyncLock: TCriticalSection;
    //ͬ������
    FEnablePrinter: Boolean;
    FEnableJSQ: Boolean;
    //ϵͳ����
  protected
    procedure ClearDrivers;
    procedure ClearPrinters(const nFree: Boolean);
    //�ͷ���Դ
    function GetPrinter(const nTunnel: string): PCodePrinter;
    //���������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��������
    procedure StartMon;
    procedure StopMon;
    //��ͣ���
    procedure RegDriver(const nDriver: TCodePrinterDriverClass);
    //ע������
    function LockDriver(const nName: string): TCodePrinterBase;
    procedure UnlockDriver(const nDriver: TCodePrinterBase);
    //��ȡ����
    function PrintCode(const nTunnel,nCode: string; var nHint: string): Boolean;
    //��ӡ����
    function IsPrinterOnline(const nTunnel: string): Boolean;
    //�Ƿ�����
    function IsPrinterEnable(const nTunnel: string): Boolean;
    procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
    //��ͣ�����
    property EnablePrinter: Boolean read FEnablePrinter;
    //�������
  end;

var
  gCodePrinterManager: TCodePrinterManager = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TCodePrinterManager, '�����������', nEvent);
end;

//------------------------------------------------------------------------------
constructor TCodePrinterMonitor.Create(AOwner: TCodePrinterManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2 * 1000;
end;

destructor TCodePrinterMonitor.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TCodePrinterMonitor.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TCodePrinterMonitor.Execute;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  while not Terminated do
  with FOwner do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FSyncLock.Enter;
    try
      if FMonIdx >= FPrinters.Count then
        FMonIdx := 0;
      //xxxxx
    finally
      FSyncLock.Leave;
    end;

    while True do
    begin
      FSyncLock.Enter;
      try
        nPrinter := nil;
        if FMonIdx >= FPrinters.Count then Break;
        
        nPrinter := FPrinters[FMonIdx];
        Inc(FMonIdx);

        if not nPrinter.FEnable then Continue;
        if GetTickCount - nPrinter.FLastOn < cCP_KeepOnLine then Continue;
      finally
        FSyncLock.Leave;
      end;

      if not Assigned(nPrinter) then Break;
      nDriver := LockDriver(nPrinter.FDriver);
      try
        nDriver.IsOnline(nPrinter);
      finally
        UnlockDriver(nDriver);
      end;
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TCodePrinterManager.Create;
begin
  FEnablePrinter := False;
  FEnableJSQ := False;

  FPrinters := TList.Create;
  FTunnelCode := TStringList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TCodePrinterManager.Destroy;
begin
  StopMon;
  ClearDrivers;
  ClearPrinters(True);

  FTunnelCode.Free;
  FSyncLock.Free;
  inherited;
end;

procedure TCodePrinterManager.ClearPrinters(const nFree: Boolean);
var nIdx: Integer;
    nPrinter: PCodePrinter;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FPrinters.Count - 1 downto 0 do
    begin
      nPrinter := FPrinters[nIdx];
      if Assigned(nPrinter.FOptions) then
        FreeAndNil(nPrinter.FOptions);
      Dispose(nPrinter);
    end;
    //xxxxx

    if nFree then
         FPrinters.Free
    else FPrinters.Clear;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TCodePrinterManager.ClearDrivers;
var nIdx: Integer;
begin
  for nIdx:=Low(FDrivers) to High(FDrivers) do
    FDrivers[nIdx].Free;
  SetLength(FDrivers, 0);
end;

procedure TCodePrinterManager.StartMon;
var nIdx: Integer;
begin
  if FEnablePrinter then
  begin
    if FPrinters.Count > 0 then
         FMonIdx := 0
    else Exit;

    for nIdx:=Low(FMonitor) to High(FMonitor) do
    begin
      FMonitor[nIdx] := nil;
      Exit; //�ر���������߼��

      if nIdx >= FPrinters.Count then Break;
      //̽���̲߳��������������

      if not Assigned(FMonitor[nIdx]) then
        FMonitor[nIdx] := TCodePrinterMonitor.Create(Self);
      //xxxxx
    end;
  end;
end;

procedure TCodePrinterManager.StopMon;
var nIdx: Integer;
begin
  for nIdx:=Low(FMonitor) to High(FMonitor) do
   if Assigned(FMonitor[nIdx]) then
   begin
     FMonitor[nIdx].StopMe;
     FMonitor[nIdx] := nil;
   end;
end;

procedure TCodePrinterManager.RegDriver(const nDriver: TCodePrinterDriverClass);
var nIdx: Integer;
begin
  for nIdx:=Low(FDriverClass) to High(FDriverClass) do
   if FDriverClass[nIdx].DriverName = nDriver.DriverName then Exit;
  //driver exists

  nIdx := Length(FDriverClass);
  SetLength(FDriverClass, nIdx + 1);
  FDriverClass[nIdx] := nDriver;
end;

//Date: 2012-9-7
//Parm: ��������
//Desc: ����nName��������
function TCodePrinterManager.LockDriver(const nName: string): TCodePrinterBase;
var nIdx,nInt: Integer;
begin
  Result := nil;
  FSyncLock.Enter;
  try
    for nIdx:=Low(FDrivers) to High(FDrivers) do
    if (not FDrivers[nIdx].IsLocked) and
       (CompareText(FDrivers[nIdx].DriverName, nName) = 0) then
    begin
      Result := FDrivers[nIdx];
      Exit;
    end;

    for nIdx:=Low(FDriverClass) to High(FDriverClass) do
    if CompareText(FDriverClass[nIdx].DriverName, nName) = 0 then
    begin
      nInt := Length(FDrivers);
      SetLength(FDrivers, nInt + 1);

      Result := FDriverClass[nIdx].Create;
      FDrivers[nInt] := Result;
      Exit;
    end;

    WriteLog(Format('�޷���������Ϊ[ %s ]���������.', [nName]));
  finally
    if Assigned(Result) then
      Result.LockMe;
    FSyncLock.Leave;
  end;
end;

//Date: 2012-9-7
//Parm: ��������
//Desc: ��nDriver����
procedure TCodePrinterManager.UnlockDriver(const nDriver: TCodePrinterBase);
begin
  if Assigned(nDriver) then
  begin
    FSyncLock.Enter;
    nDriver.UnlockMe;
    FSyncLock.Leave;
  end;
end;

//Date: 2012-9-7
//Parm: ͨ��
//Desc: ����nTunnelͨ���ϵ������
function TCodePrinterManager.GetPrinter(const nTunnel: string): PCodePrinter;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FPrinters.Count - 1 downto 0 do
  begin
    Result := FPrinters[nIdx];
    if CompareText(Result.FTunnel, nTunnel) = 0 then
         Break
    else Result := nil;
  end;
end;

//Date: 2012-9-7
//Parm: ͨ��
//Desc: �ж�nTunnel��������Ƿ�����
function TCodePrinterManager.IsPrinterOnline(const nTunnel: string): Boolean;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  if not FEnablePrinter then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  nPrinter := GetPrinter(nTunnel);

  if not Assigned(nPrinter) then
  begin
    WriteLog(Format('ͨ��[ %s ]û�����������.', [nTunnel]));
    Exit;
  end;
  
  nDriver := nil;
  try
    nDriver := LockDriver(nPrinter.FDriver);
    if Assigned(nDriver) then
      Result := nDriver.IsOnline(nPrinter);
    //xxxxx
  finally
    UnlockDriver(nDriver);
  end;
end;

//Date: 2013-07-23
//Parm: ͨ����
//Desc: ��ѯnTunnelͨ���ϵ������״̬
function TCodePrinterManager.IsPrinterEnable(const nTunnel: string): Boolean;
var nPrinter: PCodePrinter;
begin
  Result := False;

  if FEnablePrinter then
  begin
    nPrinter := GetPrinter(nTunnel);
    if Assigned(nPrinter) then
      Result := nPrinter.FEnable;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: ͨ��;��ͣ��ʶ
//Desc: ��ͣnTunnelͨ���ϵ������
procedure TCodePrinterManager.PrinterEnable(const nTunnel: string;
  const nEnable: Boolean);
var nPrinter: PCodePrinter;
begin
  if FEnablePrinter then
  begin
    nPrinter := GetPrinter(nTunnel);
    if Assigned(nPrinter) then
      nPrinter.FEnable := nEnable;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: ͨ��;����
//Desc: ��nTunnelͨ����������ϴ�ӡnCode
function TCodePrinterManager.PrintCode(const nTunnel, nCode: string;
  var nHint: string): Boolean;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  if not FEnablePrinter then
  begin
    Result := True;
    Exit;
  end;

  if Length(nCode) < 1 then
  begin
    Result := True;
    Exit;
  end;
  //����������
  
  Result := False;
  nPrinter := GetPrinter(nTunnel);

  if not Assigned(nPrinter) then
  begin
    nHint := Format('ͨ��[ %s ]û�����������.', [nTunnel]);
    Exit;
  end;
  
  nDriver := nil;
  try
    nDriver := LockDriver(nPrinter.FDriver);
    if Assigned(nDriver) then
         Result := nDriver.Print(nPrinter, nCode, nHint)
    else nHint := Format('��������Ϊ[ %s ]�������ʧ��.', [nPrinter.FDriver]);
  finally
    UnlockDriver(nDriver);
  end;

  if Result then
    FTunnelCode.Values[nTunnel] := nCode;
  //�����ϴ���Ч����
end;

//Desc: ��ȡnFile����������ļ�
procedure TCodePrinterManager.LoadConfig(const nFile: string);
var nIdx: Integer;
    nResponse: Boolean;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
    nPrinter: PCodePrinter;
begin
  nXML := TNativeXml.Create;
  try
    ClearPrinters(False);
    nXML.LoadFromFile(nFile);

    nResponse := False;
    nTmp := nXML.Root.FindNode('config');

    if Assigned(nTmp) then
    begin
      nIdx := nTmp.NodeByName('enableprinter').ValueAsInteger;
      FEnablePrinter := nIdx = 1;

      nIdx := nTmp.NodeByName('enablejsq').ValueAsInteger;
      FEnableJSQ := nIdx = 1;

      nNode := nTmp.FindNode('response');
      if Assigned(nNode) then
        nResponse := nNode.ValueAsInteger = 1;
      //ȫ������: �Ƿ��Ӧ����
    end;

    nTmp := nXML.Root.FindNode('printers');
    if Assigned(nTmp) then
    begin
      for nIdx:=0 to nTmp.NodeCount - 1 do
      begin
        New(nPrinter);
        FPrinters.Add(nPrinter);

        nNode := nTmp.Nodes[nIdx];
        with nPrinter^ do
        begin
          FID := nNode.AttributeByName['id'];
          FIP := nNode.NodeByName('ip').ValueAsString;
          FPort := nNode.NodeByName('port').ValueAsInteger;

          FTunnel := nNode.NodeByName('tunnel').ValueAsString;
          FDriver := nNode.NodeByName('driver').ValueAsString;
          FEnable := nNode.NodeByName('enable').ValueAsInteger = 1;

          FResponse := nResponse;
          if Assigned(nNode.FindNode('response')) then
            FResponse := nNode.NodeByName('response').ValueAsInteger = 1;
          //xxxxx

          if Assigned(nNode.FindNode('options')) then
          begin
            FOptions := TStringList.Create;
            SplitStr(nNode.FindNode('options').ValueAsString, FOptions, 0, ';');
          end else FOptions := nil;

          FOnline := False;
          FLastOn := 0;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TCodePrinterBase.Create;
begin
  FFlagLock := False;
  FClient := TIdTCPClient.Create;
  FClient.ConnectTimeout := 5 * 1000;
  FClient.ReadTimeout := 3 * 1000;
end;

destructor TCodePrinterBase.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;
  inherited;
end;

procedure TCodePrinterBase.LockMe;
begin
  FFlagLock := True;
end;

procedure TCodePrinterBase.UnlockMe;
begin
  FFlagLock := False;
end;

function TCodePrinterBase.IsLocked: Boolean;
begin
  Result := FFlagLock;
end;

//Desc: �ж�nPrinter�Ƿ�����
function TCodePrinterBase.IsOnline(const nPrinter: PCodePrinter): Boolean;
begin
  if (not nPrinter.FEnable) or
     (GetTickCount - nPrinter.FLastOn < cCP_KeepOnLine) then
  begin
    Result := True;
    Exit;
  end else Result := False;

  try
    if (FClient.Host <> nPrinter.FIP) or (FClient.Port <> nPrinter.FPort) then
    begin
      FClient.Disconnect;
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      //xxxxx

      FClient.Host := nPrinter.FIP;
      FClient.Port := nPrinter.FPort;
    end;

    if not FClient.Connected then
      FClient.Connect;
    Result := FClient.Connected;

    nPrinter.FOnline := Result;
    if Result then
      nPrinter.FLastOn := GetTickCount;
    //xxxxx
  except
    FClient.Disconnect;
    if Assigned(FClient.IOHandler) then
      FClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: �����;����
//Desc: ��nPrinter����nCode����.
function TCodePrinterBase.Print(const nPrinter: PCodePrinter;
  const nCode: string; var nHint: string): Boolean;
begin
  if not nPrinter.FEnable then
  begin
    Result := True;
    Exit;
  end else Result := False;

  if not IsOnline(nPrinter) then
  begin
    nHint := Format('�����[ %s ]����ͨѶ�쳣.', [nPrinter.FID]);
    Exit;
  end;

  try
    if Assigned(FClient.IOHandler) then
    begin
      FClient.IOHandler.InputBuffer.Clear;
      FClient.IOHandler.WriteBufferClear;
    end;

    FPrinter := nPrinter;
    Result := PrintCode(nCode, nHint);
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
      nHint := Format('�������[ %s ]��������ʧ��.', [nPrinter.FID]);

      FClient.Disconnect;
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      //xxxxx
    end;
  end;
end;

//------------------------------------------------------------------------------
type
  TByteWord = record
    FH: Byte;
    FL: Byte;
  end;

function CalCRC16(data, crc, genpoly: Word): Word;
var i: Word;
begin
  data := data shl 8;                       // �Ƶ����ֽ�
  for i:=7 downto 0 do
  begin
    if ((data xor crc) and $8000) <> 0 then //ֻ�������λ
         crc := (crc shl 1) xor genpoly     // ���λΪ1����λ�������
    else crc := crc shl 1;                  // ����ֻ��λ����2��
    data := data shl 1;                     // ������һλ
  end;

  Result := crc;
end;

function CRC16(const nStr: string; const nStart,nEnd: Integer): Word;
var nIdx: Integer;
begin
  Result := 0;
  if (nStart > nEnd) or (nEnd < 1) then Exit;

  for nIdx:=nStart to nEnd do
  begin
    Result := CalCRC16(Ord(nStr[nIdx]), Result, $1021);
  end;
end;

//------------------------------------------------------------------------------
type
  TPrinterZero = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;
  
class function TPrinterZero.DriverName: string;
begin
  Result := 'zero';
end;

//Desc: ��ӡ����
function TPrinterZero.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nStr,nData: string;
    nCrc: TByteWord;
    nBuf: TIdBytes;
begin
  //protocol: 55 7F len order datas crc16 AA
  nData := Char($55) + Char($7F) + Char(Length(nCode) + 1);
  nData := nData + Char($54) + Char($01);
  nData := nData + nCode;

  nCrc := TByteWord(CRC16(nData, 5, Length(nData)));
  nData := nData + Char(nCrc.FH) + Char(nCrc.FL) + Char($AA);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);
  
  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, 9, False);
    nStr := BytesToString(nBuf,Indy8BitEncoding);

    nData :=  Char($55) + Char($FF) + Char($02)+ Char($54)+ Char($4F);
    nData :=  nData + Char($4B)+ Char($5D) + Char($E4) + Char($AA);

    if nstr <> nData then
    begin
      nHint := '�����Ӧ�����!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

//-----------------------------------------------------------------------
type
  TPrinterJY = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterJY.DriverName: string;
begin
  Result := 'JY';
end;

function TPrinterJY.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nStr,nData: string;
  nBuf: TIdBytes;
begin

  //���������
  //1B 41 len(start 38) channel(start 31) 40 37 datas 40 39 0D
  // 1B 41 29 Ϊ��ͷ����
  // 27 ��ʾ������ֵĸ��� ��27��ʾΪ1���� �����ķ�ʽΪ16����
  // 20 ��ʾͨ���ı���      ��20Ϊͨ��1��  �����ķ�ʽΪ16����
  // 40 37 ��ʾ�������ݵĿ�ʼ
  // ***  ���������        ���͵ķ�ʽΪASCII��
  // 40 39 ��ʾ�������ݵĽ�β
  // 0D   ��ʾ���崫�͵Ľ�β

  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 38);
  nData := nData + Char(2 + 31) + Char($40) + Char($37);
  nData := nData + nCode + Char($40) + Char($39)+ Char($0D);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);

    nStr := BytesToString(nBuf, Indy8BitEncoding);
    if nStr <> nData then
    begin
      nHint := '�����Ӧ�����!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;


//-----------------------------------------------------------------------
type
  TPrinterWSD = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterWSD.DriverName: string;
begin
  Result := 'WSD';
end;

function TPrinterWSD.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nStr,nData: string;
  nBuf: TIdBytes;
begin
  //��ʿ�������
  //1B 41 29 2A 20 40 37 32 33 34 35 40 39 0D

  //1B 41 29 ��ʼλ
  //2A ��ʾ����ָ�������ֽڳ���+20����ɫ���ɫ�ֵĳ��ȣ��������ķ�ʽΪ16����
  //20  ��ʾͨ���ı��루20Ϊͨ��1��21Ϊͨ��2���Դ����ƣ�  �����ķ�ʽΪ16����
  //40 37 ��ʾ�������ݵĿ�ʼ
  //40 39 ��ʾ�������ݵĽ�β
  //0D   ��ʾ���崫�͵Ľ�β

  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 32 + 6);
  nData := nData+Char(2 + 31 )+Char($40)+Char($37);
  nData := nData+nCode;
  nData := nData+Char($40)+Char($39)+Char($0D);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);

    nStr := BytesToString(nBuf, Indy8BitEncoding);
    if nStr <> nData then
    begin
      nHint := '�����Ӧ�����!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

//-----------------------------------------------------------------------
type
  TPrinterSGB = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterSGB.DriverName: string;
begin
  Result := 'SGB';
end;

function TPrinterSGB.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nData: string;
    nBuf: TIdBytes;
begin
  //�˹������
  //1B 41 len(start 38) channel(start 31) 40 37 datas 40 39 0D
  //1B 41 2C 22 channel(start 31) 0D;
  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 38);
  nData := nData + Char(2 + 31) + Char($40) + Char($37);
  nData := nData + nCode + Char($40) + Char($39)+ Char($0D);
  FClient.Socket.Write(nData, Indy8BitEncoding);

  nData := Char($1B) + Char($41) + Char($2C) +Char($22);
  nData := nData + Char(2 + 31) + Char($0D);
  
  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);
  end;

  Result := True;
end;

initialization
  gCodePrinterManager := TCodePrinterManager.Create;
  gCodePrinterManager.RegDriver(TPrinterZero);
  gCodePrinterManager.RegDriver(TPrinterJY);
  gCodePrinterManager.RegDriver(TPrinterWSD);
  gCodePrinterManager.RegDriver(TPrinterSGB);
finalization
  FreeAndNil(gCodePrinterManager);
end.
