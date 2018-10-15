unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Generics.Collections,
  Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, Spin,
  ExtCtrls,
  UTonePlayer, UWaveGenerator;

type
  TKeyInfo = record
    IsBlack: boolean;
  end;


  TfrmMain = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    pbSoundKeys: TPaintBox;
    Label1: TLabel;
    gbSettings: TGroupBox;
    lblTonesPerOctave: TLabel;
    edTonesPerOctave: TSpinEdit;
    lblGeneratorType: TLabel;
    cbGeneratorType: TComboBox;
    lblOrigFreq: TLabel;
    edOrigFreq: TEdit;
    lblObertonCount: TLabel;
    edObertonCount: TSpinEdit;
    btnApplySettings: TButton;
    cbKeybordStyle: TCheckBox;
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
    procedure cbKeybordStyleClick(Sender: TObject);
  private
    FKeyInfos: TList<TKeyInfo>;
    FTonePlayer: TTonePlayer;
    FTonesPerOctave: integer;
    FEthalonFreq: double;
    FObertonCount: integer;

    procedure CreateKeys;
    function SelectedWaveGenerator: TWaveGeneratorClass;
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
  mmsystem, Math,
  UWaveUtil;

const
  FORMAT_SETTINGS: TFormatSettings = (DecimalSeparator: '.');


procedure TfrmMain.ApplySettings;
begin
  if cbGeneratorType.ItemIndex < 0 then
    Exit;

  FTonesPerOctave := edTonesPerOctave.Value;
  FEthalonFreq := StrToFloat(edOrigFreq.Text, FORMAT_SETTINGS);
  FObertonCount := edObertonCount.Value;

  FTonePlayer.Stop;
  FTonePlayer.Configure(SelectedWaveGenerator, FEthalonFreq, FObertonCount);

  pbSoundKeys.Refresh;
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


procedure TfrmMain.cbKeybordStyleClick(Sender: TObject);
begin
  pbSoundKeys.Refresh;
end;


procedure TfrmMain.ChangeKey(AKeyIndex: integer);
var
  keyFreq: double;
begin
  if
    InRange(AKeyIndex, 0, FTonesPerOctave - 1) and FTonePlayer.IsPlaying
  then begin
    keyFreq := CalcFrequency(AKeyIndex);
    if
      not FTonePlayer.IsPlaying or (keyFreq <> FTonePlayer.Frequency)
    then begin
      FTonePlayer.Stop;
      FTonePlayer.Configure(SelectedWaveGenerator, keyFreq, FObertonCount);
      FTonePlayer.Start;
    end;
  end
  else
    FTonePlayer.Stop;
end;


procedure TfrmMain.CreateKeys;
var
  i: integer;
  keyInfo: TKeyInfo;
begin
  FKeyInfos.Clear;
  for i := 0 to FTonesPerOctave - 1 do begin
    keyInfo.IsBlack := (i < FTonesPerOctave - 1) and (i mod 2 = 1);
    FKeyInfos.Add(keyInfo);
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
  FKeyInfos := TList<TKeyInfo>.Create;
  FTonePlayer := TTonePlayer.Create;

  for genClass in WaveGenerators do
    cbGeneratorType.Items.Add(genClass.GetCaption);
  cbGeneratorType.ItemIndex := 0;

  ApplySettings;
end;


procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FKeyInfos.Free;
  FTonePlayer.Free;
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
  FTonePlayer.Stop;
end;


procedure TfrmMain.pbSoundKeysPaint(Sender: TObject);
var
  i: integer;
  tonesPerOctave: integer;
  keyWidth: double;
  keyHeightInt: integer;
  whiteKeyWidth: double;
  canv: TCanvas;
  x: double;
  leftShift: double;
begin
  tonesPerOctave := Max(FTonesPerOctave, 1);
  keyWidth := pbSoundKeys.ClientWidth / tonesPerOctave;
  keyHeightInt := Round(pbSoundKeys.ClientHeight);

  canv := pbSoundKeys.Canvas;
  canv.Pen.Color := clBlack;
  canv.Brush.Color := clWhite;

  if cbKeybordStyle.Checked then begin
    for i := 0 to tonesPerOctave - 1 do begin
      leftShift := 0;
      whiteKeyWidth := 0;
      if i = 0 then begin
        if tonesPerOctave <= 2 then
          whiteKeyWidth := keyWidth
        else
          whiteKeyWidth := keyWidth + keyWidth / 2;
      end
      else if i = tonesPerOctave - 1 then begin
        if tonesPerOctave mod 2 = 0 then begin
          whiteKeyWidth := keyWidth;
        end
        else begin
          leftShift := keyWidth / 2;
          whiteKeyWidth := keyWidth + keyWidth / 2;
        end;
      end
      else if i mod 2 = 1 then
        Continue
      else begin
        whiteKeyWidth := keyWidth * 2;
        leftShift := keyWidth / 2;
      end;
      x := keyWidth * i - leftShift;
      canv.Rectangle(Round(x), 0, Round(x + whiteKeyWidth), keyHeightInt);
    end;
    canv.Brush.Color := clBlack;
    for i := 0 to tonesPerOctave - 2 do begin
      if i mod 2 = 1 then
        canv.Rectangle(
          Round(keyWidth * i), 0,
          Round(keyWidth * (i + 1)), keyHeightInt div 2);
    end;
  end
  else begin
    for i := 0 to tonesPerOctave - 1 do begin
      canv.Rectangle(
        Round(keyWidth * i), 0, Round(keyWidth * (i + 1)), keyHeightInt);
    end;
  end;
end;


function TfrmMain.SelectedWaveGenerator: TWaveGeneratorClass;
begin
  Result := WaveGenerators[cbGeneratorType.ItemIndex];
end;


procedure TfrmMain.StartPlayKey(AKeyIndex: integer);
begin
  if InRange(AKeyIndex, 0, FTonesPerOctave - 1) then begin
    FTonePlayer.Configure(
      SelectedWaveGenerator, CalcFrequency(AKeyIndex), FObertonCount);
    FTonePlayer.Start;
  end;
end;


end.
