{*******************************************************************************
  ����: dmzn 2007-02-01
  ����: �ṩ����Ի���
*******************************************************************************}
unit run_Inputbox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TznInputBox = class(TForm)
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

function Dlg_InputBox(const nApp: TApplication; const nScreen: TScreen;
  const nHint: PChar; const nValue: PChar; const nSize: Word): Boolean; stdcall;
function Dlg_InputPWDBox(const nApp: TApplication; const nScreen: TScreen;
  const nHint: PChar; const nValue: PChar; const nSize: Word): Boolean; stdcall;
procedure Dlg_FreeInputBox;
//����򴰿�

implementation

{$R *.dfm}
var gForm: TznInputBox = nil;

//Desc: �ı���
function Dlg_InputBox;
begin
  if Assigned(nApp) then Application := nApp;
  if Assigned(nScreen) then Screen := nScreen;

  if not Assigned(gForm) then
  begin
    gForm := TznInputBox.Create(Application);
    gForm.Caption := '�����';
  end;

  with gForm do
  begin
    SetHint(StrPas(nHint));
    Edit1.MaxLength := nSize;
    Edit1.Text := StrPas(nValue);

    Result := ShowModal = mrOK;
    if Result then StrPCopy(nValue, Edit1.Text);
  end;
  FreeAndNil(gForm);
end;

//Desc: �����
function Dlg_InputPWDBox;
begin
  if Assigned(nApp) then Application := nApp;
  if Assigned(nScreen) then Screen := nScreen;

  if not Assigned(gForm) then
  begin
    gForm := TznInputBox.Create(Application);
    gForm.Caption := '�����';
  end;

  with gForm do
  begin
    SetHint(StrPas(nHint));
    Edit1.MaxLength := nSize;
    Edit1.PasswordChar := '*';
    Edit1.Text := StrPas(nValue);

    Result := ShowModal = mrOK;
    if Result then StrPCopy(nValue, Edit1.Text);
  end;
  FreeAndNil(gForm);
end;

//Desc: �ͷ�
procedure Dlg_FreeInputBox;
begin
  FreeAndNil(gForm);
end;

//Desc: ������ʾ��Ϣ,�������ڿ��
procedure TznInputBox.SetHint(const nStr: string);
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
