{*******************************************************************************
  ×÷Õß: dmzn@163.com 2009-7-21
  ÃèÊö: Í¸Ã÷±à¼­¿ò
*******************************************************************************}
unit UTransEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  TZnTransEdit = class(TEdit)
  private
    FAlignText: TAlignment;
    FTransparent: Boolean;
    FPainting: Boolean;
    procedure SetAlignText(Value: TAlignment);
    procedure SetTransparent(Value: Boolean);
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMNCPaint (var Message: TMessage); message WM_NCPAINT;
    procedure WMEraseBkGnd(var Message: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure CNCtlColorEdit(var Message: TWMCtlColorEdit); message CN_CTLCOLOREDIT;
    procedure CNCtlColorStatic(var Message: TWMCtlColorStatic); message CN_CTLCOLORSTATIC;
    procedure CMParentColorChanged(var Message: TMessage); message CM_PARENTCOLORCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
  protected
    procedure RepaintWindow;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Change; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property AlignText: TAlignment read FAlignText write SetAlignText default taLeftJustify;
    property Transparent: Boolean read FTransparent write SetTransparent default false;
  end;

  TZnTransMemo = class(TMemo)
  private
    FAlignText: TAlignment;
    FTransparent: Boolean;
    FPainting: Boolean;
    procedure SetAlignText(Value: TAlignment);
    procedure SetTransparent(Value: Boolean);
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMNCPaint (var Message: TMessage); message WM_NCPAINT;
    procedure WMEraseBkGnd(var Message: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure CNCtlColorEdit(var Message: TWMCtlColorEdit); message CN_CTLCOLOREDIT;
    procedure CNCtlColorStatic(var Message: TWMCtlColorStatic); message CN_CTLCOLORSTATIC;
    procedure CMParentColorChanged(var Message: TMessage); message CM_PARENTCOLORCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
  protected
    procedure RepaintWindow;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Change; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property AlignText: TAlignment read FAlignText write SetAlignText default taLeftJustify;
    property Transparent: Boolean read FTransparent write SetTransparent default false;
  end;

procedure Register;

implementation

const
 BorderRec: array[TBorderStyle] of Integer = (1, -1);

type
  TCtrl = class(TWinControl);

procedure Register;
begin
  RegisterComponents('RunSoft', [TZnTransEdit, TZnTransMemo]);
end;

//------------------------------------------------------------------------------
function GetScreenClient(Control: TControl): TPoint;
var nP: TPoint;
begin
  nP := Control.ClientOrigin;
  ScreenToClient(Control.Parent.Handle, nP);
  Result := nP;
end;

constructor TZnTransEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAlignText := taLeftJustify;
  FTransparent := false;
  FPainting := false; 
end;

destructor TZnTransEdit.Destroy;
begin
  inherited Destroy;
end;

procedure TZnTransEdit.CreateParams(var Params: TCreateParams);
const
 Alignments: array [TAlignment] of DWord = (ES_LEFT, ES_RIGHT, ES_CENTER);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or Alignments[FAlignText];
end;

procedure TZnTransEdit.Change;
begin
  RepaintWindow;
  inherited Change;
end;

procedure TZnTransEdit.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
end;

procedure TZnTransEdit.SetAlignText(Value: TAlignment);
begin
  if FAlignText <> Value then
  begin
    FAlignText := Value;
    RecreateWnd;
    Invalidate;
  end;
end;

procedure TZnTransEdit.SetTransparent(Value: Boolean);
begin
  if FTransparent <> Value then
  begin
    FTransparent := Value;
    Invalidate;
  end;
end;

procedure TZnTransEdit.WMEraseBkGnd(var Message: TWMEraseBkGnd);
var
 DC: hDC;
 i: integer;
 p: TPoint;
begin
  if FTransparent then
  begin
    if Assigned(Parent) then
    begin
      DC := Message.DC;
      i := SaveDC(DC);
      p := GetScreenClient(self);
      p.x := -p.x;
      p.y := -p.y;
      MoveWindowOrg(DC, p.x, p.y);
      SendMessage(Parent.Handle, WM_ERASEBKGND, DC, 0);
      TCtrl(Parent).PaintControls(DC, nil);
      RestoreDC(DC, i);
    end;
  end else inherited;
end;

procedure TZnTransEdit.WMPaint(var Message: TWMPaint);
begin
  inherited;
  if FTransparent and (not FPainting) then RepaintWindow;
end;

procedure TZnTransEdit.WMNCPaint(var Message: TMessage);
begin
  inherited;
end;

procedure TZnTransEdit.CNCtlColorEdit(var Message: TWMCtlColorEdit);
begin
  inherited;
  if FTransparent then SetBkMode(Message.ChildDC, Windows.TRANSPARENT);
end;

procedure TZnTransEdit.CNCtlColorStatic(var Message: TWMCtlColorStatic);
begin
  inherited;
  if FTransparent then SetBkMode(Message.ChildDC, Windows.TRANSPARENT);
end;

procedure TZnTransEdit.CMParentColorChanged(var Message: TMessage);
begin
  inherited;
  if FTransparent then Invalidate;
end;

procedure TZnTransEdit.WMSize(var Message: TWMSize);
begin
  inherited;
  Invalidate;
end;

procedure TZnTransEdit.WMMove(var Message: TWMMove);
begin
  inherited;
  Invalidate;
end;

procedure TZnTransEdit.RepaintWindow;
var
 DC: hDC;
 TmpBitmap, Bitmap: hBitmap;
begin
  if FTransparent then
  begin
    FPainting := true;
    HideCaret(Handle);

    DC := CreateCompatibleDC(GetDC(Handle));
    TmpBitmap := CreateCompatibleBitmap(GetDC(Handle), Succ(ClientWidth), Succ(ClientHeight));
    Bitmap := SelectObject(DC, TmpBitmap);

    PaintTo(DC, 0, 0);
    BitBlt(GetDC(Handle), BorderRec[BorderStyle], BorderRec[BorderStyle],
                          ClientWidth, ClientHeight, DC, 1, 1, SRCCOPY);
    SelectObject(DC, Bitmap);

    DeleteDC(DC);
    ReleaseDC(Handle, GetDC(Handle));
    DeleteObject(TmpBitmap);
    
    ShowCaret(Handle);
    FPainting := false;
  end;
end;

//------------------------------------------------------------------------------
constructor TZnTransMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAlignText := taLeftJustify;
  FTransparent := false;
  FPainting := false;
end;

destructor TZnTransMemo.Destroy;
begin
  inherited Destroy;
end;

procedure TZnTransMemo.CreateParams(var Params: TCreateParams);
const
 Alignments: array [TAlignment] of DWord = (ES_LEFT, ES_RIGHT, ES_CENTER);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or Alignments[FAlignText];
end;

procedure TZnTransMemo.Change;
begin
  RepaintWindow;
  inherited Change;
end;

procedure TZnTransMemo.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
end;

procedure TZnTransMemo.SetAlignText(Value: TAlignment);
begin
  if FAlignText <> Value then
  begin
    FAlignText := Value;
    RecreateWnd;
    Invalidate;
  end;
end;

procedure TZnTransMemo.SetTransparent(Value: Boolean);
begin
  if FTransparent <> Value then
  begin
    FTransparent := Value;
    Invalidate;
  end;
end;

procedure TZnTransMemo.WMEraseBkGnd(var Message: TWMEraseBkGnd);
var
 DC: hDC;
 i: integer;
 p: TPoint;
begin
  if FTransparent then
  begin
    if Assigned(Parent) then
    begin
      DC := Message.DC;
      i := SaveDC(DC);
      p := GetScreenClient(self);
      p.x := -p.x;
      p.y := -p.y;
      MoveWindowOrg(DC, p.x, p.y);
      SendMessage(Parent.Handle, WM_ERASEBKGND, DC, 0);
      TCtrl(Parent).PaintControls(DC, nil);
      RestoreDC(DC, i);
    end;
  end else inherited;
end;

procedure TZnTransMemo.WMPaint(var Message: TWMPaint);
begin
  inherited;
  if FTransparent and (not FPainting) then RepaintWindow;
end;

procedure TZnTransMemo.WMNCPaint(var Message: TMessage);
begin
  inherited;
end;

procedure TZnTransMemo.CNCtlColorEdit(var Message: TWMCtlColorEdit);
begin
  inherited;
  if FTransparent then SetBkMode(Message.ChildDC, Windows.TRANSPARENT);
end;

procedure TZnTransMemo.CNCtlColorStatic(var Message: TWMCtlColorStatic);
begin
 inherited;
  if FTransparent then SetBkMode(Message.ChildDC, Windows.TRANSPARENT);
end;

procedure TZnTransMemo.CMParentColorChanged(var Message: TMessage);
begin
  inherited;
  if FTransparent then Invalidate;
end;

procedure TZnTransMemo.WMSize(var Message: TWMSize);
begin
  inherited;
  Invalidate;
end;

procedure TZnTransMemo.WMMove(var Message: TWMMove);
begin
  inherited;
  Invalidate;
end;

procedure TZnTransMemo.RepaintWindow;
var
 DC: hDC;
 TmpBitmap, Bitmap: hBitmap;
begin
  if FTransparent then
  begin
    FPainting := true;
    HideCaret(Handle);

    DC := CreateCompatibleDC(GetDC(Handle));
    TmpBitmap := CreateCompatibleBitmap(GetDC(Handle), Succ(ClientWidth), Succ(ClientHeight));
    Bitmap := SelectObject(DC, TmpBitmap);

    PaintTo(DC, 0, 0);
    BitBlt(GetDC(Handle), BorderRec[BorderStyle], BorderRec[BorderStyle],
                          ClientWidth, ClientHeight, DC, 1, 1, SRCCOPY);
    SelectObject(DC, Bitmap);
    
    DeleteDC(DC);
    ReleaseDC(Handle, GetDC(Handle));
    DeleteObject(TmpBitmap);
    
    ShowCaret(Handle);
    FPainting := false;
  end;
end;

end.
