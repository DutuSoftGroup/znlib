{*******************************************************************************
  作者: dmzn@163.com 2012-2-13
  描述: SAP连接管理对象

  备注:
  *.SAPConnectionManager用于动态分配系统到SAP的连接.
  *.在连接数受限的情况下,管理器对请求进行排队;否则直接创建新连接.
  *.管理器会保持一个长连接,保证在负载不重时的效率.
*******************************************************************************}
unit USAPConnection;

interface

uses
  Windows, Classes, ComObj, SysUtils, SyncObjs, UWaitItem, UMgrHashDict,
  USysLoger, SAPLogonCtrl_TLB, SAPFunctionsOCX_TLB;

const
  cErr_SAPConn_NoParam     = $0001;            //无连接参数
  cErr_SAPConn_NoAllowed   = $0002;            //阻止申请
  cErr_SAPConn_Closing     = $0003;            //连接正断开

type
  PSAPParam = ^TSAPParam;
  TSAPParam = record
    FID   : string;                            //参数标识
    FName : string;                            //标识名称
    FHost : string;                            //主机地址
    FUser : string;                            //用户名
    FPwd  : string;                            //用户密码

    FSystem   : string;                        //系统标识
    FSysNum   : Integer;                       //系统编号
    FClient   : string;                        //终端标识
    FLang     : string;                        //语言标识
    FCodePage : string;                        //
    FEnable   : Boolean;                       //是否有效
  end;

  PSAPConnection = ^TSAPConnection;
  TSAPConnection = record
    FID        : string;                       //连接标识
    FConn      : Connection;                   //连接对象
    FFunction  : TSAPFunctions;                //函数对象
    FUsed      : Integer;                      //排队计数
    FLock      : TCriticalSection;             //同步锁定
    FWaiter    : TWaitObject;                  //延迟对象
    FLast      : Cardinal;                     //上次使用
  end;

  PSAPConnStatus = ^TSAPConnStatus;
  TSAPConnStatus = record
    FNumConnRequest: Cardinal;                 //连接请求总数
    FNumRequestErr: Cardinal;                  //请求错误次数
    FNumConnParam: Integer;                    //连接参数个数
    FNumConnItem: Integer;                     //连接项个数
    FNumConned: Integer;                       //已连接对象(Connection)个数
    FNumConnTotal: Cardinal;                   //连接总次数
    FNumConnMax: Integer;                      //连接最多个数
    FTimeConnMax: TDateTime;                   //连接峰值时间
    FNumReUsed: Cardinal;                      //对象重复使用次数
    FNumWait: Integer;                         //排队中对象(Item.FUsed)个数
    FNumWaitMax: Integer;                      //排队最多的组队列中对象个数
    FTimeWaitMax: TDateTime;                    //排队最多时间
  end;

  TSAPConnectionManager = class(TObject)
  private
    FConnClosing: Integer;
    FAllowedRequest: Integer;
    FSyncLock: TCriticalSection;
    //同步锁
    FParams: array of TSAPParam;
    //参数列表
    FConnItems: TList;
    //连接列表
    FConnFactory: TSAPLogonControl;
    //连接厂
    FStatus: TSAPConnStatus;
    //运行状态
  protected
    procedure ClearConnItems(const nFreeMe: Boolean);
    //清理连接
    function GetRunStatus: TSAPConnStatus;
    //读取状态
    procedure CloseConnection(const nConn: PSAPConnection);
    //关闭连接
    procedure DoLogon(Sender: TObject; const nConn: IDispatch);
    procedure DoLogoff(Sender: TObject; const nConn: IDispatch);
    //事件绑定
    procedure WriteLog(const nLog: string);
    //记录日志
    function GetPoolSize: Integer;
    procedure SetPoolSize(const nValue: Integer);
    //池对象数
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure AddParam(const nParam: TSAPParam);
    procedure DelParam(const nID: string = '');
    procedure ClearParam;
    //参数管理
    function GetConnection(const nID: string; var nErrCode: Integer): PSAPConnection;
    function GetConnLoop(const nID: string; var nErrCode: Integer): PSAPConnection;
    procedure ReleaseConnection(const nConn: PSAPConnection);
    procedure ClearAllConnection;
    //使用连接
    property Status: TSAPConnStatus read GetRunStatus;
    property PoolSize: Integer read GetPoolSize write SetPoolSize;
    //属性相关
  end;

var
  gSAPConnectionManager: TSAPConnectionManager = nil;
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

//------------------------------------------------------------------------------
constructor TSAPConnectionManager.Create;
begin
  FConnClosing := cFalse;
  FAllowedRequest := cTrue;

  FillChar(FStatus, SizeOf(FStatus), #0);
  FConnItems := TList.Create;
  FSyncLock := TCriticalSection.Create;

  FConnFactory := TSAPLogonControl.Create(nil);
  with FConnFactory do
  begin
    Enabled := False;
    OnLogon := DoLogon;
    OnLogoff := DoLogoff;
  end;
end;

destructor TSAPConnectionManager.Destroy;
begin
  ClearConnItems(True);
  FreeAndNil(FConnFactory);
  FreeAndNil(FSyncLock);
  inherited;
end;

//Desc: 读取运行状态
function TSAPConnectionManager.GetRunStatus: TSAPConnStatus;
begin
  FSyncLock.Enter;
  try
    Result := FStatus;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 释放连接对象
procedure FreeConnItem(const nItem: PSAPConnection);
begin
  if Assigned(nItem) then
  with nItem^ do
  begin
    FConn := nil;
    FreeAndNil(FFunction);
    FreeAndNil(FLock);
    FreeAndNil(FWaiter);
  end;

  Dispose(nItem);
end;

//Date: 2012-2-20
//Parm: 连接数
//Desc: 本函数只能主进程调用,并且在运行前
procedure TSAPConnectionManager.SetPoolSize(const nValue: Integer);
var nIdx: Integer;
    nItem: PSAPConnection;
begin
  FSyncLock.Enter;
  try
    if FConnItems.Count <= nValue then
    begin
      for nIdx:=FConnItems.Count to nValue-1  do
      begin
        New(nItem);
        FConnItems.Add(nItem);
        Inc(FStatus.FNumConnItem);

        with nItem^ do
        begin
          FUsed := 0;
          FLast := 0;
          FLock := TCriticalSection.Create;

          FWaiter := TWaitObject.Create;
          FWaiter.Interval := 2 * 10;

          FConn := FConnFactory.NewConnection as Connection;
          FFunction := TSAPFunctions.Create(nil);
          FFunction.Connection := FConn;
        end;
      end; //add

      Exit;
    end;

    try
      InterlockedExchange(FConnClosing, cTrue);
      //close flag

      for nIdx:=FConnItems.Count - 1 downto nValue do
        CloseConnection(FConnItems[nIdx]);
      //xxxxx

      for nIdx:=FConnItems.Count-1 downto nValue  do
      begin
        FreeConnItem(FConnItems[nIdx]);
        FConnItems.Delete(nIdx);
        Dec(FStatus.FNumConnItem);
      end; //del
    finally
      InterlockedExchange(FConnClosing, cFalse);
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 连接池对象个数
function TSAPConnectionManager.GetPoolSize: Integer;
begin
  FSyncLock.Enter;
  try
    Result := FConnItems.Count;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 关闭指定连接
procedure TSAPConnectionManager.CloseConnection(const nConn: PSAPConnection);
begin
  //让出锁,等待工作对象释放
  FSyncLock.Leave;
  try
    while nConn.FUsed > 0 do
      nConn.FWaiter.EnterWait;
    //等待队列退出
  finally
    FSyncLock.Enter;
  end;

  try
    nConn.FConn.Logoff;
    nConn.FConn := nil;
    nConn.FFunction.Connection := nil;
  except
    //ignor any error
  end;
end;

//Desc: 清理连接对象
procedure TSAPConnectionManager.ClearConnItems(const nFreeMe: Boolean);
var nIdx: Integer;
begin
  if nFreeMe then
    InterlockedExchange(FAllowedRequest, cFalse);
  //请求关闭

  FSyncLock.Enter;
  try
    InterlockedExchange(FConnClosing, cTrue);
    //关闭标记

    for nIdx:=FConnItems.Count - 1 downto 0 do
      CloseConnection(FConnItems[nIdx]);
    //断开全部连接

    for nIdx:=FConnItems.Count - 1 downto 0 do
    begin
      FreeConnItem(FConnItems[nIdx]);
      FConnItems.Delete(nIdx);
    end;

    if nFreeMe then FreeAndNil(FConnItems);
    FillChar(FStatus, SizeOf(FStatus), #0);
  finally
    InterlockedExchange(FConnClosing, cFalse);
    FSyncLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-2-16
//Parm: 连接参数
//Desc: 添加一个nParam参数
procedure TSAPConnectionManager.AddParam(const nParam: TSAPParam);
var i,nIdx: Integer;
begin
  if nParam.FID = '' then Exit;
  nIdx := -1;
  FSyncLock.Enter;
  try
    for i:=Low(FParams) to High(FParams) do
    if CompareText(FParams[i].FID, nParam.FID) = 0 then
    begin
      nIdx := i; Break;
    end;

    if nIdx < 0 then
    begin
      nIdx := Length(FParams);
      SetLength(FParams, nIdx + 1);
      Inc(FStatus.FNumConnParam);
    end;

    FParams[nIdx] := nParam;
    FParams[nIdx].FEnable := True;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2012-2-16
//Parm: 参数标识
//Desc: 删除标识为nID的参数
procedure TSAPConnectionManager.DelParam(const nID: string);
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    for nIdx:=Low(FParams) to High(FParams) do
    if CompareText(FParams[nIdx].FID, nID) = 0 then
    begin
      FParams[nIdx].FEnable := False;
      Dec(FStatus.FNumConnParam);
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2012-2-16
//Desc: 清空参数
procedure TSAPConnectionManager.ClearParam;
begin
  FSyncLock.Enter;
  try
    SetLength(FParams, 0);
    FStatus.FNumConnParam := 0;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TSAPConnectionManager.DoLogon(Sender: TObject; const nConn: IDispatch);
begin
  FSyncLock.Enter;
  try
    Inc(FStatus.FNumConned);
    Inc(FStatus.FNumConnTotal);
    
    if FStatus.FNumConned > FStatus.FNumConnMax then
    begin
      FStatus.FNumConnMax := FStatus.FNumConned;
      FStatus.FTimeConnMax := Now();
    end;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TSAPConnectionManager.DoLogoff(Sender: TObject; const nConn: IDispatch);
begin
  FSyncLock.Enter;
  try
    Dec(FStatus.FNumConned);
    if FStatus.FNumConned < 0 then
      FStatus.FNumConned := 0;
    //xxxxx
  finally
    FSyncLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-2-16
//Parm: 日志内容
//Desc: 记录nLog日志
procedure TSAPConnectionManager.WriteLog(const nLog: string);
begin
  if Assigned(gSysLoger) then
    gSysLoger.AddLog(TSAPConnectionManager, 'SAP连接池', nLog);
  //xxxxx
end;

//Date: 2012-2-16
//Parm: 连接标识;错误码
//Desc: 返回nID可用的SAP连接对象
function TSAPConnectionManager.GetConnection(const nID: string;
  var nErrCode: Integer): PSAPConnection;
var nIdx: Integer;
    nParam: Integer;
    nItem,nIdle,nTmp: PSAPConnection;
begin
  Result := nil;
  nErrCode := cErr_SAPConn_NoAllowed;

  if FAllowedRequest = cFalse then
  begin
    WriteLog(sNoAllowedWhenRequest);
    Exit;
  end;

  nErrCode := cErr_SAPConn_Closing;
  if FConnClosing = cTrue then
  begin
    WriteLog(sClosingWhenRequest);
    Exit;
  end;

  FSyncLock.Enter;
  try
    nErrCode := cErr_SAPConn_NoAllowed;
    if FAllowedRequest = cFalse then
    begin
      WriteLog(sNoAllowedWhenRequest);
      Exit;
    end;

    nErrCode := cErr_SAPConn_Closing;
    if FConnClosing = cTrue then
    begin
      WriteLog(sClosingWhenRequest);
      Exit;
    end;
    //重复判定,避免Get和close锁定机制重叠(get.enter在close.enter后面进入等待)

    Inc(FStatus.FNumConnRequest);
    nParam := -1;

    for nIdx:=Low(FParams) to High(FParams) do
    if (CompareText(FParams[nIdx].FID, nID) = 0) and FParams[nIdx].FEnable then
    begin
      nParam := nIdx; Break;
    end;

    nErrCode := cErr_SAPConn_NoParam;
    if nParam < 0 then
    begin
      WriteLog(sNoParamWhenRequest);
      Exit;
    end;

    //--------------------------------------------------------------------------
    nItem := nil;
    nIdle := nil;

    for nIdx:=0 to FConnItems.Count - 1 do
    begin
      nTmp := FConnItems[nIdx];
      if nTmp.FUsed < 1 then
      begin
        nItem := nTmp; Break;
      end;

      if (not Assigned(nIdle)) or (nIdle.FUsed > nTmp.FUsed) then
        nIdle := nTmp;
      //连接数最少
    end;

    if not Assigned(nItem) then
    begin
      nItem := nIdle;
      Inc(FStatus.FNumReUsed);
    end;

    //--------------------------------------------------------------------------
    with nItem^ do
    begin
      with FConn,FParams[nParam] do
      begin
        User := FUser;
        Password := FPwd;
        Client := FClient;
        Language := FLang;
        Codepage := FCodePage;
        System_ := FSystem;
        SystemNumber := FSysNum;
        ApplicationServer := FHost;
      end;

      FID := nID;
      Inc(FUsed);
      Inc(FStatus.FNumWait);

      if nItem.FUsed > FStatus.FNumWaitMax then
      begin
        FStatus.FNumWaitMax := nItem.FUsed;
        FStatus.FTimeWaitMax := Now();
      end;

      Result := nItem;
    end;
  finally
    if not Assigned(Result) then
      Inc(FStatus.FNumRequestErr);
    FSyncLock.Leave;
  end;

  if Assigned(Result) then
  with Result^ do
  begin
    FLock.Enter;
    //工作对象进入排队

    if FConnClosing = cTrue then
    try
      Result := nil;
      nErrCode := cErr_SAPConn_Closing;
      WriteLog(sClosingWhenRequest);
      
      InterlockedDecrement(FUsed);
      InterlockedDecrement(FStatus.FNumWait);
      FWaiter.Wakeup;
    finally
      FLock.Leave;
    end;
  end;
end;

//Date: 2012-2-21
//Parm: 连接标识;错误码
//Desc: 返回nID可用的SAP连接对象,若失败则尝试多次获取
function TSAPConnectionManager.GetConnLoop(const nID: string;
  var nErrCode: Integer): PSAPConnection;
var nInt: Cardinal;
begin
  Result := nil;
  nErrCode := cErr_SAPConn_NoAllowed;
  nInt := GetTickCount;

  while True do
  begin
    Result := GetConnection(nID, nErrCode);
    if Assigned(Result) then Break;

    if (nErrCode = cErr_SAPConn_Closing) and (GetTickCount - nInt < 5000) then
         Sleep(10)
    else Break;
  end;
end;

//Date: 2012-2-16
//Parm: 连接对象
//Desc: 释放nConnection连接对象
procedure TSAPConnectionManager.ReleaseConnection(const nConn: PSAPConnection);
begin
  if Assigned(nConn) then
  with nConn^ do
  begin
    FSyncLock.Enter;
    try
      Dec(FUsed);
      FLast := GetTickCount;

      Dec(FStatus.FNumWait);
      if FConnClosing <> cTrue then
      begin
        if (FUsed < 1) and (FConnItems.IndexOf(nConn) > 0) then
          FConn.Logoff;
        //no used and not the first one
      end else FWaiter.Wakeup;
    finally
      FLock.Leave;
      FSyncLock.Leave;
    end;
  end; 
end;

//Date: 2012-2-17
//Desc: 关闭所有链接
procedure TSAPConnectionManager.ClearAllConnection;
begin
  ClearConnItems(False);
end;

initialization
  gSAPConnectionManager := nil;
finalization
  FreeAndNil(gSAPConnectionManager);
end.
