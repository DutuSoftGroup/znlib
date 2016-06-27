{*******************************************************************************
  ����: dmzn@163.com 2011-11-21
  ����: ���Ʊ��
*******************************************************************************}
unit UGridPainter;

interface

uses
  Windows, Classes, Controls, Forms, SysUtils, Graphics, Grids;

type
  PGridHeader = ^TGridHeader;
  TGridHeader = record
    FText: string;            //�ı�
    FWidth: Integer;          //���
  end; //��������

  TGridHeaderArray = array of TGridHeader;
  //������

  TGridDataItem = record
    FText: string;            //�ı�
    FCtrls: TList;            //�ؼ�
    FAlign: TAlignment;       //����
  end;

  TGridDataArray = array of TGridDataItem;
  //������

  TGridPainter = class(TObject)
  private
    FGrid: TDrawGrid;
    //�����
    FCanvas: TCanvas;
    //������
    FHeaderFont: TFont;
    //��������
    FHeaderColor: TColor;
    //����ɫ
    FLineColor: TColor;
    //������ɫ    
    FHeader: TGridHeaderArray;
    //�����б�
    FData: array of TGridDataArray;
    //�����б�
  protected
    procedure ClearHeader;
    //������Դ
    procedure DrawHeader(ACol, ARow: Integer; Rect: TRect);
    procedure DrawData(ACol, ARow: Integer; Rect: TRect);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    //���Ʊ��
    procedure GridSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    //���ѡ��
    procedure HideCtrl(const nAll: Boolean);
    //���ؿؼ�
    procedure DoTopRowChanged(Sender: TObject);
    //�б�䶯
    function GetDataCount: Integer;
    function GetDataItem(Index: Integer): TGridDataArray;
    //��������
    function GetFixWidthStr(const nStr: string; nW: Integer): string;
    //�����ַ�
  public
    constructor Create(AGrid: TDrawGrid);
    destructor Destroy; override;
    //�����ͷ�
    procedure AddHeader(nText: string; nWidth: Integer);
    //��ӱ���
    procedure AddData(const nData: TGridDataArray);
    procedure ClearData;
    //���ݴ���
    property Grid: TDrawGrid read FGrid;
    property HeaderFont: TFont read FHeaderFont;
    property HeaderColor: TColor read FHeaderColor write FHeaderColor;
    property LineColor: TColor read FLineColor write FLineColor;
    property DataCount: Integer read GetDataCount;
    property Data[Index: Integer]: TGridDataArray read GetDataItem;
  end;

implementation

//------------------------------------------------------------------------------
constructor TGridPainter.Create(AGrid: TDrawGrid);
begin
  FGrid := AGrid;
  FGrid.DoubleBuffered := True;
  FCanvas := FGrid.Canvas;

  FHeaderColor := $00FEF7E9;
  FLineColor := $00FCDEBE;

  FHeaderFont := TFont.Create;
  FHeaderFont.Assign(FGrid.Font);

  with FGrid do
  begin
    Options := Options - [goFixedVertLine, goFixedHorzLine, goVertLine,
       goHorzLine, goRangeSelect] + [goColSizing, goThumbTracking];
    //options

    Font.Color := $005D5D5D;
    DefaultDrawing := False;

    RowCount := 2;
    ColCount := 0;
    FixedCols := 0;

    BorderStyle := bsNone;
    OnDrawCell := GridDrawCell;
    OnSelectCell := GridSelectCell;
    OnTopLeftChanged := DoTopRowChanged;
  end;
end;

destructor TGridPainter.Destroy;
begin
  FGrid := nil;
  ClearHeader;
  ClearData;

  FHeaderFont.Free;
  inherited;
end;

procedure TGridPainter.ClearHeader;
begin
  SetLength(FHeader, 0);
end;

procedure TGridPainter.ClearData;
var i,nIdx,nInt: Integer;
begin
  for nIdx:=Low(FData) to High(FData) do
   for nInt:=Low(FData[nIdx]) to High(FData[nIdx]) do
    if Assigned(FData[nIdx][nInt].FCtrls) then
    with FData[nIdx][nInt] do
    begin
      for i:=FCtrls.Count - 1 downto 0 do
        TControl(FCtrls[i]).Parent.RemoveControl(FCtrls[i]);
      FCtrls.Free;
      FCtrls := nil;
    end;
  //clear all

  SetLength(FData, 0);
  if Assigned(FGrid) then
  begin
    FGrid.RowCount := 2;
    FGrid.Invalidate;
  end;     
end;

//Desc: ��ӱ���
procedure TGridPainter.AddHeader(nText: string; nWidth: Integer);
var nIdx: Integer;
begin
  nIdx := Length(FHeader);
  SetLength(FHeader, nIdx + 1);

  with FHeader[nIdx] do
  begin
    FText := nText;
    FWidth := nWidth;
  end;

  FGrid.ColCount := nIdx + 1;
  FGrid.ColWidths[nIdx] := nWidth;
end;

//Desc: �������
procedure TGridPainter.AddData(const nData: TGridDataArray);
var i,nIdx,nInt: Integer;
begin
  nIdx := Length(FData);
  SetLength(FData, nIdx + 1);
  SetLength(FData[nIdx], Length(nData));

  for nInt:=Low(nData) to High(nData) do
  with FData[nIdx][nInt] do
  begin
    FText := nData[nInt].FText;
    FCtrls := nData[nInt].FCtrls;
    FAlign := nData[nInt].FAlign;

    if Assigned(FCtrls) then
     for i:=FCtrls.Count - 1 downto 0 do
      with TControl(FCtrls[i]) do
      begin
        Parent := FGrid;
        Visible := False;
      end;
    //set parent
  end;

  FGrid.RowCount := nIdx + 2;
end;

//Desc: ����ָ����������
function TGridPainter.GetDataItem(Index: Integer): TGridDataArray;
begin
  Result := FData[Index];
end;

//Desc: ������Ŀ��
function TGridPainter.GetDataCount: Integer;
begin
  Result := Length(FData);
end;

//Desc: �������пؼ�
procedure TGridPainter.HideCtrl(const nAll: Boolean);
var i,nIdx,nInt: Integer;
begin
  for nIdx:=Low(FData) to High(FData) do
  begin
    if (not nAll) and (nIdx >= FGrid.TopRow - 2) and
       (nIdx <= FGrid.TopRow + FGrid.VisibleRowCount + 1) then Continue;
    //��ʾ�Ĳ�������

    for nInt:=Low(FData[nIdx]) to High(FData[nIdx]) do
    if Assigned(FData[nIdx][nInt].FCtrls) then
    with FData[nIdx][nInt] do
    begin
      for i:=FCtrls.Count - 1 downto 0 do
        TControl(FCtrls[i]).Visible := False;
      //xxxxx
    end;
  end;
end;

//Desc: �б����ϼ�¼�䶯
procedure TGridPainter.DoTopRowChanged(Sender: TObject);
begin
  HideCtrl(True);
  //Application.ProcessMessages;
end;

//Desc: ������ĵ�Ԫ����ѡ��
procedure TGridPainter.GridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  ARow := ARow - 1;
  //record index

  if ARow >= Length(FData) then Exit;
  if ACol >= Length(FData[ARow]) then Exit;

  CanSelect := not Assigned(FData[ARow][ACol].FCtrls);
  //no control
end;

//Desc: ���Ƶ�Ԫ��
procedure TGridPainter.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if not Assigned(FGrid) then Exit;
  //do when free
  
  if (gdFixed in State) or (gdSelected in State) then
  begin
    FCanvas.Brush.Color := $00FEF7E9;
    FCanvas.FillRect(Rect);
  end else
  begin
    FCanvas.Brush.Color := FGrid.Color;
    FCanvas.FillRect(Rect);
  end;

  if ACol = 0 then
  begin
    Rect.Left := Rect.Left + 1;
  end else Rect.Left := Rect.Left - 1;

  if ARow = 0 then
  begin
    Rect.Top := Rect.Top + 1;
  end else Rect.Top := Rect.Top - 1;

  FCanvas.Brush.Color := FLineColor;
  FCanvas.FrameRect(Rect);

  if ARow = 0 then
       DrawHeader(ACol, ARow, Rect)
  else DrawData(ACol, ARow - 1, Rect);
end;

//Desc: ���Ʊ�ͷ
procedure TGridPainter.DrawHeader(ACol, ARow: Integer; Rect: TRect);
var nL,nT: Integer;
begin
  with Rect,FHeader[ACol] do
  begin
    FCanvas.Font.Assign(FHeaderFont);
    nL := Left + Trunc((Right - Left - FCanvas.TextWidth(FText)) / 2);
    nT := Top + Trunc((Bottom - Top - FCanvas.TextHeight(FText)) / 2);

    SetBkMode(FCanvas.Handle, TRANSPARENT);
    FCanvas.TextOut(nL, nT, FText);
  end;
end;

//Desc: ��nStr�н�ȡnW����ַ�
function TGridPainter.GetFixWidthStr(const nStr: string; nW: Integer): string;
var nWStr: WideString;
    nIdx,nE,nC,nLen,nCLen : Integer;
begin
  Result := nStr;
  if FCanvas.TextWidth(nStr) <= nW then Exit;

  nE := FCanvas.TextWidth('A');
  nC := FCanvas.TextWidth('��');

  nLen := 0;
  nWStr := nStr;

  for nIdx:=1 to Length(nWStr) do
  begin
    if Ord(nWStr[nIdx]) > 255 then
         nCLen := nC
    else nCLen := nE;

    if nLen + nCLen >= nW then
    begin
      Result := Copy(nWStr, 1, nIdx - 3) + '..';
      Exit;
    end else Inc(nLen, nCLen);
  end;
end;

//Desc: ��������
procedure TGridPainter.DrawData(ACol, ARow: Integer; Rect: TRect);
var nStr: string;
    nCtrl: TControl;
    nIdx,nL,nT,nW: Integer;
begin
  if ARow > High(FData) then Exit;
  if ACol > High(FData[ARow]) then Exit;

  with FData[ARow][ACol], Rect do
  begin       
    if FText <> '' then
    begin
      FCanvas.Font.Assign(FGrid.Font);
      nStr := GetFixWidthStr(FText, FGrid.ColWidths[ACol] - 2);

      nL := 0;
      nT := Top + Trunc((Bottom - Top - FCanvas.TextHeight(nStr)) / 2);

      case FAlign of
       taLeftJustify:
        nL := Left + 1;
       taCenter:
        nL := Left + Trunc((Right - Left - FCanvas.TextWidth(nStr)) / 2);
       taRightJustify:
        nL := Right - FCanvas.TextWidth(nStr) - 1;
      end;

      SetBkMode(FCanvas.Handle, TRANSPARENT);
      FCanvas.TextOut(nL, nT, nStr); Exit;
    end;

    if not Assigned(FCtrls) then Exit;
    nL := 0;
    nW := 0;
    
    if (FAlign = taCenter) or (FAlign = taRightJustify) then
    begin
      for nIdx:=0 to FCtrls.Count - 1 do
      begin
        nCtrl := TControl(FCtrls[nIdx]);
        nW := nW + nCtrl.Width + 2;
      end;

      nW := nW - 2;
    end; //������

    case FAlign of
     taLeftJustify:
      nL := Left + 2;
     taCenter:
      nL := Left + Trunc((Right - Left - nW) / 2);
     taRightJustify:
      nL := Right -  nW - 2;
    end;

    for nIdx:=0 to FCtrls.Count - 1 do
    begin
      nCtrl := TControl(FCtrls[nIdx]);
      nCtrl.Top := Top + Trunc((Bottom - Top - nCtrl.Height) / 2);

      nCtrl.Left := nL;
      nL := nL + 1 + nCtrl.Width;
      nCtrl.Visible := True;
    end;
  end;
end;

end.
