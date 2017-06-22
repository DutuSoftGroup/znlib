{*******************************************************************************
  作者: dmzn@163.com 2017-02-20
  描述: 使用运行时序列化类和对象

  备注:
  *.直接在Record中定义的数组由于没有RTTI信息会导致序列化失败,需要先定义
    维度和数组类型.例如:
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
      {*常量定义*}

    type
      PPByte = ^PByte;
      {*类型定义*}
  private
    class function MakeKey(const nPrefix,nField: string): string;
    class procedure MakeData(const nPrefix,nField,nVal: string;
      const nList: TStrings);
    class function MakePrefix(const nFirst,nNext: string): string;
    //格式化内容
    class procedure EncodeField(const nCtx: TRttiContext;  
      const nFName: string; const nFValue: TValue;
      const nList: TStrings; const nPrefix: string;
      const nCode: Boolean);
    class procedure EncodeFields(const nCtx: TRttiContext; 
      const nFValue: TValue; const nList: TStrings; const nPrefix: string;
      const nCode: Boolean);
    //序列化Field
  public
    class function Encode(const nRecord: T;
      const nCode: Boolean = True): string; static;
    //序列化Record
    class procedure Decode(const nRecord: T; const nData: string); static;
    //反序列化Record
    class function MakeTypeValue(const nAddr,nType: Pointer): TValue; static;
    //构建TValue  
  end;

implementation

//Date: 2017-03-15
//Parm: 一级;二级 
//Desc: 构建nFirst.nNext结构的多级前缀
class function TRecordSerializer<T>.MakePrefix(const nFirst,
  nNext: string): string;
begin
  if nFirst = '' then
       Result := nNext
  else Result := nFirst + '.' + nNext;
end;

//Date: 2017-04-19
//Parm: 前缀,字段 
//Desc: 构建nPrefix.nField标识
class function TRecordSerializer<T>.MakeKey(const nPrefix,
  nField: string): string;
begin
  if nPrefix = '' then
       Result := nField
  else Result := nPrefix + '.' + nField;
end;

//Date: 2017-03-15
//Parm: 前缀,字段,值;是否分割 
//Desc: 构建nPrefix.nField=nVal的内容
class procedure TRecordSerializer<T>.MakeData(const nPrefix,nField,nVal: string; 
  const nList: TStrings);
begin
  if nVal <> '' then
    nList.Add(MakeKey(nPrefix, nField) + '=' + nVal);
  //xxxxx
end;

//Date: 2017-03-22
//Parm: 地址;PTypeInfo
//Desc: 生成TValue记录结构 
class function TRecordSerializer<T>.MakeTypeValue(const nAddr,
  nType: Pointer): TValue;
begin
  TValue.Make(nAddr, nType, Result);
end;

//------------------------------------------------------------------------------
//Date: 2017-03-15
//Parm: 上下文;字段名,值;列表;前缀
//Desc: 读取nFName.nFValue的值,存入nList中
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
//Parm: 记录实例;编码字符串
//Desc: 序列化nRecord为字符串
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
//Parm: 记录;序列化数据
//Desc: 将nData赋值给nRecord结构
class procedure TRecordSerializer<T>.Decode(const nRecord: T;
  const nData: string);
begin

end;

end.
