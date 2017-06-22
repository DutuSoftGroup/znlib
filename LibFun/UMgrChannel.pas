{*******************************************************************************
  ����: dmzn@163.com 2011-11-14
  ����: �м������ͨ��������
*******************************************************************************}
unit UMgrChannel;

{$I LibFun.inc}
interface

uses
  Windows, Classes, SysUtils, SyncObjs, uROClient, uROWinInetHttpChannel,
  uROBinMessage, uROSOAPMessage, {$IFDEF RO_v90}uROMessage, {$ENDIF}
  UBaseObject;

type
  TChannelMsgType = (mtBin, mtSoap);
  //��Ϣ����
  
  PChannelItem = ^TChannelItem;
  TChannelItem = record
    FUsed: Boolean;                //�Ƿ�ռ��
    FType: Integer;                //ͨ������
    FChannel: IUnknown;            //ͨ������

    FMsg: TROMessage;              //��Ϣ����
    FHttp: TROWinInetHTTPChannel;  //ͨ������
  end;

  TChannelManager = class(TCommonObjectBase)
  private
    FChannels: TList;
    //ͨ���б�
    FMaxCount: Integer;
    //ͨ����ֵ
    FLock: TCriticalSection;
    //ͬ����
    FNumLocked: Integer;
    //��������
    FFreeing: Integer;
    FClearing: Integer;
    //����״̬
  protected
    function GetCount: Integer;
    procedure SetChannelMax(const nValue: Integer);
    //���Դ���
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    function LockChannel(const nType: Integer = -1;
     const nMsgType: TChannelMsgType = mtBin): PChannelItem;
    procedure ReleaseChannel(const nChannel: PChannelItem);
    //ͨ������
    procedure ClearChannel;
    //����ͨ��
    procedure GetStatus(const nList: TStrings); override;
    //����״̬
    property ChannelCount: Integer read GetCount;
    property ChannelMax: Integer read FMaxCount write SetChannelMax;
    //�������
  end;

var
  gChannelManager: TChannelManager = nil;
  //ȫ��ʹ��

implementation

const
  cYes  = $0002;
  cNo   = $0005;

constructor TChannelManager.Create;
begin
  inherited;
  FMaxCount := 5;
  FNumLocked := 0;

  FFreeing := cNo;
  FClearing := cNo;
  
  FChannels := TList.Create;
  FLock := TCriticalSection.Create;
end;

destructor TChannelManager.Destroy;
begin
  InterlockedExchange(FFreeing, cYes);
  ClearChannel;
  FChannels.Free;

  FLock.Free;
  inherited;
end;

//Desc: ����ͨ������
procedure TChannelManager.ClearChannel;
var nIdx: Integer;
    nItem: PChannelItem;
begin
  InterlockedExchange(FClearing, cYes);
  //set clear flag

  FLock.Enter;
  try
    if FNumLocked > 0 then
    try
      FLock.Leave;
      while FNumLocked > 0 do
        Sleep(1);
      //wait for relese
    finally
      FLock.Enter;
    end;

    for nIdx:=FChannels.Count - 1 downto 0 do
    begin
      nItem := FChannels[nIdx];
      FChannels.Delete(nIdx);

      with nItem^ do
      begin
        if Assigned(FHttp) then FreeAndNil(FHttp);
        if Assigned(FMsg) then FreeAndNil(FMsg);

        if Assigned(FChannel) then FChannel := nil;
        Dispose(nItem);
      end;
    end;
  finally
    InterlockedExchange(FClearing, cNo);
    FLock.Leave;
  end;
end;

//Desc: ͨ������
function TChannelManager.GetCount: Integer;
begin
  FLock.Enter;
  Result := FChannels.Count;
  FLock.Leave;
end;

//Desc: ���ͨ����
procedure TChannelManager.SetChannelMax(const nValue: Integer);
begin
  FLock.Enter;
  FMaxCount := nValue;
  FLock.Leave;
end;

//Desc: ����ͨ��
function TChannelManager.LockChannel(const nType: Integer;
 const nMsgType: TChannelMsgType): PChannelItem;
var nIdx,nFit: Integer;
    nItem: PChannelItem;
begin
  Result := nil; 
  if FFreeing = cYes then Exit;
  if FClearing = cYes then Exit;

  FLock.Enter;
  try
    if FFreeing = cYes then Exit;
    if FClearing = cYes then Exit;
    nFit := -1;

    for nIdx:=0 to FChannels.Count - 1 do
    begin
      nItem := FChannels[nIdx];
      if nItem.FUsed then Continue;

      with nItem^ do
      begin
        if (nType > -1) and (FType = nType) then
        begin
          Result := nItem;
          Exit;
        end;

        if nFit < 0 then
          nFit := nIdx;
        //first idle

        if nType < 0 then
          Break;
        //no check type
      end;
    end;

    if FChannels.Count < FMaxCount then
    begin
      New(nItem);
      FChannels.Add(nItem);

      with nItem^ do
      begin
        FType := nType;
        FChannel := nil;
        FHttp := TROWinInetHTTPChannel.Create(nil);

        case nMsgType of
         mtBin: FMsg := TROBinMessage.Create;
         mtSoap: FMsg := TROSOAPMessage.Create;
        end;
      end;

      Result := nItem;
      Exit;
    end;

    if nFit > -1 then
    begin
      Result := FChannels[nFit];
      Result.FType := nType;
      Result.FChannel := nil;
    end;
  finally
    if Assigned(Result) then
    begin
      Result.FUsed := True;
      InterlockedIncrement(FNumLocked);
    end;
    FLock.Leave;
  end;
end;

//Desc: �ͷ�ͨ��
procedure TChannelManager.ReleaseChannel(const nChannel: PChannelItem);
begin
  if Assigned(nChannel) then
  begin
    FLock.Enter;
    try
      nChannel.FUsed := False;
      InterlockedDecrement(FNumLocked);
    finally
      FLock.Leave;
    end;
  end;
end;

procedure TChannelManager.GetStatus(const nList: TStrings);
begin
  FLock.Enter;
  try
    nList.Add('MaxCount: ' + #9 + IntToStr(FMaxCount));
    nList.Add('ChannelCount: ' + #9 + IntToStr(FChannels.Count));
    nList.Add('ChannelLocked: ' + #9 + IntToStr(FNumLocked));
  finally
    FLock.Leave;
  end;
end;

initialization
  gChannelManager := nil;
finalization
  FreeAndNil(gChannelManager);
end.
