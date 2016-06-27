{*******************************************************************************
  作者: dmzn@163.com 2013-11-19
  描述: 插件接口和参数定义

  备注:
  *.插件管理器TPlugManager统一主程序和插件中的全局变量和管理器对象.
  *.在插件目录中,以"0_"开头的文件表示已作废插件.
  *.插件使用TPlugEventWorker来完成主程序的广播动作.
*******************************************************************************}
unit UMgrPlug;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SyncObjs, SysUtils, Forms, Messages,
  ULibFun, UMgrDBConn, UMgrControl, UMgrParam, UBusinessPacker, UBusinessWorker,
  {$IFDEF ChannelPool}UMgrChannel,{$ENDIF}
  {$IFDEF AutoChannel}UChannelChooser,{$ENDIF}
  UTaskMonitor, UObjectList, USysLoger;

const
  {*plug message*}
  PM_RestoreForm   = WM_User + $0001;                //恢复窗体
  PM_RefreshMenu   = WM_User + $0002;                //更新菜单

  PM_RM_FullStatus = 10;
  PM_RM_OnlyStatus = 20;                             //菜单参数

const
  {*plug event*}
  cPlugEvent_InitSystemObject     = $0001;
  cPlugEvent_RunSystemObject      = $0002;
  cPlugEvent_FreeSystemObject     = $0003;
  cPlugEvent_BeforeStartServer    = $0004;
  cPlugEvent_AfterServerStarted   = $0005;
  cPlugEvent_BeforeStopServer     = $0006;
  cPlugEvent_AfterStopServer      = $0007;
  cPlugEvent_BeforeUnloadModule   = $0008;

type
  TPlugModuleInfo = record
    FModuleID       : string;    //标识
    FModuleName     : string;    //名称
    FModuleAuthor   : string;    //作者
    FModuleVersion  : string;    //版本
    FModuleDesc     : string;    //描述
    FModuleFile     : string;    //文件
    FModuleBuildTime: TDateTime; //编译时间
  end;

  TPlugModuleInfos = array of TPlugModuleInfo;
  //模块信息列表

  PPlugMenuItem = ^TPlugMenuItem;
  TPlugMenuItem = record
    FModule     : string;        //模块标识
    FName       : string;        //菜单名
    FCaption    : string;        //菜单标题
    FFormID     : Integer;       //功能窗体
    FDefault    : Boolean;       //默认启动
  end;

  TPlugMenuItems = array of TPlugMenuItem;
  //模块菜单列表

  PPlugRunParameter = ^TPlugRunParameter;
  TPlugRunParameter = record
    FAppFlag   : string;         //程序标识
    FAppPath   : string;         //程序路径
    FAppHandle : THandle;        //程序句柄
    FMainForm  : THandle;        //窗体句柄

    FLocalIP   : string;         //本机IP
    FLocalMAC  : string;         //本机MAC
    FLocalName : string;         //本机名称
    FExtParam  : TStrings;       //扩展参数
  end;

  PPlugEnvironment = ^TPlugEnvironment;
  TPlugEnvironment = record
    FApplication   : TApplication;
    FScreen        : TScreen;
    FSysLoger      : TSysLoger;
    FTaskMonitor   : TTaskMonitor;

    FParamManager  : TParamManager;
    FCtrlManager   : TControlManager;
    FDBConnManger  : TDBConnManager;
    FPackerManager : TBusinessPackerManager;
    FWorkerManager : TBusinessWorkerManager;
    //核心对象
    FExtendObjects : TStrings;
    //扩展对象
  end;

  TPlugEventWorker = class(TObject)
  private
    FLibHandle: THandle;
    //模块句柄
  protected
    procedure GetExtendMenu(const nList: TList); virtual;
    //主程序加载扩展菜单项
    procedure InitSystemObject; virtual;
    //主程序启动时初始化
    procedure RunSystemObject(const nParam: PPlugRunParameter); virtual;
    //主程序启动后运行
    procedure FreeSystemObject; virtual;
    //主程序退出时释放
    procedure BeforeStartServer; virtual;
    //服务启动之前调用
    procedure AfterServerStarted; virtual;
    //服务启动之后调用
    procedure BeforeStopServer; virtual;
    //服务关闭之前调用
    procedure AfterStopServer; virtual;
    //服务关闭之后调用
  public
    constructor Create(const nHandle: THandle = INVALID_HANDLE_VALUE);
    destructor Destroy; override;
    //创建释放
    class function ModuleInfo: TPlugModuleInfo; virtual;
    //模块信息
    property ModuleHandle: THandle read FLibHandle;
    //属性相关
  end;

  TPlugEventWorkerClass = class of TPlugEventWorker;
  //工作对象类类型

  TPlugManager = class(TObject)
  private
    FWorkers: TObjectDataList;
    //事件对象
    FMenuChanged: Boolean;
    FMenuList: TList;
    //菜单列表
    FRunParam: TPlugRunParameter;
    //运行参数
    FSyncLock: TCriticalSection;
    //同步锁定
    FIsDestroying: Boolean;
    FInitSystemObject: Boolean;
    FRunSystemObject: Boolean;
    FBeforeStartServer: Boolean;
    FAfterServerStarted: Boolean;
    //调用状态
  protected
    procedure ClearMenu(const nFree: Boolean; const nModule: string = '';
      const nLocked: Boolean = True);
    //清理资源
    function LoadPlugFile(const nFile: string): string;
    //加载插件
    procedure BeforeUnloadModule(const nWorker: TPlugEventWorker);
    //清理模块资源
    function BroadcastEvent(const nEventID: Integer; const nParam: Pointer = nil;
      const nModule: string = ''; const nLocked: Boolean = True): Boolean;
    //向插件列表广播事件
  public
    constructor Create(const nParam: TPlugRunParameter);
    destructor Destroy; override;
    //创建释放
    class procedure EnvAction(const nEnv: PPlugEnvironment; const nGet: Boolean);
    //获取环境变量
    procedure InitSystemObject(const nModule: string = '');
    procedure RunSystemObject(const nModule: string = '');
    procedure FreeSystemObject(const nModule: string = '');
    //对象申请和释放
    procedure BeforeStartServer(const nModule: string = '');
    procedure AfterServerStarted(const nModule: string = '');
    procedure BeforeStopServer(const nModule: string = '');
    procedure AfterStopServer(const nModule: string = '');
    //服务起停业务处理
    procedure AddEventWorker(const nWorker: TPlugEventWorker);
    //添加非插件工作对象
    procedure LoadPlugsInDirectory(nPath: string);
    function UpdatePlug(const nFile: string; var nHint: string): Boolean;
    function UnloadPlug(const nModule: string): string;
    procedure UnloadPlugsAll;
    //加载卸载插件
    procedure RefreshUIMenu;
    //更新界面菜单
    function GetMenuItems(const nResetMenu: Boolean): TPlugMenuItems;
    //模块菜单列表
    function GetModuleInfo(const nModule: string): TPlugModuleInfo;
    function GetModuleInfoList: TPlugModuleInfos;
    //模块信息列表
    property RunParam: TPlugRunParameter read FRunParam;
    //属性相关
  end;

var
  gPlugManager: TPlugManager = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TPlugManager, '插件管理器', nEvent);
end;

//------------------------------------------------------------------------------
constructor TPlugEventWorker.Create(const nHandle: THandle);
begin
  FLibHandle := nHandle;
end;

destructor TPlugEventWorker.Destroy;
begin
  //nothing
  inherited;
end;

class function TPlugEventWorker.ModuleInfo: TPlugModuleInfo;
var nBuf: array[0..MAX_PATH-1] of Char;
begin
  with Result do
  begin
    FModuleID       := '{0EE5410B-9334-45DE-A186-713C11434392}';
    FModuleName     := '通用框架插件基类';
    FModuleAuthor   := 'dmzn@163.com';
    FModuleVersion  := '2013-11-20';
    FModuleDesc     := '插件通过继承该类,可以获得框架的接口.';
    FModuleBuildTime:= Str2DateTime('2013-11-22 15:01:01');

    FModuleFile := Copy(nBuf, 1, GetModuleFileName(HInstance, nBuf, MAX_PATH));
    //module full file name
  end;
end;

procedure TPlugEventWorker.GetExtendMenu(const nList: TList);
begin

end;

procedure TPlugEventWorker.InitSystemObject;
begin
end;

procedure TPlugEventWorker.RunSystemObject(const nParam: PPlugRunParameter);
begin
end;

procedure TPlugEventWorker.FreeSystemObject;
begin
end;

procedure TPlugEventWorker.BeforeStartServer;
begin
end;

procedure TPlugEventWorker.AfterServerStarted;
begin
end;

procedure TPlugEventWorker.BeforeStopServer;
begin
end;

procedure TPlugEventWorker.AfterStopServer;
begin
end;

//------------------------------------------------------------------------------
constructor TPlugManager.Create(const nParam: TPlugRunParameter);
begin
  FRunParam := nParam;
  FIsDestroying := False;

  FInitSystemObject := False;
  FRunSystemObject := False;
  FBeforeStartServer := False;
  FAfterServerStarted := False;

  FMenuChanged := True;
  FMenuList := TList.Create;
  FSyncLock := TCriticalSection.Create;
  FWorkers := TObjectDataList.Create(dtObject); 
end;

destructor TPlugManager.Destroy;
begin
  FIsDestroying := True;
  UnloadPlugsAll;
  ClearMenu(True);

  FreeAndNil(FWorkers);
  FreeAndNil(FSyncLock);
  FreeAndNil(FRunParam.FExtParam);
  inherited;
end;

//Desc: 清理菜单列表
procedure TPlugManager.ClearMenu(const nFree: Boolean; const nModule: string;
  const nLocked: Boolean);
var nIdx: Integer;
    nMenu: PPlugMenuItem;
begin
  if nLocked then FSyncLock.Enter;
  try
    for nIdx:=FMenuList.Count - 1 downto 0 do
    begin
      nMenu := FMenuList[nIdx];
      if (nModule = '') or (nMenu.FModule = nModule) then
      begin
        Dispose(nMenu);
        FMenuList.Delete(nIdx);
        FMenuChanged := True;
      end;
    end;

    if nFree then
      FreeAndNil(FMenuList);
    //xxxxx
  finally
    if nLocked then FSyncLock.Leave;
  end;
end;

//Desc: 更新主菜单
procedure TPlugManager.RefreshUIMenu;
begin
  if (not FIsDestroying) and FMenuChanged then
  begin
    FMenuChanged := False;
    PostMessage(FRunParam.FMainForm, PM_RefreshMenu, PM_RM_FullStatus, 0);
  end;
end;

//Date: 2013-11-22
//Desc: 卸载模块时清理资源
procedure TPlugManager.BeforeUnloadModule(const nWorker: TPlugEventWorker);
var nStr: string;
begin
  with nWorker.ModuleInfo do
  try
    nStr := '卸载模块[ %s ],文件:[ %s ]';
    nStr := Format(nStr, [FModuleName, ExtractFileName(FModuleFile) ]);
    WriteLog(nStr);

    nStr := '  1.开始卸载Menu...';
    ClearMenu(False, FModuleID, False);
    WriteLog(nStr + '完成');

    nStr := '  2.开始停止服务...';
    nWorker.AfterStopServer;
    WriteLog(nStr + '完成');

    nStr := '  3.开始卸载Worker...';
    gBusinessWorkerManager.UnRegistePacker(FModuleID);
    WriteLog(nStr + '完成');

    nStr := '  4.开始卸载Packer...';
    gBusinessPackerManager.UnRegistePacker(FModuleID);
    WriteLog(nStr + '完成');

    nStr := '  5.开始释放Control...';
    gControlManager.UnregCtrl(FModuleID, True);
    WriteLog(nStr + '完成');

    nStr := '  6.开始释放对象...';
    nWorker.FreeSystemObject;
    WriteLog(nStr + '完成');
  except
    on E:Exception do
    begin
      WriteLog(nStr + '错误,描述: ' + E.Message);
    end;
  end;
end;

function Event2Str(const nEventID: Integer): string;
begin
  case nEventID of
   cPlugEvent_InitSystemObject   : Result := 'InitSystemObject';
   cPlugEvent_RunSystemObject    : Result := 'RunSystemObject';
   cPlugEvent_FreeSystemObject   : Result := 'FreeSystemObject';
   cPlugEvent_BeforeStartServer  : Result := 'BeforeStartServer';
   cPlugEvent_AfterServerStarted : Result := 'AfterServerStarted';
   cPlugEvent_BeforeStopServer   : Result := 'BeforeStopServer';
   cPlugEvent_AfterStopServer    : Result := 'AfterStopServer';
   cPlugEvent_BeforeUnloadModule : Result := 'BeforeUnloadModule'
   else Result := '';
  end;
end;

//Date: 2013-11-19
//Parm: 事件表示;参数;锁定
//Desc: 向插件列表广播nEventID事件,附带nParam参数调用
function TPlugManager.BroadcastEvent(const nEventID: Integer;
 const nParam: Pointer; const nModule: string; const nLocked: Boolean): Boolean;
var nErr: string;
    nIdx: Integer;
    nHwnd: THandle;
    nWorker: TPlugEventWorker;
begin
  Result := False;
  if nLocked then FSyncLock.Enter;
  try     
    for nIdx:=FWorkers.ItemHigh downto FWorkers.ItemLow do
    try
      nErr := '';
      nWorker := TPlugEventWorker(FWorkers.ObjectA[nIdx]);
      nErr := nWorker.ModuleInfo.FModuleName;

      if (nModule <> '') and (nWorker.ModuleInfo.FModuleID <> nModule) then
        Continue;
      //filter

      case nEventID of
       cPlugEvent_InitSystemObject   : nWorker.InitSystemObject;
       cPlugEvent_RunSystemObject    : nWorker.RunSystemObject(nParam);
       cPlugEvent_FreeSystemObject   : nWorker.FreeSystemObject;
       cPlugEvent_BeforeStartServer  : nWorker.BeforeStartServer;
       cPlugEvent_AfterServerStarted : nWorker.AfterServerStarted;
       cPlugEvent_BeforeStopServer   : nWorker.BeforeStopServer;
       cPlugEvent_AfterStopServer    : nWorker.AfterStopServer;
       cPlugEvent_BeforeUnloadModule :
        begin 
          BeforeUnloadModule(nWorker);
          //卸载模块资源 
          nHwnd := nWorker.ModuleHandle;
          FWorkers.DeleteItem(nIdx);
          //删除模块工作对象

          if nHwnd <> INVALID_HANDLE_VALUE then
            FreeLibrary(nHwnd);
          //关闭模块句柄
        end else Exit;
      end;

      if nModule <> '' then
        Break;
      //fixed worker
    except
      on E: Exception do
      begin
        if nErr = '' then
        begin
          nErr := '第[ %d ]个模块执行[ %s ]时获取对象失败,描述: %s';
          nErr := Format(nErr, [nIdx, Event2Str(nEventID), E.Message]);
          WriteLog(nErr);
        end else
        begin
          nErr := Format('模块[ %s ]执行[ %s ]时错误,描述: %s', [nErr,
            Event2Str(nEventID), E.Message]);       
          WriteLog(nErr);
        end;
      end;
    end;

    Result := True;
  finally
    if nLocked then FSyncLock.Leave;
  end;
end;

procedure TPlugManager.InitSystemObject(const nModule: string = '');
begin
  if nModule = '' then
    FInitSystemObject := True;
  BroadcastEvent(cPlugEvent_InitSystemObject, nil, nModule);
end;

procedure TPlugManager.RunSystemObject(const nModule: string = '');
begin
  if nModule = '' then
    FRunSystemObject := True;
  BroadcastEvent(cPlugEvent_RunSystemObject, @FRunParam, nModule);
end;

procedure TPlugManager.FreeSystemObject(const nModule: string = '');
begin
  if nModule = '' then
  begin
    FInitSystemObject := False;
    FRunSystemObject := False;
  end;
  BroadcastEvent(cPlugEvent_FreeSystemObject, nil, nModule);
end;

procedure TPlugManager.BeforeStartServer(const nModule: string = '');
begin
  if nModule = '' then
    FBeforeStartServer := True;
  BroadcastEvent(cPlugEvent_BeforeStartServer, nil, nModule);
end;

procedure TPlugManager.AfterServerStarted(const nModule: string = '');
begin
  if nModule = '' then
    FAfterServerStarted := True;
  BroadcastEvent(cPlugEvent_AfterServerStarted, nil, nModule);
end;

procedure TPlugManager.BeforeStopServer(const nModule: string = '');
begin
  if nModule = '' then
  begin
    FBeforeStartServer := False;
    FAfterServerStarted := False;
  end;
  BroadcastEvent(cPlugEvent_BeforeStopServer, nil, nModule);
end;

procedure TPlugManager.AfterStopServer(const nModule: string = '');
begin
  if nModule = '' then
  begin
    FBeforeStartServer := False;
    FAfterServerStarted := False;
  end;
  BroadcastEvent(cPlugEvent_AfterStopServer, nil, nModule);
end;

//------------------------------------------------------------------------------
//Date: 2013-12-06
//Parm: 重置默认标识
//Desc: 获取已注册的菜单列表
function TPlugManager.GetMenuItems(const nResetMenu: Boolean): TPlugMenuItems;
var nIdx,nNum: Integer;
    nMenu: PPlugMenuItem;
begin
  FSyncLock.Enter;
  try
    nNum := 0;
    SetLength(Result, FMenuList.Count);

    for nIdx:=0 to FMenuList.Count - 1 do
    begin
      nMenu := FMenuList[nIdx];
      Result[nNum] := nMenu^;

      if nResetMenu then
        nMenu.FDefault := False;
      Inc(nNum);
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-11-19
//Desc: 获取已注册的模块列表
function TPlugManager.GetModuleInfoList: TPlugModuleInfos;
var nIdx,nNum: Integer;
begin
  FSyncLock.Enter;
  try
    nNum := 0;
    SetLength(Result, FWorkers.Count);

    for nIdx:=FWorkers.ItemLow to FWorkers.ItemHigh do
    begin
      Result[nNum] := TPlugEventWorker(FWorkers.ObjectA[nIdx]).ModuleInfo;
      Inc(nNum);
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2014/9/2
//Parm: 模块标识
//Desc: 获取nModule的信息
function TPlugManager.GetModuleInfo(const nModule: string): TPlugModuleInfo;
var nIdx: Integer;
begin
  FSyncLock.Enter;
  try
    FillChar(Result, SizeOf(Result), #0);
    //init

    for nIdx:=FWorkers.ItemLow to FWorkers.ItemHigh do
    if TPlugEventWorker(FWorkers.ObjectA[nIdx]).ModuleInfo.FModuleID = nModule then
    begin
      Result := TPlugEventWorker(FWorkers.ObjectA[nIdx]).ModuleInfo;
      Exit;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-11-24
//Parm: 变量参数;获取or设置
//Desc: 读取环境参数到nEnv,或设置环境参数为nEnv.
class procedure TPlugManager.EnvAction(const nEnv: PPlugEnvironment;
 const nGet: Boolean);
var nIdx: Integer;
begin
  with nEnv^ do
  begin
    if nGet then
    begin
      FApplication   := Application;
      FScreen        := Screen;
      FSysLoger      := gSysLoger;
      FTaskMonitor   := gTaskMonitor;

      FParamManager  := gParamManager;
      FCtrlManager   := gControlManager;
      FDBConnManger  := gDBConnManager;
      FPackerManager := gBusinessPackerManager;
      FWorkerManager := gBusinessWorkerManager;

      if not Assigned(FExtendObjects) then Exit;
      //no extend

      {$IFDEF ChannelPool}
      FExtendObjects.AddObject(TChannelManager.ClassName, gChannelManager);
      {$ENDIF}

      {$IFDEF AutoChannel}
      FExtendObjects.AddObject(TChannelChoolser.ClassName, gChannelChoolser);
      {$ENDIF}
    end else
    begin
      Application    := FApplication;
      Screen         := FScreen;
      gSysLoger      := FSysLoger;
      gTaskMonitor   := FTaskMonitor;

      gParamManager  := FParamManager;
      gControlManager:= FCtrlManager;
      gDBConnManager := FDBConnManger;
      gBusinessPackerManager := FPackerManager;
      gBusinessWorkerManager := FWorkerManager;

      if not Assigned(FExtendObjects) then Exit;
      //no extend

      {$IFDEF ChannelPool}
      nIdx := FExtendObjects.IndexOf(TChannelManager.ClassName);
      if nIdx > -1 then
        gChannelManager := TChannelManager(FExtendObjects.Objects[nIdx]);
      {$ENDIF}

      {$IFDEF AutoChannel}
      nIdx := FExtendObjects.IndexOf(TChannelChoolser.ClassName);
      if nIdx > -1 then
        gChannelChoolser := TChannelChoolser(FExtendObjects.Objects[nIdx]);
      {$ENDIF}
    end;
  end;
end;

//Date: 2013-11-22
//Parm: 模块名
//Desc: 从管理器中卸载nModule模块
function TPlugManager.UnloadPlug(const nModule: string): string;
begin
  BroadcastEvent(cPlugEvent_BeforeUnloadModule, nil, nModule);
end;

//Date: 2013-11-22
//Desc: 卸载全部模块
procedure TPlugManager.UnloadPlugsAll;
begin
  BroadcastEvent(cPlugEvent_BeforeUnloadModule);
end;

//------------------------------------------------------------------------------
type
  TProcGetWorker = procedure (var nWorker: TPlugEventWorkerClass); stdcall;
  TProcBackupEnv = procedure (const nNewEnv: PPlugEnvironment); stdcall;

//Date: 2013-11-22
//Parm: 模块路径
//Desc: 载入nFile模块到管理器
function TPlugManager.LoadPlugFile(const nFile: string): string;
var nHwnd: THandle;
    nLoad: TProcGetWorker;
    nBack: TProcBackupEnv;

    nEnv: TPlugEnvironment;
    nWorker: TPlugEventWorker;
    nClass: TPlugEventWorkerClass;
begin
  Result := Format('文件[ %s ]已丢失.', [nFile]);
  if not FileExists(nFile) then Exit;
     
  nHwnd := INVALID_HANDLE_VALUE;
  try
    nHwnd := LoadLibrary(PChar(nFile));
    nLoad := GetProcAddress(nHwnd, 'LoadModuleWorker');
    nBack := GetProcAddress(nHwnd, 'BackupEnvironment');

    if not (Assigned(nLoad) and Assigned(nBack)) then
    begin
      Result := Format('文件[ %s ]不是有效模块.', [nFile]);
      Exit;
    end;

    nEnv.FExtendObjects := nil;
    //init state
    
    FSyncLock.Enter;
    try
      nLoad(nClass);
      if FWorkers.FindItem(nClass.ModuleInfo.FModuleID) < 0 then
      begin
        nWorker := nClass.Create(nHwnd);
        nHwnd := INVALID_HANDLE_VALUE;
        FWorkers.AddItem(nWorker, nWorker.ModuleInfo.FModuleID);

        nEnv.FExtendObjects := TStringList.Create;
        EnvAction(@nEnv, True);
        nBack(@nEnv);
        //初始化模块环境变量

        nWorker.GetExtendMenu(FMenuList);
        FMenuChanged := True;
        //新模块提供的菜单扩展
        
        if FInitSystemObject then
          InitSystemObject(nWorker.ModuleInfo.FModuleID);
        if FRunSystemObject then
          RunSystemObject(nWorker.ModuleInfo.FModuleID);
        if FBeforeStartServer then
          BeforeStartServer(nWorker.ModuleInfo.FModuleID);
        if FAfterServerStarted then
          AfterServerStarted(nWorker.ModuleInfo.FModuleID);
        //新模块与主程序状态同步
      end;
    finally
      if Assigned(nEnv.FExtendObjects) then
        nEnv.FExtendObjects.Free;
      FSyncLock.Leave;
    end;

    Result := '';
  finally
    if nHwnd <> INVALID_HANDLE_VALUE then
      FreeLibrary(nHwnd);
    //free if need
  end;
end;

//Date: 2013-12-11
//Parm: 工作对象;刷新菜单
//Desc: 添加新的工作对象到管理器中
procedure TPlugManager.AddEventWorker(const nWorker: TPlugEventWorker);
begin
  FSyncLock.Enter;
  try
    if FWorkers.FindItem(nWorker.ModuleInfo.FModuleID) < 0 then
    begin
      FWorkers.AddItem(nWorker, nWorker.ModuleInfo.FModuleID);
      nWorker.GetExtendMenu(FMenuList);
      FMenuChanged := True;
      //新模块提供的菜单扩展

      if FInitSystemObject then
        InitSystemObject(nWorker.ModuleInfo.FModuleID);
      if FRunSystemObject then
        RunSystemObject(nWorker.ModuleInfo.FModuleID);
      if FBeforeStartServer then
        BeforeStartServer(nWorker.ModuleInfo.FModuleID);
      if FAfterServerStarted then
        AfterServerStarted(nWorker.ModuleInfo.FModuleID);
      //新模块与主程序状态同步
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-11-22
//Parm: 模块路径
//Desc: 载入nFile模块到管理器
function TPlugManager.UpdatePlug(const nFile: string; var nHint: string): Boolean;
begin
  nHint := LoadPlugFile(nFile);
  Result := nHint = '';
end;

//Date: 2013-11-22
//Parm: 模块目录
//Desc: 载入nPath下有效的模块到管理器
procedure TPlugManager.LoadPlugsInDirectory(nPath: string);
var nStr: string;
    nRes: Integer;
    nRec: TSearchRec;
begin
  if Copy(nPath, Length(nPath), 1) <> '\' then
    nPath := nPath + '\';
  //regular path

  nRes := FindFirst(nPath + '*.dll', faAnyFile, nRec);
  try
    while nRes = 0 do
    begin
      if (Pos('0_', nRec.Name) <> 1) then
      begin
        nStr := LoadPlugFile(nPath + nRec.Name);
        if nStr <> '' then
          WriteLog(nStr);
        //xxxxx
      end;

      nRes := FindNext(nRec);
    end;
  finally
    FindClose(nRec);
  end;
end;

initialization
  gPlugManager := nil;
finalization
  FreeAndNil(gPlugManager);
end.
