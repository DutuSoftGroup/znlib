{*******************************************************************************
  ����: dmzn dmzn@163.com 2005.7
  ����: �ṩ�ļ���ѹ��/��ѹ������

  ����: nZip: TZnZip;
    nZip.SourceFile := 'C:\Text.Doc';
    nZip.DestFile := 'C:\Text.Doc.Bak'; nZip.ZipFile;

  ����:
  &.2006-02-06
  TZnZip���Create,Destroy����,���ѹ���߳���������,��������Ҫ�˳�
  ʱ�������Դ�޷��ͷŵ�����.
  TZipThread�޸���DoProcess,DoEnd����,�ж�FOwner�Ƿ���Destrying״̬,�����
  �����ڴ��д����.
  &.2006-06-13
  TZnZip�޸�StopZnZip����,FThread.Free�޸�ΪFreeAndNil(FThread).
  TZipThread�޸�DoEnd��Execute,��TerminatedΪTrueʱ������FThread:=nil,������
  StopZnZip��FThread.Free�޷���ȷ�ͷ�

  ����: ����Ԫ����Դ��,����/��ҵ�����ʹ��,�����뱣���˴���˵������.�����
  �Ա���Ԫ���˺����޸�,���ʼ�֪ͨ��,лл!
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
//Parm: nSource,����ѹ�ļ�; nDest,Ŀ���ļ�
//Desc: ��ѹnSource�ļ�,����nDest
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
//Parm: nSource,��ѹ���ļ�; nDest,Ŀ���ļ�
//Desc: ��nSourceѹ��,���浽nDest
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
