{*******************************************************************************
  作者: dmzn dmzn@163.com 2007-01-23
  描述: 使用WM_CopyData消息在两个程序中传递文本内容

  声明: 本单元公开源码,个人/商业可免费使用,不过请保留此处的说明文字.如果你
  对本单元作了合理修改,请邮件通知我,谢谢!
*******************************************************************************}
unit ZnExeData;

interface

uses
  Windows, Classes, ComObj, ExtCtrls, Messages, SysUtils;

type
  TOnDataEvent = procedure (const nData: string) of object;
  TOnDataProcedure = procedure (const nData: string);
  //收到数据

  TZnPostData = class(TComponent)
  private
    FHwnd: THandle;
    FNext: THandle;
    //消息处理句柄
    FMsgStr: string;
    FMsgID: Cardinal;
    //消息标识
    FNum: integer;
    FTimer: TTimer;
    //计数器
    FData: string;
    //待发送数据
    FOnData: TOnDataEvent;
    FOnEnd: TNotifyEvent;
    FOnTimeout: TNotifyEvent;
    FOnData2: TOnDataProcedure;
    //事件
  protected
    procedure WndProc(var nMsg: TMessage);
    procedure DoOnTimer(Sender: TObject);
    procedure SetMsgStr(const nStr: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //创建释放
    procedure SendData(const nData: string);
    //发送数据
    property OnDataProc: TOnDataProcedure read FOnData2 write FOnData2;
    //事件相关
  published
    property MsgStr: string read FMsgStr write SetMsgStr;
    property Timeout: integer read FNum write FNum;
    //属性相关
    property OnData: TOnDataEvent read FOnData write FOnData;
    property OnDataEnd: TNotifyEvent read FOnEnd write FOnEnd;
    property OnTimeout: TNotifyEvent read FOnTimeout write FOnTimeout;
    //事件相关
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RunSoft', [TZnPostData]);
end;

const
  cSender = $0010;
  //发送方
  cReceiver = $0025;
  //接收方
  cSendOK = $0027;
  //发送完毕
  
constructor TZnPostData.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNum := 3;
  FMsgStr := CreateClassID;
  FHwnd := Classes.AllocateHWnd(WndProc);
end;

destructor TZnPostData.Destroy;
begin
  DeAllocateHwnd(FHwnd);
  if Assigned(FTimer) then FTimer.Free;
  inherited;
end;

procedure TZnPostData.SetMsgStr(const nStr: string);
begin
  if nStr <> FMsgStr then
  begin
    FMsgStr := nStr;
    if not (csDesigning in ComponentState) then
       FMsgID := RegisterWindowMessage(PChar(FMsgStr));
  end;
end;

procedure TZnPostData.DoOnTimer(Sender: TObject);
begin
  FTimer.Tag := FTimer.Tag + 1;
  if FTimer.Tag >= FNum then
  begin
    FTimer.Enabled := False;
    if Assigned(FOnTimeout) then FOnTimeout(Self);
  end;
end;

procedure TZnPostData.SendData(const nData: string);
begin
  if not Assigned(FTimer) then
  begin
    FTimer := TTimer.Create(nil);
    FTimer.OnTimer := DoOnTimer;
  end;

  FData := nData;
  FNext := 0;
  FTimer.Tag := 0;

  FTimer.Enabled := True;
  PostMessage(HWND_BROADCAST, FMsgID, FHwnd, cSender);
end;

procedure TZnPostData.WndProc(var nMsg: TMessage);
var nBuf: TCopyDataStruct;
begin
  if (nMsg.Msg = FMsgID) and (nMsg.LParam = cSender) and
     (nMsg.WParam <> Integer(FHwnd)) then
  begin
    FNext := nMsg.WParam;
    SendMessage(FNext, FMsgID, FHwnd, cReceiver);
    {------------------------ +Dmzn: 2007-01-24 --------------------
    备注: 广播时发送方自己也会收到,所以需要先把自己过滤掉.
    接收方会处理这个消息,以响应发送发的询问,返回自己的句柄.
    ----------------------------------------------------------------}
  end else

  if (nMsg.Msg = FMsgID) and (nMsg.LParam = cReceiver) then
  begin
    FTimer.Tag := -2;
    FNext := nMsg.WParam;

    nBuf.cbData := Length(FData);
    nBuf.lpData := PChar(FData);
    SendMessage(FNext, WM_COPYDATA, FHwnd, Cardinal(@nBuf));
    {------------------------ +Dmzn: 2007-01-24 --------------------
    备注: 发送方收到接收方句柄后,开始传递数据,同时开始发送超时的计数.
    高位参数WParam中放置发送端句柄,作为身份识别的标志
    ----------------------------------------------------------------}
  end else

  if (nMsg.WParam = Integer(FNext)) and (nMsg.Msg = WM_COPYDATA) then
  begin
    SendMessage(nMsg.WParam, FMsgID, FHwnd, cSendOK);
    //收到数据后发送回执

    nBuf := TCopyDataStruct((Pointer(nMsg.LParam))^);
    FData := StrPas(nBuf.lpData);
    SetLength(FData, nBuf.cbData);

    if Assigned(FOnData) then FOnData(FData);
    if Assigned(FOnData2) then FOnData2(FData);
    {------------------------ +Dmzn: 2007-01-24 --------------------
    备注: 接收方收到数据,回执发送发并触发事件.
    高位参数WParam中放置发送端句柄,作为身份识别的标志
    ----------------------------------------------------------------}
  end else

  if (nMsg.Msg = FMsgID) and (nMsg.LParam = cSendOK) then
  begin
    FTimer.Enabled := False;
    if Assigned(FOnEnd) then FOnEnd(Self);
    {------------------------ +Dmzn: 2007-01-24 --------------------
    备注: 发送发收到回执,停掉超时计数
    ----------------------------------------------------------------}
  end;
end;


end.
