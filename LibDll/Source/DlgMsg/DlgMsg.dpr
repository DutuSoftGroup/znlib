library DlgMsg;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  Windows,
  SysUtils,
  Classes,
  Forms,
  run_Process in 'run_Process.pas' {znProcess},
  run_MsnPop in 'run_MsnPop.pas',
  run_Inputbox in 'run_Inputbox.pas' {znInputBox};

{$R *.res}

exports 
  Process_ShowForm, Process_CloseForm,
  Process_SetHint, Process_SetMax, Process_SetPos,
  //显示进度
  PopMsg_IsInit, PopMsg_Init, PopMsg_Free, PopMsg_ShowMsg,
  //消息提示
  Dlg_InputBox, Dlg_InputPWDBox;
  //输入框

var
  gProc: TDllProc;
  //回调函数
  gScr: TScreen;
  //全局屏幕对象
  gApp: TApplication;
  //全局工程对象

//Desc: 释放
procedure FreeResource;
begin
  try
    PopMsg_Free;
    Dlg_FreeInputBox;
    Process_CloseForm;
    Application.ProcessMessages;
  except
  end;
end;

//Desc: 还原
procedure LibraryProc(const Reason: Integer);
begin
  if Reason = DLL_PROCESS_DETACH then
  begin
    FreeResource;
    Screen := gScr;
    Application := gApp;
    DllProc := gProc;
  end;
end;

begin
  gProc := DllProc;
  gScr := Screen;
  gApp := Application;
  DllProc := @LibraryProc;
end.
 