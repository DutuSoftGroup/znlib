{*******************************************************************************
  作者: dmzn@163.com 2008-8-18
  描述: 管理系统内的全局变量

  备注:
  &.变量管理器:用于维护一组系统内变量的列表,各个模块将需要共享的值注册进来,其它
    模块获得需要的变量值.这种方法可以减小各模块间的耦合度.
  &.变量列表中的每一项称为一个变量项,每项元素由唯一的标记区分,数据域支持基本的
    数据类型,可以自由扩充.
*******************************************************************************}
unit UMgrVar;

interface

uses
  Windows, Classes, SysUtils;

const
  cVarEmpty = 'VarEmpty_8327';
  //空参数

type
  PVariantItemData = ^TVariantItemData;
  TVariantItemData = record
    FItemID: integer;               //变量标记
    FItemName: string;              //变量名称

    FItemStr: string;               //字符
    FItemInt: integer;              //整型
    FItemPtr: Pointer;              //指针
    FItemFloat: Double;             //大浮点
    FItemInt64: Int64;              //大整型
  end;

  TVariantManager = class(TObject)
  protected
    FVariants: TList;
    {*变量列表*}
    procedure ClearVarList; overload;
    {*清理列表*}
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    {*创建释放*}
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
    {*添加*}
    procedure DelVar(const nID: integer); overload;
    procedure DelVar(const nName: string); overload;
    {*删除*}
    function VarIndex(const nID: integer): integer; overload;
    function VarIndex(const nName: string): integer; overload;
    function VarItem(const nID: integer): PVariantItemData; overload;
    function VarItem(const nName: string): PVariantItemData; overload;
    {*检索*}
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
    {*取值*}
  end;

var
  gVariantManager: TVariantManager = nil;
  //全局使用变量管理器

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

//Desc: 清空变量列表
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
//Desc: 新添加变量项
function TVariantManager.NewVar: PVariantItemData;
begin
  New(Result);
  FVariants.Add(Result);
  FillChar(Result^, SizeOf(TVariantItemData), #0);
end;

//Desc: 添加整型
procedure TVariantManager.AddVarInt(const nID, nInt: integer);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemID := nID;
  nItem.FItemInt := nInt;
end;

//Desc: 添加整型
procedure TVariantManager.AddVarInt(const nName: string; const nInt: integer);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemName := nName;
  nItem.FItemInt := nInt;
end;

//Desc: 添加指针
procedure TVariantManager.AddVarPtr(const nName: string; const nPtr: Pointer);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemName := nName;
  nItem.FItemPtr := nPtr;
end;

//Desc: 添加指针
procedure TVariantManager.AddVarPtr(const nID: integer; const nPtr: Pointer);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemID := nID;
  nItem.FItemPtr := nPtr;
end;

//Desc: 添加字符串
procedure TVariantManager.AddVarStr(const nName, nStr: string);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemName := nName;
  nItem.FItemStr := nStr;  
end;

//Desc: 添加字符串
procedure TVariantManager.AddVarStr(const nID: integer; const nStr: string);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemID := nID;
  nItem.FItemStr := nStr;
end;

//Desc: 浮点
procedure TVariantManager.AddVarFloat(const nID: integer; const nFloat: Double);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemID := nID;
  nItem.FItemFloat := nFloat;
end;

//Desc: 浮点
procedure TVariantManager.AddVarFloat(const nName: string; const nFloat: Double);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemName := nName;
  nItem.FItemFloat := nFloat;
end;

//Desc: 大整型
procedure TVariantManager.AddVarInt64(const nName: string; const nInt: Int64);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemName := nName;
  nItem.FItemInt64 := nInt;
end;

//Desc: 大整型
procedure TVariantManager.AddVarInt64(const nID: integer; const nInt: Int64);
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if not Assigned(nItem) then nItem := NewVar;

  nItem.FItemID := nID;
  nItem.FItemInt64 := nInt;
end;

//Desc: 删除变量
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

//Desc: 删除变量
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
//Desc: 检索
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

//Desc: 检索
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

//Desc: 检索
function TVariantManager.VarItem(const nID: integer): PVariantItemData;
var nIdx: integer;
begin
  nIdx := VarIndex(nID);
  if nIdx < 0 then
       Result := nil
  else Result := FVariants[nIdx];
end;

//Desc: 检索
function TVariantManager.VarItem(const nName: string): PVariantItemData;
var nIdx: integer;
begin
  nIdx := VarIndex(nName);
  if nIdx < 0 then
       Result := nil
  else Result := FVariants[nIdx];
end;

//Desc: 整型变量
function TVariantManager.VarInt(const nID: integer; const nInt: integer): integer;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if Assigned(nItem) then
       Result := nItem.FItemInt
  else Result := nInt;
end;

//Desc: 整型变量
function TVariantManager.VarInt(const nName: string; const nInt: integer): integer;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if Assigned(nItem) then
       Result := nItem.FItemInt
  else Result := nInt;
end;

//Desc: 指针变量
function TVariantManager.VarPtr(const nID: integer; const nPtr: Pointer): Pointer;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if Assigned(nItem) then
       Result := nItem.FItemPtr
  else Result := nPtr;
end;

//Desc: 指针变量
function TVariantManager.VarPtr(const nName: string; const nPtr: Pointer): Pointer;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if Assigned(nItem) then
       Result := nItem.FItemPtr
  else Result := nPtr;
end;

//Desc: 字符串变量
function TVariantManager.VarStr(const nID: integer; const nStr: string): string;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if Assigned(nItem) then
       Result := nItem.FItemStr
  else Result := nStr;
end;

//Desc: 字符串变量
function TVariantManager.VarStr(const nName: string; const nStr: string): string;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if Assigned(nItem) then
       Result := nItem.FItemStr
  else Result := nStr;
end;

//Desc: 浮点
function TVariantManager.VarFloat(const nName: string; const nFloat: Double): Double;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nName);
  if Assigned(nItem) then
       Result := nItem.FItemFloat
  else Result := nFloat;
end;

//Desc: 浮点
function TVariantManager.VarFloat(const nID: integer; const nFloat: Double): Double;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if Assigned(nItem) then
       Result := nItem.FItemFloat
  else Result := nFloat;
end;

//Desc: 大整型
function TVariantManager.VarInt64(const nID: integer; const nInt: Int64): Int64;
var nItem: PVariantItemData;
begin
  nItem := VarItem(nID);
  if Assigned(nItem) then
       Result := nItem.FItemInt64
  else Result := nInt;
end;

//Desc: 大整型
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

