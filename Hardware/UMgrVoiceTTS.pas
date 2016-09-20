{*******************************************************************************
  作者: fendou116688@163.com 2016-09-07
  描述: 微软TTS语音合成驱动单元
*******************************************************************************}
unit UMgrVoiceTTS;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, ActiveX, ComObj, SpeechLib_TLB,
  NativeXml, UWaitItem, ULibFun, USysLoger;

const
  cVoice_CMD_Head       = $FD;         //帧头
  cVoice_CMD_Play       = $01;         //播放
  cVoice_CMD_Stop       = $02;         //停止
  cVoice_CMD_Pause      = $03;         //暂停
  cVoice_CMD_Resume     = $04;         //继续
  cVoice_CMD_QStatus    = $21;         //查询
  cVoice_CMD_StandBy    = $22;         //待命
  cVoice_CMD_Wakeup     = $FF;         //唤醒

  cVoice_Code_GB2312    = $00;
  cVoice_Code_GBK       = $01;
  cVoice_Code_BIG5      = $02;
  cVoice_Code_Unicode   = $03;         //编码

  cVoice_FrameInterval  = 10;          //帧间隔
  cVoice_ContentLen     = 4096;        //文本长度
  
  cVoice_Delimater      = ',';

type
  TVoiceWord = record
   FH: Byte;
   FL: Byte;
  end;

  PVoiceDataItem = ^TVoiceDataItem;
  TVoiceDataItem = record
    FHead     : Byte;                  //帧头
    FLength   : TVoiceWord;            //数据长度
    FCommand  : Byte;                  //命令字
    FParam    : Byte;                  //命令参数
    FContent  : array[0..cVoice_ContentLen-1] of Char;
  end;

  PVoiceContentParam = ^TVoiceContentParam;
  TVoiceContentParam = record
    FID       : string;                //内容标识
    FObject   : string;                //对象标识
    FSleep    : Integer;               //对象间隔
    FText     : string;                //播发内容
    FErrText  : string;                //错误内容
    FTimes    : Integer;               //重发次数
    FInterval : Integer;               //重发间隔
    FRepeat   : Integer;               //单次重复
    FReInterval: Integer;              //单次间隔
  end;

  PVoiceResource = ^TVoiceResource;
  TVoiceResource = record
    FKey      : string;                //待处理
    FValue    : string;                //处理内容
  end;

  PVoiceContentNormal = ^TVoiceContentNormal;
  TVoiceContentNormal = record
    FText     : string;                //待播发文本
    FCard     : string;                //执行语音卡
    FContent  : string;                //执行内容标识
  end;

  PTTSVoiceCardHost = ^TTTSVoiceCardHost;
  TTTSVoiceCardHost = record
    FID       : string;                //卡标识
    FName     : string;                //卡名称
    FEnable   : Boolean;               //是否启用
    FContent  : TList;                 //播发内容
    FResource : TList;                 //资源内容

    FVoiceData: TVoiceDataItem;        //语音数据
    FVoiceLast: Int64;                 //上次播发
    FVoiceTime: Byte;                  //播发次数
    FParam    : PVoiceContentParam;    //播发参数

    FVoiceEngine: string;              //语音引擎
    FVoiceVolume: Integer;             //语音音量
    FVoiceRate  : Integer;             //语音语速
  end;

type
  TTTSVoiceManager = class;
  TTTSVoiceConnector = class(TThread)
  private
    FOwner: TTTSVoiceManager;
    //拥有者
    FWaiter: TWaitObject;
    //等待对象
    FListA: TStrings;
    //字符列表
  protected
    procedure Execute; override;
    procedure Doexecute;
    //执行线程
    procedure CombineBuffer;
    //合并缓冲
    procedure SendVoiceData(const nCard: PTTSVoiceCardHost);
    //发送数据
    procedure AutomationSpeak(const nData: string);
    //采用AutoMation发送
    procedure ActiveXSpeak(const nCard: PTTSVoiceCardHost);
    //采用组件方式发送
  public
    constructor Create(AOwner: TTTSVoiceManager);
    destructor Destroy; override;
    //创建释放
    procedure WakupMe;
    //唤醒线程
    procedure StopMe;
    //停止线程
  end;

  TTTSVoiceManager = class(TObject)
  private
    FCards: TList;
    //语音卡列表
    FBuffer: TList;
    //数据缓冲
    FVoicer: TTTSVoiceConnector;
    //语音对象
    FSyncLock: TCriticalSection;
    //同步锁
    FEngines: TStrings;
    //语音引擎列表
    FSpeechObjectTokens:ISpeechObjectTokens;
    FSpeechObjectToken:ISpeechObjectToken;
    FSpVoice: TSpVoice;
    //语音连接
  protected
    procedure ClearDataList(const nList: TList; const nFree: Boolean = False);
    //清理缓冲
    function FindContentParam(const nCard: PTTSVoiceCardHost;
      const nID: string): PVoiceContentParam;
    function FindCardHost(const nID: string): PTTSVoiceCardHost;
    //检索数据
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //读取配置
    procedure StartVoice;
    procedure StopVoice;
    //启停读取
    procedure PlayVoice(const nText: string; const nCard: string = '';
      const nContent: string = '');
    //播放语音
  end;

var
  gTTSVoiceManager: TTTSVoiceManager = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TTTSVoiceManager, '微软TTS语音合成', nEvent);
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
constructor TTTSVoiceManager.Create;
begin
  FCards := TList.Create;
  FBuffer := TList.Create;
  FSyncLock := TCriticalSection.Create;

  FSpVoice := TSpVoice.Create(nil);
  FEngines := TStringList.Create;
end;

destructor TTTSVoiceManager.Destroy;
begin
  StopVoice;
  ClearDataList(FBuffer, True);
  
  ClearDataList(FCards, True);
  FSyncLock.Free;

  FEngines.Free;
  FSpVoice.Free;
  inherited;
end;

//Date: 2015-04-23
//Parm: 列表;是否释放
//Desc: 清理nList列表
procedure TTTSVoiceManager.ClearDataList(const nList: TList;
 const nFree: Boolean);
var i,nIdx: Integer;
    nCard: PTTSVoiceCardHost;
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

procedure TTTSVoiceManager.StartVoice;
var nIdx: Integer;
begin
  if FCards.Count < 1 then
    raise Exception.Create('Voice Card List Is Null.');
  //xxxxx

  FSpeechObjectTokens := FSpVoice.GetVoices('', '');
  FEngines.Clear;

  for nIdx := 0 to FSpeechObjectTokens.Count - 1 do
  begin
    FSpeechObjectToken := FSpeechObjectTokens.Item(nIdx);
    FEngines.Add(FSpeechObjectToken.GetDescription(0));
  end;

  if FEngines.Count > 0 then
    WriteLog('系统语音引擎:' + FEngines.Text);

  if not Assigned(FVoicer) then
    FVoicer := TTTSVoiceConnector.Create(Self);
  FVoicer.WakupMe;
end;

procedure TTTSVoiceManager.StopVoice;
var nIdx: Integer;
begin
  if Assigned(FVoicer) then
    FVoicer.StopMe;
  FVoicer := nil;

  ClearDataList(FBuffer);
  //清理待发送缓冲

  for nIdx:=FCards.Count - 1 downto 0 do
    PTTSVoiceCardHost(FCards[nIdx]).FVoiceTime := MAXBYTE;
  //关闭发送标记
end;

//Date: 2015-04-23
//Parm: 语音卡标识
//Desc: 检索标识为nID的语音卡
function TTTSVoiceManager.FindCardHost(const nID: string): PTTSVoiceCardHost;
var nIdx: Integer;
begin
  Result := FCards[0];
  //default is first

  for nIdx:=FCards.Count - 1 downto 0 do
  if CompareText(nID, PTTSVoiceCardHost(FCards[nIdx]).FID) = 0 then
  begin
    Result := FCards[nIdx];
    Break;
  end;
end;

//Date: 2015-04-23
//Parm: 语音卡;内容标识
//Desc: 在nCard中检索标识为nID的内容配置
function TTTSVoiceManager.FindContentParam(const nCard: PTTSVoiceCardHost;
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
//Parm: 文本;语音卡标识;内容配置标识
//Desc: 在nCard播发使用nContent参数处理的nText,写入缓冲等待处理
procedure TTTSVoiceManager.PlayVoice(const nText, nCard, nContent: string);
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
//Parm: 配置文件
//Desc: 读取nFile配置文件
procedure TTTSVoiceManager.LoadConfig(const nFile: string);
var i,nIdx: Integer;
    nXML: TNativeXml;
    nRoot,nNode,nTmp,nENode: TXmlNode;
    
    nCard: PTTSVoiceCardHost;
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
      //标记不发送

      with nRoot do
      begin
        nCard.FID     := AttributeByName['id'];
        nCard.FName   := AttributeByName['name'];
        nCard.FEnable := NodeByName('enable').ValueAsString = '1';

        nTmp := FindNode('VoiceEngine');
        if Assigned(nTmp) then
             nCard.FVoiceEngine := nTmp.ValueAsString
        else nCard.FVoiceEngine := 'Microsoft Simplified Chinese';

        nTmp := FindNode('Volume');
        if Assigned(nTmp) then
             nCard.FVoiceVolume := nTmp.ValueAsInteger
        else nCard.FVoiceVolume := 50;

        nTmp := FindNode('rate');
        if Assigned(nTmp) then
             nCard.FVoiceRate := nTmp.ValueAsInteger
        else nCard.FVoiceRate := 50;
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

            nENode := FindNode('errtext');
            if Assigned(nENode) then
                 nParam.FErrText := nENode.ValueAsString
            else nParam.FErrText := '';
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
constructor TTTSVoiceConnector.Create(AOwner: TTTSVoiceManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 1000;
end;

destructor TTTSVoiceConnector.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  inherited;
end;

procedure TTTSVoiceConnector.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TTTSVoiceConnector.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TTTSVoiceConnector.Execute;
begin
  while True do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Doexecute;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

procedure TTTSVoiceConnector.Doexecute;
var nStr: string;
    nIdx: Integer;
    nCard: PTTSVoiceCardHost;
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
          //发送累计

          nStr := 'Card:[ %s:%s ] Msg: %s';
          nStr := Format(nStr, [nCard.FID, nCard.FName, E.Message]);
          WriteLog(nStr);
        end;
      end;
    end;
  end;
end;

//Desc: 将发送缓冲数据合并到语音卡缓冲
procedure TTTSVoiceConnector.CombineBuffer;
var nStr, nTruck, nErr: string;
    i,nIdx,nLen, nPos: Integer;

    nCard: PTTSVoiceCardHost;
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
        nStr := '语音卡[ %s ]标识不存在.';
        nStr := Format(nStr, [nTxt.FCard]);

        WriteLog(nStr);
        Continue;
      end;

      if not nCard.FEnable then
      begin
        nStr := '语音卡[ %s ]已停用.';;
        nStr := Format(nStr, [nCard.FID]);

        WriteLog(nStr);
        Continue;
      end;

      nParm := FindContentParam(nCard, nTxt.FContent);
      if not Assigned(nParm) then
      begin
        nStr := '语音卡[ %s:%s ]内容标识不存在.';;
        nStr := Format(nStr, [nCard.FID, nTxt.FContent]);

        WriteLog(nStr);
        Continue;
      end;

      //------------------------------------------------------------------------
      nPos := Pos('ERR', nTxt.FText);
      if nPos>0 then
      begin
        nErr := Copy(nTxt.FText, nPos, Length(nTxt.FText) - nPos + 1);
        Delete(nTxt.FText, nPos, Length(nTxt.FText) - nPos + 1);
      end;

      //正确车牌信息
      nTruck := nTxt.FText;
      SplitStr(nTruck, FListA, 0, #9, False);
      //拆分: YA001 #9 YA002

      for i:=FListA.Count - 1 downto 0 do
      begin
        FListA[i] := Trim(FListA[i]);
        if FListA[i] = '' then
          FListA.Delete(i);
        //清理空行
      end;

      if (FListA.Count > 1) or ((Length(nTruck) > 0) and (nTruck[1] = #9)) then
      begin
        nStr := '';
        nLen := FListA.Count - 1;

        for i:=0 to nLen do
        if Trim(FListA[i]) <> '' then
        begin
          if nIdx = nLen then
               nStr := nStr + FListA[i]
          else nStr := nStr + FListA[i] + cVoice_Delimater;
        end;

        nStr := StringReplace(nParm.FText, nParm.FObject, nStr,
                                           [rfReplaceAll, rfIgnoreCase]);
        //text real content
      end else nStr := nTruck;

      //错误车牌信息
      SplitStr(nErr, FListA, 0, 'ERR', False);
      //拆分: YA001 ERR YA002

      for i:=FListA.Count - 1 downto 0 do
      begin
        FListA[i] := Trim(FListA[i]);
        if FListA[i] = '' then
          FListA.Delete(i);
        //清理空行
      end;

      if (FListA.Count > 1) or ((Length(nErr) > 0) and (Copy(nErr, 1, 3) = 'ERR')) then
      begin
        nErr := '';
        nLen := FListA.Count - 1;

        for i:=0 to nLen do
        if Trim(FListA[i]) <> '' then
        begin
          if nIdx = nLen then
               nErr := nErr + FListA[i]
          else nErr := nErr + FListA[i] + cVoice_Delimater;
        end;

        nErr := StringReplace(nParm.FErrText, nParm.FObject, nErr,
                                           [rfReplaceAll, rfIgnoreCase]);
        //text real content
      end;

      nStr := nStr + nErr;
      if Length(nStr) < 1 then Exit;
      //拼接语音记录

      for i:=nCard.FResource.Count - 1 downto 0 do
      begin
        nRes := nCard.FResource[i];
        nStr := StringReplace(nStr, nRes.FKey, nRes.FValue,
                                    [rfReplaceAll, rfIgnoreCase]);
        //resource replace
      end;


      for i:=2 to nParm.FRepeat do
        nStr := nStr + cVoice_Delimater + nStr;
      //xxxxx

      //------------------------------------------------------------------------
      with nCard.FVoiceData do
      begin
        FHead := cVoice_CMD_Head;
        FCommand := cVoice_CMD_Play;
        FParam := cVoice_Code_GB2312;

        StrPCopy(@FContent[0], nStr);
        FLength := Word2Voice(Length(nStr) + 2);

        nCard.FParam := nParm;
        nCard.FVoiceLast := 0;
        nCard.FVoiceTime := 0;
      end;

      WriteLog(nStr);
    end;

    ClearDataList(FBuffer);
    //清空缓冲
  end;
end;

//Date: 2015-04-23
//Parm: 语音卡
//Desc: 向nCard发送缓冲区数据
procedure TTTSVoiceConnector.SendVoiceData(const nCard: PTTSVoiceCardHost);
var nStr: string;
begin
  if nCard.FVoiceTime = MAXBYTE then Exit;
  //不发送标记
  if nCard.FVoiceTime >= nCard.FParam.FTimes then Exit;
  //发送次数完成
  if GetTickCount - nCard.FVoiceLast < nCard.FParam.FInterval * 1000 then Exit;
  //发送间隔未到

  nStr := nCard.FVoiceData.FContent;
  CoInitialize(nil);

  if nCard.FVoiceEngine = '' then
       AutomationSpeak(nStr)
  else ActiveXSpeak(nCard);

  Sleep(cVoice_FrameInterval);
  CoUninitialize;
  //发送并等待

  nCard.FVoiceLast := GetTickCount;
  nCard.FVoiceTime := nCard.FVoiceTime + 1;
  //计数君
end;

procedure TTTSVoiceConnector.AutomationSpeak(const nData: string);
var FVoice: OleVariant;
begin
  FVoice := CreateOLEObject('SAPI.SpVoice');
  FVoice.Speak(nData, 0);
  //xxxxx
end;

procedure TTTSVoiceConnector.ActiveXSpeak(const nCard: PTTSVoiceCardHost);
var nStr: string;
    nIdx: Integer;
begin
  nStr := nCard.FVoiceData.FContent;

  with FOwner do
  begin
    nIdx := FEngines.IndexOf(nCard.FVoiceEngine);
    FSpeechObjectToken := FSpeechObjectTokens.Item(nIdx);

    if nIdx < 0 then
    begin
      AutomationSpeak(nStr);
      Exit;
    end;
    //如果找不到引擎，使用默认

    FSpVoice.Rate  := nCard.FVoiceRate;
    FSpVoice.Voice := FSpeechObjectToken;
    FSpVoice.Volume:= nCard.FVoiceVolume;

    FSpVoice.Speak(nStr, 0);
  end;
end;

initialization
  gTTSVoiceManager := TTTSVoiceManager.Create;
finalization
  FreeAndNil(gTTSVoiceManager);
end.
