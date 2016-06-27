library DataOK;

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
  run_BackData in 'run_BackData.pas' {fBackData2},
  run_DataRes in 'run_DataRes.pas',
  run_ResData in 'run_ResData.pas' {fResData};

{$R *.res}

//Desc: ��ʼ��
procedure Data_Init(const nApp: TApplication; const nScreen: TScreen;
 const nConfigFile: PChar); stdcall;
begin
  Application := nApp;
  Screen := nScreen;
  gConfigFile := nConfigFile;
end;

exports
  Data_Init, Data_ShowBackup, Data_ShowRestore;
  //���ݱ�����ָ�

//------------------------------------------------------------------------------
var
  gProc: TDllProc;
  //�ص�����
  gScr: TScreen;
  //ȫ����Ļ����
  gApp: TApplication;
  //ȫ�ֹ��̶���

//Desc: �ͷ�
procedure FreeResource;
begin
  try
    Data_CloseResForm;
    Data_CloseBackForm;
  except
  end;
end;

//Desc: ��ԭ
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
 