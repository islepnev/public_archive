unit Timerf;

interface

procedure StartTimer;
procedure StopTimer;
procedure ResetTimer;
function GetTimerCount : Single;

implementation

uses CrtExt, Time;


var
	_Time, Start, Passed : Longint;
	TimerOn : Boolean;

(*	function ReadTimer: Longint;
	begin
		ReadTimer := Round(1000*GetSeconds);
	end;
	*)
	procedure StartTimer;
	begin
		TimerOn := True;
		Start := Clock{ReadTimer};
	end;

	procedure StopTimer;
	begin
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

	function GetTimerCount : Single;
	begin
		if TimerOn then _Time := Clock{ReadTimer} - Start + Passed;
{		GetTimerCount := ElapsedTime(0, Time)/1000;}
		GetTimerCount := _Time/1000;
	end;

end.
