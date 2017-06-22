{*******************************************************************************
  ����: dmzn@163.com 2017-03-21
  ����: ʹ�Ѿ������Ķ�������ظ�ʹ�õĶ����

  ��ע: 
  *.�̰߳�ȫ.
  *.TObjectPoolManager.Lock��Release�������ʹ��.
*******************************************************************************}
unit UObjectPool;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, UBaseObject, ULibFun;

type
  TObjectNewOne = reference to function(): TObject;
  //�������ɷ���
    
  PObjectPoolItem = ^TObjectPoolItem;
  TObjectPoolItem = record    
    FObject: TObject;             //����
    FUsed: Boolean;               //ʹ����
  end;

  PObjectPoolClass = ^TObjectPoolClass;
  TObjectPoolClass = record 
    FClass: TClass;               //����
    FNewOne: TObjectNewOne;       //����
      
    FNumLocked: Integer;          //������
    FNumLockAll: Int64;           //�������
    FItems: TList;                //�����б�
  end;

  TObjectPoolManager = class(TManagerBase)
  private
    FPool: array of TObjectPoolClass;
    //�����
    FNumLocked: Integer;
    FNumLockAll: Int64;
    //��������
    FSrvClosed: Integer;
    //����ر� 
  protected
    procedure ClearPool(const nFree: Boolean);
    //������Դ
    function FindPool(const nClass: TClass): Integer;
    //��������
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    class procedure RegistMe(const nReg: Boolean); override;
    //ע�������
    function NewClass(const nClass: TClass; const nNew: TObjectNewOne): Integer;
    procedure NewNormalClass;
    //ע������
    function Lock(const nClass: TClass; const nNew: TObjectNewOne=nil): TObject;
    procedure Release(const nObject: TObject);
    //�����ͷ�
    procedure GetStatus(const nList: TStrings;
      const nFriendly: Boolean = True); override;
    function GetHealth(const nList: TStrings = nil): TObjectHealth; override;
    //��ȡ״̬
  end;

var
  gObjectPoolManager: TObjectPoolManager = nil;
  //ȫ��ʹ��
  
implementation

uses
  UManagerGroup;
  
const
  cYes  = $0002;
  cNo   = $0005;

//------------------------------------------------------------------------------
constructor TObjectPoolManager.Create;
begin
  inherited;
  FNumLocked := 0;
  FSrvClosed := cNo;
  
  NewNormalClass;
  //reg normal 
end;

destructor TObjectPoolManager.Destroy;
begin
  SyncEnter;
  FSrvClosed := cYes; //set close flag  
  SyncLeave;

  if FNumLocked > 0 then
  begin
    while FNumLocked > 0 do
      Sleep(1);
    //wait for relese
  end;
    
  ClearPool(True);
  inherited;
end;

//Date: 2017-03-23
//Parm: �Ƿ�ע��
//Desc: ��ϵͳע�����������
class procedure TObjectPoolManager.RegistMe(const nReg: Boolean);
var nIdx: Integer;
begin
  nIdx := GetMe(TObjectPoolManager);
  if nReg then
  begin     
    if not Assigned(FManagers[nIdx].FManager) then
      FManagers[nIdx].FManager := TObjectPoolManager.Create;
    gMG.FObjectPool := FManagers[nIdx].FManager as TObjectPoolManager; 
  end else
  begin
    gMG.FObjectPool := nil;
    FreeAndNil(FManagers[nIdx].FManager);    
  end;
end;

//Desc: ��������
procedure TObjectPoolManager.ClearPool(const nFree: Boolean);
var nIdx,i: Integer;
    nItem: PObjectPoolItem;
begin
  for nIdx := Low(FPool) to High(FPool) do
  with FPool[nIdx] do
  begin
    if Assigned(FItems) then
    begin
      for i := FItems.Count - 1 downto 0 do
      begin
        nItem := FItems[i];
        FreeAndNil(nItem.FObject);

        Dispose(nItem);
        FItems.Delete(i);
      end;

      FreeAndNil(FItems);
    end;
  end;

  if nFree then  
    SetLength(FPool, 0);
  //clear all
end;

//Date: 2017-03-23
//Parm: ���� 
//Desc: ����nClass�ڶ�����е�λ��
function TObjectPoolManager.FindPool(const nClass: TClass): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx := Low(FPool) to High(FPool) do
  if FPool[nIdx].FClass = nClass then
  begin
    Result := nIdx;
    Exit;
  end;
end;

//Date: 2017-03-23
//Parm: ����;��������
//Desc: ע��nClass�ൽ�����
function TObjectPoolManager.NewClass(const nClass: TClass;
  const nNew: TObjectNewOne): Integer;
begin
  SyncEnter;
  try
    Result := FindPool(nClass);
    if Result < 0 then
    begin
      Result := Length(FPool);
      SetLength(FPool, Result + 1);
      FillChar(FPool[Result], SizeOf(TObjectPoolClass), #0);
    end;

    with FPool[Result] do
    begin
      FClass := nClass;
      FNewOne := nNew;
    end;
  finally
    SyncLeave;
  end;
end;

//Date: 2017-03-23
//Desc: ע�᳣���� 
procedure TObjectPoolManager.NewNormalClass;
var nNewOne: TObjectNewOne; 
begin
  nNewOne := function():TObject begin Result := TStringList.Create; end;
  NewClass(TStrings, nNewOne);
  NewClass(TStringList, nNewOne);

  nNewOne := function():TObject begin Result := TList.Create; end;
  NewClass(TList, nNewOne);
end;

//Date: 2017-03-23
//Parm: ��������;��������
//Desc: ����nClass�Ķ���ָ��
function TObjectPoolManager.Lock(const nClass: TClass;
  const nNew: TObjectNewOne): TObject;
var nIdx,i: Integer;
    nItem: PObjectPoolItem;    
begin  
  SyncEnter;
  try    
    Result := nil; 
    if FSrvClosed = cYes then
      raise Exception.Create(ClassName + ': Not Support "Lock" When Closing.');
    //pool will close
                                
    nIdx := FindPool(nClass);          
    if (not Assigned(nNew)) and ((nIdx < 0) or 
       (not Assigned(FPool[nIdx].FNewOne))) then
      raise Exception.Create(ClassName + ': Lock Object Need "Create" Method.');
    //xxxxx

    if nIdx < 0 then
      nIdx := NewClass(nClass, nNew);
    //xxxxx
    
    with FPool[nIdx] do
    begin
      if not Assigned(FItems) then
        FItems := TList.Create;
      //xxxxx

      if Assigned(nNew) and (not Assigned(FNewOne)) then
        FNewOne := nNew;
      //xxxxx

      for i := FItems.Count - 1 downto 0 do
      begin
        nItem := FItems[i];
        if not nItem.FUsed then
        begin
          Result := nItem.FObject;
          nItem.FUsed := True;
          Break;
        end;
      end;

      if not Assigned(Result) then
      begin
        New(nItem);
        FItems.Add(nItem);         
        
        if Assigned(nNew) then         
             nItem.FObject := nNew()
        else nItem.FObject := FNewOne();

        Result := nItem.FObject;
        nItem.FUsed := True;
      end;
    end;

    Inc(FPool[nIdx].FNumLocked);
    Inc(Self.FNumLocked);
    //inc counter

    if FPool[nIdx].FNumLockAll < High(Int64) then      
         Inc(FPool[nIdx].FNumLockAll)
    else FPool[nIdx].FNumLockAll := 0;

    if Self.FNumLockAll < High(Int64) then
         Inc(Self.FNumLockAll)
    else Self.FNumLockAll := 0;    
  finally
    SyncLeave;
  end;
end;

//Date: 2017-03-23
//Parm: ����
//Desc: �ͷŶ���
procedure TObjectPoolManager.Release(const nObject: TObject);
var nIdx,i: Integer;
    nItem: PObjectPoolItem; 
begin
  if not Assigned(nObject) then Exit;
  //nothing
  
  SyncEnter;
  try     
    for nIdx := Low(FPool) to High(FPool) do
    with FPool[nIdx] do
    begin
      if not (nObject is FClass) then Continue;
      //not match
            
      if Assigned(FItems) then         
      begin       
        for i := FItems.Count - 1 downto 0 do
        begin
          nItem := FItems[i];
          if nItem.FObject = nObject then
          begin             
            Dec(FPool[nIdx].FNumLocked);
            Dec(Self.FNumLocked);

            nItem.FUsed := False;
            Exit;
          end;
        end;
      end;
    end;
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-15
//Parm: �б�;�Ƿ��Ѻ���ʾ
//Desc: ��������״̬���ݴ���nList��
procedure TObjectPoolManager.GetStatus(const nList: TStrings;
  const nFriendly: Boolean);
var nIdx,nLen: Integer;    
begin
  with TObjectStatusHelper do
  try
    SyncEnter;
    inherited GetStatus(nList, nFriendly);
    
    if not nFriendly then
    begin
      nList.Add('NumPool=' + Length(FPool).ToString);
      nList.Add('NumLocked=' +  FNumLocked.ToString);
      nList.Add('NumLockAll=' + FNumLockAll.ToString);
      Exit;
    end;
                           
    nList.Add(FixData('NumPool:', Length(FPool)));
    nList.Add(FixData('NumLocked:', FNumLocked));
    nList.Add(FixData('NumLockAll:', FNumLockAll));
                                  
    for nIdx := Low(FPool) to High(FPool) do
    with FPool[nIdx] do
    begin           
      if Assigned(FItems) then
           nLen := FItems.Count
      else nLen := 0;
      
      nList.Add('');
      nList.Add(FixData(FClass.ClassName + '.NumAll:', nLen));
      nList.Add(FixData(FClass.ClassName + '.NumLocked:', FNumLocked));
      nList.Add(FixData(FClass.ClassName + '.NumLockAll:', FNumLockAll));
    end;
  finally
    SyncLeave;
  end;
end;

//Date: 2017-04-16
//Desc: ��ȡ������������ 
function TObjectPoolManager.GetHealth(const nList: TStrings): TObjectHealth;
var nStr: string;
begin
  SyncEnter;
  try
    Result := hlNormal;
    if (FNumLocked >= 1000) and (Result < hlLow) then
    begin
      if Assigned(nList) then
      begin
        nStr := '����������[NumLocked: %d]����,�ȴ��ͷ�.';
        nList.Add(Format(nStr, [FNumLocked]));
      end;

      Result := hlLow;
    end;

    if (FNumLocked >= 5000) and (Result < hlBad) then
    begin
      if Assigned(nList) then
      begin
        nStr := '����������[NumLocked: %d]�ﵽ����ֵ,�����ͷ��߼�.';
        nList.Add(Format(nStr, [FNumLocked]));
      end;

      Result := hlBad;
    end;    
  finally
    SyncLeave;
  end;
end;

initialization
  //nothing
finalization
  //nothing
end.
