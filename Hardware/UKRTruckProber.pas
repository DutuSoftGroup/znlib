{*******************************************************************************
  ����: fendou116688@163.com 2014/12/10
  ����: ����������ҵ�������������
*******************************************************************************}
unit UKRTruckProber;

interface
uses
  Windows, SysUtils, IniFiles, Classes, SyncObjs, UWaitItem,ULibFun,
  NativeXml, IdTCPServer, USysLoger;
const
  GKRDoutBit     = 'DoutBit';
  GKRReadByte    = 'ReadByte';
  GKRWriteByte   = 'WriteByte';
  GKRTimeDelay   = 'TimeDelay';
  GKROpenDevice  = 'OpenDevice';
  GKRCloseDevice = 'CloseDevice';

  GKRDevTruckPrb = 'kpci800.dll';
  cProber_NullASCII= $30;       //ASCII���ֽ�
  cProber_Query_Interval= 2000;      //��ѯ���
  
type
  TTruckProber = record
    FDevIndex : Integer;
    FDevEnable: Boolean;
    FDevStatus: Boolean;
  end;
  TTruckProberList = array of TTruckProber;

  { TKRTruckProber }
  TCloseDevice= procedure(nIndex: Longint); stdcall;
  TTimeDelay  = procedure(nDelaytime: longint); stdcall;
  TOpenDevice = function (nIndex: Integer): Boolean; stdcall;

  TDoutBit    = procedure(nIndex:longint;nChannel,nDoch:byte); stdcall;
  TReadByte   = function (nIndex:longint;nDich:byte):byte; stdcall;
  TWriteByte  = procedure(nIndex:longint;nDoch:Integer;nByte:byte);stdcall;

  TKRTruckProber = class(TObject)
  private
    FFilePath : string;
    FLibFName : string;
    FLibFPath : string;
    FLibhandle: THandle;

    //������ƺ�����
    FDoutBit:  TDoutBit;
    FReadByte: TReadByte;
    FWriteByte: TWriteByte;
    FTimeDelay: TTimeDelay;
    FOpenDevice: TOpenDevice;
    FCloseDevice: TCloseDevice;

    //�����豸�б�,ͬ����
    FDevList: TTruckProberList;
    FSyncLock: TCriticalSection;

  protected
    procedure InsertList(nItem:TTruckProber);overload;
    procedure InsertList(nDevIndex:Integer; nDevStatus:Boolean=TRUE;
                         nDevEnable:Boolean=TRUE);overload;
    //�����б�

    procedure DeleteItem(nDevIndex:Integer);overload;
    procedure UpdateStatus(nDevIndex:Integer; nDevStatus:Boolean=TRUE);

    function  DevIndexof(nItem: TTruckProber): Integer;
    function  FindDevItem(nDevIndex: Integer; var nItem: TTruckProber): Integer;

  public
    constructor Create;overload;
    constructor Create(var nMsg: string);overload;
    destructor Destroy; override;

    procedure CloseDevice(nIndex: LongInt; var nMsg:string);
    procedure TimeDelay (nDelaytime: LongInt; var nMsg:string);
    function  OpenDevice(nIndex: Integer; var nMsg:string): Boolean;

    function  ReadByte(nIndex:longint;nDich:byte;var nMsg:string):byte;
    procedure DoutBit(nIndex:longint;nChannel,nDoch:byte;var nMsg:string);
    procedure WriteByte(nIndex:longint;nDoch:Integer;nByte:byte;var nMsg:string);

    function ReadTProber(nIndex,nDich:Integer;var nMsg:string):Byte;
    procedure WriteTProber(nIndex:Integer;nByte:Byte;var nMsg:string);
  published

  end;

{ TKRMgrProber }
  TKRProberIOAddress = array[0..7] of Byte;
  //in-out address

  PKRProberHost = ^TKRProberHost;
  TKRProberHost = record
    FID      : string;               //��ʶ
    FName    : string;               //����
    FDevno   : Int64;
    FEnable  : Boolean;              //�Ƿ�����
  end;

  PKRProberTunnel = ^TKRProberTunnel;
  TKRProberTunnel = record
    FID      : string;               //��ʶ
    FName    : string;               //����
    FHost    : PKRProberHost;          //��������
    FIn      : TKRProberIOAddress;     //�����ַ
    FOut     : TKRProberIOAddress;     //�����ַ
    FEnable  : Boolean;              //�Ƿ�����
  end;

  TKRProberHosts = array of TKRProberHost;
  //array of host
  TKRProberTunnels = array of TKRProberTunnel;
  //array of tunnel

  TKRMgrProber = class(TObject)
  private

  protected
    FKRProber: TKRTruckProber;
    //��������豸

    FInSignalOn: Byte;
    FInSignalOff: Byte;
    FOutSignalOn: Byte;
    FOutSignalOff: Byte;
    //��������ź�

    FHosts: TKRProberHosts;
    FTunnels: TKRProberTunnels;
    //ͨ���б�

    procedure SplitAddr(var nAddr: TKRProberIOAddress; const nStr: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadConfig(const nFile: string);
    //��ȡ����
    function OpenTunnel(const nTunnel: string): Boolean;
    function CloseTunnel(const nTunnel: string): Boolean;
    function TunnelOC(const nTunnel: string; nOC: Boolean): string;
    //����ͨ��
    function GetTunnel(const nTunnel: string): PKRProberTunnel;
    procedure EnableTunnel(const nTunnel: string; const nEnabled: Boolean);
    function QueryStatus(const nHost: PKRProberHost;
      var nIn,nOut: TKRProberIOAddress): string;
    function IsTunnelOK(const nTunnel: string): Boolean;
    //��ѯ״̬

    property Hosts: TKRProberHosts read FHosts;
    //�������
  published

  end;

var
  gKRMgrProber: TKRMgrProber; 

implementation

procedure WriteLog(const nEvent: string);
begin
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create(ExtractFilePath(ParamStr(0))  + 'Log\');
  gSysLoger.AddLog(TKRMgrProber, '����������', nEvent);
end;

constructor TKRTruckProber.Create(var nMsg: string);
var
  nIni: TInifile;
begin
  nMsg := '';

  SetLength(FDevList, 0);
  FSyncLock := TCriticalSection.Create;

  FFilePath := ExtractFilePath(ParamStr(0));
  nIni := TIniFile.Create(FFilePath + 'Config.ini');
  try
    if not Assigned(nIni) then Exit;
    FLibFPath := nIni.ReadString('TruckProber', 'DevFPath', FFilePath);
    FLibFName := nIni.ReadString('TruckProber', 'DevFName', GKRDevTruckPrb);

    FLibhandle := SafeLoadLibrary(FLibFPath + FLibFName);
    if FLibhandle=0 then
    begin
      nMsg:=Format('��̬��[%s]����ʧ��,�����Ƿ����',[FLibFPath + FLibFName]);
      Exit;
    end;

    FDoutBit    := GetProcAddress(FLibhandle, GKRDoutBit);
    FReadByte   := GetProcAddress(FLibhandle, GKRReadByte);
    FWriteByte  := GetProcAddress(FLibhandle, GKRWriteByte);
    FTimeDelay  := GetProcAddress(FLibhandle, GKRTimeDelay);
    FOpenDevice := GetProcAddress(FLibhandle, GKROpenDevice);
    FCloseDevice:= GetProcAddress(FLibhandle, GKRCloseDevice);
  finally
    FreeAndNil(nIni);
  end;
end;

constructor TKRTruckProber.Create;
var
  nMsg: string;
begin
  Create(nMsg);
end;

destructor TKRTruckProber.Destroy;
var
  nIndex: Integer;
begin
  FSyncLock.Enter;
  try
    if Assigned(FCloseDevice) then
      for nIndex:=0 to Length(FDevList)-1 do
        if FDevList[nIndex].FDevStatus then
        begin
           FCloseDevice(FDevList[nIndex].FDevIndex);
        end;  

    SetLength(FDevList, 0);
  finally
    FSyncLock.Leave;
  end;

  FSyncLock.Free;
  FreeLibrary(FLibhandle);
  inherited;
end;

//Date: 2014/12/11
//Parm: �豸���;����ַ���(0:����������������/1:�ض��̵���״̬����);������Ϣ
//Desc: ��ȡ�ĵ��ֽ�����,��8������λ
//      �����رպ�ʱ������˿�Ϊ���ź����룬�������Ӧ����λΪ��0��;
//      �����ضϿ�ʱ������˿�û���ź����룬�������Ӧ����λΪ��1����
function TKRTruckProber.ReadTProber(nIndex,nDich:Integer;var nMsg:string):Byte;
begin
  Result := ReadByte(nIndex, nDich, nMsg);
end;

//Date: 2014/12/11
//Parm: �豸���;д��ַ���(0ǿ��ֵ);�������;������Ϣ
//Desc: �ú�����˿�дһ���ֽ�nBtye,��8������λ
//      ����������λΪ��1��ʱ���̵������ϣ�����������λΪ��0��ʱ���̵����Ͽ���
procedure TKRTruckProber.WriteTProber(nIndex:Integer;nByte:Byte;var nMsg:string);
begin
  WriteByte(nIndex,0,nByte,nMsg);
end;

function TKRTruckProber.OpenDevice(nIndex: Integer; var nMsg:string): Boolean;
var
  nItem: TTruckProber;
begin
  if not Assigned(FOpenDevice) then
  begin
     nMsg := Format('�����ӿ�[%s]������', [GKROpenDevice]);
     Result:=False;Exit;
  end;

  if (FindDevItem(nIndex, nItem)>0) and (nItem.FDevStatus) then
  begin
    Result:=TRUE;nMsg := '�豸�Ѵ�';Exit;
  end;

  Result := FOpenDevice(nIndex);
  if not Result then
  begin
    nMsg := '�豸��ʧ��';Exit;
  end;
  InsertList(nIndex, Result);
end;

procedure TKRTruckProber.CloseDevice(nIndex: Integer; var nMsg:string);
var
  nItem: TTruckProber;
begin
  if not Assigned(FCloseDevice) then
  begin
     nMsg := Format('�����ӿ�[%s]������', [GKRCloseDevice]); Exit;
  end;

  if (FindDevItem(nIndex, nItem)<0) or (not nItem.FDevStatus) then
  begin
     nMsg := '�豸δ��';Exit;
  end;

  FCloseDevice(nIndex);
  DeleteItem(nIndex);
end;

procedure TKRTruckProber.TimeDelay(nDelaytime: LongInt; var nMsg:string);
begin
  if not Assigned(FTimeDelay) then
  begin
     nMsg := Format('�����ӿ�[%s]������', [GKRTimeDelay]); Exit;
  end;

  FTimeDelay(nDelaytime);
end;

function TKRTruckProber.ReadByte(nIndex:longint;nDich:byte;var nMsg:string):byte;
var
  nItem: TTruckProber;
begin
  if not Assigned(FReadByte) then
  begin
     nMsg := Format('�����ӿ�[%s]������', [GKRReadByte]);
     Result:=0;Exit;
  end;

  if (FindDevItem(nIndex, nItem)<0) or (not nItem.FDevStatus) then
  begin
     Result:=0;nMsg := '�豸δ��';Exit;
  end;

  Result := FReadByte(nIndex, nDich);
end;

//Date: 2014/12/11
//Parm: �豸���;ͨ�����;��������;������Ϣ
//Desc: �ú����򿪹������ָ��ͨ�����һ��״̬����Ч��������ʹ��
procedure TKRTruckProber.DoutBit(nIndex:longint;nChannel,nDoch:byte;
  var nMsg:string);
var
  nItem: TTruckProber;
begin
  if not Assigned(FReadByte) then
  begin
     nMsg := Format('�����ӿ�[%s]������', [GKRReadByte]);Exit;
  end;

  if (FindDevItem(nIndex, nItem)<0) or (not nItem.FDevStatus) then
  begin
     nMsg := '�豸δ��';Exit;
  end;

  FDoutBit(nIndex, nChannel, nDoch);
end;

procedure TKRTruckProber.WriteByte(nIndex:longint;nDoch:Integer;nByte:byte;
  var nMsg:string);
var
  nItem: TTruckProber;
begin
  if not Assigned(FWriteByte) then
  begin
     nMsg := Format('�����ӿ�[%s]������', [GKRWriteByte]); Exit;
  end;

  if (FindDevItem(nIndex, nItem)<0) or (not nItem.FDevStatus) then
  begin
     nMsg := '�豸δ��';Exit;
  end;

  FWriteByte(nIndex, nDoch, nByte);
end;

function  TKRTruckProber.DevIndexof(nItem: TTruckProber): Integer;
var
  nIndex: Integer;
begin
  Result := -1;
  if Length(FDevList)=0 then Exit;

  FSyncLock.Enter;
  try
    for nIndex:=0 to Length(FDevList)-1 do
      if FDevList[nIndex].FDevIndex = nItem.FDevIndex then
      begin
        FDevList[nIndex].FDevStatus := nItem.FDevStatus;
        Result := nIndex; Break;
      end;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TKRTruckProber.InsertList(nDevIndex:Integer; nDevStatus:Boolean=TRUE;
  nDevEnable:Boolean=TRUE);
var
  nItem: TTruckProber;
begin
  nItem.FDevIndex := nDevIndex;
  nItem.FDevEnable:= nDevEnable;
  nItem.FDevStatus:= nDevStatus;

  InsertList(nItem);    
end;  

procedure TKRTruckProber.InsertList(nItem: TTruckProber);
var
  nLen: Integer;
begin
  if DevIndexof(nItem)>0 then Exit;

  FSyncLock.Enter;
  try
    nLen := Length(FDevList);
    SetLength(FDevList, nLen+1);

    FDevList[nLen] := nItem;
  finally
    FSyncLock.Leave;
  end;
end;

function TKRTruckProber.FindDevItem(nDevIndex: Integer;
  var nItem: TTruckProber): Integer;
var
  nIndex: Integer;
begin
  Result := -1;
  if Length(FDevList)=0 then Exit;

  FSyncLock.Enter;
  try
    for nIndex:=0 to Length(FDevList)-1 do
      if FDevList[nIndex].FDevIndex = nDevIndex then
      begin
        Result := nIndex;
        nItem  := FDevList[nIndex]; Break;
      end;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TKRTruckProber.UpdateStatus(nDevIndex:Integer;nDevStatus:Boolean=TRUE);
var
  nItem: TTruckProber;
begin
  nItem.FDevIndex := nDevIndex;
  nItem.FDevEnable:= nDevStatus;

  DevIndexof(nItem);
end;

procedure TKRTruckProber.DeleteItem(nDevIndex:Integer);
var
  nLen, nIndex, nIndex2: Integer;
begin
  nLen:=Length(FDevList);
  if nLen=0 then Exit;

  FSyncLock.Enter;
  try
    for nIndex:=0 to nLen-1 do
      if FDevList[nIndex].FDevIndex = nDevIndex then
      begin
        for nIndex2:=nIndex to nLen-2 do
          FDevList[nIndex2] := FDevList[nIndex2+1];
        SetLength(FDevList, nLen-1);
        Break;
      end;
  finally
    FSyncLock.Leave;
  end;
end;
//------------------------------------------------------------------------------
constructor TKRMgrProber.Create;
var
  nMsg: string;
begin
  FKRProber := TKRTruckProber.Create(nMsg);
end;

destructor TKRMgrProber.Destroy;
begin
  FKRProber.Free;
  inherited;
end;

//Desc: ����nFile�����ļ�
procedure TKRMgrProber.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nHost: PKRProberHost;
    nNode,nTmp: TXmlNode;
    i,nIdx,nNum: Integer; nMsg: string;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    //load config

    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nNode := nXML.Root.Nodes[nIdx];
      nNum := Length(FHosts);
      SetLength(FHosts, nNum + 1);

      with FHosts[nNum],nNode do
      begin
        FID    := AttributeByName['id'];
        FName  := AttributeByName['name'];
        FEnable := NodeByName('enable').ValueAsInteger = 1;

        nTmp  := FindNode('device');
        if not Assigned(nTmp) then FDevno := 0
        else FDevno := nTmp.ValueAsInteger;
        //�豸���Ĭ��Ϊ0
      end;

      nTmp := nNode.FindNode('signal_in');
      if Assigned(nTmp) then
      begin
        FInSignalOn := StrToInt(nTmp.AttributeByName['on']);
        FInSignalOff := StrToInt(nTmp.AttributeByName['off']);
      end else
      begin
        FInSignalOn := $00;
        FInSignalOff := $01;
      end;

      nTmp := nNode.FindNode('signal_out');
      if Assigned(nTmp) then
      begin
        FOutSignalOn := StrToInt(nTmp.AttributeByName['on']);
        FOutSignalOff := StrToInt(nTmp.AttributeByName['off']);
      end else
      begin
        FOutSignalOn := $00;
        FOutSignalOff := $01;
      end;

      nTmp := nNode.FindNode('tunnels');
      if not Assigned(nTmp) then Continue;
      nHost := @FHosts[nNum];

      for i:=0 to nTmp.NodeCount - 1 do
      begin
        nNode := nTmp.Nodes[i];
        nNum := Length(FTunnels);
        SetLength(FTunnels, nNum + 1);

        with FTunnels[nNum],nNode do
        begin
          FID    := AttributeByName['id'];
          FName  := AttributeByName['name'];
          FHost  := nHost;
          
          SplitAddr(FIn, NodeByName('in').ValueAsString);
          SplitAddr(FOut, NodeByName('out').ValueAsString);

          nNode := nNode.FindNode('enable');
          FEnable := (not Assigned(nNode)) or (nNode.ValueAsString <> '0');
        end;
      end;
    end;

    for i:=Low(FTunnels) to High(FTunnels) do
    if FTunnels[i].FEnable and FTunnels[i].FHost.FEnable then
    if not FKRProber.OpenDevice(FTunnels[i].FHost.FDevno, nMsg) then
      WriteLog(Format('ͨ��[%s]���豸ʧ��',[FTunnels[i].FID]));

  finally
    nXML.Free;
  end;
end;

//Date��2014-5-13
//Parm��ͨ����;True=Open,False=Close
//Desc����nTunnelִ�п��ϲ���,���д����򷵻�
function TKRMgrProber.TunnelOC(const nTunnel: string; nOC: Boolean): string;
var nByte: Byte;
    i,nIdx: Integer;
    nMessage: string;
    nPTunnel: PKRProberTunnel;
begin
  Result := '';
  nPTunnel := GetTunnel(nTunnel);

  if not Assigned(nPTunnel) then
  begin
    Result := 'ͨ��[ %s ]�����Ч.';
    Result := Format(Result, [nTunnel]); Exit;
  end;

  if not (nPTunnel.FEnable and nPTunnel.FHost.FEnable ) then Exit;
  //������,������

  i := 0;nByte := 0;
  for nIdx:=Low(nPTunnel.FOut) to High(nPTunnel.FOut) do
    if nPTunnel.FOut[nIdx] <> cProber_NullASCII then
    begin
       Inc(i);
       if nOC then
        nByte := nByte or (FOutSignalOn shl ((nPTunnel.FOut[nIdx] and $0F)-1))
       else
        nByte := nByte or (FOutSignalOff shl ((nPTunnel.FOut[nIdx] and $0F)-1));
    end;
  //xxxxx

  if i < 1 then Exit;
  //�������ַ,��ʾ��ʹ���������

  FKRProber.WriteTProber(nPTunnel.FHost.FDevno, nByte, nMessage);

  Result := nMessage;
end;

//Date: 2014/12/12
//Parm��ͨ����
//Desc����nTunnelִ�����ϲ���
function TKRMgrProber.OpenTunnel(const nTunnel: string): Boolean;
var nStr: string;
begin
  nStr := TunnelOC(nTunnel, False);
  Result := nStr = '';

  if not Result then
    WriteLog(nStr);
  //xxxxxx
end;

//Date: 2014/12/12
//Parm��ͨ����
//Desc����nTunnelִ�жϿ�����
function TKRMgrProber.CloseTunnel(const nTunnel: string): Boolean;
var nStr: string;
begin
  nStr := TunnelOC(nTunnel, True);
  Result := nStr = '';

  if not Result then
    WriteLog(nStr);
  //xxxxxx
end;

//Date: 2014/12/12
//Parm: ͨ����;����
//Desc: �Ƿ�����nTunnelͨ��
procedure TKRMgrProber.EnableTunnel(const nTunnel: string;
  const nEnabled: Boolean);
var nPT: PKRProberTunnel;
begin
  nPT := GetTunnel(nTunnel);
  if Assigned(nPT) then
    nPT.FEnable := nEnabled;
  //xxxxx
end;

//Date: 2014/12/12
//Parm������;��ѯ����;����������
//Desc����ѯnHost���������״̬,����nIn nOut.
function TKRMgrProber.QueryStatus(const nHost: PKRProberHost;
  var nIn, nOut: TKRProberIOAddress): string;
var nMsg: string;
    nReadByte: Byte;
    nIdx,nJdx: Integer;
begin
  for nIdx:=Low(TKRProberIOAddress) to High(TKRProberIOAddress) do
  begin
    nIn[nIdx]  := FInSignalOn;
    nOut[nIdx] := FInSignalOn;
  end;

  for nIdx:=Low(FHosts) to High(FHosts) do
  if nHost.FID = FHosts[nIdx].FID then
  begin
    nReadByte := FKRProber.ReadTProber(FHosts[nIdx].FDevno, 1, nMsg);
    if nMsg<>'' then WriteLog('����״̬��ȡʧ��:' + nMsg);
    for nJdx:=Low(TKRProberIOAddress) to High(TKRProberIOAddress) do
    if ((nReadByte shr nJdx) and 1)=1 then nIn[nJdx] := FInSignalOff;

    nReadByte := FKRProber.ReadTProber(FHosts[nIdx].FDevno, 0, nMsg);
    if nMsg<>'' then WriteLog('���״̬��ȡʧ��:' + nMsg);
    for nJdx:=Low(TKRProberIOAddress) to High(TKRProberIOAddress) do
    if ((nReadByte shr nJdx) and 1)=0 then nOut[nJdx] := FInSignalOff;

    Result := nMsg; Exit;
  end;

  Result := Format('���������[ %s ]����Ч.', [nHost.FID]);
end;

//Date: 2014/12/12
//Parm��ͨ����
//Desc����ѯnTunnel�������Ƿ�ȫ��Ϊ���ź�
function TKRMgrProber.IsTunnelOK(const nTunnel: string): Boolean;
var nIdx,nNum: Integer;
    nPT: PKRProberTunnel;
    nReadByte: Byte; nMsg:string;
begin
  Result := False;
  nPT := GetTunnel(nTunnel);

  if not Assigned(nPT) then
  begin
    WriteLog(Format('ͨ��[ %s ]��Ч.',  [nTunnel]));
    Exit;
  end;

  if not (nPT.FEnable and nPT.FHost.FEnable) then
  begin
    Result := True;
    Exit;
  end;

  nNum := 0;
  for nIdx:=Low(nPT.FIn) to High(nPT.FIn) do
   if nPT.FIn[nIdx] <> cProber_NullASCII then Inc(nNum);
  //xxxxx

  if nNum < 1 then //�������ַ,��ʶ��ʹ��������
  begin
    Result := True;
    Exit;
  end;

  nReadByte := FKRProber.ReadTProber(nPT.FHost.FDevno, 0, nMsg);
  for nIdx:=Low(nPT.FIn) to High(nPT.FIn) do
  begin
    if (nPT.FIn[nIdx]=cProber_NullASCII) or (nPT.FIn[nIdx]>8)
      or (nPT.FIn[nIdx]<1) then
      Continue;
    //invalid addr

    if ((nReadByte shr (nPT.FIn[nIdx]-1)) and 1) = FInSignalOn then
    begin
      WriteLog('nIdx:[' +IntToStr(nIdx)+ '];nRead:[' + IntToHex(nReadByte, 2) + ']');
      Exit;
    end;
    //ĳ·�������ź�,��Ϊ����δͣ��
  end;

  Result := True;
end;

procedure TKRMgrProber.SplitAddr(var nAddr: TKRProberIOAddress;
    const nStr: string);
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    SplitStr(nStr, nList, 0 , ',');
    //���
    
    for nIdx:=Low(nAddr) to High(nAddr) do
    begin
      if nIdx < nList.Count then
           nAddr[nIdx] := StrToInt(nList[nIdx])
      else nAddr[nIdx] := cProber_NullASCII;
    end;
  finally
    nList.Free;
  end;
end;

function TKRMgrProber.GetTunnel(const nTunnel: string): PKRProberTunnel;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=Low(FTunnels) to High(FTunnels) do
  if CompareText(nTunnel, FTunnels[nIdx].FID) = 0 then
  begin
    Result := @FTunnels[nIdx];
    Break;
  end;
end;

initialization
  gKRMgrProber := nil;
finalization
  FreeAndNil(gKRMgrProber);
end.

