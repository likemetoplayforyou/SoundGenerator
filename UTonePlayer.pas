unit UTonePlayer;

interface

uses
  Classes,
  UWaveGenerator;

type
  TTonePlayer = class(TObject)
  private
    FWaveGeneratorClass: TWaveGeneratorClass;
    FFrequency: double;
    FObertonCount: integer;

    FThread: TThread;
  public
    procedure Start;
    procedure Stop;

    function IsPlaying: boolean;

    procedure Configure(
      AWaveGeneratorClass: TWaveGeneratorClass; AFrequency: double;
      AObertonCount: integer);

    property Frequency: double read FFrequency;
  end;


implementation

uses
  SysUtils,
  UWaveUtil;

type
  TTonePlayerThread = class(TThread)
  private
    FWaveGeneratorClass: TWaveGeneratorClass;
    FFrequency: double;
    FObertonCount: integer;
  public
    constructor Create(
      AWaveGeneratorClass: TWaveGeneratorClass; AFrequency: double;
      AObertonCount: integer);

    procedure Execute; override;
  end;


{ TTonePlayer }

procedure TTonePlayer.Configure(
  AWaveGeneratorClass: TWaveGeneratorClass; AFrequency: double;
  AObertonCount: integer);
begin
  FWaveGeneratorClass := AWaveGeneratorClass;
  FFrequency := AFrequency;
  FObertonCount := AObertonCount;
end;


function TTonePlayer.IsPlaying: boolean;
begin
  Result := FThread <> nil;
end;


procedure TTonePlayer.Start;
begin
  if FThread <> nil then
    Exit;

  FThread :=
    TTonePlayerThread.Create(FWaveGeneratorClass, FFrequency, FObertonCount);
end;


procedure TTonePlayer.Stop;
begin
  if FThread = nil then
    Exit;

  FThread.Terminate;
  FreeAndNil(FThread);
end;


{ TTonePlayerThread }

constructor TTonePlayerThread.Create(
  AWaveGeneratorClass: TWaveGeneratorClass; AFrequency: double;
  AObertonCount: integer);
begin
  FWaveGeneratorClass := AWaveGeneratorClass;
  FFrequency := AFrequency;
  FObertonCount := AObertonCount;

  inherited Create(false);
end;


procedure TTonePlayerThread.Execute;
const
  SAMPLES_PER_SEC = 44100;
  BUFFER_COUNT = 2;
var
  waveOut: TWaveOut;
  level: integer;
  curPos: cardinal;
  gen: TWaveGenerator;
  i: integer;
  bufInfo: TDataInfo;
begin
  waveOut := TWaveOut.Create;
  try
    if waveOut.Open(1, SAMPLES_PER_SEC, 16, BUFFER_COUNT) then begin
      level := 1 shl 15 - 1;
      curPos := 0;

      gen :=
        FWaveGeneratorClass.Create(SAMPLES_PER_SEC, FFrequency, FObertonCount);
      try
        i := 0;
        while not Terminated do begin
          bufInfo := waveOut.Buffers[i];
          gen.Generate(
            bufInfo.Data, bufInfo.Length, FFrequency, level, curPos);
          waveOut.PlayBuffer(i);
          i := 1 - i;
        end;
      finally
        gen.Free;
      end;
      waveOut.Close;
    end;
  finally
    waveOut.Free;
  end;
end;


end.
