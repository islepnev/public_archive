uses
	Dos, Graph, Crt,
	GraphExt, IOErrors, BMPLib, IOErrDef;

function Save(FileName: String): Integer;
var PI : TInfo;
begin
	FillChar(PI, SizeOf(PI), 0);
	PI.biWidth := MaxX+1;
	PI.biHeight := MaxY+1;
	PI.biCompression := BI_RGB;
	case MaxC of
		255: PI.biBitCount := 8;
		else Error;
	end;
	Save := SaveBMP(FileName, PI, 0, 0);
end;

procedure Load(FileName: String);
begin
	LoadBMP(FileName, 0, 0, (MaxX+1), (MaxY+1), False);
end;

procedure SetPal;
var
	MyPal: DACPalette256;
	i: Byte;
begin
	for i := 0 to 255 do
	begin
		MyPal[i][0] := i shr 2;
		MyPal[i][1] := i shr 2;
		MyPal[i][2] := i shr 2;
	end;
	SetVGAPalette256(MyPal);
end;


procedure TestPic;
var i,j,x,y,xd : Longint;
begin
	xd := (MaxX+1) div MaxC;
	for i := 0 to MaxC do
	begin
		SetFillStyle(1, i);
		Bar(Round(i*(MaxX+1)/MaxC),0,Round((i+1)*(MaxX+1)/MaxC),MaxY);
	end;
	for i := 0 to 100 do
	begin
		x := Random(MaxX-32);
		y := Random(MaxY-32);
		SetFillStyle(1, Random(MaxC));
		Bar(x,y,x+31,y+31);
		for j := 0 to 10 do
			PutPixel(Random(MaxX), Random(MaxY), Random(MaxC));
	end;
end;

begin
	InitGraphics;
{	SetPal;}
	TestPic;
	if Save('pic00001.bmp') <> hOk then Error;
	ReadKey;
	ClearDevice;
	Load('pic00001.bmp');
	ReadKey;
	DoneGraphics;
end.