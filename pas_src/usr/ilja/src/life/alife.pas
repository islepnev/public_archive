{$DEFINE Graphics}
uses
	Crt, Dos, Graph,
	CrtExt, GraphExt, INIFile, IOErrors, IOErrDef, Timer,
	LifeDef, LifeProc, Mesgs;

const
	cfname = 'alife.ini';

procedure WriteStats;
var Time: Single;
begin
	Time := GetTimerCount;
	WriteLn('Field:            ', xSize-2, 'x', ySize-2, '   ', Longint(xSize-2)*(ySize-2), ' cells');
	WriteLn('Average filling:  ', GetCellCount/(Longint(xSize-2)*(ySize-2))*100:3:3,'%');
	WriteLn('Generation:       ', Generation);
	WriteLn('Time:             ', Time/1000:3:2, ' sec');
	if Time > 1 then
	begin
		WriteLn('Generations/sec:  ',
			Generation/(Time/1000):1:4,{ ' ñ ',
			Generation/Time/Time/18.2:1:4,} ' Gen/sec');
		WriteLn('Absolute speed:   ',
			Generation*xSize*ySize/1e3/Time:1:5,{ ' ñ ',
			Generation*xSize*ySize/Time/Time/1e6/18.2:1:5,}
			' Mcells/sec');
	end;
	WriteLn;
	WriteLn('Geometry: toroidal');
end;

procedure Statistics;
begin
	Header;
	WriteLn('Statistics');
	WriteLn;
	WriteStats;
	WriteLn;
	WriteLn('Press any key to continue');
end;

procedure key_About;
begin
	if Graphics then
	begin
		StopTimer;
		SimpleDialog(@mesg_About);
		StartTimer;
	end;
end;

procedure key_Help;
begin
	if Graphics then
	begin
		StopTimer;
		SimpleDialog(@mesg_Help);
		StartTimer;
	end;
end;

var
	pConf: PIniStruct;
	Tval : TINIValue;
	i,Code: Integer;
	f_wid,f_hei : Word;
	cf: String;
begin
	Randomize;
	TextColor(LightGray);
	TextBackground(Black);
	ClrScr;
	Header;
{	f_wid := 1024;
	f_hei := 768;}
	f_wid := 640;
	f_hei := 480;
{	if FileExist(cfname) then}
	begin
		Write('Reading configuration from file ''',cfname,'''...');
		ReadINIFile(cfname,pConf);
		Tval := GetINIParamValue(pConf,'Main','sizex');
		if Tval = 'auto' then f_wid := 0 else Val(Tval,i,Code);
		if (i >= 3) and (i <= 1024) and (Code = 0) then f_wid := i;
		Tval := GetINIParamValue(pConf,'Main','sizey');
		if Tval = 'auto' then f_hei := 0 else Val(Tval,i,Code);
		if (i >= 3) and (i <= 1024) and (Code = 0)  then f_hei := i;
		if Longint(f_wid)*Longint(f_hei) > 524288 then begin
			WriteLn('');
			Write('Field exceeds 64k');
			f_wid := 0; f_hei := 0;
		end;
		WriteLn;
	end;
{	else
	begin
		WriteLn('Configuration file ''',cfname,''' not found');
	end;}
	if (f_wid = 0) and (f_hei = 0) then WriteLn('Auto-sizing field');
	InitGraphics;
	if (f_wid = 0) and (f_hei = 0) then { auto-size }
	begin
		if (MaxX+1) > 800 then f_wid := 800 else f_wid := MaxX+1;
		if (MaxY+1) > 600 then f_hei := 600 else f_hei := MaxY+1;
	end;
{	f_wid := 100; f_hei := 75;}
	if Init(f_wid+2, f_hei+2) <> hOk then Error;
{	if Init(2*128, 2*96) <> hOk then Error;}
{	if Init((MaxX+1) div 1, (MaxY+1) div 1) <> hOk then Error;}
{	if Init(MaxX+1,MaxY+1) <> hOk then Error;}
{	if Init(3,3) <> hOk then Error;}
{	if Init(256,256) <> hOk then Error;}
{	if Init(512,512) <> hOk then Error;}
{	if Init(800,600) <> hOk then Error;}
{	if Init(400,300) <> hOk then Error;}
{	if Init(724,724) <> hOk then Error;}
	Preset;
	ShowField(True);
	ResetTimer;
	StartTimer;
{	GenerationStep := 2;}
	while True do
	begin
		if not KeyBuffEmpty then
		begin
			Reading;
			if SpecialKey then
			case Key of
				 F1Key: key_Help;
			end
			else
			case Key of
				'/' : if GenerationStep > 1 then GenerationStep := GenerationStep div 2;
				'*' : if GenerationStep < 32 then GenerationStep := GenerationStep * 2;
				ESCKey : Break;
				'A','a':key_About;
				'H','h':key_Help;
				'C','c': begin
					StopLife := False;
				end;
				'F','f':
					begin
						StopTimer;
						if Graphics then ClearDevice;
						ShowField(True);
						StartTimer;
					end;
				'S','s':
					begin
						StopTimer;
						if Graphics then ClearDevice;
{						if SaveField <> hOk then Error;}
						if Graphics then ClearDevice;
						ShowField(True);
						StartTimer;
					end;
				'F','f' :
					begin
						StopLife := False;
						StartTimer;
					end;
				'N','n' :
					begin
						if Graphics then ClearDevice;
						Preset;
						ShowField(True);
						StopLife := False;
						ResetTimer;
						StartTimer;
					end;
				'R','r' :
					begin
						Move(FirstField^, Field^, FieldSize);
						Generation := 0;
						CheckCellCount;
						ShowField(True);
						StopLife := False;
						ResetTimer;
						StartTimer;
					end;
				'G','g' : if Graphics then
					begin
						StopTimer;
						ClearDevice;
						ShowGraph;
						ReadKey;
						ClearDevice;
						ShowField(True);
						StartTimer;
					end;
				'X','x' : if Graphics then
					begin
						StopTimer;
						ClearDevice;
						ShowField(True);
						StartTimer;
					end;
				'I','i' : if Graphics then
					begin
						StopTimer;
						ClearDevice;
						DirectVideo := False;
						GotoXY(1, 1);
						Statistics;
						DirectVideo := True;
						ReadKey;
						ClearDevice;
						ShowField(True);
						StartTimer;
					end;
			end;
		end;
{		if i mod 16 = 0 then ShowField(Field, xSize, ySize);}
{		Delay(20);}
		if not Graphics then
		begin
			GotoXY(1, WhereY); ClrEol;
			Write('Time: ', GetTimerCount/1000:5, '     Generation: ', Generation:4);
			if GetTimerCount > 1 then
				Write('     Abs speed: ', Generation*xSize*ySize/1e3/GetTimerCount:6:5);
		end;
		if not StopLife then begin NextGen; Delay(100); end;
		if (Generation > 10) and
			(GGraph^[Generation-1] = GGraph^[Generation-3]) and
			(GGraph^[Generation-1] = GGraph^[Generation-5]) and
			(GGraph^[Generation-1] = GGraph^[Generation-7]) and
			(GGraph^[Generation] = GGraph^[Generation-2]) and
			(GGraph^[Generation] = GGraph^[Generation-4]) and
			(GGraph^[Generation] = GGraph^[Generation-6]) then
			begin
				StopLife := True;
				StopTimer;
			end;
{		DirectVideo := False;
		GotoXY(1, 25); TextColor(White);
		Write('Cells: ', CountCells(Field));}
	end;
	DoneGraphics;
	WriteStats;
	Done;
end.