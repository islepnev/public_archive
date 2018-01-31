unit SB;

interface

{Mixing buffers}
const
	BlockLength   = 4096; { Size of digitized sound block, samples }
												{ do not set less 1024 when disk swapper used }

type
	PMixingBlock = ^TMixingBlock;
	TMixingBlock = array[0..BlockLength-1] of integer;

var
	Mixed1: Boolean;
	MixCount:Longint;
	MixingBlock  : TMixingBlock;
	PICMaskPort      : Word;
	IRQStartMask     : Byte;
	IRQStopMask      : Byte;

function InitSB : Boolean;
procedure DoneSB; far;
function ResetDSP: boolean;
procedure InitSBMixing;
function MixingOn: Boolean;
procedure DoneMixing; far;
procedure SetMixProc(MixProcAddr : Pointer);
procedure SetMixingRate(Rate : Word);
procedure SetChannels(Channels : Byte);
procedure SetFormat(Format : Byte);
procedure SetSign(Sign : Byte);
procedure StartDAC;
procedure ContinueDAC;
procedure PauseDAC;
procedure StopDAC;

implementation

uses
	Crt, Dos,
	CrtExt, Hex2Str, IOErrors, IOErrDef, MemExt, SysInit, Trace, WaveDef,
	Detect;
var
	BaseIO : Word;
	IRQ, DMA, DMA16 : Byte;
	Stereo : Boolean;
	Signed : Boolean;
	OutFormat : Byte;
	SamplingRate : Word;

	ResetPort        : Word;
	ReadPort         : Word;
	WritePort        : Word;
	PollPort         : Word;
	AckPort          : Word;

	PICRotatePort    : Word;

	DMAMaskPort      : Word;
	DMAClrPtrPort    : Word;
	DMAModePort      : Word;
	DMABaseAddrPort  : Word;
	DMACountPort     : Word;
	DMAPagePort      : Word;

	IRQIntVector     : Byte;

	DMAStartMask     : Byte;
	DMAStopMask      : Byte;
	DMAMode          : Byte;
	DMALength        : Word;

	OldIntVector     : Pointer;
	OldExitProc      : Pointer;
	OldMixExitProc   : Pointer;
	HandlerInstalled : Boolean;
	SBInited         : Boolean;
	SBDeviceOn       : Boolean;
	Mixing           : Boolean;

	DSPVersion : real;     {Contains the version of the installed DSP chip }

var
	MixProc : procedure;

{Output buffers}
type {16-bit}
	POut16Block  = ^TOut16Block;
	TOut16Block  = array[0..BlockLength-1] of integer;
	POut16Buffer = ^TOut16Buffer;
	TOut16Buffer = array[1..2] of TOut16Block;
	PDoubleOut16Buffer = ^TDoubleOut16Buffer;
	TDoubleOut16Buffer = array[1..2] of TOut16Buffer;
var
	Out16Buffer : POut16Buffer;
	D : PDoubleOut16Buffer;
var
	BlockPtr    : array[1..2] of pointer;
	CurBlockPtr : pointer;
	CurBlock:   byte;
var
	{For auto-initialized transfers (Whole buffer)}
	BufferAddr : LongInt;
	BufferPage : byte;
	BufferOfs  : word;

procedure WriteDSP(Value: byte);
begin
	repeat until (Port[WritePort] and $80) = 0;
	Port[WritePort] := Value;
end;

function ReadDSP: byte;
begin
	repeat until (Port[PollPort] and $80) <> 0;
	ReadDSP := Port[ReadPort];
end;

function ResetDSP: boolean;
var
	i: word;
begin
	Port[ResetPort] := 1;
	Delay(30);
	Port[ResetPort] := 0;
	i := 10000;
	while (ReadDSP <> $AA) and (i > 0) do Dec(i);
	if i > 0
		then ResetDSP := True
		else ResetDSP := False;
end;

procedure CopyData; assembler;
asm
	lea   si, MixingBlock         {DS:SI -> 16-bit input block           }
	les   di, [CurBlockPtr]       {ES:DI -> 16-bit output block          }
	mov   cx, BlockLength         {CX = Number of samples to copy        }

@CopySample:
	mov   ax, [si]                {Load a sample from the mixing block   }
	add   di, 2                   {Increment destination pointer         }
{	sal   ax, 5                   {Shift sample left to fill 16-bit range}
	add   si, 2                   {Increment source pointer              }
	mov   es:[di-2], ax           {Store sample in output block          }
	dec   cx                      {Process the next sample               }
	jnz   @CopySample
end;

procedure SetCurBlock(BlockNum: byte);
begin
	CurBlock := BlockNum;
	CurBlockPtr := pointer(BlockPtr[BlockNum]);
end;

procedure ToggleBlock;
begin
	if CurBlock = 1
		then SetCurBlock(2)
		else SetCurBlock(1);
end;

procedure SetMixProc(MixProcAddr : Pointer);
begin
	@MixProc := MixProcAddr;
end;

procedure DefaultMixProc;
begin
end;

procedure IntHandler; interrupt;
var
	Temp: byte;
begin
	PushExt;
	MixProc;

	CopyData;
	ToggleBlock;
	Mixed1:= True;
  Inc(MixCount);
	Temp := Port[AckPort];
	PopExt;
	Port[$A0] := $20;
	Port[$20] := $20;
end;

procedure EnableInterrupts;  InLine($FB); {STI}
procedure DisableInterrupts; InLine($FA); {CLI}

procedure InstallHandler;
begin
	DisableInterrupts;
	Port[PICMaskPort] := Port[PICMaskPort] or IRQStopMask;
	GetIntVec(IRQIntVector, OldIntVector);
	SetIntVec(IRQIntVector, @IntHandler);
	Port[PICMaskPort] := Port[PICMaskPort] and IRQStartMask;
	EnableInterrupts;
	HandlerInstalled := True;
end;

procedure UninstallHandler;
begin
	DisableInterrupts;
	Port[PICMaskPort] := Port[PICMaskPort] or IRQStopMask;
	SetIntVec(IRQIntVector, OldIntVector);
	EnableInterrupts;
	HandlerInstalled := false;
end;

procedure SetOutRate;
begin
	WriteDSP($41);        {Set digitized sound output sampling rate}
	WriteDSP(Hi(SamplingRate));
	WriteDSP(Lo(SamplingRate));
end;

var
	Val : Byte;

procedure StartDAC;
begin
	if (OutFormat <> df_16Bit) and (OutFormat <> df_8Bit) then Exit;
	case OutFormat of
		df_8Bit: DMALength := BlockLength;
		df_16Bit: DMALength := BlockLength*2;
	end;
	SetCurBlock(1);
	Port[DMAMaskPort]     := DMAStopMask;
	Port[DMAClrPtrPort]   := $00;
	Port[DMAModePort]     := DMAMode;
	Port[DMABaseAddrPort] := Lo(BufferOfs);
	Port[DMABaseAddrPort] := Hi(BufferOfs);
	Port[DMACountPort]    := Lo(DMALength-1);
	Port[DMACountPort]    := Hi(DMALength-1);
	Port[DMAPagePort]     := BufferPage;
	Port[DMAMaskPort]     := DMAStartMask;

	SetOutRate;
	Val := 0;
	case OutFormat of
		df_16Bit: Val := Val or $B6;
		df_8Bit:  Val := Val or $C6;
	end;
	WriteDSP(Val);        {DSP command : DMA Auto-Init FIFO DAC }
	Val := 0;
	if Stereo then Val := Val or $20;
	if Signed then Val := Val or $10;
	WriteDSP(Val);        {DSP mode }
	WriteDSP(Lo(BlockLength - 1)); { samples-1 }
	WriteDSP(Hi(BlockLength - 1));
	case OutFormat of
		df_16Bit: begin Val := Port[AckPort]; Port[$A0] := $20; Port[$20] := $20; end;
		df_8Bit:  begin Val := Port[AckPort]; Port[$A0] := $20; Port[$20] := $20; end;
	end;
end;

procedure StopDAC;
begin
{	WriteDSP($D3);        { Disable speaker                         }
	WriteDSP($D5);        { Halt 16-bit DMA I/O                     }
	WriteDSP($D9);        { Exit Auto-init 16-bit DMA I/O           }
	WriteDSP($D5);        { Halt 16-bit DMA I/O                     }
	Port[DMAMaskPort] := DMAStopMask;
end;

procedure PauseDAC;
begin
	WriteDSP($D5);        { Halt 16-bit DMA                        }
	Port[DMAMaskPort] := DMAStartMask;
end;

procedure ContinueDAC;
begin
	WriteDSP($D6);        { Continue 16-bit DMA                    }
	Port[DMAMaskPort] := DMAStartMask;
end;

function InitSBDevice(BaseIO: Word; IRQ, DMA, DMA16: Byte): Boolean;
begin
	InitSBDevice := False;
{Sound card IO ports}

	ResetPort  := BaseIO + $6;
	ReadPort   := BaseIO + $A;
	WritePort  := BaseIO + $C;
	PollPort   := BaseIO + $E;
{Reset DSP, get version, and pick output mode}
	if not ResetDSP then
	begin
		InitSBDevice := False;
		Exit;
	end;
	WriteDSP($E1);  {Get DSP version number}
	DSPVersion := ReadDSP;
	DSPVersion := DSPVersion + ReadDSP/100;
	if not ((DSPVersion > 4.0) and (DMA16 <> $FF) and (DMA16 > 3)) then
	begin
		AET := '16-bit output not supported by your sound card';
		Exit;
	end;
{Compute interrupt ports and parameters}
	if IRQ <= 7 then
	begin
		IRQIntVector  := $08+IRQ;
		PICMaskPort   := $21;
	end
	else
	begin
		IRQIntVector  := $70+IRQ-8;
		PICMaskPort   := $A1;
	end;
	IRQStopMask  := 1 shl (IRQ mod 8);
	IRQStartMask := not IRQStopMask;

{Compute DMA ports and parameters}
	DMAMaskPort     := $D4;
	DMAClrPtrPort   := $D8;
	DMAModePort     := $D6;
	DMABaseAddrPort := $C0 + 4*(DMA16-4);
	DMACountPort    := $C2 + 4*(DMA16-4);
	case DMA16 of
		5: DMAPagePort := $8B;
		6: DMAPagePort := $89;
		7: DMAPagePort := $8A;
	end;
	DMAStopMask  := DMA16-4 + $04;   {000001xx}
	DMAStartMask := DMA16-4 + $00;   {000000xx}
	DMAMode      := DMA16-4 + $58;   {010110xx}
	AckPort := BaseIO + $F;
	if not SBDeviceOn then
	begin
		InstallHandler;
		OldExitProc := ExitProc;
		ExitProc    := @DoneSB;
		SBDeviceOn := True;
	end;
	InitSBDevice := True;
end;

procedure ShutdownSBDevice;
begin
	if not SBDeviceOn then Exit;
	if HandlerInstalled then UninstallHandler;
	ResetDSP;
	ExitProc := OldExitProc;
	SBDeviceOn := False;
end;

function InitSB : Boolean;
begin
	if SBInited then Exit;
	InitSB := False;
{$IFDEF DEBUG}
	WriteMsg('Sound Blaster initialization');
{$ENDIF}

	if not GetSettings(BaseIO, IRQ, DMA, DMA16) then
	begin
{$IFDEF DEBUG}
		WriteResult(hError);
{$ENDIF}
		AET := 'Invalid or non-existant BLASTER environment variable';
		Exit;
	end;
	if not InitSBDevice(BaseIO, IRQ, DMA, DMA16) then
	begin
{$IFDEF DEBUG}
		WriteResult(hError);
{$ENDIF}
		AET := 'Error initializing Sound Blaster';
		Exit;
	end;
{$IFDEF DEBUG}
	WriteResult(hOk);
	writeln('BaseIO=', HexW(BaseIO), 'h    IRQ', IRQ, '    DMA8=', DMA, '    DMA16=', DMA16);
	writeln('DSP version ', DSPVersion:0:2);
{$ENDIF}
	SBInited := True;
	InitSB := True;
end;

procedure DoneSB;
begin
	if not SBInited then Exit;
{$IFDEF DEBUG}
	WriteMsg('Sound Blaster shutdown');
{$ENDIF}
	StopDAC;
	ShutdownSBDevice;
{$IFDEF DEBUG}
	WriteResult(hOk);
{$ENDIF}
end;

function GetLinearAddr(Ptr: pointer): LongInt;
begin
	GetLinearAddr := LongInt(Seg(Ptr^))*16 + LongInt(Ofs(Ptr^));
end;

function NormalizePtr(p: pointer): pointer;
var
	LinearAddr: LongInt;
begin
	LinearAddr := GetLinearAddr(p);
	NormalizePtr := Ptr(LinearAddr div 16, LinearAddr mod 16);
end;

procedure InitSBMixing;
var
	i: Integer;
	P1, P2: POut16Buffer;
begin
	if not SBInited then Exit;
	if Mixing then Exit;
{$IFDEF DEBUG}
	WriteMsg('Mixer initialization');
{$ENDIF}
	if MaxFree < SizeOf(TDoubleOut16Buffer) then Exit;
{Find a block of memory that does not cross a page boundary - DMA restriction}
	New(D); { get double size buffer }
	P1 := @D^[1];
	P2 := @D^[2];
	if (GetLinearAddr(D) shr 16) = ((GetLinearAddr(D)+SizeOf(TOut16Buffer)-1) shr 16)
	then Out16Buffer := P1
	else Out16Buffer := P2;
	for i := 1 to 2 do
		BlockPtr[i] := NormalizePtr(Addr(Out16Buffer^[i]));
{DMA parameters}
	BufferAddr := GetLinearAddr(pointer(Out16Buffer));
	BufferPage := BufferAddr div 65536;
	BufferOfs  := (BufferAddr div 2) mod 65536;
{ initialization }
	FillChar(Out16Buffer^, SizeOf(TOut16Buffer), $00);   {Signed   16-bit}
	FillChar(MixingBlock, SizeOf(TMixingBlock), $00);
	MixCount := 0;
	StartDAC;
	Mixing := True;
{$IFDEF DEBUG}
	WriteResult(hOk);
{$ENDIF}
	OldMixExitProc := ExitProc;
	ExitProc := @DoneMixing;
end;

function MixingOn: Boolean;
begin
	MixingOn := Mixing;
end;

procedure DoneMixing;
begin
	if not SBInited then Exit;
	if not Mixing then Exit;
{$IFDEF DEBUG}
	WriteMsg('Mixer shutdown');
{$ENDIF}
	StopDAC;
	Mixing := False;
	Dispose(D); D := nil;
{$IFDEF DEBUG}
	WriteResult(hOk);
{$ENDIF}
	ExitProc := OldMixExitProc;
end;

procedure SetMixingRate(Rate : Word);
begin
	if Rate < 5000 then Rate := 5000;
	if Rate > 48000 then Rate := 48000;
	SamplingRate := Rate;
	SetOutRate;
end;

procedure SetChannels(Channels : Byte);
begin
	if Channels = 2 then Stereo := True else Stereo := False;
end;

procedure SetFormat(Format : Byte);
begin
	OutFormat := Format;
end;

procedure SetSign(Sign : Byte);
begin
	if Sign = df_Unsigned then Signed := False else Signed := True;
end;

begin
	SBInited := False;
	OldExitProc := nil;
	OldMixExitProc := nil;
	SamplingRate := 45454;
	Stereo := False;
	OutFormat := 0;
	@MixProc := @DefaultMixProc;
	Mixing := False;
	SBDeviceOn := False;
	Mixed1:= False;
	MixCount := 0;
end.