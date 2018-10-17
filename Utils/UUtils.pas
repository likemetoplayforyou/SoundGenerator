unit UUtils;

interface

uses
  Classes;

  function JoinStrings(const ASource, AAdditionStr, ASep: string): string;
  function CreateSharedStreamWriter(
    const AFileName: string; AAppend: boolean): TStreamWriter;

implementation

uses
  SysUtils;


type
  TStreamWriterEx = class(TStreamWriter)
  private
    FStream: TStream;
  public
    constructor Create(const AFileName: string; AAppend: boolean);
    destructor Destroy; override;
  end;


function JoinStrings(const ASource, AAdditionStr, ASep: string): string;
begin
  if (ASource <> '') and (AAdditionStr <> '') then
    Result := ASource + ASep + AAdditionStr
  else
    Result := ASource + AAdditionStr;
end;


function CreateSharedStreamWriter(
  const AFileName: string; AAppend: boolean): TStreamWriter;
begin
  if not FileExists(AFileName) then
    TFileStream.Create(AFileName, fmCreate).Free;

  Result := TStreamWriterEx.Create(AFileName, AAppend);
end;


{ TStreamWriterEx }

constructor TStreamWriterEx.Create(const AFileName: string; AAppend: boolean);
begin
  FStream := TFileStream.Create(AFileName, fmOpenWrite or fmShareDenyWrite);
  if AAppend then
    FStream.Seek(0, soEnd);
  inherited Create(FStream);
end;


destructor TStreamWriterEx.Destroy;
begin
  inherited;
  FStream.Free;
end;


end.
