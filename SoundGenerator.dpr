program SoundGenerator;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {frmMain},
  UWaveUtil in 'UWaveUtil.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
