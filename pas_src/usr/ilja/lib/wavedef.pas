unit WaveDef;

interface

uses
	MiniObj
{$IFNDEF WINDOWS}
	,OpXMS
{$ENDIF};

const
	BegLoopText = 'Begin repeat';
	EndLoopText = 'End repeat';

	MIDIUnityPitch = 48;
	FreqC0 = 16.352; (* Hz *)
	NoLoop = 0; NormLoop = 1; PPLoop = 2;

{ Data format }
	{ PCM }
		df_8bit     = 1; (* 8-bit integer *)
		df_12bit    = 2; (* 12-bit integer *)
		df_16bit    = 3; (* 16-bit integer *)
		df_24bit    = 4; (* 24-bit integer *)
		df_32bit    = 5; (* 32-bit integer *)
		df_Single   = 6; (* 32-bit float *)
		df_Real     = 7; (* 48-bit float *)
		df_Double   = 8; (* 64-bit float *)
		df_Extended = 9; (* 80-bit float *)
	{ uLAw }
		df_uLaw     = 10; (* 8-bit uLaw *)
	{ ALaw }
		df_ALaw     = 20; (* 8-bit ALaw *)
	{ ADPCM }
		df_ADPCM    = 100; (* ??? *)

{ Channels }
	df_Mono   = 1;
	df_Stereo = 2;

{ Sign }
	df_Signed   = 1;
	df_Unsigned = 2;

{ Byte order }
	df_Intel    = 1;
	df_Motorola = 2;

{ Audio file types }

	aft_RAW  = 1;
	aft_AIFF = 2;
	aft_AIFC = 3;
	aft_8SVX = 4;
	aft_WAV  = 5;
	aft_VOC  = 6;
	aft_AU   = 7;
	aft_SMP  = 8;
	aft_Unknown = 255;

	MinHdrSize = 16;

const
	uLaw2PCM : array[Byte] of Integer = (
	 -32124, -31100, -30076, -29052, -28028, -27004, -25980, -24956,
	 -23932, -22908, -21884, -20860, -19836, -18812, -17788, -16764,
	 -15996, -15484, -14972, -14460, -13948, -13436, -12924, -12412,
	 -11900, -11388, -10876, -10364,  -9852,  -9340,  -8828,  -8316,
	  -7932,  -7676,  -7420,  -7164,  -6908,  -6652,  -6396,  -6140,
	  -5884,  -5628,  -5372,  -5116,  -4860,  -4604,  -4348,  -4092,
	  -3900,  -3772,  -3644,  -3516,  -3388,  -3260,  -3132,  -3004,
	  -2876,  -2748,  -2620,  -2492,  -2364,  -2236,  -2108,  -1980,
		-1884,  -1820,  -1756,  -1692,  -1628,  -1564,  -1500,  -1436,
		-1372,  -1308,  -1244,  -1180,  -1116,  -1052,   -988,   -924,
		-876,   -844,   -812,   -780,   -748,   -716,   -684,   -652,
		-620,   -588,   -556,   -524,   -492,   -460,   -428,   -396,
		-372,   -356,   -340,   -324,   -308,   -292,   -276,   -260,
		-244,   -228,   -212,   -196,   -180,   -164,   -148,   -132,
		-120,   -112,   -104,    -96,    -88,    -80,    -72,    -64,
		 -56,    -48,    -40,    -32,    -24,    -16,     -8,      0,
		32124,  31100,  30076,  29052,  28028,  27004,  25980,  24956,
	  23932,  22908,  21884,  20860,  19836,  18812,  17788,  16764,
	  15996,  15484,  14972,  14460,  13948,  13436,  12924,  12412,
	  11900,  11388,  10876,  10364,   9852,   9340,   8828,   8316,
		7932,   7676,   7420,   7164,   6908,   6652,   6396,   6140,
		5884,   5628,   5372,   5116,   4860,   4604,   4348,   4092,
		3900,   3772,   3644,   3516,   3388,   3260,   3132,   3004,
		2876,   2748,   2620,   2492,   2364,   2236,   2108,   1980,
		1884,   1820,   1756,   1692,   1628,   1564,   1500,   1436,
		1372,   1308,   1244,   1180,   1116,   1052,    988,    924,
		 876,    844,    812,    780,    748,    716,    684,    652,
		 620,    588,    556,    524,    492,    460,    428,    396,
		 372,    356,    340,    324,    308,    292,    276,    260,
		 244,    228,    212,    196,    180,    164,    148,    132,
		 120,    112,    104,     96,     88,     80,     72,     64,
			56,     48,     40,     32,     24,     16,      8,      0);

const
	AbsMaxPitch = 127;

type

{ TLoop object }

	PLoop = ^TLoop;
	TLoop = object(TMyObject)
		Num : Word;            (* Loop Number *)
		Name : PChar;          (* Any comment *)
		Start, Stop : Longint; (* Samples, not bytes! *)
		LType : Byte;          (* 0 - No Loop; 1 - Forward; 2 - PingPong *)
		NCycle : Byte;         (* How many rounds to go *)
		Next : PLoop;
		constructor Init(ANum : Word; AName : PChar; AStart, AStop : Longint; ALType, ANCycle : Byte; ANext : PLoop);
		destructor Done; virtual;
	end;

{ TMarker object }

	PMarker = ^TMarker;
	TMarker = object(TMyObject)
		Num : Word;
		Where : Longint;       (* Position, sample *)
		Name : PChar;          (* Name *)
		Descr : PChar;         (* Description *)
		Next : PMarker;
		constructor Init(ANum : Word; AWhere : Longint; AName, ADescr : PChar; ANext : PMarker);
		destructor Done; virtual;
	end;

{ TMIDIPitch object }

	PMIDIPitch = ^TMIDIPitch;
	TMIDIPitch = object(TMyObject)
		Unity, Max, Min : Byte;
		procedure SetDefault;
		function Valid : Boolean;
	end;

	TChunkID = array[0..3] of Char;

	PSummary = ^TSummary;
	TSummary = record
		ID : TChunkID;
		Length: Longint;
		Text: PChar;
		Next: PSummary;
	end;


	PWaveData = ^TWaveData;
	TWaveData = object(TMyObject)
		DataFormat : Word;
		Channels : Word;
		Sign : Word;
		ByteOrder : Word;
		Rate : Real;
		Length : Longint; { samples, not bytes! }
		Loops : PLoop;
		Markers : PMarker;
		MIDIPitch : PMIDIPitch;
		ArchivalLocation, Artist, Commissioned, Comments, Copyright,
		CreationDate, Cropped, Engineer, Genre, Keywords, Medium, Name, Product,
		Software, Subject, Source, SourceForm, Technician : PChar;
		constructor Init;
		destructor Done; virtual;

		function DataValid : Boolean;
		function DataFormatDescr : String;
		function DataFormatStr : String;
		function SignStr : String;
		function ByteOrdStr : String;
		function BpS : Byte; { Bytes per Sample }
		function Size : Longint; { Length in bytes }

		procedure AddMarker(Num : Word; Where : Longint; Text : PChar);
		function CountMarkers : Word;
		function DisposeMarker(var P : PMarker) : PMarker;
		function FindMarker(ReqNum : Word) : PMarker;
		function FindLastMarker : PMarker;
		procedure SetMarkerName(Num : Word; AName : PChar);
		procedure SetMarkerDescr(Num : Word; ADescr : PChar);

		procedure AddLoop(Num : Word; Start, Stop : Longint; LType, NCycles : Byte; Text : PChar);
		function CountLoops : Word;
		function DisposeLoop(var P : PLoop) : PLoop;
		function FindLoop(ReqNum : Word) : PLoop;
		function FindLastLoop : PLoop;
		procedure SetLoopName(Num : Word; AName : PChar);

		procedure ResetData;
		procedure SetArchivalLocation(AArchivalLocation : PChar);
		procedure SetArtist(AArtist : PChar);
		procedure SetCommissioned(ACommissioned : PChar);
		procedure SetComments(AComments : PChar);
		procedure SetCopyright(ACopyright : PChar);
		procedure SetCreationDate(ACreationDate : PChar);
		procedure SetCropped(ACropped : PChar);
		procedure SetEngineer(AEngineer : PChar);
		procedure SetGenre(AGenre : PChar);
		procedure SetKeywords(AKeywords : PChar);
		procedure SetMedium(AMedium : PChar);
		procedure SetName(AName : PChar);
		procedure SetProduct(AProduct : PChar);
		procedure SetSoftware(ASoftware : PChar);
		procedure SetSubject(ASubject : PChar);
		procedure SetSource(ASource : PChar);
		procedure SetSourceForm(ASourceForm : PChar);
		procedure SetTechnician(ATechnician : PChar);
		procedure ReleaseArchivalLocation;
		procedure ReleaseArtist;
		procedure ReleaseCommissioned;
		procedure ReleaseComments;
		procedure ReleaseCopyright;
		procedure ReleaseCreationDate;
		procedure ReleaseCropped;
		procedure ReleaseEngineer;
		procedure ReleaseGenre;
		procedure ReleaseKeywords;
		procedure ReleaseMedium;
		procedure ReleaseName;
		procedure ReleaseProduct;
		procedure ReleaseSoftware;
		procedure ReleaseSubject;
		procedure ReleaseSource;
		procedure ReleaseSourceForm;
		procedure ReleaseTechnician;
		procedure ReleaseInfo; { dispose all text info }
	end;

function Pitch2Step(Pitch : Byte; Freq : Real) : Word;
function Step2Pitch(Step : Word; Freq : Real) : Word;
function PitchTxt(Pitch : Byte) : String;
function ReadWave(var F : file; WD : PWaveData; DataSize : Longint) : Integer;
{function ReadTextChunk(var F : file; ChunkSize : Longint; var P : PChar) : Integer;}
procedure FormatNotSupported(Text : PChar);

implementation

uses
{$IFDEF WINDOWS}
	WinError, WinFiles, WinTypes, BWCC,
{$ELSE}
	CrtExt,
	FileExt,
	IOErrors,
{$ENDIF}
	IOErrDef,
	Strings,
	Math;
{ TMIDIPitch methods }

procedure TMIDIPitch.SetDefault;
begin
	Min := 0;
	Unity := MIDIUnityPitch;
	Max := AbsMaxPitch;
end;

function TMIDIPitch.Valid : Boolean;
begin
	if (Unity in [0..AbsMaxPitch]) and (Min in [0..AbsMaxPitch]) and (Max in [0..AbsMaxPitch]) and
		(Min <= Unity) and (Unity <= Max) then  Valid := True else Valid := False;
end;

{ TMarker methods }

constructor TMarker.Init(ANum : Word; AWhere : Longint; AName, ADescr : PChar; ANext : PMarker);
begin
	inherited Init;
	Num := ANum;
	Where := AWhere;
	Name := AName;
	Descr := ADescr;
	Next := ANext;
end;

destructor TMarker.Done;
begin
	if Name <> nil then StrDispose(Name);
	if Descr <> nil then StrDispose(Descr);
	inherited Done;
end;

{ TLoop methods }

constructor TLoop.Init(ANum : Word; AName : PChar; AStart, AStop : Longint; ALType, ANCycle : Byte; ANext : PLoop);
begin
	inherited Init;
	Num := ANum;
	Name := AName;
	Start := AStart;
	Stop := AStop;
	LType := ALtype;
	NCycle := ANCycle;
	Next := ANext;
end;

destructor TLoop.Done;
begin
	if Name <> nil then StrDispose(Name);
	inherited Done;
end;

{ TWaveData methods }

constructor TWaveData.Init;
begin
	inherited Init;
	ResetData;
end;

destructor TWaveData.Done;
begin
	if Loops <> nil then Dispose(Loops, Done);
	if Markers <> nil then Dispose(Markers, Done);
	if MIDIPitch <> nil then Dispose(MIDIPitch, Done);
	ReleaseInfo;
end;

function TWaveData.DataValid : Boolean;
begin
	DataValid := False;
	if (Channels in [df_Mono, df_Stereo]) and
		(Sign in [df_Signed, df_Unsigned]) and
		(ByteOrder in [df_Intel, df_Motorola]) and
		(DataFormat in [
			df_8Bit, df_12Bit, df_16Bit, df_24Bit, df_32Bit,
			df_Single, df_Real, df_Double, df_Extended,
			df_uLaw, df_ALaw]){ and
		((Wave.Hand = 0) or
		((Wave.Hand <> 0) and (Wave.Len = ParL(Length * BpS * Channels))))}
	then DataValid := True;
end;

function TWaveData.BpS : Byte; { Bytes per Sample }
begin
	BpS := 0;
	case DataFormat of
		df_8Bit     : BpS := 1;
		df_12Bit    : BpS := 2; { 1.5 ??? }
		df_16Bit    : BpS := 2;
		df_24Bit    : BpS := 3;
		df_32Bit    : BpS := 4;
		df_Single   : BpS := 4;
		df_Real     : BpS := 6;
		df_Double   : BpS := 8;
		df_Extended : BpS := 10;
		df_uLaw     : BpS := 1;
		df_ALaw     : BpS := 1;
	end;
end;

function TWaveData.Size : Longint; { Length in bytes - always even }
begin
	Size := Length*BpS*Channels;
end;

function TWaveData.DataFormatStr : String;
begin
	case DataFormat of
		df_8Bit     : DataFormatStr := '8-bit PCM';
		df_12Bit    : DataFormatStr := '12-bit PCM';
		df_16Bit    : DataFormatStr := '16-bit PCM';
		df_24Bit    : DataFormatStr := '24-bit PCM';
		df_32Bit    : DataFormatStr := '32-bit PCM';
		df_Single   : DataFormatStr := '32-bit float';
		df_Real     : DataFormatStr := '48-bit float';
		df_Double   : DataFormatStr := '64-bit float';
		df_Extended : DataFormatStr := '80-bit float';
		df_uLaw     : DataFormatStr := 'æ-Law';
		df_ALaw     : DataFormatStr := 'A-Law';
		df_ADPCM    : DataFormatStr := 'ADPCM';
		else DataFormatStr := 'Unknown';
	end;
end;

function TWaveData.DataFormatDescr : String;
var S : String;
begin
	S := DataFormatStr;
	if BpS > 1 then S := S+'  '+ByteOrdStr;
	if DataFormat in [df_8Bit, df_16Bit, df_24Bit, df_32Bit] then S := S+'  '+SignStr;
	DataFormatDescr := S;
end;

function TWaveData.SignStr : String;
begin
	case Sign of
		df_Signed : SignStr := 'Signed';
		df_Unsigned : SignStr := 'Unsigned';
		else SignStr := 'Unknown';
	end;
end;

function TWaveData.ByteOrdStr : String;
begin
	case ByteOrder of
		df_Intel : ByteOrdStr := 'Intel';
		df_Motorola : ByteOrdStr := 'Motorola';
		else ByteOrdStr := 'Unknown';
	end;
end;

procedure TWaveData.AddMarker(Num : Word; Where : Longint; Text : PChar);
var P, Q : PMarker;
begin
	if MaxAvail < SizeOf(TMarker) then Exit;
	New(Q, Init(Num, Where, Text, nil, nil));
	if Markers <> nil then
	begin
		P := FindLastMarker;
		if P <> nil then P^.Next := Q else
		begin Dispose(Q, Done); Exit end;
	end
	else Markers := Q;
end;

function TWaveData.CountMarkers : Word;
var i : Word; P : PMarker;
begin
	i := 0;
	while P <> nil do
	begin
		P := P^.Next;
		Inc(i);
	end;
	CountMarkers := i;
end;

function TWaveData.DisposeMarker(var P : PMarker) : PMarker;
begin
	DisposeMarker := nil;
	if P = nil then Exit;
	DisposeMarker := P^.Next;
	Dispose(P, Done);
	P := nil;
end;

function TWaveData.FindLastMarker : PMarker;
var P : PMarker;
begin
	FindLastMarker := nil;
	P := Markers;
	if P = nil then Exit;
	while P^.Next <> nil do P := P^.Next;
	FindLastMarker := P;
end;

function TWaveData.FindMarker(ReqNum : Word) : PMarker;
var P : PMarker;
begin
	FindMarker := nil;
	P := Markers;
	while P <> nil do
	begin
		if P^.Num = ReqNum then
			begin
				FindMarker := P;
				Break;
			end;
		P := P^.Next;
	end;
end;

procedure TWaveData.SetMarkerDescr(Num : Word; ADescr : PChar);
var Q : PMarker;
begin
	Q := FindMarker(Num);
	if Q <> nil then Q^.Descr := ADescr;
end;

procedure TWaveData.SetMarkerName(Num : Word; AName : PChar);
var Q : PMarker;
begin
	Q := FindMarker(Num);
	if Q <> nil then Q^.Name := AName;
end;

procedure TWaveData.AddLoop(Num : Word; Start, Stop : Longint; LType, NCycles : Byte; Text : PChar);
var P, Q : PLoop;
begin
	if MaxAvail < SizeOf(TLoop) then Exit;
	New(Q, Init(Num, Text, Start, Stop, LType, NCycles, nil));
	if Loops <> nil then
	begin
		P := FindLastLoop;
		if P <> nil then P^.Next := Q else
		begin Dispose(Q, Done); Exit end;
	end
	else Loops := Q;
end;

function TWaveData.CountLoops : Word;
var i : Word; P : PLoop;
begin
	i := 0;
	while P <> nil do
	begin
		P := P^.Next;
		Inc(i);
	end;
	CountLoops := i;
end;

function TWaveData.DisposeLoop(var P : PLoop) : PLoop;
begin
	DisposeLoop := nil;
	if P = nil then Exit;
	DisposeLoop := P^.Next;
	Dispose(P, Done);
	P := nil;
end;

function TWaveData.FindLastLoop : PLoop;
var P : PLoop;
begin
	FindLastLoop := nil;
	P := Loops;
	if P = nil then Exit;
	while P^.Next <> nil do P := P^.Next;
	FindLastLoop := P;
end;

function TWaveData.FindLoop(ReqNum : Word) : PLoop;
var P : PLoop;
begin
	FindLoop := nil;
	P := Loops;
	while P <> nil do
	begin
		if P^.Num = ReqNum then
			begin
				FindLoop := P;
				Break;
			end;
		P := P^.Next;
	end;
end;

procedure TWaveData.SetLoopName(Num : Word; AName : PChar);
var Q : PLoop;
begin
	Q := FindLoop(Num);
	if Q <> nil then Q^.Name := AName;
end;

procedure TWaveData.ResetData;
begin
	DataFormat := 0;
	Channels := 0;
	Sign := 0;
	ByteOrder := 0;
	Rate := 0;
	Length := 0;

{ Information Fields }
	ArchivalLocation := nil;
	Artist := nil;
	Commissioned := nil;
	Comments := nil;
	Copyright := nil;
	CreationDate := nil;
	Cropped := nil;
	Engineer := nil;
	Genre := nil;
	Keywords := nil;
	Medium := nil;
	Name := nil;
	Product := nil;
	Software := nil;
	Subject := nil;
	Source := nil;
	SourceForm := nil;
	Technician := nil;

	Loops := nil;
	Markers := nil;
	MIDIPitch := nil;
end;

procedure TWaveData.SetArchivalLocation(AArchivalLocation : PChar);
begin
	ReleaseArchivalLocation;
	ArchivalLocation := AArchivalLocation;
end;

procedure TWaveData.SetArtist(AArtist : PChar);
begin
	ReleaseArtist;
	Artist := AArtist;
end;

procedure TWaveData.SetCommissioned(ACommissioned : PChar);
begin
	ReleaseCommissioned;
	Commissioned := ACommissioned;
end;

procedure TWaveData.SetComments(AComments : PChar);
begin
	ReleaseComments;
	Comments := AComments;
end;

procedure TWaveData.SetCopyright(ACopyright : PChar);
begin
	ReleaseCopyright;
	Copyright := ACopyright;
end;

procedure TWaveData.SetCreationDate(ACreationDate : PChar);
begin
	ReleaseCreationDate;
	CreationDate := ACreationDate;
end;

procedure TWaveData.SetCropped(ACropped : PChar);
begin
	ReleaseCropped;
	Cropped := ACropped;
end;

procedure TWaveData.SetEngineer(AEngineer : PChar);
begin
	ReleaseEngineer;
	Engineer := AEngineer;
end;

procedure TWaveData.SetGenre(AGenre : PChar);
begin
	ReleaseGenre;
	Genre := AGenre;
end;

procedure TWaveData.SetKeywords(AKeywords : PChar);
begin
	ReleaseKeywords;
	Keywords := AKeywords;
end;

procedure TWaveData.SetMedium(AMedium : PChar);
begin
	ReleaseMedium;
	Medium := AMedium;
end;

procedure TWaveData.SetName(AName : PChar);
begin
	ReleaseName;
	Name := AName;
end;

procedure TWaveData.SetProduct(AProduct : PChar);
begin
	ReleaseProduct;
	Product := AProduct;
end;

procedure TWaveData.SetSoftware(ASoftware : PChar);
begin
	ReleaseSoftware;
	Software := ASoftware;
end;

procedure TWaveData.SetSubject(ASubject : PChar);
begin
	ReleaseSubject;
	Subject := ASubject;
end;

procedure TWaveData.SetSource(ASource : PChar);
begin
	ReleaseSource;
	Source := ASource;
end;

procedure TWaveData.SetSourceForm(ASourceForm : PChar);
begin
	ReleaseSourceForm;
	SourceForm := ASourceForm;
end;

procedure TWaveData.SetTechnician(ATechnician : PChar);
begin
	ReleaseTechnician;
	Technician := ATechnician;
end;

procedure TWaveData.ReleaseArchivalLocation;
begin
	if ArchivalLocation <> nil then StrDispose(ArchivalLocation);
end;

procedure TWaveData.ReleaseArtist;
begin
	if Artist <> nil then StrDispose(Artist);
end;

procedure TWaveData.ReleaseCommissioned;
begin
	if Commissioned <> nil then StrDispose(Commissioned);
end;

procedure TWaveData.ReleaseComments;
begin
	if Comments <> nil then StrDispose(Comments);
end;

procedure TWaveData.ReleaseCopyright;
begin
	if Copyright <> nil then StrDispose(Copyright);
end;

procedure TWaveData.ReleaseCreationDate;
begin
	if CreationDate <> nil then StrDispose(CreationDate);
end;

procedure TWaveData.ReleaseCropped;
begin
	if Cropped <> nil then StrDispose(Cropped);
end;

procedure TWaveData.ReleaseEngineer;
begin
	if Engineer <> nil then StrDispose(Engineer);
end;

procedure TWaveData.ReleaseGenre;
begin
	if Genre <> nil then StrDispose(Genre);
end;

procedure TWaveData.ReleaseKeywords;
begin
	if Keywords <> nil then StrDispose(Keywords);
end;

procedure TWaveData.ReleaseMedium;
begin
	if Medium <> nil then StrDispose(Medium);
end;

procedure TWaveData.ReleaseName;
begin
	if Name <> nil then StrDispose(Name);
end;

procedure TWaveData.ReleaseProduct;
begin
	if Product <> nil then StrDispose(Product);
end;

procedure TWaveData.ReleaseSoftware;
begin
	if Software <> nil then StrDispose(Software);
end;

procedure TWaveData.ReleaseSubject;
begin
	if Subject <> nil then StrDispose(Subject);
end;

procedure TWaveData.ReleaseSource;
begin
	if Source <> nil then StrDispose(Source);
end;

procedure TWaveData.ReleaseSourceForm;
begin
	if SourceForm <> nil then StrDispose(SourceForm);
end;

procedure TWaveData.ReleaseTechnician;
begin
	if Technician <> nil then StrDispose(Technician);
end;

procedure TWaveData.ReleaseInfo;
begin
	ReleaseArchivalLocation;
	ReleaseArtist;
	ReleaseCommissioned;
	ReleaseComments;
	ReleaseCopyright;
	ReleaseCreationDate;
	ReleaseCropped;
	ReleaseEngineer;
	ReleaseGenre;
	ReleaseMedium;
	ReleaseName;
	ReleaseProduct;
	ReleaseSoftware;
	ReleaseSubject;
	ReleaseSource;
	ReleaseSourceForm;
	ReleaseTechnician;
end;

function Pitch2Step(Pitch : Byte; Freq : Real) : Word;
begin
	Pitch2Step := Round(Freq/(FreqC0*Exp(Ln(2)*Pitch/12)));
end;

function Step2Pitch(Step : Word; Freq : Real) : Word;
begin
	if Step = 0 then Step2Pitch := 255 else
	Step2Pitch := Round(12/Ln(2)*Ln(Freq/Step/FreqC0));
end;

function PitchTxt(Pitch : Byte) : String;
var Note, Oct : String;
begin
	Str(Pitch div 12, Oct);
	case Pitch mod 12 of
		0:  Note := 'C';
		1:  Note := 'C#';
		2:  Note := 'D';
		3:  Note := 'D#';
		4:  Note := 'E';
		5:  Note := 'F';
		6:  Note := 'F#';
		7:  Note := 'G';
		8:  Note := 'G#';
		9:  Note := 'A';
		10: Note := 'A#';
		11: Note := 'B';
	end;
	PitchTxt := Note+Oct;
end;

function ReadWave(var F : file; WD : PWaveData; DataSize : Longint) : Integer;
var
	FP, FS : Longint;
begin
	ReadWave := hError;
	if WD = nil then Exit; (* data object not initialized *)
	if DataSize <= 0 then Exit; (* Nothing to do *)
{	if WD^.BpS = 0 then Exit;}

{	if not (WD^.Channels in [1,2]) then begin AET := 'Invalid channel count'; Exit end;}

	if FileSize(F, FS) <> hOk then Exit;
	if FilePos(F, FP) <> hOk then Exit;
	if FP+DataSize > ParL(FS) then begin AET := 'Wave data exceeds file'; Exit end;

{	if ReadFileToXMS(F, WD^.Wave.Hand, MinL(FS-FP, DataSize)) <> hOk then Exit;
	WD^.Wave.Len := ParL(MinL(FS-FP, DataSize));
	WD^.Wave.Ofs := 0;}
{	WD^.Length := DataSize div WD^.BpS;}
	ReadWave := hOk;
end;
{
function ReadTextChunk(var F : file; ChunkSize : Longint; var P : PChar) : Integer;
var L, P0 : Longint; SL : Word; B : Byte;
begin
	ReadTextChunk := hError;
	if ChunkSize = 0 then begin P := nil; ReadTextChunk := hOk; Exit end;
	L := ChunkSize;
	if L < 65535 then SL := L else SL := 65535;
	if FilePos(F, P0) <> hOk then Exit;
	 if MaxAvail < SL+1 then begin AET := NoMem+'to read string'; Exit; end;
	GetMem(P, SL+1);
	if BlockRead(F, P^, SL) <> hOk then Exit;
	Mem[Seg(P^):Ofs(P^)+SL] := 0; (* force leading zero *)
	if Odd(ChunkSize) then
		if BlockRead(F, B, 1) <> hOk then Exit; (* word align *)
	ReadTextChunk := hOk;
end;
}
procedure FormatNotSupported(Text : PChar);
const FNS = 'Format not supported';
begin
{$IFDEF WINDOWS}
	BWCCMessageBox(0, Text, FNS, MB_OK or MB_IconHand);
{$ELSE}
	AET := FNS;
	Error;
{$ENDIF}
end;

end.