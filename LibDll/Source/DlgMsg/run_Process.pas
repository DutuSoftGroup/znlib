{*******************************************************************************
  ����: dmzn 2006-09-18
  ����: �ṩ��ʾ���ȵĴ���
*******************************************************************************}
unit run_Process;

interface

uses
  Windows, Messages, Graphics, Forms, Gauges, Controls, StdCtrls, Classes,
  ExtCtrls;

type
  TznProcess = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Gauge1: TGauge;
    procedure FormDestroy(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);  
  private
    { Private declarations }
    FOx,FOy: integer;
    FCanMove: Boolean;
    FAutoFree: Boolean;
  public
    { Public declarations }
  end;

procedure Process_ShowForm(const nApp: TApplication; const nScreen: TScreen;
  const nHint: PChar; const nMaxValue: integer; const nAutoFree: Boolean = True); stdcall;
//��ʾ���ȴ���
procedure Process_CloseForm; stdcall;
//�ͷŽ��ȴ���

procedure Process_SetHint(const nHint: PChar); stdcall;
procedure Process_SetMax(const nValue: integer); stdcall;
//���ò���
procedure Process_SetPos(const nValue: integer = -1); stdcall;
//��ʾ����

implementation

{$R *.dfm}
var gForm: TznProcess = nil;

//Date: 2006-09-18
//Desc: ��ʾһ����͸���Ľ�����ʾ��
procedure Process_ShowForm;
begin
  if Assigned(nApp) then Application := nApp;
  if Assigned(nScreen) then Screen := nScreen;

  if not Assigned(gForm) then
  begin
    gForm := TznProcess.Create(Application);
    with gForm do
    begin
      AlphaBlend := True;
      AlphaBlendValue := 210;
      BorderStyle := bsNone;

      Color := clMoneyGreen;
      FormStyle := fsStayOnTop;
      Position := poDesktopCenter;
    end;
  end;

  with gForm do
  begin
    FCanMove := False;
    FAutoFree := nAutoFree;
    Label1.Caption := nHint;

    Gauge1.Progress := 0;
    Gauge1.MaxValue := nMaxValue;

    if not Showing then
    begin
      Show;
      Application.ProcessMessages;
    end;
    //nCaller.SetFocus;
  end;
end;

//Date: 2006-09-18
//Parm: ����ֵ
//Desc: ���ý���ΪnValue
procedure Process_SetPos(const nValue: integer);
begin
  if Assigned(gForm) then
  with gForm do
  begin
    if nValue > -1 then
         Gauge1.Progress := nValue
    else Gauge1.Progress := Gauge1.Progress - nValue;

    if Gauge1.Progress = Gauge1.MaxValue then
    begin
      if (nValue > -1) and FAutoFree then Process_CloseForm;
      if (nValue < 0) then Gauge1.Progress := 0;
    end;
  end;
end;

//Date: 2006-09-18
//Desc: �رս��ȴ�
procedure Process_CloseForm;
begin
  if Assigned(gForm) then gForm.Free;
end;

procedure Process_SetHint(const nHint: PChar);
begin
  if Assigned(gForm) then
  begin
    gForm.Label1.Caption := nHint;
    Application.ProcessMessages;
  end;
end;

procedure Process_SetMax(const nValue: integer);
begin
  if Assigned(gForm) then gForm.Gauge1.MaxValue := nValue;
end;

procedure TznProcess.FormDestroy(Sender: TObject);
begin
  gForm := nil;
end;

{---------------------------------- �ƶ����� ----------------------------------}
procedure TznProcess.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FCanMove := True;
    FOx := X; FOy := Y;
  end;
end;

procedure TznProcess.Panel1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if FCanMove then
  begin
    Top := Top + Y - FOy;
    Left := Left + X - FOx;
  end;
end;

procedure TznProcess.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FCanMove := False;
end;

end.
