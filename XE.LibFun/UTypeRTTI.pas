{*******************************************************************************
  ����: dmzn@163.com 2017-02-20
  ����: ʹ������ʱ���л���Ͷ���

  ��ע:
  *.ֱ����Record�ж������������û��RTTI��Ϣ�ᵼ�����л�ʧ��,��Ҫ�ȶ���
    ά�Ⱥ���������.����:
    TDimension = 0..5;
    TDimArray = array [TDimension] of Byte;
*******************************************************************************}
unit UTypeRTTI;

{$I LibFun.inc}
interface

uses
  System.Classes, System.Rtti, System.SysUtils, System.TypInfo, ULibFun,
  UManagerGroup;

type
  TRecordSerializer<T> = class
  public
    const 
      sSerializerNoSuport = 'Znlib.NotSupportType';      
      sSerializerVersionK = 'Znlib.Serializer.Version';
      sSerializerVersionV = '0.0.1';
      sSerializerAuthorK  = 'Znlib.Serializer.Author';
      sSerializerAuthorV  = 'dmzn@163.com';
      sSerializerEncodeK  = 'Znlib.Serializer.Encode';
      sSerializerEncodeY  = 'Y';
      sSerializerEncodeN  = 'N';      
      {*��������*}

    type
      PPByte = ^PByte;
      {*���Ͷ���*}
  private
    class function MakeKey(const nPrefix,nField: string): string;
    class procedure MakeData(const nPrefix,nField,nVal: string;
      const nList: TStrings);
    class function MakePrefix(const nFirst,nNext: string): string;
    //��ʽ������
    class procedure EncodeField(const nCtx: TRttiContext;  
      const nFName: string; const nFValue: TValue;
      const nList: TStrings; const nPrefix: string;
      const nCode: Boolean);
    class procedure EncodeFields(const nCtx: TRttiContext; 
      const nFValue: TValue; const nList: TStrings; const nPrefix: string;
      const nCode: Boolean);
    //���л�Field
  public
    class function Encode(const nRecord: T;
      const nCode: Boolean = True): string; static;
    //���л�Record
    class procedure Decode(const nRecord: T; const nData: string); static;
    //�����л�Record
    class function MakeTypeValue(const nAddr,nType: Pointer): TValue; static;
    //����TValue  
  end;

implementation

//Date: 2017-03-15
//Parm: һ��;���� 
//Desc: ����nFirst.nNext�ṹ�Ķ༶ǰ׺
class function TRecordSerializer<T>.MakePrefix(const nFirst,
  nNext: string): string;
begin
  if nFirst = '' then
       Result := nNext
  else Result := nFirst + '.' + nNext;
end;

//Date: 2017-04-19
//Parm: ǰ׺,�ֶ� 
//Desc: ����nPrefix.nField��ʶ
class function TRecordSerializer<T>.MakeKey(const nPrefix,
  nField: string): string;
begin
  if nPrefix = '' then
       Result := nField
  else Result := nPrefix + '.' + nField;
end;

//Date: 2017-03-15
//Parm: ǰ׺,�ֶ�,ֵ;�Ƿ�ָ� 
//Desc: ����nPrefix.nField=nVal������
class procedure TRecordSerializer<T>.MakeData(const nPrefix,nField,nVal: string; 
  const nList: TStrings);
begin
  if nVal <> '' then
    nList.Add(MakeKey(nPrefix, nField) + '=' + nVal);
  //xxxxx
end;

//Date: 2017-03-22
//Parm: ��ַ;PTypeInfo
//Desc: ����TValue��¼�ṹ 
class function TRecordSerializer<T>.MakeTypeValue(const nAddr,
  nType: Pointer): TValue;
begin
  TValue.Make(nAddr, nType, Result);
end;

//------------------------------------------------------------------------------
//Date: 2017-03-15
//Parm: ������;�ֶ���,ֵ;�б�;ǰ׺
//Desc: ��ȡnFName.nFValue��ֵ,����nList��
class procedure TRecordSerializer<T>.EncodeField(const nCtx: TRttiContext;
  const nFName: string; const nFValue: TValue;
  const nList: TStrings; const nPrefix: string; const nCode: Boolean);
var nIdx: Integer;
    nRF: TRTTIField;
    nArray: TRTTIArrayType;
    nDynAry: TRTTIDynamicArrayType; 
begin    
  case nFValue.Kind of   
    tkInt64:
    begin
      MakeData(nPrefix, nFName, IntToStr(nFValue.AsInt64), nList);
      //int64
    end;
    tkInteger:
    begin
      MakeData(nPrefix, nFName, IntToStr(nFValue.AsInteger), nList);
      //integer
    end;
      
    tkFloat:
    with TDateTimeHelper do
    begin
      if nFValue.TypeInfo = TypeInfo(TDate) then
      begin
        MakeData(nPrefix, nFName, Date2Str(nFValue.AsExtended), nList);
        //date
      end else
        
      if nFValue.TypeInfo = TypeInfo(TTime) then
      begin
        MakeData(nPrefix, nFName, Time2Str(nFValue.AsExtended), nList);
        //time
      end else

      if nFValue.TypeInfo = TypeInfo(TDateTime) then
      begin
        MakeData(nPrefix, nFName, DateTime2Str(nFValue.AsExtended), nList);
        //datetime
      end else         
      begin
        MakeData(nPrefix, nFName, FloatToStr(nFValue.AsExtended), nList);
        //float
      end;
    end;  
         
    tkArray: 
    begin
      nArray := nCtx.GetType(nFValue.TypeInfo) as TRTTIArrayType; 
      //get field type
  
      for nIdx := 0 to nArray.TotalElementCount - 1 do
      begin
        EncodeField(nCtx, MakePrefix(nFName, IntToStr(nIdx)), MakeTypeValue(
          PByte(nFValue.GetReferenceToRawData) +
          nArray.ElementType.TypeSize * nIdx, nArray.ElementType.Handle), 
          nList, nPrefix, nCode);
        //encode element
      end;
    end;

    tkDynArray:
    begin
      nDynAry := nCtx.GetType(nFValue.TypeInfo) as TRTTIDynamicArrayType;
      //get field type

      for nIdx := 0 to nFValue.GetArrayLength - 1 do
      begin
        EncodeField(nCtx, MakePrefix(nFName, IntToStr(nIdx)), MakeTypeValue(
          PPByte(nFValue.GetReferenceToRawData)^ + 
          nDynAry.ElementType.TypeSize * nIdx, nDynAry.ElementType.Handle),
          nList, nPrefix, nCode);
        //encode elment
      end;
    end;
    
    tkSet: 
    begin
      MakeData(nPrefix, nFName, nFValue.ToString, nList);
      //set
    end;
    tkEnumeration:
    begin
      if nFValue.TypeInfo = TypeInfo(Boolean) then
      begin
        MakeData(nPrefix, nFName, BoolToStr(nFValue.AsBoolean, True), nList);
      end else
      begin
        MakeData(nPrefix, nFName, nFValue.ToString, nList);
      end; //enumeration
    end;
    tkRecord:
    begin   
      EncodeFields(nCtx, nFValue, nList, MakePrefix(nPrefix, nFName), nCode);
      //record
    end;
            
    tkChar,
    tkWChar,
    tkString,
    tkLString,
    tkWString,
    tkUString:
    begin
      if nCode then      
           MakeData(nPrefix, nFName,
                    TEncodeHelper.EncodeBase64(nFValue.ToString), nList)
           //string and base64
      else MakeData(nPrefix, nFName, nFValue.ToString, nList);      
    end else
    begin
      MakeData(nPrefix, nFName, sSerializerNoSuport, nList);
      //unsupport
    end;
  end;
end;

class procedure TRecordSerializer<T>.EncodeFields(const nCtx: TRttiContext;
  const nFValue: TValue; const nList: TStrings;
  const nPrefix: string; const nCode: Boolean);
var nRF: TRTTIField;
    nRecord: TRTTIRecordType;
begin
  nRecord := nCtx.GetType(nFValue.TypeInfo).AsRecord;
  for nRF in nRecord.GetFields do
  begin
    if nRF.FieldType = nil then
    begin
      MakeData(nPrefix, nRF.Name, sSerializerNoSuport, nList);
      Continue;
    end;
      
    if nRF.FieldType.TypeKind = tkRecord then
      Continue;
    //do later
        
    EncodeField(nCtx, nRF.Name, nRF.GetValue(nFValue.GetReferenceToRawData), 
                nList, nPrefix, nCode);
    //normal field
  end; 

  for nRF in nRecord.GetFields do
  begin
    if Assigned(nRF.FieldType) and (nRF.FieldType.TypeKind = tkRecord) then        
      EncodeField(nCtx, nRF.Name, nRF.GetValue(nFValue.GetReferenceToRawData),
                  nList, nPrefix, nCode);
    //record
  end;
end;

//Date: 2017-03-14
//Parm: ��¼ʵ��;�����ַ���
//Desc: ���л�nRecordΪ�ַ���
class function TRecordSerializer<T>.Encode(const nRecord: T;
  const nCode: Boolean): string;
var nCtx: TRttiContext;
    nType: TRttiType;
    nList: TStrings; 
begin   
  gMG.CheckSupport('TRecordSerializer', 'FObjectPool', gMG.FObjectPool);
  //check manager
   
  nList := nil;
  nCtx := TRttiContext.Create;
  try
    nType := nCtx.GetType(TypeInfo(T));
    if nType.TypeKind <> tkRecord then
      raise Exception.Create(ClassName + ' Only Support Record Type.');
    //xxxxx
        
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nList.Clear;    
    nList.Add(sSerializerVersionK + '=' + sSerializerVersionV);
    nList.Add(sSerializerAuthorK + '=' + sSerializerAuthorV);
    
    if nCode then
         nList.Add(sSerializerEncodeK + '=' + sSerializerEncodeY)
    else nList.Add(sSerializerEncodeK + '=' + sSerializerEncodeN);

    EncodeFields(nCtx, MakeTypeValue(@nRecord, nType.Handle), nList, '', nCode);      
    Result := nList.Text;
  finally
    gMG.FObjectPool.Release(nList);
    nCtx.Free;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017-03-14
//Parm: ��¼;���л�����
//Desc: ��nData��ֵ��nRecord�ṹ
class procedure TRecordSerializer<T>.Decode(const nRecord: T;
  const nData: string);
begin

end;

end.
