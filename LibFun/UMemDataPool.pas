{*******************************************************************************
  作者: dmzn@163.com 2015-08-04
  描述: 管理new/getmem分配的内存数据项

  备注:
  *.使用方法:
    1.RegDataType: 注册数据类型.
    2.LockData: 锁定数据,管理器会检索缓冲池,有空闲则返回,无空闲则创建.
    3.UnlockData: 释放锁定,与LockData配对使用.
  *.由于LockData带有一些逻辑,比直接new/getmem操作慢很多.
  *.管理器的意义,在于简化内存调用,提供应用的内存分配状体,减少内存碎片(可能).
  *.线程安全.
*******************************************************************************}
unit UMemDataPool;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, UBaseObject;

type
  TMPDataNew = procedure (const nFlag: string; const nType: Word;
    var nData: Pointer);
  //分配内存回调
  TMPDataDispose = procedure (const nFlag: string; const nType: Word;
    const nData: Pointer);
  //释放内存回调
  TMPDataEnumCallback = function (const nData: Pointer; const nResult: TList): Boolean;
  //数据枚举回调

  PMPDataMain = ^TMPDataMain;
  TMPDataMain = record
    FType: Word;                         //数据类型
    FFlag: string;                       //数据表示
    FDesc: string;                       //类型描述
    FNumOnce: Byte;                      //单次分配
    FNumAll: Word;                       //总数量
    FNumFree: Word;                      //可用数量
    FNumLock: Int64;                     //请求次数

    FDataFirst: Pointer;                 //数据列表
    FDataNew: TMPDataNew;                //分配内存
    FDataDispose: TMPDataDispose;        //释放内存
  end;

  PMPDataItem = ^TMPDataItem;
  TMPDataItem = record
    FData: Pointer;                      //数据节点
    FNext: Pointer;                      //下一节点
    FUsed: Boolean;                      //是否使用
  end;

  TMPDataUsed = record
    FItem: PMPDataItem;                  //数据项
    FMain: PMPDataMain;                  //所在主项
    FUsed: Boolean;                      //是否使用
  end;

  TMPDataUsedItems = array of TMPDataUsed;

  TMemDataManager = class(TCommonObjectBase)
  private
    FLockCounter: Int64;
    //锁定计数
    FSerialBase: Word;
    //编码基数
    FDataList: TList;
    FDataUsed: TMPDataUsedItems;
    //数据列表
    FSyncLock: TCriticalSection;
    //同步锁定
  protected
    procedure ClearData(const nData: PMPDataMain);
    procedure ClearList(const nFree: Boolean);
    //清理数据
    procedure SetUsedFlag(const nItem,nMain: Pointer);
    //使用标记
    function GetDataByMain(const nMain: PMPDataMain): Pointer;
    //获取数据
    function FindDataMain(const nType: Word = 0;
     const nFlag: string = ''): Integer;
    //检索数据
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    function RegDataType(const nFlag,nDesc: string; const nNew: TMPDataNew;
     const nDispose: TMPDataDispose; const nNumOnce: Byte = 1): Word;
    procedure UnregType(const nType: Word); overload;
    procedure UnregType(const nFlag: string); overload;
    //注册释放
    function LockData(const nType: Word): Pointer; overload;
    function LockData(const nFlag: string): Pointer; overload;
    procedure UnLockData(const nData: Pointer);
    //锁定释放
    procedure EnumData(const nType: Word; const nFlag: string;
      const nCallback: TMPDataEnumCallback; const nResult: TList = nil);
    //枚举数据
    procedure GetStatus(const nList: TStrings); override;
    //获取状态
  end;

var
  gMemDataManager: TMemDataManager = nil;
  //全局使用

implementation

constructor TMemDataManager.Create;
begin
  inherited;
  FLockCounter := 0;
  FSerialBase := 0;

  SetLength(FDataUsed, 0);  
  FDataList := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TMemDataManager.Destroy;
begin
  ClearList(True);
  FSyncLock.Free;
  inherited;
end;

//Desc: 释放列表
procedure TMemDataManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
    nData: PMPDataMain;
begin
  for nIdx:=FDataList.Count - 1 downto 0 do
  begin
    nData := FDataList[nIdx];
    ClearData(nData);
    FDataList.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FDataList);
  //xxxxx
end;

//Desc: 清理nData主项
procedure TMemDataManager.ClearData(const nData: PMPDataMain);
var nIdx: Integer;
    nItem,nTmp: PMPDataItem;
begin
  nItem := nData.FDataFirst;
  if Assigned(nItem) then
  begin
    while True do
    begin
      nTmp := nItem;
      nItem := nItem.FNext;

      nData.FDataDispose(nData.FFlag, nData.FType, nTmp.FData);
      Dispose(nTmp);
      if not Assigned(nItem) then Break;
    end;
  end;

  for nIdx:=Low(FDataUsed) to High(FDataUsed) do
   if FDataUsed[nIdx].FMain = nData then
    FDataUsed[nIdx].FUsed := False;
  //撤销已用标记

  Dispose(nData);
  //释放主节点
end;

//Date: 2015-08-04
//Parm: 类型编号;类型标识
//Desc: 检索类型为nType的主项
function TMemDataManager.FindDataMain(const nType: Word;
 const nFlag: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FDataList.Count - 1 downto 0 do
  if ((nType > 0) and (PMPDataMain(FDataList[nIdx]).FType = nType)) or
     ((nFlag <> '') and (PMPDataMain(FDataList[nIdx]).FFlag = nFlag)) then
  begin
    Result := nIdx;
    Exit;
  end;
end;

//Date: 2015-08-04
//Parm: 标识;描述;创建,释放回调;每次分配个数
//Desc: 注册一个描述为nDesc的数据类型,返回类型编号
function TMemDataManager.RegDataType(const nFlag,nDesc: string;
  const nNew: TMPDataNew; const nDispose: TMPDataDispose;
  const nNumOnce: Byte): Word;
var nMain: PMPDataMain;
begin
  if not (Assigned(nNew) and Assigned(nDispose)) then
    raise Exception.Create(ClassName + ': New/Free Function Is Null.');
  //xxxxx

  if (nNumOnce < 1) or (nNumOnce > 220) then
    raise Exception.Create(ClassName + ': NumOnce Parameter Invalid.');
  //xxxxx

  if (nFlag <> '') and (FindDataMain(0, nFlag) > -1) then
    raise Exception.Create(ClassName + ': Flag Has Exists.');
  //xxxxx

  FSyncLock.Enter;
  try
    Inc(FSerialBase);
    Result := FSerialBase;

    New(nMain);
    FDataList.Add(nMain);
    FillChar(nMain^, SizeOf(TMPDataMain), #0);

    nMain.FType := Result;
    nMain.FFlag := nFlag;
    nMain.FDesc := nDesc;

    nMain.FNumOnce := nNumOnce;
    nMain.FDataNew := nNew;
    nMain.FDataDispose := nDispose;
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2015-08-04
//Parm: 类型编号
//Desc: 注销编号为nType的数据类型
procedure TMemDataManager.UnregType(const nType: Word);
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    nIdx := FindDataMain(nType);
    if nIdx > -1 then
    begin
      ClearData(FDataList[nIdx]);
      FDataList.Delete(nIdx);
    end;
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2015-08-05
//Parm: 类型标识
//Desc: 注销标识为nType的数据类型
procedure TMemDataManager.UnregType(const nFlag: string);
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    nIdx := FindDataMain(0, nFlag);
    if nIdx > -1 then
    begin
      ClearData(FDataList[nIdx]);
      FDataList.Delete(nIdx);
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2015-08-05
//Parm: 数据项;主项
//Desc: 在已用列表中,添加一项纪录
procedure TMemDataManager.SetUsedFlag(const nItem, nMain: Pointer);
var nIdx,nInt: Integer;

  procedure SetFlag;
  begin
    with FDataUsed[nIdx] do
    begin
      FUsed := True;
      FItem := nItem;
      FMain := nMain;

      FItem.FUsed := True;
      Dec(FMain.FNumFree);
    end;
  end;
begin
  for nIdx:=Low(FDataUsed) to High(FDataUsed) do
  if not FDataUsed[nIdx].FUsed then
  begin
    SetFlag;
    Exit;
  end;

  nInt := Length(FDataUsed);
  if nInt >= 10000 then
    raise Exception.Create(ClassName + ': DataUsed Array Is Full.');
  //xxxxx

  SetLength(FDataUsed, nInt + 10);
  for nIdx:=nInt to High(FDataUsed) do
    FDataUsed[nIdx].FUsed := False;
  //init flag

  nIdx := nInt;
  SetFlag;
end;

//Date: 2015-08-05
//Parm: 主项
//Desc: 返回nMain中的可用数据项
function TMemDataManager.GetDataByMain(const nMain: PMPDataMain): Pointer;
var nIdx: Integer;
    nItem: PMPDataItem;
begin
  Inc(FLockCounter);
  Inc(nMain.FNumLock);
  nItem := nMain.FDataFirst;

  while Assigned(nItem) do
  begin
    if not nItem.FUsed then
    begin
      SetUsedFlag(nItem, nMain);
      Result := nItem.FData;
      Exit;
    end;

    nItem := nItem.FNext;
    //next item
  end;

  if nMain.FNumAll >= High(Word) - nMain.FNumOnce then
    raise Exception.Create(ClassName + ': Data List Is Full.');
  //xxxxx

  for nIdx:=1 to nMain.FNumOnce do
  begin
    New(nItem);
    FillChar(nItem^, SizeOf(TMPDataItem), #0);

    nItem.FNext := nMain.FDataFirst; //插入空闲首项
    nMain.FDataFirst := nItem;
    nMain.FDataNew(nMain.FFlag, nMain.FType, nItem.FData);

    Inc(nMain.FNumAll);
    Inc(nMain.FNumFree);
  end;

  SetUsedFlag(nItem, nMain);
  Result := nItem.FData; //返回首项
end;

//Date: 2015-08-04
//Parm: 类型编号
//Desc: 返回类型为nType的一个数据项,从缓存中取空闲,或新分配
function TMemDataManager.LockData(const nType: Word): Pointer;
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    Result := nil;
    nIdx := FindDataMain(nType);

    if nIdx < 0 then
      raise Exception.Create(ClassName + ': Invalid Data Type.');
    Result := GetDataByMain(FDataList[nIdx]);
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2015-08-05
//Parm: 类型标记
//Desc: 返回标识为nFlag的一个数据项,从缓存中取空闲,或新分配
function TMemDataManager.LockData(const nFlag: string): Pointer;
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    Result := nil;
    nIdx := FindDataMain(0, nFlag);

    if nIdx < 0 then
      raise Exception.Create(ClassName + ': Invalid Data Flag.');
    Result := GetDataByMain(FDataList[nIdx]);
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2015-08-04
//Parm: 类型编号;数据项
//Desc: 将nData的状态置为空闲
procedure TMemDataManager.UnLockData(const nData: Pointer);
var nIdx: Integer;
begin
  if Assigned(nData) then
  try
    FSyncLock.Enter;
    //locked
    
    for nIdx:=Low(FDataUsed) to High(FDataUsed) do
     with FDataUsed[nIdx] do
      if FUsed and (FItem.FData = nData) then
      begin
        FUsed := False;
        FItem.FUsed := False;

        Inc(FMain.FNumFree);
        Exit;
      end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2015-11-19
//Parm: 类型编号;类型标识;回调;结果集
//Desc: 枚举编号为nType,或标识为nFlag的列表
procedure TMemDataManager.EnumData(const nType: Word; const nFlag: string; 
  const nCallback: TMPDataEnumCallback; const nResult: TList);
var nIdx: Integer;
    nItem: PMPDataItem;
begin
  FSyncLock.Enter;
  try
    if nType > 0 then
      nIdx := FindDataMain(nType) else
    if nFlag <> '' then
         nIdx := FindDataMain(0, nFlag)
    else nIdx := -1;
    if nIdx < 0 then Exit;

    nItem := PMPDataMain(FDataList[nIdx]).FDataFirst;
    while Assigned(nItem) do
    begin
      if nItem.FUsed and (not nCallback(nItem.FData, nResult)) then
        Break;
      nItem := nItem.FNext;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2015-08-05
//Parm: 结果列表
//Desc: 获取运行状态,存入nList中
procedure TMemDataManager.GetStatus(const nList: TStrings);
var nStr: string;
    nIdx: Integer;
    nMain: PMPDataMain;
begin
  FSyncLock.Enter;
  try
    nList.Add('DataUsed: ' + #9 + IntToStr(Length(FDataUsed)));
    nList.Add('LockCounter: ' + #9 + IntToStr(FLockCounter));
                                  
    for nIdx:=0 to FDataList.Count - 1 do
    begin
      nList.Add('');
      nMain := FDataList[nIdx];
      nStr := '%s.%s.%s:' + #9 + '%d';

      nList.Add(Format(nStr, [nMain.FFlag, nMain.FDesc, 'NumAll', nMain.FNumAll]));
      nList.Add(Format(nStr, [nMain.FFlag, nMain.FDesc, 'NumFree', nMain.FNumFree]));
      nList.Add(Format(nStr, [nMain.FFlag, nMain.FDesc, 'NumLock', nMain.FNumLock]));
    end;
  finally
    FSyncLock.Leave;
  end;
end;

initialization
  gMemDataManager := nil;
finalization
  FreeAndNil(gMemDataManager);
end.
