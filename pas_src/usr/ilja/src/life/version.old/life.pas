 {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ~                              L I F E                             ~
  ~           Version   3.25  of   January   1995.                   ~
  ~           Created   by   Slepnev   Ilja                          ~
  ~           Dubna, Russia.                                         ~
  ~                                                                  ~
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{$R-}
uses
	Crt,
	CrtExt,
	Graph,
	GraphExt,
	Dos,
	IOErrDef,
	LifeProc,
	Mouse,
	Sound;
var
	ButtonOld, ButtonNow, HButtonOld, HButtonNow, EndCalc,
	HelpButtonOld, HelpButtonNow : Boolean;
	i : Word;
	MIA : DirType;

const BDL = 200;

procedure CalcF;
var
	Changed : Boolean;
	Number, Age, A1, A2, A3, A4, A5, A6, A7, A8  :  Byte;
	XM, YM : Word;
begin
	Changed := False;
	if Paste then PasteRestore;
	with CurrentF^ do
	for x := 1 to Xmax do
	begin
		if LeftPressed or RightPressed then EndCalc := True else;
		for y := 1 to Ymax do
		begin
			Number := 0;
			A1 := Field [X - 1,Y - 1];
			A2 := Field [X,    Y - 1];
			A3 := Field [X + 1,Y - 1];
			A4 := Field [X + 1,Y];
			A5 := Field [X + 1,Y + 1];
			A6 := Field [X,    Y + 1];
			A7 := Field [X - 1,Y + 1];
			A8 := Field [X - 1,Y];
			Age := Field [x,y];
			if (A1 = 3)  or (A1 = 1) then Number := 1;
			if (A2 = 3)  or (A2 = 1) then inc(Number);
			if (A3 = 3)  or (A3 = 1) then inc(Number);
			if (A4 = 3)  or (A4 = 1) then inc(Number);
			if (A5 = 3)  or (A5 = 1) then inc(Number);
			if (A6 = 3)  or (A6 = 1) then inc(Number);
			if (A7 = 3)  or (A7 = 1) then inc(Number);
			if (A8 = 3)  or (A8 = 1) then inc(Number);
			case Number of
				2	: if Age = 3 then;
				3	: if Age = 0 then begin Field [x, y] := 2; Inc(Cells); Changed := True end else
				else
				if Age = 3 then
				begin
					Field [x, y] := 1;
					Dec(CurrentF^.Cells);
					Changed := True;
				end;
			end;
		end;
	end;
	if not Changed then endcalc := True else
	begin
	HideMouse;
	SetFillStyle(1, Black);
	XM := 0;
	with CurrentF^ do
	for x := 1 to Xmax do
	begin
		YM := 0;
		for y := 1 to Ymax do
		begin
			if Field [x, y] = 1 then
			begin
				Field [x, y] := 0;
				Bar(XM, YM, XM + 8, YM + 8);
			end;
			Inc(YM, 10);
		end;
		Inc(XM, 10);
	end;
	SetFillStyle(1, CellColor);
	XM := 0;
	with CurrentF^ do
	for x := 1 to Xmax do
	begin
		YM := 0;
		for y := 1 to Ymax do
		begin
			if Field [x,y] = 2 then
			begin
				Field [x, y] := 3;
				Bar(XM, YM, XM + 8, YM + 8);
			end;
			Inc(YM, 10);
		end;
		Inc(XM, 10);
	end;
	Inc(CurrentF^.Generation);
	if CurrentF^.Cells > MaxCell then MaxCell := CurrentF^.Cells;
	Gr[CurrentF^.Generation] := CurrentF^.Cells;
	ShowMouse;
	end;
end;
{==========================================================================}
begin
	GetStatus;
	ClrScr;
	SetVariables;
	GetDir(0, StartDir);
	TestEnv;
	VideoMode := '640x480x16';
	InitGraphics;
	begin
		if FWE then	if Intro <> hOk then Quit;
		Paste := True;
		FirstActions;
		ShowMouse;
		ShowMain;
		Butts;
		ButtonNow := LeftPressed;
		while True do
		begin
			ButtonOld := ButtonNow;
			ButtonNow := LeftPressed;
			if ButtonNow and not ButtonOld { Pressed }
			then
			begin
{ Field }	if MouseInField then
				with CurrentF^ do
				begin
					Xnow := GetMouseX div 10 + 1;
					Ynow := GetMouseY div 10 + 1;
					if Field [xnow, ynow] = 3 then
					begin
						Field [xnow, ynow] := 0;
						SetFillStyle(1, 0);
						HideMouse;
						Bar((Xnow  - 1) * 10, (Ynow - 1) * 10, (Xnow - 1) * 10 + 8, (Ynow - 1) * 10 + 8);
						Dec(CurrentF^.Cells);
						Gr[CurrentF^. Generation] := CurrentF^.Cells;
						ShowMouse;
					end
					else
					begin
						Field [xnow, ynow] := 3;
						SetFillStyle(1, CellColor);
						HideMouse;
						Bar((Xnow  - 1) * 10, (Ynow - 1) * 10, (Xnow - 1) * 10 + 8, (Ynow - 1) * 10 + 8);
						Inc(CurrentF^.Cells);
						Gr[CurrentF^. Generation] := CurrentF^.Cells;
						ShowMouse;
					end;
					if Cells > MaxCell then MaxCell := Cells;
				end else
{ Help }		if MouseIn(BHelp) then
				begin
					ClearAllButtons;
					BA[BHelp,1] := True; BA[BHelp,2] := True; Butts;
					Delay(BDL);
					ClearAllButtons;
					BA[BOk,1] := True; BA[BOk,2] := False; Butts;
					Help(Main);
					while true do
					begin
						ButtonOld := ButtonNow;
						ButtonNow := LeftPressed;
						if ButtonNow and not ButtonOld { Pressed }
						then
							if MouseIn(BOk) then Break else
						else;
					end;
					ClearAllButtons;
					BA[BOk,1] := True; BA[BOk,2] := True; Butts;
					HideMouse;
					Restore;
					ClearAllButtons; Butts;
					ShowMain;
					Butts;
					ShowMouse;
				end else
{ Start }	if (MouseIn(BStart) and (CurrentF^.Cells > 0)) then
				begin
					ClearAllButtons; BA[BStart,1] := True; BA[BStart,2] := True; Butts;
					Delay(BDL);
					ClearAllButtons; BA[BStop,1] := True; BA[BStop,2] := False; Butts;
					if CurrentF^.Generation = 0 then
					begin
						for x := 0 to XMax + 1 do
							for y := 0 to Ymax + 1 do
								FirstF^.Field [x,y] := CurrentF^.Field [x,y];
						FirstF^.Cells := CurrentF^.Cells;
						FirstF^.Generation := 0;
					end;
					ButtonNow := LeftPressed;
					EndCalc := False;
					while not endcalc do CalcF;
					if Paste then PasteRestore;
					Freshing;
					BA[BStop,1] := True; BA[BStop,2] := True; Butts;
					Delay(BDL);
					ClearAllButtons; Butts;
					ShowMain;
					Butts;
					ShowMouse;
				end else
{ Move }		if (MouseIn(BMove) and (CurrentF^.Cells > 0 )) then
					begin
						BA[BMove,2] := True; Butts;
						Delay(BDL);
						ClearAllButtons; Butts;
						BA[BMove,1] := True; BA[BMove,2] := False; Butts;
						DrawArr;
						while true do
						begin
							if LeftPressed { Pressed Now }
							then
							begin
								MIA := MouseInArrow;
								if  MIA> 0 then MoveField(MIA) else;
								if MouseIn(BMove) then
								begin
									BA[BMove,2] := True; Butts;
									Delay(BDL);
									Break
								end
								else
							end
							else;
						end;
						ClearArrows;
						ClearAllButtons; Butts;
						ShowMain; Butts;
					end else
{ Put }		if MouseIn(BPut) then
				begin
					BA[BPut,2] := True; Butts;
					Delay(BDL);
					for x := 0 to Xmax + 1 do
						for y := 0 to Ymax + 1 do
						begin
							BufferF^.Field [x, y] := CurrentF^.Field [x,y];
							BufferF^.Cells := CurrentF^.Cells;
							BufferF^.Generation := CurrentF^.Generation;
						end;
					BA[BPut,2] := False; Butts
				end else
{ Get }		if MouseIn(BGet) then
				begin
					BA[BGet,2] := True; Butts;
					Delay(BDL);
					for x := 0 to Xmax + 1 do
						for y := 0 to Ymax + 1 do
						begin
							CurrentF^.Field [x, y] := BufferF^.Field [x,y];
							CurrentF^.Cells := BufferF^.Cells;
							CurrentF^.Generation := BufferF^.Generation;
						end;
					Restore;
					BA[BGet,2] := False; Butts
				end else
{ Restore }	if MouseIn(BRestore) then
				if CurrentF^.Cells > 0 then
				begin
					BA[BRestore,2] := True; Butts;
					Delay(BDL);
					ClearAllButtons; Butts;
					BA[BHelp,1] := True; BA[BHelp, 2] := False;
					BA[BAskClear,1] := True; BA[BAskClear, 2] := False;
					BA[BCancel,1] := True; BA[BCancel, 2] := False;
					Butts;
					HButtonNow := LeftPressed;
					while true do
					begin
						HButtonOld := HButtonNow;
						HButtonNow := LeftPressed;
						if HButtonNow and not HButtonOld { Pressed }
						then
						begin
							if MouseIn(BHelp) then
								begin
									BA[BHelp,2] := True; Butts;
									Delay(BDL);
									ClearAllButtons; Butts;
									Help(ClearH);
									BA[BOk,1] := True; BA[BOk,2] := False; Butts;
									HButtonNow := LeftPressed;
									while true do
									begin
										HButtonOld := HButtonNow;
										HButtonNow := LeftPressed;
										if HButtonNow and not HButtonOld { Pressed }
										then
											if MouseIn(BOk) then Break else
										else;
									end;
									Restore;
									ClearAllButtons; Butts;
									BA[BHelp,1] := True; BA[BHelp, 2] := False;
									BA[BAskClear,1] := True; BA[BAskClear, 2] := False;
									BA[BCancel,1] := True; BA[BCancel, 2] := False;
									Butts;
								end else
							if MouseIn(BCancel) then
								begin
									BA[BCancel,1] := True; BA[BCancel, 2] := True;
									Butts;
									Delay(BDL);
									ClearAllButtons; Butts;
									ShowMain; Butts;
									Bell;
									Break
								end else
							if MouseIn(BAskClear) then
								begin
									BA[BAskClear,1] := True; BA[BAskClear, 2] := True;
									Butts;
									Delay(BDL);
									for x := 0 to Xmax + 1 do
										for y := 0 to Ymax + 1 do
											CurrentF^.Field [x,y] := FirstF^. Field[x,y];
									CurrentF^.Cells := FirstF^.Cells;
									CurrentF^.Generation := 0;
									Restore;
									ClearAllButtons; Butts;
									ShowMain; Butts;
									Break
								end
						end else
					end
				end else
				begin
					BA[BRestore,2] := True; Butts;
					Delay(BDL);
					for x := 0 to Xmax + 1 do
							for y := 0 to Ymax + 1 do
								CurrentF^.Field [x,y] := FirstF^. Field[x,y];
					CurrentF^.Cells := FirstF^.Cells;
					CurrentF^.Generation := 0;
					Restore;
					BA[BRestore,2] := False; Butts
				end else
{ Disk }		if MouseIn(BDisk) then
				begin
				ClrKbd;
				BA[BDisk,2] := True; Butts;
				Delay(BDL);
				ClearAllButtons; Butts;
				Disk;
				ShowMain; Butts;
				end else
{ Graphic }	if (MouseIn(BGr) and (CurrentF^.Generation > 0 )) then
				begin
					BA[BGr,1] := True; BA[BGr,2] := True; 
					Butts;
					Delay(BDL);
					ClearAllButtons; Butts;
					BA[BGr,1] := True; BA[BGr,2] := False; Butts;
					HideMouse;
					Graphic;
					ShowMouse;
					while not LeftPressed do;
					Restore;
					ClearAllButtons; Butts;
					ShowMain; Butts;
				end else
{ Clear }	if MouseIn(BClear) then
				begin
					BA[BClear,1] := True; BA[BClear, 2] := True;
					Butts;
					Delay(BDL);
					ClearAllButtons; Butts;
					BA[BHelp,1] := True; BA[BHelp, 2] := False;
					BA[BAskClear,1] := True; BA[BAskClear, 2] := False;
					BA[BCancel,1] := True; BA[BCancel, 2] := False;
					Butts;
					HButtonNow := LeftPressed;
					while true do
					begin
						HButtonOld := HButtonNow;
						HButtonNow := LeftPressed;
						if HButtonNow and not HButtonOld { Pressed }
						then
						begin
							if MouseIn(BHelp) then
								begin
									BA[BHelp,2] := True; Butts;
									Delay(BDL);
									ClearAllButtons; Butts;
									Help(ClearH);
									BA[BOk,1] := True; BA[BOk,2] := False; Butts;
									HButtonNow := LeftPressed;
									while true do
									begin
										HButtonOld := HButtonNow;
										HButtonNow := LeftPressed;
										if HButtonNow and not HButtonOld { Pressed }
										then
											if MouseIn(BOk) then Break else
										else;
									end;
									Restore;
									ClearAllButtons; Butts;
									BA[BHelp,1] := True; BA[BHelp, 2] := False;
									BA[BAskClear,1] := True; BA[BAskClear, 2] := False;
									BA[BCancel,1] := True; BA[BCancel, 2] := False;
									Butts;
								end else
							if MouseIn(BCancel) then
								begin
									BA[BCancel,1] := True; BA[BCancel, 2] := True;
									Butts;
									Delay(BDL);
									Bell;
									Break;
								end else
							if MouseIn(BAskClear) then
								begin
									BA[BAskClear,1] := True; BA[BAskClear, 2] := True;
									Butts;
									Delay(BDL);
									CurrentF^.Cells := 0;
									SetFillStyle(1, Black);
									with CurrentF^ do
									for x := 0 to XMax + 1 do
										for y := 0 to YMax + 1 do
											if (Field [x,y] <> 0) and (x <> 0) and (y <> 0)
																		 and (x <> XMax + 1) and (y <> YMax + 1)
											then
											begin
												Field [x,y] := 0;
												Bar((X - 1) * 10, (Y - 1) * 10, (X - 1) * 10 + 8, (Y - 1) * 10 + 8);
											end;
									for count := 0 to CurrentF^.Generation do GR[count] := 0;
									CurrentF^.Generation := 0;
									Water;
									MaxCell := 1;
									Break;
								end
						end else
					end;
					ClearAllButtons; Butts;
					ShowMain;
					Butts;
				end else
{ Options }	if MouseIn(BOptions) then
				begin
					ClearAllButtons;
					BA[BOptions,1] := True; BA[BOptions,2] := True;
					Butts;
					Delay(BDL);
					ClearAllButtons; Butts;
					BA[BSounds,1] := True; BA[BSounds,2] := False; Butts;
					HButtonNow := LeftPressed;
					while true do
					begin
						HButtonOld := HButtonNow;
						HButtonNow := LeftPressed;
						if HButtonNow and not HButtonOld { Pressed }
						then if MouseIn(BSounds) then
						begin
							BA[BSounds,2] := True; Butts;
							Delay(BDL);
							SoundAllowed := not SoundAllowed;
							Bell;
							Break
						end;
					end;
					ClearAllButtons; Butts;
					ShowMain;
					Butts;
				end else
{ Quit }		if MouseIn(BQuit) then
				begin
					BA[BQuit,1] := True; BA[BQuit,2] := True; Butts;
					Delay(BDL);
					BA[BQuit,2] := False; Butts;
					HideMouse;
					Quit;
				end else
				;
			end
{---------------------------------------------------------------------------}
		end
	end;
end.