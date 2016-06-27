{*******************************************************************************
  ����: dmzn@163.com 2012-02-03
  ����: ҵ��������ݷ�װ��
*******************************************************************************}
unit UBusinessPacker;

interface

uses
  Windows, Classes, SyncObjs, SysUtils, NativeXml, UObjectList, ULibFun;

type
  PBWWorkerInfo = ^TBWWorkerInfo;
  TBWWorkerInfo = record
    FUser   : string;              //������
    FIP     : string;              //IP��ַ
    FMAC    : string;              //������ʶ
    FTime   : TDateTime;           //����ʱ��
    FKpLong : Int64;               //����ʱ��
  end;

  TBWWorkerInfoType = (itFrom, itVia, itFinal);
  //��Ϣ����

  PBWDataBase = ^TBWDataBase;
  TBWDataBase = record
    FWorker   : string;            //��װ��
    FFrom     : TBWWorkerInfo;     //Դ
    FVia      : TBWWorkerInfo;     //����
    FFinal    : TBWWorkerInfo;     //����

    FMsgNO    : string;            //��Ϣ��
    FKey      : string;            //��¼���
    FParam    : string;            //��չ����

    FResult   : Boolean;           //ִ�н��
    FErrCode  : string;            //�������
    FErrDesc  : string;            //��������
  end;

  TBusinessPackerBase = class(TObject)
  protected
    FEnabled: Boolean;
    //���ñ��
    FStrBuilder: TStrings;
    //�ַ�������
    FXMLBuilder: TNativeXml;
    //XML������
    FCodeEnable: Boolean;
    //���ñ���
    procedure DoInitIn(const nData: Pointer); virtual;
    procedure DoInitOut(const nData: Pointer); virtual;
    procedure DoPackIn(const nData: Pointer); virtual;
    procedure DoUnPackIn(const nData: Pointer); virtual;
    procedure DoPackOut(const nData: Pointer); virtual;
    procedure DoUnPackOut(const nData: Pointer); virtual;
    //����ʵ��
    function PackerEncode(const nStr: string): string; overload;
    function PackerEncode(const nDT: TDateTime): string; overload;
    function PackerEncode(const nVal: Boolean): string; overload;
    procedure PackerDecode(const nStr: string; var nValue: string); overload;
    procedure PackerDecode(const nStr: string; var nValue: Boolean); overload;
    procedure PackerDecode(const nStr: string; var nValue: Integer); overload;
    procedure PackerDecode(const nStr: string; var nValue: Cardinal); overload;
    procedure PackerDecode(const nStr: string; var nValue: Int64); overload;
    procedure PackerDecode(const nStr: string; var nValue: Double); overload;
    procedure PackerDecode(const nStr: string; var nValue: TDateTime); overload;
    //�������
    procedure PackWorkerInfo(const nBuilder: TStrings; var nInfo: TBWWorkerInfo;
      const nPrefix: string; const nEncode: Boolean = True);
    //���������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    class function PackerName: string; virtual;
    //������
    procedure InitData(const nData: Pointer; const nIn: Boolean;
      const nSub: Boolean = True; const nBase: Boolean = True);
    //��ʼ��
    function PackIn(const nData: Pointer; nCode: Boolean = True): string;
    procedure UnPackIn(const nStr: string; const nData: Pointer;
      nCode: Boolean = True);
    //��δ���
    function PackOut(const nData: Pointer; nCode: Boolean = True): string;
    procedure UnPackOut(const nStr: string; const nData: Pointer;
      nCode: Boolean = True);
    //���δ���
    property StrBuilder: TStrings read FStrBuilder;
    property XMLBuilder: TNativeXml read FXMLBuilder;
    //�������
  end;

  TBusinessPackerClass = class of TBusinessPackerBase;
  //class type

  TBusinessPackerManager = class(TObject)
  private
    FPackerClass: TObjectDataList;
    //���б�
    FPackerPool: TObjectDataList;
    //�����
    FNumLocked: Integer;
    //��������
    FSrvClosed: Integer;
    //����ر�
    FSyncLock: TCriticalSection;
    //ͬ����
  protected
    function GetPacker(const nName: string): TBusinessPackerBase;
    //��ȡ��������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure RegistePacker(const nPacker: TBusinessPackerClass;
     const nPackerID: string = '');
    procedure UnRegistePacker(const nPackerID: string);
    //ע����
    function LockPacker(const nName: string): TBusinessPackerBase;
    procedure RelasePacker(const nPacker: TBusinessPackerBase);
    //�����ͷ�
    procedure MoveTo(const nManager: TBusinessPackerManager);
    //�ƶ�����
  end;

function PackerEncodeStr(const nStr: string): string;
function PackerDecodeStr(const nStr: string): string;
//�ַ�����

var
  gBusinessPackerManager: TBusinessPackerManager = nil;
  //ȫ��ʹ��

implementation

const
  cYes  = $0002;
  cNo   = $0005;

function PackerEncodeStr(const nStr: string): string;
begin
  Result := EncodeBase64(nStr);
end;

function PackerDecodeStr(const nStr: string): string;
begin
  Result := DecodeBase64(nStr);
end;

//------------------------------------------------------------------------------
constructor TBusinessPackerManager.Create;
begin
  FNumLocked := 0;
  FSrvClosed := cNo;
  
  FSyncLock := TCriticalSection.Create;
  FPackerPool := TObjectDataList.Create(dtObject);
  FPackerClass := TObjectDataList.Create(dtClass);
end;

destructor TBusinessPackerManager.Destroy;
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

    FreeAndNil(FPackerPool);
    FreeAndNil(FPackerClass);
  finally
    FSyncLock.Leave;
  end;

  FreeAndNil(FSyncLock);
  inherited;
end;

//Date: 2012-3-7
//Parm: ����������;��ʶ
//Desc: ע��nPacker��
procedure TBusinessPackerManager.RegistePacker(
  const nPacker: TBusinessPackerClass; const nPackerID: string);
begin
  FSyncLock.Enter;
  try
    FPackerClass.AddItem(nPacker, nPackerID);
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-11-20
//Parm: ��ʶ
//Desc: ��ע��nPackerID����Ͷ���
procedure TBusinessPackerManager.UnRegistePacker(const nPackerID: string);
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FPackerClass.ItemHigh downto FPackerClass.ItemLow do
     if FPackerClass[nIdx].FItemID = nPackerID then
      FPackerClass.DeleteItem(nIdx);
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

    for nIdx:=FPackerPool.ItemHigh downto FPackerPool.ItemLow do
     if FPackerPool[nIdx].FItemID = nPackerID then
      FPackerPool.DeleteItem(nIdx);
    //�ͷŶ���
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2012-3-7
//Parm: ������
//Desc: ��ȡ����ִ��nFunName�Ĺ�������
function TBusinessPackerManager.GetPacker(
  const nName: string): TBusinessPackerBase;
var nIdx: Integer;
    nPacker: TBusinessPackerBase;
    nClass: TBusinessPackerClass;
begin
  Result := nil;

  for nIdx:=FPackerPool.ItemLow to FPackerPool.ItemHigh do
  begin
    nPacker := TBusinessPackerBase(FPackerPool.ObjectA[nIdx]);
    if nPacker.FEnabled and (nPacker.PackerName = nName) then
    begin
      Result := nPacker;
      Result.FEnabled := False;
      Exit;
    end;
  end;

  for nIdx:=FPackerClass.ItemLow to FPackerClass.ItemHigh do
  begin
    nClass := TBusinessPackerClass(FPackerClass.ClassA[nIdx]);
    if nClass.PackerName = nName then
    begin
      Result := nClass.Create;
      Result.FEnabled := False;

      FPackerPool.AddItem(Result, FPackerClass[nIdx].FItemID);
      Exit;
    end;
  end;
end;

//Desc: ��ȡ��������
function TBusinessPackerManager.LockPacker(
  const nName: string): TBusinessPackerBase;
begin
  Result := nil;
  if FSrvClosed = cYes then Exit;
  
  FSyncLock.Enter;
  try
    if FSrvClosed = cYes then Exit;
    Result := GetPacker(nName);
    
    if not Assigned(Result) then
      raise Exception.Create(Format('Packer "%s" is invalid.', [nName]));
    //xxxxx
  finally
    if Assigned(Result) then
      InterlockedIncrement(FNumLocked);
    FSyncLock.Leave;
  end;
end;

//Desc: �ͷŹ�������
procedure TBusinessPackerManager.RelasePacker(
  const nPacker: TBusinessPackerBase);
begin
  if Assigned(nPacker) then
  try
    FSyncLock.Enter;
    nPacker.FEnabled := True;
    InterlockedDecrement(FNumLocked);
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: �����ݽ���nManager����
procedure TBusinessPackerManager.MoveTo(const nManager: TBusinessPackerManager);
begin
  FPackerClass.MoveData(nManager.FPackerClass);
  FPackerPool.MoveData(nManager.FPackerPool);
end;

//------------------------------------------------------------------------------
constructor TBusinessPackerBase.Create;
begin
  FEnabled := True;
  FStrBuilder := TStringList.Create;
  FXMLBuilder := TNativeXml.Create;
end;

destructor TBusinessPackerBase.Destroy;
begin
  FStrBuilder.Free;
  FXMLBuilder.Free;
  inherited;
end;

class function TBusinessPackerBase.PackerName: string;
begin
  Result := '';
end;

//Date: 2012-3-14
//Parm: ����;���;����;����
//Desc: �������ʼ��nData����
procedure TBusinessPackerBase.InitData(const nData: Pointer;
 const nIn,nSub,nBase: Boolean);
var nBW: TBWDataBase;
begin
  if nBase then
  begin
    FillChar(nBW, SizeOf(nBW), #0);
    nBW.FMsgNO := PBWDataBase(nData).FMsgNO;
    nBW.FKey := PBWDataBase(nData).FKey;
    PBWDataBase(nData)^ := nBW;

    with PBWDataBase(nData)^ do
    begin
      FFrom.FTime := Now;
      FVia.FTime := Now;
      FFinal.FTime := Now;
      FResult := False;
    end;
  end;

  if nSub then
  begin
    if nIn then
         DoInitIn(nData)
    else DoInitOut(nData);
  end;
end;

//Date: 2012-3-7
//Parm: ��������;�Ƿ����
//Desc: ����������nData�������
function TBusinessPackerBase.PackIn(const nData: Pointer; nCode: Boolean): string;
begin
  FStrBuilder.Clear;
  FCodeEnable := nCode;

  DoPackIn(nData);
  Result := FStrBuilder.Text;
end;

//Date: 2012-3-7
//Parm: �ַ�����;����
//Desc: ��nStr�������
procedure TBusinessPackerBase.UnPackIn(const nStr: string; const nData: Pointer;
  nCode: Boolean);
begin
  FStrBuilder.Text := nStr;
  FCodeEnable := nCode;
  DoUnPackIn(nData);
end;

//Date: 2012-3-7
//Parm: �ṹ����;�Ƿ����
//Desc: �Խṹ����nData�������
function TBusinessPackerBase.PackOut(const nData: Pointer; nCode: Boolean): string;
begin
  FStrBuilder.Clear;
  FCodeEnable := nCode;

  DoPackOut(nData);
  Result := FStrBuilder.Text;
end;

//Date: 2012-3-7
//Parm: �ַ�����
//Desc: ��nStr�������
procedure TBusinessPackerBase.UnPackOut(const nStr: string;
 const nData: Pointer; nCode: Boolean);
begin
  FStrBuilder.Text := nStr;
  FCodeEnable := nCode;
  DoUnPackOut(nData);
end;

//Date: 2012-3-7
//Parm: ������;��Ϣ;ǰ׺;�Ƿ����
//Desc: ����nInfo����Ϣ
procedure TBusinessPackerBase.PackWorkerInfo(const nBuilder: TStrings;
  var nInfo: TBWWorkerInfo; const nPrefix: string; const nEncode: Boolean);
begin
  with nBuilder,nInfo do
  begin
    if nEncode  then
    begin
      Values[nPrefix + '_User']    := PackerEncode(FUser);
      Values[nPrefix + '_MAC']     := PackerEncode(FMAC);
      Values[nPrefix + '_IP']      := PackerEncode(FIP);
      Values[nPrefix + '_Time']    := PackerEncode(FTime);
      Values[nPrefix + '_KpLong']  := IntToStr(FKpLong);
    end else
    begin
      PackerDecode(Values[nPrefix + '_User'], FUser);
      PackerDecode(Values[nPrefix + '_IP'], FIP);
      PackerDecode(Values[nPrefix + '_MAC'], FMAC);
      PackerDecode(Values[nPrefix + '_Time'], FTime);
      PackerDecode(Values[nPrefix + '_KpLong'], FKpLong);
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��nStr����
function TBusinessPackerBase.PackerEncode(const nStr: string): string;
begin
  if FCodeEnable then
       Result := PackerEncodeStr(nStr)
  else Result := nStr;
end;

//Desc: ������
function TBusinessPackerBase.PackerEncode(const nDT: TDateTime): string;
begin
  try
    Result := DateTime2Str(nDT);
  except
    Result := DateTime2Str(Now);
  end;
end;

//Desc: ������
function TBusinessPackerBase.PackerEncode(const nVal: Boolean): string;
begin
  if nVal then
       Result := 'Y'
  else Result := 'N';
end;

//Desc: �ַ���
procedure TBusinessPackerBase.PackerDecode(const nStr: string;
 var nValue: string);
begin
  if nStr = '' then
  begin
    nValue := '';
  end else

  if FCodeEnable then
       nValue := PackerDecodeStr(nStr)
  else nValue := nStr;
end;

//Desc: ������
procedure TBusinessPackerBase.PackerDecode(const nStr: string;
 var nValue: Boolean);
begin
  nValue := nStr = 'Y';
end;

//Desc: �з�������
procedure TBusinessPackerBase.PackerDecode(const nStr: string;
 var nValue: Integer); 
begin
  if nStr = '' then
       nValue := 0
  else nValue := StrToInt(nStr)
end;

//Desc: �޷�������
procedure TBusinessPackerBase.PackerDecode(const nStr: string;
 var nValue: Cardinal);
begin
  if nStr = '' then
       nValue := 0
  else nValue := StrToInt(nStr)
end;

//Desc: 64��������
procedure TBusinessPackerBase.PackerDecode(const nStr: string;
 var nValue: Int64);
begin
  if nStr = '' then
       nValue := 0
  else nValue := StrToInt64Def(nStr, 0)
end;

//Desc: ������
procedure TBusinessPackerBase.PackerDecode(const nStr: string;
 var nValue: Double);
begin
  if nStr = '' then
       nValue := 0
  else nValue := StrToFloat(nStr);
end;

//Desc: ����
procedure TBusinessPackerBase.PackerDecode(const nStr: string;
 var nValue: TDateTime);
begin
  if nStr = '' then
       nValue := 0
  else nValue := Str2DateTime(nStr);
end;

//------------------------------------------------------------------------------  
procedure TBusinessPackerBase.DoInitIn(const nData: Pointer);
begin

end;

procedure TBusinessPackerBase.DoInitOut(const nData: Pointer);
begin

end;

procedure TBusinessPackerBase.DoPackIn(const nData: Pointer);
begin

end;

procedure TBusinessPackerBase.DoPackOut(const nData: Pointer);
begin

end;

procedure TBusinessPackerBase.DoUnPackIn(const nData: Pointer);
begin

end;

procedure TBusinessPackerBase.DoUnPackOut(const nData: Pointer);
begin

end;

initialization
  gBusinessPackerManager := TBusinessPackerManager.Create;
finalization
  FreeAndNil(gBusinessPackerManager);
end.


