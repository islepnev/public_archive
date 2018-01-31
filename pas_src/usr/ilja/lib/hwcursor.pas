unit HWCursor;

interface

uses
	Objects, GraphExt;

var
	HWCursorActive : Boolean;

const
{ Standard Cursor Shapes }
	cs_Arrow     = 1;
	cs_Up        = 2;
	cs_Down      = 3;
	cs_Left      = 4;
	cs_Right     = 5;
	cs_UpLeft    = 6;
	cs_UpRight   = 7;
	cs_DownLeft  = 8;
	cs_DownRight = 9;
	cs_Busy      = 10;
	cs_Text      = 11;
	cs_Default   = cs_Arrow;

function TestHWCursor : Integer;
function InitHWCursor : Integer;
procedure DoneHWCursor; far;
procedure SetHWCursorShape(Shape : Word);
procedure GetHWCursorPos(var Pos : TPoint);
procedure SetHWCursorPos(Pos : TPoint);
procedure SetHWCursorColor(FG, BG : RGBColor);
procedure ShowHWCursor;
procedure HideHWCursor;

implementation

uses
	IOErrDef, Mouse, HWGraph;

var
	HWC : TPoint;
	MouseEvent : Word;
	ButtonState : Word;
	SaveHWCursorExit : Pointer;
	HWCFG, HWCBG : RGBColor;

procedure MoveCursor; far;
begin
	HWC.X := GetMouseX;
	HWC.Y := GetMouseY;
	SetHWCurPos(HWC.X, HWC.Y);
end;

procedure MouseEventHandler; far; assembler;
asm
	push	AX
	mov	AX, SEG @DATA
	mov	DS, AX
	pop	AX
	mov	MouseEvent, AX
	mov	ButtonState, BX
	call	FAR PTR MoveCursor;
	retf
end;

function TestHWCursor : Integer;
var
	CursorFound : Boolean;
	x : Byte;
begin
	TestHWCursor := hError;
	FillChar(DoTest, SizeOf(DoTest), Ord(True)); (* allow test for all chips *)
	if FindVideo <> hOk then Exit;
	if vids = 0 then
	begin
		AET := 'No video interface found';
		Exit;
	end
	else
	begin
{$IFDEF DEBUG}
		WriteLn(istr(vids)+' video interfaces found');
{$ENDIF}
	end;
{$IFDEF DEBUG}
	WriteLn('Video system:   ', ChipNam[Chip],' with '+IStr(mm)+' Kbytes');
	if SubVers <> 0 then WriteLn('Version:  '+Hex4(SubVers)+'h');
	if Name <> '' then WriteLn('Name:     '+Name);
	WriteLn('DAC:      '+DACName);
	WriteLn;
{$ENDIF}
	CursorFound := False;
	for x := 1 to vids do
	begin
		if SelectVideo(x) <> hOk then Exit;
		if features and ft_cursor > 0 then
		begin
			CursorFound := True;
			Break;
		end;
	end;
	if not CursorFound then
	begin
		AET := 'Hardware Cursor not supported by this card';
		Exit;
	end;
	TestHWCursor := hOk;
end;

function InitHWCursor : Integer;
begin
	InitHWCursor := hError;
	if HWCursorActive then Exit;
	if not Graphics then
	begin
		AET := GraphNotInit;
		Exit;
	end;
	if InitMouse <> MouseOk then
	begin
		AET := 'Mouse not present';
		Exit;
	end;

{	asm cli end;}
	SetEventHandler(MMoved, Addr(MouseEventHandler));
	SaveHWCursorExit := ExitProc;
	ExitProc := @DoneHWCursor;
{	asm sti end;}
	HWCursorActive := True;

	pixels := MaxX+1;
	lins := MaxY+1;
	case MaxC of
		15 : begin memmode := _pl4; bytes := pixels div 2 end;
		255 : begin memmode := _p8; bytes := pixels end;
		32767: begin memmode := _p15; bytes := pixels*2 end;
		65535: begin memmode := _p16; bytes := pixels*2 end;
		else Exit;
	end;
	SetMouseRange(0, 0, pixels-1{32}, lins-1{32});
	SetHWCursorShape(cs_Default);
	HWC.X := pixels div 2;
	HWC.Y := lins div 2;
	SetHWcurpos(HWC.x, HWC.y);
	SetHWcurcol(((longint(255))*256
			 +(longint(255)))*256+$ff,0);
	MoveMouseTo(HWC.x, HWC.y);
	InitHWCursor := hOk;
end;

procedure DoneHWCursor;
begin
	if not HWCursorActive then Exit;
	HideHWCursor;
	ClearEventHandler;
	HWCursorActive := False;
	ExitProc := SaveHWCursorExit;
end;

procedure SetHWCursorShape(Shape : Word);
const CurMap : cursortype =
	 (($00f81f00,$00800130,$00800130,$00800100
	  ,$00f00f00,$008c3100,$00824100,$00818100
	  ,$80800101,$40800102,$20800104,$21800184
	  ,$11800188,$11800188,$11800188,$ffffffff
	  ,$ffffffff,$11800188,$11800188,$11800188
	  ,$21800184,$20800104,$40800102,$80800101
	  ,$00818100,$00824100,$008C3100,$00f00f00
	  ,$00800100,$00800100,$00800100,$00f81f00),
	  ($00f81f00,$00800130,$00800130,$00800100
	  ,$00f00f00,$008c3100,$00824100,$00818100
	  ,$80800101,$40800102,$20800104,$21800184
	  ,$11800188,$11800188,$11800188,$ffffffff
	  ,$ffffffff,$11800188,$11800188,$11800188
	  ,$21800184,$20800104,$40800102,$80800101
	  ,$00818100,$00824100,$008C3100,$00f00f00
	  ,$00800100,$00800100,$00800100,$00f81f00));
{	 (($00f81f00,$00800130,$00800130,$00800100
	  ,$00f00f00,$008c3100,$00824100,$00818100
	  ,$80800101,$40800102,$20800104,$21800184
	  ,$11800188,$11800188,$11800188,$ffffffff
	  ,$ffffffff,$11800188,$11800188,$11800188
	  ,$21800184,$20800104,$40800102,$80800101
	  ,$00818100,$00824100,$008C3100,$00f00f00
	  ,$00800100,$00800100,$00800100,$00f81f00),
	  ($00f81f00,$00800130,$00800130,$00800100
	  ,$00f00f00,$008c3100,$00824100,$00818100
	  ,$80800101,$40800102,$20800104,$21800184
	  ,$11800188,$11800188,$11800188,$ffffffff
	  ,$ffffffff,$11800188,$11800188,$11800188
	  ,$21800184,$20800104,$40800102,$80800101
	  ,$00818100,$00824100,$008C3100,$00f00f00
	  ,$00800100,$00800100,$00800100,$00f81f00));}

begin
	if not HWCursorActive then Exit;
	case Shape of
		0:	;
		cs_Arrow : SetHWcurmap(CurMap);
	end;
	SetHWCursorColor(HWCFG, HWCBG);
end;

procedure ShowHWCursor;
begin
	if not HWCursorActive then Exit;
	HWCurOnOff(True);
end;

procedure HideHWCursor;
begin
	if not HWCursorActive then Exit;
	HWCurOnOff(False);
end;

procedure GetHWCursorPos(var Pos : TPoint);
begin
	Pos := HWC;
end;

procedure SetHWCursorPos(Pos : TPoint);
begin
	if not HWCursorActive then Exit;
	MoveMouseTo(Pos.X, Pos.Y);
	HWC := Pos;
end;

procedure SetHWCursorColor(FG, BG : RGBColor);
begin
	if not HWCursorActive then Exit;
	HWCFG := FG;
	HWCBG := BG;
	SetHWcurcol(
		((longint(FG[0]))*256+(longint(FG[1])))*256+FG[2],
		((longint(BG[0]))*256+(longint(BG[1])))*256+BG[2]);
end;

begin
	SaveHWCursorExit := nil;
	HWCursorActive := False;
	HWC.X := 0;
	HWC.Y := 0;
	MouseEvent := 0;
	ButtonState := 0;
	HWCFG := RGBWhite;
	HWCBG := RGBBlack;
end.