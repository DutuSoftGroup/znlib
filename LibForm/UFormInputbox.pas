{*******************************************************************************
  ����: dmzn 2007-02-01
  ����: �ṩ����Ի���
*******************************************************************************}
unit UFormInputbox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfFormInputBox = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    BtnOK: TButton;
    BtnExit: TButton;
  private
    { Private declarations }
    procedure SetHint(const nStr: string);
    //��ʾ��Ϣ
  public
    { Public declarations }
  end;

function ShowInputBox(const nHint,nTitle: string; var nValue: string;
  const nSize: Word = 0): Boolean;
function ShowInputPWDBox(const nHint,nTitle: string; var nValue: string;
  const nSize: Word = 0): Boolean;
//��ں���

implementation

{$R *.dfm}

//Desc: �ı���
function ShowInputBox(const nHint,nTitle: string; var nValue: string;
  const nSize: Word = 0): Boolean;
begin
  with TfFormInputBox.Create(Application) do
  begin
    Caption := nTitle;
    SetHint(nHint);
    Edit1.Text := nValue;
    Edit1.MaxLength := nSize;

    Result := ShowModal = mrOK;
    if Result then nValue := Edit1.Text;
    Free;
  end;
end;

//Desc: �����
function ShowInputPWDBox(const nHint,nTitle: string; var nValue: string;
  const nSize: Word = 0): Boolean;
begin
  with TfFormInputBox.Create(Application) do
  begin
    Caption := nTitle;
    SetHint(nHint);

    Edit1.Text := nValue;
    Edit1.MaxLength := nSize;
    Edit1.PasswordChar := '*';

    Result := ShowModal = mrOK;
    if Result then nValue := Edit1.Text;
    Free;
  end;
end;

//Desc: ������ʾ��Ϣ,�������ڿ��
procedure TfFormInputBox.SetHint(const nStr: string);
var nNum: integer;
begin
  Label1.Caption := nStr;
  nNum := Canvas.TextWidth(nStr);
  if (nNum mod Label1.Width) = 0 then
       nNum := nNum div Label1.Width
  else nNum := nNum div Label1.Width + 1;
  //��Ҫ������

  Label1.Height := nNum * (Canvas.TextHeight('��') + 5);
  Edit1.Top := Label1.Top + Label1.Height + 5;
  BtnOK.Top := Edit1.Top + Edit1.Height + 12;

  BtnExit.Top := BtnOK.Top;
  ClientHeight := BtnExit.Top + BtnExit.Height + 12;
end;

end.
