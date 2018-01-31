unit Timer;

interface

procedure StartTimer;
procedure StopTimer;
{procedure ResetTimer;}
function GetTimerCount : Longint;
function Clock: Longint; { milliseconds }

implementation

{$IFDEF __TMT__}
uses ZenTimer;

procedure StartTimer;
begin
	ULZTimerOn;
end;
procedure StopTimer;
begin
	ULZTimerOff;
end;
function GetTimerCount : Longint;
begin
	GetTimerCount := Round(ULZTimerResolution*ULZTimerCount);
end;
function Clock : Longint;
begin
	Clock := Round(ULZTimerResolution*ULZReadTime);
end;
begin
{$ELSE}

uses Time;

var
	_Time, Start, Passed, RunDays : Longint;
	TimerOn : Boolean;
	Savetime : Longint;

	function Clock: Longint;
	var l : Longint;
	begin
		l := Time.Clock;
		if l < savetime then begin savetime := l; Inc(RunDays); end; {24h hack}
		Clock := l+86400000*RunDays;
	end;

	procedure StartTimer;
	begin
		if TimerOn then Exit;
		TimerOn := True;
		Start := Clock;
	end;

	procedure StopTimer;
	begin
		if not TimerOn then Exit;
		TimerOn := False;
		_Time := Clock{ReadTimer} - Start + Passed;
		Passed := _Time;
	end;

	procedure ResetTimer;
	begin
		_Time := 0;
		Start := 0;
		Passed := 0;
		TimerOn := False;
	end;

	function GetTimerCount;
	begin
		if TimerOn then _Time := Clock - Start + Passed;

		GetTimerCount := _Time;
	end;

begin
	SaveTime := Time.Clock;
	RunDays := 0;
{$ENDIF}
end.