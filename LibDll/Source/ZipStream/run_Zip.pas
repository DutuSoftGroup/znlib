{*******************************************************************************
  作者: dmzn@163.com 2007.05.17
  描述: 提供对流数据的压缩&解压缩

  备注:
  &.使用息方式同步线程和VCL.
*******************************************************************************}
unit run_Zip;

interface

uses
  Windows, Messages, SysUtils, Classes, ComCtrls, ZlibEx;

const
  WM_WParam = $1235;
  WM_LParam = $5321;
  WM_Begin = WM_USER + $0020;
  WM_End   = WM_USER + $0022;
  WM_DATA  = WM_USER + $0025;

type
  TZnZip = class;

  TZipThread = class(TThread)
  private
   { Private declarations }
   FOwner    : TZnZip;
   FZip      : boolean;
   FNormal   : boolean;
   
   FLeft     : integer;
   FHasDone  : integer;
   FZipRate  : Single;
  protected
   { protected declarations }
   procedure DoBegin;
   procedure DoProcess;
   procedure DoEnd;

   procedure Execute; override;
   procedure ZipStream(const nSource,nDest: TStream);
   procedure UnZipStream(const nSource,nDest: TStream);
  public
   { public declarations }
   constructor Create(AOwner: TZnZip; IsZip: boolean);
  end;

  TThreadEvent = class
  private
    FOwner: TZnZip;
    //拥有者
    FHwnd: THandle;
    //消息句柄
    FDestroy: Boolean;
    //是否销毁状态
    FProcess: TThreadList;
    //进度数据
  protected
    FMax: Cardinal;
    FRate: Single;
    FNormal: Boolean;
    //不需缓冲的数据
    procedure SyncEvent;
    //同步处理消息
    procedure FreeAll;
    //释放资源
    procedure WndProc(var nMsg: TMessage);
    //消息处理过程
  public
    constructor Create(AOwner: TZnZip);
    destructor Destroy; override;   
    procedure AddPos(const nPos: Cardinal);
    procedure DoBegin(const nMax: Cardinal);
    procedure DoEnd(const nNormal: boolean; nZipRate: Single);
  end;

  TOnBegin = procedure (const nMax: Cardinal) of object;
  TOnProcess = procedure (const nHasDone: Cardinal) of object;
  TOnEnd = procedure (const nNormal: boolean; nZipRate: Single) of object;

  TZnZip = class(TComponent)
  private
   { Private declarations }
   FBusy     : boolean;
   FFrom,
   FDest     : TStream;
   FThread   : TZipThread;
   FEvent    : TThreadEvent;
   FZipLevel : TZCompressionLevel;

   FOnBegin  : TOnBegin;
   FOnProc   : TOnProcess;
   FOnEnd    : TOnEnd;
  public
   { public declarations }
   constructor Create(AOwner: TComponent);override;
   destructor Destroy;override;

   procedure ZipStream(const nSource,nDest: TStream);
   procedure UnZipStream(const nSource,nDest: TStream);
   procedure StopZnZip;
  published
   { published declarations }
   property Busy: boolean read FBusy;
   property OnBegin: TOnBegin read FOnBegin write FOnBegin;
   property OnProcess : TOnProcess read FOnProc write FOnProc;
   property OnEnd: TOnEnd read FOnEnd write FOnEnd;
   property ZipLevel: TZCompressionLevel read FZipLevel write FZipLevel;
  end;

procedure Register;

implementation

const
  BufSize = $F000;

procedure Register;
begin
  RegisterComponents('RunSoft', [TZnZip]);
end;

{********************  TZipThread  ****************}
constructor TZipThread.Create(AOwner: TZnZip; IsZip: boolean);
begin
  FOwner := AOwner;
  FZip := IsZip;
  FreeOnTerminate := True;
  inherited Create(False);
end;

procedure TZipThread.DoBegin;
begin
  FOwner.FEvent.DoBegin(FLeft);
end;

procedure TZipThread.DoEnd;
begin
  with FOwner do
  begin
    FBusy := False;
    if Assigned(FOnEnd) and (not (csDestroying in ComponentState)) then
      if FNormal then
        if FZip then
             FEvent.DoEnd(True, FZipRate)
        else FEvent.DoEnd(True, 0)
      else FEvent.DoEnd(False, 0);
  end;
end;

procedure TZipThread.DoProcess;
begin
  FOwner.FEvent.AddPos(FHasDone);
end;

procedure TZipThread.Execute;
begin
  FNormal := True;
  try
    if FZip then
       ZipStream(FOwner.FFrom, FOwner.FDest)
    else
       UnZipStream(FOwner.FFrom, FOwner.FDest);
  except
    FNormal := False;
  end;

  if Terminated then
       FreeOnTerminate := False
  else FOwner.FThread := nil;

  DoEnd;
  //Synchronize(DoEnd);
end;

//Desc: 压缩nStream
procedure TZipThread.ZipStream(const nSource,nDest: TStream);
var nZipStream: TZCompressionStream;
    nBuf: array [0..BufSize] of Byte;
begin
  nZipStream := TZCompressionStream.Create(nDest, FOwner.FZipLevel);
  try
    nSource.Seek(0, soFromBeginning);
    FHasDone := 0;
    FLeft := nSource.Size; DoBegin;

    while not Terminated and (FLeft > 0) do
    begin
       if FLeft > BufSize then
       begin
         nSource.Read(nBuf, BufSize);
         nZipStream.Write(nBuf, BufSize);
         FHasDone := FHasDone + BufSize;
       end else
       begin
         nSource.Read(nBuf, FLeft);
         nZipStream.Write(nBuf, FLeft);
         FHasDone := FHasDone + FLeft;
       end;

       DoProcess;
       FLeft := FLeft - BufSize;
    end;

    FZipRate := nZipStream.CompressionRate;
    if Terminated then FNormal := False; 
  finally
    nZipStream.Free;
  end;
end;

//Desc: 解压缩nStream
procedure TZipThread.UnZipStream(const nSource,nDest: TStream);
var nBuf: array [0..BufSize] of Byte;
    nZipStream: TZDecompressionStream;
begin
  nZipStream := TZDecompressionStream.Create(nSource);
  try
    nZipStream.Seek(0, soFromBeginning);
    FHasDone := 0;
    FLeft := nZipStream.Size; DoBegin;

    while not Terminated and (FLeft > 0) do
    begin
       if FLeft > BufSize then
       begin
         nZipStream.Read(nBuf, BufSize);
         nDest.Write(nBuf, BufSize);
         FHasDone := FHasDone + BufSize;
       end else
       begin
         nZipStream.Read(nBuf, FLeft);
         nDest.Write(nBuf, FLeft);
         FHasDone := FHasDone + FLeft;
       end;

       DoProcess;
       FLeft := FLeft - BufSize;
    end;

    if Terminated then FNormal := False;
  finally
    nZipStream.Free;
  end;
end;

{********************************* TEvent *************************************}
constructor TThreadEvent.Create(AOwner: TZnZip);
begin
  FOwner := AOwner;
  FDestroy := False;
  FProcess := TThreadList.Create;
  FHwnd := Classes.AllocateHWnd(WndProc);
end;

destructor TThreadEvent.Destroy;
begin
  FDestroy := True;
  Classes.DeAllocateHwnd(FHwnd);
  FreeAll;
  inherited;
end;

procedure TThreadEvent.FreeAll;
var nList: TList;
    i,nCount: integer;
begin
  nList := FProcess.LockList;
  nCount := nList.Count - 1;

  for i:=nCount downto 0 do
    FreeMem(nList.Items[i]);
  FProcess.UnlockList;
  FProcess.Free;
end;

//Desc: 压缩开始
procedure TThreadEvent.DoBegin(const nMax: Cardinal);
begin
  FMax := nMax;
  PostMessage(FHwnd, WM_Begin, WM_WParam, WM_LParam);
end;

//Desc: 压缩结束
procedure TThreadEvent.DoEnd(const nNormal: boolean; nZipRate: Single);
begin
  FRate := nZipRate;
  FNormal := nNormal;
  PostMessage(FHwnd, WM_End, WM_WParam, WM_LParam);
end;

//Desc: 添加进度值到队列
procedure TThreadEvent.AddPos(const nPos: Cardinal);
var nBuf: PLongword;
begin
  if not FDestroy then
  begin
    nBuf := AllocMem(SizeOf(nPos));
    nBuf^ := nPos;

    FProcess.LockList.Add(nBuf);
    FProcess.UnlockList;
    PostMessage(FHwnd, WM_DATA, WM_WParam, WM_LParam);
  end;
end;

//Desc: 同步消息
procedure TThreadEvent.SyncEvent;
var nList: TList;
begin
  nList := FProcess.LockList;
  while nList.Count > 0 do
  begin
    with FOwner do
    if Assigned(FOnProc) then
       FOnProc(Cardinal(nList.Items[0]^));
    FreeMem(nList.Items[0]);
    nList.Delete(0);
  end;
  FProcess.UnlockList;
end;

//Desc: 处理消息
procedure TThreadEvent.WndProc(var nMsg: TMessage);
begin
  if (nMsg.WParam = WM_WParam) and (nMsg.LParam = WM_LParam) then
  with FOwner do
  if not (csDestroying in ComponentState) then
  begin
    if (nMsg.Msg = WM_Begin) and Assigned(FOnBegin) then FOnBegin(FMax);
    if (nMsg.Msg = WM_DATA) then SyncEvent;
    if (nMsg.Msg = WM_End) and Assigned(FOnEnd) then FOnEnd(FNormal, FRate);
  end;
end;

{************************** TZnZip **************************} 
constructor TZnZip.Create(AOwner: TComponent);
begin
  FBusy := False;
  FZipLevel := zcDefault;
  inherited Create(AOwner);
end;

destructor TZnZip.Destroy;
begin
  StopZnZip;
  inherited Destroy;
end;

procedure TZnZip.StopZnZip;
begin
  if FBusy and Assigned(FThread) then
  begin
     FThread.Terminate;
     FThread.WaitFor;
     FreeAndNil(FThread);
  end;

  FreeAndNil(FEvent);
  //释放事件
end;

//Desc: 压缩nStream
procedure TZnZip.ZipStream(const nSource,nDest: TStream);
begin
  if not Assigned(FThread) then
  begin
    FBusy := True;
    FFrom := nSource; FDest := nDest;

    if not Assigned(FEvent) then
       FEvent := TThreadEvent.Create(Self);
    FThread := TZipThread.Create(Self, True);
  end;
end;

//Desc: 解压缩nStream
procedure TZnZip.UnZipStream(const nSource,nDest: TStream);
begin
  if not Assigned(FThread) then
  begin
    FBusy := True;
    FFrom := nSource; FDest := nDest;

    if not Assigned(FEvent) then
       FEvent := TThreadEvent.Create(Self);
    FThread := TZipThread.Create(Self, False);
  end;
end;

end.
