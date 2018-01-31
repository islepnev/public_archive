unit LifeProc;

interface

uses LifeDef;

var
	ShowCell : procedure (cx, cy : Word; State : Boolean);
	CountXLAT : array[0..255] of Byte;

function Init(xs, ys : Word) : Integer;
procedure Done;
procedure Reset;
procedure Preset;
procedure NextGen;
procedure ShowField(Refresh : Boolean);
{procedure ShowCell(cx, cy : Word; State : Boolean); far;}
procedure InvOrder32(Field : PCells; xSize, ySize : Word);
{function FieldSize(xSize, ySize : Word) : Word;}
function WriteField(var F : file; Field : PCells) : Integer;
procedure ShowGraph;
function GetCellCount: Longint;
procedure CheckCellCount;
{function SaveField: Integer;}

implementation

uses
	Crt, Dos, Graph,
	CrtExt, GraphExt, IOErrDef, Math;

const
	SquareCell = True;
var
	xz, yz,                 { zoom }
	fwx,fwy,fww,fwh : Word; { window coords and sizes }

procedure Iterate; far; external; {$L LIFE.OBJ}
procedure Edges; far; external;
procedure ShowF(NewField, OldField : PCells; xSize, ySize : Word); far; external;

procedure NextGen;
begin
	Move(Field^, TempField^, FieldSize); { copy field -> temp }
	Iterate; { next generation - in temp, old - in field }
	Inc(Generation);
	Edges;
	Move(TempField^, Field^, FieldSize);
	if Generation mod GenerationStep = 0 then ShowField(False);
	CheckCellCount;
end;

procedure ShowBigCell(cx, cy : Word; State : Boolean); far; forward;
procedure ShowBarCell(cx, cy : Word; State : Boolean); far; forward;
procedure ShowPicCell(cx, cy : Word; State : Boolean); far; forward;

function Init(xs, ys : Word) : Integer;
begin
	Init := hError;
	if not Graphics then begin AET := 'Must be in graphics mode to initialize'; Exit; end;
	xSize := xs{ div 8 * 8};
	ySize := ys;
	xz := (MaxX+1) div xSize;
	yz := (MaxY+1) div ySize;
	if xz = 0 then xz := 1;
	if yz = 0 then yz := 1;
	if SquareCell then
	begin
		if xz < yz then yz := xz;
		if yz < xz then xz := yz;
	end;
	if (xz < 2) or (yz < 2)
	then @ShowCell := @ShowPicCell
	else
		if (xz > 3) and (yz > 3)
		then @ShowCell := @ShowBigCell
		else @ShowCell := @ShowBarCell;
	fwx := 0;
	fwy := 0;
	fww := (xSize-2)*xz;
	fwh := (ySize-2)*yz;
	FieldSize := (Longint(xSize)*ySize+7) div 8;
	if FieldSize > 65535 then begin AET := 'Field size exceeds 64k - cannot render'; Exit end;
	if MaxAvail < FieldSize then begin AET := NoMem; Exit end;
	GetMem(Field, FieldSize);
	if MaxAvail < FieldSize then begin AET := NoMem; Exit end;
	GetMem(TempField, FieldSize);
	if MaxAvail < FieldSize then begin AET := NoMem; Exit end;
	GetMem(OldField, FieldSize);
	if MaxAvail < FieldSize then begin AET := NoMem; Exit end;
	GetMem(FirstField, FieldSize);
	if MaxAvail < SizeOf(GGraph^) then begin AET := NoMem; Exit end;
	New(GGRaph);
	Init := hOk;
end;

procedure Done;
begin
	if OldField   <> nil then FreeMem(OldField,   FieldSize);
	if TempField  <> nil then FreeMem(TempField,  FieldSize);
	if Field      <> nil then FreeMem(Field,      FieldSize);
	if FirstField <> nil then FreeMem(FirstField, FieldSize);
	if GGraph <> nil then Dispose(GGraph);
end;

procedure Reset;
begin
	if Field      <> nil then FillChar(Field^,      FieldSize, 0);
	if TempField  <> nil then FillChar(TempField^,  FieldSize, 0);
	if OldField   <> nil then FillChar(OldField^,   FieldSize, 0);
	if FirstField <> nil then FillChar(FirstField^, FieldSize, 0);
	if GGraph     <> nil then FillChar(GGraph^, SizeOf(GGraph^), 0);
	Generation := 0;
	MaxCells := 0;
	StopLife := False;
end;

procedure Preset;
var i : Word; c, k : Byte;
{const F = 8;}
const F = 20;
begin
	Reset;
	for i := 0 to FieldSize-1 do
{	Field^[i] := Random(255);}
	begin
		c := 0;
		for k := 0 to 7 do
			if Random(F) = 0
			then c := c or 1 shl k;
		Field^[i] := c;
	end;
{	Field^[0] := 170;
	Field^[1] := 170;}
	Move(Field^, TempField^, FieldSize); { copy field -> temp }
	Iterate; { next generation - in temp, old - in field }
	Edges;
	Move(TempField^, Field^, FieldSize);
	CheckCellCount;
	Move(Field^, FirstField^, FieldSize);
end;

procedure ShowField(Refresh : Boolean);
var
	a, b, i, j, xm, ym : Word; c, o : Boolean; L : Longint;
	ViewPort: ViewPortType;
begin
	if not Graphics then Exit;
	if Field = nil then Exit;
	if OldField = nil then Exit;
	GetViewSettings(ViewPort);
	SetViewPort(fwx,fwy,fwx+fww,fwy+fwh, ClipOff);
	if not Refresh
		then ShowF(Field, OldField, xSize, ySize)
		else
	begin
		Edges;
		SetFillStyle(1, 1);
		Bar(0,0, (xSize-2)*xz-1, (ySize-2)*yz-1);
{		Bar(xz, yz, (xSize-1)*xz-1, (ySize-1)*yz-1);}
		FillChar(OldField^, FieldSize, 0);
		ShowF(Field, OldField, xSize, ySize);
	end;
	Move(Field^, OldField^, FieldSize);
	with ViewPort do SetViewPort(x1,y1,x2,y2,Clip);
end;

procedure ShowBigCell(cx, cy : Word; State : Boolean);
begin
	SetFillStyle(1, 1+Byte(State)*14);
{	Dec(cx); Dec(cy);}
	Bar(cx*xz, cy*yz, (cx+1)*xz-2, (cy+1)*yz-2);
{	PutPixel();}
end;

procedure ShowBarCell(cx, cy : Word; State : Boolean);
begin
	SetFillStyle(1, 1+Byte(State)*14);
{	Dec(cx); Dec(cy);}
	Bar(cx*xz, cy*yz, (cx+1)*xz-1, (cy+1)*yz-1);
end;

procedure ShowPicCell(cx, cy : Word; State : Boolean);
begin
	PutPixel(cx, cy, 1+Byte(State)*14);
{	PutPixel(cx*xz, cy*yz, 1+Byte(State)*14);}
end;

procedure InvOrder32(Field : PCells; xSize, ySize : Word);
var c : Word;
begin
	if Field = nil then Exit;
	for c := 0 to (FieldSize+3) div 4 do
		BackOrd(MemL[Seg(Field^):Ofs(Field^)+c*4]);
end;

function WriteField(var F : file; Field : PCells) : Integer;
begin
	WriteField := hError;
	WriteField := hOk;
end;

function CountCells(var Field : PCells) : Longint;
var i : Word; L : Longint;
begin
	L := 0;
	for i := 0 to FieldSize-1 do L := L + Longint(CountXLAT[Field^[i]]);
	CountCells := L;
end;

function GetCellCount: Longint;
begin
	GetCellCount := CountCells(Field);
end;

procedure CheckCellCount;
var c : Longint;
begin
	if GGraph = nil then Exit;
	c := CountCells(Field);
	if c > MaxCells then MaxCells := c;
	GGraph^[Generation] := c;
end;

procedure ShowGraph;
var
	x1, y1, x2, y2 : Word;
	i, x, y : Word;
begin
	if GGraph = nil then Exit;
	x1 := 1; x2 := MaxX-1;
	y1 := 1; y2 := MaxY-1;
	SetColor(LightGray);
	Rectangle(x1-1, y1-1, x2+1, y2+1);
	for i := 1 to Generation do if i mod 10 = 0 then
	begin
		x := x1+Round((x2-x1)/Generation*i);
		y := 2;
		if i mod 100 = 0 then Inc(y, 3);
		if i mod 1000 = 0 then Inc(y, 4);
		Line(x, y2, x, y2-y);
	end;
	SetColor(LightCyan);
	MoveTo(x1, y2-Round((y2-y1)/MaxCells*GGraph^[0]));
	for i := 1 to Generation do
	begin
		x := x1+Round((x2-x1)/Generation*i);
		y := y2-Round((y2-y1)/MaxCells*GGraph^[i]);
		LineTo(x, y);
	end;
end;
{
function SaveField: Integer;
const
	MinFileSize = 16384;
var
	FN: String;
	SaveWriteMode: Boolean;
	F: file;
	function WriteData: Integer;
	begin
		WriteData := hError;
		if DiskFree(0) < MinFileSize then Exit;
		WriteData := hOk;
	end;
begin
	SaveField := hError;
	GotoXY(1,1);
	TextColor(White);
	TextBackground(Black);
	SaveWriteMode := DirectVideo;
	DirectVideo := False;
	WriteLn('Save field');
	Write('Enter filename: ');
	ReadLn(FN);
	if RewriteFile(F, FN) <> hOk then Exit;
	if WriteData <> hOk then Exit;
	if CloseFile(F) <> hOk then Exit;
	DirectVideo := SaveWriteMode;
	SaveField := hOk;
end;
}

var i : Byte;

begin
	for i := 0 to 255 do
		CountXLAT[i] :=
		(i and $01)       +
		(i and $02) shr 1 +
		(i and $04) shr 2 +
		(i and $08) shr 3 +
		(i and $10) shr 4 +
		(i and $20) shr 5 +
		(i and $40) shr 6 +
		(i and $80) shr 7;
end.
