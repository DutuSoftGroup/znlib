{*******************************************************************************
  ����: dmzn@163.com 2012-4-21
  ����: �����ϳ�
*******************************************************************************}
unit UMgrVoice;

{$I Link.Inc}
interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, USysLoger, UWaitItem,
  ULibFun, CPort, CPortTypes;

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

  PVoiceBase = ^TVoiceBase;
  TVoiceBase = record
    FHead     : Byte;                  //֡ͷ
    FLength   : TVoiceWord;            //���ݳ���
    FCommand  : Byte;                  //������
    FParam    : Byte;                  //�������
  end;

  PVoiceText = ^TVoiceText;
  TVoiceText = record
    FBase     : TVoiceBase;
    FContent  : array[0..cVoice_ContentLen-1] of Char;
  end;

  TVoiceParam = record
    FTruck    : string;                //������ʶ
    FSleep    : Integer;               //���ż��
    FText     : string;                //��������
    FTimes    : Integer;               //�ط�����
    FInterval : Integer;               //�ط����
    FRepeat   : Integer;               //�����ظ�
    FReInterval: Integer;              //���μ��
    FVoiceLast: Int64;                 //�ϴβ���
    FVoiceTime: Byte;                  //��������
  end;

  TVoiceComport = record
    FPort     : string;
    FBaud     : TBaudRate;
    FDataBits : TDataBits;
    FStopBits : TStopBits;
  end;

  TTextExt = record                                                 //  20130521
    FId       : string;
    FText     : string;
  end;
  TTextExts = array of TTextExt;                                    //  20130521

const
  cSizeVoiceBase      = SizeOf(TVoiceBase);
  cSizeVoiceText      = SizeOf(TVoiceText);

type
  TVoiceManager = class;
  TVoiceControler = class(TThread)
  private

    FOwner: TVoiceManager;
    //ӵ����
    FCMDStop: TVoiceBase;
    FContent: TVoiceText;
    //��������
    FWaiter: TWaitObject;
    //�ȴ�����
    FComport: TComport;
    //���ڶ���
  protected
    procedure DoExuecte;
    procedure Execute; override;
    //ִ���߳�
  public
    constructor Create(AOwner: TVoiceManager);
    destructor Destroy; override;
    //�����ͷ�
    procedure WakupMe;
    //�����߳�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TVoiceManager = class(TObject)
  private
    FTexts: TTextExts;                                              //  20130521
    FVoicer: TVoiceControler;
    //��������
    FParam: TVoiceParam;
    //��������
    FPortParam: TVoiceComport;
    //�˿ڲ���  
    FSyncLock: TCriticalSection;
    //ͬ����
    function RepeatContent(const nStr: string): string;
    //�ظ�����
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��ȡ����
    procedure StartVoice;
    procedure StopVoice;
    //��ͣ��ȡ
    procedure PlayVoice(const nContent: string);
    //��������
  end;

var
  gVoiceManager: TVoiceManager = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TVoiceManager, '�ϳ���������', nEvent);
end;

constructor TVoiceManager.Create;
begin
  FSyncLock := TCriticalSection.Create;
end;

destructor TVoiceManager.Destroy;
begin
  StopVoice;
  FSyncLock.Free;
  inherited;
end;

procedure TVoiceManager.StartVoice;
begin
  if not Assigned(FVoicer) then
    FVoicer := TVoiceControler.Create(Self);
  FVoicer.WakupMe;
end;

procedure TVoiceManager.StopVoice;
begin
  if Assigned(FVoicer) then
    FVoicer.StopMe;
  FVoicer := nil;
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

//Desc: ����nContent����
procedure TVoiceManager.PlayVoice(const nContent: string);
var nStr: string;
    nIdx,nLen: Integer;
    nList: TStrings;
    nNum : Integer;                                                  // 20130520
    nContent1,nId :string;                                           // 20130520
begin
  if not Assigned(FVoicer) then Exit;
  //no controler

  nList := TStringList.Create;
  try
    FSyncLock.Enter;
    if Trim(nContent) = '' then
    begin
      FVoicer.FContent.FBase.FCommand := cVoice_CMD_Stop;
      Exit;
    end; //no content

    nNum := Pos(';',nContent);                                     // 20130520
    if  nNum> 0 then
    begin
      nContent1 := nContent;
      nId := nContent1;
      Delete(nContent1,1,nNum);
      Delete(nId,nNum,Length(nId)-nNum+1);
    end else nContent1 :=nContent;                                   // 20130520

    SplitStr(nContent1, nList, 0, #9);
    if (nList.Count > 1) or (nContent1[1] = #9) then
    begin
      nStr := '';
      nLen := nList.Count - 1;

      for nIdx:=0 to nLen do
      if Trim(nList[nIdx]) <> '' then
      begin
        if nIdx = nLen then
             nStr := nStr + nList[nIdx]
        else nStr := nStr + nList[nIdx] + Format('[p%d]', [FParam.FSleep]);
      end;

      if nNum> 0 then                                               //  20130521
      begin
        for nIdx := Low(FTexts) to High(FTexts) do
        begin
          if nId = FTexts[nIdx].FId then  FParam.FText := FTexts[nIdx].FText;
        end;
      end;

      with FParam do
       nStr := StringReplace(FText, FTruck, nStr, [rfReplaceAll, rfIgnoreCase]);
      //truck content
    end else nStr := nContent1;

    with FVoicer.FContent do
    begin
      FBase.FHead := cVoice_CMD_Head;
      FBase.FCommand := cVoice_CMD_Play;
      FBase.FParam := cVoice_Code_GB2312;

      nStr := '[m3]' + RepeatContent(nStr) + '[d]';
      StrPCopy(@FContent[0], nStr);
      FBase.FLength := Word2Voice(Length(nStr) + 2);
    end;

    FParam.FVoiceLast := 0;
    FParam.FVoiceTime := 0;

    FVoicer.WakupMe;
    WriteLog('��������: ' + nStr);
  finally
    nList.Free;
    FSyncLock.Leave;
  end;
end;

//Desc: �ظ�nStr��������
function TVoiceManager.RepeatContent(const nStr: string): string;
var nIdx: Integer;
begin
  Result := nStr;
  //default

  for nIdx:=2 to FParam.FRepeat do
    Result := Result + Format('[p%d]', [FParam.FReInterval]) + nStr;
  //xxxxx
end;

//Desc: ����nFile�����ļ�
procedure TVoiceManager.LoadConfig(const nFile: string);
var nStr: string;
    nXML: TNativeXml;
    nNode: TXmlNode;
    i :Integer;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByName('content');

    with FParam do
    begin
      FTruck    := nNode.NodeByName('truck').ValueAsString;
      FSleep    := nNode.NodeByName('sleep').ValueAsInteger;
      FText     := nNode.NodeByName('text').ValueAsString;
      FTimes    := nNode.NodeByName('times').ValueAsInteger;
      FInterval := nNode.NodeByName('interval').ValueAsInteger;

      FRepeat   := nNode.NodeByName('repeat').ValueAsInteger;
      FReInterval := nNode.NodeByName('reinterval').ValueAsInteger;
    end;

    nNode := nXML.Root.NodeByName('comport');
    with FPortParam do
    begin
      FPort     := nNode.NodeByName('port').ValueAsString;
      nStr      := nNode.NodeByName('baud').ValueAsString;
      FBaud     := StrToBaudRate(nStr);

      nStr      := nNode.NodeByName('data_bits').ValueAsString;
      FDataBits := StrToDataBits(nStr);

      nStr      := nNode.NodeByName('stop_bits').ValueAsString;
      FStopBits := StrToStopBits(nStr);
    end;

    nNode := nXML.Root.NodeByName('content');                       //  20130521
    nNode := nNode.NodeByName('text-ext');
    if Assigned(nNode) then
    begin
      SetLength(FTexts,2);
      for i :=0 to nNode.NodeCount-1 do
      begin
        FTexts[i].FId   := nNode.Nodes[i].AttributeByName['id'];
        FTexts[i].FText := nNode.Nodes[i].ValueAsString;
      end;
    end;                                                            //  20130521
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TVoiceControler.Create(AOwner: TVoiceManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 1000;

  FComport := TComPort.Create(nil);
  FComport.SyncMethod := smDisableEvents;
  with FComport.Timeouts do
  begin
    ReadInterval := -1;
    ReadTotalConstant := 1000;
    ReadTotalMultiplier := 200;
  end;
end;

destructor TVoiceControler.Destroy;
begin
  FComport.Close;
  FComport.Free;

  FWaiter.Free;
  inherited;
end;

procedure TVoiceControler.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TVoiceControler.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TVoiceControler.Execute;
var nInit: Int64;
begin
  nInit := 0;
  //init
  FContent.FBase.FCommand := cVoice_CMD_Stop;
  //no content

  with FCMDStop do
  begin
    FHead    := cVoice_CMD_Head;
    FLength  := Word2Voice(1);
    FCommand := cVoice_CMD_Stop;
  end;

  while not Terminated do
  with FOwner do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    try
      if not FComport.Connected then
      with FPortParam,FComport do
      begin
        Port := FPort;
        BaudRate := FBaud;
        DataBits := FDataBits;
        StopBits := FStopBits;

        Open;
        //connect voice card
      end;
    except
      WriteLog('����������ʧ��.');
      Continue;
    end;

    FSyncLock.Enter;
    try
      if FContent.FBase.FCommand = cVoice_CMD_Stop then Continue;
      //no content

      if (FParam.FVoiceTime < FParam.FTimes) and
         (GetTickCount - nInit >= 10 * 1000) and
         (GetTickCount - FParam.FVoiceLast >= FParam.FInterval * 1000) then
      begin
        DoExuecte;
        nInit := GetTickCount;
        
        FParam.FVoiceLast := nInit;
        FParam.FVoiceTime := FParam.FVoiceTime + 1;
      end;
    finally
      FSyncLock.Leave;
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Desc: ��������
procedure TVoiceControler.DoExuecte;
begin
  //FComport.Write(@FCMDStop, Voice2Word(FCMDStop.FLength) + 3);
  //Sleep(cVoice_FrameInterval);

  FComport.Write(@FContent, Voice2Word(FContent.FBase.FLength) + 3);
  Sleep(cVoice_FrameInterval);
end;

initialization
  gVoiceManager := TVoiceManager.Create;
finalization
  FreeAndNil(gVoiceManager);
end.
