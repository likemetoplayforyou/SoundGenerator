unit UKeyPlayer;

interface

uses
  Math,
  UTonePlayer, UWaveGenerator;

type
  TKeyPlayer = class(TObject)
  private
    FTonePlayer: TTonePlayer;
    FEthalonFreq: double;
    FKeysPerOctave: integer;
    FPlayingKey: integer;

    function CalcFrequency(AKeyIndex: integer): double;
  public
    constructor Create;
    destructor Destroy; override;

    procedure PlayKey(AKeyIndex: integer);
    procedure Stop;

    property TonePlayer: TTonePlayer read FTonePlayer;
    property PlayingKey: integer read FPlayingKey;
    property EthalonFreq: double read FEthalonFreq write FEthalonFreq;
    property KeysPerOctave: integer read FKeysPerOctave write FKeysPerOctave;
  end;


implementation

{ TKeyPlayer }

function TKeyPlayer.CalcFrequency(AKeyIndex: integer): double;
begin
  Result := FEthalonFreq * Power(2, AKeyIndex / FKeysPerOctave);
end;


constructor TKeyPlayer.Create;
begin
  inherited Create;
  FTonePlayer := TTonePlayer.Create;
  FPlayingKey := -1;
end;


destructor TKeyPlayer.Destroy;
begin
  FTonePlayer.Free;
  inherited;
end;


procedure TKeyPlayer.PlayKey(AKeyIndex: integer);
var
  keyFreq: double;
begin
  FPlayingKey := AKeyIndex;
  if InRange(AKeyIndex, 0, FKeysPerOctave - 1) then begin
    keyFreq := CalcFrequency(AKeyIndex);
    if
      not FTonePlayer.IsPlaying or (keyFreq <> FTonePlayer.Frequency)
    then begin
      Stop;
      FTonePlayer.Frequency := keyFreq;
      FTonePlayer.Start;
    end
  end
  else
    Stop;
end;


procedure TKeyPlayer.Stop;
begin
  FTonePlayer.Stop;
  FPlayingKey := -1;
end;


end.
