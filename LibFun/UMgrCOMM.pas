{*******************************************************************************
  作者: dmzn@163.com 2010-4-22
  描述: 串口管理
*******************************************************************************}
unit UMgrCOMM;

interface

uses
  Windows, Classes, SysUtils, ULibFun, Registry, WinSpool;

function IsValidCOMPort(const nCOM: string): Boolean;
//端口可连接
function GetCOMPortNames(const nList: TStrings): Boolean;
function GetValidCOMPort(const nList: TStrings): Boolean;
//枚举系统端口

implementation

//------------------------------------------------------------------------------
//Desc: 尝试连接nCom端口
function IsValidCOMPort(const nCOM: string): Boolean;
var nFile: THandle;
begin
  nFile := INVALID_HANDLE_VALUE;
  try
    nFile := CreateFile( PChar('\\.\' + nCOM),
             GENERIC_READ or GENERIC_WRITE,
             0, {not shared}
             nil, {no security ??}
             OPEN_EXISTING,
             FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED,
             0 {template} );
    //xxxxx

    Result := nFile <> INVALID_HANDLE_VALUE;
    if Result then CloseHandle(nFile);
  except
    if nFile <> INVALID_HANDLE_VALUE then
      CloseHandle(nFile);
    Result := False;
  end;
end;

//Date: 2009-12-06
//Parm: 结果列表
//Desc: 通过查注册表获取USB串口
function EnumUSBPort(const nList: TStrings): Boolean;
var nStr: string;
    nReg: TRegistry;
    nTmp: TStrings;
    i,nCount: integer;
begin
  Result := False;
  nTmp := nil;
  nReg := TRegistry.Create;
  try
    nReg.RootKey := HKEY_LOCAL_MACHINE;
    if nReg.OpenKeyReadOnly('HARDWARE\DEVICEMAP\SERIALCOMM\') then
    begin
      nTmp := TStringList.Create;
      nReg.GetValueNames(nTmp);
      nCount := nTmp.Count - 1;

      for i:=0 to nCount do
      begin
        nStr := nReg.ReadString(nTmp[i]);
        if Pos('COM', nStr) = 1 then
        begin
          nStr := 'COM' + IntToStr(SplitIntValue(nStr));
          if nList.IndexOf(nStr) < 0 then nList.Add(nStr);
        end;
      end;

      nReg.CloseKey;
      Result := True;
    end;
  finally
    nTmp.Free;
    nReg.Free;
  end;
end;

//Date: 2009-7-9
//Parm: 列表
//Desc: 获取并口列表
function GetComPortNames(const nList: TStrings): Boolean;
var nStr: string;
    nBuffer: Pointer;
    nInfoPtr: PPortInfo1;
    nIdx,nBytesNeeded,nReturned: DWORD;
begin
  nList.Clear;
  nBuffer := nil;
  Result := EnumPorts(nil, 1, nil, 0, nBytesNeeded, nReturned);

  if (not Result) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
  try
    GetMem(nBuffer, nBytesNeeded);
    Result := EnumPorts(nil, 1, nBuffer, nBytesNeeded, nBytesNeeded, nReturned);

    if Result then
    begin
      for nIdx := 0 to nReturned - 1 do
      begin
        nInfoPtr := PPortInfo1(DWORD(nBuffer) + nIdx * SizeOf(TPortInfo1));
        nStr := nInfoPtr^.pName;

        if Pos('COM', nStr) = 1 then
        begin
          nStr := 'COM' + IntToStr(SplitIntValue(nStr));
          if nList.IndexOf(nStr) < 0 then nList.Add(nStr);
        end;
      end;
    end;
  finally
    FreeMem(nBuffer);
  end;

  EnumUSBPort(nList);
  //补充USB转串口
  Result := nList.Count > 0;
end;

//------------------------------------------------------------------------------
const
  MAX_DETAIL_BUFF_LEN   = 256;
  SetupApiModuleName    = 'SetupApi.dll';

const
  ANYSIZE_ARRAY         = 1;
  {$EXTERNALSYM ANYSIZE_ARRAY}

  DIGCF_PRESENT         = $00000002;
  {$EXTERNALSYM DIGCF_PRESENT}
  DIGCF_DEVICEINTERFACE = $00000010;
  {$EXTERNALSYM DIGCF_DEVICEINTERFACE}

  SPDRP_FRIENDLYNAME    = $0000000C; // FriendlyName (R/W)
  {$EXTERNALSYM SPDRP_FRIENDLYNAME}
  GUID_CLASS_COMPORT: TGUID = (
    D1:$86e0d1e0; D2:$8089; D3:$11d0; D4:($9c, $e4, $08, $00, $3e, $30, $1f, $73));
  {$EXTERNALSYM GUID_CLASS_COMPORT}
  
type
  HDEVINFO = Pointer;
  {$EXTERNALSYM HDEVINFO}

  ULONG_PTR = DWORD;
  {$EXTERNALSYM ULONG_PTR}

//
// Device information structure (references a device instance
// that is a member of a device information set)
//
  PSPDevInfoData = ^TSPDevInfoData;
  SP_DEVINFO_DATA = packed record
    cbSize: DWORD;
    ClassGuid: TGUID;
    DevInst: DWORD; // DEVINST handle
    Reserved: ULONG_PTR;
  end;
  {$EXTERNALSYM SP_DEVINFO_DATA}
  TSPDevInfoData = SP_DEVINFO_DATA;
  
//
// Device interface information structure (references a device
// interface that is associated with the device information
// element that owns it).
//
  PSPDeviceInterfaceData = ^TSPDeviceInterfaceData;
  SP_DEVICE_INTERFACE_DATA = packed record
    cbSize: DWORD;
    InterfaceClassGuid: TGUID;
    Flags: DWORD;
    Reserved: ULONG_PTR;
  end;
  {$EXTERNALSYM SP_DEVICE_INTERFACE_DATA}
  TSPDeviceInterfaceData = SP_DEVICE_INTERFACE_DATA;

  PSPDeviceInterfaceDetailDataA = ^TSPDeviceInterfaceDetailDataA;
  PSPDeviceInterfaceDetailDataW = ^TSPDeviceInterfaceDetailDataW;
  PSPDeviceInterfaceDetailData = PSPDeviceInterfaceDetailDataA;
  SP_DEVICE_INTERFACE_DETAIL_DATA_A = packed record
    cbSize: DWORD;
    DevicePath: array [0..ANYSIZE_ARRAY - 1] of AnsiChar;
  end;
  {$EXTERNALSYM SP_DEVICE_INTERFACE_DETAIL_DATA_A}
  SP_DEVICE_INTERFACE_DETAIL_DATA_W = packed record
    cbSize: DWORD;
    DevicePath: array [0..ANYSIZE_ARRAY - 1] of WideChar;
  end;
  {$EXTERNALSYM SP_DEVICE_INTERFACE_DETAIL_DATA_W}
  TSPDeviceInterfaceDetailDataA = SP_DEVICE_INTERFACE_DETAIL_DATA_A;
  TSPDeviceInterfaceDetailDataW = SP_DEVICE_INTERFACE_DETAIL_DATA_W;
  TSPDeviceInterfaceDetailData = TSPDeviceInterfaceDetailDataA;

function SetupDiGetClassDevs(ClassGuid: PGUID; const Enumerator: PChar;
  hwndParent: HWND; Flags: DWORD): HDEVINFO; stdcall;
  external SetupApiModuleName name 'SetupDiGetClassDevsA';
{$EXTERNALSYM SetupDiGetClassDevs}

function SetupDiEnumDeviceInterfaces(DeviceInfoSet: HDEVINFO;
  DeviceInfoData: PSPDevInfoData; const InterfaceClassGuid: TGUID;
  MemberIndex: DWORD; var DeviceInterfaceData: TSPDeviceInterfaceData): LongBool; stdcall;
  external SetupApiModuleName name 'SetupDiEnumDeviceInterfaces';
{$EXTERNALSYM SetupDiEnumDeviceInterfaces}

function SetupDiGetDeviceInterfaceDetail(DeviceInfoSet: HDEVINFO;
  DeviceInterfaceData: PSPDeviceInterfaceData;
  DeviceInterfaceDetailData: PSPDeviceInterfaceDetailDataA;
  DeviceInterfaceDetailDataSize: DWORD; var RequiredSize: DWORD;
  Device: PSPDevInfoData): LongBool; stdcall;
  external SetupApiModuleName name 'SetupDiGetDeviceInterfaceDetailA';
{$EXTERNALSYM SetupDiGetDeviceInterfaceDetail}

function SetupDiGetDeviceRegistryProperty(DeviceInfoSet: HDEVINFO;
  const DeviceInfoData: TSPDevInfoData; Property_: DWORD;
  var PropertyRegDataType: DWORD; PropertyBuffer: PBYTE; PropertyBufferSize: DWORD;
  var RequiredSize: DWORD): LongBool; stdcall;
  external SetupApiModuleName name 'SetupDiGetDeviceRegistryPropertyA';
{$EXTERNALSYM SetupDiGetDeviceRegistryProperty}

function SetupDiDestroyDeviceInfoList(DeviceInfoSet: HDEVINFO): LongBool; stdcall;
  external SetupApiModuleName name 'SetupDiDestroyDeviceInfoList';
{$EXTERNALSYM SetupDiDestroyDeviceInfoList}

//Desc: win2k或更版本
function Win2K_EnumCOMPort(const nList: TStrings): Boolean;
var nStr: string;
    nIdx: Integer;
    nRSize: DWORD;
    nBool: Boolean;
    nBuf,nName: array[0..MAX_DETAIL_BUFF_LEN-1] of Char;

    nGUID: TGUID;
    nPInfo: HDEVINFO;
    nDevData: TSPDevInfoData;
    nData: TSPDeviceInterfaceData;
    nDtlData: PSPDeviceInterfaceDetailData;
begin
  Result := False;
  nList.Clear;
  nPInfo := nil;
  try
    nGUID := GUID_CLASS_COMPORT;
    nPInfo := SetupDiGetClassDevs(@nGUID, nil, 0,
              DIGCF_PRESENT or DIGCF_DEVICEINTERFACE);
    if not Assigned(nPInfo) then Exit;

    nIdx := 0;
    nBool := True;

    while nBool do
    begin
      nData.cbSize := SizeOf(nData);
      nBool := SetupDiEnumDeviceInterfaces(nPInfo, nil, nGUID, nIdx, nData);
      if not nBool then Continue;

      FillChar(nBuf, MAX_DETAIL_BUFF_LEN, #0);
      nDtlData := @nBuf;
      nDtlData.cbSize := SizeOf(TSPDeviceInterfaceDetailData);
      nDevData.cbSize := SizeOf(nDevData);

      nBool := SetupDiGetDeviceInterfaceDetail(nPInfo, @nData, @nBuf,
               MAX_DETAIL_BUFF_LEN, nRSize, @nDevData);
      if not nBool then Continue;

      FillChar(nName, MAX_DETAIL_BUFF_LEN, #0);
      if SetupDiGetDeviceRegistryProperty(nPInfo, nDevData, SPDRP_FRIENDLYNAME,
         nRSize, @nName, MAX_DETAIL_BUFF_LEN, nRSize) then
      begin
        nStr := nName;
        System.Delete(nStr, 1, Pos('(', nStr));
        nStr := Copy(nStr, 1, Pos(')', nStr) - 1);
        nList.Add(nStr);
      end;

      Inc(nIdx);
    end;

    SetupDiDestroyDeviceInfoList(nPInfo);
    //free resource
    Result := nList.Count > 0;
  except
    if not Assigned(nPInfo) then
      SetupDiDestroyDeviceInfoList(nPInfo);
    //xxxxx
  end;
end;

//Date: 2010-4-22
//Parm: 列表
//Desc: 枚举可用的串口列表
function GetValidCOMPort(const nList: TStrings): Boolean;
var nInfo: OSVERSIONINFO;
begin
  FillChar(nInfo, SizeOf(nInfo), #0);
  nInfo.dwOSVersionInfoSize := SizeOf(nInfo);

  nList.Clear;
  Result := GetVersionEx(nInfo);

  if Result and (nInfo.dwMajorVersion >= 5) then
  begin
    Result := Win2K_EnumCOMPort(nList);
    if Result then EnumUSBPort(nList);
  end;

  if not Result then
    Result := GetCOMPortNames(nList);
  //xxxxx
end;

end.





