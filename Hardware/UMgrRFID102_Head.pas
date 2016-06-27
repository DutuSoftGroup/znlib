{*******************************************************************************
  ����: dmzn@163.com 2015-12-05
  ����: �������пƻ���Ƽ����޹�˾ RFID102��ȡ������ͷ�ļ�
*******************************************************************************}
unit UMgrRFID102_Head;

interface

const
  cHY_DLLName = 'RFID102.dll';

type
  TReadCmdType = (
    tCmd_Err_Cmd                  = $00,  //δʶ������   
    tCmd_G2_Seek                  = $01,
    tCmd_G2_ReadData              = $02,
    tCmd_G2_WriteData             = $03,
    tCmd_G2_WriteEPCID            = $04,
    tCmd_G2_Destory               = $05,
    tCmd_G2_SetMemRWProtect       = $06,
    tCmd_G2_EreaseArea            = $07,
    tCmd_G2_InstalReadProtect     = $08,
    tCmd_G2_SetReadProtect        = $09,
    tCmd_G2_UnlockRProtect        = $0A,
    tCmd_G2_ChargeRProtect        = $0B,
    tCmd_G2_SetEASWarn            = $0C,
    tCmd_G2_ChargeEASWarn         = $0D,
    tCmd_G2_UseAreaLock           = $0E,
    tCmd_G2_SeekSingle            = $0F,
    tCmd_G2_WriteArea             = $10,

    //����EPC C1G2���� ��Χ0x01-0x10
    //1	0x01	ѯ���ǩ
    //2	0x02	������
    //3	0x03	д����
    //4	0x04	дEPC��
    //5	0x05	���ٱ�ǩ
    //6	0x06	�趨�洢����д����״̬
    //7	0x07	�����
    //8	0x08	����EPC���趨����������
    //9	0x09	����ҪEPC�Ŷ������趨
    //10	0x0a	����������
    //11	0x0b	���Ա�ǩ�Ƿ����ö�����
    //12	0x0c	EAS��������
    //13	0x0d	EAS����̽��
    //14	0x0e	user������
    //15	0x0f	ѯ�鵥��ǩ
    //16	0x10	��д

    
    tCmd_6B_SeekSingle             = $50,
    tCmd_6B_SeekMulti              = $51,
    tCmd_6B_ReadData               = $52,
    tCmd_6B_WriteData              = $53,
    tCmd_6B_ChargeLock             = $54,
    tCmd_6B_Lock                   = $55,
    //����1800-68���� ��Χ0x50-0x55
    //1	0x50	ѯ������(����)���������ÿ��ֻ��ѯ��һ�ŵ��ӱ�ǩ����������ѯ�顣
    //2	0x51	����ѯ������(����)�����������ݸ�������������ѯ���ǩ������
    //        ���������ĵ��ӱ�ǩ��UID������ͬʱѯ����ŵ��ӱ�ǩ��
    //3	0x52	�����������������ȡ���ӱ�ǩ�����ݣ�һ�������Զ�32���ֽڡ�
    //4	0x53	д�������д�����ݵ����ӱ�ǩ�У�һ��������д32���ֽڡ�
    //5	0x54	�������������ĳ���洢��Ԫ�Ƿ��Ѿ���������
    //6	0x55	�����������ĳ����δ�������ĵ��ӱ�ǩ��
    
    
    tCmd_Reader_ReadInfo              = $21,
    tCmd_Reader_SetWorkrate           = $22,
    tCmd_Reader_SetAddr               = $24,
    tCmd_Reader_SetSeekTimeOut        = $25,
    tCmd_Reader_SetBoundrate          = $28,
    tCmd_Reader_SetOutweight          = $2F,
    tCmd_Reader_SetRoundAndRight      = $33,
    tCmd_Reader_SetWGParam            = $34,
    tCmd_Reader_SetWorkmode           = $35,
    tCmd_Reader_ReadWorkmode          = $36,
    tCmd_Reader_SetEASweight          = $37,
    tCmd_Reader_SetSyris485TimeOut    = $38,
    tCmd_Reader_SetReplyTimeOut       = $3B,
    tCmd_Reader_SetReLay              = $3C
    //��д���Զ�������

    //1	0x21	��ȡ��д����Ϣ
    //2	0x22	���ö�д������Ƶ��
    //3	0x24	���ö�д����ַ
    //4	0x25	���ö�д��ѯ��ʱ��
    //5	0x28	���ö�д���Ĳ�����
    //6	0x2F	������д���������
    //7	0x33	�����������
    //8	0x34	Τ��������������
    //9	0x35	����ģʽ��������
    //10	0x36	��ȡ����ģʽ��������
    //11	0x37	EAS���Ծ�����������
    //12	0x38	����Syris485��Ӧƫִʱ��
    //13	0x3b	���ô�����Чʱ��
    //14  0x3c  ���ü̵�������״̬
  );

  PRFIDReaderCmd = ^TRFIDReaderCmd;
  TRFIDReaderCmd = record
    FLen :Char;
    //ָ����������ݿ�ĳ��ȣ���������Len����
    //�����ݿ�ĳ��ȵ���4��Data[]�ĳ��ȡ�Len��������ֵΪ96����СֵΪ4

    FAddr:Char;
    //��д����ַ����ַ��Χ��0x00~0xFE��0xFFΪ�㲥��ַ��
    //��д��ֻ��Ӧ�������ַ��ͬ����ַΪ0xFF�������д������ʱ��ַΪ0x00

    FCmd :TReadCmdType;
    //������롣

    FStatus: Char;
    //����ִ�н��״ֵ̬��

    FData:string;
    //��������ʵ�������У����Բ����ڡ�

    FLSB, FMSB:Char;
    //CRC16���ֽں͸��ֽڡ�CRC16�Ǵ�Len��Data[]��CRC16ֵ
  end;

//------------------------------------------------------------------------------
  RTempRecord=Record
  end;

  function OpenNetPort(Port : LongInt; IPaddr:string; var ComAdr : byte;
    var frmcomportindex:longint): LongInt; stdcall;external cHY_DLLName ;
  function CloseNetPort( frmComPortindex : longint ): LongInt;
    stdcall; external cHY_DLLName;
  //xxxxxx

  function OpenComPort(Port : LongInt;var ComAdr : byte;Baud:byte;
    var frmcomportindex: longint): LongInt; stdcall; external cHY_DLLName ;
  function CloseComPort(  ): LongInt; stdcall;external cHY_DLLName ;
  function AutoOpenComPort(var Port : longint; var ComAdr : byte;Baud:byte;
    var frmComPortindex :longint ) : LongInt; stdcall; external cHY_DLLName ;
  function CloseSpecComPort( frmComPortindex : longint ): LongInt;
    stdcall;external cHY_DLLName;
  //xxxxxx
  
  function GetReaderInformation(var ComAdr: byte; VersionInfo: pchar;
    var ReaderType: byte; TrType: pchar;
    var dmaxfre ,dminfre,powerdBm:Byte;
    var ScanTime: byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function SetWGParameter(var ComAdr:Byte;
    Wg_mode:Byte;
    Wg_Data_Inteval:Byte;
    Wg_Pulse_Width:Byte;
    Wg_Pulse_Inteval:Byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function ReadActiveModeData(ScanModeData: pchar;
    var ValidDatalength: longint;
    frmComPortindex: longint): LongInt; Stdcall;external cHY_DLLName;
  function SetWorkMode(var ComAdr:Byte;
    Parameter:PChar;
    frmComPortindex : longint): LongInt; stdcall;external cHY_DLLName;
  function GetWorkModeParameter(var ComAdr:Byte;
    Parameter:PChar;
    frmComPortindex : longint): LongInt; stdcall;external cHY_DLLName;
  function BuzzerAndLEDControl(var ComAdr:Byte;
    AvtiveTime:Byte;
    SilentTime:Byte;
    Times:Byte;
    frmComPortindex: LongInt):LongInt; stdcall;external cHY_DLLName;
  //xxxxxx

  function WriteComAdr(var ComAdr : byte; var ComAdrData : Byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function SetPowerDbm(var ComAdr : byte;powerDbm : Byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function Writedfre(var ComAdr : byte;var dmaxfre : Byte; var dminfre : Byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function Writebaud(var ComAdr : byte;var baud : Byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function WriteScanTime(var ComAdr:byte;var ScanTime : Byte;
    frmComPortindex : longint): LongInt; stdcall;external cHY_DLLName;
  function SetAccuracy(var ComAdr:Byte;Accuracy:Byte;
    frmComPortindex:longint):LongInt; stdcall;external cHY_DLLName;
  function SetOffsetTime(var ComAdr:Byte;OffsetTime:Byte;
    frmComPortindex:longint):LongInt; stdcall;external cHY_DLLName;
  function SetFhssMode(var ComAdr:Byte;FhssMode :Byte;
    frmComPortindex: longint):LongInt; stdcall;external cHY_DLLName;
  function GetFhssMode(var ComAdr:Byte;var FhssMode :Byte;
    frmComPortindex: longint):LongInt; stdcall;external cHY_DLLName;
  function SetTriggerTime(var ComAdr:Byte;var TriggerTime :Byte;
    frmComPortindex: longint):LongInt; stdcall;external cHY_DLLName;
  function SetRelay(var ComAdr:Byte;RelayStatus :Byte;
    frmComPortindex: longint):LongInt; stdcall;external cHY_DLLName;
  //xxxxxx
  
  //EPC  G2
  function Inventory_G2(var ComAdr : byte;
    AdrTID,LenTID,TIDFlag:Byte;
    EPClenandEPC : pchar;
    var Totallen:longint;
    var CardNum : longint;
    frmComPortindex:LongInt): LongInt; stdcall; external cHY_DLLName;
  //xxxxxx
 
  function ReadCard_G2(var ComAdr:Byte;EPC:PChar;Mem,WordPtr,Num:Byte;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;
    Data:PChar;EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function WriteCard_G2(var ComAdr:Byte;EPC:PChar;Mem,WordPtr,Writedatalen:Byte;
    Writedata:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;
    WrittenDataNum:LongInt;EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function EraseCard_G2(var ComAdr:Byte;EPC:PChar;Mem,WordPtr,Num:Byte;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;EPClength:byte;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function SetCardProtect_G2(var ComAdr:Byte;EPC:PChar;select,setprotect:Byte;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;
    EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function DestroyCard_G2(var ComAdr:Byte;EPC:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;EPClength:byte;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function WriteEPC_G2(var ComAdr:Byte;
    Password:PChar;WriteEPC:PChar;WriteEPClen:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function SetReadProtect_G2(var ComAdr:Byte;EPC:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;EPClength:byte;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function SetMultiReadProtect_G2(var ComAdr:Byte;
    Password:PChar;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function RemoveReadProtect_G2(var ComAdr:Byte;
    Password:PChar;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function CheckReadProtected_G2(var ComAdr:Byte; var readpro:byte;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function SetEASAlarm_G2(var ComAdr:Byte;EPC:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;EAS:byte;
    EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function CheckEASAlarm_G2(var ComAdr:Byte;
    var errorcode:longint;frmComPortindex : longint ): LongInt;
    stdcall;external cHY_DLLName;
  function LockUserBlock_G2(var ComAdr:Byte;EPC:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;BlockNum:byte;
    EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  //xxxxxx
  
  function WriteBlock_G2(var ComAdr:Byte;EPC:PChar;Mem,WordPtr,Writedatalen:Byte;
    Writedata:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;
    WrittenDataNum:LongInt;EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  //xxxxxx
  //18000_6B

  function Inventory_6B(var ComAdr : byte; ID_6B : pchar;
    frmComPortindex:LongInt): LongInt; stdcall; external cHY_DLLName;
  function inventory2_6B(var ComAdr : byte;Condition,StartAddress,mask:byte;
    ConditionContent:PChar; ID_6B : pchar;var Cardnum:longint;
    frmComPortindex:LongInt): LongInt; stdcall; external cHY_DLLName;
  function ReadCard_6B(var ComAdr;ID_6B:PChar;StartAddress,Num:Byte;
    Data:PChar;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function WriteCard_6B(var ComAdr;ID_6B:PChar;StartAddress:Byte;
    Writedata:PChar;Writedatalen:Byte;var writtenbyte:longint;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function LockByte_6B(var ComAdr;ID_6B:PChar;Address:Byte;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function CheckLock_6B(var ComAdr;ID_6B:PChar;Address:Byte;
    var ReLockState:Byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  //xxxxxx
  
implementation


end.












 
