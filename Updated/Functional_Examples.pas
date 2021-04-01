unit Functional_Examples;

interface

type
  TFunctionalExamples = class
  public
    class function Factorial(Value: integer): integer;
  end;


implementation

uses FunctionalLib;

{ TFunctionalExamples }

class function TFunctionalExamples.Factorial(Value: integer) : integer;
begin
  Result := TFunctional.Ternary<integer, integer> (
                Value = 1,                                  // predicate

                TFunctional.Identity<integer, integer> (1), // if = 1

                function(Number: integer) : integer         // if <> 1
                begin
                  Result := Number * Factorial(Pred(Number));
                end)
            (Value);                                        // apply to AValue
end;


end.
