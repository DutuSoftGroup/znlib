{*******************************************************************************
  ����: dmzn@163.com 2012-02-03
  ����: ҵ�������÷�װ��
*******************************************************************************}
unit UBusinessWorker;

interface

uses
  Windows, Classes, SyncObjs, SysUtils, ULibFun, USysLoger, UObjectList,
  UBusinessPacker;

const
  {*worker action code*}
  cWorker_GetPackerName       = $0010;
  cWorker_GetSAPName          = $0011;
  cWorker_GetRFCName          = $0012;
  cWorker_GetMITName          = $0015;

type
  TBusinessWorkerBase = class(TObject)
  protected
    FEnabled: Boolean;
    //���ñ��
    FPacker: TBusinessPackerBase;
    //��װ��
    FWorkTime: TDateTime;
    FWorkTimeInit: Cardinal;
    //��ʼʱ��
    function DoWork(var nData: string): Boolean; overload; virtual;
    function DoWork(const nIn,nOut: Pointer): Boolean; overload; virtual; 
    //���ദ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  public
    constructor Create; virtual;
    destructor Destroy; override;
    //�����ͷ�
    class function FunctionName: string; virtual;
    //������
    function GetFlagStr(const nFlag: Integer): string; virtual;
    //�������
    function WorkActive(var nData: string): Boolean; overload;
    function WorkActive(const nIn,nOut: Pointer): Boolean; overload;
    //ִ��ҵ��
  end;

  TBusinessWorkerSweetHeart = class(TBusinessWorkerBase)
  public
    class function FunctionName: string; override;
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    class procedure RegWorker(const nSrvURL: string);
    //ע�����
  end;

  TBusinessWorkerClass = class of TBusinessWorkerBase;
  //class type

  TBusinessWorkerManager = class(TObject)
  private
    FWorkerClass: TObjectDataList;
    //���б�
    FWorkerPool: TObjectDataList;
    //�����
    FNumLocked: Integer;
    //��������
    FSrvClosed: Integer;
    //����ر�
    FSyncLock: TCriticalSection;
    //ͬ����
  protected
    function GetWorker(const nFunName: string): TBusinessWorkerBase;
    //��ȡ��������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure RegisteWorker(const nWorker: TBusinessWorkerClass;
      const nWorkerID: string = '');
    procedure UnRegistePacker(const nWorkerID: string);
    //ע����
    function LockWorker(const nFunName: string;
      const nExceptionOnNull: Boolean = True): TBusinessWorkerBase;
    procedure RelaseWorker(const nWorkder: TBusinessWorkerBase);
    //�����ͷ�
    procedure MoveTo(const nManager: TBusinessWorkerManager);
    //�ƶ�����
  end;

var
  gBusinessWorkerManager: TBusinessWorkerManager = nil;
  //ȫ��ʹ��

Resourcestring
  sSys_SweetHeart = 'Sys_SweetHeart';       //����ָ��

implementation

const
  cYes  = $0002;
  cNo   = $0005;

var
  gLocalServiceURL: string;
  //���ط����ַ�б�

class function TBusinessWorkerSweetHeart.FunctionName: string;
begin
  Result := sSys_SweetHeart;
end;

function TBusinessWorkerSweetHeart.DoWork(var nData: string): Boolean;
begin
  nData := PackerEncodeStr(gLocalServiceURL);
  Result := True;
end;

class procedure TBusinessWorkerSweetHeart.RegWorker(const nSrvURL: string);
begin
  gLocalServiceURL := nSrvURL;
  if Assigned(gBusinessWorkerManager) then
    gBusinessWorkerManager.RegisteWorker(TBusinessWorkerSweetHeart);
  //registe
end;

//------------------------------------------------------------------------------
constructor TBusinessWorkerManager.Create;
begin
  FNumLocked := 0;
  FSrvClosed := cNo;

  FSyncLock := TCriticalSection.Create;
  FWorkerPool := TObjectDataList.Create(dtObject);
  FWorkerClass := TObjectDataList.Create(dtClass);
end;

destructor TBusinessWorkerManager.Destroy;
begin
  InterlockedExchange(FSrvClosed, cYes);
  //set close float

  FSyncLock.Enter;
  try
    if FNumLocked > 0 then
    try
      FSyncLock.Leave;
      while FNumLocked > 0 do
        Sleep(1);
      //wait for relese
    finally
      FSyncLock.Enter;
    end;
    
    FreeAndNil(FWorkerPool);
    FreeAndNil(FWorkerClass);
  finally
    FSyncLock.Leave;
  end;

  FreeAndNil(FSyncLock);
  inherited;
end;

//Date: 2012-3-7
//Parm: ����������;��ʶ
//Desc: ע��nWorker��
procedure TBusinessWorkerManager.RegisteWorker(
  const nWorker: TBusinessWorkerClass; const nWorkerID: string);
begin
  FSyncLock.Enter;
  try
    FWorkerClass.AddItem(nWorker, nWorkerID);
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-11-22
//Parm: ��ʶ
//Desc: ��ע��nWorkerID����Ͷ���
procedure TBusinessWorkerManager.UnRegistePacker(const nWorkerID: string);
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FWorkerClass.ItemHigh downto FWorkerClass.ItemLow do
     if FWorkerClass[nIdx].FItemID = nWorkerID then
      FWorkerClass.DeleteItem(nIdx);
    //��ע����

    if FNumLocked > 0 then
    try
      InterlockedExchange(FSrvClosed, cYes);
      FSyncLock.Leave;

      while FNumLocked > 0 do
        Sleep(1);
      //wait for relese
    finally
      FSyncLock.Enter;
      InterlockedExchange(FSrvClosed, cNo);
    end;

    for nIdx:=FWorkerPool.ItemHigh downto FWorkerPool.ItemLow do
     if FWorkerPool[nIdx].FItemID = nWorkerID then
      FWorkerPool.DeleteItem(nIdx);
    //�ͷŶ���
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2012-3-7
//Parm: ������
//Desc: ��ȡ����ִ��nFunName�Ĺ�������
function TBusinessWorkerManager.GetWorker(
  const nFunName: string): TBusinessWorkerBase;
var nIdx: Integer;
    nWorker: TBusinessWorkerBase;
    nClass: TBusinessWorkerClass;
begin
  Result := nil;

  for nIdx:=FWorkerPool.ItemLow to FWorkerPool.ItemHigh do
  begin
    nWorker := TBusinessWorkerBase(FWorkerPool.ObjectA[nIdx]);
    if nWorker.FEnabled and (nWorker.FunctionName = nFunName) then
    begin
      Result := nWorker;
      Result.FEnabled := False;
      Exit;
    end;
  end;

  for nIdx:=FWorkerClass.ItemLow to FWorkerClass.ItemHigh do
  begin
    nClass := TBusinessWorkerClass(FWorkerClass.ClassA[nIdx]);
    if nClass.FunctionName = nFunName then
    begin
      Result := nClass.Create;
      Result.FEnabled := False;

      FWorkerPool.AddItem(Result, FWorkerClass[nIdx].FItemID);
      Exit;
    end;
  end;
end;

//Desc: ��ȡ��������
function TBusinessWorkerManager.LockWorker(const nFunName: string;
  const nExceptionOnNull: Boolean): TBusinessWorkerBase;
begin
  Result := nil;
  if FSrvClosed = cYes then Exit;

  FSyncLock.Enter;
  try
    if FSrvClosed = cYes then Exit;
    Result := GetWorker(nFunName);
    
    if (not Assigned(Result)) and nExceptionOnNull then
      raise Exception.Create(Format('Worker "%s" is invalid.', [nFunName]));
    //xxxxx
  finally
    if Assigned(Result) then
      InterlockedIncrement(FNumLocked);
    FSyncLock.Leave;
  end;
end;

//Desc: �ͷŹ�������
procedure TBusinessWorkerManager.RelaseWorker(
  const nWorkder: TBusinessWorkerBase);
begin
  if Assigned(nWorkder) then
  try
    FSyncLock.Enter;
    nWorkder.FEnabled := True;
    InterlockedDecrement(FNumLocked);
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: �����ݽ���nManager����
procedure TBusinessWorkerManager.MoveTo(const nManager: TBusinessWorkerManager);
begin
  FWorkerClass.MoveData(nManager.FWorkerClass);
  FWorkerPool.MoveData(nManager.FWorkerPool);
end;

//------------------------------------------------------------------------------
constructor TBusinessWorkerBase.Create;
begin
  FEnabled := True;
end;

destructor TBusinessWorkerBase.Destroy;
begin
  //nothing
  inherited;
end;

class function TBusinessWorkerBase.FunctionName: string;
begin
  Result := '';
end;

function TBusinessWorkerBase.GetFlagStr(const nFlag: Integer): string;
begin
  Result := '';
end;

function TBusinessWorkerBase.DoWork(var nData: string): Boolean;
begin
  Result := True;
end;

function TBusinessWorkerBase.DoWork(const nIn, nOut: Pointer): Boolean;
begin
  Result := True;
end;

procedure TBusinessWorkerBase.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(ClassType, 'ҵ��������', nEvent);
end;

//Date: 2012-3-9
//Parm: �������
//Desc: ִ����nDataΪ���ݵ�ҵ���߼�
function TBusinessWorkerBase.WorkActive(var nData: string): Boolean;
var nStr: string;
begin
  FPacker := nil;
  try
    nStr := GetFlagStr(cWorker_GetPackerName);
    if nStr <> '' then
    begin
      FPacker := gBusinessPackerManager.LockPacker(nStr);
      if FPacker.PackerName <> nStr then
      begin
        nData := 'Զ�̵���ʧ��(Packer Is Null).';
        Result := False;
        Exit;
      end;
    end;

    FWorkTime := Now;
    FWorkTimeInit := GetTickCount;
    Result := DoWork(nData);
  finally
    gBusinessPackerManager.RelasePacker(FPacker);
  end;
end;

//Date: 2012-3-11
//Parm: ָ�����;ָ�����
//Desc: ִ����nDataΪ���ݵ�ҵ���߼�
function TBusinessWorkerBase.WorkActive(const nIn,nOut: Pointer): Boolean;
var nPacker: string;
begin
  FPacker := nil;
  try
    nPacker := GetFlagStr(cWorker_GetPackerName);
    if nPacker <> '' then
    begin
      FPacker := gBusinessPackerManager.LockPacker(nPacker);
      if FPacker.PackerName <> nPacker then
      begin
        Result := False;
        Exit;
      end;
    end;

    FWorkTime := Now;
    FWorkTimeInit := GetTickCount;
    Result := DoWork(nIn, nOut);
  finally
    gBusinessPackerManager.RelasePacker(FPacker);
  end;
end;

initialization
  gBusinessWorkerManager := TBusinessWorkerManager.Create;
finalization
  FreeAndNil(gBusinessWorkerManager);
end.


