{*******************************************************************************
  作者: dmzn@163.com 2011-11-21
  描述: 绘制表格
*******************************************************************************}
unit UGridExPainter;

interface

uses
  Windows, Classes, Controls, Forms, Messages, SysUtils, Graphics, Grids;

type
  PGridExHeader = ^TGridExHeader;
  TGridExHeader = record
    FText: string;            //文本
    FWidth: Integer;          //宽度
    FDataCol: Integer;        //数据列
    FSplit: Boolean;          //等分
  end; //标题数据

  TGridExHeaderArray = array of TGridExHeader;
  //标题组

  TGridExDataItem = record
    FText: string;            //文本
    FCtrls: TList;            //控件
    FAlign: TAlignment;       //排列
  end;

  TGridExDataArray = array of TGridExDataItem;
  //行数据组

  TGridExColDrawInfo = record
    FStart: Integer;          //开始行
    FEnd: Integer;            //结束行
    FRect: TRect;             //绘制范围
    FLast: Cardinal;          //上次绘制
  end;

  TGridExColDataItem = record
    FCol: Integer;            //列索引
    FRows: Word;              //占用行
    FText: string;            //文本
    FCtrl: TControl;          //组件
    FAlign: TAlignment;       //排列
    FDraw: TGridExColDrawInfo;//绘制信息
  end;

  TGridExColDataArray = array of TGridExColDataItem;
  //列数据组

  TGridExPainter = class(TObject)
  private
    FGrid: TDrawGrid;
    //主表格
    FCanvas: TCanvas;
    //主画布
    FHeaderFont: TFont;
    //标题字体
    FHeaderColor: TColor;
    //背景色
    FLineColor: TColor;
    //边线颜色    
    FHeader: TGridExHeaderArray;
    //标题列表
    FRowData: array of TGridExDataArray;
    FColData: TGridExColDataArray;
    //数据列表
  protected
    procedure ClearHeader;
    //清理资源
    procedure DrawHeader(ACol, ARow: Integer; Rect: TRect);
    procedure DrawRowData(ACol, ARow: Integer; Rect: TRect);
    procedure DrawColData(ACol, ARow: Integer; Rect: TRect);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    //绘制表格
    procedure GridSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    //表格选中
    procedure HideCtrl(const nAll: Boolean);
    //隐藏控件
    procedure DoTopRowChanged(Sender: TObject);
    //列表变动
    function GetDataColumn(const ACol: Integer): Integer;
    //数据列
    function GetDataCount: Integer;
    function GetDataItem(Index: Integer): TGridExDataArray;
    //检索数据
    function GetFixWidthStr(const nStr: string; nW: Integer): string;
    //定长字符
  public
    constructor Create(AGrid: TDrawGrid);
    destructor Destroy; override;
    //创建释放
    procedure AddHeader(nText: string; nWidth: Integer; nSplit: Boolean = False);
    //添加标题
    procedure AddRowData(const nData: TGridExDataArray);
    procedure AddColData(const nData : TGridExColDataArray);
    procedure ClearData;
    //数据处理
    property Grid: TDrawGrid read FGrid;
    property HeaderFont: TFont read FHeaderFont;
    property HeaderColor: TColor read FHeaderColor write FHeaderColor;
    property LineColor: TColor read FLineColor write FLineColor;
    property DataCount: Integer read GetDataCount;
    property Data[Index: Integer]: TGridExDataArray read GetDataItem;
  end;

  TDrawGridEx = class(TDrawGrid)
  protected
    procedure CreateParams(var nParams: TCreateParams); override;
    procedure WMCommand(var nMsg: TWMCommand); message WM_COMMAND;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RunSoft', [TDrawGridEx]);
end;

procedure TDrawGridEx.CreateParams(var nParams: TCreateParams);
begin
  inherited CreateParams(nParams);
  ControlStyle := ControlStyle + [csAcceptsControls];
end;

function DoControlMsg(nHandle: HWnd; var nMsg: TWMCommand): Boolean;
var nCtrl: TWinControl;
begin
  DoControlMsg := False;
  nCtrl := FindControl(nHandle);

  if Assigned(nCtrl) then
  with TMessage(nMsg) do
  begin
    Result := nCtrl.Perform(Msg + CN_BASE, WParam, LParam);
    DoControlMsg := True;
  end;
end;

procedure TDrawGridEx.WMCommand(var nMsg: TWMCommand);
begin
  if not DoControlMsg(nMsg.Ctl, nMsg) then inherited;
end;

//------------------------------------------------------------------------------
constructor TGridExPainter.Create(AGrid: TDrawGrid);
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
    DefaultDrawing := False;
    OnSelectCell := GridSelectCell;
    OnDrawCell := GridDrawCell;
    OnTopLeftChanged := DoTopRowChanged;
  end;
end;

destructor TGridExPainter.Destroy;
begin
  FGrid := nil;
  ClearHeader;
  ClearData;
  
  FHeaderFont.Free;
  inherited;
end;

procedure TGridExPainter.ClearHeader;
begin
  SetLength(FHeader, 0);
end;

//Desc: 清理输入
procedure TGridExPainter.ClearData;
var i,nIdx,nInt: Integer;
begin
  for nIdx:=Low(FRowData) to High(FRowData) do
   for nInt:=Low(FRowData[nIdx]) to High(FRowData[nIdx]) do
    if Assigned(FRowData[nIdx][nInt].FCtrls) then
    with FRowData[nIdx][nInt] do
    begin
      for i:=FCtrls.Count - 1 downto 0 do
        TControl(FCtrls[i]).Parent.RemoveControl(FCtrls[i]);
      FCtrls.Free;
      FCtrls := nil;
    end;
  //clear all
  SetLength(FRowData, 0);

  for nIdx:=Low(FColData) to High(FColData) do
   if Assigned(FColData[nIdx].FCtrl) then
    with FColData[nIdx] do
    begin
      TControl(FCtrl).Parent.RemoveControl(FCtrl);
      FCtrl := nil;
    end;
  //clear all

  SetLength(FColData, 0);
  if Assigned(FGrid) then
  begin
    FGrid.RowCount := 2;
    FGrid.Invalidate;
  end;  
end;

//Desc: 返回表头列ACol对应的数据列
function TGridExPainter.GetDataColumn(const ACol: Integer): Integer;
var nIdx: Integer;
begin
  Result := -1;
  if not FHeader[ACol].FSplit then
   for nIdx:=Low(FHeader) to ACol do
    if not FHeader[nIdx].FSplit then Inc(Result);
  //xxxxx
end;

//Desc: 添加标题
procedure TGridExPainter.AddHeader(nText: string; nWidth: Integer; nSplit: Boolean);
var nIdx: Integer;
begin
  nIdx := Length(FHeader);
  SetLength(FHeader, nIdx + 1);

  with FHeader[nIdx] do
  begin
    FText := nText;
    FWidth := nWidth;
    FSplit := nSplit;
    FDataCol := GetDataColumn(nIdx);
  end;

  FGrid.ColCount := nIdx + 1;
  FGrid.ColWidths[nIdx] := nWidth;
end;

//Desc: 添加行数据
procedure TGridExPainter.AddRowData(const nData: TGridExDataArray);
var i,nIdx,nInt: Integer;
begin
  nIdx := Length(FRowData);
  SetLength(FRowData, nIdx + 1);
  SetLength(FRowData[nIdx], Length(nData));

  for nInt:=Low(nData) to High(nData) do
  with FRowData[nIdx][nInt] do
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

//Desc: 检测nCol列当前排到哪一行.
function CurrentRow(const nData: TGridExColDataArray; nCol: Integer): Integer;
var nIdx: Integer;
begin
  Result := 0;

  for nIdx:=Low(nData) to High(nData) do
  if nData[nIdx].FCol = nCol then
  begin
    Result := Result + nData[nIdx].FRows;
    //指定列递增
  end;
end;

//Desc: 添加列数据
procedure TGridExPainter.AddColData(const nData: TGridExColDataArray);
var i,nIdx,nInt: Integer;
begin
  for nIdx:=Low(nData) to High(nData) do
  begin
    i := CurrentRow(FColData, nData[nIdx].FCol);
    //开始行号

    nInt := Length(FColData);
    SetLength(FColData, nInt + 1);

    with FColData[nInt] do
    begin
      FCol :=  nData[nIdx].FCol;
      FRows := nData[nIdx].FRows;
      FText :=  nData[nIdx].FText;
      FCtrl :=  nData[nIdx].FCtrl;
      FAlign :=  nData[nIdx].FAlign;

      with FDraw do
      begin
        FStart := i;
        FEnd := i + FRows - 1;
        FLast := 0;
      end;
    end;
  end;
end;

//Desc: 检索指定索引数据
function TGridExPainter.GetDataItem(Index: Integer): TGridExDataArray;
begin
  Result := FRowData[Index];
end;

//Desc: 数据条目数
function TGridExPainter.GetDataCount: Integer;
begin
  Result := Length(FRowData);
end;

//Desc: 隐藏所有控件
procedure TGridExPainter.HideCtrl(const nAll: Boolean);
var i,nIdx,nInt: Integer;
begin
  for nIdx:=Low(FRowData) to High(FRowData) do
  begin
    if (not nAll) and (nIdx >= FGrid.TopRow - 2) and
       (nIdx <= FGrid.TopRow + FGrid.VisibleRowCount + 1) then Continue;
    //显示的不予隐藏

    for nInt:=Low(FRowData[nIdx]) to High(FRowData[nIdx]) do
    if Assigned(FRowData[nIdx][nInt].FCtrls) then
    with FRowData[nIdx][nInt] do
    begin
      for i:=FCtrls.Count - 1 downto 0 do
        TControl(FCtrls[i]).Visible := False;
      //xxxxx
    end;
  end;

  for nIdx:=Low(FColData) to High(FColData) do
  begin
    if Assigned(FColData[nIdx].FCtrl) then
    with FColData[nIdx]do
    begin
      TControl(FCtrl).Visible := False;
      //xxxxx
    end;
  end;
end;

//Desc: 列表最上记录变动
procedure TGridExPainter.DoTopRowChanged(Sender: TObject);
begin
  FGrid.Invalidate;
  HideCtrl(True);
end;

//Desc: 有组件的单元格不能选中
procedure TGridExPainter.GridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  ACol := GetDataColumn(ACol);
  if ACol < 0 then Exit;
  
  ARow := ARow - 1;
  //record index

  if ARow >= Length(FRowData) then Exit;
  if ACol >= Length(FRowData[ARow]) then Exit;

  CanSelect := not Assigned(FRowData[ARow][ACol].FCtrls);
  //no control
end;

//Desc: 绘制单元格
procedure TGridExPainter.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if not Assigned(FGrid) then Exit;
  //do when free

  if (gdFixed in State) or
     ((gdSelected in State) and (not FHeader[ACol].FSplit)) then
  begin
    FCanvas.Brush.Color := $00FEF7E9;
    FCanvas.FillRect(Rect);
  end else
  begin
    FCanvas.Brush.Color := FGrid.Color;
    FCanvas.FillRect(Rect);
  end;

  if (ARow < 1) or (not FHeader[ACol].FSplit) then
  with FCanvas,Rect do
  begin
    Pen.Width := 1;
    Pen.Color := FLineColor;

    MoveTo(Right, Top);
    LineTo(Left, Top);
    LineTo(Left, Bottom);

    if ARow >= FGrid.RowCount - 1 then
    begin
      Bottom := Bottom - 1;
      MoveTo(Left, Bottom);
      LineTo(Right, Bottom);
    end;

    if ACol >= FGrid.ColCount - 1 then
    begin
      Right := Right - 1;
      MoveTo(Right, Bottom);
      LineTo(Right, Top);
    end;
  end;

  if ARow = 0 then
  begin
    if ACol < Length(FHeader) then
      DrawHeader(ACol, ARow, Rect);
    Exit;
  end;
  
  if FHeader[ACol].FSplit then
  begin
    DrawColData(ACol, ARow - 1, Rect);
  end else
  begin
    DrawRowData(ACol, ARow - 1, Rect);
  end;
end;

//Desc: 绘制表头
procedure TGridExPainter.DrawHeader(ACol, ARow: Integer; Rect: TRect);
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

//Desc: 在nStr中截取nW宽的字符
function TGridExPainter.GetFixWidthStr(const nStr: string; nW: Integer): string;
var nWStr: WideString;
    nIdx,nE,nC,nLen,nCLen : Integer;
begin
  Result := nStr;
  if FCanvas.TextWidth(nStr) <= nW then Exit;

  nE := FCanvas.TextWidth('A');
  nC := FCanvas.TextWidth('汉');

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

//Desc: 绘制行数据
procedure TGridExPainter.DrawRowData(ACol, ARow: Integer; Rect: TRect);
var nStr: string;
    nCtrl: TControl;
    nIdx,nL,nT,nW,nCol: Integer;
begin
  if ARow > High(FRowData) then Exit;
  nCol := ACol;
  ACol := FHeader[ACol].FDataCol;
  if ACol > High(FRowData[ARow]) then Exit;

  with FRowData[ARow][ACol], Rect do
  begin
    if FText <> '' then
    begin
      FCanvas.Font.Assign(FGrid.Font);
      nStr := GetFixWidthStr(FText, FGrid.ColWidths[nCol]);

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
    end; //计算宽度

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

//Desc: 绘制列数据
procedure TGridExPainter.DrawColData(ACol, ARow: Integer; Rect: TRect);
var nStr: string;
    nIdx,nL,nT,nW,nH: Integer;
begin
  nL := -1;
  for nIdx:=Low(FColData) to High(FColData) do
   with FColData[nIdx] do
    if (FCol = ACol) and (ARow >= FDraw.FStart) and (ARow <= FDraw.FEnd) then
    begin
      //if GetTickCount - FDraw.FLast >= 0 then
        nL := nIdx;
      Break;
    end;
  //find fix col data

  if nL < 0 then Exit;
  ACol := nL;

  with FColData[ACol], Rect, FCanvas do
  begin
    nH := Bottom - Top;
    nW := FGrid.TopRow - 1;

    if FDraw.FStart > nW then
         nT := ARow - FDraw.FStart
    else nT := ARow - nW;

    Top := Top - nT * nH;
    Bottom := Bottom + (FDraw.FEnd - ARow) * nH;

    //--------------------------------------------------------------------------
    if FText <> '' then
    begin
      FCanvas.Font.Assign(FGrid.Font);
      nStr := GetFixWidthStr(FText, FGrid.ColWidths[ACol]);

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
      FCanvas.TextOut(nL, nT, nStr);
    end;
                  
    //--------------------------------------------------------------------------
    Pen.Width := 1;
    Pen.Color := FLineColor;

    MoveTo(Right, Top);
    LineTo(Left, Top);
    LineTo(Left, Bottom);

    if ARow >= FGrid.RowCount - 2 then
    begin
      Bottom := Bottom - 1;
      MoveTo(Left, Bottom);
      LineTo(Right, Bottom);
    end;

    if FCol >= FGrid.ColCount - 1 then
    begin
      Right := Right - 1;
      MoveTo(Right, Bottom);
      LineTo(Right, Top);
    end;

    FDraw.FLast := GetTickCount;
    //绘制状态
  end;
end;

end.
