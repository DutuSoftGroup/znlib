{*******************************************************************************
  ����: dmzn@163.com 2008-8-6
  ����: Base64�ı�����
*******************************************************************************}
unit UBase64;

interface

function EncodeBase64(const nStr:string):string;
function DecodeBase64(const nStr:string):string;
//��ں���

implementation

const
  gBaseTable:string='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  //BASE64���

function FindInTable(const nStr: string):integer;
begin
  Result := Pos(nStr, gBaseTable) - 1;
end;

//���뺯��
function EncodeBase64(const nStr:string):string;
var
  Times,LenSrc,i:integer;
  x1,x2,x3,x4:char;
  xt:byte;
begin
  result:='';
  LenSrc:=length(nStr);
  if LenSrc mod 3 =0 then Times:=LenSrc div 3
  else Times:=LenSrc div 3 + 1;
  for i:=0 to times-1 do
  begin
    if LenSrc >= (3+i*3) then
    begin
      x1:=gBaseTable[(ord(nStr[1+i*3]) shr 2)+1];
      xt:=(ord(nStr[1+i*3]) shl 4) and 48;
      xt:=xt or (ord(nStr[2+i*3]) shr 4);
      x2:=gBaseTable[xt+1];
      xt:=(Ord(nStr[2+i*3]) shl 2) and 60;
      xt:=xt or (ord(nStr[3+i*3]) shr 6);
      x3:=gBaseTable[xt+1];
      xt:=(ord(nStr[3+i*3]) and 63);
      x4:=gBaseTable[xt+1];
    end
    else if LenSrc>=(2+i*3) then
    begin
      x1:=gBaseTable[(ord(nStr[1+i*3]) shr 2)+1];
      xt:=(ord(nStr[1+i*3]) shl 4) and 48;
      xt:=xt or (ord(nStr[2+i*3]) shr 4);
      x2:=gBaseTable[xt+1];
      xt:=(ord(nStr[2+i*3]) shl 2) and 60;
      x3:=gBaseTable[xt+1];
      x4:='=';
    end else
    begin
      x1:=gBaseTable[(ord(nStr[1+i*3]) shr 2)+1];
      xt:=(ord(nStr[1+i*3]) shl 4) and 48;
      x2:=gBaseTable[xt+1];
      x3:='=';
      x4:='=';
    end;
    result:=result+x1+x2+x3+x4;
  end;
end;

//���뺯��
function DecodeBase64(const nStr:string):string;
var
  SrcLen,Times,i:integer;
  x1,x2,x3,x4,xt:byte;
begin
  result:='';
  SrcLen:=Length(nStr);
  Times:=SrcLen div 4;
  for i:=0 to Times-1 do
  begin
    x1:=FindInTable(nStr[1+i*4]);
    x2:=FindInTable(nStr[2+i*4]);
    x3:=FindInTable(nStr[3+i*4]);
    x4:=FindInTable(nStr[4+i*4]);
    x1:=x1 shl 2;
    xt:=x2 shr 4;
    x1:=x1 or xt;
    x2:=x2 shl 4;
    result:=result+chr(x1);
    if x3= 64 then break;
    xt:=x3 shr 2;
    x2:=x2 or xt;
    x3:=x3 shl 6;
    result:=result+chr(x2);
    if x4=64 then break;
    x3:=x3 or x4;
    result:=result+chr(x3);
  end;
end;

end.