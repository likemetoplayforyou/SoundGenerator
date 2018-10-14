unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    PaintBox1: TPaintBox;
    lblOrigFreq: TLabel;
    edOrigFreq: TEdit;
    cbGeneratorType: TComboBox;
    lblGeneratorType: TLabel;
    lblObertonCount: TLabel;
    edObertonCount: TSpinEdit;
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FPlaySoundThread: TThread;
    FIsPlaying: boolean;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  mmsystem, Generics.Collections, Math,
  UWaveUtil;

const
  BLOCK_SIZE = 1024 * 32;
  BUFFER_COUNT = 2;


type
  TWaveGenerator = class(TObject)
  private
    FSampleRate: integer;
    FFrequency: double;
    FObertonCount: integer;
  public
    constructor Create(
      ASampleRate: integer; AFrequency: double;
      AObertonCount: integer); virtual;

    class function GetCaption: string; virtual; abstract;

    procedure Generate(
      ABuffer: PSmallInt; ASize: integer; AFreq: double; ALevel: SmallInt;
      var ACurrPos: cardinal); virtual; abstract;
  end;


  TWaveGeneratorClass = class of TWaveGenerator;


var
  WaveGenerators: TList<TWaveGeneratorClass>;


type
  TPlaySoundThread = class(TThread)
  private
    FWaveGeneratorClass: TWaveGeneratorClass;
    FOrigFreq: double;
    FObertonCount: integer;
  public
    constructor Create(
      AWaveGeneratorClass: TWaveGeneratorClass; AOrigFreq: double;
      AObertonCount: integer);

    procedure Execute; override;
  end;


  TSinGenerator = class(TWaveGenerator)
  protected
    function GenerateNormalizedSample(
      ASamplePos: cardinal; AFreq: double): double; virtual;
  public
    class function GetCaption: string; override;
    procedure Generate(
      ABuffer: PSmallInt; ASize: integer; AFreq: double; ALevel: SmallInt;
      var ACurrPos: cardinal); override;
  end;


  TObertonGenerator = class(TSinGenerator)
  protected
    class function GetCaption: string; override;
    function GenerateNormalizedSample(
      ASamplePos: cardinal; AFreq: double): double; override;
  public
    procedure AfterConstruction; override;
  end;


procedure TfrmMain.btnStartClick(Sender: TObject);
const
  FORMAT_SETTINGS: TFormatSettings = (DecimalSeparator: '.');
var
  waveGenCls: TWaveGeneratorClass;
begin
  if FIsPlaying or (cbGeneratorType.ItemIndex < 0) then
    Exit;

  FIsPlaying := true;
  waveGenCls := WaveGenerators[cbGeneratorType.ItemIndex];
  FPlaySoundThread :=
    TPlaySoundThread.Create(
      waveGenCls, StrToFloatDef(edOrigFreq.Text, 1, FORMAT_SETTINGS),
      edObertonCount.Value);
end;


procedure TfrmMain.btnStopClick(Sender: TObject);
begin
  FPlaySoundThread.Terminate;
  FIsPlaying := false;
end;


procedure TfrmMain.FormCreate(Sender: TObject);
var
  genClass: TWaveGeneratorClass;
begin
  inherited;
  for genClass in WaveGenerators do
    cbGeneratorType.Items.Add(genClass.GetCaption);
  cbGeneratorType.ItemIndex := 0;
end;


procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FPlaySoundThread.Free;
end;


{ TPlaySoundThread }

constructor TPlaySoundThread.Create(
  AWaveGeneratorClass: TWaveGeneratorClass; AOrigFreq: double;
  AObertonCount: integer);
begin
  FWaveGeneratorClass := AWaveGeneratorClass;
  FOrigFreq := AOrigFreq;
  FObertonCount := AObertonCount;

  inherited Create(false);
end;


procedure TPlaySoundThread.Execute;
const
  SAMPLES_PER_SEC = 44100;
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
        FWaveGeneratorClass.Create(SAMPLES_PER_SEC, FOrigFreq, FObertonCount);
      try
        i := 0;
        while not Terminated do begin
          bufInfo := waveOut.Buffers[i];
          gen.Generate(bufInfo.Data, bufInfo.Length, FOrigFreq, level, curPos);
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


{ TSinGenerator }

procedure TSinGenerator.Generate(
  ABuffer: PSmallInt; ASize: integer; AFreq: double; ALevel: SmallInt;
  var ACurrPos: cardinal);
var
  i: integer;
  y: double;
begin
  for i := 0 to ASize - 1 do begin
    y := ALevel * GenerateNormalizedSample(ACurrPos, AFreq);
    ABuffer^ := SmallInt(Round(y));
    Inc(ABuffer);
    Inc(ACurrPos);
  end;
end;


function TSinGenerator.GenerateNormalizedSample(
  ASamplePos: cardinal; AFreq: double): double;
var
  angle: double;
begin
  angle := 2 * PI / FSampleRate * ASamplePos * AFreq;
  Result := Sin(angle);
end;


class function TSinGenerator.GetCaption: string;
begin
  Result := 'SIN()';
end;


{ TObertonGenerator }

procedure TObertonGenerator.AfterConstruction;
begin
  inherited;
  FObertonCount := Min(Round(FSampleRate / (FFrequency * 2)), FObertonCount);
end;


function TObertonGenerator.GenerateNormalizedSample(
  ASamplePos: cardinal; AFreq: double): double;
var
  i: integer;
  value: double;
begin
  Result := 0;
  for i := 1 to FObertonCount do begin
    value := inherited GenerateNormalizedSample(ASamplePos, AFreq * i);
    value := value / 2 / i;
    Result := Result + value;
  end;
end;


class function TObertonGenerator.GetCaption: string;
begin
  Result := 'Oberton (sin)'
end;


{ TWaveGenerator }

constructor TWaveGenerator.Create(
  ASampleRate: integer; AFrequency: double; AObertonCount: integer);
begin
  inherited Create;
  FSampleRate := ASampleRate;
  FFrequency := AFrequency;
  FObertonCount := AObertonCount;
end;


initialization
  WaveGenerators := TList<TWaveGeneratorClass>.Create;

  WaveGenerators.Add(TSinGenerator);
  WaveGenerators.Add(TObertonGenerator);


finalization
  WaveGenerators.Free;


end.
