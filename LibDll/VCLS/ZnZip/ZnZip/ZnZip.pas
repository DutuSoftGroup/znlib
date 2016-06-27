{*******************************************************************************
  作者: dmzn dmzn@163.com 2005.7
  描述: 提供文件的压缩/解压缩功能

  例程: nZip: TZnZip;
    nZip.SourceFile := 'C:\Text.Doc';
    nZip.DestFile := 'C:\Text.Doc.Bak'; nZip.ZipFile;

  更新:
  &.2006-02-06
  TZnZip添加Create,Destroy方法,解决压缩线程正在运行,而主程序要退出
  时分配的资源无法释放的问题.
  TZipThread修改了DoProcess,DoEnd方法,判断FOwner是否在Destrying状态,否则会
  导致内存读写错误.
  &.2006-06-13
  TZnZip修改StopZnZip方法,FThread.Free修改为FreeAndNil(FThread).
  TZipThread修改DoEnd和Execute,在Terminated为True时不设置FThread:=nil,否则导致
  StopZnZip的FThread.Free无法正确释放

  声明: 本单元公开源码,个人/商业可免费使用,不过请保留此处的说明文字.如果你
  对本单元作了合理修改,请邮件通知我,谢谢!
*******************************************************************************}
unit ZnZip;

interface

uses
  SysUtils, Classes, ComCtrls, ZlibEx;

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
   procedure ZipFile(const nSource,nDest: string);
   procedure UnZipFile(const nSource,nDest: string);
  public
   { public declarations }
   constructor Create(AOwner: TZnZip; IsZip: boolean);
  end;

  TOnBegin = procedure (const nMax: Cardinal) of object;
  TOnProcess = procedure (const nHasDone: Cardinal) of object;
  TOnEnd = procedure (const nNormal: boolean; nZipRate: Single) of object;

  TZnZip = class(TComponent)
  private
   { Private declarations }
   FSource	 : string;
   FDest		 : string;
   FBusy     : boolean;
   FThread   : TZipThread;
   FZipLevel : TZCompressionLevel;

   FOnBegin  : TOnBegin;
   FOnProc   : TOnProcess;
   FOnEnd    : TOnEnd;
  public
   { public declarations }
   constructor Create(AOwner: TComponent);override;
   destructor Destroy;override;

   procedure ZipFile;
   procedure UnZipFile;
   procedure StopZnZip;
  published
   { published declarations }
   property Busy: boolean read FBusy;
   property SourceFile: string read FSource write FSource;
   property DestFile: string read FDest write FDest;
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
  if Assigned(FOwner.FOnBegin) then FOwner.FOnBegin(FLeft);
end;

procedure TZipThread.DoEnd;
begin
  with FOwner do
  begin
    FBusy := False;
    if Assigned(FOnEnd) and (not (csDestroying in ComponentState)) then
      if FNormal then
        if FZip then
             FOnEnd(True, FZipRate)
        else FOnEnd(True, 0)
      else FOnEnd(False, 0);
  end;
end;

procedure TZipThread.DoProcess;
begin
  with FOwner do
  if Assigned(FOnProc) and
     (not (csDestroying in ComponentState)) then FOnProc(FHasDone);
end;

procedure TZipThread.Execute;
begin
    FNormal := True;
  try
    if FZip then
       ZipFile(FOwner.FSource, FOwner.FDest)
    else
       UnZipFile(FOwner.FSource, FOwner.FDest);
  except
    FNormal := False;
  end;

  if Terminated then
       FreeOnTerminate := False
  else FOwner.FThread := nil;
  Synchronize(DoEnd);
end;

//Name: UnZipFile
//Parm: nSource,待解压文件; nDest,目标文件
//Desc: 解压nSource文件,存入nDest
procedure TZipThread.UnZipFile(const nSource, nDest: string);
var nSStream: TMemoryStream;
	  nDStream: TMemoryStream;
    nBuf: array [0..BufSize] of Byte;
    nZipStream: TZDecompressionStream;
begin
    nSStream := TMemoryStream.Create;
    nDStream := TMemoryStream.Create;
  try
    nSStream.LoadFromFile(nSource);
    nZipStream := TZDecompressionStream.Create(nSStream);
    nZipStream.Seek(0, soFromBeginning);

    FHasDone := 0;
    FLeft := nZipStream.Size;
    Synchronize(DoBegin);

    while not Terminated and (FLeft > 0) do
    begin
       if FLeft > BufSize then
       begin
         nZipStream.Read(nBuf, BufSize);
         nDStream.Write(nBuf, BufSize);
         FHasDone := FHasDone + BufSize;
       end else
       begin
         nZipStream.Read(nBuf, FLeft);
         nDStream.Write(nBuf, FLeft);
         FHasDone := FHasDone + FLeft;
       end;

       Synchronize(DoProcess);
       FLeft := FLeft - BufSize;
    end;

    nZipStream.Free;
    if Terminated then
       FNormal := False else
    begin
      if FileExists(nDest) then DeleteFile(nDest);
      nDStream.SaveToFile(nDest);
    end;
  finally
    nDStream.Free;
    nSStream.Free;
  end;
end;

//Name: ZipFile
//Parm: nSource,待压缩文件; nDest,目标文件
//Desc: 把nSource压缩,保存到nDest
procedure TZipThread.ZipFile(const nSource, nDest: string);
var nSStream: TMemoryStream;
	  nDStream: TMemoryStream;
    nZipStream: TZCompressionStream;
    nBuf: array [0..BufSize] of Byte;
begin
    nSStream := TMemoryStream.Create;
    nDStream := TMemoryStream.Create;
    nZipStream := TZCompressionStream.Create(nDStream, FOwner.FZipLevel);
  try
    nSStream.LoadFromFile(nSource);
    nSStream.Seek(0, soFromBeginning);

    FHasDone := 0;
    FLeft := nSStream.Size;
    Synchronize(DoBegin);

    while not Terminated and (FLeft > 0) do
    begin
       if FLeft > BufSize then
       begin
         nSStream.Read(nBuf, BufSize);
         nZipStream.Write(nBuf, BufSize);
         FHasDone := FHasDone + BufSize;
       end else
       begin
         nSStream.Read(nBuf, FLeft);
         nZipStream.Write(nBuf, FLeft);
         FHasDone := FHasDone + FLeft;
       end;

       Synchronize(DoProcess);
       FLeft := FLeft - BufSize;
    end;

    FZipRate := nZipStream.CompressionRate;
    nZipStream.Free;
    
    if Terminated then
       FNormal := False else
    begin
      if FileExists(nDest) then DeleteFile(nDest);
      nDStream.SaveToFile(nDest);
    end;
  finally
    nDStream.Free;
    nSStream.Free;
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
end;

procedure TZnZip.UnZipFile;
begin
  if not Assigned(FThread) and FileExists(FSource) then
  begin
    FBusy := True;
    FThread := TZipThread.Create(Self, False);
  end;
end;

procedure TZnZip.ZipFile;
begin
  if not Assigned(FThread) and FileExists(FSource) then
  begin
    FBusy := True;
    FThread := TZipThread.Create(Self, True);
  end;
end;

end.
