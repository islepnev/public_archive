uses Crt, CrtExt, GraphExt, IOErrDef, IOErrors;
var F : file; S : String; StartMem : LongInt;
  procedure Dummy;
  begin
  end;
begin
  StartMem := MemAvail;
{	TextColor(LightGray);
	TextBackground(Black);
	ClrScr;{
	WriteLn(CRTWidth,' ', CRTHeight, ' ', CRTSize);}
  InitGraphics;
  CriticalErrorTxt :=
		'This is the error box test procedure. ';
	CriticalError;
{	Error;
	Exit;}
  {	Assign(F, 'A:\');}
(*	Reset(F);
	ReadLn(F, S);*)
  {	if RewriteFile(F,'B:\') <> hOk then Error;}
  {	WriteLn(F, 'Testing...');}
  {	Close(F);}
  DoneGraphics;
  if StartMem <> MemAvail then
  begin
    Str(StartMem - MemAvail, S);
    AET := 'Heap warning: lost ' + S + ' bytes';
    Error;
  end;
end.
