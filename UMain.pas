unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  Vcl.ExtCtrls;

type
  TSoundInfo = class(TObject)
  private
    FMute: boolean;
    FFrequency: double;
  public
    property Mute: boolean read FMute write FMute;
    property Frequency: double read FFrequency write FFrequency;
  end;


  TfrmMain = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    pbSoundKeys: TPaintBox;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    lblTonesPerOctave: TLabel;
    edTonesPerOctave: TSpinEdit;
    lblGeneratorType: TLabel;
    cbGeneratorType: TComboBox;
    lblOrigFreq: TLabel;
    edOrigFreq: TEdit;
    lblObertonCount: TLabel;
    edObertonCount: TSpinEdit;
    btnApplySettings: TButton;
    cbKeyBordStyle: TCheckBox;
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pbSoundKeysPaint(Sender: TObject);
    procedure edTonesPerOctaveExit(Sender: TObject);
    procedure pbSoundKeysMouseDown(
      Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnApplySettingsClick(Sender: TObject);
    procedure pbSoundKeysMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbSoundKeysMouseMove(
      Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    FSoundInfo: TSoundInfo;
    FTonesPerOctave: integer;
    FEthalonFreq: double;
    FObertonCount: integer;
    FPlaySoundThread: TThread;
    FIsPlaying: boolean;

    procedure ApplySettings;
    function CalcFrequency(AKeyIndex: integer): double;
    procedure StartPlayKey(AKeyIndex: integer);
    procedure ChangeKey(AKeyIndex: integer);
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

  FORMAT_SETTINGS: TFormatSettings = (DecimalSeparator: '.');


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
    FSoundInfo: TSoundInfo;
    FObertonCount: integer;
  public
    constructor Create(
      AWaveGeneratorClass: TWaveGeneratorClass; ASoundInfo: TSoundInfo;
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


procedure TfrmMain.ApplySettings;
begin
  if cbGeneratorType.ItemIndex < 0 then
    Exit;

  if FPlaySoundThread <> nil then
    FPlaySoundThread.Terminate;
  FTonesPerOctave := edTonesPerOctave.Value;
  FEthalonFreq := StrToFloat(edOrigFreq.Text, FORMAT_SETTINGS);
  FObertonCount := edObertonCount.Value;

  pbSoundKeys.Refresh;

  FPlaySoundThread :=
    TPlaySoundThread.Create(
      WaveGenerators[cbGeneratorType.ItemIndex], FSoundInfo, FObertonCount);
end;


procedure TfrmMain.btnApplySettingsClick(Sender: TObject);
begin
  ApplySettings;
end;


procedure TfrmMain.btnStartClick(Sender: TObject);
//var
//  waveGenCls: TWaveGeneratorClass;
begin
//  if FIsPlaying or (cbGeneratorType.ItemIndex < 0) then
//    Exit;
//
//  FIsPlaying := true;
//  waveGenCls := WaveGenerators[cbGeneratorType.ItemIndex];
//  FPlaySoundThread :=
//    TPlaySoundThread.Create(
//      waveGenCls, StrToFloatDef(edOrigFreq.Text, 1, FORMAT_SETTINGS),
//      edObertonCount.Value);
end;


procedure TfrmMain.btnStopClick(Sender: TObject);
begin
//  FPlaySoundThread.Terminate;
//  FIsPlaying := false;
end;


function TfrmMain.CalcFrequency(AKeyIndex: integer): double;
begin
  Result := FEthalonFreq * Power(2, AKeyIndex / FTonesPerOctave);
end;


procedure TfrmMain.ChangeKey(AKeyIndex: integer);
begin
  if InRange(AKeyIndex, 0, FTonesPerOctave - 1) then begin
    FSoundInfo.Frequency := CalcFrequency(AKeyIndex);
  end;
end;


procedure TfrmMain.edTonesPerOctaveExit(Sender: TObject);
begin
  FTonesPerOctave := edTonesPerOctave.Value;
  pbSoundKeys.Refresh;
end;


procedure TfrmMain.FormCreate(Sender: TObject);
var
  genClass: TWaveGeneratorClass;
begin
  inherited;
  FSoundInfo := TSoundInfo.Create;
  FSoundInfo.Mute := true;

  for genClass in WaveGenerators do
    cbGeneratorType.Items.Add(genClass.GetCaption);
  cbGeneratorType.ItemIndex := 0;
end;


procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FPlaySoundThread.Free;
  FSoundInfo.Free;
  inherited;
end;


procedure TfrmMain.pbSoundKeysMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  keyIdx: integer;
begin
  keyIdx := Trunc(X * FTonesPerOctave / pbSoundKeys.ClientWidth);
  StartPlayKey(keyIdx);
end;


procedure TfrmMain.pbSoundKeysMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  keyIdx: integer;
begin
  keyIdx := Trunc(X * FTonesPerOctave / pbSoundKeys.ClientWidth);
  ChangeKey(keyIdx);
end;


procedure TfrmMain.pbSoundKeysMouseUp(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FSoundInfo.Mute := true;
end;


procedure TfrmMain.pbSoundKeysPaint(Sender: TObject);
var
  i: integer;
  tonesPerOctave: integer;
  keyWidth: double;
  keyHeightInt: integer;
  canv: TCanvas;
begin
  tonesPerOctave := Max(FTonesPerOctave, 1);
  keyWidth := pbSoundKeys.ClientWidth / tonesPerOctave;
  keyHeightInt := Round(pbSoundKeys.ClientHeight);

  canv := pbSoundKeys.Canvas;
  canv.Pen.Color := clBlack;
  canv.Brush.Color := clWhite;
  for i := 0 to tonesPerOctave - 1 do begin
    canv.Rectangle(
      Round(keyWidth * i), 0, Round(keyWidth * (i + 1)), keyHeightInt);
  end;
end;


procedure TfrmMain.StartPlayKey(AKeyIndex: integer);
begin
  if InRange(AKeyIndex, 0, FTonesPerOctave - 1) then begin
    FSoundInfo.Frequency := CalcFrequency(AKeyIndex);
    FSoundInfo.Mute := false;
  end;
end;


{ TPlaySoundThread }

constructor TPlaySoundThread.Create(
  AWaveGeneratorClass: TWaveGeneratorClass; ASoundInfo: TSoundInfo;
  AObertonCount: integer);
begin
  FWaveGeneratorClass := AWaveGeneratorClass;
  FSoundInfo := ASoundInfo;
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
        FWaveGeneratorClass.Create(
          SAMPLES_PER_SEC, FSoundInfo.Frequency, FObertonCount);
      try
        i := 0;
        while not Terminated do begin
          while FSoundInfo.Mute do begin
            if Terminated then
              Exit;
          end;

          bufInfo := waveOut.Buffers[i];
          gen.Generate(
            bufInfo.Data, bufInfo.Length, FSoundInfo.Frequency, level, curPos);
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
