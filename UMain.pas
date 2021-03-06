unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Generics.Collections,
  Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, Spin,
  ExtCtrls,
  UTonePlayer, UWaveGenerator, UKeyPlayer, UFilePlayer;

type
  TKeyInfo = record
    IsBlack: boolean;
  end;


  TKeyGUI = class(TObject)
  private
    FLbl: TLabel;
  public
    constructor Create(AContainer: TWinControl; AIndex: integer);
    destructor Destroy; override;

    property Lbl: TLabel read FLbl;
  end;


  TfrmMain = class(TForm)
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
    pnKeyBoard: TPanel;
    pbSoundKeys: TPaintBox;
    pnKeyCaptions: TPanel;
    btnStartRec: TButton;
    tmRec: TTimer;
    btnStopRec: TButton;
    btnPlayFile: TButton;
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
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure pnKeyCaptionsResize(Sender: TObject);
    procedure tmRecTimer(Sender: TObject);
    procedure btnStartRecClick(Sender: TObject);
    procedure btnStopRecClick(Sender: TObject);
    procedure btnPlayFileClick(Sender: TObject);
  private
    FKeyInfos: TList<TKeyInfo>;
    FKeyGUIList: TList<TKeyGUI>;
    FHotKeysMap: TDictionary<string, integer>;
    FKeyPlayer: TKeyPlayer;
    FFilePlayer: TFilePlayer;
    FIsPlayingByHotKey: boolean;
    FTonesPerOctave: integer;

    FRecordFile: TStringList;
    FPlayFile: TStringList;

    procedure PlaceKeys;
    procedure FillHotKeysMap;
    function GetKeyIndex(AX, AY: integer): integer;
    procedure CreateKeys;
    function SelectedWaveGenerator: TWaveGeneratorClass;
    procedure ApplySettings;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  mmsystem, Math,
  UUtils,
  UWaveUtil;

const
  FORMAT_SETTINGS: TFormatSettings = (DecimalSeparator: '.');


procedure TfrmMain.ApplySettings;
begin
  if cbGeneratorType.ItemIndex < 0 then
    Exit;

  FTonesPerOctave := edTonesPerOctave.Value;

  FKeyPlayer.Stop;
  FKeyPlayer.EthalonFreq := StrToFloat(edOrigFreq.Text, FORMAT_SETTINGS);
  FKeyPlayer.KeysPerOctave := FTonesPerOctave;
  FKeyPlayer.TonePlayer.WaveGeneratorClass := SelectedWaveGenerator;
  FKeyPlayer.TonePlayer.ObertonCount :=  edObertonCount.Value;

  CreateKeys;

  pbSoundKeys.Refresh;
end;


procedure TfrmMain.btnApplySettingsClick(Sender: TObject);
begin
  ApplySettings;
end;


procedure TfrmMain.btnPlayFileClick(Sender: TObject);
begin
  FFilePlayer.PlayFile('RecordFile.txt');
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


procedure TfrmMain.btnStartRecClick(Sender: TObject);
begin
  FRecordFile.Add('');
  tmRec.Enabled := true;
end;


procedure TfrmMain.btnStopClick(Sender: TObject);
begin
//  FPlaySoundThread.Terminate;
//  FIsPlaying := false;
end;


procedure TfrmMain.btnStopRecClick(Sender: TObject);
begin
  tmRec.Enabled := false;
  FRecordFile.SaveToFile('RecordFile.txt');
end;


procedure TfrmMain.cbKeybordStyleClick(Sender: TObject);
begin
  CreateKeys;
  pbSoundKeys.Refresh;
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

  FKeyGUIList.Clear;
  for i := 0 to FKeyInfos.Count - 1 do begin
    FKeyGUIList.Add(TKeyGUI.Create(pnKeyCaptions, i));
  end;

  PlaceKeys;

  FillHotKeysMap;
end;


procedure TfrmMain.edTonesPerOctaveExit(Sender: TObject);
begin
  FTonesPerOctave := edTonesPerOctave.Value;
  pbSoundKeys.Refresh;
end;


procedure TfrmMain.FillHotKeysMap;
const
  HOT_KEY_PAIR_MAP: array [0..11] of array [boolean] of string = (
    ('Q', '2'), ('W', '3'), ('E', '4'), ('R', '5'), ('T', '6'), ('Y', '7'),
    ('U', '8'), ('I', '9'), ('O', '0'), ('P', '-'), ('[', '='), (']', ']')
  );
var
  i: integer;
  k: integer;
  isBlack: boolean;
begin
  FHotKeysMap.Clear;

  k := -1;
  for i := 0 to FKeyInfos.Count - 1 do begin
    isBlack := cbKeybordStyle.Checked and FKeyInfos[i].IsBlack;
    if cbKeybordStyle.Checked then begin
      if not isBlack then
        Inc(k);
    end
    else
      k := i;
    if k > High(HOT_KEY_PAIR_MAP) then
      Break;

    FHotKeysMap.Add(HOT_KEY_PAIR_MAP[k, isBlack], i);
  end;
end;


procedure TfrmMain.FormCreate(Sender: TObject);
var
  genClass: TWaveGeneratorClass;
begin
  inherited;
  FKeyInfos := TList<TKeyInfo>.Create;
  FKeyGUIList := TObjectList<TKeyGUI>.Create(true);
  FHotKeysMap := TDictionary<string, integer>.Create;
  FKeyPlayer := TKeyPlayer.Create;
  FFilePlayer := TFilePlayer.Create(FKeyPlayer);
  FRecordFile := TStringList.Create;
  FPlayFile := TStringList.Create;

  for genClass in WaveGenerators do
    cbGeneratorType.Items.Add(genClass.GetCaption);
  cbGeneratorType.ItemIndex := 0;

  ApplySettings;
end;


procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FPlayFile.Free;
  FRecordFile.Free;
  FFilePlayer.Free;
  FKeyPlayer.Free;
  FHotKeysMap.Free;
  FKeyGUIList.Free;
  FKeyInfos.Free;
  inherited;
end;


procedure TfrmMain.FormKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
var
  sndKeyIdx: integer;
begin
  if ActiveControl is TCustomEdit then
    Exit;

  if FHotKeysMap.TryGetValue(Chr(Key and $7F), sndKeyIdx) then begin
    FIsPlayingByHotKey := true;
    FKeyPlayer.PlayKey(sndKeyIdx);
  end;
end;


procedure TfrmMain.FormKeyUp(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ActiveControl is TCustomEdit then
    Exit;

  FKeyPlayer.Stop;

  FIsPlayingByHotKey := false;
end;


function TfrmMain.GetKeyIndex(AX, AY: integer): integer;
var
  keyWidth: double;
begin
  Result := Trunc(AX * FTonesPerOctave / pbSoundKeys.ClientWidth);
  if
    cbKeybordStyle.Checked and InRange(Result, 0, FKeyInfos.Count - 1) and
    FKeyInfos[Result].IsBlack and (AY > pbSoundKeys.ClientHeight div 2)
  then begin
    keyWidth := pbSoundKeys.ClientWidth / FKeyInfos.Count;
    if AX <= (keyWidth * (Result + 0.5))then
      Dec(Result)
    else
      Inc(Result);
  end;
end;


procedure TfrmMain.pbSoundKeysMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FKeyPlayer.PlayKey(GetKeyIndex(X, Y));
end;


procedure TfrmMain.pbSoundKeysMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not FIsPlayingByHotKey then
    FKeyPlayer.PlayKey(GetKeyIndex(X, Y));
end;


procedure TfrmMain.pbSoundKeysMouseUp(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FKeyPlayer.Stop;
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
    for i := 0 to FKeyInfos.Count - 1 do begin
      if FKeyInfos[i].IsBlack then
        Continue;

      leftShift := 0;
      if i = 0 then begin
        if FKeyInfos.Count <= 2 then
          whiteKeyWidth := keyWidth
        else
          whiteKeyWidth := keyWidth + keyWidth / 2;
      end
      else if i = FKeyInfos.Count - 1 then begin
        if FKeyInfos.Count mod 2 = 0 then begin
          whiteKeyWidth := keyWidth;
        end
        else begin
          leftShift := keyWidth / 2;
          whiteKeyWidth := keyWidth + keyWidth / 2;
        end;
      end
      else begin
        whiteKeyWidth := keyWidth * 2;
        leftShift := keyWidth / 2;
      end;
      x := keyWidth * i - leftShift;
      canv.Rectangle(Round(x), 0, Round(x + whiteKeyWidth), keyHeightInt);
    end;
    canv.Brush.Color := clBlack;
    for i := 0 to FKeyInfos.Count - 1 do begin
      if FKeyInfos[i].IsBlack then
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


procedure TfrmMain.PlaceKeys;
var
  lblTop: integer;
  lblWidth: double;
  i: integer;
  lbl: TLabel;
begin
  if FKeyGUIList.Count <= 0 then
    Exit;

  lblTop := (pnKeyCaptions.ClientHeight - FKeyGUIList[0].Lbl.Height) div 2;
  lblWidth := pnKeyCaptions.ClientWidth / FKeyGUIList.Count;
  for i := 0 to FKeyGUIList.Count - 1 do begin
    lbl := FKeyGUIList[i].Lbl;
    lbl.Left := Round(i * lblWidth);
    lbl.Width := Round(lblWidth);
    lbl.Top := lblTop;
  end;
end;


procedure TfrmMain.pnKeyCaptionsResize(Sender: TObject);
begin
  PlaceKeys;
end;


function TfrmMain.SelectedWaveGenerator: TWaveGeneratorClass;
begin
  Result := WaveGenerators[cbGeneratorType.ItemIndex];
end;


procedure TfrmMain.tmRecTimer(Sender: TObject);
var
  keyIdxStr: string;
begin
  if FRecordFile.Count <= 0 then
    Exit;

  if FKeyPlayer.PlayingKey >= 0 then
    keyIdxStr := IntToStr(FKeyPlayer.PlayingKey)
  else
    keyIdxStr := 'X';

  FRecordFile[FRecordFile.Count - 1] :=
    JoinStrings(FRecordFile[FRecordFile.Count - 1], keyIdxStr, '-');
end;


{ TKeyGUI }

constructor TKeyGUI.Create(AContainer: TWinControl; AIndex: integer);
begin
  inherited Create;
  FLbl := TLabel.Create(AContainer);
  FLbl.Parent := AContainer;
  FLbl.AutoSize := false;
  FLbl.Alignment := taCenter;
  FLbl.Caption := '+' + IntToStr(AIndex);
end;


destructor TKeyGUI.Destroy;
begin
  FLbl.Free;
  inherited;
end;


end.
