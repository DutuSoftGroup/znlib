{*******************************************************************************
  ����: dmzn@163.com 2012-2-13
  ����: SAP���ӹ������

  ��ע:
  *.SAPConnectionManager���ڶ�̬����ϵͳ��SAP������.
  *.�����������޵������,����������������Ŷ�;����ֱ�Ӵ���������.
  *.�������ᱣ��һ��������,��֤�ڸ��ز���ʱ��Ч��.
*******************************************************************************}
unit USAPConnection;

interface

uses
  Windows, Classes, ComObj, SysUtils, SyncObjs, UWaitItem, UMgrHashDict,
  USysLoger, SAPLogonCtrl_TLB, SAPFunctionsOCX_TLB;

const
  cErr_SAPConn_NoParam     = $0001;            //�����Ӳ���
  cErr_SAPConn_NoAllowed   = $0002;            //��ֹ����
  cErr_SAPConn_Closing     = $0003;            //�������Ͽ�

type
  PSAPParam = ^TSAPParam;
  TSAPParam = record
    FID   : string;                            //������ʶ
    FName : string;                            //��ʶ����
    FHost : string;                            //������ַ
    FUser : string;                            //�û���
    FPwd  : string;                            //�û�����

    FSystem   : string;                        //ϵͳ��ʶ
    FSysNum   : Integer;                       //ϵͳ���
    FClient   : string;                        //�ն˱�ʶ
    FLang     : string;                        //���Ա�ʶ
    FCodePage : string;                        //
    FEnable   : Boolean;                       //�Ƿ���Ч
  end;

  PSAPConnection = ^TSAPConnection;
  TSAPConnection = record
    FID        : string;                       //���ӱ�ʶ
    FConn      : Connection;                   //���Ӷ���
    FFunction  : TSAPFunctions;                //��������
    FUsed      : Integer;                      //�ŶӼ���
    FLock      : TCriticalSection;             //ͬ������
    FWaiter    : TWaitObject;                  //�ӳٶ���
    FLast      : Cardinal;                     //�ϴ�ʹ��
  end;

  PSAPConnStatus = ^TSAPConnStatus;
  TSAPConnStatus = record
    FNumConnRequest: Cardinal;                 //������������
    FNumRequestErr: Cardinal;                  //����������
    FNumConnParam: Integer;                    //���Ӳ�������
    FNumConnItem: Integer;                     //���������
    FNumConned: Integer;                       //�����Ӷ���(Connection)����
    FNumConnTotal: Cardinal;                   //�����ܴ���
    FNumConnMax: Integer;                      //����������
    FTimeConnMax: TDateTime;                   //���ӷ�ֵʱ��
    FNumReUsed: Cardinal;                      //�����ظ�ʹ�ô���
    FNumWait: Integer;                         //�Ŷ��ж���(Item.FUsed)����
    FNumWaitMax: Integer;                      //�Ŷ�����������ж������
    FTimeWaitMax: TDateTime;                    //�Ŷ����ʱ��
  end;

  TSAPConnectionManager = class(TObject)
  private
    FConnClosing: Integer;
    FAllowedRequest: Integer;
    FSyncLock: TCriticalSection;
    //ͬ����
    FParams: array of TSAPParam;
    //�����б�
    FConnItems: TList;
    //�����б�
    FConnFactory: TSAPLogonControl;
    //���ӳ�
    FStatus: TSAPConnStatus;
    //����״̬
  protected
    procedure ClearConnItems(const nFreeMe: Boolean);
    //��������
    function GetRunStatus: TSAPConnStatus;
    //��ȡ״̬
    procedure CloseConnection(const nConn: PSAPConnection);
    //�ر�����
    procedure DoLogon(Sender: TObject; const nConn: IDispatch);
    procedure DoLogoff(Sender: TObject; const nConn: IDispatch);
    //�¼���
    procedure WriteLog(const nLog: string);
    //��¼��־
    function GetPoolSize: Integer;
    procedure SetPoolSize(const nValue: Integer);
    //�ض�����
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure AddParam(const nParam: TSAPParam);
    procedure DelParam(const nID: string = '');
    procedure ClearParam;
    //��������
    function GetConnection(const nID: string; var nErrCode: Integer): PSAPConnection;
    function GetConnLoop(const nID: string; var nErrCode: Integer): PSAPConnection;
    procedure ReleaseConnection(const nConn: PSAPConnection);
    procedure ClearAllConnection;
    //ʹ������
    property Status: TSAPConnStatus read GetRunStatus;
    property PoolSize: Integer read GetPoolSize write SetPoolSize;
    //�������
  end;

var
  gSAPConnectionManager: TSAPConnectionManager = nil;
  //ȫ��ʹ��

implementation

const
  cTrue  = $1101;
  cFalse = $1105;
  //��������

resourcestring
  sNoAllowedWhenRequest = '���ӳض����ͷ�ʱ�յ�����,�Ѿܾ�.';
  sClosingWhenRequest   = '���ӳض���ر�ʱ�յ�����,�Ѿܾ�.';
  sNoParamWhenRequest   = '���ӳض����յ�����,����ƥ�����.';

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

//Desc: ��ȡ����״̬
function TSAPConnectionManager.GetRunStatus: TSAPConnStatus;
begin
  FSyncLock.Enter;
  try
    Result := FStatus;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: �ͷ����Ӷ���
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
//Parm: ������
//Desc: ������ֻ�������̵���,����������ǰ
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

//Desc: ���ӳض������
function TSAPConnectionManager.GetPoolSize: Integer;
begin
  FSyncLock.Enter;
  try
    Result := FConnItems.Count;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: �ر�ָ������
procedure TSAPConnectionManager.CloseConnection(const nConn: PSAPConnection);
begin
  //�ó���,�ȴ����������ͷ�
  FSyncLock.Leave;
  try
    while nConn.FUsed > 0 do
      nConn.FWaiter.EnterWait;
    //�ȴ������˳�
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

//Desc: �������Ӷ���
procedure TSAPConnectionManager.ClearConnItems(const nFreeMe: Boolean);
var nIdx: Integer;
begin
  if nFreeMe then
    InterlockedExchange(FAllowedRequest, cFalse);
  //����ر�

  FSyncLock.Enter;
  try
    InterlockedExchange(FConnClosing, cTrue);
    //�رձ��

    for nIdx:=FConnItems.Count - 1 downto 0 do
      CloseConnection(FConnItems[nIdx]);
    //�Ͽ�ȫ������

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
//Parm: ���Ӳ���
//Desc: ���һ��nParam����
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
//Parm: ������ʶ
//Desc: ɾ����ʶΪnID�Ĳ���
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
//Desc: ��ղ���
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
//Parm: ��־����
//Desc: ��¼nLog��־
procedure TSAPConnectionManager.WriteLog(const nLog: string);
begin
  if Assigned(gSysLoger) then
    gSysLoger.AddLog(TSAPConnectionManager, 'SAP���ӳ�', nLog);
  //xxxxx
end;

//Date: 2012-2-16
//Parm: ���ӱ�ʶ;������
//Desc: ����nID���õ�SAP���Ӷ���
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
    //�ظ��ж�,����Get��close���������ص�(get.enter��close.enter�������ȴ�)

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
      //����������
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
    //������������Ŷ�

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
//Parm: ���ӱ�ʶ;������
//Desc: ����nID���õ�SAP���Ӷ���,��ʧ�����Զ�λ�ȡ
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
//Parm: ���Ӷ���
//Desc: �ͷ�nConnection���Ӷ���
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
//Desc: �ر���������
procedure TSAPConnectionManager.ClearAllConnection;
begin
  ClearConnItems(False);
end;

initialization
  gSAPConnectionManager := nil;
finalization
  FreeAndNil(gSAPConnectionManager);
end.
