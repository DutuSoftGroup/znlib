{*******************************************************************************
  ����: dmzn@163.com 2011-04-16
  ����: �¼�����������,��̬�����󶨹���.

  ��ע:
  *.ʵ�ֶ�̬�����󶨵���ΪTDynamicMethodManager.
  *.TDynamicMethodManager���ڶ�̬�󶨶���TMethodָ��(����),��ά��ԭ��ָ��.
  *.Դ����ʧЧʱ,�����ֶ������,����Ŀ��������ʱ�쳣.
*******************************************************************************}
unit UMgrEvent;

interface

uses
  Windows, Classes, Controls, Forms, SysUtils, TypInfo, UAdjustForm;

type
  TDynamicMethodManager = class(TObject)
  private
    FMethods: TList;
    {*�¼��б�*}
  protected
    procedure ReleaseItem(const nIdx: Integer);
    procedure ClearMethods(const nFree: Boolean);
    {*������Դ*}
    function FindTarget(const nTarget: TObject; const nMethod: string): Integer;
    {*��������*}
  public
    constructor Create;
    destructor Destroy; override;
    {*�����ͷ�*}
    function BindMethod(const nSource: TObject; const nSMethod: string;
      const nTarget: TObject; const nTMethod: string;
      const nSubAll: Boolean = True): Boolean;
    {*��Ӱ�*}
    procedure UnBindMethod(const nSource: TObject; const nSMethod: string = '');
    {*�����*}
    procedure ClearAll;
    {*����ȫ��*}
  end;

implementation

type
  PMethodItem = ^TMethodItem;
  TMethodItem = record
    FSource: TObject;        //Դ����
    FSMethod: string;        //Դ������
    FTarget: TObject;        //Ŀ�����
    FTMethodName: string;    //Ŀ�귽����
    FTLastMethod: TMethod;   //Ŀ��ɷ���
  end;

constructor TDynamicMethodManager.Create;
begin
  FMethods := TList.Create;
end;

destructor TDynamicMethodManager.Destroy;
begin
  ClearMethods(True);
  inherited;
end;

//Desc: ������Դ
procedure TDynamicMethodManager.ClearMethods(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FMethods.Count - 1 downto 0 do
    ReleaseItem(nIdx);
  if nFree then FreeAndNil(FMethods);
end;

//Desc: ��������ΪnIdx����
procedure TDynamicMethodManager.ReleaseItem(const nIdx: Integer);
var nAddr: Pointer;
begin
  with PMethodItem(FMethods[nIdx])^ do
  try
    nAddr := GetMethodProp(FTarget, FTMethodName).Code;
    if Assigned(nAddr) and (nAddr = FSource.MethodAddress(FSMethod)) then
      SetMethodProp(FTarget, FTMethodName, FTLastMethod);
    //restor old method
  except
    //maybe any error
  end;

  Dispose(PMethodItem(FMethods[nIdx]));
  FMethods.Delete(nIdx);
end;

//Desc: ����ȫ��
procedure TDynamicMethodManager.ClearAll;
begin
  ClearMethods(False);
end;

//Date: 2011-4-16
//Parm: ����;������
//Desc: ��������ΪnTarget,����ΪnMethod��Item���ڵ�����.
function TDynamicMethodManager.FindTarget(const nTarget: TObject;
  const nMethod: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FMethods.Count - 1 downto 0 do
   with PMethodItem(FMethods[nIdx])^ do
    if (FTarget = nTarget) and (CompareStr(FTMethodName, nMethod) = 0) then
    begin
      Result := nIdx; Break;
    end;
end;

//Date: 2011-4-16
//Parm: Դ����;Դ������;Ŀ�����;Ŀ�귽����;���������
//Desc: ��nSource.nSMethod�󶨵�nTarget.nTMethod��,������.
function TDynamicMethodManager.BindMethod(const nSource: TObject;
  const nSMethod: string; const nTarget: TObject; const nTMethod: string;
  const nSubAll: Boolean): Boolean;
var nSM: TMethod;
    nList: TList;
    nIdx: Integer;
    nCtrl: TObject;

    //Desc: ��nObj����
    procedure BindItem(const nObj: TObject);
    var nBI_Idx: Integer;
        nBI_Method:TMethod;
        nBI_Item: PMethodItem;
    begin
      nBI_Idx := FindTarget(nObj, nTMethod);
      nBI_Method := GetMethodProp(nObj, nTMethod);

      if (nBI_Idx < 0) or (nBI_Method.Code <> nSM.Code) then
      begin
        if nBI_Idx < 0 then
        begin
          New(nBI_Item);
          FMethods.Add(nBI_Item);
          FillChar(nBI_Item^, SizeOf(TMethodItem), #0);
        end else nBI_Item := FMethods[nBI_Idx];

        with nBI_Item^ do
        begin
          FSource := nSource;
          FSMethod := nSMethod;
          FTarget := nObj;

          FTMethodName := nTMethod;
          if (FTLastMethod.Code = nil) or (nBI_Method.Code <> nSM.Code) then
            FTLastMethod := nBI_Method;
          //backup old method

          if nBI_Method.Code <> nSM.Code then
            SetMethodProp(nObj, nTMethod, nSM);
          //xxxxx
        end;
      end;
    end;
begin
  nSM.Data := nSource;
  nSM.Code := nSource.MethodAddress(nSMethod);
  Result := Assigned(nSM.Data) and IsPublishedProp(nTarget, nTMethod);
  
  if not Result then Exit;
  //must have fix method property

  BindItem(nTarget);
  if not (nSubAll and (nTarget is TWinControl)) then Exit;

  nList := TList.Create;
  try
    EnumSubCtrlList(TWinControl(nTarget), nList);
    for nIdx:=nList.Count - 1 downto 0 do
    begin
      nCtrl := nList[nIdx];
      if IsPublishedProp(nCtrl, nTMethod) then BindItem(nCtrl);
    end; //bind all sub     
  finally
    nList.Free;
  end;
end;

//Desc: �����
procedure TDynamicMethodManager.UnBindMethod(const nSource: TObject;
  const nSMethod: string);
var nIdx: Integer;
begin
  for nIdx:=FMethods.Count - 1 downto 0 do
   with PMethodItem(FMethods[nIdx])^ do
    if (FSource = nSource) and
       ((nSMethod = '') or (CompareStr(FSMethod, nSMethod) = 0)) then
     ReleaseItem(nIdx);
  //xxxxx
end;

end.
