{*******************************************************************************
  作者: dmzn@163.com 2008-08-06
  描述: 统一管理控件(TWinControl)的创建销毁

  备注:
  &.方法GetCtrls获取已注册类的信息,列表中每一项是PControlItem
  &.方法GetInstances,GetAllInstance获取实例,每一项是TWinControl对象
*******************************************************************************}
unit UMgrControl;

interface

uses
  Windows, Classes, SysUtils, Controls;

type
  PControlItem = ^TControlItem;
  TControlItem = record
    FClass: TWinControlClass;       //类别
    FClassID: integer;              //标识
    FGroupID: string;               //分组
    FInstance: TList;               //实例
  end;

  TOnCtrlCreate = function (AClass:TWinControlClass; AOwner: TComponent): TWinControl;
  //创建实例
  TOnCtrlFree = procedure (const nClassID: integer; const nCtrl: TWinControl;
    var nNext: Boolean) of Object;
  //实例释放

  TControlManager = class(TObject)
  private
    FCtrlList: TList;
    {*控件列表*}
    FOnCtrlFree: TOnCtrlFree;
    {*释放事件*}
  protected
    procedure ClearCtrlList(const nFree: Boolean);
    {*清理列表*}
    procedure DeleteItem(const nIdx: Integer; const nFreeInst: Boolean);
    {*删除项*}
  public
    constructor Create;
    destructor Destroy; override;
    {*创建释放*}
    procedure RegCtrl(const nClass: TWinControlClass; const nClassID: integer;
     const nGroupID: string = '');
    procedure UnregCtrl(const nGroupID: string; const nFree: Boolean); overload;
    procedure UnregCtrl(const nClassID: Integer; const nFree: Boolean); overload;
    {*注册控件*}
    function NewCtrl(const nClassID: integer; const nOwner: TComponent;
      var nIndex: integer; const nOnCreate: TOnCtrlCreate = nil): TWinControl;
    function NewCtrl2(const nClassID: integer; const nOwner: TComponent;
      const nAlign: TAlign = alClient): TWinControl;
    function NewCtrl3(const nClassID: integer; const nOwner: TComponent;
      const nOnCreate: TOnCtrlCreate = nil): TWinControl;
    {*创建控件*}
    procedure FreeCtrl(const nClassID: integer; const nFree: Boolean = True;
     nIndex: integer = -1; nInstance: Pointer = nil);
    procedure FreeAllCtrl(const nFree: Boolean = True);
    {*释放控件*}
    function GetCtrl(const nGroupID: string): PControlItem; overload;
    function GetCtrl(const nClassID: integer): PControlItem; overload;
    function GetCtrls(const nList: TList): Boolean;
    {*检索控件*}
    function GetInstances(const nClassID: integer; const nList: TList): Boolean;
    function GetInstance(const nClassID: integer; const nIndex: integer = 0): TWinControl;
    function GetAllInstance(const nList: TList): Boolean;
    {*检索实例*}
    function IsInstanceExists(const nClassID: integer): Boolean;
    {*实例存在*}
    procedure MoveTo(const nManager: TControlManager);
    {*转移数据*}
    property OnCtrlFree: TOnCtrlFree read FOnCtrlFree write FOnCtrlFree;
    {*属性*}
  end;

var
  gControlManager: TControlManager = nil;
  //全局使用

implementation

constructor TControlManager.Create;
begin
  inherited;
  FCtrlList := TList.Create;
end;

destructor TControlManager.Destroy;
begin
  ClearCtrlList(True);
  inherited;
end;

//Date: 2013-11-24
//Parm: 索引;释放实例
//Desc: 删除控件列表中索引为nIdx的项
procedure TControlManager.DeleteItem(const nIdx: Integer;
 const nFreeInst: Boolean);
var i: Integer;
    nItem: PControlItem;
begin
  nItem := FCtrlList[nIdx];
  if Assigned(nItem.FInstance) then
  begin
    if nFreeInst then
    begin
      for i:=nItem.FInstance.Count - 1 downto 0 do
      begin
        if Assigned(nItem.FInstance[i]) then
          TWinControl(nItem.FInstance[i]).Free;
        nItem.FInstance.Delete(i);
      end;
    end;

    FreeAndNil(nItem.FInstance);
  end;

  Dispose(nItem);
  FCtrlList.Delete(nIdx);
end;

//Desc: 清空控件列表
procedure TControlManager.ClearCtrlList(const nFree: Boolean);
var nIdx: integer;
begin
  for nIdx:=FCtrlList.Count - 1 downto 0 do
    DeleteItem(nIdx, False);
  //xxxxx
  
  if nFree then
    FreeAndNil(FCtrlList);
  //xxxxx
end;

//Date: 2008-8-6
//Parm: 类型;标识;分组
//Desc: 注册一个标识为nClassID的类
procedure TControlManager.RegCtrl(const nClass: TWinControlClass;
  const nClassID: integer; const nGroupID: string);
var nItem: PControlItem;
begin
  if not Assigned(GetCtrl(nClassID))then
  begin
    New(nItem);
    FCtrlList.Add(nItem);

    with nItem^ do
    begin
      FClass := nClass;
      FClassID := nClassID;
      FGroupID := nGroupID;
      FInstance := nil;
    end;
  end;
end;

//Date: 2013-11-24
//Parm: 分组标识
//Desc: 卸载分组标识为nGroupID的控件
procedure TControlManager.UnregCtrl(const nGroupID: string; const nFree: Boolean);
var nIdx: Integer;
    nItem: PControlItem;
begin
  for nIdx:=FCtrlList.Count - 1 downto 0 do
  begin
    nItem := FCtrlList[nIdx];
    if nItem.FGroupID = nGroupID then
      DeleteItem(nIdx, nFree);
    //xxxxx
  end;
end;

//Date: 2013-11-24
//Parm: 类标识
//Desc: 卸载类标识为nClassID的控件
procedure TControlManager.UnregCtrl(const nClassID: Integer; const nFree: Boolean);
var nIdx: Integer;
    nItem: PControlItem;
begin
  for nIdx:=FCtrlList.Count - 1 downto 0 do
  begin
    nItem := FCtrlList[nIdx];
    if nItem.FClassID = nClassID then
      DeleteItem(nIdx, nFree);
    //xxxxx
  end;
end;

//Date: 2008-8-6
//Parm: 标识;是否释放;指定索引;实例
//Desc: 释放nClassID中第nIndex个实例
procedure TControlManager.FreeCtrl(const nClassID: integer;
  const nFree: Boolean; nIndex: integer; nInstance: Pointer);
var nIdx: Integer;
    nItem: PControlItem;
begin
  nItem := GetCtrl(nClassID);
  if not (Assigned(nItem) and Assigned(nItem.FInstance)) then Exit;

  if (nIndex < 0) and Assigned(nInstance) then
    nIndex := nItem.FInstance.IndexOf(nInstance);
  //object index

  if nIndex < 0 then
  begin
    nIndex := 0;
    nIdx := nItem.FInstance.Count - 1;
  end else
  begin
    if nIndex >= nItem.FInstance.Count then
      Exit;
    nIdx := nIndex;
  end;

  while nIdx >= nIndex do
  begin
    if nFree then
      TWinControl(nItem.FInstance[nIdx]).Free;
    nItem.FInstance[nIdx] := nil;
    Dec(nIdx);
  end;
end;

//Date: 2008-9-22
//Parm: 是否释放
//Desc: 释放当前注册的所有类的实例
procedure TControlManager.FreeAllCtrl(const nFree: Boolean);
var nNext: Boolean;
    i,nIdx: integer;
    nItem: PControlItem;
begin
  for nIdx:=FCtrlList.Count - 1 downto 0 do
  begin
    nItem := FCtrlList[nIdx];
    if Assigned(nItem.FInstance) then
    begin
      for i:=nItem.FInstance.Count - 1 downto 0 do
      begin
        if not Assigned(nItem.FInstance[i]) then Continue;
        //filter

        nNext := True;
        if Assigned(FOnCtrlFree) then
          FOnCtrlFree(nItem.FClassID, nItem.FInstance[i], nNext);
        if not nNext then Continue;

        if nFree then
          TWinControl(nItem.FInstance[i]).Free;
        nItem.FInstance[i] := nil;
      end;
    end;
  end;
end;

//Date: 2008-8-6
//Parm: 标记
//Desc: 返回标记为nClassID的控件
function TControlManager.GetCtrl(const nClassID: integer): PControlItem;
var nIdx: integer;
    nItem: PControlItem;
begin
  Result := nil;

  for nIdx:=FCtrlList.Count - 1 downto 0 do
  begin
    nItem := FCtrlList[nIdx];
    if nItem.FClassID = nClassID then
    begin
      Result := nItem;
      Break;
    end;
  end;
end;

//Date: 2013-11-28
//Parm: 分组标识
//Desc: 检索nGroupID的控件
function TControlManager.GetCtrl(const nGroupID: string): PControlItem;
var nIdx: integer;
    nItem: PControlItem;
begin
  Result := nil;

  for nIdx:=FCtrlList.Count - 1 downto 0 do
  begin
    nItem := FCtrlList[nIdx];
    if nItem.FGroupID = nGroupID then
    begin
      Result := nItem;
      Break;
    end;
  end;
end;

//Date: 2008-8-6
//Parm: 列表
//Desc: 枚举当前注册的所有控件,放入nList中
function TControlManager.GetCtrls(const nList: TList): Boolean;
var nIdx: integer;
begin
  nList.Clear;
  for nIdx:=0 to FCtrlList.Count-1 do
    nList.Add(FCtrlList[nIdx]);
  Result := nList.Count > 0;
end;
            
//Date: 2008-8-6
//Parm: 标识;索引
//Desc: 检索标识为nClassID类型的第nIndex个实例
function TControlManager.GetInstance(const nClassID, nIndex: integer): TWinControl;
var nItem: PControlItem;
begin
  Result := nil;
  nItem := GetCtrl(nClassID);

  if Assigned(nItem) and Assigned(nItem.FInstance) and
     (nIndex >= 0) and (nIndex < nItem.FInstance.Count) then
  begin
    Result := TWinControl(nItem.FInstance[nIndex]);
  end;
end;

//Date: 2008-8-6
//Parm: 标识;列表
//Desc: 获取标识为nClassID类型的所有实例,存入nList中
function TControlManager.GetInstances(const nClassID: integer;
  const nList: TList): Boolean;
var nIdx: integer;
    nItem: PControlItem;
begin
  nList.Clear;
  nItem := GetCtrl(nClassID);

  if Assigned(nItem) and Assigned(nItem.FInstance) then
  begin
    for nIdx:=0 to nItem.FInstance.Count - 1 do
     if Assigned(nItem.FInstance[nIdx]) then
      nList.Add(nItem.FInstance[nIdx]);
    //xxxxx
  end;

  Result := nList.Count > 0;
end;

//Date: 2008-8-6
//Parm: 列表
//Desc: 检索当前已注册的所有类的所有实例
function TControlManager.GetAllInstance(const nList: TList): Boolean;
var i,nIdx: integer;
    nItem: PControlItem;
begin
  nList.Clear;
  for nIdx:=0 to FCtrlList.Count-1 do
  begin
    nItem := FCtrlList[nIdx];
    if Assigned(nItem.FInstance) then
    begin
      for i:=0 to nItem.FInstance.Count-1 do
       if Assigned(nItem.FInstance[i]) then
        nList.Add(nItem.FInstance[i]);
      //xxxxx
    end;
  end;

  Result := nList.Count > 0;
end;

//Date: 2008-8-6
//Parm: 标识
//Desc: 标识为nClassID的类是否有实例
function TControlManager.IsInstanceExists(const nClassID: integer): Boolean;
begin
  Result := Assigned(GetInstance(nClassID));
end;

//Date: 2008-8-6
//Parm: 标识; 拥有者;实例索引
//Desc: 创建一个nClassID类的实例,返回索引nIndex
function TControlManager.NewCtrl(const nClassID: integer; const nOwner: TComponent;
 var nIndex: integer; const nOnCreate: TOnCtrlCreate): TWinControl;
var i,nCount: integer;
    nItem: PControlItem;
begin
  nIndex := -1;
  Result := nil;

  nItem := GetCtrl(nClassID);
  if not Assigned(nItem) then Exit;

  if Assigned(nOnCreate) then
       Result := nOnCreate(nItem.FClass, nOwner)
  else Result := nItem.FClass.Create(nOwner);
  
  if Assigned(nItem.FInstance) then
  begin
    nCount := nItem.FInstance.Count - 1;
    for i:=0 to nCount do
    if not Assigned(nItem.FInstance[i]) then
    begin
      nItem.FInstance[i] := Result;
      nIndex := i; Exit;
    end;

    nIndex := nItem.FInstance.Add(Result);
  end else
  begin
    nItem.FInstance := TList.Create;
    nIndex := nItem.FInstance.Add(Result);
  end;
end;

//Date: 2008-9-20
//Parm: 标识;拥有者;排列方式
//Desc: 创建nClasID的唯一实例.若nOwner是容器,则放置到nOwer上
function TControlManager.NewCtrl2(const nClassID: integer; 
 const nOwner: TComponent; const nAlign: TAlign): TWinControl;
var nIdx: integer;
begin
  Result := GetInstance(nClassID);
  if not Assigned(Result) then
  begin
    Result := NewCtrl(nClassID, nOwner, nIdx);
    if Assigned(Result) and (nOwner is TWinControl) then
    begin
      Result.Parent := TWinControl(nOwner);
      Result.Align := nAlign;
    end;
  end;
end;

//Date: 2013-11-26
//Parm: 标识;拥有者;创建函数
//Desc: 使用nOnCreate创建nClassID实例
function TControlManager.NewCtrl3(const nClassID: integer;
  const nOwner: TComponent; const nOnCreate: TOnCtrlCreate): TWinControl;
var nIdx: integer;
begin
  Result := GetInstance(nClassID);
  if not Assigned(Result) then
    Result := NewCtrl(nClassID, nOwner, nIdx, nOnCreate);
  //xxxxx
end;

//Date: 2013-11-24
//Parm: 管理器实例
//Desc: 将当前已注册的控件列表转移到nManager中
procedure TControlManager.MoveTo(const nManager: TControlManager);
var nIdx: Integer;
begin
  for nIdx:=0 to FCtrlList.Count - 1 do
    nManager.FCtrlList.Add(FCtrlList[nIdx]);
  FCtrlList.Clear;
end;

initialization
  gControlManager := TControlManager.Create;
finalization
  FreeAndNil(gControlManager);
end.
