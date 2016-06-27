{*******************************************************************************
  作者: dmzn@163.com 2013-2-21
  描述: 执行控制台命令并等待完成
*******************************************************************************}
unit UConsoleApp;

interface

uses
  Windows, Classes, SysUtils;

type
  PCAOutput = ^TCAOutput;
  TCAOutput = record
    FOutMsg: string;
    FErrMsg: string;
    FErrCode: Cardinal;
  end;

function ExecConsoleApp(const nCmd: string; nOut: TStrings): Cardinal;
function ExecConsoleApp2(const nCmd: string; nOut: PCAOutput = nil): Boolean;
//入口函数

implementation

//Date: 2013-2-21
//Parm: 命令行;输出
//Desc: 执行nCmd并将结果输出到nOut中,返回执行结果码.
function ExecConsoleApp(const nCmd: string; nOut: TStrings): Cardinal;
var nPBuf: PChar;
    nLen,nExitCode: Cardinal;
    nRead,nTotal: Cardinal;
    nReadBuf: array of Char;
    nHRead,nHWrite,nHTemp: THandle;

    nStartupInfo:TStartupInfo;
    nProcessInfo:TProcessInformation;
    nSecurityAttributes: TSecurityAttributes;
begin
  Result := NOERROR;
  nHRead  := INVALID_HANDLE_VALUE;
  nHWrite := INVALID_HANDLE_VALUE;

  nProcessInfo.hThread  := INVALID_HANDLE_VALUE;
  nProcessInfo.hProcess := INVALID_HANDLE_VALUE; 
  try
    FillChar(nSecurityAttributes, SizeOf(nSecurityAttributes), #0);
    //init for security
    
    with nSecurityAttributes do
    begin
      bInheritHandle := True;
      nLength := SizeOf(nSecurityAttributes);
    end;

    if not CreatePipe(nHRead, nHWrite, @nSecurityAttributes, 0) then
    begin
      Result := GetLastError;
      Exit;
    end;

    if Win32Platform = VER_PLATFORM_WIN32_NT then
    begin
      if not SetHandleInformation(nHRead, HANDLE_FLAG_INHERIT, 0) then
      begin
        Result := GetLastError;
        Exit;
      end;
    end else
    begin
      if not DuplicateHandle(GetCurrentProcess, nHRead, GetCurrentProcess,
         @nHTemp, 0, True, DUPLICATE_SAME_ACCESS) then
      begin
        Result := GetLastError;
        Exit;
      end;
      //SetHandleInformation does not work under Window95, so we have to
      //make a copy thenclose the original

      CloseHandle(nHRead);
      nHRead := nHTemp;
    end;

    //--------------------------------------------------------------------------
    FillChar(nStartupInfo, SizeOf(nStartupInfo), #0);
    //init for startup struct

    with nStartupInfo do
    begin
      cb := SizeOf(nStartupInfo);
      hStdOutput := nHWrite;
      hStdError := nHWrite;
      wShowWindow := SW_HIDE;
      dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    end;
    {Initialise the startup info. I suspect that it is only safe to pass
    WriteHandle as hStdOutput because we are going to make sure that the
    child inherits it. This is not documented anywhere, but I am reasonably
    sure it is correct. We should not have to use STARTF_USESHOWWINDOW and
    wShowWindow:= SW_HIDE as we are going to tell CreateProcess not to
    bother with an output window, but it would appear that Windows 95
    ignores the CREATE_NO_WINDOW flag. Fair enough - it is not in the SDK
    documentation (I got it out of Richter). CREATE_NO_WINDOW definately works
    under NT 4.0, so it is worth doing}

    if not CreateProcess(nil, PChar(nCmd), nil, nil,
       True, {inherit kernel object handles from parent}
       NORMAL_PRIORITY_CLASS or CREATE_NO_WINDOW,
       {DETACHED_PROCESS relevant for Console parent only No need to
       create an output window - it would be blank anyway}
       nil, nil, nStartupInfo, nProcessInfo) then
    begin
      Result := GetLastError;
      Exit;
    end;
    
    CloseHandle(nProcessInfo.hThread);
    nProcessInfo.hThread := INVALID_HANDLE_VALUE;
    //not interested in threadhandle - close it

    CloseHandle(nHWrite);
    nHWrite := INVALID_HANDLE_VALUE;
    {close our copy of Write handle - Child has its own copy now. It is important
    to close ours, otherwise ReadFile may not return when child closes its
    StdOutput - this is the mechanism by which the following loop detects the
    termination of the child process: it does not poll GetExitCodeProcess.

    The clue to this behaviour is in the 'Anonymous Pipes' topic of Win32.hlp - quote

    "To read from the pipe, a process uses the read handle in a call to the
    ReadFile function. When a write operation of any number of bytes completes,
    the ReadFile call returns. The ReadFile call also returns when all handles
    to the write end of the pipe have been closed or if any errors occur before
    the read operation completes normally."

    On this basis (and going somewhat beyond that stated above) I have assumed that
    ReadFile will return TRUE when a write is completed at the other end of the pipe
    and will return FALSE when the write handle is closed at the other end.

    I have also assumed that ReadFile will return when its output buffer is full
    regardless of the size of the write at the other end.     
    I have tested all these assumptions as best I can (under NT 4)}

    SetLength(nReadBuf, 0);
    nPBuf := nil;
    nExitCode := 0;
    //init for read 

    while nExitCode = 0 do
    begin
      if WaitForSingleObject(nProcessInfo.hProcess, 20) <> WAIT_TIMEOUT then
        nExitCode := 1;
      //check process status

      if PeekNamedPipe(nHRead, nil, 0, nil, @nTotal, nil) and (nTotal > 0) then
      try
        GetMem(nPBuf, nTotal);
        //alloc memory

        if ReadFile(nHRead, nPBuf^, nTotal, nRead, nil) and (nRead > 0) then
        begin
          nLen := Length(nReadBuf);
          SetLength(nReadBuf, nLen + nRead);
          CopyMemory(@nReadBuf[nLen], nPBuf, nRead);
        end
      finally
        if Assigned(nPBuf) then
        begin
          FreeMem(nPBuf);
          nPBuf := nil;
        end; //release memory
      end;
    end;

    WaitForSingleObject(nProcessInfo.hProcess, 5000);
    {The child process may have closed its stdoutput handle but not yet
    terminated, so will wait for up to five seconds to it a chance to
    terminate. If it has not done so after this time, then we will end
    up returning STILL_ACTIVE ($103)

    If you don't care about the exit code of the process, then you don't
    need this wait: having said that, unless the child process has a
    particularly longwinded cleanup routine, the wait will be very short
    in any event.
    I recommend you leave this wait in unless you have an intimate
    understanding of the child process you are spawining and are sure you
    don't want to wait for it}

    GetExitCodeProcess(nProcessInfo.hProcess, Result);
    nLen := Length(nReadBuf);
    if nLen > 0 then
    begin
      SetLength(nReadBuf, nLen + 1);
      nReadBuf[nLen] := #0;
      nOut.Add(StrPas(@nReadBuf[0]));
    end;
  finally
    if nProcessInfo.hThread <> INVALID_HANDLE_VALUE then
      CloseHandle(nProcessInfo.hThread);
    //thread handle

    if nProcessInfo.hProcess <> INVALID_HANDLE_VALUE then
      CloseHandle(nProcessInfo.hProcess);
    //process handle

    if nHWrite <> INVALID_HANDLE_VALUE then
      CloseHandle(nHWrite);
    //write pipe handle

    if nHRead <> INVALID_HANDLE_VALUE then
      CloseHandle(nHRead);
    //read pipe handle
  end;
end;

//Date: 2013-2-21
//Parm: 命令行;输出
//Desc: 执行nCmd并将结果输出到nOut中,返回成功或失败.
function ExecConsoleApp2(const nCmd: string; nOut: PCAOutput): Boolean;
var nIdx: Integer;
    nRes: Cardinal;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nRes := ExecConsoleApp(nCmd, nList);
    Result := nRes = NOERROR;
    if not Assigned(nOut) then Exit;

    for nIdx:=nList.Count - 1 downto 0 do
     if Trim(nList[nIdx]) = '' then
       nList.Delete(nIdx);
    //delete blank line

    nOut.FOutMsg := Trim(nList.Text);
    nOut.FErrCode := nRes;
    nOut.FErrMsg := SysErrorMessage(nRes);
  finally
    nList.Free;
  end;
end;

end.
