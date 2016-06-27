{*******************************************************************************
  作者: dmzn@163.com 2011-04-16
  描述: 事件管理器对象,动态方法绑定管理.

  备注:
  *.实现动态方法绑定的类为TDynamicMethodManager.
  *.TDynamicMethodManager用于动态绑定对象TMethod指针(方法),并维护原有指针.
  *.源方法失效时,必须手动解除绑定,避免目标对象调用时异常.
*******************************************************************************}
unit UMgrEvent;

interface

uses
  Windows, Classes, Controls, Forms, SysUtils, TypInfo, UAdjustForm;

type
  TDynamicMethodManager = class(TObject)
  private
    FMethods: TList;
    {*事件列表*}
  protected
    procedure ReleaseItem(const nIdx: Integer);
    procedure ClearMethods(const nFree: Boolean);
    {*清理资源*}
    function FindTarget(const nTarget: TObject; const nMethod: string): Integer;
    {*检索对象*}
  public
    constructor Create;
    destructor Destroy; override;
    {*创建释放*}
    function BindMethod(const nSource: TObject; const nSMethod: string;
      const nTarget: TObject; const nTMethod: string;
      const nSubAll: Boolean = True): Boolean;
    {*添加绑定*}
    procedure UnBindMethod(const nSource: TObject; const nSMethod: string = '');
    {*解除绑定*}
    procedure ClearAll;
    {*清理全部*}
  end;

implementation

type
  PMethodItem = ^TMethodItem;
  TMethodItem = record
    FSource: TObject;        //源对象
    FSMethod: string;        //源方法名
    FTarget: TObject;        //目标对象
    FTMethodName: string;    //目标方法名
    FTLastMethod: TMethod;   //目标旧方法
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

//Desc: 清理资源
procedure TDynamicMethodManager.ClearMethods(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FMethods.Count - 1 downto 0 do
    ReleaseItem(nIdx);
  if nFree then FreeAndNil(FMethods);
end;

//Desc: 清理索引为nIdx的项
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

//Desc: 清理全部
procedure TDynamicMethodManager.ClearAll;
begin
  ClearMethods(False);
end;

//Date: 2011-4-16
//Parm: 对象;方法名
//Desc: 检索对象为nTarget,方法为nMethod的Item所在的索引.
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
//Parm: 源对象;源方法名;目标对象;目标方法名;包括子组件
//Desc: 将nSource.nSMethod绑定到nTarget.nTMethod上,并备份.
function TDynamicMethodManager.BindMethod(const nSource: TObject;
  const nSMethod: string; const nTarget: TObject; const nTMethod: string;
  const nSubAll: Boolean): Boolean;
var nSM: TMethod;
    nList: TList;
    nIdx: Integer;
    nCtrl: TObject;

    //Desc: 绑定nObj对象
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

//Desc: 解除绑定
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
