{*******************************************************************************
  作者: dmzn 2007-01-09
  描述: 通用运行时函数库接口声明单元
*******************************************************************************}
unit ULibDLL;

interface

uses
  Windows, Forms, Classes, ZLibEX;

const
  cDlgMsgLib   = 'DlgMsg.dll';
  cDataOKLib   = 'DataOK.dll';
  cZipDataLib  = 'ZipFile.dll';
  //通用函数库

procedure Data_Init(const nApp: TApplication; const nScreen: TScreen;
 const nConfigFile: PChar); stdcall; external cDataOKLib;
function Data_ShowBackup(const nTitle,nSource,nDest: PChar): Boolean; stdcall;
 external cDataOKLib; 
function Data_ShowRestore(const nTitle,nIdxFile,nDest: PChar): Boolean; stdcall;
 external cDataOKLib;
//数据备份还原

procedure Process_ShowForm(const nApp: TApplication;
 const nScreen: TScreen; const nHint: PChar; const nMaxValue: integer;
 const nAutoFree: Boolean = True); stdcall; external cDlgMsgLib;
procedure Process_CloseForm; stdcall; external cDlgMsgLib;
procedure Process_SetHint(const nHint: PChar); stdcall; external cDlgMsgLib;
procedure Process_SetMax(const nValue: integer); stdcall; external cDlgMsgLib;
procedure Process_SetPos(const nValue: integer = -1); stdcall; external cDlgMsgLib;
//显示进度窗体

function PopMsg_IsInit: Boolean; stdcall; external cDlgMsgLib;
procedure PopMsg_Init(const nApp: TApplication; const nScreen: TScreen;
 const nBackImg: integer = -1); stdcall; external cDlgMsgLib;
procedure PopMsg_Free; stdcall; external cDlgMsgLib;
procedure PopMsg_ShowMsg(const nMsg,nTitle: PChar); stdcall; external cDlgMsgLib;
//弹出式消息提示框

function Dlg_InputBox(const nApp: TApplication; const nScreen: TScreen;
 const nHint: PChar; const nValue: PChar;
 const nSize: Word): Boolean; stdcall; external cDlgMsgLib;
function Dlg_InputPWDBox(const nApp: TApplication; const nScreen: TScreen;
 const nHint: PChar; const nValue: PChar;
 const nSize: Word): Boolean; stdcall; external cDlgMsgLib;
//输入框

procedure Zip_SetParam(const nApp: TApplication;
 const nScreen: TScreen); stdcall; external cZipDataLib;
function Zip_HasZipped(const nStream: TStream): Boolean; stdcall; external cZipDataLib;
function Zip_ZipFile(const nTitle,nSource,nDest: PChar;
 const nZipLevel: TZCompressionLevel = zcDefault): Boolean; stdcall; external cZipDataLib;
function Zip_UnZipFile(const nTitle, nSource,
 nDest: PChar): Boolean; stdcall; external cZipDataLib;
function Zip_ZipStream(const nTitle: PChar; const nSource,nDest: TStream;
 const nZipLevel: TZCompressionLevel = zcDefault): Boolean; stdcall; external cZipDataLib;
function Zip_UnZipStream(const nTitle: PChar;
 const nSource,nDest: TStream): Boolean; stdcall; external cZipDataLib;
//压缩&解压缩

implementation

end.
