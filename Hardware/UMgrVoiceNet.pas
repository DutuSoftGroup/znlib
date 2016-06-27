{*******************************************************************************
  ����: dmzn@163.com 2015-04-21
  ����: ����������ϳ�������Ԫ
*******************************************************************************}
unit UMgrVoiceNet;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, IdComponent, IdTCPConnection, IdGlobal,
  IdTCPClient, IdSocketHandle, NativeXml, UWaitItem, ULibFun, USysLoger;

const
  cVoice_CMD_Head       = $FD;         //֡ͷ
  cVoice_CMD_Play       = $01;         //����
  cVoice_CMD_Stop       = $02;         //ֹͣ
  cVoice_CMD_Pause      = $03;         //��ͣ
  cVoice_CMD_Resume     = $04;         //����
  cVoice_CMD_QStatus    = $21;         //��ѯ
  cVoice_CMD_StandBy    = $22;         //����
  cVoice_CMD_Wakeup     = $FF;         //����

  cVoice_Code_GB2312    = $00;
  cVoice_Code_GBK       = $01;
  cVoice_Code_BIG5      = $02;
  cVoice_Code_Unicode   = $03;         //����

  cVoice_FrameInterval  = 10;          //֡���
  cVoice_ContentLen     = 4096;        //�ı�����

type
  TVoiceWord = record
   FH: Byte;
   FL: Byte;
  end;

  PVoiceDataItem = ^TVoiceDataItem;
  TVoiceDataItem = record
    FHead     : Byte;                  //֡ͷ
    FLength   : TVoiceWord;            //���ݳ���
    FCommand  : Byte;                  //������
    FParam    : Byte;                  //�������
    FContent  : array[0..cVoice_ContentLen-1] of Char;
  end;

  PVoiceContentParam = ^TVoiceContentParam;
  TVoiceContentParam = record
    FID       : string;                //���ݱ�ʶ
    FObject   : string;                //�����ʶ
    FSleep    : Integer;               //������
    FText     : string;                //��������
    FTimes    : Integer;               //�ط�����
    FInterval : Integer;               //�ط����
    FRepeat   : Integer;               //�����ظ�
    FReInterval: Integer;              //���μ��
  end;

  PVoiceResource = ^TVoiceResource;
  TVoiceResource = record
    FKey      : string;                //������
    FValue    : string;                //��������
  end;

  PVoiceContentNormal = ^TVoiceContentNormal;
  TVoiceContentNormal = record
    FText     : string;                //�������ı�
    FCard     : string;                //ִ��������
    FContent  : string;                //ִ�����ݱ�ʶ
  end;

  PVoiceCardHost = ^TVoiceCardHost;
  TVoiceCardHost = record
    FID       : string;                //����ʶ
    FName     : string;                //������
    FHost     : string;                //����ַ
    FPort     : Integer;               //���˿�
    FEnable   : Boolean;               //�Ƿ�����
    FContent  : TList;                 //��������
    FResource : TList;                 //��Դ����

    FVoiceData: TVoiceDataItem;        //��������
    FVoiceLast: Int64;                 //�ϴβ���
    FVoiceTime: Byte;                  //��������
    FParam    : PVoiceContentParam;    //��������
  end;

type
  TNetVoiceManager = class;
  TNetVoiceConnector = class(TThread)
  private
    FOwner: TNetVoiceManager;
    //ӵ����
    FWaiter: TWaitObject;
    //�ȴ�����
    FClient: TIdTCPClient;
    //�������
    FListA: TStrings;
    //�ַ��б�
  protected
    procedure Execute; override;
    procedure Doexecute;
    //ִ���߳�
    procedure CombineBuffer;
    //�ϲ�����
    procedure DisconnectClient;
    procedure SendVoiceData(const nCard: PVoiceCardHost);
    //��������
  public
    constructor Create(AOwner: TNetVoiceManager);
    destructor Destroy; override;
    //�����ͷ�
    procedure WakupMe;
    //�����߳�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TNetVoiceManager = class(TObject)
  private
    FCards: TList;
    //�������б�
    FBuffer: TList;
    //���ݻ���
    FVoicer: TNetVoiceConnector;
    //��������
    FSyncLock: TCriticalSection;
    //ͬ����
  protected
    procedure ClearDataList(const nList: TList; const nFree: Boolean = False);
    //������
    function FindContentParam(const nCard: PVoiceCardHost;
      const nID: string): PVoiceContentParam;
    function FindCardHost(const nID: string): PVoiceCardHost;
    //��������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��ȡ����
    procedure StartVoice;
    procedure StopVoice;
    //��ͣ��ȡ
    procedure PlayVoice(const nText: string; const nCard: string = '';
      const nContent: string = '');
    //��������
  end;

var
  gNetVoiceHelper: TNetVoiceManager = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TNetVoiceManager, '���������ϳ�', nEvent);
end;

function Word2Voice(const nWord: Word): TVoiceWord;
var nByte: Byte;
begin
  Result := TVoiceWord(nWord);
  nByte := Result.FH;

  Result.FH := Result.FL;
  Result.FL := nByte;
end;

function Voice2Word(const nVoice: TVoiceWord): Word;
var nVW: TVoiceWord;
begin
  nVW.FH := nVoice.FL;
  nVW.FL := nVoice.FH;
  Result := Word(nVW); 
end;

//------------------------------------------------------------------------------
constructor TNetVoiceManager.Create;
begin
  FCards := TList.Create;
  FBuffer := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TNetVoiceManager.Destroy;
begin
  StopVoice;
  ClearDataList(FBuffer, True);
  
  ClearDataList(FCards, True);
  FSyncLock.Free;
  inherited;
end;

//Date: 2015-04-23
//Parm: �б�;�Ƿ��ͷ�
//Desc: ����nList�б�
procedure TNetVoiceManager.ClearDataList(const nList: TList;
 const nFree: Boolean);
var i,nIdx: Integer;
    nCard: PVoiceCardHost;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    if nList = FCards then
    begin
      nCard := nList[nIdx];
      //card host

      if Assigned(nCard.FContent) then
      begin
        for i:=nCard.FContent.Count - 1 downto 0 do
          Dispose(PVoiceContentParam(nCard.FContent[i]));
        nCard.FContent.Free;
      end;

      if Assigned(nCard.FResource) then
      begin
        for i:=nCard.FResource.Count - 1 downto 0 do
          Dispose(PVoiceResource(nCard.FResource[i]));
        nCard.FResource.Free;
      end;

      Dispose(nCard);
      nList.Delete(nIdx);
    end else

    if nList = FBuffer then
    begin
      Dispose(PVoiceContentNormal(nList[nIdx]));
      nList.Delete(nIdx);
    end;
  end;

  if nFree then
    nList.Free;
  //xxxxx
end;

procedure TNetVoiceManager.StartVoice;
begin
  if FCards.Count < 1 then
    raise Exception.Create('Voice Card List Is Null.');
  //xxxxx

  if not Assigned(FVoicer) then
    FVoicer := TNetVoiceConnector.Create(Self);
  FVoicer.WakupMe;
end;

procedure TNetVoiceManager.StopVoice;
var nIdx: Integer;
begin
  if Assigned(FVoicer) then
    FVoicer.StopMe;
  FVoicer := nil;

  ClearDataList(FBuffer);
  //��������ͻ���

  for nIdx:=FCards.Count - 1 downto 0 do
    PVoiceCardHost(FCards[nIdx]).FVoiceTime := MAXBYTE;
  //�رշ��ͱ��
end;

//Date: 2015-04-23
//Parm: ��������ʶ
//Desc: ������ʶΪnID��������
function TNetVoiceManager.FindCardHost(const nID: string): PVoiceCardHost;
var nIdx: Integer;
begin
  Result := FCards[0];
  //default is first

  for nIdx:=FCards.Count - 1 downto 0 do
  if CompareText(nID, PVoiceCardHost(FCards[nIdx]).FID) = 0 then
  begin
    Result := FCards[nIdx];
    Break;
  end;
end;

//Date: 2015-04-23
//Parm: ������;���ݱ�ʶ
//Desc: ��nCard�м�����ʶΪnID����������
function TNetVoiceManager.FindContentParam(const nCard: PVoiceCardHost;
  const nID: string): PVoiceContentParam;
var nIdx: Integer;
begin
  if nCard.FContent.Count > 0 then
       Result := nCard.FContent[0]
  else Result := nil;

  for nIdx:=nCard.FContent.Count - 1 downto 0 do
  if CompareText(nID, PVoiceContentParam(nCard.FContent[nIdx]).FID) = 0 then
  begin
    Result := nCard.FContent[nIdx];
    Break;
  end;
end;

//Date: 2015-04-23
//Parm: �ı�;��������ʶ;�������ñ�ʶ
//Desc: ��nCard����ʹ��nContent���������nText,д�뻺��ȴ�����
procedure TNetVoiceManager.PlayVoice(const nText, nCard, nContent: string);
var nData: PVoiceContentNormal;
begin
  if not Assigned(FVoicer) then
    raise Exception.Create('Voice Service Should Start First.');
  //xxxxx

  if Length(nText) < 1 then Exit;
  //invalid text

  FSyncLock.Enter;
  try
    New(nData);
    FBuffer.Add(nData);

    nData.FText := nText;
    nData.FCard := nCard;
    nData.FContent := nContent;
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2015-04-23
//Parm: �����ļ�
//Desc: ��ȡnFile�����ļ�
procedure TNetVoiceManager.LoadConfig(const nFile: string);
var i,nIdx: Integer;
    nXML: TNativeXml;
    nRoot,nNode,nTmp: TXmlNode;
    
    nCard: PVoiceCardHost;
    nParam: PVoiceContentParam;
    nRes: PVoiceResource;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nRoot := nXML.Root.Nodes[nIdx];
      New(nCard);
      FCards.Add(nCard);

      nCard.FVoiceTime := MAXBYTE;
      //��ǲ�����

      with nRoot do
      begin
        nCard.FID     := AttributeByName['id'];
        nCard.FName   := AttributeByName['name'];
        nCard.FHost   := NodeByName('ip').ValueAsString;
        nCard.FPort   := NodeByName('port').ValueAsInteger;
        nCard.FEnable := NodeByName('enable').ValueAsInteger = 1;
      end;

      nNode := nRoot.FindNode('contents');
      if Assigned(nNode) then
      begin
        nCard.FContent := TList.Create;
        //contents

        for i:=0 to nNode.NodeCount - 1 do
        begin
          nTmp := nNode.Nodes[i];
          New(nParam);
          nCard.FContent.Add(nParam);

          with nTmp do
          begin
            nParam.FID       := AttributeByName['id'];
            nParam.FObject   := NodeByName('object').ValueAsString;
            nParam.FSleep    := NodeByName('sleep').ValueAsInteger;
            nParam.FText     := NodeByName('text').ValueAsString;
            nParam.FTimes    := NodeByName('times').ValueAsInteger;
            nParam.FInterval := NodeByName('interval').ValueAsInteger;

            nParam.FRepeat   := NodeByName('repeat').ValueAsInteger;
            nParam.FReInterval := NodeByName('reinterval').ValueAsInteger;
          end;
        end;
      end else nCard.FContent := nil;

      nNode := nRoot.FindNode('resource');
      if Assigned(nNode) then
      begin
        nCard.FResource := TList.Create;
        //resource

        for i:=nNode.NodeCount - 1 downto 0 do
        begin
          nTmp := nNode.Nodes[i];
          New(nRes);
          nCard.FResource.Add(nRes);

          nRes.FKey   := nTmp.AttributeByName['key'];
          nRes.FValue := nTmp.AttributeByName['value'];
        end;
      end else nCard.FResource := nil;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TNetVoiceConnector.Create(AOwner: TNetVoiceManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 1000;

  FClient := TIdTCPClient.Create(nil);
  FClient.ReadTimeout := 3 * 1000;
  FClient.ConnectTimeout := 3 * 1000;
end;

destructor TNetVoiceConnector.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;

  FWaiter.Free;
  FListA.Free;
  inherited;
end;

procedure TNetVoiceConnector.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TNetVoiceConnector.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

//Desc: �Ͽ��׽���
procedure TNetVoiceConnector.DisconnectClient;
begin
  FClient.Disconnect;
  if Assigned(FClient.IOHandler) then
    FClient.IOHandler.InputBuffer.Clear;
  //try to swtich connection
end;

procedure TNetVoiceConnector.Execute;
begin
  while True do
  try
    FWaiter.EnterWait;
    if Terminated then
    begin
      DisconnectClient;
      Exit;
    end;

    Doexecute;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

procedure TNetVoiceConnector.Doexecute;
var nStr: string;
    nIdx: Integer;
    nCard: PVoiceCardHost;
begin
  with FOwner do
  begin
    FSyncLock.Enter;
    try
      CombineBuffer;
    finally
      FSyncLock.Leave;
    end;

    nCard := nil;
    //init

    for nIdx:=FCards.Count - 1 downto 0 do
    try
      if Terminated then Exit;
      nCard := FCards[nIdx];
      SendVoiceData(nCard);
    except
      on E: Exception do
      begin
        if Assigned(nCard) then
        begin
          nCard.FVoiceTime := nCard.FVoiceTime + 1;
          //�����ۼ�

          nStr := 'Card:[ %s:%d ] Msg: %s';
          nStr := Format(nStr, [nCard.FHost, nCard.FPort, E.Message]);
          WriteLog(nStr);
        end;

        DisconnectClient;
        //�Ͽ���·
      end;
    end;
  end;
end;

//Desc: �����ͻ������ݺϲ�������������
procedure TNetVoiceConnector.CombineBuffer;
var nStr: string;
    i,nIdx,nLen: Integer;

    nCard: PVoiceCardHost;
    nRes: PVoiceResource;
    nParm: PVoiceContentParam;
    nTxt: PVoiceContentNormal;
begin
  with FOwner do
  begin
    for nIdx:=0 to FBuffer.Count - 1 do
    begin
      nTxt := FBuffer[nIdx];
      nCard := FindCardHost(nTxt.FCard);

      if not Assigned(nCard) then
      begin
        nStr := '������[ %s ]��ʶ������.';
        nStr := Format(nStr, [nTxt.FCard]);

        WriteLog(nStr);
        Continue;
      end;

      if not nCard.FEnable then
      begin
        nStr := '������[ %s ]��ͣ��.';;
        nStr := Format(nStr, [nCard.FID]);

        WriteLog(nStr);
        Continue;
      end;

      nParm := FindContentParam(nCard, nTxt.FContent);
      if not Assigned(nParm) then
      begin
        nStr := '������[ %s:%s ]���ݱ�ʶ������.';;
        nStr := Format(nStr, [nCard.FID, nTxt.FContent]);

        WriteLog(nStr);
        Continue;
      end;

      //------------------------------------------------------------------------
      SplitStr(nTxt.FText, FListA, 0, #9, False);
      //���: YA001 #9 YA002

      for i:=FListA.Count - 1 downto 0 do
      begin
        FListA[i] := Trim(FListA[i]);
        if FListA[i] = '' then
          FListA.Delete(i);
        //�������
      end;

      if (FListA.Count > 1) or (nTxt.FText[1] = #9) then
      begin
        nStr := '';
        nLen := FListA.Count - 1;

        for i:=0 to nLen do
        if Trim(FListA[i]) <> '' then
        begin
          if nIdx = nLen then
               nStr := nStr + FListA[i]
          else nStr := nStr + FListA[i] + Format('[p%d]', [nParm.FSleep]);
        end;

        nStr := StringReplace(nParm.FText, nParm.FObject, nStr,
                                           [rfReplaceAll, rfIgnoreCase]);
        //text real content
      end else nStr := nTxt.FText;

      for i:=nCard.FResource.Count - 1 downto 0 do
      begin
        nRes := nCard.FResource[i];
        nStr := StringReplace(nStr, nRes.FKey, nRes.FValue,
                                    [rfReplaceAll, rfIgnoreCase]);
        //resource replace
      end;

      for i:=2 to nParm.FRepeat do
        nStr := nStr + Format('[p%d]', [nParm.FReInterval]) + nStr;
      //xxxxx

      //------------------------------------------------------------------------

      with nCard.FVoiceData do
      begin
        FHead := cVoice_CMD_Head;
        FCommand := cVoice_CMD_Play;
        FParam := cVoice_Code_GB2312;

        nStr := '[m3]' + nStr + '[d]';
        StrPCopy(@FContent[0], nStr);
        FLength := Word2Voice(Length(nStr) + 2);

        nCard.FParam := nParm;
        nCard.FVoiceLast := 0;
        nCard.FVoiceTime := 0;
      end;
    end;

    ClearDataList(FBuffer);
    //��ջ���
  end;
end;

//Date: 2015-04-23
//Parm: ������
//Desc: ��nCard���ͻ���������
procedure TNetVoiceConnector.SendVoiceData(const nCard: PVoiceCardHost);
var nBuf: TIdBytes;
begin
  if nCard.FVoiceTime = MAXBYTE then Exit;
  //�����ͱ��
  if nCard.FVoiceTime >= nCard.FParam.FTimes then Exit;
  //���ʹ������
  if GetTickCount - nCard.FVoiceLast < nCard.FParam.FInterval * 1000 then Exit;
  //���ͼ��δ��

  if FClient.Host <> nCard.FHost then
  begin
    DisconnectClient;
    FClient.Host := nCard.FHost;
    FClient.Port := nCard.FPort;
  end;

  if not FClient.Connected then
    FClient.Connect;
  //xxxxx

  SetLength(nBuf, 0);
  nBuf := RawToBytes(nCard.FVoiceData, Voice2Word(nCard.FVoiceData.FLength) + 3);
  //���ݻ���

  FClient.IOHandler.Write(nBuf);
  Sleep(cVoice_FrameInterval);
  //���Ͳ��ȴ�

  nCard.FVoiceLast := GetTickCount;
  nCard.FVoiceTime := nCard.FVoiceTime + 1;
  //������
end;

initialization
  gNetVoiceHelper := nil;
finalization
  FreeAndNil(gNetVoiceHelper);
end.
