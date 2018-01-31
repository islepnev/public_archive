unit GrPlot;
interface

{ 'af' must be pointer to function(Real): Real; far; }
procedure DrawGraphMinMaxPtTxt(af: pointer; xmin,xmax: Real; steps: Word; Title: String);
procedure DrawGraphMinMaxTxt(af: pointer; xmin,xmax: Real; Title: String);

implementation

uses Graph;

procedure DrawGraphMinMaxPtTxt(af: pointer; xmin,xmax: Real; steps: Word; Title: String);
var
	ymin,ymax,xz,yz:Real;
	xsize,ysize,xorg,yorg,hd,vd,vt,x,y,x1,y1:Word;
	i: Word;
	S: String;
	l: Longint;
	f: function(t: Real): Real;
	procedure MakeCoords(i:Real);
	begin
		x := Round(xsize/(xmax-xmin)*(i-xmin));
		y := ysize-Round(ysize/(ymax-ymin)*(f(i)-ymin));
	end;
begin
	ClearDevice;
	SetTextStyle(SmallFont,HorizDir,6);
	@f := af;
	steps := Round(steps/(xmax-xmin));
	ymin := 1e38;
	ymax := -1e38;
	for l := Round(xmin*steps) to Round(xmax*steps) do
	begin
		if f(l/steps) > ymax then ymax := f(l/steps);
		if f(l/steps) < ymin then ymin := f(l/steps);
	end;
{	vt := 1;}

{	ymax := Trunc(ymax+1);
	ymin := Trunc(ymin);}
{	ymin := Trunc(ymin) div vt * vt;}
{	ymax := Trunc(ymin)+Round(ymax-ymin+(vt-1)) div vt * vt;}
{	ymax := Trunc(ymax+(vt-1)) div vt * vt;}
{	rmin := 0;
	tmin := -273;}
	vd := 20;
	hd := 16;
	xorg := 120;
	yorg := 20;
	xsize := GetMaxX - 2*xorg;
	ysize := GetMaxY - 2*yorg;
	xz := (xmax-xmin)*xsize;
	yz := (ymax-ymin)*ysize;
	SetLineStyle(DottedLn,1,NormWidth);
	SetColor(LightGray);
	SetViewPort(xorg,yorg,xorg+xsize,yorg+ysize,ClipOff);
	SetTextJustify(CenterText, TopText);
	for i := 0 to hd do
	begin
		x := Round(xsize/hd*i);
		Line(x,0,x,ysize);
		Str((xmin+(xmax-xmin)/hd*i):1:1, S);
		OutTextXY(x,ysize+3,S);
	end;
	SetTextJustify(RightText, CenterText);
	for i := 0 to vd do
	begin
		y := ysize-Round(ysize/vd*i);
		Line(0,Round(ysize/vd*i),xsize,Round(ysize/vd*i));
		Str((ymin+(ymax-ymin)/vd*i):1:2, S);
		OutTextXY(-3,y,S);
	end;
	SetTextJustify(CenterText, TopText);
	SetColor(LightRed);
	OutTextXY(xsize div 2,-Round(TextHeight(Title)*1.2)-2,Title);
{	Line(0,ysize,xsize,0);}
{	SetLineStyle(SolidLn,1,ThickWidth); }
	SetLineStyle(SolidLn,1,NormWidth);
	SetColor(LightGreen);
	MakeCoords(xmin);
	x1 := x; y1 := y;
	for l := Round(xmin*steps) to Round(xmax*steps) do
	begin
		MakeCoords(l/steps);
{		SetColor(LightGreen);
		SetFillStyle(1,LightGreen);
		PieSlice(x,y,0,360,1);}
		SetColor(LightBlue);
		Line(x1,y1,x,y);
{		PutPixel(x,y,LightBlue);}
		x1 := x; y1 := y;
	end;
end;

procedure DrawGraphMinMaxTxt(af: pointer; xmin,xmax: Real; Title: String);
begin
	DrawGraphMinMaxPtTxt(af,xmin,xmax, 100, Title);
end;
end.