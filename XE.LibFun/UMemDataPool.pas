{*******************************************************************************
  作者: dmzn@163.com 2017-04-15
  描述: 管理new/getmem分配的内存数据项

  备注:
  *.使用方法:
    1.NewType: 注册数据类型.
    2.LockData: 锁定数据,管理器会检索缓冲池,有空闲则返回,无空闲则创建.
    3.Release: 释放锁定,与LockData配对使用.
  *.由于LockData带有一些逻辑,比直接new/getmem操作慢很多.管理器的意义,在于简化
    内存调用,提供应用的内存分配状体,减少内存碎片(可能).
  *.线程安全.
*******************************************************************************}
unit UMemDataPool;

interface

uses
  System.Classes, System.SysUtils, UBaseObject;

type
  TMPDataNew = reference to function(): Pointer;
  //分配内存回调
  TMPDataDispose = reference to procedure (const nData: Pointer);
  //释放内存回调

  PMPDataMain = ^TMPDataMain;
  TMPDataMain = record
    FType: Int64;                        //数据类型
    FFlag: string;                       //数据表示
    FDesc: string;                       //类型描述
    FNumOnce: Byte;                      //单次分配
    FNumAll: Cardinal;                   //总数量
    FNumLocked: Cardinal;                //已锁定
    FNumLockAll: Int64;                  //请求次数

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

  TMemDataManager = class(TManagerBase)
  private const
    cDataUsedMax = 10000;
    //缓冲列表大小
  private
    FNumLocked: Int64;
    FNumLockAll: Int64;
    //锁定计数
    FDataList: TList;
    FDataUsed: TMPDataUsedItems;
    //数据列表
    FSrvClosed: Integer;
    //服务关闭 
  protected
    procedure ClearData(const nData: PMPDataMain);
    procedure ClearList(const nFree: Boolean);
    //清理数据
    procedure SetUsedFlag(const nItem,nMain: Pointer);
    //使用标记
    function GetDataByMain(const nMain: PMPDataMain): Pointer;
    //获取数据
    function FindDataMain(const nType: Int64 = 0;
     const nFlag: string = ''): Integer;
    //检索数据
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    class procedure RegistMe(const nReg: Boolean); override;
    //注册管理器    
    function NewType(const nFlag,nDesc: string; const nNew: TMPDataNew;
     const nDispose: TMPDataDispose; const nNumOnce: Byte = 1): Int64;
    procedure DeleteType(const nType: Int64); overload;
    procedure DeleteType(const nFlag: string); overload;
    //注册释放
    function LockData(const nType: Int64): Pointer; overload;
    function LockData(const nFlag: string): Pointer; overload;
    procedure Release(const nData: Pointer);
    //锁定释放 
    procedure GetStatus(const nList: TStrings;
      const nFriendly: Boolean = True); override;
    function GetHealth(const nList: TStrings = nil): TObjectHealth; override;
    //获取状态 
  end;

var
  gMemDataManager: TMemDataManager = nil;
  //全局使用

implementation

uses
  UManagerGroup;

const
  cYes  = $0002;
  cNo   = $0005;
  
constructor TMemDataManager.Create;
begin
  inherited; 
  FNumLocked := 0;
  FNumLockAll := 0;

  FSrvClosed := cNo;                    
  SetLength(FDataUsed, 0);  
  FDataList := TList.Create;
end;

destructor TMemDataManager.Destroy;
begin
  SyncEnter;
  FSrvClosed := cYes; //set close flag  
  SyncLeave;
  
  if FNumLocked > 0 then
  begin
    while FNumLocked > 0 do
      Sleep(1);
    //wait for relese
  end;
  
  ClearList(True);
  inherited;
end;

//Date: 2017-04-15
//Parm: 是否注册
//Desc: 向系统注册管理器对象
class procedure TMemDataManager.RegistMe(const nReg: Boolean);
var nIdx: Integer;
begin
  nIdx := GetMe(TMemDataManager);
  if nReg then
  begin     
    if not Assigned(FManagers[nIdx].FManager) then
      FManagers[nIdx].FManager := TMemDataManager.Create;
    gMG.FMemDataManager := FManagers[nIdx].FManager as TMemDataManager; 
  end else
  begin
    gMG.FMemDataManager := nil;
    FreeAndNil(FManagers[nIdx].FManager);    
  end;
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

      nData.FDataDispose(nTmp.FData);
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

//Date: 2017-04-14
//Parm: 类型编号;类型标识
//Desc: 检索类型为nType的主项
function TMemDataManager.FindDataMain(const nType: Int64;
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

//Date: 2017-04-14
//Parm: 标识;描述;创建,释放回调;每次分配个数
//Desc: 注册一个描述为nDesc的数据类型,返回类型编号
function TMemDataManager.NewType(const nFlag,nDesc: string;
  const nNew: TMPDataNew; const nDispose: TMPDataDispose;
  const nNumOnce: Byte): Int64;
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
                      
  gMG.CheckSupport(ClassName, 'FSerialIDManager', gMG.FSerialIDManager);
  //check manager

  SyncEnter;
  try
    Result := gMG.FSerialIDManager.GetID;
    //serial id

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
    SyncLeave;
  end;   
end;

//Date: 2017-04-15
//Parm: 类型编号
//Desc: 注销编号为nType的数据类型
procedure TMemDataManager.DeleteType(const nType: Int64);
var nIdx: Integer;
begin
  SyncEnter;
  try
    nIdx := FindDataMain(nType);
    if nIdx > -1 then
    begin
      ClearData(FDataList[nIdx]);
      FDataList.Delete(nIdx);
    end;
  finally
    SyncLeave;
  end;   
end;

//Date: 2017-04-15
//Parm: 类型标识
//Desc: 注销标识为nType的数据类型
procedure TMemDataManager.DeleteType(const nFlag: string);
var nIdx: Integer;
begin
  SyncEnter;
  try
    nIdx := FindDataMain(0, nFlag);
    if nIdx > -1 then
    begin
      ClearData(FDataList[nIdx]);
      FDataList.Delete(nIdx);
    end;
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-15
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
      Inc(FMain.FNumLocked);
      Inc(Self.FNumLocked);
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
  if nInt >= cDataUsedMax then
    raise Exception.Create(ClassName + ': DataUsed Array Is Full.');
  //xxxxx

  SetLength(FDataUsed, nInt + 10);
  for nIdx:=nInt to High(FDataUsed) do
    FDataUsed[nIdx].FUsed := False;
  //init flag

  nIdx := nInt;
  SetFlag;
end;

//Date: 2017-04-15
//Parm: 主项
//Desc: 返回nMain中的可用数据项
function TMemDataManager.GetDataByMain(const nMain: PMPDataMain): Pointer;
var nIdx: Integer;
    nItem: PMPDataItem;
begin
  if FNumLockAll < High(Int64) then  
       Inc(FNumLockAll)
  else FNumLockAll := 1;
  
  if nMain.FNumLockAll < High(Int64) then  
       Inc(nMain.FNumLockAll)
  else nMain.FNumLockAll := 1;
  
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

  if nMain.FNumAll >= High(Cardinal) - nMain.FNumOnce then
    raise Exception.Create(ClassName + ': Data List Is Full.');
  //xxxxx

  for nIdx:=1 to nMain.FNumOnce do
  begin
    New(nItem);
    FillChar(nItem^, SizeOf(TMPDataItem), #0);

    nItem.FNext := nMain.FDataFirst; //插入空闲首项
    nMain.FDataFirst := nItem;
    nItem.FData := nMain.FDataNew();

    Inc(nMain.FNumAll);
    //+1
  end;

  SetUsedFlag(nItem, nMain);
  Result := nItem.FData; //返回首项
end;

//Date: 2017-04-15
//Parm: 类型编号
//Desc: 返回类型为nType的一个数据项,从缓存中取空闲,或新分配
function TMemDataManager.LockData(const nType: Int64): Pointer;
var nIdx: Integer;
begin
  SyncEnter;
  try
    Result := nil;
    if FSrvClosed = cYes then
      raise Exception.Create(ClassName + ': Not Support "Lock" When Closing.');
    //pool will close
    
    
    nIdx := FindDataMain(nType);
    if nIdx < 0 then
      raise Exception.Create(ClassName + ': Invalid Data Type.');
    Result := GetDataByMain(FDataList[nIdx]);
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-15
//Parm: 类型标记
//Desc: 返回标识为nFlag的一个数据项,从缓存中取空闲,或新分配
function TMemDataManager.LockData(const nFlag: string): Pointer;
var nIdx: Integer;
begin
  SyncEnter;
  try
    Result := nil;
    if FSrvClosed = cYes then
      raise Exception.Create(ClassName + ': Not Support "Lock" When Closing.');
    //pool will close

    nIdx := FindDataMain(0, nFlag); 
    if nIdx < 0 then
      raise Exception.Create(ClassName + ': Invalid Data Flag.');
    Result := GetDataByMain(FDataList[nIdx]);
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-15
//Parm: 类型编号;数据项
//Desc: 将nData的状态置为空闲
procedure TMemDataManager.Release(const nData: Pointer);
var nIdx: Integer;
begin
  if not Assigned(nData) then Exit;
  //not match
  
  SyncEnter;
  try    
    for nIdx:=Low(FDataUsed) to High(FDataUsed) do
     with FDataUsed[nIdx] do
      if FUsed and (FItem.FData = nData) then
      begin
        FUsed := False;
        FItem.FUsed := False;

        Dec(FMain.FNumLocked);
        Dec(Self.FNumLocked);
        Exit;
      end;
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-15
//Parm: 列表;是否友好显示
//Desc: 将管理器状态数据存入nList中
procedure TMemDataManager.GetStatus(const nList: TStrings; 
  const nFriendly: Boolean);
var nIdx: Integer;
    nMain: PMPDataMain;
begin
  with TObjectStatusHelper do
  try
    SyncEnter;
    inherited GetStatus(nList, nFriendly);
    
    if not nFriendly then
    begin
      nList.Add('DataUsed=' + Length(FDataUsed).ToString);
      nList.Add('NumLocked=' +  FNumLocked.ToString);
      nList.Add('NumLockAll=' + FNumLockAll.ToString);
      Exit;
    end;
    
    nList.Add(FixData('DataUsed:', Length(FDataUsed).ToString));
    nList.Add(FixData('NumLocked:', FNumLocked));
    nList.Add(FixData('NumLockAll:', FNumLockAll));
                                  
    for nIdx:=0 to FDataList.Count - 1 do
    begin
      nList.Add('');
      nMain := FDataList[nIdx];

      nList.Add(FixData(nMain.FFlag + '.' + 
                        nMain.FDesc + '.NumAll', nMain.FNumAll));
      nList.Add(FixData(nMain.FFlag + '.' + 
                        nMain.FDesc + '.NumLocked', nMain.FNumLocked));
      nList.Add(FixData(nMain.FFlag + '.' + 
                        nMain.FDesc + '.NumLockAll', nMain.FNumLockAll));
      //xxxxx
    end;
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-16
//Desc: 获取管理器健康度 
function TMemDataManager.GetHealth(const nList: TStrings): TObjectHealth;
var nStr: string;
    nInt: Integer;
begin
  SyncEnter;
  try
    Result := hlNormal;
    nInt := Length(FDataUsed);
     
    if ((nInt >= cDataUsedMax / 2) and (nInt < cDataUsedMax - 500)) and 
        (Result < hlLow) then
    begin
      if Assigned(nList) then
      begin
        nStr := '缓冲区[DataUsed: %d%%]占用过高.';
        nList.Add(Format(nStr, [Trunc(nInt / cDataUsedMax) * 100]));
      end;
        
      Result := hlLow;
    end;        

    if (nInt >= cDataUsedMax - 500) and (Result < hlBad) then
    begin
      if Assigned(nList) then
      begin
        nStr := '缓冲区[DataUsed: %d%%]已不足.';
        nList.Add(Format(nStr, [Trunc(nInt / cDataUsedMax) * 100]));
      end;

      Result := hlBad;
    end;
      

    if (FNumLocked >= cDataUsedMax / 10) and (Result < hlLow) then
    begin
      if Assigned(nList) then
      begin
        nStr := '已锁定对象[NumLocked: %d]过多,等待释放.';
        nList.Add(Format(nStr, [FNumLocked]));
      end;

      Result := hlLow;
    end;

    if (FNumLocked >= cDataUsedMax / 2) and (Result < hlBad) then
    begin
      if Assigned(nList) then
      begin
        nStr := '已锁定对象[NumLocked: %d]达到警戒值,请检查释放逻辑.';
        nList.Add(Format(nStr, [FNumLocked]));
      end;

      Result := hlBad;
    end;
  finally
    SyncLeave;
  end;
end;

initialization
  //nothing
finalization
  //nothing
end.
