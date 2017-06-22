{*******************************************************************************
  ����: dmzn@163.com 2017-03-27
  ����: ͳһ������ֹ�������ȫ�ֱ���
*******************************************************************************}
unit UManagerGroup;

interface

uses
  System.Rtti, System.SysUtils, UBaseObject, UObjectPool, UMemDataPool, 
  ULibFun;

type
  PManagerGroup = ^TManagerGroup;
  TManagerGroup = record
  public
    const 
      sAllManager = 'ALLManager';
      {*��������*}
  public
    FSerialIDManager: TSerialIDManager;
    //��Ź�����
    FObjectManager: TCommonObjectManager;
    //���������
    FObjectPool: TObjectPoolManager;
    //���󻺳��
    FMemDataManager: TMemDataManager;
    //�ڴ������
  public
    procedure RegistAll(const nReg: Boolean);
    //ע������
    procedure CheckSupport(const nCallClass,nManagerName: string;
      const nManager: TObject); overload;
    procedure CheckSupport(const nCallClass: string;
      const nManagers: TStringHelper.TStringArray); overload;    
    //��֤����������Ƿ�����
  end;

var
  gMG: TManagerGroup;
  //ȫ��ʹ��
  
implementation

//Date: 2017-03-27
//Parm: �Ƿ�ע��
//Desc: ɨ��Group������Manager,����Manager��ע�᷽��.
procedure TManagerGroup.RegistAll(const nReg: Boolean);
var nCtx: TRttiContext;
    nType: TRttiType;
    nRF: TRttiField;
    nMethod: TRttiMethod;
    nInstance: TRttiInstanceType;
begin    
  nCtx := TRttiContext.Create;
  try
    nType := nCtx.GetType(TypeInfo(TManagerGroup));
    for nRF in nType.GetFields do
     if nRF.FieldType.TypeKind = tkClass then   
      begin
        nInstance := nRF.FieldType.AsInstance; 
        nMethod := nInstance.GetMethod('RegistMe');
        
        if Assigned(nMethod) then
          nMethod.Invoke(nInstance.MetaclassType, [TValue.From(nReg)]);
        //call function
      end;    
  finally
    nCtx.Free;
  end;
end;

//Date: 2017-04-18
//Parm: ������;������;����������
//Desc: ��nCallClass��ҪnManager֧��,��nManagerΪnil,�׳��쳣.
procedure TManagerGroup.CheckSupport(const nCallClass,nManagerName: string;
  const nManager: TObject);
var nStr: string;
begin
  if not Assigned(nManager) then
  begin
    nStr := '%s Needs TManagerGroup.%s(nil) Support.';
    raise Exception.Create(Format(nStr, [nCallClass, nManagerName]));
  end;
end;

//Date: 2017-04-17
//Parm: ������;���������������
//Desc: ���nCallClsss�����nManagers�Ƿ����
procedure TManagerGroup.CheckSupport(const nCallClass: string;
  const nManagers: TStringHelper.TStringArray);
var nStr,nBase: string;
    nBool: Boolean;
    nCtx: TRttiContext;
    nType: TRttiType;
    nRF: TRttiField;    
begin
  nCtx := TRttiContext.Create;
  try
    nType := nCtx.GetType(TypeInfo(TManagerGroup));
    for nBase in nManagers do
    begin
      nBool := False;
      //init flag
      
      for nRF in nType.GetFields do
      begin
        nBool := (nBase = nRF.Name) or (nBase = sAllManager);
        if not nBool then Continue;
        
        if nRF.FieldType.TypeKind = tkClass then
        begin
          CheckSupport(nCallClass, nRF.Name, nRF.GetValue(@gMG).AsObject);
          if nBase <> sAllManager then           
            Break; 
          //match done  
        end else

        if nBase <> sAllManager then        
        begin
          nStr := '%s: Manager "%s" Is Not Valid Class.';
          raise Exception.Create(Format(nStr, [nCallClass, nBase]));
        end;  
      end;

      if not nBool then
      begin
        nStr := '%s: Manager "%s" Is Not Exists.';
        raise Exception.Create(Format(nStr, [nCallClass, nBase]));
      end; //not exits
    end;
  finally
    nCtx.Free;
  end;    
end;

initialization
  FillChar(gMG, SizeOf(TManagerGroup), #0);
  gMG.RegistAll(True);
finalization
  gMG.RegistAll(False);
end.
