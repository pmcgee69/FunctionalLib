program FunctionalDemo;

uses
  Forms,
  UI in 'UI.pas' {Form6},
  FunctionalLib in 'FunctionalLib.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm6, Form6);
  Application.Run;
end.
