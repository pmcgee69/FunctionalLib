unit FunctionalLib;

interface

uses
  Classes, Generics.Collections, SysUtils;

type
  IDictionary<TKey,TValue> = interface
    ['{4A15EB4C-9FA5-4781-B910-F8E110519C6E}']
    procedure Add(const Key: TKey; const Value: TValue);
    function TryGetValue(const Key: TKey; out Value: TValue): Boolean;
  end;

  TManagedDictionary<TKey,TValue> = class(TDictionary<TKey,TValue>, IDictionary<TKey,TValue>)
  protected
    FRefCount: Integer;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TCurriedFunc<A,B,R> = reference to function(AArgA: A) : TFunc<B, R>;

  TFunctional = class
  public
    class function Identity<A, R>(AValue: R): TFunc<A, R>;
    class function Memoize<A, R>(AFunc: TFunc<A, R>): TFunc<A, R>;
    class function PartialApply<A, B, R>(AFunc: TFunc<A, B, R>; AArgA: A): TFunc<B, R>;
    class function Ternary<A, R>(APredicate: boolean; AIfTrue, AIfFalse: TFunc<A, R>): TFunc<A, R>;
  end;

  TFunctionalExamples = class
  public
    class function Factorial(AValue: integer): integer;
  end;

implementation

uses
  Windows;

{ TManagedDictionary<TKey, TValue> }

function TManagedDictionary<TKey, TValue>.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TManagedDictionary<TKey,TValue>._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TManagedDictionary<TKey,TValue>._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

{ TFuctional }

class function TFunctional.Identity<A, R>(AValue: R): TFunc<A, R>;
begin
  Result := function (AArg: A): R
  begin
    Result := AValue;
  end;
end;

class function TFunctional.Memoize<A, R>(AFunc: TFunc<A, R>): TFunc<A, R>;
var
  Map: IDictionary<A, R>;
begin
  Map := TManagedDictionary<A, R>.Create;

  Result := function(arg: A): R
  var
    FuncResult: R;
  begin
    if Map.TryGetValue(arg, FuncResult) then begin
      Exit(FuncResult);
    end;
    FuncResult := AFunc(arg);
    Map.Add(arg, FuncResult);
    Exit(FuncResult);
  end;
end;

class function TFunctional.PartialApply<A, B, R>(AFunc: TFunc<A, B, R>; AArgA: A): TFunc<B, R>;
begin
  Result := function(AArgB: B): R
  begin
    Result := AFunc(AArgA, AArgB);
  end;
end;

class function TFunctional.Ternary<A, R>(
  APredicate: boolean;
  AIfTrue, AIfFalse: TFunc<A, R>): TFunc<A, R>;
begin
  if APredicate then
    Result := AIfTrue
  else
    Result := AIfFalse;
end;

{ TFunctionalExamples }

class function TFunctionalExamples.Factorial(AValue: integer): integer;
begin
  Result := TFunctional.Ternary<integer, integer>(
    AValue = 1,                                // predicate

    TFunctional.Identity<integer, integer>(1), // if = 1

    function(ANumber: integer): integer        // if <> 1
    begin
      Result := ANumber * Factorial(Pred(ANumber));
    end
    )

    (AValue);                                  // apply to AValue
end;

end.
