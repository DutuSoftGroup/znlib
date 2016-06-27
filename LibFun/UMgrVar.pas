{*******************************************************************************
  ����: dmzn@163.com 2008-8-18
  ����: ����ϵͳ�ڵ�ȫ�ֱ���

  ��ע:
  &.����������:����ά��һ��ϵͳ�ڱ������б�,����ģ�齫��Ҫ�����ֵע�����,����
    ģ������Ҫ�ı���ֵ.���ַ������Լ�С��ģ������϶�.
  &.�����б��е�ÿһ���Ϊһ��������,ÿ��Ԫ����Ψһ�ı������,������֧�ֻ�����
    ��������,������������.
*******************************************************************************}
unit UMgrVar;

interface

uses
  Windows, Classes, SysUtils;

const
  cVarEmpty = 'VarEmpty_8327';
  //�ղ���

type
  PVariantItemData = ^TVariantItemData;
  TVariantItemData = record
    FItemID: integer;               //�������
    FItemName: string;              //��������

    FItemStr: string;               //�ַ�
    FItemInt: integer;              //����
    FItemPtr: Pointer;              //ָ��
    FItemFloat: Double;             //�󸡵�
    FItemInt64: Int64;              //������
  end;

  TVariantManager = class(TObject)
  protected
    FVariants: TList;
    {*�����б�*}
    procedure ClearVarList; overload;
    {*�����б�*}
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    {*�����ͷ�*}
    function NewVar: PVariantItemData;
    procedure AddVarStr(const nID: integer; const nStr: string); overload;
    procedure AddVarStr(const nName,nStr: string); overload;
    procedure AddVarInt(const nID,nInt: integer); overload;
    procedure AddVarInt(const nName: string; const nInt: integer); overload;
    procedure AddVarPtr(const nID: integer; const nPtr: Pointer); overload;
    procedure AddVarPtr(const nName: string; const nPtr: Pointer); overload;
    procedure AddVarFloat(const nID: integer; const nFloat: Double); overload;
    procedure AddVarFloat(const nName: string; const nFloat: Double); overload;
    procedure AddVarInt64(const nID: integer; const nInt: Int64); overload;
    procedure AddVarInt64(const nName: string; const nInt: Int64); overload;
    {*���*}
    procedure DelVar(const nID: integer); overload;
    procedure DelVar(const nName: string); overload;
    {*ɾ��*}
    function VarIndex(const nID: integer): integer; overload;
    function VarIndex(const nName: string): integer; overload;
    function VarItem(const nID: integer): PVariantItemData; overload;
    function VarItem(const nName: string): PVariantItemData; overload;
    {*����*}
    function VarStr(const nID: integer; const nStr: string = ''): string; overload;
    function VarStr(const nName: string;const nStr: string = ''): string; overload;
    function VarInt(const nID: integer; const nInt: integer = -1): integer; overload;
    function VarInt(const nName: string; const nInt: integer = -1): integer; overload; 
    function VarPtr(const nID: integer; const nPtr: Pointer = nil): Pointer; overload;
    function VarPtr(const nName: string; const nPtr: Pointer = nil): Pointer; overload;
    function VarFloat(const nID: integer; const nFloat: Double): Double; overload;
    function VarFloat(const nName: string; const nFloat: Double): Double; overload;
    function VarInt64(const nID: integer; const nInt: Int64 = 0): Int64; overload;
    function VarInt64(const nName: string; const nInt: Int64 = 0): Int64; overload;
    {*ȡֵ*}
  end;

var
  gVariantManager: TVariantManager = nil;
  //ȫ��ʹ�ñ���������

implementation

constructor TVariantManager.Create;
begin
  inherited;
  FVariants := TList.Create;
end;

destructor TVariantManager.Destroy;
begin
  ClearVarList;
  FVariants.Free;
  inherited;
end;

//Desc: ��ձ����б�
procedure TVariantManager.ClearVarList;
var nIdx: integer;
begin
  for nIdx:=FVariants.Count - 1 downto 0 do
  begin
    Dispose(PVariantItemData(FVariants[nIdx]));
    FVariants.Delete(nIdx);
  end;
end;

//------------------------------------------------------------------------------
//Desc: ����ӱ�����
function TVariantManager.NewVar: PVariantItemData;
begin
  New(Result);
  FVariants.Add(Result);
  FillChar(Result^, SizeOf(TVariantItemData), #0);
end;

//Desc: �������
procedure TVariantManager.AddVarInt(const nID, nInt: integer);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemID := nID;
  nItem.FItemInt := nInt;
end;

//Desc: �������
procedure TVariantManager.AddVarInt(const nName: string; const nInt: integer);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemName := nName;
  nItem.FItemInt := nInt;
end;

//Desc: ���ָ��
procedure TVariantManager.AddVarPtr(const nName: string; const nPtr: Pointer);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemName := nName;
  nItem.FItemPtr := nPtr;
end;

//Desc: ���ָ��
procedure TVariantManager.AddVarPtr(const nID: integer; const nPtr: Pointer);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemID := nID;
  nItem.FItemPtr := nPtr;
end;

//Desc: ����ַ���
procedure TVariantManager.AddVarStr(const nName, nStr: string);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemName := nName;
  nItem.FItemStr := nStr;  
end;

//Desc: ����ַ���
procedure TVariantManager.AddVarStr(const nID: integer; const nStr: string);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemID := nID;
  nItem.FItemStr := nStr;
end;

//Desc: ����
procedure TVariantManager.AddVarFloat(const nID: integer; const nFloat: Double);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemID := nID;
  nItem.FItemFloat := nFloat;
end;

//Desc: ����
procedure TVariantManager.AddVarFloat(const nName: string; const nFloat: Double);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemName := nName;
  nItem.FItemFloat := nFloat;
end;

//Desc: ������
procedure TVariantManager.AddVarInt64(const nName: string; const nInt: Int64);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemName := nName;
  nItem.FItemInt64 := nInt;
end;

//Desc: ������
procedure TVariantManager.AddVarInt64(const nID: integer; const nInt: Int64);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemID := nID;
  nItem.FItemInt64 := nInt;
end;

//Desc: ɾ������
procedure TVariantManager.DelVar(const nID: integer);
var nIdx: integer;
begin
  nIdx := VarIndex(nID);
  if nIdx > -1 then
  begin
    Dispose(PVariantItemData(FVariants[nIdx]));
    FVariants.Delete(nIdx);
  end;
end;

//Desc: ɾ������
procedure TVariantManager.DelVar(const nName: string);
var nIdx: integer;
begin
  nIdx := VarIndex(nName);
  if nIdx > -1 then
  begin
    Dispose(PVariantItemData(FVariants[nIdx]));
    FVariants.Delete(nIdx);
  end;
end;

//------------------------------------------------------------------------------
//Desc: ����
function TVariantManager.VarIndex(const nID: integer): integer;
var i,nCount: integer;
begin
  Result := -1;
  nCount := FVariants.Count - 1;

  for i:=0 to nCount do
  if PVariantItemData(FVariants[i]).FItemID = nID then
  begin
    Result := i; Break;
  end;
end;

//Desc: ����
function TVariantManager.VarIndex(const nName: string): integer;
var i,nCount: integer;
begin
  Result := -1;
  nCount := FVariants.Count - 1;

  for i:=0 to nCount do
  if CompareText(PVariantItemData(FVariants[i]).FItemName, nName) = 0 then
  begin
    Result := i; Break;
  end;
end;

//Desc: ����
function TVariantManager.VarItem(const nID: integer): PVariantItemData;
var nIdx: integer;
begin
  nIdx := VarIndex(nID);
  if nIdx < 0 then
       Result := nil
  else Result := FVariants[nIdx];
end;

//Desc: ����
function TVariantManager.VarItem(const nName: string): PVariantItemData;
var nIdx: integer;
begin
  nIdx := VarIndex(nName);
  if nIdx < 0 then
       Result := nil
  else Result := FVariants[nIdx];
end;

//Desc: ���ͱ���
function TVariantManager.VarInt(const nID: integer; const nInt: integer): integer;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if Assigned(nItem) then
       Result := nItem.FItemInt
  else Result := nInt;
end;

//Desc: ���ͱ���
function TVariantManager.VarInt(const nName: string; const nInt: integer): integer;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if Assigned(nItem) then
       Result := nItem.FItemInt
  else Result := nInt;
end;

//Desc: ָ�����
function TVariantManager.VarPtr(const nID: integer; const nPtr: Pointer): Pointer;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if Assigned(nItem) then
       Result := nItem.FItemPtr
  else Result := nPtr;
end;

//Desc: ָ�����
function TVariantManager.VarPtr(const nName: string; const nPtr: Pointer): Pointer;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if Assigned(nItem) then
       Result := nItem.FItemPtr
  else Result := nPtr;
end;

//Desc: �ַ�������
function TVariantManager.VarStr(const nID: integer; const nStr: string): string;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if Assigned(nItem) then
       Result := nItem.FItemStr
  else Result := nStr;
end;

//Desc: �ַ�������
function TVariantManager.VarStr(const nName: string; const nStr: string): string;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if Assigned(nItem) then
       Result := nItem.FItemStr
  else Result := nStr;
end;

//Desc: ����
function TVariantManager.VarFloat(const nName: string; const nFloat: Double): Double;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if Assigned(nItem) then
       Result := nItem.FItemFloat
  else Result := nFloat;
end;

//Desc: ����
function TVariantManager.VarFloat(const nID: integer; const nFloat: Double): Double;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if Assigned(nItem) then
       Result := nItem.FItemFloat
  else Result := nFloat;
end;

//Desc: ������
function TVariantManager.VarInt64(const nID: integer; const nInt: Int64): Int64;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if Assigned(nItem) then
       Result := nItem.FItemInt64
  else Result := nInt;
end;

//Desc: ������
function TVariantManager.VarInt64(const nName: string; const nInt: Int64): Int64;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if Assigned(nItem) then
       Result := nItem.FItemInt64
  else Result := nInt; 
end;

initialization
  gVariantManager := TVariantManager.Create;
finalization
  FreeAndNil(gVariantManager);
end.

