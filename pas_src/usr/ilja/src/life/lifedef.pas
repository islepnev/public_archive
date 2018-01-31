unit LifeDef;

interface

const
	aName = 'aLife';
	aARCH = 'i80386';
	aVer  = '0.01';

type
	PCells = ^TCells;
	TCells = array[0..65534] of Byte; { 16-bit index }
	PGGraph = ^TGGraph;
	TGGraph = array[0..16382] of Longint;

var
	XSize, YSize, CColor : Word; { Sizes of current field (+ 2) }
	FieldSize, Generation : Longint;
	Field, TempField, OldField, FirstField : PCells;
	GenerationStep : Word;
	MaxCells : Longint;
	GGraph : PGGRaph;
	StopLife : Boolean;

implementation

uses Graph;

begin
	xSize := 0;
	ySize := 0;
	CColor := LightGreen;
	FieldSize := 0;
	Generation := 0;
	Field := nil;
	TempField := nil;
	OldField := nil;
	FirstField := nil;
	GenerationStep := 1;
	MaxCells := 0;
	GGraph := nil;
	StopLife := False;
end.
