{*******************************************************************************
  ����: dmzn@163.com 2008-08-06
  ����: ͳһ����ؼ�(TWinControl)�Ĵ�������

  ��ע:
  &.����GetCtrls��ȡ��ע�������Ϣ,�б���ÿһ����PControlItem
  &.����GetInstances,GetAllInstance��ȡʵ��,ÿһ����TWinControl����
*******************************************************************************}
unit UMgrControl;

interface

uses
  Windows, Classes, SysUtils, Controls;

type
  PControlItem = ^TControlItem;
  TControlItem = record
    FClass: TWinControlClass;       //���
    FClassID: integer;              //��ʶ
    FGroupID: string;               //����
    FInstance: TList;               //ʵ��
  end;

  TOnCtrlCreate = function (AClass:TWinControlClass; AOwner: TComponent): TWinControl;
  //����ʵ��
  TOnCtrlFree = procedure (const nClassID: integer; const nCtrl: TWinControl;
    var nNext: Boolean) of Object;
  //ʵ���ͷ�

  TControlManager = class(TObject)
  private
    FCtrlList: TList;
    {*�ؼ��б�*}
    FOnCtrlFree: TOnCtrlFree;
    {*�ͷ��¼�*}
  protected
    procedure ClearCtrlList(const nFree: Boolean);
    {*�����б�*}
    procedure DeleteItem(const nIdx: Integer; const nFreeInst: Boolean);
    {*ɾ����*}
  public
    constructor Create;
    destructor Destroy; override;
    {*�����ͷ�*}
    procedure RegCtrl(const nClass: TWinControlClass; const nClassID: integer;
     const nGroupID: string = '');
    procedure UnregCtrl(const nGroupID: string; const nFree: Boolean); overload;
    procedure UnregCtrl(const nClassID: Integer; const nFree: Boolean); overload;
    {*ע��ؼ�*}
    function NewCtrl(const nClassID: integer; const nOwner: TComponent;
      var nIndex: integer; const nOnCreate: TOnCtrlCreate = nil): TWinControl;
    function NewCtrl2(const nClassID: integer; const nOwner: TComponent;
      const nAlign: TAlign = alClient): TWinControl;
    function NewCtrl3(const nClassID: integer; const nOwner: TComponent;
      const nOnCreate: TOnCtrlCreate = nil): TWinControl;
    {*�����ؼ�*}
    procedure FreeCtrl(const nClassID: integer; const nFree: Boolean = True;
     nIndex: integer = -1; nInstance: Pointer = nil);
    procedure FreeAllCtrl(const nFree: Boolean = True);
    {*�ͷſؼ�*}
    function GetCtrl(const nGroupID: string): PControlItem; overload;
    function GetCtrl(const nClassID: integer): PControlItem; overload;
    function GetCtrls(const nList: TList): Boolean;
    {*�����ؼ�*}
    function GetInstances(const nClassID: integer; const nList: TList): Boolean;
    function GetInstance(const nClassID: integer; const nIndex: integer = 0): TWinControl;
    function GetAllInstance(const nList: TList): Boolean;
    {*����ʵ��*}
    function IsInstanceExists(const nClassID: integer): Boolean;
    {*ʵ������*}
    procedure MoveTo(const nManager: TControlManager);
    {*ת������*}
    property OnCtrlFree: TOnCtrlFree read FOnCtrlFree write FOnCtrlFree;
    {*����*}
  end;

var
  gControlManager: TControlManager = nil;
  //ȫ��ʹ��

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
//Parm: ����;�ͷ�ʵ��
//Desc: ɾ���ؼ��б�������ΪnIdx����
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

//Desc: ��տؼ��б�
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
//Parm: ����;��ʶ;����
//Desc: ע��һ����ʶΪnClassID����
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
//Parm: �����ʶ
//Desc: ж�ط����ʶΪnGroupID�Ŀؼ�
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
//Parm: ���ʶ
//Desc: ж�����ʶΪnClassID�Ŀؼ�
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
//Parm: ��ʶ;�Ƿ��ͷ�;ָ������;ʵ��
//Desc: �ͷ�nClassID�е�nIndex��ʵ��
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
//Parm: �Ƿ��ͷ�
//Desc: �ͷŵ�ǰע����������ʵ��
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
//Parm: ���
//Desc: ���ر��ΪnClassID�Ŀؼ�
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
//Parm: �����ʶ
//Desc: ����nGroupID�Ŀؼ�
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
//Parm: �б�
//Desc: ö�ٵ�ǰע������пؼ�,����nList��
function TControlManager.GetCtrls(const nList: TList): Boolean;
var nIdx: integer;
begin
  nList.Clear;
  for nIdx:=0 to FCtrlList.Count-1 do
    nList.Add(FCtrlList[nIdx]);
  Result := nList.Count > 0;
end;
            
//Date: 2008-8-6
//Parm: ��ʶ;����
//Desc: ������ʶΪnClassID���͵ĵ�nIndex��ʵ��
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
//Parm: ��ʶ;�б�
//Desc: ��ȡ��ʶΪnClassID���͵�����ʵ��,����nList��
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
//Parm: �б�
//Desc: ������ǰ��ע��������������ʵ��
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
//Parm: ��ʶ
//Desc: ��ʶΪnClassID�����Ƿ���ʵ��
function TControlManager.IsInstanceExists(const nClassID: integer): Boolean;
begin
  Result := Assigned(GetInstance(nClassID));
end;

//Date: 2008-8-6
//Parm: ��ʶ; ӵ����;ʵ������
//Desc: ����һ��nClassID���ʵ��,��������nIndex
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
//Parm: ��ʶ;ӵ����;���з�ʽ
//Desc: ����nClasID��Ψһʵ��.��nOwner������,����õ�nOwer��
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
//Parm: ��ʶ;ӵ����;��������
//Desc: ʹ��nOnCreate����nClassIDʵ��
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
//Parm: ������ʵ��
//Desc: ����ǰ��ע��Ŀؼ��б�ת�Ƶ�nManager��
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
