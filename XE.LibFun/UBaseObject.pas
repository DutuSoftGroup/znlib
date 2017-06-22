{*******************************************************************************
  ����: dmzn@163.com 2017-03-21
  ����: ע�����ϵͳ���������״̬

  ��ע:
  *.TObjectBase.DataS,DataP,Health����,����ʱ��Ҫ��SyncEnter����,������̲߳���
    ʱд������.
*******************************************************************************}
unit UBaseObject;

interface

uses   
  System.Classes, System.SysUtils, System.SyncObjs, ULibFun
  {$IF defined(MSWINDOWS)},Winapi.Windows{$ENDIF};

type
  TObjectHealth = (hlHigh, hlNormal, hlLow, hlBad);
  //����״̬

  TObjectStatusHelper = class
  public  
    class procedure AddTitle(const nList: TStrings;
      const nClass: string);  static;
    //��ӱ���   
    class function FixData(const nTitle: string;
      const nData: string): string; overload; static;
    class function FixData(const nTitle: string;
      const nData: Double): string; overload; static; 
    //��ʽ������    
  end;

  TObjectBase = class(TObject)  
  public
    type
      TDataDim = 0..2;
      TDataS = array [TDataDim] of string;
      TDataP = array [TDataDim] of Pointer;      
    var
      DataS: TDataS;
      DataP: TDataP;
      //״̬���� 
  strict private
    FSyncLock: TCriticalSection;
    //ͬ������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�     
    procedure SyncEnter;
    procedure SyncLeave;
    //ͬ������      
    procedure GetStatus(const nList: TStrings;
      const nFriendly: Boolean = True); virtual;
    function GetHealth(const nList: TStrings = nil): TObjectHealth; virtual;
    //����״̬
  end;

  TObjectBaseClass = class of TObjectBase;
  //������

  TManagerBase = class
  strict protected 
    type
      TItem = record
        FClass: TClass;
        FManager: TManagerBase;
      end;
    class var
      FManagers: array of TItem;
      //�������б�   
  strict private
    FSyncLock: TCriticalSection;
    //ͬ������
  protected
    class function GetMe(const nClass: TClass;
      const nAutoNew: Boolean = True): Integer; static;
    class procedure RegistMe(const nReg: Boolean); virtual; abstract;
    //ע�������    
  public 
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�    
    procedure SyncEnter;
    procedure SyncLeave;
    //ͬ������          
    procedure GetStatus(const nList: TStrings;
      const nFriendly: Boolean = True); virtual;
    function GetHealth(const nList: TStrings = nil): TObjectHealth; virtual;
    //����״̬ 
    class function GetManager(const nClass: TClass): TManagerBase; static;
    //����������    
  end;

  TManagerClass = class of TManagerBase;
  //��������
  
  TCommonObjectManager = class(TManagerBase)
  private  
    FObjects: TList;
    //�����б�
  public       
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    class procedure RegistMe(const nReg: Boolean); override;
    //ע�������
    procedure AddObject(const nObj: TObject);
    procedure DelObject(const nObj: TObject);
    //���ɾ��
    procedure GetStatus(const nList: TStrings;
      const nFriendly: Boolean = True); override;
    //��ȡ״̬
  end;

  TSerialIDManager = class(TManagerBase)
  private
    FBase: Int64;
    //�������
    FTimeStamp: string;
    //ʱ���
  public
    constructor Create;
    //�����ͷ�
    class procedure RegistMe(const nReg: Boolean); override;
    //ע�������    
    function GetID: Int64;
    function GetSID: string;
    //��ȡ��ʶ
    procedure GetStatus(const nList: TStrings;
      const nFriendly: Boolean = True); override;
    //��ȡ״̬
  end;

implementation

uses
  UManagerGroup;

//Date: 2017-04-14
//Parm: �б�;����
//Desc: ���һ����ı��⵽�б�
class procedure TObjectStatusHelper.AddTitle(const nList: TStrings;
  const nClass: string);
var nLen: Integer;
begin
  if nList.Count > 0 then     
      nList.Add('');
  //xxxxx
  
  nLen := Trunc((85 - Length(nClass)) / 2);
  nList.Add(StringOfChar('+', nLen) + ' ' + nClass + ' ' +
            StringOfChar('+', nLen));
  //title
end;

//Date: 2017-04-10
//Parm: ǰ׺����;����
//Desc: ��ʽ������,��ʽΪ: nTitle(����) nData
class function TObjectStatusHelper.FixData(const nTitle, nData: string): string;
begin
  Result := ULibFun.TStringHelper.FixWidth(nTitle, 32) + nData;
end;

class function TObjectStatusHelper.FixData(const nTitle: string;
  const nData: Double): string;
begin
  Result := FixData(nTitle, nData.ToString);
end;

//------------------------------------------------------------------------------
constructor TObjectBase.Create;
begin
  FSyncLock := nil;  
  if Assigned(gMG.FObjectManager) then
    gMG.FObjectManager.AddObject(Self);
  //xxxxx
end;

destructor TObjectBase.Destroy;
begin
  if Assigned(gMG.FObjectManager) then
    gMG.FObjectManager.DelObject(Self);
  //xxxxx
  
  FSyncLock.Free;
  inherited;
end;

procedure TObjectBase.SyncEnter;
begin
  if not Assigned(FSyncLock) then   
    FSyncLock := TCriticalSection.Create;
  FSyncLock.Enter;
end;

procedure TObjectBase.SyncLeave;
begin
  if Assigned(FSyncLock) then
    FSyncLock.Leave;
  //xxxxx
end;

//Desc: ���󽡿���
function TObjectBase.GetHealth(const nList: TStrings): TObjectHealth;
begin
  Result := hlNormal;
end;

//Desc: ����״̬
procedure TObjectBase.GetStatus(const nList: TStrings; const nFriendly: Boolean);
begin
  TObjectStatusHelper.AddTitle(nList, ClassName);
end;

//------------------------------------------------------------------------------
constructor TManagerBase.Create;
begin
  inherited;
  FSyncLock := nil;
end;

destructor TManagerBase.Destroy;
begin
  FSyncLock.Free;
  inherited;
end;

procedure TManagerBase.SyncEnter;
begin
  if not Assigned(FSyncLock) then   
    FSyncLock := TCriticalSection.Create;
  FSyncLock.Enter;
end;

procedure TManagerBase.SyncLeave;
begin
  if Assigned(FSyncLock) then
    FSyncLock.Leave;
  //xxxxx
end;

//Date: 2017-03-23
//Parm: ���;�Զ����
//Desc: ����nClass�ڹ������б��е�λ��
class function TManagerBase.GetMe(const nClass: TClass;
  const nAutoNew: Boolean): Integer;
var nIdx: Integer;
begin
  for nIdx := Low(FManagers) to High(FManagers) do
  if FManagers[nIdx].FClass = nClass then
  begin
    Result := nIdx;
    Exit;
  end;
    
  Result := -1;
  if not nAutoNew then Exit;

  Result := Length(FManagers);
  nIdx := Result; 
  SetLength(FManagers, nIdx + 1);

  with FManagers[nIdx] do
  begin
    FClass := nClass;
    FManager := nil;
  end;    
end;

//Desc: ����״̬
procedure TManagerBase.GetStatus(const nList: TStrings; 
  const nFriendly: Boolean);
begin
  TObjectStatusHelper.AddTitle(nList, ClassName);
end;

//Desc: ���󽡿���
function TManagerBase.GetHealth(const nList: TStrings): TObjectHealth;
begin
  Result := hlNormal;
end;

//Date: 2017-04-15
//Parm: ����
//Desc: ��������ΪnClass�Ĺ�����
class function TManagerBase.GetManager(const nClass: TClass): TManagerBase;
var nIdx: Integer;
begin
  nIdx := GetMe(nClass, False);
  if nIdx < 0 then
       Result := nil
  else Result := FManagers[nIdx].FManager; 
end;

//------------------------------------------------------------------------------
constructor TCommonObjectManager.Create;
begin
  inherited;
  FObjects := TList.Create;
end;

destructor TCommonObjectManager.Destroy;
begin
  FObjects.Free;
  inherited;
end;

//Date: 2017-03-23
//Parm: �Ƿ�ע��
//Desc: ��ϵͳע�����������
class procedure TCommonObjectManager.RegistMe(const nReg: Boolean);
var nIdx: Integer;
begin
  nIdx := GetMe(TCommonObjectManager);
  if nReg then
  begin     
    if not Assigned(FManagers[nIdx].FManager) then
      FManagers[nIdx].FManager := TCommonObjectManager.Create;
    gMG.FObjectManager := FManagers[nIdx].FManager as TCommonObjectManager; 
  end else
  begin
    gMG.FObjectManager := nil;
    FreeAndNil(FManagers[nIdx].FManager);    
  end;
end;

procedure TCommonObjectManager.AddObject(const nObj: TObject);
begin
  if not (nObj is TObjectBase) then
    raise Exception.Create(ClassName + ': Object Is Not Support.');
  //xxxxx

  SyncEnter;
  FObjects.Add(nObj);
  SyncLeave;
end;

procedure TCommonObjectManager.DelObject(const nObj: TObject);
var nIdx: Integer;
begin
  SyncEnter;
  try
    nIdx := FObjects.IndexOf(nObj);
    if nIdx > -1 then
      FObjects.Delete(nIdx);
    //xxxxx
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-15
//Parm: �б�;�Ƿ��Ѻ���ʾ
//Desc: ��������״̬���ݴ���nList��
procedure TCommonObjectManager.GetStatus(const nList: TStrings;
  const nFriendly: Boolean);
var nIdx: Integer;
begin
  with TObjectStatusHelper do
  try  
    SyncEnter;     
    if not nFriendly then
    begin
      inherited GetStatus(nList, nFriendly);
      nList.Add('NumObject=' + FObjects.Count.ToString);
      Exit;
    end;
    
    for nIdx:=0 to FObjects.Count - 1 do
    with TObjectBase(FObjects[nIdx]) do
    begin
      TObjectStatusHelper.AddTitle(nList, ClassName);
      GetStatus(nList, nFriendly);
    end;
  finally
    SyncLeave;
  end;
end;

//------------------------------------------------------------------------------
constructor TSerialIDManager.Create;
begin
  inherited;
  FBase := 0;

  with TDateTimeHelper do
  begin
    FTimeStamp := DateTime2Str(Now());
    {$IF defined(MSWINDOWS)}
    FTimeStamp := FTimeStamp + ' Win-OS: ' + TimeLong2CH(GetTickCount);
    {$ENDIF}
  end;
end;

//Date: 2017-03-23
//Parm: �Ƿ�ע��
//Desc: ��ϵͳע�����������
class procedure TSerialIDManager.RegistMe(const nReg: Boolean);
var nIdx: Integer;
begin
  nIdx := GetMe(TSerialIDManager);
  if nReg then
  begin     
    if not Assigned(FManagers[nIdx].FManager) then
      FManagers[nIdx].FManager := TSerialIDManager.Create;
    gMG.FSerialIDManager := FManagers[nIdx].FManager as TSerialIDManager; 
  end else
  begin
    gMG.FSerialIDManager := nil;
    FreeAndNil(FManagers[nIdx].FManager);    
  end;
end;

function TSerialIDManager.GetID: Int64;
begin
  SyncEnter;
  if FBase < High(Int64) then
       Inc(FBase)
  else FBase := 1;

  Result := FBase;
  SyncLeave;
end;

function TSerialIDManager.GetSID: string;
begin
  Result := GetID.ToString;
end;

//Date: 2017-04-15
//Parm: �б�;�Ƿ��Ѻ���ʾ
//Desc: ��������״̬���ݴ���nList��
procedure TSerialIDManager.GetStatus(const nList: TStrings;
  const nFriendly: Boolean);
var nStr: string;
begin
  with TObjectStatusHelper do
  try  
    SyncEnter;
    inherited GetStatus(nList, nFriendly);
    
    if not nFriendly then
    begin
      nList.Add('Base=' + FBase.ToString);
      Exit;
    end;
    
    with TDateTimeHelper do
    begin
      nStr := DateTime2Str(Now());
      {$IF defined(MSWINDOWS)}
      nStr := nStr + ' Win-OS: ' + TimeLong2CH(GetTickCount);
      {$ENDIF}
    end;
  
    nList.Add(FixData('Base:', FBase));
    nList.Add(FixData('Start On:',  FTimeStamp));
    nList.Add(FixData('Service Now:',  nStr));
  finally
    SyncLeave;
  end;
end;

initialization
  //nothing
finalization
  //nothing
end.
