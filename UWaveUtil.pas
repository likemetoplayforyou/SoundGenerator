unit UWaveUtil;

interface

uses
  mmsystem;

type
  TDataInfo = record
    Data: pointer;
    ItemSize: byte;
    Length: cardinal;
  end;


  TWaveOut = class(TObject)
  private
    type
      TBufferInfo = record
        Header: TWAVEHDR;
        Data: PAnsiChar;
      end;

    const
      //BLOCK_SIZE = 1024 * 32;
      BLOCK_SIZE = 1024 * 4;
  private
    FBufferCount: integer;
    FBuffers: array of TBufferInfo;
    FSampleSize: integer;
    FHandle: HWAVEOUT;
    FEvent: THandle;

    function GetBuffer(AIndex: integer): TDataInfo;
  public
    constructor Create;

    function Open(
      AChannels, ASamplesPerSec, ABitsPerSample: integer;
      ABufferCount: integer): boolean;
    procedure Close;

    procedure PlayBuffer(AIndex: integer);

    property Buffers[AIndex: integer]: TDataInfo read GetBuffer;
  end;


implementation

uses
  Windows;

{ TWaveOut }

procedure TWaveOut.Close;
var
  i: integer;
begin
  waveOutReset(FHandle);
  for i := 0 to FBufferCount - 1 do
    waveOutUnprepareHeader(FHandle, @FBuffers[i].Header, SizeOf(TWAVEHDR));
  VirtualFree(FBuffers[0].Data, 0, MEM_RELEASE);
  waveOutClose(FHandle);
  CloseHandle(FEvent);
end;


constructor TWaveOut.Create;
begin
  inherited Create;
end;


function TWaveOut.GetBuffer(AIndex: integer): TDataInfo;
begin
  Result.Data := FBuffers[AIndex].Data;
  Result.ItemSize := FSampleSize;
  Result.Length := BLOCK_SIZE div FSampleSize;
end;


function TWaveOut.Open(
  AChannels, ASamplesPerSec, ABitsPerSample, ABufferCount: integer): boolean;
var
  wfx: TWAVEFORMATEX;
  si: TSYSTEMINFO;
  pgSize: integer;
  planSize: integer;
  allocSize: integer;
  buffersPtr: PAnsiChar;
  i: integer;
begin
  Result := false;

  Assert(ABufferCount > 0);
  FBufferCount := ABufferCount;
  SetLength(FBuffers, FBufferCount);
  FSampleSize := ABitsPerSample div 8;

  FillChar(wfx, SizeOf(TWAVEFORMATEX), #0);
  wfx.wFormatTag := WAVE_FORMAT_PCM;
  wfx.nChannels := AChannels;
  wfx.nSamplesPerSec := ASamplesPerSec;
  wfx.wBitsPerSample := ABitsPerSample;
  wfx.nBlockAlign := wfx.wBitsPerSample div 8 * wfx.nChannels;
  wfx.nAvgBytesPerSec := wfx.nSamplesPerSec * wfx.nBlockAlign;
  wfx.cbSize := 0;

  FEvent := CreateEvent(nil, false, false, nil);
  if
    waveOutOpen(@FHandle, 0, @wfx, FEvent, 0, CALLBACK_EVENT) <>
      MMSYSERR_NOERROR
  then begin
    CloseHandle(FEvent);
    Exit;
  end;

  GetSystemInfo(si);
  pgSize := si.dwPageSize;
  planSize := FBufferCount * BLOCK_SIZE;// * wfx.nChannels;
  allocSize := (planSize + pgSize - 1) div pgSize * pgSize;
  buffersPtr :=
    VirtualAlloc(nil, allocSize, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);
  for i := 0 to FBufferCount - 1 do
    FBuffers[i].Data := PAnsiChar(LongInt(buffersPtr) + BLOCK_SIZE * i);

  for i := 0 to FBufferCount - 1 do begin
    FillChar(FBuffers[i].Header, SizeOf(TWAVEHDR), #0);
    FBuffers[i].Header.lpData := FBuffers[i].Data;
    FBuffers[i].Header.dwBufferLength := BLOCK_SIZE;
    waveOutPrepareHeader(FHandle, @FBuffers[i].Header, SizeOf(TWAVEHDR))
  end;

  Result := true;
end;


procedure TWaveOut.PlayBuffer(AIndex: integer);
begin
  waveOutWrite(FHandle, @FBuffers[AIndex].Header, SizeOf(TWAVEHDR));
  WaitForSingleObject(FEvent, INFINITE);
end;


end.
