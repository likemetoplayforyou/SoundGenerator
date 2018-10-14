unit UWaveGenerator;

interface

uses
  Generics.Collections;

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


implementation

uses
  Math;

type
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


{ TWaveGenerator }

constructor TWaveGenerator.Create(
  ASampleRate: integer; AFrequency: double; AObertonCount: integer);
begin
  inherited Create;
  FSampleRate := ASampleRate;
  FFrequency := AFrequency;
  FObertonCount := AObertonCount;
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


initialization
  WaveGenerators := TList<TWaveGeneratorClass>.Create;

  WaveGenerators.Add(TSinGenerator);
  WaveGenerators.Add(TObertonGenerator);


finalization
  WaveGenerators.Free;


end.
