unit Managed_Dict;

interface

uses
  Generics.Collections;

type
  IDictionary<TKey,TValue> = interface                                         //     ['{4A15EB4C-9FA5-4781-B910-F8E110519C6E}']
    procedure Add        (const Key: TKey; const Value: TValue);
    function  TryGetValue(const Key: TKey; var   Value: TValue): Boolean;
  end;

  TManagedDictionary<TKey,TValue> = class(TDictionary<TKey,TValue>, IDictionary<TKey,TValue>)
  protected
    FRefCount         : Integer;
    function  QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef  : Integer; stdcall;
    function _Release : Integer; stdcall;
  end;


implementation

uses
  Windows;

{ TManagedDictionary<TKey, TValue> }

function TManagedDictionary<TKey, TValue>.QueryInterface(const IID: TGUID; out Obj) : HResult;
begin
  if GetInterface(IID, Obj) then  Result := 0
                            else  Result := E_NOINTERFACE;
end;


function TManagedDictionary<TKey,TValue>._AddRef: Integer;
begin
  Result   := InterlockedIncrement(FRefCount);
end;


function TManagedDictionary<TKey,TValue>._Release: Integer;
begin
  Result   := InterlockedDecrement(FRefCount);
  if Result = 0 then Destroy;
end;

end.
