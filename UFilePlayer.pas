unit UFilePlayer;

interface

uses
  ExtCtrls, Classes, SysUtils,
  UKeyPlayer;

type
  TFilePlayer = class(TObject)
  private
    FTimer: TTimer;
    FKeyFile: TStringList;
    FKeyPlayer: TKeyPlayer;
    FPosition: integer;

    procedure OnTimer(Sender: TObject);
  public
    constructor Create(AKeyPlayer: TKeyPlayer);
    destructor Destroy; override;

    procedure PlayFile(const AFileName: string);
  end;


implementation

{ TFilePlayer }

constructor TFilePlayer.Create(AKeyPlayer: TKeyPlayer);
const
  TIMER_INTERVAL = 125;
begin
  inherited Create;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := false;
  FTimer.Interval := TIMER_INTERVAL;
  FTimer.OnTimer := OnTimer;

  FKeyFile := TStringList.Create;

  FKeyPlayer := AKeyPlayer;
end;


destructor TFilePlayer.Destroy;
begin
  FKeyFile.Free;
  FTimer.Free;
  inherited;
end;


procedure TFilePlayer.OnTimer(Sender: TObject);
var
  line: string;
  keyIdx: integer;
begin
  if FKeyFile.Count >= 0 then begin
    line := FKeyFile[FKeyFile.Count - 1];
    while (FPosition <= Length(line)) and (line[FPosition] = '-') do
      Inc(FPosition);
    if FPosition <= Length(line) then begin
      if TryStrToInt(line[FPosition], keyIdx) then
        FKeyPlayer.PlayKey(keyIdx)
      else
        FKeyPlayer.Stop;
      Inc(FPosition);
    end
    else
      FTimer.Enabled := false;
  end
  else
    FTimer.Enabled := false;
end;


procedure TFilePlayer.PlayFile(const AFileName: string);
begin
  FKeyFile.LoadFromFile(AFileName);
  if FKeyFile.Count >= 0 then begin
    FPosition := 1;
    FTimer.Enabled := true;
  end;
end;


end.
