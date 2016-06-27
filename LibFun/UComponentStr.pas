{*******************************************************************************
  作者: dmzn@ylsoft.com 2007-08-04
  描述: 实现组件与字符串的相互转换

  备注:
  &.NewControlByType
    该函数会依据类名生成一个控件,并将它显示在父容器上.控件的属性由nValue字符串
  指定.需要注意的是,nName参数用于在nOwner中搜索是否有名称已存在的控件,但无法保
  正同一个窗体中是否有该名称的控件.假若nOwner=Application,nParent=Form1,可能会
  在Form1上生成两个名称为nName的组件:一个是设计时添加的,Owner=Form1;一个时动态
  创建的,Owner=Application.
  &.动态创建的组件需要在编译时注册类别到管理器,使用ManagerRegisterClass函数,
  该函数有检测能力,可以避免重复注册同一种类别.
*******************************************************************************}
unit UComponentStr;

interface

uses
  Windows, Classes, Controls, SysUtils, TypInfo;

function ComponentToStr(const nIns: TComponent): string;
//com -> Str
function StrToComponent(const nValue: string; nIns: TComponent): TComponent;
//Str -> com

function FilterPropery(const nValue: string; nIns: TComponent): string;
//delete event and child property
function ComponentProperty(const nIns: TComponent): string;
//com property widthout event and child

function NewComponentByType(const nType,nName,nValue: string;
 const nOwner: TComponent; const nParent: TWinControl): TComponent;
//new component

function ManagerRegisterClass(const nClass: TComponentClass): Boolean;
//register class
procedure ManagerUnRegisterClass;
//unregister class

implementation

const
  cReplaceFlag = '*|*';
  //替换标志

var
  gRegClass: array of TComponentClass;
  //已注册的类列表

//Desc: 转换nIns组件实例为字符串
function ComponentToStr(const nIns: TComponent): string;
var nTmp: string;
    nStr: TStringStream;
    nBin: TMemoryStream;
begin
  nBin := TMemoryStream.Create;
  nStr := TStringStream.Create(nTmp);
  try
    nBin.WriteComponent(nIns);
    nBin.Seek(0, soFromBeginning);
    ObjectBinaryToText(nBin, nStr);

    nStr.Seek(0, soFromBeginning);
    Result := StringReplace(nStr.DataString, #39, cReplaceFlag, [rfReplaceAll]);
  finally
    nBin.Free;
    nStr.Free;
  end;
end;

//Desc: 将nValue属性内容整合到nIns组件实例上
function StrToComponent(const nValue: string; nIns: TComponent): TComponent;
var nTmp: string;
    nStr: TStringStream;
    nBin: TMemoryStream;
begin
  nTmp := StringReplace(nValue, cReplaceFlag, #39, [rfReplaceAll]);
  nStr := TStringStream.Create(nTmp);
  nBin := TMemoryStream.Create;
  try
    ObjectTextToBinary(nStr, nBin);
    nBin.Seek(0, soFromBeginning);
    Result := nBin.ReadComponent(nIns);
  finally
    nBin.Free;
    nStr.Free;
  end;
end;

//Date: 2007-08-06
//Parm: 属性列表;组件
//Desc: 从nValue属性表中事件和子控件的信息
function FilterPropery(const nValue: string; nIns: TComponent): string;
var nStr: string;
    nIdx: integer;
    nList: TStrings;
    nChild: Boolean;
begin
  nList := TStringList.Create;
  try
    nList.Text := nValue;
    nIdx := 1;
    nChild := False;

    while nIdx < (nList.Count - 1) do
    begin
      if nChild then
      begin
        nList.Delete(nIdx); Continue;
      end;

      nStr := LowerCase(Trim(nList[nIdx]));
      if Pos('object ', nStr) = 1 then
      begin
        nChild := True; Continue;
      end;

      if Pos('on', nStr) = 1 then
      begin
        nStr := Copy(nStr, 1, Pos('=', nStr) - 1);
        nStr := TrimRight(nStr);

        if IsPublishedProp(nIns, nStr) and (PropType(nIns, nStr) = tkMethod) then
             nList.Delete(nIdx)
        else Inc(nIdx);
      end else Inc(nIdx);
    end;

    Result := nList.Text;
  finally
    nList.Free;
  end;
end;

//Date: 2007-08-07
//Parm: 组件
//Desc: 获取nIns的属性字符串,过滤掉事件和子控件
function ComponentProperty(const nIns: TComponent): string;
begin
  Result := FilterPropery(ComponentToStr(nIns), nIns);
end;

//Date: 2007-08-04
//Parm: 类名;属性;拥有者;父组件
//Desc: 生成nType类的组件,并将nValue属性赋予它
function NewComponentByType(const nType,nName,nValue: string;
 const nOwner: TComponent; const nParent: TWinControl): TComponent;
var nClass: TPersistentClass;
begin
  Result := nil;     
  nClass := GetClass(nType);

  if Assigned(nClass) and (nOwner.FindComponent(nName) = nil) then
  begin
    Result := TComponentClass(nClass).Create(nOwner);
    if Result is TControl then
      TControl(Result).Parent := nParent;
    if nValue <> '' then
      StrToComponent(nValue, Result);
    Result.Name := nName;
  end;
end;

//Date: 2007-08-04
//Parm: 类
//Desc: 将nClass注册到系统环境中,完成注册返回真
function ManagerRegisterClass(const nClass: TComponentClass): Boolean;
var i,nLen: integer;
begin
  Result := False;
  nLen := High(gRegClass);
  for i:=Low(gRegClass) to nLen do
   if gRegClass[i] = nClass then Exit;

  nLen := Length(gRegClass);
  SetLength(gRegClass, nLen + 1);
  gRegClass[nLen] := nClass;

  RegisterClass(nClass);
  Result := True;
end;

//Desc: 卸载已注册类
procedure ManagerUnRegisterClass;
var i,nLen: integer;
begin
  nLen := High(gRegClass);
  for i:=Low(gRegClass) to nLen do
    UnRegisterClass(gRegClass[i]);
  SetLength(gRegClass, 0);
end;

end.