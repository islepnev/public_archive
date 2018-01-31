unit OutDev{ice};

interface

const
	NoDevice = 0;
	PCSpeaker = 1;
	Covox = 2;
	QVox = 3;

	SPEAKER_PORT = $61;
	PIT_CONTROL = $43;
	PIT_CHANNEL_0 = $40; { Timer }
{	PIT_CHANNEL_1 = $41; { Memory refresh }
	PIT_CHANNEL_2 = $42; { Speaker }
	PIT_FREQ = $1234DD;

var
	WaveDevice : Byte;

procedure SetDeviceHandler(Device : Pointer);
function GetMixingFreq : Word;
procedure SetMixingFreq(Freq : Word);
procedure SetMixerFreq;
procedure SoundOn;
procedure SoundOff;
procedure SetTimerRate(TimerCount : Word);
procedure SetNormalTimerRate;
procedure SetupTime;

implementation

uses Dos, SysInit;

var
	OldVec, NewVec : Pointer;
	MixingFreq : Word;

procedure SetDeviceHandler(Device : Pointer);
begin
	NewVec := Device;
end;

procedure SetTimerRate(TimerCount : Word);
begin
	asm cli end;
	Port[PIT_CONTROL] := 76;
	Port[PIT_CHANNEL_0] := Lo(TimerCount);
	Port[PIT_CHANNEL_0] := Hi(TimerCount);
	asm sti end;
end;

procedure SetNormalTimerRate;
begin
	asm cli end;
	Port[PIT_CONTROL] := 76;
	Port[PIT_CHANNEL_0] := 255;
	Port[PIT_CHANNEL_0] := 255;
	asm sti end;
end;

function GetMixingFreq : Word;
begin
	GetMixingFreq := MixingFreq;
end;

procedure SetMixingFreq(Freq : Word);
begin
	MixingFreq := Freq;
end;

procedure SetMixerFreq;
begin
	SetTimerRate(PIT_FREQ div MixingFreq);
end;

procedure SoundOn;
begin
	asm cli end;
	GetIntVec($08, OldVec);
	SetIntVec($08, NewVec);
	if WaveDevice = PCSpeaker then
	begin
		Port[PIT_CONTROL] := $90;
		Port[SPEAKER_PORT] := Port[SPEAKER_PORT] or 3;
	end;
	asm sti end;
	SetTimerRate(PIT_FREQ div MixingFreq);
end;

procedure SoundOff;
begin
	if WaveDevice = PCSpeaker then
	begin
		Port[SPEAKER_PORT] := Port[SPEAKER_PORT] and $FC;
		Port[PIT_CONTROL] := $B6;
	end;
	SetNormalTimerRate;
	asm cli end;
	SetIntVec($08, OldVec);
{	SetIntVec(00, Old00Vec);
	SetIntVec(13, Old13Vec);}
	SetupTime;
end;

procedure SetupTime;
const CMOS_ADDR = $70; CMOS_DATA = $71;
var Hour, Min, Sec, Day, Month, Year : Byte;
	function BCD2DEC(BCD : Byte) : Byte;
		begin BCD2DEC := (BCD div 16)*10+(BCD - BCD div 16 * 16) end;
begin
	Port[CMOS_ADDR] := $00;
	Sec := BCD2DEC(Port[CMOS_DATA]);
	Port[CMOS_ADDR] := $02;
	Min := BCD2DEC(Port[CMOS_DATA]);
	Port[CMOS_ADDR] := $04;
	Hour := BCD2DEC(Port[CMOS_DATA]);
	SetTime(Hour, Min, Sec, 00);

	Port[CMOS_ADDR] := $07;
	Day := BCD2DEC(Port[CMOS_DATA]);
	Port[CMOS_ADDR] := $08;
	Month := BCD2DEC(Port[CMOS_DATA]);
	Port[CMOS_ADDR] := $09;
	Year := BCD2DEC(Port[CMOS_DATA]);
	asm sti end;
	if Year >= 80 then SetDate(1900+Year, Month, Day)
	else SetDate(2000+Year, Month, Day)
end;

end.
