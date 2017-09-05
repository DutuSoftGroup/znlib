{*******************************************************************************
  ����: dmzn@ylsoft.com 2011-03-13
  ����: LED���ƿ�����
*******************************************************************************}
unit UMgrLEDCard;

{$I Link.Inc}
interface

uses
  Windows, SysUtils, Classes, Forms, Graphics, NativeXml, UWaitItem, ULibFun,
  UMgrQueue, USysLoger, JclUnicode;

const
  //�ط�����
  cSend_TryNum                      = 3;

  //��ʱ�����ļ�
  cSend_HeadFile                    = 'head.txt';
  cSend_HeadFileRTF                 = 'head.rtf';
  cSend_FootFile                    = 'foot.txt';

  //˫����ʱ�ļ������ʼ
  cSend_DoublePaintBase             = 100;
  cSend_DoublePaintFile             = 'LEDRes.txt';

  //������ͨѶģʽ
  SEND_MODE_SERIALPORT              = 0;
  SEND_MODE_NETWORK                 = 2;
  SEND_MODE_SAVEFILE                = 5;
  
  //�û�������Ϣ�����
  SEND_CMD_PARAMETER                = $A1FF; //������������
  SEND_CMD_SCREENSCAN               = $A1FE; //����ɨ�跽ʽ��
  SEND_CMD_SENDALLPROGRAM           = $A1F0; //�������н�Ŀ��Ϣ��
  SEND_CMD_POWERON                  = $A2FF; //ǿ�ƿ���
  SEND_CMD_POWEROFF                 = $A2FE; //ǿ�ƹػ�
  SEND_CMD_TIMERPOWERONOFF          = $A2FD; //��ʱ���ػ�
  SEND_CMD_CANCEL_TIMERPOWERONOFF   = $A2FC; //ȡ����ʱ���ػ�
  SEND_CMD_RESIVETIME               = $A2FB; //У��ʱ�䡣
  SEND_CMD_ADJUSTLIGHT              = $A2FA; //���ȵ�����

  //ͨѶ���󷵻ش���ֵ
  RETURN_NOERROR                    = 0;
  RETURN_ERROR_NO_USB_DISK          = $F5;
  RETURN_ERROR_NOSUPPORT_USB        = $F6;
  RETURN_ERROR_AERETYPE             = $F7;
  RETURN_ERROR_RA_SCREENNO          = $F8;
  RETURN_ERROR_NOFIND_AREAFILE      = $F9;
  RETURN_ERROR_NOFIND_AREA          = $FA;
  RETURN_ERROR_NOFIND_PROGRAM       = $FB;
  RETURN_ERROR_NOFIND_SCREENNO      = $FC;
  RETURN_ERROR_NOW_SENDING          = $FD;
  RETURN_ERROR_OTHER                = $FF;

  //����������
  CONTROLLER_TYPE_4M1               = $0142;
  CONTROLLER_TYPE_4M                = $0042;
  CONTROLLER_TYPE_5M1               = $0052;
  CONTROLLER_TYPE_5M2               = $0252;
  CONTROLLER_TYPE_5M3               = $0352;
  CONTROLLER_TYPE_5M4               = $0452;

  CONTROLLER_BX_5E1                 = $0154;
  CONTROLLER_BX_5E2                 = $0254;
  CONTROLLER_BX_5E3                 = $0354; //��̬����

  {************************* ���¶������ڶ�̬���� ***************************}
  RUN_MODE_CYCLE_SHOW               = 0;
  //��̬������ѭ����ʾ��
  RUN_MODE_SHOW_LAST_PAGE           = 1;
  //��̬��������ʾ��ɺ�ֹ��ʾ���һҳ���ݣ�
  RUN_MODE_SHOW_CYCLE_WAITOUT_NOSHOW = 2;
  //��̬������ѭ����ʾ�������趨ʱ���������δ����ʱ������ʾ��
  RUN_MODE_SHOW_ORDERPLAYED_NOSHOW  = 4;
  //��̬������˳����ʾ����ʾ�����һҳ��Ͳ�����ʾ

  //����״̬���붨��
  RETURN_ERROR_NOFIND_DYNAMIC_AREA  = $E1;
  RETURN_ERROR_NOFIND_DYNAMIC_AREA_FILE_ORD = $E2;
  RETURN_ERROR_NOFIND_DYNAMIC_AREA_PAGE_ORD = $E3;
  RETURN_ERROR_NOSUPPORT_FILETYPE   = $E4;

type
  TCardCode = record
    FCode: Word;
    FDesc: string;
  end;

const
  cCardEffects: array[0..39] of TCardCode = (
             (FCode: $00; FDesc:'�����ʾ'),
             (FCode: $01; FDesc:'��̬'),
             (FCode: $02; FDesc:'���ٴ��'),
             (FCode: $03; FDesc:'�����ƶ�'),
             (FCode: $04; FDesc:'��������'),
             (FCode: $05; FDesc:'�����ƶ�'),
             (FCode: $06; FDesc:'��������'),
             (FCode: $07; FDesc:'��˸'),
             (FCode: $08; FDesc:'Ʈѩ'),
             (FCode: $09; FDesc:'ð��'),
             (FCode: $0A; FDesc:'�м��Ƴ�'),
             (FCode: $0B; FDesc:'��������'),
             (FCode: $0C; FDesc:'���ҽ�������'),
             (FCode: $0D; FDesc:'���½�������'),
             (FCode: $0E; FDesc:'����պ�'),
             (FCode: $0F; FDesc:'�����'),
             (FCode: $10; FDesc:'��������'),
             (FCode: $11; FDesc:'��������'),
             (FCode: $12; FDesc:'��������'),
             (FCode: $13; FDesc:'��������'),
             (FCode: $14; FDesc:'��������'),
             (FCode: $15; FDesc:'��������'),
             (FCode: $16; FDesc:'��������'),
             (FCode: $17; FDesc:'��������'),
             (FCode: $18; FDesc:'���ҽ�����Ļ'),
             (FCode: $19; FDesc:'���½�����Ļ'),
             (FCode: $1A; FDesc:'��ɢ����'),
             (FCode: $1B; FDesc:'ˮƽ��ҳ'),
             (FCode: $1D; FDesc:'������Ļ'),
             (FCode: $1E; FDesc:'������Ļ'),
             (FCode: $1F; FDesc:'������Ļ'),
             (FCode: $20; FDesc:'������Ļ'),
             (FCode: $21; FDesc:'���ұպ�'),
             (FCode: $22; FDesc:'���ҶԿ�'),
             (FCode: $23; FDesc:'���±պ�'),
             (FCode: $24; FDesc:'���¶Կ�'),
             (FCode: $25; FDesc:'��������'),
             (FCode: $26; FDesc:'��������'),
             (FCode: $27; FDesc:'�����ƶ�'),
             (FCode: $28; FDesc:'��������'));
  //ϵͳ֧�ֵ���Ч

type
  TCardFont = record
    FFontName: string;      //����
    FFontSize: Integer;     //��С
    FFontBold: Boolean;     //�Ӵ�

    FSpeed: Integer;        //����
    FKeep: Integer;         //ͣ��
    FEffect: Integer;       //��Ч
  end;

  PCardItem = ^TCardItem;
  TCardItem = record
    FType: Integer;         //����(4m,4m1)
    FID: string;            //��ʶ
    FName: string;          //����
    FGroup: string;         //����
    FDoublePaint: Boolean;  //˫����,С���ַ���
    FEnabled: Boolean;      //�Ƿ�����

    FIP: string;            //IP
    FPort: Integer;         //�˿�
    FWidth: Integer;        //���
    FHeight: Integer;       //�߶�
    FDataOE: Integer;       //OE�趨

    FHeadEnable: Boolean;
    FHeadRect: TRect;
    FHeadText: string;
    FHeadFont: TCardFont;   //��ͷ

    FDataEnable: Boolean;
    FStatusEnable: Boolean;
    FColWidth: array of Integer;
    FRowNum: Integer;
    FRowHeight: Integer;
    FPicNum: Integer;
    FDataRect: TRect;
    FDataFont: TCardFont;
    FDataTunnels: string;   //��Чͨ��
    FDataItemNum: Integer;  //��ϸ����
    FFontHeadSAdjust: Integer;
    FFontHeadLAdjust: Integer;
    FFontDataLAdjust: Integer; //����

    FFootEnable: Boolean;
    FFootRect: TRect;
    FFootText: string;
    FFootDefault: string;
    FFootDefaultOnly: Boolean;
    FFootFormat: string;
    FFootFont: TCardFont;   //��β
  end;

  TCardManager = class;
  TCardSendThread = class(TThread)
  private
    FOwner: TCardManager;
    //ӵ����
    FFileOpt: TStrings;
    FFileUTF: TWideStringList;
    //�ļ�����
    FWaiter: TWaitObject;
    //�ȴ�����
    FNowItem: PCardItem;
    //��ǰ����
    FQueueLast: Int64;
    //���б䶯
    FDLLHandle: THandle;
    //������
  protected
    procedure Execute; override;
    //ִ���߳�
    procedure DrawQueue(const nFileBase: Integer);
    //���ƶ���
    function SendDynamicData: Boolean;
    function SendQueueData: Boolean;
    //���Ͷ���
    procedure BuildFootFormatText;
    //������β
    function GetUTFResource(const nStr: WideString): WideString;
    //UTF��Դ
    function GetBMPFile(const nGroup: string; nID: Integer): string;
    //ͼƬ�ļ���
  public
    constructor Create(AOwner: TCardManager);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TCardManager = class(TObject)
  private
    FCards: TList;
    //���б�     
    FFileName: string;
    //�洢�ļ�
    FTempDir: string;
    //��ʱĿ¼
    FSender: TCardSendThread;
    //�����߳�
  protected
    procedure ClearList(const nFree: Boolean);
    //������Դ
    procedure SetFileName(const nFile: string);
    //�����ļ�
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure StartSender;
    procedure StopSender;
    //��ͣ����
    function GetErrorDesc(const nErr: Integer): string;
    //��������
    property Cards: TList read FCards;
    property TempDir: string read FTempDir write FTempDir;
    property FileName: string read FFileName write SetFileName;
    //�������
  end;

var
  gCardManager: TCardManager = nil;
  //ȫ��ʹ��

implementation

const
  cDLL        = 'BX_IV.dll';

function InitDLLResource(nHandle: Integer): integer; stdcall; external cDLL;
procedure FreeDLLResource; stdcall; external cDLL;
//��ʼ���ͷ�
function AddScreen(nControlType, nScreenNo, nWidth, nHeight, nScreenType,
  nPixelMode: Integer; nDataDA, nDataOE: Integer; nRowOrder, nFreqPar: Integer;
  pCom: PChar; nBaud: Integer;
  pSocketIP: PChar; nSocketPort: Integer;
  pFileName: PChar): integer; stdcall; stdcall; external cDLL;
//��ӡ�������ʾ��
function AddScreenProgram(nScreenNo, nProgramType: Integer; nPlayLength: Integer;
  nStartYear, nStartMonth, nStartDay, nEndYear, nEndMonth, nEndDay: Integer;
  nMonPlay, nTuesPlay, nWedPlay, nThursPlay, bFriPlay, nSatPlay,
  nSunPlay: integer; nStartHour, nStartMinute, nEndHour,
  nEndMinute: Integer): Integer; stdcall; external cDLL;
//��ָ����ʾ����ӽ�Ŀ
function AddScreenProgramBmpTextArea(nScreenNo, nProgramOrd: Integer;
  nX, nY, nWidth, nHeight: integer): Integer; stdcall; external cDLL;
//��ָ����ʾ��ָ����Ŀ���ͼ������
function AddScreenProgramAreaBmpTextFile(nScreenNo, nProgramOrd,
  nAreaOrd: Integer; pFileName: PChar; nShowSingle: Integer;
  pFontName: PChar; nFontSize, nBold, nFontColor: Integer; nStunt, nRunSpeed,
  nShowTime: Integer): Integer; stdcall; external cDLL;
//��ָ����ʾ��ָ����Ŀָ����������ļ�
function DeleteScreen(nScreenNo: Integer): Integer; stdcall; external cDLL;
//ɾ��ָ����ʾ��
function DeleteScreenProgram(nScreenNo,
  nProgramOrd: Integer): Integer; stdcall; external cDLL;
//ɾ��ָ����ʾ��ָ����Ŀ
function DeleteScreenProgramArea(nScreenNo, nProgramOrd,
  nAreaOrd: Integer): Integer; stdcall; external cDLL;
//ɾ��ָ����ʾ��ָ����Ŀ��ָ������
function DeleteScreenProgramAreaBmpTextFile(nScreenNo, nProgramOrd, nAreaOrd,
  nFileOrd: Integer): Integer; stdcall; external cDLL;
//ɾ��ָ����ʾ��ָ����Ŀָ��ͼ�������ָ���ļ�
function SendScreenInfo(nScreenNo, nSendMode, nSendCmd,
  nOtherParam1: Integer): Integer; stdcall; external cDLL;
//������Ӧ�����ʾ��

{*************************** ���¶������ڶ�̬���� ***************************}
const
  cDLLDyn     = 'BX_Dyn.dll';

function DynAddScreen(nControlType, nScreenNo, nSendMode, nWidth, nHeight,
  nScreenType, nPixelMode: Integer;
  pCom: PChar; nBaud: Integer; pSocketIP: PChar; nSocketPort: Integer;
  pCommandDataFile: pChar): integer; stdcall; external cDLLDyn name 'AddScreen';
//��̬���������ʾ����Ϣ
function AddScreenDynamicArea(nScreenNo, nDYAreaID: Integer; nRunMode: Integer;
  nTimeOut, nAllProRelate: Integer; pProRelateList: PChar;
  nPlayPriority: Integer; nAreaX, nAreaY, nAreaWidth, nAreaHeight: Integer;
  nAreaFMode, nAreaFLine, nAreaFColor, nAreaFStunt, nAreaFRunSpeed,
  nAreaFMoveStep: Integer): Integer; stdcall; external cDLLDyn;
//��̬����ָ����ʾ����Ӷ�̬����
function AddScreenDynamicAreaFile(nScreenNo, nDYAreaID: Integer;
  pFileName: PChar; nShowSingle: integer; pFontName: PChar;
  nFontSize, nBold, nFontColor: Integer;
  nStunt, nRunSpeed, nShowTime: Integer): Integer; stdcall; external cDLLDyn;
//��̬����ָ����ʾ����ָ����̬���������Ϣ�ļ�
function DynDeleteScreen(nScreenNo: Integer): Integer; stdcall;
  external cDLLDyn name 'DeleteScreen';
//ɾ����̬����ָ����ʾ����������Ϣ
function DeleteScreenDynamicAreaFile(nScreenNo, nDYAreaID,
  nFileOrd: Integer): Integer; stdcall; external cDLLDyn;
//ɾ����̬����ָ����ʾ��ָ���Ķ�̬����ָ���ļ���Ϣ
function SendDynamicAreaInfoCommand(nScreenNo,
  nDYAreaID: Integer): Integer; stdcall; external cDLLDyn;
//���Ͷ�̬����ָ����ʾ��ָ���Ķ�̬������Ϣ����ʾ��
function SendDeleteDynamicAreasCommand(nScreenNo, nDelAllDYArea: Integer;
  pDYAreaIDList: PChar): Integer; stdcall; external cDLLDyn;
//ɾ����̬����ָ����ʾ��ָ���Ķ�̬������Ϣ
function SendUpdateDynamicAreaPageInfoCommand(nScreenNo, nDYAreaID, nFileOrd,
  nPageOrd: Integer): Integer; stdcall; external cDLLDyn;
//��̬����ָ����ʾ��ָ���Ķ�̬���򵥶�����ָ��������ҳ��Ϣ
function SendDeleteDynamicAreaPageCommand(nScreenNo, nDYAreaID: Integer;
  pDYAreaPageOrdList: PChar): Integer; stdcall; external cDLLDyn;
//ɾ����̬����ָ����ʾ����ָ����̬����ָ��������ҳ��Ϣ

//------------------------------------------------------------------------------
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TCardManager, 'LED��ʾ������', nEvent);
end;

constructor TCardSendThread.Create(AOwner: TCardManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;

  FFileOpt := TStringList.Create;
  FFileUTF := TWideStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 5 * 1000;

  FQueueLast := 0;
  FDLLHandle := InitDLLResource(Application.Handle);
end;

destructor TCardSendThread.Destroy;
begin
  FWaiter.Free;
  FFileOpt.Free;
  FFileUTF.Free;

  FreeDLLResource;
  inherited;
end;

//Desc: ֹͣ(�ⲿ����)
procedure TCardSendThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

//Date: 2012-4-18
//Parm: �����ʶ;��ʶ
//Desc: ����nGroup.nIDλͼ�ļ���
function TCardSendThread.GetBMPFile(const nGroup: string; nID: Integer): string;
begin
  Result := Format('%s%s%d.bmp', [FOwner.FTempDir, nGroup, nId]);
end;

//Date: 2014-05-20
//Parm: ����������
//Desc: ����nStr��Ӧ��UTF������Դ
function TCardSendThread.GetUTFResource(const nStr: WideString): WideString;
var nSA: string;
    nRes,nWS: WideString;
    nIdx,nLen: Integer;
begin
  Result := FFileUTF.Values[nStr];
  if Result <> '' then Exit;

  nWS := '';
  nLen := Length(nStr);

  for nIdx:=1 to nLen do
  begin
    nSA := nStr[nIdx];
    if Windows.IsDBCSLeadByte(Byte(nSA[1])) then //˫�ֽ�
    begin
      nWS := nWS + nSA; 
      if nIdx < nLen then Continue;
    end;

    if nWS = '' then
    begin
      Result := Result + nSA;
      //�Ǻ���ֱ��ƴ��
    end else
    begin
      nRes := FFileUTF.Values[nWS];
      //�ж�Ӧ����

      if nRes = '' then
           Result := Result + nWS
      else Result := Result + nRes;
      nWS := '';
    end;
  end;

  if Result <> nStr then Exit;
  //����ɹ�

  Result := '';
  for nIdx:=1 to nLen do
  begin
    nRes := FFileUTF.Values[nStr[nIdx]];
    if nRes = '' then
         Result := Result + nStr[nIdx]
    else Result := Result + nRes;
  end;
end;

procedure TCardSendThread.Execute;
var nStr: string;
    nInit: Int64;
    nIdx,nNum: Integer;
begin
  FFileUTF.Clear;
  nStr := ExtractFilePath(FOwner.FFileName) + cSend_DoublePaintFile;
  
  if FileExists(nStr) then
    FFileUTF.LoadFromFile(nStr);
  //����UTF��Դ�����ļ�

  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Break;

    if FQueueLast = gTruckQueueManager.LineChanged then Continue;
    //����û�б䶯
    nInit := gTruckQueueManager.LineChanged;
    //����䶯ʱ��

    for nIdx:=0 to FOwner.FCards.Count - 1 do
      PCardItem(FOwner.FCards[nIdx]).FPicNum := 0;
    //init picture number

    for nIdx:=0 to FOwner.FCards.Count - 1 do
    begin
      gTruckQueueManager.SyncLock.Enter;
      try
        FNowItem := FOwner.FCards[nIdx];
        if not FNowItem.FEnabled then Continue;
        //ignor

        if FNowItem.FPicNum < 1 then
        begin
          DrawQueue(0);
          //draw normal picture
          nNum := FNowItem.FPicNum;

          if FNowItem.FDoublePaint and (nNum > 0) then
          try
            FNowItem.FPicNum := 0;
            DrawQueue(cSend_DoublePaintBase);
            //draw double picture
          finally
            FNowItem.FPicNum := nNum;
          end;
        end;

        if FNowItem.FFootEnable then
          BuildFootFormatText;
        //build footer text
      finally
        gTruckQueueManager.SyncLock.Leave;
      end;

      if not SendQueueData then
        WriteLog('����[ ' + FNowItem.FName + ' ]�����쳣.');
      //loged
    end;

    FQueueLast := nInit;
    //��¼�䶯ʱ��
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Desc: ������β����ʾ����
procedure TCardSendThread.BuildFootFormatText;
var nStr: string;
begin
  with FNowItem^ do
  begin
    if FFootDefaultOnly then
    begin
      FFootFormat := FFootDefault;
    end else
    begin
      nStr := gTruckQueueManager.GetVoiceTruck('��', False);
      if nStr = '' then
           FFootFormat := FFootDefault
      else FFootFormat := FFootText;
    end;

    FFootFormat := StringReplace(FFootFormat, 'dt', Date2Str(Now),
                   [rfReplaceAll, rfIgnoreCase]);
    //date item

    FFootFormat := StringReplace(FFootFormat, 'tm', Time2Str(Now),
                   [rfReplaceAll, rfIgnoreCase]);
    //time item

    FFootFormat := StringReplace(FFootFormat, 'tk', nStr,
                   [rfReplaceAll, rfIgnoreCase]);
    //truck item
  end;
end;

//Desc: ����ǰ�����û��ƶ���
procedure TCardSendThread.DrawQueue(const nFileBase: Integer);
var nStr: string;
    nWStr: WideString;
    nBmp: TBitmap;
    nCard: PCardItem;
    nLine: PLineItem;
    nTruck: PTruckItem;
    i,nI,nIdx,nCur: Integer;
    nL,nT,nML,nMT: Integer;

    //Desc: �ڵ�ǰ�������м�λ�û���nText�ַ�
    procedure MidDrawText(const nText: string; nSAdjust,nLAdjust: Integer);
    begin
      with nBmp,FNowItem^ do
      begin
        with Canvas do
        begin
          if nFileBase <> cSend_DoublePaintBase then
            nSAdjust := 0;
          //˫��ʱ��������

          Font.Name := FDataFont.FFontName;
          Font.Size := FDataFont.FFontSize + nSAdjust;
          Font.Color := clRed;

          if FDataFont.FFontBold then
               Font.Style := Font.Style + [fsBold]
          else Font.Style := Font.Style - [fsBold];
        end;

        if nFileBase = cSend_DoublePaintBase then
        begin
          nWStr := GetUTFResource(nText);
          nML := Canvas.TextWidth(nWStr);
          nML := nL + Trunc((FColWidth[nI] - nML) / 2) + nLAdjust;

          nMT := Canvas.TextHeight(nWStr);
          nMT := nT + Trunc((FRowHeight - nMT) / 2);

          SetBkMode(Handle, Windows.TRANSPARENT);
          TextOutW(Canvas.Handle, nML, nMT, PWideChar(nWStr), Length(nWStr));

          Inc(nT, FRowHeight);
          Exit;
        end; //˫������

        nML := Canvas.TextWidth(nText);
        nML := nL + Trunc((FColWidth[nI] - nML) / 2);

        nMT := Canvas.TextHeight(nText);
        nMT := nT + Trunc((FRowHeight - nMT) / 2);

        SetBkMode(Handle, Windows.TRANSPARENT);
        Canvas.TextOut(nML, nMT, nText);
        Inc(nT, FRowHeight);
      end;
    end;
begin
  nBmp := nil;
  {$IFDEF DEBUG}
  WriteLog('��ʼ����:' + FNowItem.FName);
  {$ENDIF}

  if not FNowItem.FDataEnable then
    Exit;
  //��ʹ��������

  with FNowItem^, gTruckQueueManager do
  try
    nCur := 0;
    nIdx := 0;

    while nIdx < Lines.Count do
    begin
      nLine := Lines[nIdx];

      if (not nLine.FIsValid) or ((Length(FDataTunnels) > 0) and
         (Pos(nLine.FLineID, FDataTunnels) < 1)) then
      begin
        Inc(nIdx); Continue;
      end;

      if not Assigned(nBmp) then
      begin
        Inc(FPicNum);
        nBmp := TBitmap.Create;

        with nBmp do
        begin
          PixelFormat := pf1bit;
          Width := FDataRect.Right - FDataRect.Left;
          Height := FDataRect.Bottom - FDataRect.Top;

          Canvas.Brush.Color := clBlack;
          Canvas.FillRect(Rect(0, 0, Width, Height));

          Canvas.Pen.Color := clRed;
          Canvas.Pen.Width := 1;
          Canvas.Rectangle(Rect(1, 1, Width-1, Height-1));

          Canvas.Pen.Color := clRed;
          Canvas.Pen.Width := 1;

          Canvas.Lock;
          //����,��ʼ����
          nL := 1;
          
          for i:=Low(FColWidth) to High(FColWidth)-1 do
          begin
            Inc(nL, FColWidth[i]);
            Canvas.MoveTo(nL, 1);
            Canvas.LineTo(nL, Height-1);
          end; //����

          nT := 1;
          for i:=1 to FRowNum-1 do
          begin
            Inc(nT, FRowHeight);
            Canvas.MoveTo(1, nT);
            Canvas.LineTo(Width-1, nT);
          end; //����

          nL := 1;
          nT := 1;
          nI := Low(FColWidth);
          //ÿ����ʼλ��
        end; 
      end;
      
      with nBmp do
      begin
        nLine := Lines[nIdx];
        MidDrawText(nLine.FName, FFontHeadSAdjust, FFontHeadLAdjust);

        if FStatusEnable then
        begin
          if nLine.FIsValid then
               nStr := '����'
          else nStr := 'ͣ��';
          MidDrawText(nStr, FFontHeadSAdjust, FFontHeadLAdjust);
        end;

        if nLine.FTrucks.Count < 1 then
          Inc(nIdx);
        //no truck,next line

        for i:=nCur to nLine.FTrucks.Count-1 do
        begin
          if (FStatusEnable and (i-nCur >= FRowNum-2)) or
             ((not FStatusEnable) and (i-nCur >= FRowNum-1)) then
          begin
            nCur := i;
            Break;
          end;
          //row is enough to fill truck

          nTruck := nLine.FTrucks[i];
          MidDrawText(nTruck.FTruck, 0, FFontDataLAdjust);

          if (i = nLine.FTrucks.Count - 1) or
             ((FDataItemNum > 0) and (FDataItemNum <= i+1)) then
          begin
            Inc(nIdx);
            nCur := 0;
            Break;
          end; //next line
        end;

        Inc(nL, FColWidth[nI]);
        nT := 1;
        Inc(nI);

        if nI >= Length(FColWidth) then
        begin
          nStr := GetBMPFile(FGroup, FPicNum + nFileBase);
          if FileExists(nStr) then
            DeleteFile(nStr);
          Sleep(500); //wait io

          SaveToFile(nStr);
          Canvas.Unlock;
          //�������,����
          
          Sleep(500); //wait io
          FreeAndNil(nBmp);
        end;
      end;
    end;

    if Assigned(nBmp) then
    begin
      nStr := GetBMPFile(FGroup, FPicNum + nFileBase);
      if FileExists(nStr) then
        DeleteFile(nStr);
      Sleep(500); //wait io

      nBmp.SaveToFile(nStr);
      nBmp.Canvas.Unlock;
      Sleep(500); //wait io
    end;

    for nIdx:=0 to FOwner.Cards.Count - 1 do
    begin
      nCard := FOwner.FCards[nIdx];
      if (nCard <> FNowItem) and (nCard.FGroup = FNowItem.FGroup) then
        nCard.FPicNum := FNowItem.FPicNum;
      //�����ѻ���ͼƬ
    end;
  finally
    nBmp.Free;
  end;
end;

//Desc: ���ͻ��ƺõĶ���
function TCardSendThread.SendQueueData: Boolean;
var nStr: string;
    nRes,nIdx,nArea: Integer;
begin
  Result := False;
  //default is failure

  with FNowItem^,FOwner do
  try
    case FType of
     CONTROLLER_BX_5E1, CONTROLLER_BX_5E2, CONTROLLER_BX_5E3:
      begin
        Result := SendDynamicData;
        Exit;
      end;
    end;

    try
      nRes := DeleteScreen(1);
      if (nRes<>RETURN_NOERROR) and (nRes<>RETURN_ERROR_NOFIND_SCREENNO) then
      begin
        WriteLog(Format('DeleteScreen:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;
    except
      //ignor any error
    end;

    nRes := AddScreen(FType, 1, FWidth, FHeight, 1, 2, 0, FDataOE, 0, 0,
            'COM1', 9600, PChar(FIP), FPort, nil);
    if nRes <> RETURN_NOERROR then
    begin
      WriteLog(Format('AddScreen:%s', [GetErrorDesc(nRes)]));
      Exit;
    end;

    nRes := AddScreenProgram(1, 0, 0, 65535, 11, 26, 2011, 11, 26, 1, 1, 1,
            1, 1, 1, 1, 0, 0, 23, 59);
    if nRes <> RETURN_NOERROR then
    begin
      WriteLog(Format('AddScreenProgram:%s', [GetErrorDesc(nRes)]));
      Exit;
    end;

    nArea := 0;
    //first area

    //--------------------------------------------------------------------------
    if FHeadEnable then
    begin
      with FHeadRect do
       nRes := AddScreenProgramBmpTextArea(1, 0, Left, Top,
                                           Right-Left, Bottom-Top);
      //xxxxx

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenProgramBmpTextArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      nStr := FTempDir + cSend_HeadFileRTF;
      //default head file
    
      if (not FDoublePaint) or (not FileExists(nStr)) then
      begin
        nStr := FTempDir + cSend_HeadFile;
        //normal txt file
      
        if not FileExists(nStr) then
        begin
          FFileOpt.Text := FHeadText;
          FFileOpt.SaveToFile(nStr);
          Sleep(1000); //wait I/O
        end;
      end; 

      with FHeadFont do
      begin
        if FFontBold then
             nIdx := 1
        else nIdx := 0;

        nRes := AddScreenProgramAreaBmpTextFile(1, 0, nArea,
                PChar(nStr), 1,
                PChar(FFontName), FFontSize, nIdx, 1, FEffect, FSpeed, FKeep);
        //xxxxx
      end;

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenProgramAreaBmpTextFile:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;
    end;

    //--------------------------------------------------------------------------
    if FDataEnable and (FPicNum > 0) then
    begin
      with FDataRect do
        nRes := AddScreenProgramBmpTextArea(1, 0, Left, Top,
                Right-Left, Bottom-Top);
      //xxxxx

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenProgramBmpTextArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end else Inc(nArea);

      for nIdx:=1 to FPicNum do
      begin
        with FDataFont do
        begin
          nRes := AddScreenProgramAreaBmpTextFile(1, 0, nArea,
                  PChar(GetBMPFile(FGroup, nIdx)), 0,
                  PChar(FFontName), FFontSize, 0, 1, FEffect, FSpeed, FKeep);
        end;

        if nRes <> RETURN_NOERROR then
        begin
          WriteLog(Format('AddScreenProgramAreaBmpTextFile:%s', [GetErrorDesc(nRes)]));
          Exit;
        end;

        if not FDoublePaint then continue;
        //no double paint picture

        nStr := GetBMPFile(FGroup, nIdx + cSend_DoublePaintBase);
        if not FileExists(nStr) then continue;

        with FDataFont do
        begin
          nRes := AddScreenProgramAreaBmpTextFile(1, 0, nArea,
                  PChar(nStr), 0,
                  PChar(FFontName), FFontSize, 0, 1, FEffect, FSpeed, FKeep);
        end;

        if nRes <> RETURN_NOERROR then
        begin
          WriteLog(Format('AddScreenProgramAreaBmpTextFile:%s', [GetErrorDesc(nRes)]));
          Exit;
        end;
      end;
    end;

    //--------------------------------------------------------------------------
    if FFootEnable then
    begin
      with FFootRect do
        nRes := AddScreenProgramBmpTextArea(1, 0, Left, Top,
                Right-Left, Bottom-Top);
      //xxxxx
      
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenProgramBmpTextArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end else Inc(nArea);

      FFileOpt.Text := FFootFormat;
      FFileOpt.SaveToFile(FTempDir + cSend_FootFile);
      Sleep(1000); //wait I/O

      with FFootFont do
      begin
        if FFontBold then
             nIdx := 1
        else nIdx := 0;

        nRes := AddScreenProgramAreaBmpTextFile(1, 0, nArea,
                PChar(FTempDir + cSend_FootFile), 1,
                PChar(FFontName), FFontSize, nIdx, 1, FEffect, FSpeed, FKeep);
      end;

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenProgramAreaBmpTextFile:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;
    end;

    //--------------------------------------------------------------------------
    nRes := SendScreenInfo(1, SEND_MODE_NETWORK, SEND_CMD_SENDALLPROGRAM, 0);
    Result := nRes = RETURN_NOERROR;

    if not Result then
      WriteLog(Format('SendScreenInfo:%s', [GetErrorDesc(nRes)]));
    //xxxxx

    {$IFDEF DEBUG}
    WriteLog('��Ļ:' + FNowItem.FName + '���ݷ������.');
    {$ENDIF}                                          
  except
    On E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Desc: ��̬������ƿ���������
function TCardSendThread.SendDynamicData: Boolean;
var nStr: string;
    nRes,nIdx,nArea,nTag: Integer;
begin
  Result := False;
  //default is failure

  with FNowItem^,FOwner do
  try
    try
      nRes := DynDeleteScreen(1);
      if (nRes<>RETURN_NOERROR) and (nRes<>RETURN_ERROR_NOFIND_SCREENNO) then
      begin
        WriteLog(Format('DeleteScreen:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;
    except
      //ignor any error
    end;

    nRes := DynAddScreen(FType, 1, SEND_MODE_NETWORK, FWidth, FHeight, 1, 2, 
            'COM1', 9600, PChar(FIP), FPort, nil);
    if nRes <> RETURN_NOERROR then
    begin
      WriteLog(Format('AddScreen:%s', [GetErrorDesc(nRes)]));
      Exit;
    end;

    nArea := 0;
    //first area

    //--------------------------------------------------------------------------
    if FHeadEnable then
    with FHeadRect,FHeadFont do
    begin
      nRes := AddScreenDynamicArea(1, nArea, RUN_MODE_CYCLE_SHOW, 3600*24, 0, nil,
              0, Left, Top, Right-Left, Bottom-Top, 255, 0, 255, 1, 0, 1);
      //xxxxx
      
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenDynamicArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      nStr := FTempDir + cSend_HeadFileRTF;
      //default head file

      if (not FDoublePaint) or (not FileExists(nStr)) then
      begin
        nStr := FTempDir + cSend_HeadFile;
        //normal txt file

        if not FileExists(nStr) then
        begin
          FFileOpt.Text := FHeadText;
          FFileOpt.SaveToFile(nStr);
          Sleep(1000); //wait I/O
        end;
      end;

      if FFontBold then
           nTag := 1
      else nTag := 0;

      nRes := AddScreenDynamicAreaFile(1, nArea, PChar(nStr),
              1, PChar(FFontName), FFontSize, nTag, clRed, FEffect, FSpeed, FKeep);
      //xxxxx

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenDynamicAreaFile:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      nRes := SendDynamicAreaInfoCommand(1, nArea);
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('SendDynamicAreaInfoCommand:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      Inc(nArea);
      //next area
    end;

    //--------------------------------------------------------------------------
    if FDataEnable and (FPicNum > 0) then
    with FDataRect,FDataFont do
    begin
      nRes := AddScreenDynamicArea(1, nArea, RUN_MODE_CYCLE_SHOW, 3600*24, 0, nil,
              0, Left, Top, Right-Left, Bottom-Top, 255, 0, 255, 1, 0, 1);
      //xxxxx

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenDynamicArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      if FFontBold then
           nTag := 1
      else nTag := 0;

      for nIdx:=1 to FPicNum do
      begin
        nRes := AddScreenDynamicAreaFile(1, nArea, PChar(GetBMPFile(FGroup, nIdx)),
                0, PChar(FFontName), FFontSize, nTag, clRed, FEffect, FSpeed, FKeep);
        //xxxxx

        if nRes <> RETURN_NOERROR then
        begin
          WriteLog(Format('AddScreenDynamicAreaFile:%s', [GetErrorDesc(nRes)]));
          Exit;
        end;

        if not FDoublePaint then continue;
        //no double paint picture

        nStr := GetBMPFile(FGroup, nIdx + cSend_DoublePaintBase);
        if not FileExists(nStr) then continue;

        nRes := AddScreenDynamicAreaFile(1, nArea, PChar(nStr),
                0, PChar(FFontName), FFontSize, nTag, clRed, FEffect, FSpeed, FKeep);
        //xxxxx

        if nRes <> RETURN_NOERROR then
        begin
          WriteLog(Format('AddScreenDynamicAreaFile:%s', [GetErrorDesc(nRes)]));
          Exit;
        end;
      end;

      nRes := SendDynamicAreaInfoCommand(1, nArea);
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('SendDynamicAreaInfoCommand:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      Inc(nArea);
      //next area
    end;

    //--------------------------------------------------------------------------
    if FFootEnable then
    with FFootRect, FFootFont do
    begin
      nRes := AddScreenDynamicArea(1, nArea, RUN_MODE_CYCLE_SHOW, 3600*24, 0, nil,
              0, Left, Top, Right-Left, Bottom-Top, 255, 0, 255, 1, 0, 1);
      //xxxxx
      
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenDynamicArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      FFileOpt.Text := FFootFormat;
      FFileOpt.SaveToFile(FTempDir + cSend_FootFile);
      Sleep(1000); //wait I/O

      if FFontBold then
           nTag := 1
      else nTag := 0;

      nRes := AddScreenDynamicAreaFile(1, nArea, PChar(FTempDir+cSend_FootFile),
              1, PChar(FFontName), FFontSize, nTag, clRed, FEffect, FSpeed, FKeep);
      //xxxxx

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenDynamicAreaFile:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      nRes := SendDynamicAreaInfoCommand(1, nArea);
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('SendDynamicAreaInfoCommand:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;
    end;

    {$IFDEF DEBUG}
    WriteLog('��Ļ:' + FNowItem.FName + '���ݷ������.');
    {$ENDIF}
    Result := True;                                          
  except
    On E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TCardManager.Create;
begin
  FFileName := '';
  FCards := TList.Create;
end;

destructor TCardManager.Destroy;
begin
  StopSender;
  ClearList(True);
  inherited;
end;

procedure TCardManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FCards.Count - 1 downto 0 do
  begin
    Dispose(PCardItem(FCards[nIdx]));
    FCards.Delete(nIdx);
  end;

  if nFree then FreeAndNil(FCards);
end;

procedure TCardManager.StartSender;
begin
  if not Assigned(FSender) then
    FSender := TCardSendThread.Create(Self);
  FSender.FWaiter.Wakeup;
end;

procedure TCardManager.StopSender;
begin
  if Assigned(FSender) then
    FSender.StopMe;
  FSender := nil;
end;

//------------------------------------------------------------------------------
function TCardManager.GetErrorDesc(const nErr: Integer): string;
begin
  Result := 'δ����Ĵ���.';

  case nErr of
   RETURN_ERROR_NO_USB_DISK:
    Result := '�Ҳ���usb�豸·��';
   RETURN_ERROR_NOSUPPORT_USB:
    Result := '��֧��USBģʽ';
   RETURN_ERROR_AERETYPE:
    Result := '�������ʹ���,����ӡ�ɾ��ͼ�������ļ�ʱ�������ͳ����ش����ʹ���.';
   RETURN_ERROR_RA_SCREENNO:
    Result := '�Ѿ��и���ʾ����Ϣ,��Ҫ�����趨����DeleteScreenɾ������ʾ�������.';
   RETURN_ERROR_NOFIND_AREAFILE:
    Result := 'û���ҵ���Ч�������ļ�';
   RETURN_ERROR_NOFIND_AREA:
    Result := 'û���ҵ���Ч����ʾ����,����ʹ��AddScreenProgram���������Ϣ.';
   RETURN_ERROR_NOFIND_PROGRAM:
    Result := 'û���ҵ���Ч����ʾ����Ŀ.����ʹ��AddScreenProgram�������ָ����Ŀ.';
   RETURN_ERROR_NOFIND_SCREENNO:
    Result := 'ϵͳ��û�в��ҵ�����ʾ��,����ʹ��AddScreen���������ʾ��.';
   RETURN_ERROR_NOW_SENDING:
    Result := 'ϵͳ�����������ʾ��ͨѶ,���Ժ���ͨѶ.';
   RETURN_ERROR_OTHER:
    Result := '��������.';
   RETURN_NOERROR:
    Result := '�����ɹ�';

   //dynamic area card
   RETURN_ERROR_NOFIND_DYNAMIC_AREA:
    Result := 'û���ҵ���Ч�Ķ�̬����';
   RETURN_ERROR_NOFIND_DYNAMIC_AREA_FILE_ORD:
    Result := '��ָ���Ķ�̬����û���ҵ�ָ�����ļ����';
   RETURN_ERROR_NOFIND_DYNAMIC_AREA_PAGE_ORD:
    Result := '��ָ���Ķ�̬����û���ҵ�ָ����ҳ���';
   RETURN_ERROR_NOSUPPORT_FILETYPE: Result := '��֧�ָ��ļ�����';
  end;
end;

//Desc: ��ȡnNode����������
procedure ReadCardFont(var nFont: TCardFont; const nNode: TXmlNode);
begin
  with nFont do
  begin
    FFontName := nNode.NodeByName('fontname').ValueAsString;
    FFontSize := nNode.NodeByName('fontsize').ValueAsInteger;
    FFontBold := nNode.NodeByName('fontbold').ValueAsInteger > 0;

    FSpeed := nNode.NodeByName('fontspeed').ValueAsInteger;
    FKeep := nNode.NodeByName('fontkeep').ValueAsInteger;
    FEffect := nNode.NodeByName('fonteffect').ValueAsInteger;
  end;
end;

//Desc: ��ȡnFile
procedure TCardManager.SetFileName(const nFile: string);
var nStr: string;
    i,nIdx: Integer;
    nItem: TCardItem;
    nCard: PCardItem;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
begin
  FFileName := nFile;
  nXML := TNativeXml.Create;
  try
    ClearList(False);
    nXML.LoadFromFile(nFile);
    
    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    with nItem do
    begin
      nNode := nXML.Root.Nodes[nIdx];
      FID := nNode.AttributeByName['ID'];
      FName := nNode.AttributeByName['Name'];
      FGroup := nNode.AttributeByName['Group'];

      nNode := nXML.Root.Nodes[nIdx].FindNode('param');
      if not Assigned(nNode) then Continue;

      FType := CONTROLLER_TYPE_4M;
      nStr := nNode.NodeByName('type').ValueAsString;

      if CompareText('4m1', nStr) = 0 then
           FType := CONTROLLER_TYPE_4M1 else
      if CompareText('5m1', nStr) = 0 then
           FType := CONTROLLER_TYPE_5M1 else
      if CompareText('5m2', nStr) = 0 then
           FType := CONTROLLER_TYPE_5M2 else
      if CompareText('5m3', nStr) = 0 then
           FType := CONTROLLER_TYPE_5M3 else
      if CompareText('5m4', nStr) = 0 then
           FType := CONTROLLER_TYPE_5M4 else
      if CompareText('5e1', nStr) = 0 then
           FType := CONTROLLER_BX_5E1 else
      if CompareText('5e2', nStr) = 0 then
           FType := CONTROLLER_BX_5E2 else
      if CompareText('5e3', nStr) = 0 then
           FType := CONTROLLER_BX_5E3;
      //for card type

      FIP := nNode.NodeByName('ip').ValueAsString;
      FPort := nNode.NodeByName('port').ValueAsInteger;
      FWidth := nNode.NodeByName('width').ValueAsInteger;
      FHeight := nNode.NodeByName('height').ValueAsInteger;
      FDataOE := nNode.NodeByName('data_oe').ValueAsInteger;

      nTmp := nNode.FindNode('data_tunnels');
      if Assigned(nTmp) then
           FDataTunnels := nTmp.ValueAsString
      else FDataTunnels := '';

      nTmp := nNode.FindNode('double_paint');
      if Assigned(nTmp) then
           FDoublePaint := nTmp.ValueAsString = '1'
      else FDoublePaint := False;

      nTmp := nNode.FindNode('enable');
      if Assigned(nTmp) then
           FEnabled := nTmp.ValueAsString <> 'N'
      else FEnabled := True;

      //------------------------------------------------------------------------
      nNode := nXML.Root.Nodes[nIdx].FindNode('head_area');
      if not Assigned(nNode) then Continue;
      FHeadEnable := nNode.AttributeByName['use_head'] <> 'N';

      with FHeadRect,nNode.NodeByName('rect') do
      begin
        Left := StrToInt(AttributeByName['L']);
        Top := StrToInt(AttributeByName['T']);
        Right := Left + StrToInt(AttributeByName['W']);
        Bottom := Top + StrToInt(AttributeByName['H']);
      end;

      FHeadText := nNode.NodeByName('text').ValueAsString;
      ReadCardFont(FHeadFont, nNode);

      //------------------------------------------------------------------------
      nNode := nXML.Root.Nodes[nIdx].FindNode('data_area');
      if not Assigned(nNode) then Continue;
      FDataEnable := nNode.AttributeByName['use_data'] <> 'N';
      FStatusEnable := nNode.AttributeByName['use_status'] <> 'N';

      FRowNum := nNode.NodeByName('rownum').ValueAsInteger;
      FRowHeight := nNode.NodeByName('rowheight').ValueAsInteger;

      with nNode.FindNode('colwidth') do
      begin
        SetLength(FColWidth, NodeCount);
        for i:=0 to NodeCount - 1 do
          FColWidth[i] := Nodes[i].ValueAsInteger;
        //width value
      end;

      with FDataRect,nNode.NodeByName('rect') do
      begin
        Left := StrToInt(AttributeByName['L']);
        Top := StrToInt(AttributeByName['T']);
        Right := Left + StrToInt(AttributeByName['W']);
        Bottom := Top + StrToInt(AttributeByName['H']);
      end;

      ReadCardFont(FDataFont, nNode);
      //font node

      nTmp := nNode.FindNode('itemnum');
      if Assigned(nTmp) then
           FDataItemNum := nTmp.ValueAsInteger
      else FDataItemNum := 0;

      nTmp := nNode.FindNode('font_head_size_adjust');
      if Assigned(nTmp) then
           FFontHeadSAdjust := nTmp.ValueAsInteger
      else FFontHeadSAdjust := 0;

      nTmp := nNode.FindNode('font_head_left_adjust');
      if Assigned(nTmp) then
           FFontHeadLAdjust := nTmp.ValueAsInteger
      else FFontHeadLAdjust := 0;

      nTmp := nNode.FindNode('font_data_left_adjust');
      if Assigned(nTmp) then
           FFontDataLAdjust := nTmp.ValueAsInteger
      else FFontDataLAdjust := 0;

      //------------------------------------------------------------------------
      nNode := nXML.Root.Nodes[nIdx].FindNode('foot_area');
      FFootEnable := Assigned(nNode);

      if FFootEnable then
      begin
        FFootEnable := nNode.AttributeByName['use_foot'] <> 'N';
        //xxxxx

        with FFootRect,nNode.NodeByName('rect') do
        begin
          Left := StrToInt(AttributeByName['L']);
          Top := StrToInt(AttributeByName['T']);
          Right := Left + StrToInt(AttributeByName['W']);
          Bottom := Top + StrToInt(AttributeByName['H']);
        end;

        nTmp := nNode.NodeByName('default');
        FFootDefault := nTmp.ValueAsString;
        FFootDefaultOnly := nTmp.AttributeByName['useonly'] = 'Y'; 

        FFootText := nNode.NodeByName('text').ValueAsString;
        ReadCardFont(FFootFont, nNode);
      end;

      New(nCard);
      FCards.Add(nCard);
      nCard^ := nItem;
    end;
  finally
    nXML.Free;
  end;
end;

initialization
  gCardManager := TCardManager.Create;
finalization
  FreeAndNil(gCardManager);
end.


