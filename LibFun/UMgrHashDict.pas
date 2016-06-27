{*******************************************************************************
  作者: dmzn@163.com 2011-10-12
  描述: 高速带索引哈希字典对象

  *.备注:
  *.索引规则: 第一层节点|0..9,a..z|共36个节点,第二层相同...,依次类推,层数由
    NodeLevel决定.上下级结构为:第一层的36个节点,每个节点对应第二层的一个节点.
                   0 1 2 3...y z      ->第一层
                       |       |
                   0 1 2 3..   |      ->第二层
                           0 1 2 3 ...
                               |
                           0 1 2 3 ...->二层数据
    由上图,得出第一层36个点,第二层36 x 36个点.
  *.以一个3个字符的字符串为例:共36x36x36=46656个,假若节点是线性的,检索很缓慢,使
    用索引字典二层存放,复杂度为:36(一层) + 36(二层) + 36(二层数据).

  *.待处理:
  *.命中缓冲使用移位填充,若当前位点(BufferIdx)在最后一个被命中的节点之前,即
    节点在(BufferIdx+1)的位置,会导致该节点刚被访问,然后就被清出缓冲,效率会降低.
*******************************************************************************}
unit UMgrHashDict;

interface

uses
  Windows, Classes, SysUtils, SyncObjs;

type
  PDictData = ^TDictData;
  TDictData = record
    FID: PChar;          //标识内容
    FIDLen: Byte;        //标识长度
    FType: Word;         //数据类型
    FData: Pointer;      //数据内容
  end;

  PDictNode = ^TDictNode;
  TDictNode = record
    FKey: Char;          //关键字
    FNodeSub: TList;     //子节点
    FNodeData: TList;    //数据组
    FOneData: PDictData; //单数据
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
    //节点深度
    FRoot: TDictNodeArray;
    //根节点
    FBufferIdx: Word;
    FBuffer: TDictDataArray;
    //命中缓冲
    FLock: TCriticalSection;
    //共享锁
    FDataCount: Integer;
    //数据个数
    FOnFree: TDictFreeData;
    //事件相关
  protected
    procedure FreeNode(const nNode: PDictNode; const nFreeMe: Boolean);
    procedure DisposeData(const nData: PDictData; const nFreeMe: Boolean);
    //释放资源
    function NewSubItem(const nID: string; const nIDLen: Word; var nLevel: Word;
      const nPNode: PDictNode): PDictData;
    function NewItem(const nID: string; const nIDLen: Word): PDictData;
    //新字典项
    function GetSubItem(const nID: string; const nIDLen: Word; var nLevel: Word;
      const nNode: PDictNode; const nDelData: Boolean = False): PDictData;
    function GetItem(const nID: string; const nDelData: Boolean = False): PDictData;
    //检索字典
  public
    constructor Create(const nNodeLeve: Word = 1);
    destructor Destroy; override;
    //创建释放
    procedure AddItem(const nID: string; const nData: Pointer;
      const nType: Word = 0; const nOnlyCheck: Boolean = True);
    function DelItem(const nID: string): Boolean;
    procedure ClearItem;
    //添加删除
    function FindItem(const nID: string): PDictData;
    //检索数据
    property DataCount: Integer read FDataCount;
    //属性相关
    property OnDataFree: TDictFreeData read FOnFree write FOnFree;
    //事件相关
  end;

implementation

const
  cMaxBuf = 36;                  //命中缓冲大小
  cMaxID = High(Byte) - 5;       //字典标识长度
  
  cSizeData = SizeOf(TDictData);
  cSizeNode = SizeOf(TDictNode); //节点结构大小

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

//Desc: 释放nNode节点
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

//Desc: 释放nData数据
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
//Parm: 标识;标识长度;关键字位置;节点;是否删除
//Desc: 在nNode中检索nID[nLevel]关键字的数据
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
      end else //单数据

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
    end; //最后一级节点

    if Assigned(FNodeSub) then
    begin
      Inc(nLevel);

      for nIdx:=FNodeSub.Count - 1 downto 0 do
      if PDictNode(FNodeSub[nIdx]).FKey = nID[nLevel] then
      begin
        Result := GetSubItem(nID, nIDLen, nLevel, FNodeSub[nIdx], nDelData);
        if Assigned(Result) then Break;
      end;
    end; //子节点
  end;
end;

//Desc: 检索标识为nID的字典项
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

//Desc: 检索标识为nID的字典项,结果存入nData.
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
//Parm: 标识;标识长度;关键字位置;父节点
//Desc: 在nPNode上创建nID字典项
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
    end; //最后一级节点

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

//Desc: 新建nID字典项
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

//Desc: 添加标识为nID,类型为nType的nData数据
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

//Desc: 删除nID字典项
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
