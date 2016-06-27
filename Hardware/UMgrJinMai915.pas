{*******************************************************************************
  ���ߣ�dmzn@163.com 2014-5-15
  ����������915Զ�������ͨѶ��Ԫ
*******************************************************************************}
unit UMgrJinMai915;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, USysLoger, UWaitItem,
  ULibFun;

const
  cJMBufferSize      = 512;         //���ջ���

type
  TJMReaderType = (rtIn, rtOut, rtAll);
  //��ͷ����

  PJMReaderItem = ^TJMReaderItem;
  TJMReaderItem = record
    FEnable: Boolean;               //�Ƿ�����   
    FID: string;                    //�ڵ��ʶ
    FName: string;                  //�ڵ�����
    FType: TJMReaderType;           //����

    FHost: string;                  //����IP
    FPort: Integer;                 //ͨѶ�˿�
    FSock: Integer;                 //�׽���
    FAddr: Integer;                 //ͨѶ��ַ

    FStart,FEnd: Integer;           //���ݷ�Χ
    FCardFlag: string;              //�ſ���ʶ
    FCardLen: Integer;              //���ų���
    FCardCut: Integer;              //�ü�����
    FCardFull: Boolean;             //��������
    FCard: string;                  //�ſ����
  end;

  TJMCardManager = class;
  TJMReaderThead = class(TThread)
  private
    FOwner: TJMCardManager;
    //ӵ����
    FWaiter: TWaitObject;
    //�ȴ�����
    FLastActive: Int64;
    FActiveReader: PJMReaderItem;
    //���ͷ
    FDataLen: Integer;
    FBuffer: array[0..cJMBufferSize - 1] of Byte;
    //���ջ���
  protected
    procedure CloseReader(const nReader: PJMReaderItem);
    procedure CloseReaders;
    //�رն�ͷ
    procedure SyncDoCard;
    procedure Execute; override;
    //ִ���߳�
    function HexCard(const nReader: PJMReaderItem): Boolean;
    procedure ReadCard(const nReader: PJMReaderItem);
    //��ȡ����
  public
    constructor Create(AOwner: TJMCardManager);
    destructor destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TJMCardProc = procedure (const nReader: PJMReaderItem);
  TJMCardEvent = procedure (const nReader: PJMReaderItem) of object;
  //�¼�����

  PJMCardReceiver = ^TJMCardReceiver;
  TJMCardReceiver = record
    FID: Integer;                          //���ն���
    FEvent: TJMCardEvent;                  //�����¼�
  end;

  TJMCardManager = class(TObject)
  private
    FCfgFile: string;
    //�����ļ�
    FReaders: TList;
    //�������б�
    FReader: TJMReaderThead;
    //�����߳�
    FSyncLock: TCriticalSection;
    //ͬ������
    FReceiverIDBase: Integer;
    FReceivers: TList;
    //���ն���
    FStartCounter: Integer;
    //��������
    FOnCardProc: TJMCardProc;
    FOnCardSync: TJMCardProc;
    FOnCardEvent: TJMCardEvent;
    //�¼����
  protected
    procedure ClearReaders(const nFree: Boolean);
    procedure ClearReceivers(const nFree: Boolean);
    //������Դ
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure StartRead;
    procedure StopRead(const nForce: Boolean = False);
    //��ͣ����
    procedure LoadConfig(const nFile: string);
    //��ȡ����
    function AddReceiver(const nEvent: TJMCardEvent): Integer;
    procedure DelReceiver(const nReceiverID: Integer);
    //���ն���
    property ConfigFile: string read FCfgFile;
    property OnCardProc: TJMCardProc read FOnCardProc write FOnCardProc;
    property OnCardSync: TJMCardProc read FOnCardSync write FOnCardSync;
    property OnCardEvent: TJMCardEvent read FOnCardEvent write FOnCardEvent;
    //�������
  end;

var
  gJMCardManager: TJMCardManager = nil;
  //ȫ��ʹ��
  
implementation

const
  cLib = 'adpnet.dll';

function an_open(nIP: string; nPort: Integer): Integer; stdcall; external cLib;
function an_close(nSocket: Integer): BOOL; stdcall; external cLib;
//���ӶϿ�����
function an_getaddress(nSocket: Thandle; nAddr: PINT; nVer: PINT): integer;
  stdcall; external cLib;
//��ȡ�豸��ַ�汾

function an_identify6b(nSocket: Thandle; nAddr: Integer; nData: PChar;
  nSize: PChar): integer; stdcall; external cLib;
//��ȡ6BЭ���ǩ
function an_read6b(nSocket: Thandle; nAddr: Integer; nData: PChar;
  iAddr,iSize : PChar) : integer; stdcall; external cLib;
//��ȡ6B��ǩ����
function an_getautocard(nSocket: Thandle; nData : PDWORD;
  nSize : PDWORD) : integer; stdcall; external cLib;
//��ȡ�Զ����Ϳ���

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TJMCardManager, 'Զ���������', nEvent);
end;

//------------------------------------------------------------------------------
constructor TJMReaderThead.Create(AOwner: TJMCardManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 3 * 1000;
end;

destructor TJMReaderThead.destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TJMReaderThead.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

//Date��2014-5-27
//Parm����ͷ
//Desc���ر�nReader
procedure TJMReaderThead.CloseReader(const nReader: PJMReaderItem);
var nSock: Integer;
begin
  if nReader.FSock > 0 then
  begin
    nSock := nReader.FSock;
    nReader.FSock := 0;
    an_close(nSock);
  end;
end;

//Date��2014-5-27
//Desc���ر����ж�ͷ
procedure TJMReaderThead.CloseReaders;
var nIdx: Integer;
begin
  FOwner.FSyncLock.Enter;
  try
    for nIdx:= FOwner.FReaders.Count - 1 downto 0 do
      CloseReader(FOwner.FReaders[nIdx]);
    //xxxxx
  finally
    FOwner.FSyncLock.Leave;
  end;
end;

procedure TJMReaderThead.SyncDoCard;
var nIdx: Integer;
begin
  if Assigned(FOwner.FOnCardEvent) then
    FOwner.FOnCardEvent(FActiveReader);
  //xxxxx

  if Assigned(FOwner.FOnCardSync) then
    FOwner.FOnCardSync(FActiveReader);
  //xxxxx

  for nIdx:=FOwner.FReceivers.Count - 1 downto 0 do
    PJMCardReceiver(FOwner.FReceivers[nIdx]).FEvent(FActiveReader);
  //xxxxx
end;

procedure TJMReaderThead.Execute;
var nIdx: Integer;
begin
  FLastActive := GetTickCount;
  nIdx := 0;
  //init
  
  while True do
  try
    FWaiter.EnterWait;
    if Terminated then
    begin
      CloseReaders;
      Exit;
    end;

    while True do
    try
      FOwner.FSyncLock.Enter;
      //lock data
      if Terminated then Break;

      if nIdx >= FOwner.FReaders.Count then
      begin
        nIdx := 0;
        Break;
      end;

      Inc(nIdx);
      ReadCard(FOwner.FReaders[nIdx-1]);
    finally
      FOwner.FSyncLock.Leave;
    end;
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Date��2014-5-27
//Parm����ͷ
//Desc����ȡnReader�ϵĿ���
procedure TJMReaderThead.ReadCard(const nReader: PJMReaderItem);
var nInt,nRet: Integer;
begin
  if nReader.FEnable then
  try
    if nReader.FSock < 1 then
    begin
      nReader.FSock := an_open(nReader.FHost, nReader.FPort);
      //xxxxx

      if nReader.FSock < 1 then
        raise Exception.Create(Format('����[ %s ]ʧ��.', [nReader.FName]));
      //xxxxx
    end;

    FDataLen := 255;
    nRet := an_getautocard(nReader.FSock, @FBuffer[0], @FDataLen);

    if nRet <> 0 then
    begin
      nInt := GetTickCount - FLastActive;
      if (nRet = 401) or  //��·�쳣,��������
        ((nRet = 206) and (nInt >= 4 * 60 * 1000 )) or //�޿���
         (nInt >= 10 * 60 * 1000) then
      begin
        if nRet = 206 then
          FWaiter.Wakeup(True);
        //xxxxx
        
        FLastActive := GetTickCount;
        CloseReader(nReader);
        WriteLog(Format('��������[ %s],����: %d.', [nReader.FName, nRet]));
      end;
      Exit;
    end;
    //read card no

    if FDataLen >= cJMBufferSize then
         nReader.FEnd := cJMBufferSize - 1
    else nReader.FEnd := FDataLen - 1;

    FLastActive := GetTickCount;
    nReader.FStart := 0;
    if not HexCard(nReader) then Exit;

    if Assigned(FOwner.FOnCardEvent) or Assigned(FOwner.FOnCardSync) or
       (FOwner.FReceivers.Count > 0) then
    begin
      FActiveReader := nReader;
      Synchronize(SyncDoCard);
    end;

    if Assigned(FOwner.FOnCardProc) then
      FOwner.FOnCardProc(nReader);
    //xxxxx
  except
    on E: Exception do
    begin
      CloseReader(nReader);
      raise;
    end;
  end;  
end;

//Date: 2014-06-11
//Parm: ��ͷ
//Desc: ��FBuffer��FStart-FEnd������Hex��,����nReader��
function TJMReaderThead.HexCard(const nReader: PJMReaderItem): Boolean;
var nIdx,nPos: Integer;
begin
  Result := False;
  if nReader.FStart >= nReader.FEnd then Exit;
  nReader.FCard := '';

  for nIdx:=nReader.FStart to nReader.FEnd do
    nReader.FCard := nReader.FCard + IntToHex(FBuffer[nIdx], 2);
  //xxxxxx

  if nReader.FCardFull then
  begin
    Result := True;
    Exit;
  end; //full card

  if nReader.FCardFlag <> '' then
  begin
    nPos := Pos(nReader.FCardFlag, nReader.FCard);
    if nPos < 1 then Exit;

    nReader.FCard := Copy(nReader.FCard, nPos + Length(nReader.FCardFlag), 44);
    //FFFF10320D01E20020755919017926600B42B0CCFFFF
    
    nPos := Pos(nReader.FCardFlag, nReader.FCard);
    if nPos < 1 then Exit;
    nReader.FCard := Copy(nReader.FCard, 1, nPos - 1);
  end;

  nPos := Length(nReader.FCard) - nReader.FCardLen + 1;
  nReader.FCard := Copy(nReader.FCard, nPos, nReader.FCardLen-nReader.FCardCut);
  Result := Length(nReader.FCard) = nReader.FCardLen-nReader.FCardCut;
end;

//------------------------------------------------------------------------------
constructor TJMCardManager.Create;
begin
  FStartCounter := 0;
  FReceiverIDBase := 0;
  FReceivers := TList.Create;

  FReaders := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TJMCardManager.Destroy;
begin
  StopRead(True);
  ClearReaders(True);
  ClearReceivers(True);
  
  FSyncLock.Free;
  inherited;
end;

procedure TJMCardManager.StartRead;
begin
  if not Assigned(FReader) then
    FReader := TJMReaderThead.Create(Self);
  Inc(FStartCounter);
end;

procedure TJMCardManager.StopRead(const nForce: Boolean);
begin
  if FStartCounter > 0 then
    Dec(FStartCounter);
  if (not nForce) and (FStartCounter > 0) then Exit;

  if Assigned(FReader) then
    FReader.StopMe;
  FReader := nil;
end;

procedure TJMCardManager.ClearReaders(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FReaders.Count - 1 downto 0 do
  begin
    Dispose(PJMReaderItem(FReaders[nIdx]));
    FReaders.Delete(nIdx);
  end;

  if nFree then
    FReaders.Free;
  //xxxxx
end;

procedure TJMCardManager.ClearReceivers(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FReceivers.Count - 1 downto 0 do
  begin
    Dispose(PJMCardReceiver(FReceivers[nIdx]));
    FReceivers.Delete(nIdx);
  end;

  if nFree then
    FReceivers.Free;
  //xxxxx
end;

//Date: 2014-06-13
//Parm: �����¼�
//Desc: ���nEvent�����¼�
function TJMCardManager.AddReceiver(const nEvent: TJMCardEvent): Integer;
var nItem: PJMCardReceiver;
begin
  FSyncLock.Enter;
  try
    New(nItem);
    FReceivers.Add(nItem);

    Inc(FReceiverIDBase);
    Result := FReceiverIDBase;
    
    nItem.FID := FReceiverIDBase;
    nItem.FEvent := nEvent;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2014-06-13
//Parm: ��ʶ
//Desc: �Ƴ�nReceiverID�����¼�
procedure TJMCardManager.DelReceiver(const nReceiverID: Integer);
var nIdx: Integer;
    nItem: PJMCardReceiver;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FReceivers.Count - 1 downto 0 do
    begin
      nItem := FReceivers[nIdx];
      if nItem.FID <> nReceiverID then continue;

      Dispose(nItem);
      FReceivers.Delete(nIdx);
    end;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TJMCardManager.LoadConfig(const nFile: string);
var nIdx: Integer;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
    nReader: PJMReaderItem;
begin
  nXML := nil;
  FSyncLock.Enter;
  try
    nXML := TNativeXml.Create;
    nXML.LoadFromFile(nFile);
    ClearReaders(False);

    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nNode :=nXML.Root.Nodes[nIdx];
      New(nReader);
      FReaders.Add(nReader);

      with nNode,nReader^ do
      begin
        FEnable := NodeByName('enable').ValueAsString <> 'N';
        FID := AttributeByName['id'];
        FName := AttributeByName['name'];
        FType := TJMReaderType(NodeByName('type').ValueAsInteger);

        FHost := NodeByName('ip').ValueAsString;
        FPort := NodeByName('port').ValueAsInteger;
        FSock := 0;
        FAddr := 0;

        FCardFlag := NodeByName('cardflag').ValueAsString;
        FCardLen := NodeByName('cardlen').ValueAsInteger;
        FCardCut := NodeByName('cardcut').ValueAsInteger;

        nTmp := FindNode('cardfull');
        if Assigned(nTmp) then
             FCardFull := nTmp.ValueAsString = 'Y'
        else FCardFull := False;
      end;
    end;
  finally
    FSyncLock.Leave;
    nXML.Free;
  end;
end;

initialization
  gJMCardManager := nil;
finalization
  FreeAndNil(gJMCardManager);
end.
