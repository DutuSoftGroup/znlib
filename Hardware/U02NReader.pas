{*******************************************************************************
  ����: dmzn@163.com 2012-4-20
  ����: ��������02N��ͷ
*******************************************************************************}
unit U02NReader;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, UWaitItem, IdComponent, IdUDPBase,
  IdGlobal, IdUDPServer, IdSocketHandle, NativeXml, ULibFun, UMemDataPool,
  USysLoger;

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
    FOptions: TStrings;          //���Ӳ���
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

  TOnCard = procedure (const nCard: string; const nHost: PReaderHost);
  //��Ƭ�¼�

  T02NReader = class(TThread)
  private
    FReaders: TList;
    //��ͷ�б�
    FCards: TList;
    //�յ����б�
    FListA: TStrings;
    //�ַ��б�
    FKeepELabel: Integer;
    FKeepReadone: Integer;
    FKeepReadkeep: Integer;
    //��ʱ�ȴ�
    FSrvPort: Integer;
    FServer: TIdUDPServer;
    //�����
    FWaiter: TWaitObject;
    //�ȴ�����
    FIDCardData: Word;
    //���ݱ�ʶ
    FDefaultHost: TReaderHost;
    //Ĭ�϶�ͷ
    FSyncLock: TCriticalSection;
    //ͬ����
    FCardIn: TOnCard;
    FCardOut: TOnCard;
    //��Ƭ�¼�
  protected
    function DoReaderCard: Boolean;
    procedure Execute; override;
    //ִ���߳�
    procedure RegisterDataType;
    //ע������
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

procedure OnNew(const nFlag: string; const nType: Word; var nData: Pointer);
var nItem: PReaderCard;
begin
  if nFlag = 'NRCardData' then
  begin
    New(nItem);
    nData := nItem;
  end;
end;

procedure OnFree(const nFlag: string; const nType: Word; const nData: Pointer);
var nItem: PReaderCard;
begin
  if nFlag = 'NRCardData' then
  begin
    nItem := nData;
    Dispose(nItem);
  end;
end;

procedure T02NReader.RegisterDataType;
begin
  if not Assigned(gMemDataManager) then
    raise Exception.Create('02NReader Needs MemDataManager Support.');
  //xxxxx

  with gMemDataManager do
    FIDCardData := RegDataType('NRCardData', '02NReader', OnNew, OnFree, 2);
  //xxxxx
end;

//------------------------------------------------------------------------------
constructor T02NReader.Create;
begin
  RegisterDataType;
  //do first
  
  inherited Create(False);
  FreeOnTerminate := False;

  FListA := TStringList.Create;
  FReaders := TList.Create;
  FCards := TList.Create;

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

  FListA.Free;
  inherited;
end;

procedure T02NReader.ClearReader(const nFree: Boolean);
var nIdx: Integer;
    nHost: PReaderHost;
begin
  for nIdx:=FReaders.Count - 1 downto 0 do
  begin
    nHost := FReaders[nIdx];
    FreeAndNil(nHost.FOptions);
    
    Dispose(nHost);
    FReaders.Delete(nIdx);
  end;

  if nFree then
    FReaders.Free;
  //xxxxx
end;

procedure T02NReader.ClearCards(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FCards.Count - 1 downto 0 do
  begin
    gMemDataManager.UnLockData(FCards[nIdx]);
    FCards.Delete(nIdx);
  end;

  if nFree then
    FCards.Free;
  //xxxxx
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
    nMatch: Boolean;
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
        nMatch := nHost.FRealLabel = '';
        if not nMatch then
        begin
          SplitStr(nHost.FRealLabel, FListA, 0, ';');
          //multi real label

          for i:=FListA.Count-1 downto 0 do
          if Pos(FListA[i], nELabel) > 0 then
          begin
            nMatch := True;
            Break;
          end;
        end;

        if nHost.FEEnable and nMatch then
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

    FSrvPort := 1234;
    FKeepELabel := 300;
    FKeepReadone := 6000;
    FKeepReadkeep := 2000; //default value

    nTmp := nXML.Root.NodeByName('config');
    if Assigned(nTmp) then
    begin
      nTP := nTmp.FindNode('local_port');
      if Assigned(nTP) then
        FSrvPort := nTP.ValueAsInteger;
      //xxxxx

      nTP := nTmp.FindNode('keep_readone');
      if Assigned(nTP) then
        FKeepReadone := nTP.ValueAsInteger;
      //xxxxx

      nTP := nTmp.FindNode('keep_readkeep');
      if Assigned(nTP) then
        FKeepReadkeep := nTP.ValueAsInteger;
      //xxxxx

      nTP := nTmp.FindNode('keep_elabel');
      if Assigned(nTP) then
        FKeepELabel := nTP.ValueAsInteger;
      //xxxxx
    end;

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
          
          nTP := nNode.FindNode('type');
          if Assigned(nTP) then
          begin
            nInt := nTP.ValueAsInteger;
            if (nInt >= Ord(rfSite)) and (nInt <= Ord(rfOut)) then
              FFun := TReaderFunction(nInt);
            //xxxxx
          end;

          nTP := nNode.FindNode('printer');
          if Assigned(nTP) then
               FPrinter := nTP.ValueAsString
          else FPrinter := '';

          nTP := nNode.FindNode('options');
          if Assigned(nTP) then
          begin
            FOptions := TStringList.Create;
            SplitStr(nTP.ValueAsString, FOptions, 0, ';');
          end else FOptions := nil;
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
                                          
          nTP := nNode.FindNode('ledtext');
          if Assigned(nTP) then
               FLEDText := nTP.ValueAsString
          else FLEDText := 'NULL';

          nTP := nNode.FindNode('options');
          if Assigned(nTP) then
          begin
            FOptions := TStringList.Create;
            SplitStr(nTP.ValueAsString, FOptions, 0, ';');
          end else FOptions := nil;

          nNode := nNode.FindNode('uselabel');
          //ʹ�õ���ǩ
          if Assigned(nNode) then
               FEEnable := nNode.ValueAsString = 'Y'
          else FEEnable := False;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure T02NReader.Execute;
begin
  FillChar(FDefaultHost, SizeOf(FDefaultHost), #0);
  with FDefaultHost do
  begin
    FType := rtOnce;
    FFun := rfSite;
    FTunnel := '';
  end; //Ĭ�϶�ͷ,�������������ҵ��

  while not Terminated do
  try
    FWaiter.EnterWait;
    //xxxxx

    while True do
    begin
      if Terminated then Exit;
      if not DoReaderCard then Break;
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Desc: ִ��ҵ��
function T02NReader.DoReaderCard: Boolean;
var nIdx: Integer;
    nCard: string;
    nCardOut: Boolean;
    nHost: PReaderHost;
    nPCard: PReaderCard;
begin
  FSyncLock.Enter;
  try
    Result := False;
    nPCard := nil;
    //init

    for nIdx:=FCards.Count - 1 downto 0 do
    begin
      nPCard := FCards[nIdx];
      if nPCard.FOldOne then
      begin
        gMemDataManager.UnLockData(nPCard);
        nPCard := nil;

        FCards.Delete(nIdx);
        Continue;
      end; //����Ч

      if Assigned(nPCard.FHost) and (nPCard.FHost.FType = rtOnce) then
      begin
        if (nPCard.FEvent) and
           (GetTickCount - nPCard.FLast > FKeepReadone) then
        begin
          nPCard.FOldOne := True;
        end;
      end else //��ˢ������

      if Assigned(nPCard.FHost) and (nPCard.FHost.FType = rtKeep) then
      begin
        if GetTickCount - nPCard.FLast > FKeepReadkeep then
        begin
          nPCard.FEvent := False;
          nPCard.FOldOne := True;

          nPCard.FHost.FETimeOut := False;
          nPCard.FHost.FRealLabel := '';
          //��Ƭ����,���ҵ���ǩ
        end;

        if (nPCard.FHost.FEEnable) and             //ʹ�õ���ǩ
           (nPCard.FHost.FRealLabel <> '') and     
           (not nPCard.FHost.FETimeOut) and        //ҵ��δ��ʱ
           (GetTickCount - nPCard.FHost.FELast > FKeepELabel * 1000) then
        begin
          nPCard.FEvent := False;
          nPCard.FHost.FETimeOut := True;
        end;
      end; //��ˢ������

      if nPCard.FEvent then
           nPCard := nil
      else Break; //�ҵ��¿�
    end;

    if not Assigned(nPCard) then Exit;
    //û���账��Ƭ

    if Assigned(nPCard.FHost) then
         nHost := nPCard.FHost
    else nHost := @FDefaultHost;
    {----------------- +by dmzn@173.com 2012.09.01 -------------------------
     FHostΪ��,��ʾ�ôſ������������Ͷ�����������,�ڴ���ҵ��ǰ,�޷�
     ��֪�ôſ����ڵ�ͨ����.ϵͳ����Դǿ��Ϊ��װˢ��.
    -----------------------------------------------------------------------}
                                                                     
    nCardOut := (nPCard.FOldOne) or
                (Assigned(nPCard.FHost) and nPCard.FHost.FETimeOut);
    //��Ƭ����,�����ǩ��ʱ

    nCard := nPCard.FCard;
    nPCard.FEvent := True; 
    Result := True;
  finally
    FSyncLock.Leave;
  end;

  if nCardOut then
  begin
    if Assigned(FCardOut) then FCardOut(nCard, nHost);
  end else
  begin
    if Assigned(FCardIn) then FCardIn(nCard, nHost);
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

      if GetTickCount - nPCard.FLast >= 2 * 1000 then
      begin
        nPCard.FEvent := False;
        //�������Ч
      end;
    end else
    begin
      nPCard := gMemDataManager.LockData(FIDCardData);
      //new lock
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
  g02NReader := nil;
finalization
  FreeAndNil(g02NReader);
end.
