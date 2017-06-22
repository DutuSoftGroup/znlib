{*******************************************************************************
  ����: dmzn@163.com 2017-02-20
  ����: ��Ŀͨ�ú������嵥Ԫ
*******************************************************************************}
unit ULibFun;

{$I LibFun.inc}
interface

uses
  System.Classes, System.SysUtils, System.NetEncoding, System.Hash; 

type
  TStringHelper = class
  public
    const
      {$IFNDEF XE2_UP}
        cFirstIndex = 1;
      {$ELSE}
        cFirstIndex = Low(String);
      {$ENDIF}
    type
      TFillPos = (fpLeft, fpMid, fpRight);
      //���λ��:��,�м�,��
      TStringArray = array of string;
      //�ַ�����̬����
  
    class function Combine(const nList: TStrings; 
      nFlag: string = '';      
      const nFlagEnd: Boolean = True): string; overload; static;
    class function Combine(const nStrArray: array of string; 
      nFlag: string = '';      
      const nFlagEnd: Boolean = True): string; overload; static;
    class function Split(const nStr: string; const nList: TStrings; 
      const nNum: Word = 0; nFlag: string = ''; 
      const nFlagEnd: Boolean = True): Boolean; static;
    //�ϲ�,����ַ���
    class function AdjustFormat(const nItems,nSymbol: string; 
      const nAdd: Boolean; nFlag: string = ''; 
      const nFlagEnd: Boolean = True): string; overload; static;
    class function AdjustFormat(const nList: TStrings; 
      const nSymbol: string; const nAdd: Boolean;
      nFlag: string = ''; const nFlagEnd: Boolean = True;      
      const nListYet: Boolean = True): string; overload; static;
    //��ʽ���б��ַ���
    class function FixWidth(const nStr: string; 
      const nWidth: Byte; const nStyle: TFillPos = fpRight;  
      const nFixChar: Char = #32): string; static;
    //�����ַ���
    class function SplitValue(const nStr: string; 
      const nList: TStrings): Boolean; static;
    class function SplitInt(const nStr: string; 
      const nDef: Integer = 0): Integer; static;
    class function SplitFloat(const nStr: string; 
      const nDef: Double = 0): Double; static;
    //��ֳ���ֵ
    class function GetPinYin(const nCH: string): string; static;
    //��ȡnChinese��ƴ����д
    class function MirrorStr(const nStr: string): string; static;
    //����תnStr�ַ���
    class function IsNumber(const nStr: string; 
      const nFloat: Boolean = True): Boolean; static;
    //�Ƿ���ֵ
  end;

  TFloatHelper = class
  public
    type
      TFloatRelationType = (rtGreater, rtGE, rtEqual, rtLE, rtLess);
      //�����ϵ:>, >=, =, <=, <
  
    class function Float2PInt(const nValue: Double; 
      const nPrecision: Integer = 100;
      const nRound: Boolean = True): Int64; static;
    class function Float2Float(const nValue: Double; 
      const nPrecision: Integer = 100;
      const nRound: Boolean = True): Double; static;
    //������ת������
    class function FloatRelation(const nA,nB: Double; 
      const nType: TFloatRelationType;
      const nPrecision: Integer = 100): Boolean; static;
    //�����ϵ�ж�
  end;

  TEncodeHelper = class
  public
    class function EncodeBase64(const nData: string;
      const nLineBreak: Boolean = False): string; static;
    class function DecodeBase64(const nData: string): string; static;
    //base64
    class function EncodeMD5(const nData: string): string; static;
    //md5
  end;
  
  TDateTimeHelper = class
  public
    class function Str2Date(const nStr: string): TDate; static;
    //change nStr to date value
    class function Str2Time(const nStr: string): TTime; static;
    //change nStr to time value
    class function Date2Str(const nDate: TDateTime;
      const nSeparator: Boolean = True): string; static;
    //change nDate to string value
    class function Time2Str(const nTime: TDateTime;
      const nSeparator: Boolean = True): string; static;
    //change nTime to string value
    class function DateTime2Str(const nDT: TDateTime): string; static;
    //change nDT to string value
    class function Str2DateTime(const nStr: string): TDateTime; static;
    //change nStr to datetime value
    class function Date2CH(const nDate: TDate): string; static;
    //change nDate to chinese string
    class function Time2CH(const nTime: TTime): string; static;
    //change nTime to chinese string
    class function Date2Week(nPrefix: string = '';
      nDate: TDateTime = 0): string; static;
    //get the week of nDate
    class function TimeLong2CH(const nTime: Int64): string; static;
    //change time long to chinese string
  end;

implementation

//------------------------------------------------------------------------------
//Date: 2017-03-17
//Parm: �ַ�������;�ָ���; 
//Desc: ʹ��nFlag��nStrArray�ϲ�Ϊ�ַ���
class function TStringHelper.Combine(const nStrArray: array of string;
  nFlag: string; const nFlagEnd: Boolean): string;
var nIdx,nLen: integer;
begin
  if nFlag = '' then
    nFlag := ';';
  //def flag

  Result := '';
  nLen := High(nStrArray);

  for nIdx:=Low(nStrArray) to nLen do
   if (nIdx <> nLen) or nFlagEnd then
        Result := Result + nStrArray[nIdx] + nFlag
   else Result := Result + nStrArray[nIdx];
end;

//Date: 2017-03-17
//Parm: �ַ����б�;�ָ���; 
//Desc: ʹ��nFlag��nList�ϲ�Ϊ�ַ���
class function TStringHelper.Combine(const nList: TStrings; nFlag: string;
  const nFlagEnd: Boolean): string;
var nIdx,nCount: integer;
begin
  if nFlag = '' then
    nFlag := ';';
  //def flag

  Result := '';
  nCount := nList.Count - 1;

  for nIdx:=0 to nCount do
   if (nIdx <> nCount) or nFlagEnd then
        Result := Result + nList[nIdx] + nFlag
   else Result := Result + nList[nIdx];
end;

//Date: 2017-03-17
//Parm: �ַ���;����б�;�������;�ָ���
//Desc: ʹ��nFlag��nStr���,�������nList.
class function TStringHelper.Split(const nStr: string; const nList: TStrings;
  const nNum: Word; nFlag: string; const nFlagEnd: Boolean): Boolean;
var nPos,nNow,nLen: integer;
begin
  if nFlag = '' then
    nFlag := ';';
  //def flag
  
  nList.Clear;
  nlen := Length(nFlag);
  nPos := Pos(nFlag, nStr, 1);

  nNow := 1;
  while nPos > 0 do
  begin
    nList.Add(Copy(nStr, nNow, nPos - nNow));
    nNow := nPos + nLen;
    nPos := Pos(nFlag, nStr, nNow);
  end;

  nLen := Length(nStr);
  if nNow <= nLen then
    nList.Add(Copy(nStr, nNow, nLen - nNow + 1));
  //xxxxx

  if (not nFlagEnd) and (nNow = nLen + 1) then
  begin
    nLen := Length(nFlag);
    if Copy(nStr, nNow - nLen, nLen) = nFlag then
      nList.Add('');
    //if nStr not end by flag,but the end is flag,append blank
  end; 

  if nNum > 0 then
       Result := nList.Count = nNum
  else Result := nList.Count > 0;
end;

//Date: 2017-03-17
//Parm: �ַ���;�б�
//Desc: ����nStr�е���ֵ,����nList��
class function TStringHelper.SplitValue(const nStr: string;
  const nList: TStrings): Boolean;
var nVal: string;
    nIdx,nLen: integer;
begin
  nList.Clear;
  nVal := '';
  nLen := Length(nStr);

  for nIdx:=1 to nLen do
  begin
    if CharInSet(nStr[nIdx], ['0'..'9', '.', '-']) then
    begin
      nVal := nVal + nStr[nIdx];
    end else

    if nVal <> '' then
    begin
      if IsNumber(nVal, True) then
        nList.Add(nVal);
      nVal := '';
    end;
  end;

  if (nVal <> '') and IsNumber(nVal, True) then
    nList.Add(nVal);
  Result := nList.Count > 0;
end;

//Date: 2017-03-17
//Parm: �ַ���;Ĭ��ֵ
//Desc: ����nStr�е�������ֵ
class function TStringHelper.SplitInt(const nStr: string;
  const nDef: Integer): Integer;
var nVal: string;
    nIdx,nLen: integer;
begin
  Result := nDef;
  nVal := '';
  nLen := Length(nStr);

  for nIdx:=1 to nLen do
  begin
    if CharInSet(nStr[nIdx], ['0'..'9', '.', '-']) then
    begin
      nVal := nVal + nStr[nIdx];
    end else

    if nVal <> '' then    
    begin
      if IsNumber(nVal, False) then 
        Break;
      nVal := '';
    end;
  end;

  if IsNumber(nVal, False) then
    Result := StrToInt(nVal);
  //xxxxx
end;

//Date: 2017-03-17
//Parm: �ַ���;Ĭ��ֵ
//Desc: ����nStr�еĸ�����ֵ
class function TStringHelper.SplitFloat(const nStr: string;
  const nDef: Double): Double;
var nVal: string;
    nIdx,nLen: integer;
begin
  Result := nDef;
  nVal := '';
  nLen := Length(nStr);

  for nIdx:=1 to nLen do
  begin
    if CharInSet(nStr[nIdx], ['0'..'9', '.', '-']) then
    begin
      nVal := nVal + nStr[nIdx];
    end else

    if nVal <> '' then    
    begin
      if IsNumber(nVal, True) then 
        Break;
      nVal := '';
    end;
  end;

  if IsNumber(nVal, True) then
    Result := StrToFloat(nVal);
  //xxxxx
end;

//Date: 2014-09-17
//Parm: ����;����;�Ƿ����;�ָ���
//Desc: ��nList��������ǰ��,��ӻ�ɾ��nSymbol����
class function TStringHelper.AdjustFormat(const nItems, nSymbol: string;
  const nAdd: Boolean; nFlag: string; const nFlagEnd: Boolean): string;
var nList: TStrings;
begin
  nList := TStringList.Create;
  try
    if nFlag = '' then nFlag := ';';
    Split(nItems, nList, 0, nFlag, nFlagEnd);
    Result := AdjustFormat(nList, nSymbol, nAdd, nFlag, False);
  finally
    nList.Free;
  end;
end;

//Date: 2014-09-17
//Parm: ����;����;�Ƿ����;�ָ���
//Desc: ��nList��������ǰ��,��ӻ�ɾ��nSymbol����
class function TStringHelper.AdjustFormat(const nList: TStrings;
  const nSymbol: string; const nAdd: Boolean; nFlag: string; const nFlagEnd,
  nListYet: Boolean): string;
var nStr,nBak: string;
    nIdx,nLen,nSLen: Integer;
begin
  if nFlag = '' then
     nFlag := ';';
  nSLen := Length(nSymbol);

  if nAdd and (not nListYet) then
    nBak := nList.Text;
  //��������

  for nIdx:=0 to nList.Count - 1 do
  begin
    nStr := nList[nIdx];
    nLen := Length(nStr);

    if nAdd then
    begin
      if Copy(nStr, 1, nSLen) <> nSymbol then
        nStr := nSymbol + nStr;
      //xxxxx

      if Copy(nStr, nLen - nSLen + 1, nSLen) <> nSymbol then
        nStr := nStr + nSymbol;
      //xxxxx
    end else
    begin
      if Copy(nStr, 1, nSLen) = nSymbol then
        nStr := Copy(nStr, 2, nLen - 1);
      //xxxxx

      if Copy(nStr, nLen - nSLen + 1, nSLen) = nSymbol then
        nStr := Copy(nStr, 1, nLen - nSLen);
      //xxxxx
    end;

    nList[nIdx] := nStr;
    //change
  end;

  Result := Combine(nList, nFlag, nFlagEnd);
  //�ϲ�

  if nAdd and (not nListYet) then
    nList.Text := nBak;
  //��ԭ����
end;

//Date: 2017-03-17
//Parm: �ַ���;����;��䷽ʽ;��为��
//Desc: ʹ��nFixChar���nStr,ʹ�䱣��nWidth����.
class function TStringHelper.FixWidth(const nStr: string; const nWidth: Byte;
const nStyle: TFillPos; const nFixChar: Char): string;
var nLen,nHalf: Integer;
begin
  nLen := Length(nStr);
  if nLen >= nWidth then
  begin
    Result := nStr; 
    Exit;
  end;

  nLen := nWidth - nLen;
  //not enough length

  case nStyle of
   fpLeft:
    begin
      Result := StringOfChar(nFixChar, nLen) + nStr;
    end;
   fpMid:
    begin 
      nHalf := Trunc(nLen / 2);
      Result := StringOfChar(nFixChar, nHalf) + nStr +
                StringOfChar(nFixChar, nLen - nHalf);
    end;
   fpRight: 
    begin
      Result := nStr + StringOfChar(nFixChar, nLen);      
    end;
  end;
end;

//Date: 2017-03-17
//Parm: �ַ�;�Ƿ񸡵�
//Desc: �ж�nStr�Ƿ�Ϊ��ֵ
class function TStringHelper.IsNumber(const nStr: string;
  const nFloat: Boolean): Boolean;
begin
  Result := False;
  if nStr <> '' then  
  try
    if nFloat then
         StrToFloat(nStr)
    else StrToInt64(nStr);
    Result := True;
  except
    //ignor any error
  end;
end;

//Date: 2017-03-17
//Parm: �ַ���
//Desc: ��nStr����ת
class function TStringHelper.MirrorStr(const nStr: string): string ;
var nIdx,nLen: Integer;
begin
  nLen := Length(nStr);
  SetLength(Result, nLen);

  for nIdx:=1 to nLen do
    Result[nIdx] := nStr[nLen - nIdx + 1];
  //convert
end;

//------------------------------------------------------------------------------
const
  cPYData: array[216..247] of AnsiString = (
  {216}'CJWGNSPGCGNESYPB' + 'TYYZDXYKYGTDJNMJ' + 'QMBSGZSCYJSYYZPG' +
  {216}'KBZGYCYWYKGKLJSW' + 'KPJQHYZWDDZLSGMR' + 'YPYWWCCKZNKYDG',
  {217}'TTNJJEYKKZYTCJNM' + 'CYLQLYPYQFQRPZSL' + 'WBTGKJFYXJWZLTBN' +
  {217}'CXJJJJZXDTTSQZYC' + 'DXXHGCKBPHFFSSYY' + 'BGMXLPBYLLLHLX',
  {218}'SPZMYJHSOJNGHDZQ' + 'YKLGJHXGQZHXQGKE' + 'ZZWYSCSCJXYEYXAD' +
  {218}'ZPMDSSMZJZQJYZCD' + 'JEWQJBDZBXGZNZCP' + 'WHKXHQKMWFBPBY',
  {219}'DTJZZKQHYLYGXFPT' + 'YJYYZPSZLFCHMQSH' + 'GMXXSXJJSDCSBBQB' +
  {219}'EFSJYHXWGZKPYLQB' + 'GLDLCCTNMAYDDKSS' + 'NGYCSGXLYZAYBN',
  {220}'PTSDKDYLHGYMYLCX' + 'PYCJNDQJWXQXFYYF' + 'JLEJBZRXCCQWQQSB' +
  {220}'ZKYMGPLBMJRQCFLN' + 'YMYQMSQYRBCJTHZT' + 'QFRXQHXMJJCJLX',
  {221}'QGJMSHZKBSWYEMYL' + 'TXFSYDSGLYCJQXSJ' + 'NQBSCTYHBFTDCYZD' +
  {221}'JWYGHQFRXWCKQKXE' + 'BPTLPXJZSRMEBWHJ' + 'LBJSLYYSMDXLCL',
  {222}'QKXLHXJRZJMFQHXH' + 'WYWSBHTRXXGLHQHF' + 'NMCYKLDYXZPWLGGS' +
  {222}'MTCFPAJJZYLJTYAN' + 'JGBJPLQGDZYQYAXB' + 'KYSECJSZNSLYZH',
  {223}'ZXLZCGHPXZHZNYTD' + 'SBCJKDLZAYFMYDLE' + 'BBGQYZKXGLDNDNYS' +
  {223}'KJSHDLYXBCGHXYPK' + 'DQMMZNGMMCLGWZSZ' + 'XZJFZNMLZZTHCS',
  {224}'YDBDLLSCDDNLKJYK' + 'JSYCJLKOHQASDKNH' + 'CSGANHDAASHTCPLC' +
  {224}'PQYBSDMPJLPCJOQL' + 'CDHJJYSPRCHNKNNL' + 'HLYYQYHWZPTCZG',
  {225}'WWMZFFJQQQQYXACL' + 'BHKDJXDGMMYDJXZL' + 'LSYGXGKJRYWZWYCL' +
  {225}'ZMSSJZLDBYDCPCXY' + 'HLXCHYZJQSQQAGMN' + 'YXPFRKSSBJLYXY',
  {226}'SYGLNSCMHCWWMNZJ' + 'JLXXHCHSYD CTXRY' + 'CYXBYHCSMXJSZNPW' +
  {226}'GPXXTAYBGAJCXLYS' + 'DCCWZOCWKCCSBNHC' + 'PDYZNFCYYTYCKX',
  {227}'KYBSQKKYTQQXFCWC' + 'HCYKELZQBSQYJQCC' + 'LMTHSYWHMKTLKJLY' +
  {227}'CXWHEQQHTQHZPQSQ' + 'SCFYMMDMGBWHWLGS' + 'LLYSDLMLXPTHMJ',
  {228}'HWLJZYHZJXHTXJLH' + 'XRSWLWZJCBXMHZQX' + 'SDZPMGFCSGLSXYMJ' +
  {228}'SHXPJXWMYQKSMYPL' + 'RTHBXFTPMHYXLCHL' + 'HLZYLXGSSSSTCL',
  {229}'SLDCLRPBHZHXYYFH' + 'BBGDMYCNQQWLQHJJ' + 'ZYWJZYEJJDHPBLQX' +
  {229}'TQKWHLCHQXAGTLXL' + 'JXMSLXHTZKZJECXJ' + 'CJNMFBYCSFYWYB',
  {230}'JZGNYSDZSQYRSLJP' + 'CLPWXSDWEJBJCBCN' + 'AYTWGMPABCLYQPCL' +
  {230}'ZXSBNMSGGFNZJJBZ' + 'SFZYNDXHPLQKZCZW' + 'ALSBCCJXJYZHWK',
  {231}'YPSGXFZFCDKHJGXD' + 'LQFSGDSLQWZKXTMH' + 'SBGZMJZRGLYJBPML' +
  {231}'MSXLZJQQHZSJCZYD' + 'JWBMJKLDDPMJEGXY' + 'HYLXHLQYQHKYCW',
  {232}'CJMYYXNATJHYCCXZ' + 'PCQLBZWWYTWBQCML' + 'PMYRJCCCXFPZNZZL' +
  {232}'JPLXXYZTZLGDLDCK' + 'LYRLZGQTGJHHGJLJ' + 'AXFGFJZSLCFDQZ',
  {233}'LCLGJDJCSNCLLJPJ' + 'QDCCLCJXMYZFTSXG' + 'CGSBRZXJQQCTZHGY' +
  {233}'QTJQQLZXJYLYLBCY' + 'AMCSTYLPDJBYREGK' + 'JZYZHLYSZQLZNW',
  {234}'CZCLLWJQJJJKDGJZ' + 'OLBBZPPGLGHTGZXY' + 'GHZMYCNQSYCYHBHG' +
  {234}'XKAMTXYXNBSKYZZG' + 'JZLQJDFCJXDYGJQJ' + 'JPMGWGJJJPKQSB',
  {235}'GBMMCJSSCLPQPDXC' + 'DYYKYWCJDDYYGYWR' + 'HJRTGZNYQLDKLJSZ' +
  {235}'ZGZQZJGDYKSHPZMT' + 'LCPWNJAFYZDJCNMW' + 'ESCYGLBTZCGMSS',
  {236}'LLYXQSXSBSJSBBGG' + 'GHFJLYPMZJNLYYWD' + 'QSHZXTYYWHMCYHYW' +
  {236}'DBXBTLMSYYYFSXJC' + 'SDXXLHJHF SXZQHF' + 'ZMZCZTQCXZXRTT',
  {237}'DJHNNYZQQMNQDMMG' + 'LYDXMJGDHCDYZBFF' + 'ALLZTDLTFXMXQZDN' +
  {237}'GWQDBDCZJDXBZGSQ' + 'QDDJCMBKZFFXMKDM' + 'DSYYSZCMLJDSYN',
  {238}'SPRSKMKMPCKLGDBQ' + 'TFZSWTFGGLYPLLJZ' + 'HGJJGYPZLTCSMCNB' +
  {238}'TJBQFKTHBYZGKPBB' + 'YMTDSSXTBNPDKLEY' + 'CJNYCDYKZDDHQH',
  {239}'SDZSCTARLLTKZLGE' + 'CLLKJLQJAQNBDKKG' + 'HPJTZQKSECSHALQF' +
  {239}'MMGJNLYJBBTMLYZX' + 'DCJPLDLPCQDHZYCB' + 'ZSCZBZMSLJFLKR',
  {240}'ZJSNFRGJHXPDHYJY' + 'BZGDLJCSEZGXLBLH' + 'YXTWMABCHECMWYJY' +
  {240}'ZLLJJYHLGBDJLSLY' + 'GKDZPZXJYYZLWCXS' + 'ZFGWYYDLYHCLJS',
  {241}'CMBJHBLYZLYCBLYD' + 'PDQYSXQZBYTDKYYJ' + 'YYCNRJMPDJGKLCLJ' +
  {241}'BCTBJDDBBLBLCZQR' + 'PPXJCGLZCSHLTOLJ' + 'NMDDDLNGKAQHQH',
  {242}'JHYKHEZNMSHRP QQ' + 'JCHGMFPRXHJGDYCH' + 'GHLYRZQLCYQJNZSQ' +
  {242}'TKQJYMSZSWLCFQQQ' + 'XYFGGYPTQWLMCRNF' + 'KKFSYYLQBMQAMM',
  {243}'MYXCTPSHCPTXXZZS' + 'MPHPSHMCLMLDQFYQ' + 'XSZYJDJJZZHQPDSZ' +
  {243}'GLSTJBCKBXYQZJSG' + 'PSXQZQZRQTBDKYXZ' + 'KHHGFLBCSMDLDG',
  {244}'DZDBLZYYCXNNCSYB' + 'ZBFGLZZXSWMSCCMQ' + 'NJQSBDQSJTXXMBLT' +
  {244}'XZCLZSHZCXRQJGJY' + 'LXZFJPHYXZQQYDFQ' + 'JJLZZNZJCDGZYG',
  {245}'CTXMZYSCTLKPHTXH' + 'TLBJXJLXSCDQXCBB' + 'TJFQZFSLTJBTKQBX' +
  {245}'XJJLJCHCZDBZJDCZ' + 'JDCPRNPQCJPFCZLC' + 'LZXBDMXMPHJSGZ',
  {246}'GSZZQLYLWTJPFSYA' + 'SMCJBTZYYCWMYTCS' + 'JJLQCQLWZMALBXYF' +
  {246}'BPNLSFHTGJWEJJXX' + 'GLLJSTGSHJQLZFKC' + 'GNNDSZFDEQFHBS',
  {247}'AQTGYLBXMMYGSZLD' + 'YDQMJJRGBJTKGDHG' + 'KBLQKBDMBYLXWCXY' +
  {247}'TTYBKMRTJZXQJBHL' + 'MHMJJZMQASLDCYXY' + 'QDLQCAFYWYXQHZ'  );

//Desc: ����תƴ��
function HZ2PY(const nValue: array of AnsiChar): AnsiChar;
begin
  Result := #0;

  case Word(nValue[0]) shl 8 + Word(nValue[1]) of
    $B0A1..$B0C4: Result := 'A';
    $B0C5..$B2C0: Result := 'B';
    $B2C1..$B4ED: Result := 'C';
    $B4EE..$B6E9: Result := 'D';
    $B6EA..$B7A1: Result := 'E';
    $B7A2..$B8C0: Result := 'F';
    $B8C1..$B9FD: Result := 'G';
    $B9FE..$BBF6: Result := 'H';
    $BBF7..$BFA5: Result := 'J';
    $BFA6..$C0AB: Result := 'K';
    $C0AC..$C2E7: Result := 'L';
    $C2E8..$C4C2: Result := 'M';
    $C4C3..$C5B5: Result := 'N';
    $C5B6..$C5BD: Result := 'O';
    $C5BE..$C6D9: Result := 'P';
    $C6DA..$C8BA: Result := 'Q';
    $C8BB..$C8F5: Result := 'R';
    $C8F6..$CBF9: Result := 'S';
    $CBFA..$CDD9: Result := 'T';
    $CDDA..$CEF3: Result := 'W';
    $CEF4..$D1B8: Result := 'X';
    $D1B9..$D4D0: Result := 'Y';
    $D4D1..$D7F9: Result := 'Z';
  end; //һ������

  if Result = #0 then
   case Byte(nValue[0]) of
    216..247: Result := cPYData[Byte(nValue[0])][Byte(nValue[1]) - 160];
   end;
end;

//Desc: ƴ����Ч�ַ�(�ɼ��ַ�)
function PYValidChar(const nChar: AnsiChar): Boolean;
begin
  Result := (Ord(nChar) >= Ord(' ')) and (Ord(nChar) <= Ord('~'));
end;

//Date: 2017-03-17
//Parm: �����ַ���
//Desc: ��ȡnCH��ƴ������ĸ 
class function TStringHelper.GetPinYin(const nCH: string): string;
var nChar: AnsiChar;
    nStr: AnsiString;
    nIdx,nLen: integer;
    nArray: array[0..1] of AnsiChar;
begin
  Result := '';
  nIdx := 0;
  nLen := Length(nCH); 

  while nIdx < nLen do
  begin
    Inc(nIdx);
    nStr := AnsiString(nCH[nIdx]);
    
    if Length(nStr) < 2 then
    begin
      if PYValidChar(nStr[1]) then
        Result := Result + string(nStr);
      //xxxxx
    end else
    begin
      nArray[0] := nStr[1];
      nArray[1] := nStr[2];

      nChar := HZ2PY(nArray);
      if PYValidChar(nChar) then
        Result := Result + string(nChar);
      //xxxxx
    end;
  end;

  Result := LowerCase(Result);
end;

//------------------------------------------------------------------------------
//Date: 2017-03-17
//Parm: ֵ;����;��������
//Desc: ��nValue�Ŵ�nPrecision,Ȼ��ȡ��,С��λ��������
class function TFloatHelper.Float2PInt(const nValue: Double;
  const nPrecision: Integer; const nRound: Boolean): Int64;
var nStr,nVal: string;
    nInt: Integer;
begin
  nInt := Length(IntToStr(nPrecision)) - 1;
  //�Ŵ���(10,100)����0�ĸ���

  nStr := '#.' + StringOfChar('0', nInt + 2);
  //�ಹ��λ,��ֹ�����Զ���������

  nStr := FormatFloat(nStr, StrToFloat(FloatToStr(nValue)));
  //��ֹ������������

  if nStr = '' then
  begin
    Result := 0;
    Exit;
  end;

  nVal := Copy(nStr, 1, Length(nStr)-2);
  //ȥ���ಹ����λ
  nVal := StringReplace(nVal, '.', '', []);
  //ȥ��С����
  Result := StrToInt64(nVal);
  //תΪ����

  if nRound then
  begin
    nStr := Copy(nStr, Length(nStr)-1, 2);
    if StrToInt(nStr) < 50 then Exit;

    if Result >= 0 then
         Inc(Result)
    else Dec(Result);
  end;
end;

//Date: 2017-03-17
//Parm: ֵ;����;��������
//Desc: ��nValue�Ŵ�nPrecision,ȡ��,Ȼ�󻻻�С��
class function TFloatHelper.Float2Float(const nValue: Double;
  const nPrecision: Integer; const nRound: Boolean): Double;
begin
  Result := Float2PInt(nValue, nPrecision, nRound) / nPrecision;
end;

//Date: 2017-03-17
//Parm: ������A,B;���ж���ϵ;�ж�����
//Desc: ��nPrecision����,�ж�nA��nB�Ƿ�����nType��ϵ
class function TFloatHelper.FloatRelation(const nA, nB: Double;
  const nType: TFloatRelationType; const nPrecision: Integer): Boolean;
var nIA,nIB: Int64;
begin
  Result := False;
  nIA := Float2PInt(nA, nPrecision, False);
  nIB := Float2PInt(nB, nPrecision, False);

  case nType of
   rtGreater: Result := nIA > nIB;
   rtGE: Result := nIA >= nIB;
   rtEqual: Result := nIA = nIB;
   rtLE: Result := nIA <= nIB;
   rtLess: Result := nIA < nIB;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017-03-17
//Parm: ����������;�Ƿ���
//Desc: ��nDataִ��base64���� 
class function TEncodeHelper.EncodeBase64(const nData: string;
  const nLineBreak: Boolean): string;
var nCoder: TBase64Encoding;
begin
  nCoder := nil;
  try
    if nLineBreak then
         nCoder := TBase64Encoding.Create
    else nCoder := TBase64Encoding.Create(MaxInt);

    Result := nCoder.Encode(nData);
  finally
    nCoder.Free;
  end;
end;

//Date: 2017-03-17
//Parm: ����������
//Desc: ��nDataִ��base64����
class function TEncodeHelper.DecodeBase64(const nData: string): string;
begin
  with TBase64Encoding.Create do
  try
    Result := Decode(nData);
  finally
    Free;
  end;
end;

//Date: 2017-03-17
//Parm: ����������
//Desc: ��nDataִ��md5���� 
class function TEncodeHelper.EncodeMD5(const nData: string): string;
begin
  Result := THashMD5.GetHashString(nData);
end;

//------------------------------------------------------------------------------
//Desc: ���ػ���ʽ
function LocalDTSettings: TFormatSettings;
begin
  Result := TFormatSettings.Create('en-US');
  //default config  

  with Result do
  begin
    ShortDateFormat:='yyyy-MM-dd';
    DateSeparator  :='-';
    LongTimeFormat :='hh:mm:ss';
    TimeSeparator  :=':';
  end;
end;

//Desc: ת��Ϊ������
class function TDateTimeHelper.Str2Date(const nStr: string): TDate;
begin
  try
    Result := StrToDate(nStr, LocalDTSettings);
  except
    Result := Date();
  end;
end;

//Desc: ����ת�ַ���
class function TDateTimeHelper.Date2Str(const nDate: TDateTime;
  const nSeparator: Boolean): string;
begin
  if nSeparator then
       Result := FormatDateTime('YYYY-MM-DD', nDate)
  else Result := FormatDateTime('YYYYMMDD', nDate);
end;

//Desc: ת��Ϊʱ����
class function TDateTimeHelper.Str2Time(const nStr: string): TTime;
begin
  try
    Result := StrToTime(nStr, LocalDTSettings);
  except
    Result := Time();
  end;
end;

class function TDateTimeHelper.Time2Str(const nTime: TDateTime;
  const nSeparator: Boolean): string;
begin
  if nSeparator then
       Result := FormatDateTime('HH:MM:SS', nTime)
  else Result := FormatDateTime('HHMMSS', nTime);
end;

class function TDateTimeHelper.Str2DateTime(const nStr: string): TDateTime;
begin
  try
    Result := StrToDateTime(nStr, LocalDTSettings);
  except
    Result := Now();
  end;
end;

//Desc: ����ת�ַ���
class function TDateTimeHelper.DateTime2Str(const nDT: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd hh:mm:ss', nDT);
end;

//Desc: ��nDateתΪyyyy��MM��dd��
class function TDateTimeHelper.Date2CH(const nDate: TDate): string;
begin
  Result := Date2Str(nDate, False);
  Result := Copy(Result, 1, 4) + '��' +
            Copy(Result, 5, 2) + '��' +
            Copy(Result, 7, 2) + '��';
  //combine
end;

//Desc: ��hhMMss���ַ���תΪhhʱMM��ss��
class function TDateTimeHelper.Time2CH(const nTime: TTime): string;
begin
  Result := Time2Str(nTime, False);
  Result := Copy(Result, 1, 2) + 'ʱ' +
            Copy(Result, 3, 2) + '��' +
            Copy(Result, 5, 2) + '��';
  //combine
end;

//Date: 2013-07-21
//Parm: ǰ׺;����
//Desc: ��ȡnDate����������
class function TDateTimeHelper.Date2Week(nPrefix: string;
  nDate: TDateTime): string;
begin
  if nDate = 0 then
    nDate := Date();
  //default is now

  if nPrefix = '' then
    nPrefix := '����';
  //default prefix

  case DayOfWeek(nDate) of
   1: Result := '��';
   2: Result := 'һ';
   3: Result := '��';
   4: Result := '��';
   5: Result := '��';
   6: Result := '��';
   7: Result := '��' else Result := '';
  end;

  Result := nPrefix + Result;
end;

//Date: 2017-04-14
//Parm: ʱ�䳤��(��λ����)
//Desc: ����nTime�����Ƕ೤ʱ��(��,Сʱ,��,��,����)
class function TDateTimeHelper.TimeLong2CH(const nTime: Int64): string;
var nD,nH,nM,nS,nMS: Int64;
begin
  nD := Trunc(nTime / (1000 * 3600 * 24));
  nMS := nTime - nD * 1000 * 3600 * 24;
   
  nH := Trunc(nMS / (1000 * 3600));
  nMS := nMS - nH * 1000 * 3600;

  nM := Trunc(nMS / (1000 * 60));
  nMS := nMS - nM * 1000 * 60;

  nS := Trunc(nMS / 1000);
  nMS := nMS - nS * 1000;   
  Result := Format('%d �� %d ʱ %d �� %d �� %d ����', [nD, nH, nM, nS, nMS]);
end;

end.
