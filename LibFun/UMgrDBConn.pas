{*******************************************************************************
  作者: dmzn@163.com 2011-10-22
  描述: 数据库连接管理器

  备注:
  *.数据连接管理器,维护一组数据库连接参数,并动态分配连接对象.
  *.每组连接参数使用一个ID标识,存放于高速哈希表内.
  *.每组连接对象使用一个ID标识,表示到同一个数据库,含有多个工作对象.
  *.每组连接对应一个数据库,每个数组库对应N个Worker实际负责Connection,管理器
    负责
*******************************************************************************}
unit UMgrDBConn;

interface

uses
  ActiveX, ADODB, Classes, DB, Windows, SysUtils, SyncObjs, UMgrHashDict,
  UWaitItem, USysLoger, UBaseObject;

const
  cErr_GetConn_NoParam     = $0001;            //无连接参数
  cErr_GetConn_NoAllowed   = $0002;            //阻止申请
  cErr_GetConn_Closing     = $0003;            //连接正断开
  cErr_GetConn_MaxConn     = $0005;            //最大连接数
  cErr_GetConn_BuildFail   = $0006;            //构建失败

type
  PDBParam = ^TDBParam;
  TDBParam = record
    FID        : string;                       //参数标识
    FName      : string;                       //标识名称
    FHost      : string;                       //主机地址
    FPort      : Integer;                      //服务端口
    FDB        : string;                       //数据库名
    FUser      : string;                       //用户名
    FPwd       : string;                       //用户密码
    FConn      : string;                       //连接字符
    
    FEnable    : Boolean;                      //启用参数
    FNumWorker : Integer;                      //工作对象数
  end;

  PDBWorker = ^TDBWorker;
  TDBWorker = record
    FIdle : Boolean;                            //未分配
    FConn : TADOConnection;                     //连接对象
    FQuery: TADOQuery;                          //查询对象
    FExec : TADOQuery;                          //操作对象

    FWaiter: TWaitObject;                       //延迟对象
    FUsed : Integer;                            //排队计数
    FLock : TCriticalSection;                   //同步锁定

    FThreadID: THandle;                         //所在线程
    FCallNum: Integer;                          //调用计数
    FConnItem: Pointer;                         //所属连接项(专用)
  end;

  PDBConnItem = ^TDBConnItem;
  TDBConnItem = record
    FID   : string;                             //连接标识
    FUsed : Integer;                            //排队计数
    FLast : Cardinal;                           //上次使用
    FWorker: array of PDBWorker;                //工作对象
  end;

  PDBConnStatus = ^TDBConnStatus;
  TDBConnStatus = record
    FNumConnParam: Integer;                     //可连接数据库个数
    FNumConnItem: Integer;                      //连接组(数据库)个数
    FNumConnObj: Integer;                       //连接对象(Connection)个数
    FNumObjConned: Integer;                     //已连接对象(Connection)个数
    FNumObjReUsed: Cardinal;                    //对象重复使用次数
    FNumObjRequest: Cardinal;                   //连接请求总数
    FNumObjRequestErr: Cardinal;                //请求错误次数
    FNumObjWait: Integer;                       //排队中对象(Worker.FUsed)个数
    FNumWaitMax: Integer;                       //排队最多的组队列中对象个数
    FNumMaxTime: TDateTime;                     //排队最多时间
  end;

  TDBActionCallback = function (const nWorker: PDBWorker;
    const nData: Pointer): Boolean;
  TDBActionCallbackObj = function (const nWorker: PDBWorker;
    const nData: Pointer): Boolean of object;
  //回调函数

  TDBConnManager = class(TCommonObjectBase)
  private
    FWorkers: TList;
    //工作对象
    FConnDef: string;
    FConnItems: TList;
    //连接列表
    FParams: THashDictionary;
    //参数列表
    FConnClosing: Integer;
    FAllowedRequest: Integer;
    FSyncLock: TCriticalSection;
    //同步锁
    FStatus: TDBConnStatus;
    //运行状态
  protected
    procedure DoFreeDict(const nType: Word; const nData: Pointer);
    //释放字典
    procedure FreeDBConnItem(const nItem: PDBConnItem);
    procedure ClearConnItems(const nFreeMe: Boolean);
    //清理连接
    procedure ClearWorkers(const nFreeMe: Boolean);
    //清理对象
    procedure WorkerAction(const nWorker: PDBWorker; const nIdx: Integer = -1;
     const nFree: Boolean = True);
    function GetIdleWorker(const nLocked: Boolean): PDBWorker;
    //对象操作
    function CloseWorkerConnection(const nWorker: PDBWorker): Boolean;
    function CloseConnection(const nID: string; const nLock: Boolean): Integer;
    //关闭连接
    procedure DoAfterConnection(Sender: TObject);
    procedure DoAfterDisconnection(Sender: TObject);
    //时间绑定
    function GetRunStatus: TDBConnStatus;
    //读取状态
    function GetMaxConn: Integer;
    procedure SetMaxConn(const nValue: Integer);
    //设置连接数
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure AddParam(const nParam: TDBParam);
    procedure DelParam(const nID: string = '');
    procedure ClearParam;
    //参数管理
    function GetConnectionStr(const nID: string): string;
    class function MakeDBConnection(const nParam: TDBParam): string;
    //连接字符串
    function GetConnection(const nID: string; var nErrCode: Integer;
     const nThreadUnion: Boolean = False): PDBWorker;
    procedure ReleaseConnection(const nWorker: PDBWorker);
    //使用连接
    function Disconnection(const nID: string = ''): Integer;
    //断开连接
    function WorkerQuery(const nWorker: PDBWorker; const nSQL: string): TDataSet;
    function WorkerExec(const nWorker: PDBWorker; const nSQL: string): Integer;
    //操作连接
    function SQLQuery(const nSQL: string; var nWorker: PDBWorker;
      nID: string = ''): TDataSet;
    function ExecSQLs(const nSQLs: TStrings; const nTrans: Boolean;
      nID: string = ''): Boolean;
    function ExecSQL(const nSQL: string; nID: string = ''): Integer;
    //读写操作
    function DBAction(const nAction: TDBActionCallback;
      const nData: Pointer = nil; nID: string = ''): Boolean; overload;
    function DBAction(const nAction: TDBActionCallbackObj;
      const nData: Pointer = nil; nID: string = ''): Boolean; overload;
    //读写回调模式
    procedure GetStatus(const nList: TStrings); override;
    //对象状态
    property Status: TDBConnStatus read GetRunStatus;
    property MaxConn: Integer read GetMaxConn write SetMaxConn;
    property DefaultConnection: string read FConnDef write FConnDef;
    //属性相关
  end;

var
  gDBConnManager: TDBConnManager = nil;
  //全局使用

implementation

const
  cTrue  = $1101;
  cFalse = $1105;
  //常量定义

resourcestring
  sNoAllowedWhenRequest = '连接池对象释放时收到请求,已拒绝.';
  sClosingWhenRequest   = '连接池对象关闭时收到请求,已拒绝.';
  sNoParamWhenRequest   = '连接池对象收到请求,但无匹配参数.';
  sBuildWorkerFailure   = '连接池对象创建DBWorker失败.';

//------------------------------------------------------------------------------
//Desc: 记录日志
procedure WriteLog(const nMsg: string);
begin
  if Assigned(gSysLoger) then
    gSysLoger.AddLog(TDBConnManager, '数据库连接池', nMsg);
  //xxxxx
end;

constructor TDBConnManager.Create;
begin
  inherited;
  FConnClosing := cFalse;
  FAllowedRequest := cTrue;

  FConnDef := '';
  FConnItems := TList.Create;

  FWorkers := TList.Create;
  FSyncLock := TCriticalSection.Create;
  
  FParams := THashDictionary.Create(3);
  FParams.OnDataFree := DoFreeDict;
end;

destructor TDBConnManager.Destroy;
begin
  ClearConnItems(True);
  ClearWorkers(True);

  FParams.Free;
  FSyncLock.Free;
  inherited;
end;

//Desc: 获取最大连接数
function TDBConnManager.GetMaxConn: Integer;
begin
  Result := FWorkers.Count;
end;

//Desc: 设置最大工作对象对象数(启动前调用)
procedure TDBConnManager.SetMaxConn(const nValue: Integer);
var nIdx: Integer;
    nItem: PDBWorker;
begin
  FSyncLock.Enter;
  try
    if FWorkers.Count <= nValue then
    begin
      for nIdx:=FWorkers.Count to nValue-1  do
      begin
        New(nItem);
        FWorkers.Add(nItem);
        FillChar(nItem^, SizeOf(TDBWorker), #0);

        with nItem^ do
        begin
          if not Assigned(FConn) then
          begin
            FConn := TADOConnection.Create(nil);
            InterlockedIncrement(FStatus.FNumConnObj);

            with FConn do
            begin
              ConnectionTimeout := 7;
              LoginPrompt := False;
              AfterConnect := DoAfterConnection;
              AfterDisconnect := DoAfterDisconnection;
            end;
          end;

          if not Assigned(FQuery) then
          begin
            FQuery := TADOQuery.Create(nil);
            FQuery.Connection := FConn;
          end;

          if not Assigned(FExec) then
          begin
            FExec := TADOQuery.Create(nil);
            FExec.Connection := FConn;
          end;

          if not Assigned(FWaiter) then
          begin
            FWaiter := TWaitObject.Create;
            FWaiter.Interval := 2 * 10;
          end;

          if not Assigned(FLock) then
            FLock := TCriticalSection.Create;
          FIdle := True;
        end;
      end; //add

      Exit;
    end;

    try
      InterlockedExchange(FConnClosing, cTrue);
      //close flag

      for nIdx:=FWorkers.Count - 1 downto nValue do
        WorkerAction(nil, nIdx, True);
      //delete 
    finally
      InterlockedExchange(FConnClosing, cFalse);
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2012-4-1
//Parm: 工作对象;索引;释放,解锁
//Desc: 对nWorker或nIdx索引的对象做释放或锁定操作
procedure TDBConnManager.WorkerAction(const nWorker: PDBWorker;
 const nIdx: Integer; const nFree: Boolean);
var i: Integer;
    nItem: PDBWorker;
begin
  if Assigned(nWorker) then
       i := FWorkers.IndexOf(nWorker)
  else i := nIdx;

  if i < 0 then Exit;
  nItem := FWorkers[i];
  if not Assigned(nItem) then Exit;

  if not nFree then
  begin
    nItem.FIdle := True;
    nItem.FUsed := 0;
    Exit;
  end;

  with nItem^ do
  begin
    FreeAndNil(FQuery);
    FreeAndNil(FExec);
    FreeAndNil(FConn);
    FreeAndNil(FLock);
    FreeAndNil(FWaiter);
  end;

  Dispose(nItem);
  FWorkers.Delete(nIdx);
end;

//Desc: 获取空闲对象
function TDBConnManager.GetIdleWorker(const nLocked: Boolean): PDBWorker;
var nIdx: Integer;
    nItem: PDBWorker;
begin
  Result := nil;

  for nIdx:=FWorkers.Count - 1 downto 0 do
  begin
    nItem := FWorkers[nIdx];
    if not nItem.FIdle then Continue;

    nItem.FIdle := not nLocked;
    Result := nItem;
    Break;
  end;
end;

//Desc: 清空工作对象组
procedure TDBConnManager.ClearWorkers(const nFreeMe: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FWorkers.Count - 1 downto 0 do
    WorkerAction(nil, nIdx, True);
  //clear

  if nFreeMe then
    FWorkers.Free;
  //free
end;

//Desc: 释放字典项
procedure TDBConnManager.DoFreeDict(const nType: Word; const nData: Pointer);
begin
  Dispose(PDBParam(nData));
end;

//Desc: 释放连接对象
procedure TDBConnManager.FreeDBConnItem(const nItem: PDBConnItem);
var nIdx: Integer;
begin
  for nIdx:=Low(nItem.FWorker) to High(nItem.FWorker) do
  begin
    WorkerAction(nItem.FWorker[nIdx], -1, False);
    nItem.FWorker[nIdx] := nil;
  end;

  Dispose(nItem);
end;

//Desc: 清理连接对象
procedure TDBConnManager.ClearConnItems(const nFreeMe: Boolean);
var nIdx: Integer;
begin
  if nFreeMe then
    InterlockedExchange(FAllowedRequest, cFalse);
  //请求关闭

  FSyncLock.Enter;
  try
    CloseConnection('', False);
    //断开全部连接

    for nIdx:=FConnItems.Count - 1 downto 0 do
    begin
      FreeDBConnItem(FConnItems[nIdx]);
      FConnItems.Delete(nIdx);
    end;

    if nFreeMe then
      FreeAndNil(FConnItems);
    FillChar(FStatus, SizeOf(FStatus), #0);
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 断开到数据库的连接
function TDBConnManager.Disconnection(const nID: string): Integer;
begin
  Result := CloseConnection(nID, True);
end;

//Desc: 断开nWorker的数据连接,断开成功返回True.
function TDBConnManager.CloseWorkerConnection(const nWorker: PDBWorker): Boolean;
begin
  //让出锁,等待工作对象释放
  FSyncLock.Leave;
  try
    while nWorker.FUsed > 0 do
      nWorker.FWaiter.EnterWait;
    //等待队列退出
  finally
    FSyncLock.Enter;
  end;

  try
    nWorker.FConn.Connected := False;
  except
    //ignor any error
  end;

  Result := not nWorker.FConn.Connected;
end;

//Desc: 关闭指定连接,返回关闭个数.
function TDBConnManager.CloseConnection(const nID: string;
  const nLock: Boolean): Integer;
var nIdx,nInt: Integer;
    nItem: PDBConnItem;
begin
  Result := 0;
  if InterlockedExchange(FConnClosing, cTrue) = cTrue then Exit;

  if nLock then FSyncLock.Enter;
  try
    for nIdx:=FConnItems.Count - 1 downto 0 do
    begin
      nItem := FConnItems[nIdx];
      if (nID <> '') and (CompareText(nItem.FID, nID) <> 0) then Continue;

      nItem.FUsed := 0;
      //重置计数

      for nInt:=Low(nItem.FWorker) to High(nItem.FWorker) do
      if Assigned(nItem.FWorker[nInt]) then
      begin
        if CloseWorkerConnection(nItem.FWorker[nInt]) then
          Inc(Result);
        nItem.FWorker[nInt].FUsed := 0;
      end;
    end;
  finally
    InterlockedExchange(FConnClosing, cFalse);
    if nLock then FSyncLock.Leave;
  end;
end;

//Desc: 数据连接成功
procedure TDBConnManager.DoAfterConnection(Sender: TObject);
begin
  InterlockedIncrement(FStatus.FNumObjConned);
end;

//Desc: 数据断开成功
procedure TDBConnManager.DoAfterDisconnection(Sender: TObject);
begin
  InterlockedDecrement(FStatus.FNumObjConned);
end;

//------------------------------------------------------------------------------
//Desc: 生成本方或数据库连接
class function TDBConnManager.MakeDBConnection(const nParam: TDBParam): string;
begin
  with nParam do
  begin
    Result := FConn;
    Result := StringReplace(Result, '$DBName', FDB, [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '$Host', FHost, [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '$User', FUser, [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '$Pwd', FPwd, [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '$Port', IntToStr(FPort), [rfReplaceAll, rfIgnoreCase]);
  end;
end;

//Desc: 添加参数
procedure TDBConnManager.AddParam(const nParam: TDBParam);
var nPtr: PDBParam;
    nData: PDictData;
begin
  if nParam.FID = '' then Exit;

  FSyncLock.Enter;
  try
    nData := FParams.FindItem(nParam.FID);
    if not Assigned(nData) then
    begin
      New(nPtr);
      FParams.AddItem(nParam.FID, nPtr, 0, False);
      Inc(FStatus.FNumConnParam);
    end else nPtr := nData.FData;

    nPtr^ := nParam;
    nPtr.FConn := MakeDBConnection(nParam);

    if nPtr.FNumWorker < 1 then
      nPtr.FNumWorker := 3;
    //xxxxx

    if FConnDef = '' then
      FConnDef := nParam.FID;
    //first is default
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 删除参数
procedure TDBConnManager.DelParam(const nID: string);
begin
  FSyncLock.Enter;
  try
    if FParams.DelItem(nID) then
      Dec(FStatus.FNumConnParam);
    //xxxxx
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 清理参数
procedure TDBConnManager.ClearParam;
begin
  FSyncLock.Enter;
  try
    FParams.ClearItem;
    FStatus.FNumConnParam := 0;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 获取nID参数的连接字符串
function TDBConnManager.GetConnectionStr(const nID: string): string;
var nPtr: PDBParam;
    nData: PDictData;
begin
  FSyncLock.Enter;
  try
    nData := FParams.FindItem(nID);
    if Assigned(nData) then
    begin
      nPtr := nData.FData;
      Result := nPtr.FConn;
    end else Result := '';
  finally
    FSyncLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2011-10-23
//Parm: 连接标识;错误码;同线程使用相同链路
//Desc: 返回nID可用的数据连接对象
function TDBConnManager.GetConnection(const nID: string; var nErrCode: Integer;
 const nThreadUnion: Boolean): PDBWorker;
var nIdx: Integer;
    nParam: PDictData;
    nWorker: PDBWorker;
    nItem,nIdle,nTmp: PDBConnItem;
begin
  Result := nil;
  nErrCode := cErr_GetConn_NoAllowed;

  if FAllowedRequest = cFalse then
  begin
    WriteLog(sNoAllowedWhenRequest);
    Exit;
  end;

  nErrCode := cErr_GetConn_Closing;
  if FConnClosing = cTrue then
  begin
    WriteLog(sClosingWhenRequest);
    Exit;
  end;

  FSyncLock.Enter;
  try
    nErrCode := cErr_GetConn_NoAllowed;
    if FAllowedRequest = cFalse then
    begin
      WriteLog(sNoAllowedWhenRequest);
      Exit;
    end;

    nErrCode := cErr_GetConn_Closing;
    if FConnClosing = cTrue then
    begin
      WriteLog(sClosingWhenRequest);
      Exit;
    end;
    //重复判定,避免Get和close锁定机制重叠(get.enter在close.enter后面进入等待)

    Inc(FStatus.FNumObjRequest);
    nErrCode := cErr_GetConn_NoParam;
    nParam := FParams.FindItem(nID);
    
    if not Assigned(nParam) then
    begin
      WriteLog(sNoParamWhenRequest);
      Exit;
    end;

    //--------------------------------------------------------------------------
    nItem := nil;
    nIdle := nil;

    for nIdx:=FConnItems.Count - 1 downto 0 do
    begin
      nTmp := FConnItems[nIdx];
      if CompareText(nID, nTmp.FID) = 0 then
      begin
        nItem := nTmp; Break;
      end;

      if nTmp.FUsed < 1 then
       if (not Assigned(nIdle)) or (nIdle.FLast > nTmp.FLast) then
        nIdle := nTmp;
      //空闲时间最长连接
    end;

    if not Assigned(nItem) then
    begin
      nWorker := GetIdleWorker(False);
      if (not Assigned(nIdle)) and (not Assigned(nWorker)) then
      begin
        nErrCode := cErr_GetConn_MaxConn; Exit;
      end;

      if Assigned(nWorker) then
      begin
        New(nItem);
        FConnItems.Add(nItem);
        Inc(FStatus.FNumConnItem);

        nItem.FID := nID;
        nItem.FUsed := 0;
        SetLength(nItem.FWorker, PDBParam(nParam.FData).FNumWorker);

        for nIdx:=Low(nItem.FWorker) to High(nItem.FWorker) do
          nItem.FWorker[nIdx] := nil;
        //xxxxx
      end else
      begin
        nItem := nIdle;
        nItem.FID := nID;
        nItem.FUsed := 1;

        try
          for nIdx:=Low(nItem.FWorker) to High(nItem.FWorker) do
           if Assigned(nItem.FWorker[nIdx]) then
            CloseWorkerConnection(nItem.Fworker[nIdx]);
          Inc(FStatus.FNumObjReUsed);
        finally
          nItem.FUsed := 0;
        end;
      end;
    end;

    //--------------------------------------------------------------------------
    with nItem^ do
    begin
      for nIdx:=Low(FWorker) to High(FWorker) do
      begin
        if (Assigned(FWorker[nIdx])) and
           (FWorker[nIdx].FThreadID > 0) and
           (FWorker[nIdx].FThreadID = GetCurrentThreadId) then
        begin
          Result := FWorker[nIdx];
          Inc(Result.FCallNum);
          Break;
        end;
      end; //优先扫描同线程链路

      if not Assigned(Result) then
      begin
        for nIdx:=Low(FWorker) to High(FWorker) do
        begin
          if Assigned(FWorker[nIdx]) then
          begin
            if FWorker[nIdx].FUsed < 1 then
            begin
              Result := FWorker[nIdx];
              Break;
            end;

            //排队最少的工作对象
            if (not Assigned(Result)) or
               (FWorker[nIdx].FUsed < Result.FUsed) then
            begin
              Result := FWorker[nIdx];
            end;
          end else
          begin
            Result := GetIdleWorker(True);
            FWorker[nIdx] := Result;
            if Assigned(Result) then Break;
          end; //新工作对象
        end;
      end; //扫描空闲链路

      if Assigned(Result) then
      begin
        Inc(Result.FUsed);
        Inc(nItem.FUsed);
        Inc(FStatus.FNumObjWait);

        if nThreadUnion and (Result.FThreadID < 1) then
        begin
          Inc(Result.FCallNum);
          Result.FThreadID := GetCurrentThreadId;
        end;
        {-----------------------------------------------------------------------
        原理:
        1.调用方设置Worker所在的ThreadID.
        2.由于被调用方优先检索同线程的Worker,检索成功后增加调用计数.
        3.调用方使用完毕后,删除ThreadID.
        -----------------------------------------------------------------------}

        if nItem.FUsed > FStatus.FNumWaitMax then
        begin
          FStatus.FNumWaitMax := nItem.FUsed;
          FStatus.FNumMaxTime := Now;
        end;

        if not Result.FConn.Connected then
          Result.FConn.ConnectionString := PDBParam(nParam.FData).FConn;
        Result.FConnItem := nItem;
      end;
    end;
  finally
    if not Assigned(Result) then
      Inc(FStatus.FNumObjRequestErr);
    FSyncLock.Leave;
  end;

  if Assigned(Result) then
  with Result^ do
  begin
    if Result.FCallNum <= 1 then
      FLock.Enter;
    //工作对象进入排队

    if FConnClosing = cTrue then
    try
      Result := nil;
      nErrCode := cErr_GetConn_Closing;

      InterlockedDecrement(FUsed);
      InterlockedDecrement(FStatus.FNumObjWait);
      FWaiter.Wakeup;
    finally
      FLock.Leave;
    end;

    if Result.FCallNum <= 1 then
      CoInitialize(nil);
    //初始化COM对象
  end;
end;

//Date: 2011-10-23
//Parm: 数据对象
//Desc: 释放nWorker连接对象
procedure TDBConnManager.ReleaseConnection(const nWorker: PDBWorker);
var nItem: PDBConnItem;
begin
  if not Assigned(nWorker) then Exit;
  //invalid worker to release

  FSyncLock.Enter;
  try
    if nWorker.FCallNum > 0 then
      Dec(nWorker.FCallNum);
    //同线程调用计数

    if nWorker.FCallNum < 1 then
    try
      nWorker.FThreadID := 0;
      //同线程调用结束,删除线程标识
      
      if nWorker.FQuery.Active then
        nWorker.FQuery.Close;
      //xxxxx
    except
      on E:Exception do
      begin
        WriteLog(E.Message);
      end;
    end;

    nItem := nWorker.FConnItem;
    Dec(nItem.FUsed);
    nItem.FLast := GetTickCount;

    Dec(nWorker.FUsed);
    if nWorker.FCallNum < 1 then
      nWorker.FLock.Leave;
    Dec(FStatus.FNumObjWait);

    if FConnClosing = cTrue then
      nWorker.FWaiter.Wakeup;
    //xxxxx
  finally
    if nWorker.FCallNum < 1 then
      CoUnInitialize; //释放COM对象    
    FSyncLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 读取运行状态
function TDBConnManager.GetRunStatus: TDBConnStatus;
begin
  FSyncLock.Enter;
  try
    Result := FStatus;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 执行写操作语句
function TDBConnManager.WorkerExec(const nWorker: PDBWorker;
  const nSQL: string): Integer;
var nStep: Integer;
    nException: string;
begin
  Result := -1;
  nException := '';
  nStep := 0;

  while nStep <= 2 do
  try
    if nStep = 1 then
    begin
      nWorker.FQuery.Close;
      nWorker.FQuery.SQL.Text := 'select 1';
      nWorker.FQuery.Open;

      nWorker.FQuery.Close;
      Break;
      //connection is ok
    end else

    if nStep = 2 then
    begin
      nWorker.FConn.Close;
      nWorker.FConn.Open;
    end; //reconnnect
           
    nWorker.FExec.Close;
    nWorker.FExec.SQL.Text := nSQL;
    Result := nWorker.FExec.ExecSQL;

    nException := '';
    Break;
  except
    on E:Exception do
    begin
      Inc(nStep);
      nException := E.Message;
    end;
  end;

  if nException <> '' then
  begin
    WriteLog('SQL: ' + nSQL + ' ::: ' + nException);
    raise Exception.Create(nException);
  end;
end;

//Desc: 执行查询语句
function TDBConnManager.WorkerQuery(const nWorker: PDBWorker;
  const nSQL: string): TDataSet;
var nStep: Integer;
    nException: string;
begin
  Result := nWorker.FQuery;
  nException := '';
  nStep := 0;

  while nStep <= 2 do
  try
    if nStep = 1 then
    begin
      nWorker.FQuery.Close;
      nWorker.FQuery.SQL.Text := 'select 1';
      nWorker.FQuery.Open;

      nWorker.FQuery.Close;
      Break;
      //connection is ok
    end else

    if nStep = 2 then
    begin
      nWorker.FConn.Close;
      nWorker.FConn.Open;
    end; //reconnnect
    
    nWorker.FQuery.Close;
    nWorker.FQuery.SQL.Text := nSQL;
    nWorker.FQuery.Open;

    nException := '';
    Break;
  except
    on E:Exception do
    begin
      Inc(nStep);
      nException := E.Message;
    end;
  end;

  if nException <> '' then
  begin
    WriteLog('SQL: ' + nSQL + ' ::: ' + nException);
    raise Exception.Create(nException);
  end;
end;

//Date: 2013-07-26
//Parm: 语句;工作对象;连接标识
//Desc: 在nID数据库上执行nSQL查询,返回结果.需手动释放nWorker.
function TDBConnManager.SQLQuery(const nSQL: string; var nWorker: PDBWorker;
  nID: string): TDataSet;
var nErrNum: Integer;
begin
  if nID = '' then
    nID := FConnDef;
  nWorker := GetConnection(nID, nErrNum);

  if not Assigned(nWorker) then
  begin
    nID := Format('连接[ %s ]数据库失败(ErrCode: %d).', [nID, nErrNum]);
    WriteLog(nID);
    raise Exception.Create(nID);
  end;

  if not nWorker.FConn.Connected then
    nWorker.FConn.Connected := True;
  //conn db

  Result := WorkerQuery(nWorker, nSQL);
  //do query
end;

//Date: 2013-07-23
//Parm: 语句;连接标识
//Desc: 在nID数据库上执行nSQL语句
function TDBConnManager.ExecSQL(const nSQL: string; nID: string): Integer;
var nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  try
    Result := -1;
    if nID = '' then nID := FConnDef;
    nDBConn := GetConnection(nID, nErrNum);

    if not Assigned(nDBConn) then
    begin
      nID := Format('连接[ %s ]数据库失败(ErrCode: %d).', [nID, nErrNum]);
      WriteLog(nID);
      raise Exception.Create(nID);
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    Result := WorkerExec(nDBConn, nSQL);
    //do exec
  finally
    ReleaseConnection(nDBConn);
  end;
end;

//Date: 2013-07-23
//Parm: 语句列表;是否事务;连接标识
//Desc: 在nID数据库上执行nSQLs语句
function TDBConnManager.ExecSQLs(const nSQLs: TStrings; const nTrans: Boolean;
  nID: string): Boolean;
var nIdx: Integer;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  try
    Result := False;
    if nID = '' then nID := FConnDef;
    nDBConn := GetConnection(nID, nErrNum);

    if not Assigned(nDBConn) then
    begin
      nID := Format('连接[ %s ]数据库失败(ErrCode: %d).', [nID, nErrNum]);
      WriteLog(nID);
      raise Exception.Create(nID);
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    if nTrans then
      nDBConn.FConn.BeginTrans;
    //trans
    try
      for nIdx:=0 to nSQLs.Count - 1 do
        WorkerExec(nDBConn, nSQLs[nIdx]);
      //execute sql list

      if nTrans then
        nDBConn.FConn.CommitTrans;
      Result := True;
    except
      on E:Exception do
      begin
        if nTrans then
          nDBConn.FConn.RollbackTrans;
        WriteLog('SQL: ' + nSQLs.Text + ' ::: ' + E.Message);
      end;
    end;
  finally
    ReleaseConnection(nDBConn);
  end;
end;

//Date: 2013-07-27
//Parm: 动作;数据;连接标识
//Desc: 在nID数据库上执行nAction定义的业务
function TDBConnManager.DBAction(const nAction: TDBActionCallback;
  const nData: Pointer; nID: string): Boolean;
var nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  try
    Result := False;
    if nID = '' then nID := FConnDef;
    nDBConn := GetConnection(nID, nErrNum);

    if not Assigned(nDBConn) then
    begin
      nID := Format('连接[ %s ]数据库失败(ErrCode: %d).', [nID, nErrNum]);
      WriteLog(nID);
      raise Exception.Create(nID);
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    Result := nAction(nDBConn, nData);
    //do action
  finally
    ReleaseConnection(nDBConn);
  end;
end;

//Date: 2013-07-27
//Parm: 动作;连接标识
//Desc: 在nID数据库上执行nAction定义的业务
function TDBConnManager.DBAction(const nAction: TDBActionCallbackObj;
  const nData: Pointer; nID: string): Boolean;
var nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  try
    Result := False;
    if nID = '' then nID := FConnDef;
    nDBConn := GetConnection(nID, nErrNum);

    if not Assigned(nDBConn) then
    begin
      nID := Format('连接[ %s ]数据库失败(ErrCode: %d).', [nID, nErrNum]);
      WriteLog(nID);
      raise Exception.Create(nID);
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    Result := nAction(nDBConn, nData);
    //do action
  finally
    ReleaseConnection(nDBConn);
  end;
end;

procedure TDBConnManager.GetStatus(const nList: TStrings);
begin
  with GetRunStatus do
  begin
    nList.Add('NumConnParam: ' + #9 + IntToStr(FNumConnParam));
    nList.Add('NumConnItem: ' + #9 + IntToStr(FNumConnItem));
    nList.Add('NumConnObj: ' + #9 + IntToStr(FNumConnObj));
    nList.Add('NumObjConned: ' + #9 + IntToStr(FNumObjConned));
    nList.Add('NumObjReUsed: ' + #9 + IntToStr(FNumObjReUsed));
    nList.Add('NumObjRequest: ' + #9 + IntToStr(FNumObjRequest));
    nList.Add('NumObjReqErr: ' + #9 + IntToStr(FNumObjRequestErr));
    nList.Add('NumObjWait: ' + #9 + IntToStr(FNumObjWait));
    nList.Add('NumWaitMax: ' + #9 + IntToStr(FNumWaitMax));
    nList.Add('NumMaxTime: ' + #9 + DateTimeToStr(FNumMaxTime));
  end;
end;

initialization
  gDBConnManager := nil;
finalization
  FreeAndNil(gDBConnManager);
end.
