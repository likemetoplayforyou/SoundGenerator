program SoundGenerator;

uses
  Forms,
  UMain in 'UMain.pas' {frmMain},
  UWaveUtil in 'UWaveUtil.pas',
  UTonePlayer in 'UTonePlayer.pas',
  UWaveGenerator in 'UWaveGenerator.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
