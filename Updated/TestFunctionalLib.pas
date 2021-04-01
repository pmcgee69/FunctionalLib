unit TestFunctionalLib;

interface

uses
  TestFramework, Classes, Generics.Collections, SysUtils, FunctionalLib, Functional_Examples;

type
  // Test methods for class TMemoize

  TestTFunctional = class(TTestCase)
  private
    class function SlowIncrement(ANum: integer): integer;
  public
  published
    procedure TestIdentity;
    procedure TestMemoize;
    procedure TestPartialApply;
    procedure TestTernary;
  end;

  TestTFunctionalExamples = class(TTestCase)
  published
    procedure TestFactorial;
  end;

implementation

uses
  Windows, Benchmarker;

class function TestTFunctional.SlowIncrement(ANum: integer): integer;
begin
  Sleep(100); // simulate web service / db access
  Result := ANum + 1;
end;

procedure TestTFunctional.TestIdentity;
const
  Expected = 42;
var
  Id42: TFunc<integer, integer>;
  Actual: Integer;
begin
  Id42 := TFunctional.Identity<integer, integer>(Expected);

  Actual := Id42(13);

  CheckEquals(Expected, Actual);
end;

procedure TestTFunctional.TestMemoize;
var
  Cold, Warm: Double;
  ColdResult, WarmResult, AnonResult: integer;
  MemoizedSlowInc: TFunc<integer, integer>;
  BenchmarkProc: TProc;
begin
  MemoizedSlowInc := TFunctional.Memoize<integer,integer>(SlowIncrement);
  BenchmarkProc := procedure()
  begin
    AnonResult := MemoizedSlowInc(1);
  end;
  // first execution should be slow
  Cold := TBenchmarker.Benchmark(BenchmarkProc, 1, 0);
  ColdResult := AnonResult;
  // next time for same value should be fast
  Warm := TBenchmarker.Benchmark(BenchmarkProc, 1, 0);
  WarmResult := AnonResult;
  CheckEquals(ColdResult, WarmResult);
  CheckTrue(Warm < (Cold / 100));
end;

procedure TestTFunctional.TestPartialApply;
var
  Partial: TFunc<integer, integer>;
  TestFunc: TFunc<integer, integer, integer>;
begin
  TestFunc := function(A, B: integer): integer
  begin
    Result := A - B;
  end;

  Partial := TFunctional.PartialApply<integer, integer, integer>(TestFunc, 5);

  CheckEquals(TestFunc(5, 3), Partial(3));
end;

procedure TestTFunctional.TestTernary;
var
  Func: TFunc<integer, integer>;
  Actual: integer;
begin
  Func := TFunctional.Ternary<integer, integer>(
    true,
    TFunctional.Identity<integer, integer>(2),
    function(A: integer): integer
    begin
      raise Exception.Create('oops.');
    end);

  Actual := Func(1);

  CheckEquals(2, Actual);
end;

{ TFunctionalExamples }

procedure TestTFunctionalExamples.TestFactorial;
const
  Expected = 6;
var
  Actual: integer;
begin
  Actual := TFunctionalExamples.Factorial(3);

  CheckEquals(Expected, Actual);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTFunctional.Suite);
  RegisterTest(TestTFunctionalExamples.Suite);
end.

