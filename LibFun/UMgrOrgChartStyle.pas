{*******************************************************************************
  ����: dmzn@163.com 2013-3-8
  ����: ����OrgChart���
*******************************************************************************}
unit UMgrOrgChartStyle;

interface

uses
  Windows, Classes, Graphics, SysUtils, IniFiles, dxorgchr;

type
  POrgNodeStyle = ^TOrgNodeStyle;
  TOrgNodeStyle = record
    FType: Word;
    FStyle: TdxOcNodeInfo;
  end;

  POrgChartStyle = ^TOrgChartStyle;
  TOrgChartStyle = record
    FName: string;
    FIndentX: Integer;
    FIndentY: Integer;
    FLineColor: TColor;
    FLineWidth: Byte;
    FNodeList: TList;
  end;

  TOrgChartStyleManager = class(TObject)
  private
    FChart: TList;
    //����б�
  protected
    procedure DeleteChart(const nIndex: Integer);
    procedure ClearList(const nFree: Boolean);
    //������Դ
    function FindChart(const nName: string): Integer;
    function FindNode(const nType: Word; const nNodes: TList): Integer;
    //��������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadChartStyle(const nName: string; const nChart: TdxOrgChart);
    procedure LoadNodeStyle(const nName: string; const nType: Word;
     const nNode: TdxOcNode);
    //Ӧ�÷��
    procedure AddChart(const nStyle: TOrgChartStyle);
    function DelChart(const nName: string): Boolean;
    //��ɾchart
    procedure AddNode(const nName: string; const nNode: TOrgNodeStyle);
    function DelNode(const nName: string; const nType: Integer): Boolean;
    //��ɾnode
    procedure LoadConfig(const nFileName: string);
    procedure SaveConfig(const nFileName: string);
    //��д����
  end;

var
  gChartStyleManager: TOrgChartStyleManager = nil;
  //ȫ��ʹ��

implementation

constructor TOrgChartStyleManager.Create;
begin
  FChart := TList.Create;
end;

destructor TOrgChartStyleManager.Destroy;
begin
  ClearList(True);
  inherited;
end;

//Date: 2013-3-8
//Parm: ����
//Desc: �ͷ�FChart.nIndex��ʶ�Ľڵ�
procedure TOrgChartStyleManager.DeleteChart(const nIndex: Integer);
var nIdx: Integer;
    nChart: POrgChartStyle;
begin
  nChart := FChart[nIndex];
  if Assigned(nChart.FNodeList) then
  begin
    for nIdx:=nChart.FNodeList.Count - 1 downto 0 do
      Dispose(POrgNodeStyle(nChart.FNodeList[nIdx]));
    FreeAndNil(nChart.FNodeList);
  end;

  Dispose(nChart);
  FChart.Delete(nIndex);
end;

//Desc: ������Դ
procedure TOrgChartStyleManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FChart.Count - 1 downto 0 do
    DeleteChart(nIdx);
  //delete item

  if nFree then
    FreeAndNil(FChart);
  //free list
end;

//Date: 2013-3-8
//Parm: chart����
//Desc: ����nName���б��е�����
function TOrgChartStyleManager.FindChart(const nName: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FChart.Count - 1 downto 0 do
  if CompareText(nName, POrgChartStyle(FChart[nIdx]).FName) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2013-3-8
//Parm: ����;�б�
//Desc: ��nNodes�м���nType���͵�����
function TOrgChartStyleManager.FindNode(const nType: Word;
  const nNodes: TList): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=nNodes.Count - 1 downto 0 do
  if POrgNodeStyle(nNodes[nIdx]).FType = nType then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2013-3-8
//Parm: �����
//Desc: ���nStyle
procedure TOrgChartStyleManager.AddChart(const nStyle: TOrgChartStyle);
var nIdx: Integer;
    nList: TList;
    nP: POrgChartStyle;
begin
  nIdx := FindChart(nStyle.FName);
  if nIdx < 0 then
  begin
    New(nP);
    FChart.Add(nP);
    nList := TList.Create;
  end else
  begin
    nP := FChart[nIdx];
    nList := nP.FNodeList;
  end;

  nP^ := nStyle;
  nP.FNodeList := nList;
end;

//Date: 2013-3-8
//Parm: chart����
//Desc: ɾ��nName chart
function TOrgChartStyleManager.DelChart(const nName: string): Boolean;
var nIdx: Integer;
begin
  nIdx := FindChart(nName);
  Result := nIdx >= 0;

  if Result then
    DeleteChart(nIdx);
  //to delete
end;

//Date: 2013-3-8
//Parm: chart��;�ڵ�
//Desc: ΪnName���nNode���
procedure TOrgChartStyleManager.AddNode(const nName: string;
  const nNode: TOrgNodeStyle);
var nIdx: Integer;
    nC: POrgChartStyle;
    nN: POrgNodeStyle;
begin
  nIdx := FindChart(nName);
  if nIdx < 0 then Exit;

  nC := FChart[nIdx];
  nIdx := FindNode(nNode.FType, nC.FNodeList);

  if nIdx < 0 then
  begin
    New(nN);
    nC.FNodeList.Add(nN);
  end else nN := nC.FNodeList[nIdx];

  nN^ := nNode;
  //copy value
end;

//Date: 2013-3-8
//Parm: chart��;����
//Desc: ɾ��nName��nType���͵ķ��
function TOrgChartStyleManager.DelNode(const nName: string;
  const nType: Integer): Boolean;
var nIdx: Integer;
    nChart: POrgChartStyle;
begin
  nIdx := FindChart(nName);
  Result := nIdx >= 0;
  if not Result then Exit;

  nChart := FChart[nIdx];
  nIdx := FindNode(nType, nChart.FNodeList);

  if nIdx >= 0 then
  begin
    Dispose(POrgNodeStyle(nChart.FNodeList[nIdx]));
    nChart.FNodeList.Delete(nIdx);
  end;
end;

//Date: 2013-3-8
//Parm: ����;chart
//Desc: ΪnChartӦ������ΪnName�ķ��
procedure TOrgChartStyleManager.LoadChartStyle(const nName: string;
  const nChart: TdxOrgChart);
var nIdx: Integer;
    nP: POrgChartStyle;
begin
  nIdx := FindChart(nName);
  if nIdx < 0 then Exit;

  nP := FChart[nIdx];
  with nChart do
  begin
    IndentX := nP.FIndentX;
    IndentY := nP.FIndentY;
    LineColor := nP.FLineColor;
    LineWidth := nP.FLineWidth;
  end;
end;

//Date: 2013-3-8
//Parm: ����;����;�ڵ�
//Desc: ΪnNodeӦ�÷��ΪnName.nType�ķ��
procedure TOrgChartStyleManager.LoadNodeStyle(const nName: string;
  const nType: Word; const nNode: TdxOcNode);
var nIdx: Integer;
    nC: POrgChartStyle;
    nN: POrgNodeStyle;
begin
  nIdx := FindChart(nName);
  if nIdx < 0 then Exit;

  nC := FChart[nIdx];
  nIdx := FindNode(nType, nC.FNodeList);
  if nIdx < 0 then Exit;

  nN := nC.FNodeList[nIdx];
  with nNode do
  begin
    Width := nN.FStyle.Width;
    Height := nN.FStyle.Height;
    Color := nN.FStyle.Color;
    Shape := nN.FStyle.Shape;
    ChildAlign := nN.FStyle.Align;
    ImageIndex := nN.FStyle.Index;
    ImageAlign := nN.FStyle.IAlign;
  end;
end;

//Date: 2013-3-8
//Parm: �ļ���
//Desc: ����nFileName����
procedure TOrgChartStyleManager.LoadConfig(const nFileName: string);
var nIni: TIniFile;
    nList: TStrings;
    nC: POrgChartStyle;
    nN: POrgNodeStyle;
    i,nIdx,nOrd: Integer;
begin
  nIni := TIniFile.Create(nFileName);
  nList := TStringList.Create;
  try
    ClearList(False);
    //init list
    nIni.ReadSection('Charts', nList);
    //get chart name list

    for nIdx:=0 to nList.Count - 1 do
    begin
      New(nC);
      FChart.Add(nC);
      nC.FNodeList := TList.Create;

      nC.FName := nIni.ReadString('Charts', nList[nIdx], '');
      nC.FIndentX := nIni.ReadInteger(nC.FName, 'IndentX', 16);
      nC.FIndentY := nIni.ReadInteger(nC.FName, 'IndentY', 16);
      nC.FLineColor := nIni.ReadInteger(nC.FName, 'LineColor', clBlack);
      nC.FLineWidth := nIni.ReadInteger(nC.FName, 'LineWidth', 1);
    end;

    for nIdx:=0 to FChart.Count - 1 do
    begin
      nC := FChart[nIdx];
      nIni.ReadSection(nC.FName, nList);
      //get node style

      for i:=nList.Count - 1 downto 0 do
      if Pos('Node_', nList[i]) > 0 then
      begin
        New(nN);
        nC.FNodeList.Add(nN);
        nN.FType := nIni.ReadInteger(nList[i], 'Type', 0);

        with nN.FStyle do
        begin
          Width := nIni.ReadInteger(nList[i], 'Width', 0);
          Height := nIni.ReadInteger(nList[i], 'Height', 0);
          Color := nIni.ReadInteger(nList[i], 'Color', clNone);

          nOrd := nIni.ReadInteger(nList[i], 'Align', Ord(caCenter));
          Align := TdxOcNodeAlign(nOrd);
          nOrd := nIni.ReadInteger(nList[i], 'Shape', Ord(shRectangle));
          Shape := TdxOcShape(nOrd);

          Index := nIni.ReadInteger(nList[i], 'ImageIndex', 0);
          nOrd := nIni.ReadInteger(nList[i], 'ImageAlign', Ord(iaNone));
          IAlign := TdxOcImageAlign(nOrd);
        end;
      end;
    end;
  finally
    nList.Free;
    nIni.Free;
  end;   
end;

//Date: 2013-3-8
//Parm: �ļ���
//Desc: �������õ�nFileName�ļ�
procedure TOrgChartStyleManager.SaveConfig(const nFileName: string);
var nStr: string;
    nIni: TIniFile;
    i,nIdx: Integer;
    nC: POrgChartStyle;
    nN: POrgNodeStyle;
begin
  nIni := TIniFile.Create(nFileName);
  try
    nIni.EraseSection('Charts');
    //init

    for nIdx:=0 to FChart.Count - 1 do
    begin
      nC := FChart[nIdx];
      nIni.WriteString('Charts', IntToStr(nIdx), nC.FName);
      //name list

      nIni.EraseSection(nC.FName);
      //init chart section

      nIni.WriteInteger(nC.FName, 'IndentX', nC.FIndentX);
      nIni.WriteInteger(nC.FName, 'IndentY', nC.FIndentY);
      nIni.WriteInteger(nC.FName, 'LineColor', nC.FLineColor);
      nIni.WriteInteger(nC.FName, 'LineWidth', nC.FLineWidth);

      for i:=0 to nC.FNodeList.Count - 1 do
      begin
        nN := NC.FNodeList[i];
        nStr := 'Node_' + nC.FName + '_' + IntToStr(nN.FType);
        nIni.WriteString(nC.FName, nStr, IntToStr(i));

        with nN.FStyle do
        begin
          nIni.WriteInteger(nStr, 'Type', nN.FType);
          nIni.WriteInteger(nStr, 'Width', nN.FStyle.Width);
          nIni.WriteInteger(nStr, 'Height', Height);
          nIni.WriteInteger(nStr, 'Color', Color);
          nIni.WriteInteger(nStr, 'Align', Ord(Align));
          nIni.WriteInteger(nStr, 'Shape', Ord(Shape));
          nIni.WriteInteger(nStr, 'ImageIndex', Index);
          nIni.WriteInteger(nStr, 'ImageAlign', Ord(IAlign));
        end;
      end;
    end;
  finally
    nIni.Free;
  end;   
end;

initialization
  gChartStyleManager := TOrgChartStyleManager.Create;
finalization
  FreeAndNil(gChartStyleManager);
end.
