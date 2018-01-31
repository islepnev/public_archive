{$R+,Q+,I+,S+}
unit menu;
interface
uses Crt, Graph, CrtExt, Mouse;
const
	MenuMaxWidth = 32; MenuMaxHeight = 20;
	MaxAllowedColor = 248;
	MenuActiveBarColor  = 255;	MenuPassiveBarColor = 254;
	MenuActiveTextColor = 253;	MenuPassiveTextColor = 252;
	MenuKeyColor = 251;
	ToolBoxActiveColor = 250; ToolBoxPassiveColor = 249;
type StatType = (Act, Pass, ActSel, PassSel);
	MenuType =
	record
		X, Y, MW, Num, Current : Word;
		Item : array[1..MenuMaxHeight] of string[MenuMaxWidth];
		St : array[1..MenuMaxHeight] of StatType;
		BMP : Pointer;
	end;
procedure MLine(Menu : MenuType; Ln : Word);
procedure ClearMenu(Menu : MenuType);
procedure RestoreMenu(var Menu : MenuType);
procedure Select(var Menu : MenuType);
implementation
{---------------------------------------------------------------------}
Procedure MLine;
begin
	HideMouse;
	SetTextStyle(DefaultFont, HorizDir, 1);
	SetWriteMode(NormalPut);
	with Menu do
	begin
		if St[Ln] = ActSel  then SetFillStyle(1, MenuActiveBarColor);
		if St[Ln] = Act     then SetFillStyle(1, MenuActiveBarColor);
		if St[Ln] = PassSel then SetFillStyle(1, MenuPassiveBarColor);
		if St[Ln] = Pass    then SetFillStyle(1, MenuPassiveBarColor);
		Bar(X, Y + (Ln-1) * 16, X + MW, Y + Ln*16-1);
		if St[Ln] = ActSel  then SetColor(MenuActiveTextColor);
		if St[Ln] = Act     then SetColor(MenuActiveTextColor);
		if St[Ln] = PassSel then SetColor(MenuPassiveTextColor);
		if St[Ln] = Pass    then SetColor(MenuPassiveTextColor);
		SetLineStyle(SolidLn, 0, NormWidth);
		Rectangle(X, Y + (Ln-1) * 16, X + MW, Y + Ln*16{-1});
		if St[Ln] = ActSel  then SetColor(MenuActiveTextColor);
		if St[Ln] = Act     then SetColor(MenuActiveTextColor);
		if St[Ln] = PassSel then SetColor(MenuPassiveTextColor);
		if St[Ln] = Pass    then SetColor(MenuPassiveTextColor);
		OutTextXY(X + 16, Y + (Ln-1) * 16 + 4, Item[Ln]);
		SetColor(MenuKeyColor);
		OutTextXY(X + 16, Y + (Ln-1) * 16 + 4, Item[Ln, 1]);
	end;
	ShowMouse;
end;
{---------------------------------------------------------------------}
Procedure ClearMenu;
var MH : Word;
begin
	HideMouse;
	SetFillStyle(1, 0);
	with Menu do
	begin
		PutImage(X-2, Y-2, BMP^, NormalPut);
		MH := Num * 16;
		FreeMem(BMP, ImageSize(0, 0, MW+4, MH+4));
	end;
	ShowMouse;
end;
{---------------------------------------------------------------------}
Procedure RestoreMenu;
var
	Q, MH, IS : Word;
begin
	HideMouse;
	with Menu do
	begin
		MH := Num * 16;
		IS := ImageSize(0, 0, MW+4, MH+4);
		if MaxAvail <= IS then
		begin
      	TextMode(LastMode);
         WriteLn;
         WriteLn('No enough memory to menu operation.');
			Halt;
      end;
		GetMem(BMP, IS);
		GetImage(X-2, Y-2, X+MW+2, Y+MH+2, BMP^);
		SetColor(MenuActiveTextColor);
		SetLineStyle(SolidLn, 0, NormWidth);
		SetWriteMode(NormalPut);
		Rectangle(X-2,Y-2,X+MW+2,Y+MH+1);
		Rectangle(X-1,Y-1,X+MW+1,Y+MH);
		for q := 1 to Num do MLine(Menu, q);
	end;
	ShowMouse;
end;
{---------------------------------------------------------------------}
Procedure Select;
var eoj : Boolean;
	tx, ty, Dy : Integer;
	i : Word;
const MStep = 8;
{......................................................................}
Procedure Incr;
begin
	with Menu do
	if Current < Num then
	begin
		if St[Current] = Act then St[Current] := Pass;
		if St[Current] = ActSel then St[Current] := PassSel;
		MLine(Menu, Current);
		Inc(Current);
		if St[Current] = Pass then St[Current] := Act;
		if St[Current] = PassSel then St[Current] := ActSel;
		MLine(Menu, Current);
	end;
end;
{......................................................................}
Procedure Decr;
begin
	with Menu do
	if Current > 1 then
	begin
		if St[Current] = Act then St[Current] := Pass;
		if St[Current] = ActSel then St[Current] := PassSel;
		MLine(Menu, Current);
		Dec(Current);
		if St[Current] = Pass then St[Current] := Act;
		if St[Current] = PassSel then St[Current] := ActSel;
		MLine(Menu, Current);
	end;
end;
{......................................................................}
Procedure Sets(C : Word);
begin
	with Menu do
	begin
		if St[Current] = Act then St[Current] := Pass;
		if St[Current] = ActSel then St[Current] := PassSel;
		MLine(Menu, Current);
		Current := C;
		if St[Current] = Pass then St[Current] := Act;
		if St[Current] = PassSel then St[Current] := ActSel;
		MLine(Menu, Current);
	end;
end;
{......................................................................}
begin
	eoj := False;
	while LeftPressed do;
	with Menu do
	while not eoj do
	begin
		while (not KeyPressed) and (not eoj) do
		begin
			tx := GetMouseX; ty := GetMouseY;
			if (tx < 0) or (tx > 1280) then Continue;
			if (ty < 0) or (ty > 1024) then Continue;
			if RightPressed then begin while RightPressed do; Inc(Current,128); eoj := True; Break end;
			if LeftPressed then
			if (tX > X) and (tx < X + MW) and (tY > Y) and (tY < Y + Num * 16) then
			begin
				Sets((tY - Y) div 16 + 1);
				while LeftPressed do;
				eoj := True
			end;
		end;
		if eoj then Break;
		Reading;
		if not SpecialKey then
		case Key of
			#13 : begin eoj := True end;
			#27 : begin Inc(Current, 128); eoj := True end;
			'a'..'z','A'..'Z' :
			begin
				for i := 1 to Num do if UpCase(Item[i, 1]) = UpCase(Key) then
					begin Sets(i); eoj := True end;
			end
		end
		else
		case Key Of
			UpKey : Decr;
			DownKey : Incr;
		end;
	end;
end;

begin
end.