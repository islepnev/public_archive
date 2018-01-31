{$Q-,R-,S+,I+}

unit Mouse;

interface

uses Objects;

var MousePresent : Boolean;

const

{ InitMouse return codes }
	MouseError = 1; MouseOk = 0;

{ mouse event mask }
	MMoved          = $0001;
	MLeftPressed    = $0002;
	MLeftReleased   = $0004;
	MRightPressed   = $0008;
	MRightReleased  = $0010;
	MCenterPressed  = $0020;
	MCenterReleased = $0040;
	MAllEvents      = $00FF;

{ mouse button mask }
	MLeftButton = 1;
	MRightButton = 2;
	MCenterButton = 4;


function InitMouse : Word;
procedure ShowMouse;
procedure HideMouse;
function LeftPressed : Boolean;
function RightPressed : Boolean;
procedure MoveMouseTo(X, Y : Word);
procedure SetMouseRange(x1, y1, x2, y2 : Word);
procedure SetMouseSpeed(x, y : Word);
procedure GetLastDistance(var dx, dy : Integer);
procedure SetEventHandler(Mask : Word; ProcAddr : Pointer);
procedure ClearEventHandler;
procedure GetMouseXY(var XY : TPoint);
function GetMouseX : Word;
function GetMouseY : Word;

implementation

uses Dos, Graph;

function InitMouse : Word;
var Regs : Registers;
begin
	Regs.AX := $0;	{ reset mouse }
	Intr($33, Regs);
	InitMouse := Regs.AX;
	if (Regs.AX <> 0) or (Regs.BX = 2) or (Regs.BX = 3) then
	begin
		InitMouse := MouseOk;
		MousePresent := True;
	end
	else
	begin
		InitMouse := MouseError;
		MousePresent := False;
	end;
end;

procedure ShowMouse;
var Regs : Registers;
begin
	Regs.AX := 1;
	Intr($33, Regs);
end;

procedure HideMouse;
var Regs : Registers;
begin
	Regs.AX := 2;
	Intr($33, Regs);
end;

function LeftPressed : Boolean;
var Regs : Registers;
begin
	Regs.AX := 3;	{ query left button status }
	Intr($33, Regs);
	if (Regs.BX and 1) = 1 then LeftPressed := True else LeftPressed := False;
end;

function RightPressed : Boolean;
var Regs : Registers;
begin
	Regs.AX := 3;	{ query right button status }
	Intr($33, Regs);
	if (Regs.BX and 2) = 2 then RightPressed := True else RightPressed := False;
end;

procedure MoveMouseTo;
var Regs : Registers;
begin
	Regs.AX := 4;	{ move mouse pointer }
	Regs.CX := X;
	Regs.DX := Y;
	Intr($33,Regs);
end;

procedure SetMouseRange(x1, y1, x2, y2 : Word);
var Regs : Registers;
begin
	Regs.AX := 7;
	Regs.CX := x1;
	Regs.DX := x2;
	Intr($33,Regs);
	Regs.AX := 8;
	Regs.CX := y1;
	Regs.DX := y2;
	Intr($33,Regs);
end;

procedure SetMouseSpeed(x, y : Word);
var Regs : Registers;
begin
	Regs.AX := $f;
	Regs.CX := x; { horizontal }
	Regs.DX := y; { vertical }
	Intr($33,Regs);
end;

procedure EventHandlerDefaultProc;assembler;
asm
	retf
end;

procedure GetLastDistance(var dx, dy : Integer);
var Regs : Registers;
begin
	Regs.AX := $b;
	Intr($33,Regs);
	dx := Regs.CX; { horizontal }
	dy := Regs.DX; { vertical }
end;


procedure SetEventHandler(Mask : Word; ProcAddr : Pointer);
var Regs : Registers;
begin
	if ProcAddr = nil then Exit;
	Regs.ES := Seg(ProcAddr^);
	Regs.DX := Ofs(ProcAddr^);
	Regs.CX := Mask;
	Regs.AX := $0c;
	Intr($33, Regs);
end;

procedure ClearEventHandler;
var Regs : Registers;
begin
	Regs.ES := Seg(EventHandlerDefaultProc);
	Regs.DX := Ofs(EventHandlerDefaultProc);
	Regs.CX := 0;
	Regs.AX := $0c;
	Intr($33, Regs);
end;

function GetMouseX : Word;
var regs : Registers;
begin
  regs.ax := 3;	{ query right button status }
  intr($33,regs);
  GetMouseX := regs.cx;
end;

function GetMouseY : Word;
var regs : Registers;
begin
  regs.ax := 3;	{ query right button status }
  intr($33,regs);
  GetMouseY := regs.dx;
end;

procedure GetMouseXY(var XY : TPoint);
var regs : Registers;
begin
	regs.ax := 3;
	intr($33,regs);
	XY.X := regs.cx;
	XY.Y := regs.dx;
end;

begin
	MousePresent := False;
end.
