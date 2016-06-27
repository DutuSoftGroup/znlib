{-----------------------------------------------------------------------------
 Degisy Software TDataFile
 Last modification : March, 13, 2004
 (Please write this last modification date in your e-mails.)

 Product:       TDataFile
 Version: 	1.19
 Author:	Alexander Momot
 Web:		http://www.degisy.com
 E-Mail:	support@degisy.com
 Status:	FreeWare
 Delphi:		32-bit versions
 Platform:	Windows 32-bit versions.

~ History ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 20.02.2003
 [+] Added a new ReadFont and WriteFont methods. (Thanks to Sergey)
-----------------------------------------------------------------------------}
unit UDataFile;

interface

uses
  Windows, SysUtils, Classes, Graphics;

const
  MAX_NAMELEN    = 36;
  MAXPATHLEN     = 240;
  SECTION_TEST   = '$test';

type
  IDENTNAME = array[0..MAX_NAMELEN - 1]of Char;

  pDataHdr = ^IDataHdr;
  IDataHdr = packed record
   Id      : Integer;
   Section : IDENTNAME;
   Ident   : IDENTNAME;
   Size    : Integer;
  end;

  TDataFile = class(TObject)
  private
    FFile: TFileStream;
    FFileName: string;
    FCodeKey: string;
    function  GetSectionCount: Integer;
    procedure XorBuffer(pBuf: Pointer; Count: integer);
    function  FindIdent(Section, Ident: string; pHdr: pDataHdr): boolean;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    //----------------------------------------------------
    procedure GetSectionNames(List: TStrings);
    procedure GetValueNames(Section: string; List: TStrings);
    //----------------------------------------------------
    function  SectionExists(Section: string): Boolean;
    function  ValueExists(Section, Ident: string): Boolean;
    //----------------------------------------------------
    function  ReadData(Section, Ident: string; pBuf: Pointer): Integer;
    function  ReadStream(Section, Ident: string; Stream: TStream): Integer;
    function  ReadString(Section, Ident, Default: string): string;
    function  ReadInteger(Section, Ident: string; Default: Integer): Integer;
    function  ReadDouble(Section, Ident: string; Default: Double): Double;
    function  ReadExtended(Section, Ident: string; Default: Extended): Extended;
    function  ReadDateTime(Section, Ident: string; Default: TDateTime): TDateTime;
    function  ReadBoolean(Section, Ident: string; Default: Boolean): Boolean;
    procedure ReadStrings(Section, Ident: string; List: TStrings);
    procedure ReadFont(Section, Ident: string; Font: TFont);
    //----------------------------------------------------
    function  WriteData(Section, Ident: string; pBuf: Pointer; Count: Integer): Integer;
    function  WriteStream(Section, Ident: string; Stream: TStream): Integer;
    procedure WriteString(Section, Ident, Value: string);
    procedure WriteInteger(Section, Ident: string; Value: Integer);
    procedure WriteDouble(Section, Ident: string; Value: Double);
    procedure WriteExtended(Section, Ident: string; Value: Extended);
    procedure WriteDateTime(Section, Ident: string; Value: TDateTime);
    procedure WriteBoolean(Section, Ident: string; Value: Boolean);
    procedure WriteStrings(Section, Ident: string; List: TStrings);
    procedure WriteFont(Section, Ident: string; Font: TFont);
    //----------------------------------------------------
    procedure Delete(Section, Ident: string);
    procedure DeleteSection(Section: string);
    //----------------------------------------------------
    property  CodeKey: string read FCodeKey write FCodeKey;
    property  FileName: string read FFileName;
    property  SectionCount: Integer read GetSectionCount;
  end;


implementation

const
  HDR_IDENT = $112;

type
  IIFont = class(TFont);

  pSaveFont = ^ISaveFont;
  ISaveFont = packed record
   CharSet : TFontCharSet;
   Color   : TColor;
   Pitch   : TFontPitch;
   Size    : Word;
   Style   : TFontStyles;
  end;

constructor TDataFile.Create(const FileName: string);
var
  OpenMode: integer;
begin
  FFileName := FileName;
  if FileExists(FFileName)then
   OpenMode := fmOpenReadWrite or fmShareDenyNone
  else
   OpenMode := fmCreate or fmShareDenyNone;
  FFile := TFileStream.Create(FileName, OpenMode);
  FCodeKey := 'hDmpSwrdGZxqlHdgfcIRuHsDHs5Tu';
end;                           

destructor  TDataFile.Destroy;
begin
  if Assigned( FFile )then FFile.Free;
end;

function TDataFile.FindIdent(Section, Ident: string; pHdr: pDataHdr): boolean;
var
  Sect    : string;
  Iden    : string;
  Count   : integer;
  IsError : boolean;
begin
  IsError := False;
  Result  := False;
  FFile.Seek(0, soFromBeginning);
  repeat
   Count  := FFile.Read(pHdr^, SizeOf(IDataHdr));
   if( Count <> SizeOf(IDataHdr))then Break;
   XorBuffer(pHdr, SizeOf(IDataHdr));
   if( pHdr^.ID <> HDR_IDENT )then
   begin
    IsError := True;
    Break;
   end;
   Sect := pHdr^.Section;
   Iden := pHdr^.Ident;
   Result := ( ANSICompareText(Sect, Section) = 0 )and
             (( ANSICompareText(Iden, Ident) = 0 )or
             ( Ident = SECTION_TEST ));
   if( Result )then Break;
   FFile.Seek(pHdr^.Size, soFromCurrent);
  until( False );
  if( IsError )then raise EInvalidOperation.Create('Invalid file format.');
end;

procedure TDataFile.XorBuffer(pBuf: Pointer; Count: Integer);
var
  I: Integer;
  P: pByte;
begin
  p := pBuf;
  if( FCodeKey <> '' )then
  for I := 0 to Count - 1 do
  begin
   p^ := Byte(FCodeKey[1 + ((I - 1) mod Length(FCodeKey))]) xor p^;
   inc(p);
  end;
end;

function TDataFile.GetSectionCount: Integer;
var
  Hdr    : IDataHdr;
  Count  : integer;
  IsError: boolean;
begin
  IsError := False;
  Result  := 0;
  FFile.Seek(0, soFromBeginning);
  repeat
   Count  := FFile.Read(Hdr, SizeOf(IDataHdr));
   if( Count <> SizeOf(IDataHdr))then Break;
   XorBuffer(pBYTE(@Hdr), SizeOf(IDataHdr));
   if( Hdr.ID <> HDR_IDENT )then
   begin
    IsError := True;
    Break;
   end else inc(Result);
   FFile.Seek(Hdr.Size, soFromCurrent);
  until( False );
  if( IsError )then raise EInvalidOperation.Create('Invalid file format.');
end;

procedure TDataFile.GetSectionNames(List: TStrings);
var
  Hdr    : IDataHdr;
  Count  : integer;
  IsError: boolean;
begin
  IsError := False;
  List.Clear;
  FFile.Seek(0, soFromBeginning);
  repeat
   Count  := FFile.Read(Hdr, SizeOf(IDataHdr));
   if( Count <> SizeOf(IDataHdr))then Break;
   XorBuffer(pBYTE(@Hdr), SizeOf(IDataHdr));
   if( Hdr.ID <> HDR_IDENT )then
   begin
    IsError := True;
    Break;
   end else
   if( List.IndexOf(Hdr.Section) = -1 )then
   List.Add(Hdr.Section);
   FFile.Seek(Hdr.Size, soFromCurrent);
  until( False );
  if( IsError )then raise EInvalidOperation.Create('Invalid file format.');
end;

procedure TDataFile.GetValueNames(Section: string; List: TStrings);
var
  Hdr    : IDataHdr;
  Count  : integer;
  IsError: boolean;
begin
  IsError := False;
  List.Clear;
  FFile.Seek(0, soFromBeginning);
  repeat
   Count  := FFile.Read(Hdr, SizeOf(IDataHdr));
   if( Count <> SizeOf(IDataHdr))then Break;
   XorBuffer(pBYTE(@Hdr), SizeOf(IDataHdr));
   if( Hdr.ID <> HDR_IDENT )then
   begin
    IsError := True;
    Break;
   end else
   if ANSICompareText(Section, Hdr.Section) = 0 then
   List.Add(Hdr.Ident);
   FFile.Seek(Hdr.Size, soFromCurrent);
  until( False );
  if( IsError )then raise EInvalidOperation.Create('Invalid file format.');
end;

{------------------------------------------------------------------------------}
{  find                                                                        }
{------------------------------------------------------------------------------}

function TDataFile.SectionExists(Section: string): Boolean;
var
  Hdr: IDataHdr;
begin
  Result := FindIdent(Section, SECTION_TEST, @Hdr);
end;

function TDataFile.ValueExists(Section, Ident: string): Boolean;
var
  Hdr: IDataHdr;
begin
  Result := FindIdent(Section, Ident, @Hdr);
end;

{------------------------------------------------------------------------------}
{  read                                                                        }
{------------------------------------------------------------------------------}

function TDataFile.ReadData(Section, Ident: string; pBuf: Pointer): Integer;
var
  Found   : boolean;
  Hdr     : IDataHdr;
begin
  Found := FindIdent(Section, Ident, @Hdr);
  if( Found  )then
  begin
   Result := FFile.Read(pBuf^, Hdr.Size);
   XorBuffer(pBuf, Hdr.Size);
  end else
   Result := -1;
end;

function TDataFile.ReadStream(Section, Ident: string; Stream: TStream): Integer;
var
  Hdr  : IDataHdr;
  pBuf : Pointer;
begin
  if( FindIdent(Section, Ident, @Hdr)  )then
  begin
   Result := Hdr.Size;
   GetMem(pBuf, Result);
   try
    FFile.Read(pBuf^, Result);
    XorBuffer(pBuf, Result);
    Stream.Size := 0;
    Stream.Write(pBuf^, Result);
    Stream.Seek(0, soFromBeginning);
   finally
    FreeMem(pBuf, Result);
   end;
  end else
   Result := -1;
end;

function TDataFile.ReadString(Section, Ident, Default: string): string;
var
  Buf   : TMemoryStream;
  pBuf  : PChar;
  Count : Integer;
begin
  Buf   := TMemoryStream.Create;
  try
   Count := ReadStream(Section, Ident, Buf);
   if( Count > -1 )then
   begin
    pBuf  := StrAlloc(Count);
    try
     Buf.Seek(0, soFromBeginning);
     Buf.Read(pBuf^, Count);
     Result := StrPas(pBuf);
    finally
     StrDispose(pBuf);
    end;
   end else
    Result := Default;
  finally
   Buf.Free;
  end;
end;

function TDataFile.ReadInteger(Section, Ident: string; Default: Integer): Integer;
var
  Buf   : array[0..1023]of Char;
  Count : Integer;
begin
  Count := ReadData(Section, Ident, @Buf);
  if( Count >= SizeOf(Integer) )then
   Move(Buf, Result, SizeOf(Integer))
  else
   Result := Default;
end;

function TDataFile.ReadDouble(Section, Ident: string; Default: Double): Double;
var
  Buf   : array[0..1023]of Char;
  Count : Integer;
begin
  Count := ReadData(Section, Ident, @Buf);
  if( Count >= SizeOf(Double) )then
   Move(Buf, Result, SizeOf(Double))
  else
   Result := Default;
end;

function TDataFile.ReadExtended(Section, Ident: string; Default: Extended): Extended;
var
  Buf   : array[0..1023]of Char;
  Count : Integer;
begin
  Count := ReadData(Section, Ident, @Buf);
  if( Count >= SizeOf(Extended) )then
   Move(Buf, Result, SizeOf(Extended))
  else
   Result := Default;
end;

function TDataFile.ReadDateTime(Section, Ident: string; Default: TDateTime): TDateTime;
var
  Buf   : array[0..1023]of Char;
  Count : Integer;
begin
  Count := ReadData(Section, Ident, @Buf);
  if( Count >= SizeOf(TDateTime) )then
   Move(Buf, Result, SizeOf(TDateTime))
  else
   Result := Default;
end;

function TDataFile.ReadBoolean(Section, Ident: string; Default: Boolean): Boolean;
var
  Buf   : array[0..1023]of Char;
  Count : Integer;
begin
  Count := ReadData(Section, Ident, @Buf);
  if( Count >= SizeOf(Boolean) )then
   Move(Buf, Result, SizeOf(Boolean))
  else
   Result := Default;
end;

procedure TDataFile.ReadStrings(Section, Ident: string; List: TStrings);
var
  Buf   : TMemoryStream;
  Count : Integer;
begin
  List.Clear;
  Buf := TMemoryStream.Create;
  try
   Count := ReadStream(Section, Ident, Buf);
   if( Count > -1 )then
   List.LoadFromStream( Buf );
  finally
   Buf.Free;
  end;
end;

procedure TDataFile.ReadFont(Section, Ident: string; Font: TFont);
var
  Buf   : TMemoryStream;
  pPos  : PChar;
  pBuf  : Pointer;
  Count : Integer;
  FontChange: TNotifyEvent;
begin
  Buf := TMemoryStream.Create;
  try
   Count := ReadStream(Section, Ident, Buf);
   if( Count > SizeOf(ISaveFont))then
   begin
    GetMem(pBuf, Count);
    FontChange := Font.OnChange;
    try
     Buf.Seek(0, soFromBeginning);
     Buf.Read(pBuf^, Count);
     Font.OnChange := nil;
     Font.Charset := pSaveFont(pBuf)^.CharSet;
     Font.Color := pSaveFont(pBuf)^.Color;
     Font.Pitch := pSaveFont(pBuf)^.Pitch;
     Font.Size  := pSaveFont(pBuf)^.Size;
     Font.Style := pSaveFont(pBuf)^.Style;
     pPos := pBuf;
     inc(pPos, SizeOf(ISaveFont));
     Font.Name := StrPas(pPos);
    finally
     Font.OnChange := FontChange;
     IIFont(Font).Changed;
     FreeMem(pBuf, Count);
    end;
   end; 
  finally
   Buf.Free;
  end;
end;

{------------------------------------------------------------------------------}
{  write                                                                       }
{------------------------------------------------------------------------------}

function TDataFile.WriteData(Section, Ident: string; pBuf: Pointer; Count: Integer): Integer;
var
  Hdr : IDataHdr;
  P   : Pointer;
begin
  Delete(Section, Ident);
  FFile.Seek(0, soFromEnd);
  { feel header }
  Hdr.Id := HDR_IDENT;
  StrPCopy(Hdr.Section, Section);
  StrPCopy(Hdr.Ident, Ident);
  Hdr.Size := Count;
  { xor }
  XorBuffer(@Hdr, SizeOf(IDataHdr));
  { write header }
  Result := FFile.Write(Hdr, SizeOf(IDataHdr));
  if( Result > -1 )then
  begin
   GetMem(P, Count);
   try
    Move(pBuf^, P^, Count);
    { xor data }
    XorBuffer(P, Count);
    { write data }
    Result := FFile.Write(P^, Count);
   finally
    FreeMem(P, Count);
   end;
  end;
end;

function TDataFile.WriteStream(Section, Ident: string; Stream: TStream): Integer;
var
  pBuf : Pointer;
begin
  { init buffer }
  GetMem(pBuf, Stream.Size);
  try
   Stream.Seek(0, soFromBeginning);
   Stream.Read(pBuf^, Stream.Size);
   { write data }
   Result := WriteData(Section, Ident, pBuf, Stream.Size);
  finally
   FreeMem(pBuf, Stream.Size);
  end;
end;

procedure TDataFile.WriteString(Section, Ident, Value: string);
var
  pBuf : pChar;
begin
  pBuf := StrNew(PChar(Value));
  try
   WriteData(Section, Ident, pBuf, StrLen(pBuf) + 1);
  finally
   StrDispose(pBuf);
  end;
end;

procedure TDataFile.WriteInteger(Section, Ident: string; Value: Integer);
begin
  WriteData(Section, Ident, @Value, SizeOf(Integer));
end;

procedure TDataFile.WriteDouble(Section, Ident: string; Value: Double);
begin
  WriteData(Section, Ident, @Value, SizeOf(Double));
end;

procedure TDataFile.WriteExtended(Section, Ident: string; Value: Extended);
begin
  WriteData(Section, Ident, @Value, SizeOf(Extended));
end;

procedure TDataFile.WriteDateTime(Section, Ident: string; Value: TDateTime);
begin
  WriteData(Section, Ident, @Value, SizeOf(TDateTime));
end;

procedure TDataFile.WriteBoolean(Section, Ident: string; Value: Boolean);
begin
  WriteData(Section, Ident, @Value, SizeOf(Boolean));
end;

procedure TDataFile.WriteStrings(Section, Ident: string; List: TStrings);
var
  Buf   : TMemoryStream;
begin
  Buf := TMemoryStream.Create;
  try
   List.SaveToStream( Buf );
   WriteStream(Section, Ident, Buf);
  finally
   Buf.Free;
  end;
end;

procedure TDataFile.WriteFont(Section, Ident: string; Font: TFont);
var
  pBuf: Pointer;
  pPos: PChar;
  Len : Integer;
begin
  Len := SizeOf(ISaveFont) + Length(Font.Name) + 1;
  GetMem(pBuf, Len);
  try
   pSaveFont(pBuf)^.CharSet := Font.Charset;
   pSaveFont(pBuf)^.Color := Font.Color;
   pSaveFont(pBuf)^.Pitch := Font.Pitch;
   pSaveFont(pBuf)^.Size  := Font.Size;
   pSaveFont(pBuf)^.Style := Font.Style;
   pPos := pBuf;
   inc(pPos, SizeOf(ISaveFont));
   StrPCopy(pPos, Font.Name);
   WriteData(Section, Ident, pBuf, Len);
  finally
   FreeMem(pBuf, Len);
  end;
end;

{------------------------------------------------------------------------------}
{  delete                                                                      }
{------------------------------------------------------------------------------}

procedure TDataFile.Delete(Section, Ident: string);
var
  BufPos   : Integer;
  HdrPos   : Integer;
  EndPos   : Integer;
  FileSize : Integer;
  Count    : Integer;
  Hdr      : IDataHdr;
  pBuf     : Pointer;
begin
  if( FindIdent(Section, Ident, @Hdr) )then
  begin
   FileSize := FFile.Size;
   BufPos   := FFile.Position;
   HdrPos   := BufPos - SizeOf(IDataHdr);
   { seek to end buffer }
   EndPos   := FFile.Seek(Hdr.Size, soFromCurrent);
   Count    := FileSize - EndPos;
   GetMem(pBuf, Count);
   try
    FFile.Read(pBuf^, Count);
    FFile.Seek(HdrPos, soFromBeginning);
    FFile.Write(pBuf^, Count);
    FFile.Size := FileSize - ( Hdr.Size + SizeOf(IDataHdr) );
   finally
    FreeMem(pBuf, Count);
   end;
  end;
end;

procedure TDataFile.DeleteSection(Section: string);
var
  BufPos : Integer;
  HdrPos : Integer;
  EndPos : Integer;
  Size   : Integer;
  Count  : Integer;
  Hdr    : IDataHdr;
  pBuf   : Pointer;
begin
  //while FindIdent(Section, '', @Hdr)do
  while FindIdent(Section, SECTION_TEST, @Hdr)do
  begin
   Size := FFile.Size;
   BufPos := FFile.Position;
   HdrPos := BufPos - SizeOf(IDataHdr);
   { Seek to end buffer }
   EndPos := FFile.Seek(Hdr.Size, soFromCurrent);
   Count  := Size - EndPos;
   GetMem(pBuf, Count);
   try
    FFile.Read(pBuf^, Count);
    FFile.Seek(HdrPos, soFromBeginning);
    FFile.Write(pBuf^, Count);
    FFile.Size := Size - ( Hdr.Size + SizeOf(IDataHdr) );
   finally
    FreeMem(pBuf, Count);
   end;
  end;
end;

end.
