{*******************************************************************************
  作者: dmzn@163.com 2013-08-30
  描述: 以Key-Value模式显示数值项,支持分组

  备注:
  *.增删数据时,组件非线程安全.
  *.若使用TZnVLData.FData自定义数据,需关联OnDataFree手动释放.
  *.若TZnVLData.FType为图像类型,则FData必须为PZnVLPicture结构.
*******************************************************************************}
unit UZnValueList;

interface

uses
  Windows, Classes, Controls, Forms, Graphics, Grids, Messages, SysUtils,
  ValEdit;

type
  TZnVLPictureAlign = (paLeft, paRight);
  //图像位置

  PZnVLPictureData = ^TZnVLPictureData;
  TZnVLPictureData = record
    FText: string;                      //文本内容
    FIcon: TBitmap;                     //图像内容
    FFlag: Integer;                     //图像索引
    FLoop: Byte;                        //重复次数
    FAlign: TZnVLPictureAlign;          //图像位置
  end;

  PZnVLPicture = ^TZnVLPicture;
  TZnVLPicture = record
    FKey: TZnVLPictureData;             //键内容
    FValue: TZnVLPictureData;           //值内容
  end;

  TZnVLType = (vtText, vtPicture, vtGroup);
  //文本,图像,分组
  
  PZnVLData = ^TZnVLData;
  TZnVLData = record
    FType: TZnVLType;                   //类型
    FKey: string;                       //键
    FValue: string;                     //值

    FFlag: string;                      //标识
    FData: Pointer;                     //数据
  end;

  TZnVLFreeDataProc = procedure (const nData: PZnVLData);
  TZnVLFreeDataEvent = procedure (const nData: PZnVLData) of object;
  TZnVLMouseMoveProc = procedure (Shift: TShiftState; X, Y: Integer;
    const nData: PZnVLData);
  TZnVLMouseMoveEvent = procedure (Shift: TShiftState; X, Y: Integer;
    const nData: PZnVLData) of object;
  //事件定义

  TZnValueList = class(TValueListEditor)
  private
    FData: TList;
    //数据列表
    FColorGroup: TColor;
    FColorSelect: TColor;
    //颜色项
    FSpaceGroup: Word;
    FSpaceItem: Word;
    FSpaceValue: Word;
    //居左偏移
    FAutoFocus: Boolean;
    //自动焦点
    FOnFreeProc: TZnVLFreeDataProc;
    FOnFreeEvent: TZnVLFreeDataEvent;
    FOnMMProc: TZnVLMouseMoveProc;
    FOnMMEvent: TZnVLMouseMoveEvent;
    //事件相关
  protected
    procedure FreeData(const nData: PZnVLData; nOnlyExt: Boolean);
    procedure ClearData(const nFree: Boolean);
    //清理资源
    procedure DrawPicture(const nPic: PZnVLPictureData; var nRect: TRect);
    procedure DrawText(const nText: string; var nRect: TRect);
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
    //绘制表格
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    //处理滚轮
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //创建释放
    function AddPicture(const nKey,nValue: string; const nFlag: string = '';
     const nInsFlag: string = ''; const nInsBack: Boolean = True): PZnVLPicture;
    procedure AddData(const nKey,nValue: string; const nData: Pointer = nil;
     const nFlag: string = ''; const nType: TZnVLType = vtText;
     const nInsFlag: string = ''; const nInsBack: Boolean = True);
    procedure DeleteData(const nFlag: string; const nDim: Boolean = False);
    procedure ClearAll;
    //添加删除
    function FindData(const nFlag: string; const nIdx: PINT = nil): PZnVLData;
    function FindLast(const nDimFlag: string; const nIdx: PINT = nil): PZnVLData;
    function GetSelectData(const nIdx: PINT = nil): PZnVLData;
    //检索删除
    property DataList: TList read FData;
    property OnDataFreeP: TZnVLFreeDataProc read FOnFreeProc write FOnFreeProc;
    property OnMouseMoveP: TZnVLMouseMoveProc read FOnMMProc write FOnMMProc;
    //属性相关
  published
    property AutoFocus: Boolean read FAutoFocus write FAutoFocus;
    property ColorGroup: TColor read FColorGroup write FColorGroup;
    property ColorSelected: TColor read FColorSelect write FColorSelect;
    property SpaceGroup: Word read FSpaceGroup write FSpaceGroup;
    property SpaceItem: Word read FSpaceItem write FSpaceItem;
    property SpaceValue: Word read FSpaceValue write FSpaceValue;
    property OnDataFree: TZnVLFreeDataEvent read FOnFreeEvent write FOnFreeEvent;
    property OnMouseMoveE: TZnVLMouseMoveEvent read FOnMMEvent write FOnMMEvent;
    //属性宣告
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RunSoft', [TZnValueList]);
end;

constructor TZnValueList.Create(AOwner: TComponent);
begin
  inherited;
  FData := TList.Create;

  FAutoFocus := True;
  FColorGroup := $009FD5FF;
  FColorSelect := clSkyBlue;

  FSpaceGroup := 2;
  FSpaceItem := 3;
  FSpaceValue := 2;

  BorderStyle := bsNone;
  DefaultDrawing := False;
  DefaultRowHeight := 20;

  Options := Options - [goFixedVertLine];
  Options := Options - [goFixedHorzLine];
  Options := Options - [goVertLine];
  Options := Options - [goHorzLine];
  Options := Options - [goEditing];
  Options := Options - [goAlwaysShowEditor];
end;

destructor TZnValueList.Destroy;
begin
  ClearData(True);
  inherited;
end;

function TZnValueList.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := True;
  Perform(WM_VSCROLL, SB_LINEDOWN, 0);
end;

function TZnValueList.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := True;
  Perform(WM_VSCROLL, SB_LINEUP, 0);
end;

procedure TZnValueList.MouseMove(Shift: TShiftState; X, Y: Integer);
var nCol,nRow: Integer;
begin
  if not ((csDesigning in ComponentState) or
          (csDestroying in ComponentState)) then
  begin
    if FAutoFocus and (not Focused) then
      SetFocus;
    //auto focus

    MouseToCell(X, Y, nCol, nRow);
    Dec(nRow, FixedRows);
    //data index

    if (nRow >= 0) and (nRow < FData.Count) then
    begin
      if Assigned(FOnMMProc) then
        FOnMMProc(Shift, X, Y, FData[nRow]);
      //xxxxx

      if Assigned(FOnMMEvent) then
        FOnMMEvent(Shift, X, Y, FData[nRow]);
      //xxxxx
    end;
  end;

  inherited MouseMove(Shift, X, Y);
end;

//------------------------------------------------------------------------------
//Date: 2013-08-31
//Parm: 数据;只释放扩展
//Desc: 释放nData数据项
procedure TZnValueList.FreeData(const nData: PZnVLData; nOnlyExt: Boolean);
var nPic: PZnVLPicture;
begin
  if Assigned(nData) then
  begin
    if Assigned(nData.FData) then
    begin
      if nData.FType = vtPicture then
      begin
        nPic := nData.FData;
        nData.FData := nil;
        
        if Assigned(nPic.FKey.FIcon) then
          nPic.FKey.FIcon.Free;
        //xxxxx

        if Assigned(nPic.FValue.FIcon) then
          nPic.FValue.FIcon.Free;
        Dispose(nPic);
      end else
      begin
        if Assigned(FOnFreeEvent) then
          FOnFreeEvent(nData);
        //xxxxx

        if Assigned(FOnFreeProc) then
          FOnFreeProc(nData);
        nData.FData := nil;
      end;
    end;

    if not nOnlyExt then
      Dispose(nData);
    //xxxxx
  end;
end;

procedure TZnValueList.ClearData(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FData.Count - 1 downto 0 do
  begin
    FreeData(FData[nIdx], False);
    FData.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FData);
  Strings.Clear;
end;

//Date: 2013-08-31
//Desc: 清空列表
procedure TZnValueList.ClearAll;
begin
  ClearData(False);
end;

//Date: 2013-08-31
//Parm: 标识;模糊匹配
//Desc: 删除标识为nFlag的数据项
procedure TZnValueList.DeleteData(const nFlag: string; const nDim: Boolean);
var nLStr: string;
    nIdx: Integer;
    nData: PZnVLData;
begin
  if nDim then
    nLStr := LowerCase(nFlag);
  //for dim search

  for nIdx:=FData.Count - 1 downto 0 do
  begin
    nData := FData[nIdx];
    if (nDim and (Pos(nLStr, LowerCase(nData.FFlag)) > 0)) or
       (CompareText(nFlag, nData.FFlag) = 0) then
    begin
      FreeData(FData[nIdx], False);
      FData.Delete(nIdx);

      if Strings.Count > 0 then
        Strings.Delete(0);
      //xxxxx
    end;
  end;

  Invalidate;
end;

//------------------------------------------------------------------------------
//Date: 2013-08-31
//Parm: 标识;索引
//Desc: 检索标识为nFlag的数据项
function TZnValueList.FindData(const nFlag: string; const nIdx: PINT): PZnVLData;
var nI: Integer;
    nData: PZnVLData;
begin
  if Assigned(nIdx) then
    nIdx^ := -1;
  Result := nil;

  for nI:=FData.Count - 1 downto 0 do
  begin
    nData := FData[nI];
    if CompareText(nFlag, nData.FFlag) = 0 then
    begin
      if Assigned(nIdx) then
        nIdx^ := nI;
      //return index

      Result := nData;
      Break;
    end;
  end;
end;

//Date: 2013-11-17
//Parm: 模糊标识;索引
//Desc: 检索标识里包含nDimFlag的最后一个项在列表中的位置
function TZnValueList.FindLast(const nDimFlag: string; const nIdx: PINT): PZnVLData;
var nI: Integer;
    nLStr: string;
    nData: PZnVLData;
begin
  Result := nil;
  if Assigned(nIdx) then
    nIdx^ := -1;
  nLStr := LowerCase(nDimFlag);

  for nI:=FData.Count - 1 downto 0 do
  begin
    nData := FData[nI];
    if Pos(nLStr, LowerCase(nData.FFlag)) > 0 then
    begin
      if Assigned(nIdx) then
        nIdx^ := nI;
      //return index

      Result := nData;
      Break;
    end;
  end;
end;

//Date: 2013-11-17
//Parm: 索引
//Desc: 返回选中行的数据
function TZnValueList.GetSelectData(const nIdx: PINT): PZnVLData;
var nRow: Integer;
begin
  nRow := Self.Row;
  Dec(nRow, FixedRows);

  if (nRow >= 0) and (nRow < FData.Count) then
  begin
    if Assigned(nIdx) then
      nIdx^ := nRow;
    Result := FData[nRow];
  end else
  begin
    if Assigned(nIdx) then
      nIdx^ := -1;
    Result := nil;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2013-08-30
//Parm: 键;值;数据;类型;插入点;插入位置
//Desc: 添加新数据到列表,位置在nInsFlag.nInsPre指定位置
procedure TZnValueList.AddData(const nKey,nValue: string; const nData: Pointer;
  const nFlag: string; const nType: TZnVLType;
  const nInsFlag: string; const nInsBack: Boolean);
var nIdx: Integer;
    nNew: PZnVLData;
begin
  if nFlag <> '' then
  begin
    nNew := FindData(nFlag);
    FreeData(nNew, True);
  end else nNew := nil;

  if not Assigned(nNew) then
  begin
    if nInsFlag = '' then
         nIdx := -1
    else FindData(nInsFlag, @nIdx);

    if nInsBack and (nIdx >= 0) then
      Inc(nIdx, 1);
    //指定节点后面索引

    New(nNew);
    if nIdx < 0 then
         FData.Add(nNew)
    else FData.Insert(nIdx, nNew);

    InsertRow('k', 'v', True);
    //new data row
  end;

  nNew.FType := nType;
  nNew.FKey := nKey;
  nNew.FValue := nValue;

  nNew.FFlag := nFlag;
  nNew.FData := nData;
end;

//Date: 2013-08-31
//Desc: 申请图像节点
function TZnValueList.AddPicture(const nKey,nValue: string; 
 const nFlag,nInsFlag: string; const nInsBack: Boolean): PZnVLPicture;
begin
  New(Result);
  AddData(nKey, nValue, Result, nFlag, vtPicture, nInsFlag, nInsBack);
  FillChar(Result^, SizeOf(TZnVLPicture), #0);

  with Result.FKey do
  begin
    FText := nKey;
    FAlign := paLeft;
    FFlag := -1;
  end;

  with Result.FValue do
  begin
    FText := nValue;
    FAlign := paLeft;
    FFlag := -1;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2013-08-31
//Parm: 图;区域
//Desc: 在nRect中绘制nPic图像
procedure TZnValueList.DrawPicture(const nPic: PZnVLPictureData; var nRect: TRect);
var nMid,nNum: Integer;
begin
  if nPic.FAlign = paRight then
  begin
    nMid := Trunc((nRect.Bottom - nRect.Top -
            Canvas.TextHeight(nPic.FText)) / 2) + nRect.Top;
    Canvas.TextOut(nRect.Left, nMid, nPic.FText);

    Inc(nRect.Left, Canvas.TextWidth(nPic.FText) + 2);
    //图像开始
  end;

  if Assigned(nPic.FIcon) then
  begin
    if nPic.FLoop < 1 then
      nPic.FLoop := 1;
    nMid := Trunc((nRect.Bottom - nRect.Top - nPic.FIcon.Height)/ 2) + nRect.Top;

    for nNum:=1 to nPic.FLoop do
    begin
      Canvas.Draw(nRect.Left, nMid, nPic.FIcon);
      Inc(nRect.Left, nPic.FIcon.Width);
    end;
  end;

  if nPic.FAlign = paLeft then
  begin
    nMid := Trunc((nRect.Bottom - nRect.Top -
            Canvas.TextHeight(nPic.FText)) / 2) + nRect.Top;
    Canvas.TextOut(nRect.Left + 2, nMid, nPic.FText);
  end;
end;

//Date: 2013-09-10
//Parm: 文本;区域
//Desc: 在nRect中绘制nText文本
procedure TZnValueList.DrawText(const nText: string; var nRect: TRect);
var nMid: Integer;
begin
  nMid := Trunc((nRect.Bottom - nRect.Top - Canvas.TextHeight(nText)) / 2) +
          nRect.Top;
  Canvas.TextOut(nRect.Left, nMid, nText);

  nRect.Left := nRect.Left + Canvas.TextWidth(nText);
  //adjust rect
end;

//Date: 2013-09-10
//Desc: 绘制指定单元格
procedure TZnValueList.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var nData: PZnVLData;
begin
  with Canvas do
  begin
    if (FixedRows > 0) and (ARow = 0) then
    begin
      Brush.Color := $00F2F2F2;
      FillRect(ARect);

      Canvas.Font.Assign(Self.Font);
      SetBkMode(Canvas.Handle, TRANSPARENT);

      if ACol = 0 then
      begin
        ARect.Left := ARect.Left + FSpaceGroup;
        if TitleCaptions.Count > 0 then
             DrawText(TitleCaptions[0], ARect)
        else DrawText('信息项', ARect);
      end else

      if ACol = 1 then
      begin
        ARect.Left := ARect.Left + FSpaceValue;
        if TitleCaptions.Count > 1 then
             DrawText(TitleCaptions[1], ARect)
        else DrawText('内容', ARect);
      end;

      Exit;
    end; //title row

    //--------------------------------------------------------------------------
    if (csDesigning in ComponentState) or
       (csDestroying in ComponentState) then Exit;
    //do nothing

    Dec(ARow, FixedRows);
    if (ARow < 0) or (FData.Count <= ARow) then Exit;
    nData := FData[ARow];
    //待绘制数据项

    if gdSelected in AState then
    begin
      Brush.Color := FColorSelect;
    end else
    begin
      if ARow mod 2 = 0 then
           Brush.Color := $00FBFBFB
      else Brush.Color := clWhite;
    end; //设置内容背景色
         
    if nData.FType = vtGroup then
      Brush.Color := FColorGroup;
    FillRect(ARect);
    //绘制背景

    if ACol = 1 then
    begin
      ARect.Left := ARect.Left + FSpaceValue;
    end else
    begin
      if nData.FType = vtGroup then
           ARect.Left := ARect.Left + FSpaceGroup
      else ARect.Left := ARect.Left + FSpaceItem;
    end; //设置内容偏移 

    if nData.FType = vtText then
    begin
      Canvas.Font.Assign(Self.Font);
      SetBkMode(Canvas.Handle, TRANSPARENT);

      if ACol = 0 then
           DrawText(nData.FKey, ARect)
      else DrawText(nData.FValue, ARect);
    end else //绘制文本项

    if nData.FType = vtGroup then
    begin
      Canvas.Font.Assign(Self.Font);
      Canvas.Font.Style := Canvas.Font.Style + [fsBold];
      SetBkMode(Canvas.Handle, TRANSPARENT);
      
      if ACol = 0 then
           DrawText(nData.FKey, ARect)
      else DrawText(nData.FValue, ARect);
    end else //绘制分组

    if nData.FType = vtPicture then
    begin
      Canvas.Font.Assign(Self.Font);
      SetBkMode(Canvas.Handle, TRANSPARENT);
      
      if ACol = 0 then
           DrawPicture(@PZnVLPicture(nData.FData).FKey, ARect)
      else DrawPicture(@PZnVLPicture(nData.FData).FValue, ARect);
    end;

    if (ACol = 0) and (nData.FType <> vtGroup) then
    begin
      Pen.Style := psDot;
      Pen.Width := 1;
      Pen.Color := clSilver;

      MoveTo(ARect.Right - 1, ARect.Top);
      LineTo(ARect.Right - 1, ARect.Bottom);
    end; //绘制右边线
  end;
end;

end.
