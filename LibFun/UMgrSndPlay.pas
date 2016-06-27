{*******************************************************************************
  作者: dmzn@163.com 2012-1-10
  描述: 顺序播放多个声音文件

  备注:
  *.线程模式,PlaySound使用SND_SYNC同步模式.
*******************************************************************************}
unit UMgrSndPlay;

interface

uses
  Windows, Classes, SyncObjs, SysUtils, MMSystem, UWaitItem;

type
  TSoundPlayManager = class;
  TSoundPlayer = class(TThread)
  private
    FOwner: TSoundPlayManager;
    {*拥有者*}
    FSounds: TStrings;
    {*声音列表*}
    FWaiter: TWaitObject;
    {*等待对象*}
  protected
    procedure Execute; override;
    {*执行线程*}
  public
    constructor Create(AOwner: TSoundPlayManager);
    destructor Destroy; override;
    {*创建释放*}
    procedure Wakeup;
    {*开始播放*}
    procedure StopMe;
    {*停止线程*}
  end;

  TSoundPlayManager = class(TObject)
  private
    FPlayer: TSoundPlayer;
    {*播放线程*}
    FSounds: TStrings;
    {*声音列表*}
    FSyncer: TCriticalSection;
    {*同步对象*}
  protected
    function IsSoundFile(const nFile: string): Boolean;
    {*声音有效*}
  public
    constructor Create;
    destructor Destroy; override;
    {*创建释放*}
    procedure PlaySound(const nFile: string);
    procedure PlaySounds(const nFiles: TStrings);
    {*播放声音*}
  end;

var
  gSoundPlayManager: TSoundPlayManager = nil;
  //全局使用

implementation

constructor TSoundPlayer.Create(AOwner: TSoundPlayManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FSounds := TStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 1000;
end;

destructor TSoundPlayer.Destroy;
begin
  FSounds.Free;
  FWaiter.Free;
  inherited;
end;

procedure TSoundPlayer.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TSoundPlayer.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;
  
  WaitFor;
  Free;
end;

procedure TSoundPlayer.Execute;
var nIdx,nNum: Integer;
begin
  nNum := 0;
  
  while not Terminated do
  try
    nNum := 0;
    FWaiter.EnterWait;
    if Terminated then Exit;

    FOwner.FSyncer.Enter;
    try
      FSounds.AddStrings(FOwner.FSounds);
      FOwner.FSounds.Clear;
    finally
      FOwner.FSyncer.Leave;
    end;

    if FSounds.Count > 0 then
    begin
      for nIdx:=0 to FSounds.Count - 1 do
      begin
        nNum := nIdx;
        sndPlaySound(PChar(FSounds[nIdx]), SND_SYNC);
      end;

      nNum := 0;
      FSounds.Clear;
    end;
  except
    if (nNum > 0) and (nNum < FSounds.Count) then
      FSounds.Delete(nNum);
    //delete the error item
  end;
end;

//------------------------------------------------------------------------------
constructor TSoundPlayManager.Create;
begin       
  FSounds := TStringList.Create;
  FSyncer := TCriticalSection.Create;
  FPlayer := TSoundPlayer.Create(Self);
end;

destructor TSoundPlayManager.Destroy;
begin
  FPlayer.StopMe;
  FSyncer.Free;
  FSounds.Free;
  inherited;
end;

//Desc: 判定nFile是否有效声音文件
function TSoundPlayManager.IsSoundFile(const nFile: string): Boolean;
begin
  Result := FileExists(nFile) and (LowerCase(ExtractFileExt(nFile)) = '.wav');
end;

//Desc: 播放nFile文件
procedure TSoundPlayManager.PlaySound(const nFile: string);
begin
  if IsSoundFile(nFile) then
  begin
    FSyncer.Enter;
    try
      FSounds.Add(nFile);
    finally
      FSyncer.Leave;
      FPlayer.Wakeup;
    end;
  end;
end;

//Desc: 播放nFiles声音组
procedure TSoundPlayManager.PlaySounds(const nFiles: TStrings);
var nIdx,nNum: Integer;
begin
  nNum := 0;
  FSyncer.Enter;
  try
    for nIdx:=0 to nFiles.Count - 1 do
    if IsSoundFile(nFiles[nIdx]) then
    begin
      FSounds.Add(nFiles[nIdx]);
      Inc(nNum);
    end;
  finally
    FSyncer.Leave;
  end;

  if nNum > 0 then
    FPlayer.Wakeup;
  //xxxxx
end;

initialization
  gSoundPlayManager := TSoundPlayManager.Create;
finalization
  FreeAndNil(gSoundPlayManager);
end.
