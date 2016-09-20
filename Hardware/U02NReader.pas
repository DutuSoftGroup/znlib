{*******************************************************************************
  ����: dmzn@163.com 2012-4-20
  ����: ��������02N��ͷ
*******************************************************************************}
unit U02NReader;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, UWaitItem, IdComponent, IdUDPBase,
  IdGlobal, IdUDPServer, IdSocketHandle, NativeXml, ULibFun, USysLoger;

type
  TReaderType = (rtOnce, rtKeep);
  //����: ���ζ�;������
  TReaderFunction = (rfSite, rfIn, rfOut);
  //����: �ֳ�;����;����

  PReaderHost = ^TReaderHost;
  TReaderHost = record
    FID     : string;            //��ʶ
    FIP     : string;            //��ַ
    FPort   : Integer;           //�˿�
    FType   : TReaderType;       //����
    FFun    : TReaderFunction;   //����
    FTunnel : string;            //ͨ��
    FPrinter: string;            //��ӡ
    FLEDText: string;            //LED

    FEEnable: Boolean;           //���õ���ǩ
    FELabel : string;            //ͨ����ȡ�ĵ��ӱ�ǩ
    FELast  : Int64;             //�ϴδ���
    FETimeOut: Boolean;          //����ǩ��ʱ
    FRealLabel: string;          //ʵ��ҵ��ĵ��ӱ�ǩ

    FPrepare: Boolean;           //Ԥװ������
  end;

  PReaderCard = ^TReaderCard;
  TReaderCard = record
    FHost   : PReaderHost;       //��ͷ
    FCard   : string;            //����
    FOldOne : Boolean;           //��ʱ��

    FEvent  : Boolean;           //�Ѵ���
    FLast   : Int64;             //�ϴδ���
    FInTime : Int64;             //�״�ʱ��
  end;

  TOnCard = procedure (nHost: TReaderHost; nCard: TReaderCard);
  //��Ƭ�¼�

  T02NReader = class(TThread)
  private
    FReaders: TList;
    //��ͷ�б�
    FCards: TList;
    //�յ����б�
    FKeepTime: Integer;
    //��ʱ�ȴ�
    FSrvPort: Integer;
    FServer: TIdUDPServer;
    //�����
    FWaiter: TWaitObject;
    //�ȴ�����
    FSyncLock: TCriticalSection;
    //ͬ����
    FCardIn: TOnCard;
    FCardOut: TOnCard;
    //��Ƭ�¼�
  protected
    procedure Execute; override;
    //ִ���߳�
    procedure OnUDPRead(AThread: TIdUDPListenerThread; AData: TIdBytes;
      ABinding: TIdSocketHandle);
    //��ȡ����
    procedure ClearReader(const nFree: Boolean);
    procedure ClearCards(const nFree: Boolean);
    //������Դ
    function GetReader(const nID,nIP: string): Integer;
    //������ͷ
    procedure GetACard(const nIP,nCard: string);
    //���п���
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��������
    procedure StartReader(const nPort: Integer = 0);
    procedure StopReader;
    procedure StopMe(const nFree: Boolean = True);
    //��ͣ��ͷ
    procedure SetReaderCard(const nReader,nCard: string);
    //���Ϳ���
    procedure SetRealELabel(const nTunnel,nELabel: string);
    procedure ActiveELabel(const nTunnel,nELabel: string);
    //�������ǩ
    property ServerPort: Integer read FSrvPort write FSrvPort;
    property KeepTime: Integer read FKeepTime write FKeepTime;
    property OnCardIn: TOnCard read FCardIn write FCardIn;
    property OnCardOut: TOnCard read FCardOut write FCardOut;
    //�������
  end;

var
  g02NReader: T02NReader = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(T02NReader, '�ֳ����������', nEvent);
end;

constructor T02NReader.Create;
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FReaders := TList.Create;
  FCards := TList.Create;
  FKeepTime := 2 * 1000;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := INFINITE;
  FSyncLock := TCriticalSection.Create;

  FServer := TIdUDPServer.Create;
  FServer.OnUDPRead := OnUDPRead;
end;

destructor T02NReader.Destroy;
begin
  StopMe(False);
  FServer.Active := False;
  FServer.Free;

  ClearCards(True);
  ClearReader(True);
  //xxxxx

  FWaiter.Free;
  FSyncLock.Free;
  inherited;
end;

procedure T02NReader.ClearReader(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FReaders.Count - 1 downto 0 do
  begin
    Dispose(PReaderHost(FReaders[nIdx]));
    FReaders.Delete(nIdx);
  end;

  if nFree then FReaders.Free;
end;

procedure T02NReader.ClearCards(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FCards.Count - 1 downto 0 do
  begin
    Dispose(PReaderCard(FCards[nIdx]));
    FCards.Delete(nIdx);
  end;

  if nFree then FCards.Free;
end;

procedure T02NReader.StopMe(const nFree: Boolean);
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  if nFree then
    Free;
  //xxxxx
end;

procedure T02NReader.StartReader(const nPort: Integer);
begin
  if nPort > 0 then
    FSrvPort := nPort;
  //new port

  FServer.Active := False;
  FServer.DefaultPort := FSrvPort;
  FServer.Active := True;

  FWaiter.Interval := 500;
  FWaiter.Wakeup;
end;

procedure T02NReader.StopReader;
begin
  FServer.Active := False;
  FWaiter.Interval := INFINITE;
end;

//Date: 2015-12-05
//Parm: ��ͷ��ַ;�ſ���
//Desc: ��nReader���Ϳ���nCard,����ˢ��ҵ��
procedure T02NReader.SetReaderCard(const nReader, nCard: string);
begin
  GetACard(nReader, nCard);
end;

//Date: 2015-01-11
//Parm: ����ǩ��
//Desc: ����nELabel�ʱ��
procedure T02NReader.ActiveELabel(const nTunnel,nELabel: string);
var i,nIdx: Integer;
    nHost: PReaderHost;
    nCard: PReaderCard;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FReaders.Count - 1 downto 0 do
    begin
      nHost := FReaders[nIdx];
      if CompareText(nTunnel, nHost.FTunnel) = 0 then
      begin
        if nHost.FEEnable and (
          (nHost.FRealLabel = '') or (Pos(nHost.FRealLabel, nELabel) > 0)) then
        begin
          nHost.FELabel := nELabel;
          nHost.FELast := GetTickCount;

          if nHost.FETimeOut then
          begin
            nHost.FETimeOut := False;
            //�����ʱ

            for i:=FCards.Count - 1 downto 0 do
            begin
              nCard := FCards[i];
              if nCard.FHost <> nHost then Continue;

              nCard.FEvent := False;
              //���´���ҵ��
            end;            
          end;
        end;
        
        Exit;
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2015-01-11
//Parm: ͨ����;����ǩ
//Desc: ����nCard��Ӧ�ĵ���ǩ
procedure T02NReader.SetRealELabel(const nTunnel, nELabel: string);
var nIdx: Integer;
    nHost: PReaderHost;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FReaders.Count - 1 downto 0 do
    begin
      nHost := FReaders[nIdx];
      if CompareText(nTunnel, nHost.FTunnel) = 0 then
      begin
        nHost.FELast := GetTickCount;
        nHost.FETimeOut := False;

        nHost.FRealLabel := nELabel;
        Exit;
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

procedure T02NReader.LoadConfig(const nFile: string);
var nIdx,nInt: Integer;
    nXML: TNativeXml;
    nHost: PReaderHost;
    nNode,nTmp,nTP: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    ClearReader(False);
    nXML.LoadFromFile(nFile);

    nTmp := nXML.Root.NodeByName('local_udp');
    if Assigned(nTmp) then
         FSrvPort := nTmp.ValueAsInteger
    else FSrvPort := 1234;

    nTmp := nXML.Root.NodeByName('readone');
    if Assigned(nTmp) then
    begin
      for nIdx:=0 to nTmp.NodeCount - 1 do
      begin
        New(nHost);
        FReaders.Add(nHost);

        nNode := nTmp.Nodes[nIdx];
        with nHost^ do
        begin
          FType := rtOnce;
          FID := nNode.NodeByName('id').ValueAsString;
          FIP := nNode.NodeByName('ip').ValueAsString;
          FPort := nNode.NodeByName('port').ValueAsInteger;

          FTunnel := nNode.NodeByName('tunnel').ValueAsString;
          FEEnable := False;

          FFun := rfSite;
          nTP := nNode.NodeByName('type');

          if Assigned(nTP) then
          begin
            nInt := nTP.ValueAsInteger;
            if (nInt >= Ord(rfSite)) and (nInt <= Ord(rfOut)) then
              FFun := TReaderFunction(nInt);
            //xxxxx
          end;

          nTP := nNode.NodeByName('printer');
          if Assigned(nTP) then
               FPrinter := nTP.ValueAsString
          else FPrinter := '';

          nTP := nNode.NodeByName('prepare');
          if Assigned(nTP) then
               FPrepare := UpperCase(nTP.ValueAsString) = 'Y'
          else FPrepare := False;
        end;
      end;
    end;

    nTmp := nXML.Root.NodeByName('readkeep');
    if Assigned(nTmp) then
    begin
      for nIdx:=0 to nTmp.NodeCount - 1 do
      begin
        New(nHost);
        FReaders.Add(nHost);

        nNode := nTmp.Nodes[nIdx];
        with nHost^ do
        begin
          FType := rtKeep;
          FID := nNode.NodeByName('id').ValueAsString;
          FIP := nNode.NodeByName('ip').ValueAsString;
          FPort := nNode.NodeByName('port').ValueAsInteger;
          FTunnel := nNode.NodeByName('tunnel').ValueAsString;
                                          
          nTP := nNode.NodeByName('ledtext');
          if Assigned(nTP) then
               FLEDText := nTP.ValueAsString
          else FLEDText := '  ��Ʒˮ��  ' + '  ֵ������  ';

          nTP := nNode.NodeByName('prepare');
          if Assigned(nTP) then
               FPrepare := UpperCase(nTP.ValueAsString) = 'Y'
          else FPrepare := False;

          nNode := nNode.FindNode('uselabel');
          //ʹ�õ���ǩ
          if Assigned(nNode) then
               FEEnable := nNode.ValueAsString <> 'N'
          else FEEnable := True; 
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure T02NReader.Execute;
var nIdx: Integer;
    nHost: TReaderHost;
    nCard: TReaderCard;
    nPCard: PReaderCard;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    while True do
    begin
      FSyncLock.Enter;
      try
        nPCard := nil;
        for nIdx:=FCards.Count - 1 downto 0 do
        begin
          nPCard := FCards[nIdx];
          if nPCard.FOldOne then
          begin
            Dispose(nPCard);
            nPCard := nil;

            FCards.Delete(nIdx);
            Continue;
          end; //����Ч

          if Assigned(nPCard.FHost) and (nPCard.FHost.FType = rtKeep) then
          begin
            if GetTickCount - nPCard.FLast > FKeepTime then
            begin
              nPCard.FEvent := False;
              nPCard.FOldOne := True;

              nPCard.FHost.FRealLabel := '';
              //��Ƭ����,���ҵ���ǩ
            end;

            if nPCard.FHost.FEEnable and (nPCard.FHost.FRealLabel <> '') and //ʹ�õ���ǩ
               (not nPCard.FHost.FETimeOut) and                              //ҵ��δ��ʱ
               (GetTickCount - nPCard.FHost.FELast > 5 * 60 * 1000) then
            begin
              nPCard.FEvent := False;
              nPCard.FHost.FETimeOut := True;
            end;
          end; //�ѳ�ʱ

          if nPCard.FEvent then
               nPCard := nil
          else Break;
        end;

        if Assigned(nPCard) then
        begin
          nPCard.FEvent := True;
          nCard := nPCard^;

          if Assigned(nPCard.FHost) then
          begin
            nHost := nPCard.FHost^;
          end else
          begin
            nHost.FType := rtOnce;
            nHost.FFun := rfSite;
            nHost.FTunnel := '';
          end;
          {----------------- +by dmzn@173.com 2012.09.01 -----------------
           FHostΪ��,��ʾ�ôſ������������Ͷ�����������,�ڴ���ҵ��ǰ,�޷�
           ��֪�ôſ����ڵ�ͨ����.ϵͳ����Դǿ��Ϊ��װˢ��.
          ----------------------------------------------------------------}
        end else Break;
      finally
        FSyncLock.Leave;
      end;

      if nCard.FOldOne or
         (Assigned(nPCard.FHost) and nPCard.FHost.FETimeOut) then
      begin
        if Assigned(FCardOut) then FCardOut(nHost, nCard);
      end else
      begin
        if Assigned(FCardIn) then FCardIn(nHost, nCard);
      end;
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Desc: ������ͷ(��������)
function T02NReader.GetReader(const nID,nIP: string): Integer;
var nIdx: Integer;
    nHost: PReaderHost;
begin
  Result := -1;

  for nIdx:=FReaders.Count - 1 downto 0 do
  begin
    nHost := FReaders[nIdx];
    if (nID <> '') and (CompareText(nID, nHost.FID) = 0) then
    begin
      Result := nIdx;
      Exit;
    end;

    if (nIP <> '') and (CompareText(nIP, nHost.FIP) = 0) then
    begin
      Result := nIdx;
      Exit;
    end;
  end;
end;

//Desc: �յ�nIP�ϴ���nCard��Ƭ
procedure T02NReader.GetACard(const nIP, nCard: string);
var nIdx,nInt: Integer;
    nPCard: PReaderCard;
begin
  FSyncLock.Enter;
  try
    if nIP <> '' then
    begin
      nInt := GetReader('', nIP);
      if nInt < 0 then Exit;
    end else nInt := -1;
             
    nPCard := nil;
    //default

    for nIdx:=FCards.Count - 1 downto 0 do
    begin
      nPCard := FCards[nIdx];
      if CompareText(nCard, nPCard.FCard) = 0 then
           Break
      else nPCard := nil;
    end;

    if Assigned(nPCard) then
    begin
      if nInt < 0 then
      begin
        nPCard.FHost := nil;
        nPCard.FEvent := False;
      end else

      if nPCard.FHost <> FReaders[nInt] then
      begin
        nPCard.FHost := FReaders[nInt];
        nPCard.FEvent := False;
        //��������
      end;
      {
      if nPCard.FHost.FType = rtOnce then
      begin
        nPCard.FEvent := False;
        //���ζ�ÿ��ˢ��Ч
      end;
      }
      if GetTickCount - nPCard.FLast >= 2 * 1000 then
      begin
        nPCard.FEvent := False;
        //�������Ч
      end;
    end else
    begin
      New(nPCard);
      FCards.Add(nPCard);

      if nInt >= 0 then
      begin
        nPCard.FHost := FReaders[nInt];
        nPCard.FHost.FRealLabel := '';
        nPCard.FHost.FETimeOut := False;
      end else nPCard.FHost := nil;

      nPCard.FCard := nCard;
      nPCard.FEvent := False;
      nPCard.FInTime := GetTickCount;
    end;

    nPCard.FOldOne := False;
    nPCard.FLast := GetTickCount;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2012-4-22
//Parm: 16λ��������
//Desc: ��ʽ��nCardΪ��׼����
function ParseCardNO(const nCard: string; const nHex: Boolean): string;
var nInt: Int64;
    nIdx: Integer;
begin
  if nHex then
  begin
    Result := '';
    for nIdx:=1 to Length(nCard) do
      Result := Result + IntToHex(Ord(nCard[nIdx]), 2);
    //xxxxx
  end else Result := nCard;

  nInt := StrToInt64('$' + Result);
  Result := IntToStr(nInt);
  Result := StringOfChar('0', 12 - Length(Result)) + Result;
end;

procedure T02NReader.OnUDPRead(AThread: TIdUDPListenerThread;
  AData: TIdBytes; ABinding: TIdSocketHandle);
var nStr,nCard: string;
    nIdx: Integer;
begin
  nStr := '';
  for nIdx:=Low(AData) to High(AData) do
    nStr := nStr + IntToHex(AData[nIdx], 2);
  //xxxxx

  if (Pos('BBFF01', nStr) = 1) and (Length(nStr) >= 14) then
  begin
    nStr := Copy(nStr, 7, 14);
    GetACard(ABinding.PeerIP, ParseCardNO(nStr, False));
  end else
  begin
    nStr := BytesToString(AData);
    if (Pos('+', nStr) <> 1) or (Length(nStr) < 12) then Exit;

    System.Delete(nStr, 1, 1);
    nIdx := Pos('+', nStr);

    if nIdx > 0 then
    begin
      nCard := Copy(nStr, 1, nIdx - 1);
      System.Delete(nStr, 1, nIdx);
    end else
    begin
      nCard := nStr;
      nStr := '';
    end;

    GetACard(nStr, nCard);
    //parse card

    FServer.Send(ABinding.PeerIP, ABinding.PeerPort, 'Y');
    //respond
  end;
end;

initialization
  g02NReader := T02NReader.Create;
finalization
  FreeAndNil(g02NReader);
end.
