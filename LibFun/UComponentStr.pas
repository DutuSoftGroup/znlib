{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-08-04
  ����: ʵ��������ַ������໥ת��

  ��ע:
  &.NewControlByType
    �ú�����������������һ���ؼ�,��������ʾ�ڸ�������.�ؼ���������nValue�ַ���
  ָ��.��Ҫע�����,nName����������nOwner�������Ƿ��������Ѵ��ڵĿؼ�,���޷���
  ��ͬһ���������Ƿ��и����ƵĿؼ�.����nOwner=Application,nParent=Form1,���ܻ�
  ��Form1��������������ΪnName�����:һ�������ʱ��ӵ�,Owner=Form1;һ��ʱ��̬
  ������,Owner=Application.
  &.��̬�����������Ҫ�ڱ���ʱע����𵽹�����,ʹ��ManagerRegisterClass����,
  �ú����м������,���Ա����ظ�ע��ͬһ�����.
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
  //�滻��־

var
  gRegClass: array of TComponentClass;
  //��ע������б�

//Desc: ת��nIns���ʵ��Ϊ�ַ���
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

//Desc: ��nValue�����������ϵ�nIns���ʵ����
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
//Parm: �����б�;���
//Desc: ��nValue���Ա����¼����ӿؼ�����Ϣ
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
//Parm: ���
//Desc: ��ȡnIns�������ַ���,���˵��¼����ӿؼ�
function ComponentProperty(const nIns: TComponent): string;
begin
  Result := FilterPropery(ComponentToStr(nIns), nIns);
end;

//Date: 2007-08-04
//Parm: ����;����;ӵ����;�����
//Desc: ����nType������,����nValue���Ը�����
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
//Parm: ��
//Desc: ��nClassע�ᵽϵͳ������,���ע�᷵����
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

//Desc: ж����ע����
procedure ManagerUnRegisterClass;
var i,nLen: integer;
begin
  nLen := High(gRegClass);
  for i:=Low(gRegClass) to nLen do
    UnRegisterClass(gRegClass[i]);
  SetLength(gRegClass, 0);
end;

end.