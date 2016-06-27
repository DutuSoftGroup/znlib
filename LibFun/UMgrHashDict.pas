{*******************************************************************************
  ����: dmzn@163.com 2011-10-12
  ����: ���ٴ�������ϣ�ֵ����

  *.��ע:
  *.��������: ��һ��ڵ�|0..9,a..z|��36���ڵ�,�ڶ�����ͬ...,��������,������
    NodeLevel����.���¼��ṹΪ:��һ���36���ڵ�,ÿ���ڵ��Ӧ�ڶ����һ���ڵ�.
                   0 1 2 3...y z      ->��һ��
                       |       |
                   0 1 2 3..   |      ->�ڶ���
                           0 1 2 3 ...
                               |
                           0 1 2 3 ...->��������
    ����ͼ,�ó���һ��36����,�ڶ���36 x 36����.
  *.��һ��3���ַ����ַ���Ϊ��:��36x36x36=46656��,�����ڵ������Ե�,�����ܻ���,ʹ
    �������ֵ������,���Ӷ�Ϊ:36(һ��) + 36(����) + 36(��������).

  *.������:
  *.���л���ʹ����λ���,����ǰλ��(BufferIdx)�����һ�������еĽڵ�֮ǰ,��
    �ڵ���(BufferIdx+1)��λ��,�ᵼ�¸ýڵ�ձ�����,Ȼ��ͱ��������,Ч�ʻή��.
*******************************************************************************}
unit UMgrHashDict;

interface

uses
  Windows, Classes, SysUtils, SyncObjs;

type
  PDictData = ^TDictData;
  TDictData = record
    FID: PChar;          //��ʶ����
    FIDLen: Byte;        //��ʶ����
    FType: Word;         //��������
    FData: Pointer;      //��������
  end;

  PDictNode = ^TDictNode;
  TDictNode = record
    FKey: Char;          //�ؼ���
    FNodeSub: TList;     //�ӽڵ�
    FNodeData: TList;    //������
    FOneData: PDictData; //������
  end;

  TDictNodeArray = array of TDictNode;
  TDictDataArray = array of PDictData;
  //array

  TDictFreeData = procedure (const nType: Word; const nData: Pointer) of Object;
  //event

type
  THashDictionary = class(TObject)
  private
    FLevel: Word;
    //�ڵ����
    FRoot: TDictNodeArray;
    //���ڵ�
    FBufferIdx: Word;
    FBuffer: TDictDataArray;
    //���л���
    FLock: TCriticalSection;
    //������
    FDataCount: Integer;
    //���ݸ���
    FOnFree: TDictFreeData;
    //�¼����
  protected
    procedure FreeNode(const nNode: PDictNode; const nFreeMe: Boolean);
    procedure DisposeData(const nData: PDictData; const nFreeMe: Boolean);
    //�ͷ���Դ
    function NewSubItem(const nID: string; const nIDLen: Word; var nLevel: Word;
      const nPNode: PDictNode): PDictData;
    function NewItem(const nID: string; const nIDLen: Word): PDictData;
    //���ֵ���
    function GetSubItem(const nID: string; const nIDLen: Word; var nLevel: Word;
      const nNode: PDictNode; const nDelData: Boolean = False): PDictData;
    function GetItem(const nID: string; const nDelData: Boolean = False): PDictData;
    //�����ֵ�
  public
    constructor Create(const nNodeLeve: Word = 1);
    destructor Destroy; override;
    //�����ͷ�
    procedure AddItem(const nID: string; const nData: Pointer;
      const nType: Word = 0; const nOnlyCheck: Boolean = True);
    function DelItem(const nID: string): Boolean;
    procedure ClearItem;
    //���ɾ��
    function FindItem(const nID: string): PDictData;
    //��������
    property DataCount: Integer read FDataCount;
    //�������
    property OnDataFree: TDictFreeData read FOnFree write FOnFree;
    //�¼����
  end;

implementation

const
  cMaxBuf = 36;                  //���л����С
  cMaxID = High(Byte) - 5;       //�ֵ��ʶ����
  
  cSizeData = SizeOf(TDictData);
  cSizeNode = SizeOf(TDictNode); //�ڵ�ṹ��С

//------------------------------------------------------------------------------
constructor THashDictionary.Create;
begin
  inherited Create;
  FDataCount := 0;
  SetLength(FRoot, 0);

  SetLength(FBuffer, cMaxBuf);
  FBufferIdx := Low(FBuffer);
  FillChar(FBuffer[0], SizeOf(FBuffer), #0);

  FLevel := nNodeLeve;
  if FLevel < 1 then FLevel := 1;
  FLock := TCriticalSection.Create;
end;

destructor THashDictionary.Destroy;
begin
  ClearItem;
  FLock.Free;
  inherited;
end;

procedure THashDictionary.ClearItem;
var nIdx: Integer;
begin
  FLock.Enter;
  try
    for nIdx:=Low(FRoot) to High(FRoot) do
      FreeNode(@FRoot[nIdx], False);
    //xxxxx
    
    SetLength(FRoot, 0);
    FillChar(FBuffer[0], SizeOf(FBuffer), #0);
    FBufferIdx := Low(FBuffer);
  finally
    FLock.Leave;
  end;
end;

//Desc: �ͷ�nNode�ڵ�
procedure THashDictionary.FreeNode(const nNode: PDictNode;
 const nFreeMe: Boolean);
var nIdx: Integer;
begin
  if Assigned(nNode.FNodeData) then
  begin
    for nIdx:=nNode.FNodeData.Count - 1 downto  0 do
      DisposeData(nNode.FNodeData[nIdx], True);
    FreeAndNil(nNode.FNodeData);
  end;

  if Assigned(nNode.FNodeSub) then
  begin
    for nIdx:=nNode.FNodeSub.Count - 1 downto 0 do
      FreeNode(nNode.FNodeSub[nIdx], True);
    FreeAndNil(nNode.FNodeSub);
  end;

  if Assigned(nNode.FOneData) then
    DisposeData(nNode.FOneData, True);
  //xxxxx

  if nFreeMe then Dispose(nNode);
  //free node
end;

//Desc: �ͷ�nData����
procedure THashDictionary.DisposeData(const nData: PDictData;
 const nFreeMe: Boolean);
begin
  try
    try
      if Assigned(nData.FID) and (nData.FIDLen > 0) then
        FreeMem(nData.FID, nData.FIDLen);
      if Assigned(FOnFree) then FOnFree(nData.FType, nData.FData);
    finally
      if nFreeMe then Dispose(nData);
    end;
  except
    //ignor any error
  end;
end;

//------------------------------------------------------------------------------
//Date: 2011-10-17
//Parm: ��ʶ;��ʶ����;�ؼ���λ��;�ڵ�;�Ƿ�ɾ��
//Desc: ��nNode�м���nID[nLevel]�ؼ��ֵ�����
function THashDictionary.GetSubItem(const nID: string; const nIDLen: Word;
  var nLevel: Word; const nNode: PDictNode; const nDelData: Boolean): PDictData;
var nIdx: Integer;
begin
  Result := nil;

  with nNode^ do
  begin
    if (nLevel = FLevel) or (nLevel = nIDLen) then
    begin
      if Assigned(FOneData) then
      begin
        if FOneData.FID = nID then
        begin
          Result := FOneData;

          if nDelData then
          begin
            DisposeData(Result, True);
            FOneData := nil;
          end;
        end;
      end else //������

      if Assigned(FNodeData) then
      begin
        for nIdx:=FNodeData.Count - 1 downto 0 do
        if PDictData(FNodeData[nIdx]).FID = nID then
        begin
          Result := FNodeData[nIdx];

          if nDelData then
          begin
            DisposeData(Result, True);
            FNodeData.Delete(nIdx);
          end;
          
          Break;
        end;
      end;

      Exit;
    end; //���һ���ڵ�

    if Assigned(FNodeSub) then
    begin
      Inc(nLevel);

      for nIdx:=FNodeSub.Count - 1 downto 0 do
      if PDictNode(FNodeSub[nIdx]).FKey = nID[nLevel] then
      begin
        Result := GetSubItem(nID, nIDLen, nLevel, FNodeSub[nIdx], nDelData);
        if Assigned(Result) then Break;
      end;
    end; //�ӽڵ�
  end;
end;

//Desc: ������ʶΪnID���ֵ���
function THashDictionary.GetItem(const nID: string;
  const nDelData: Boolean = False): PDictData;
var nLevel: Word;
    nIdx,nLen: Integer;
begin
  Result := nil;
  nLen := Length(nID);

  if nLen > 0 then
  begin
    for nIdx:=Low(FRoot) to High(FRoot) do
    if FRoot[nIdx].FKey = nID[1] then
    begin
      nLevel := 1;
      Result := GetSubItem(nID, nLen, nLevel, @FRoot[nIdx], nDelData);
      if Assigned(Result) then Break;
    end;
  end;
end;

//Desc: ������ʶΪnID���ֵ���,�������nData.
function THashDictionary.FindItem(const nID: string): PDictData;
var nLow: string;
    nIdx: Integer;
begin
  FLock.Enter;
  try
    Result := nil;
    nLow := LowerCase(nID);

    for nIdx:=Low(FBuffer) to High(FBuffer) do
    if Assigned(FBuffer[nIdx]) and (FBuffer[nIdx].FID = nLow) then
    begin
      Result := FBuffer[nIdx]; Break;
    end;

    if not Assigned(Result) then
    begin
      Result := GetItem(nLow);

      if Assigned(Result) then
      begin
        if FBufferIdx >= cMaxBuf then
          FBufferIdx := Low(FBuffer);
        //xxxxx

        FBuffer[FBufferIdx] := Result;
        Inc(FBufferIdx);
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2011-10-17
//Parm: ��ʶ;��ʶ����;�ؼ���λ��;���ڵ�
//Desc: ��nPNode�ϴ���nID�ֵ���
function THashDictionary.NewSubItem(const nID: string; const nIDLen: Word;
  var nLevel: Word; const nPNode: PDictNode): PDictData;
var nIdx: Integer;
    nNode: PDictNode;
begin
  with nPNode^ do
  begin
    if (nLevel = FLevel) or (nLevel = nIDLen) then
    begin
      if Assigned(FNodeData) or Assigned(FOneData) then
      begin
        if not Assigned(FNodeData) then
          FNodeData := TList.Create;
        //xxxxx

        if Assigned(FOneData) then
        begin
          FNodeData.Add(FOneData);
          FOneData := nil;
        end;

        New(Result);
        FNodeData.Add(Result);
      end else
      begin
        New(FOneData);
        Result := FOneData;
      end;

      Exit;
    end; //���һ���ڵ�

    if not Assigned(FNodeSub) then
      FNodeSub := TList.Create;
    //xxxxx

    Inc(nLevel);
    nNode := nil;

    for nIdx:=FNodeSub.Count - 1 downto 0 do
    if PDictNode(FNodeSub[nIdx]).FKey = nID[nLevel] then
    begin
      nNode := FNodeSub[nIdx];
      Break;
    end;

    if not Assigned(nNode) then
    begin
      New(nNode);
      FNodeSub.Add(nNode);

      FillChar(nNode^, cSizeNode, #0);
      nNode.FKey := nID[nLevel];
    end;

    Result := NewSubItem(nID, nIDLen, nLevel, nNode);
    //new item
  end;
end;

//Desc: �½�nID�ֵ���
function THashDictionary.NewItem(const nID: string; const nIDLen: Word): PDictData;
var nLevel: Word;
    nIdx: Integer;
begin
  Result := nil;

  for nIdx:=Low(FRoot) to High(FRoot) do
  if FRoot[nIdx].FKey = nID[1] then
  begin
    nLevel := 1;
    Result := NewSubItem(nID, nIDLen, nLevel, @FRoot[nIdx]);
    Break;
  end;

  if not Assigned(Result) then
  begin
    nIdx := Length(FRoot);
    SetLength(FRoot, nIdx + 1);
    FillChar(FRoot[nIdx], cSizeNode, #0);

    nLevel := 1;
    FRoot[nIdx].FKey := nID[nLevel];
    Result := NewSubItem(nID, nIDLen, nLevel, @FRoot[nIdx]);
  end;

  Inc(FDataCount);
  FillChar(Result^, cSizeData, #0);
  //init          
end;

//Desc: ��ӱ�ʶΪnID,����ΪnType��nData����
procedure THashDictionary.AddItem(const nID: string; const nData: Pointer;
  const nType: Word; const nOnlyCheck: Boolean);
var nLow: string;
    nLen: Integer;
    nPtr: PDictData;
begin
  nLen := Length(nID);
  if nLen < 1 then Exit;

  FLock.Enter;
  try
    nLow := LowerCase(nID);
    if nLen > cMaxID then
    begin
      nLow := Copy(nLow, 1, cMaxID);
      nLen := cMaxID;
    end;

    if nOnlyCheck then
         nPtr := GetItem(nLow)
    else nPtr := nil;
    
    if Assigned(nPtr) then
         DisposeData(nPtr, False)
    else nPtr := NewItem(nLow, nLen);
    
    with nPtr^ do
    begin
      FIDLen := nLen + 1;
      FID := GetMemory(FIDLen);
      StrPCopy(FID, nLow);

      FType := nType;
      FData := nData;
    end;
  finally
    FLock.Leave;
  end;
end;

//Desc: ɾ��nID�ֵ���
function THashDictionary.DelItem(const nID: string): Boolean;
var nIdx: Integer;
    nPtr: PDictData;
begin
  FLock.Enter;
  try
    nPtr := GetItem(LowerCase(nID), True);
    Result := Assigned(nPtr);

    if Result then
    begin
      Dec(FDataCount);

      for nIdx:=Low(FBuffer) to High(FBuffer) do
      if FBuffer[nIdx] = nPtr then
      begin
        FBuffer[nIdx] := nil;
        Break;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

end.
