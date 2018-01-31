unit Timers;

interface

procedure InitTimer(AFreq : Word);
procedure DoneTimer; far;
procedure ResetTimer;
procedure StartTimer;
procedure StopTimer;
function GetTimerCount : Single; far;
function GetmTimerCount : Longint;

implementation

uses
	Dos,
	OutDev;

const
	TimerInt = $08;
var
	Time, DosTime : Single;
	mTime : Longint;
	Timer : Boolean;
	TimerFreq : Word;
	OldTimerProc : procedure;
	OldExitProc : Pointer;

procedure MyTimerInt; interrupt;
begin
{ this routine trashes FPU !!! }
{ PUSH FPU }
	if Timer then Time := Time + 1 / TimerFreq;
	DosTime := DosTime + 1 / TimerFreq;
	if DosTime > 1 / (PIT_FREQ / 65536) then
	begin
		OldTimerProc;
		DosTime := 0;
	end;
{ POP FPU }
	Port[$20] := $20;
end;

procedure InitTimer(AFreq : Word);
begin
	if AFreq < 20 then AFreq := 20;
	TimerFreq := AFreq;
	GetIntVec(TimerInt, @OldTimerProc);
	OldExitProc := ExitProc;
	ExitProc := @DoneTimer;
	SetIntVec(TimerInt, @MyTimerInt);
	SetTimerRate(Round(PIT_FREQ / TimerFreq));
	DosTime := 0;
end;

procedure DoneTimer;
begin
	SetNormalTimerRate;
{	SetupTime;}
	SetIntVec(TimerInt, @OldTimerProc);
	ExitProc := OldExitProc;
end;

procedure ResetTimer;
begin
	Time := 0;
end;

procedure StartTimer;
begin
	Timer := True;
end;

procedure StopTimer;
begin
	Timer := False;
end;

function GetTimerCount : Single;
begin
	GetTimerCount := Time;
end;

function GetmTimerCount : Longint;
begin
	GetmTimerCount := mTime;
end;

begin
end.