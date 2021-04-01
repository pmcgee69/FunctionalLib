unit FunctionalLib;

interface

uses
  Classes, Generics.Collections, SysUtils, Managed_Dict;

type

  TCurriedFunc<A,B,R> = reference to function(ArgA: A) : TFunc<B, R>;

  TFunctional = class
  public
    class function Identity     <A, R>    (Value: R)                      : TFunc<A, R>;
    class function Memoize      <A, R>    (Func: TFunc<A, R>)             : TFunc<A, R>;
    class function PartialApply <A, B, R> (Func: TFunc<A, B, R>; ArgA: A) : TFunc<B, R>;
    class function Ternary      <A, R>    (Predicate: boolean;
                                           IfTrue, IfFalse: TFunc<A, R>)  : TFunc<A, R>;
  end;


implementation

{ TFunctional }

class function TFunctional.Identity <A, R> (Value: R) : TFunc<A, R>;
begin
  Result := function (Arg: A): R
            begin
              Result := Value;
            end;
end;


class function TFunctional.Memoize <A, R> (Func: TFunc<A, R>) : TFunc<A, R>;
var
  Map :  IDictionary <A, R>;
begin
  Map := TManagedDictionary <A, R>.Create;

  Result := function(arg: A): R
            var
              FuncResult: R;
            begin
              if not Map.TryGetValue(arg, FuncResult) then begin
                 FuncResult := Func(arg);
                 Map.Add(arg, FuncResult);
              end;
              Exit(FuncResult);
            end;
end;


class function TFunctional.PartialApply <A, B, R> (Func: TFunc<A, B, R>; ArgA: A): TFunc<B, R>;
begin
  Result := function(ArgB: B): R
            begin
              Result := Func(ArgA, ArgB);
            end;
end;


class function TFunctional.Ternary <A, R> ( Predicate: boolean;
                                            IfTrue, IfFalse: TFunc<A, R>)        : TFunc<A, R>;
begin
  if Predicate then Result := IfTrue
               else Result := IfFalse;
end;


end.
