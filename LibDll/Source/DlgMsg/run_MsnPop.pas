{*******************************************************************************
  作者: dmzn 2007-01-12
  描述: 提供弹出式消息提示框
*******************************************************************************}
unit run_MsnPop;

interface

uses
  Windows, SysUtils, Graphics, Controls, Forms, MSNPopUp;

function PopMsg_IsInit: Boolean; stdcall;
procedure PopMsg_Init(const nApp: TApplication; const nScreen: TScreen;
 const nBackImg: integer = -1); stdcall;
procedure PopMsg_Free; stdcall;
procedure PopMsg_ShowMsg(const nMsg,nTitle: PChar); stdcall;
//入口函数

implementation

{$R PopImg.res}
var gMsger: TMSNPopUp = nil;

//Date: 2007-02-03
//Desc: 是否已经初始化
function PopMsg_IsInit;
begin
  Result := Assigned(gMsger);
end;

//Date: 2007-01-12
//Desc: 初始化提示框对象
procedure PopMsg_Init;
var nID: integer;
begin
  if Assigned(nApp) then Application := nApp;
  if Assigned(nScreen) then Screen := nScreen;

  if not Assigned(gMsger) then
  begin
    gMsger := TMSNPopUp.Create(nil);
    with gMsger do
    begin
      TimeOut := 3;
      BackgroundDrawMethod := dmFit;
      //gMsger.GradientColor1 := clWhite;

      with Font do
      begin
        Size := 9;
        Height := -12;
        Name := '宋体';
        Charset := GB2312_CHARSET;
      end;

      HoverFont.Assign(gMsger.Font);
      TitleFont.Assign(gMsger.Font);
      TitleFont.Color := clGreen;
      TitleFont.Style := [fsBold];
      Options := Options - [msnCascadePopups];
    end;
  end;

  if nBackImg < 0 then
     nID := Random(3) else
  if nBackImg < 3 then
       nID := nBackImg
  else nID := 0;

  gMsger.BackgroundImage.LoadFromResourceName(HInstance, 'Img' + IntToStr(nID));
  //载入背景
end;

//Date: 2007-01-12
//Desc: 释放消息提示框
procedure PopMsg_Free;
begin
  if Assigned(gMsger) then
  begin
    gMsger.ClosePopUps;
    FreeAndNil(gMsger);
  end;
end;

//Date: 2007-01-12
//Parm: 消息内容; 标题栏
//Desc: 弹出一个消息提示框
procedure PopMsg_ShowMsg(const nMsg,nTitle: PChar);
begin
  if Assigned(gMsger) then
  with gMsger do
  begin
    Text := nMsg;
    Title := nTitle;
    ShowPopup;
  end;
end;

end.
