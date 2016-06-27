{*******************************************************************************
  作者: dmzn 2013-12-03
  描述: 提供复选对话框
*******************************************************************************}
unit UFormCheckbox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ULibFun, StdCtrls;

type
  TfFormCheckbox = class(TForm)
    Label1: TLabel;
    BtnOK: TButton;
    BtnExit: TButton;
    CheckBox1: TCheckBox;
    RadioYes: TRadioButton;
    RadioNo: TRadioButton;
  private
    { Private declarations }
    procedure SetHint(const nHint1,nHint2: string);
    //提示信息
  public
    { Public declarations }
  end;

function ShowCheckbox(const nHint1,nHint2,nTitle: string;
  var nValue: Boolean; const nRadio: Boolean = False): Boolean;
//入口函数

implementation

{$R *.dfm}

//Desc: 文本框
function ShowCheckbox(const nHint1,nHint2,nTitle: string;
  var nValue: Boolean; const nRadio: Boolean = False): Boolean;
begin
  with TfFormCheckbox.Create(Application) do
  try
    Label1.Visible := not nRadio;
    CheckBox1.Visible := not nRadio;
    RadioYes.Visible := nRadio;
    RadioNo.Visible := nRadio;

    Caption := nTitle;
    SetHint(nHint1, nHint2);

    if nRadio then
    begin
      RadioYes.Checked := nValue;
      RadioNo.Checked := not nValue;
    end else CheckBox1.Checked := nValue;

    Result := ShowModal = mrOK;
    if Result then
    begin
      if nRadio then
           nValue := RadioYes.Checked
      else nValue := CheckBox1.Checked;
    end;
  finally
    Free;
  end;
end;

//Desc: 设置提示信息,调整窗口宽高
procedure TfFormCheckbox.SetHint(const nHint1,nHint2: string);
var nNum: integer;
begin
  if Label1.Visible then
  begin
    Label1.Caption := nHint1;
    CheckBox1.Caption := nHint2;
    CheckBox1.Left := Label1.Left + 4;
    CheckBox1.Width := Canvas.TextWidth(nHint2) + 32;

    nNum := Canvas.TextWidth(nHint1);
    if (nNum mod Label1.Width) = 0 then
         nNum := nNum div Label1.Width
    else nNum := nNum div Label1.Width + 1;
    //需要多少行

    Label1.Height := nNum * (Canvas.TextHeight('润') + 5);
    CheckBox1.Top := Label1.Top + Label1.Height + 5;
    BtnOK.Top := CheckBox1.Top + CheckBox1.Height + 12;

    nNum := CheckBox1.Width + Label1.Left * 2;
    if nNum > ClientWidth then
      ClientWidth := nNum;
    //xxxxx
  end else
  begin
    RadioYes.Left := Label1.Left;
    RadioYes.Caption := nHint1;
    RadioYes.Width := Canvas.TextWidth(nHint1) + 32;
    RadioNo.Top := RadioYes.Top + RadioYes.Height + 5;

    RadioNo.Left := Label1.Left;
    RadioNo.Caption := nHint2;
    RadioNo.Width := Canvas.TextWidth(nHint2) + 32;
    BtnOK.Top := RadioNo.Top + RadioNo.Height + 5;

    if RadioYes.Width > RadioNo.Width then
         nNum := RadioYes.Width
    else nNum := RadioNo.Width;

    nNum := nNum + Label1.Left * 2;
    if nNum > ClientWidth then
      ClientWidth := nNum;
    //xxxxx
  end;

  BtnExit.Top := BtnOK.Top;
  ClientHeight := BtnExit.Top + BtnExit.Height + 12;
end;

end.
