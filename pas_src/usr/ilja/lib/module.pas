unit Module;

interface

uses WaveDef;

const
	ModuleVersion = '1.04';

(* mask for ReadModule *)
	rm_IgnoreError       = $0001;
	rm_IgnoreMissPattern = $0002;
	rm_WrType            = $0004;
	rm_HdrOnly           = $0008; (* reads only header *)

(* ReadModule return codes *)
	rmc_Ok              = 0;
	rmc_FileError       = $1000;
	rmc_NoFileSpecified = -1;
	rmc_NotSupported    = -2;
	rmc_UnknownFormat   = -3;
	rmc_OutOfMemory     = -4;
	rmc_MissPattern     = -5;

type

	TSampleName = array[0..21] of Char;

	TModName = array[0..19] of Char;

	TSampleDescr = record
		Name : TSampleName;
		LengthAm : Word;
		Finetune: Byte;
		Volume : Byte;
		LBAm, LEAm : Word; { Loop parameters }
	end;

	TSequence = array[0..127] of Byte;
	TModType = array[0..3] of Char;
	TModHeader = record
		ModName : TModName;
		Samples : array[0..30] of TSampleDescr;
		TotalPatterns : Byte;
		RestartPosition : Byte; { Historically set to 127, but can be safely ignored. }
		Sequence : TSequence;
		ModType : TModType;
	end;

	TCHNData = Longint;

	TPattern = record
		case Byte of
		1:(CHN4:array[0..63, 0..3] of TCHNData);
{		2:(CHN6:array[0..31, 0..5] of TCHNData);}
		3:(CHN8:array[0..31, 0..7] of TCHNData);
	end;

	PPattern = ^TPattern;

	TModPatterns = array[0..127] of PPattern;

	TReserved = array[0..21] of Byte;

	TPatternHeader = record
		ID : Longint;
		Name : TModName;
		Count : Byte;
		TotalPatterns : Byte;
		RestartPosition : Byte;
		Volume : array[0..30] of Byte;
		Sequence : TSequence;
		ModType : TModType;
	end;

const
	PATID = $54544150;
	PatternSize = 1024;
	NullName : TSampleName = #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
	ModType15Samples : TModType = '15-S';

var
	ModName : String; { name of module file }
	ModHeader : TModHeader;
	ModPatterns : TModPatterns;
	Samples : array[0..30] of PWaveInfo;

function PieceLen(i : Byte; b : Word) : Word;
function ReadModule(Mask : Longint) : Integer;
procedure ReleaseSample(i : Byte);
procedure ReleaseModule;
procedure ClearModInfo;
procedure ClearModSampleInfo(var Sample : TSampleDescr);
procedure ClearPattern(Patterns : PPattern);
function GetPatternsNum : Byte;
function GetMaxPattern : Byte;
function GetSampleNum(ChannelData : TCHNData) : Byte;
function GetSampleT(ChannelData : TCHNData) : Word;
function GetEffect(ChannelData : TCHNData) : Byte;
function GetEffectX(ChannelData : TCHNData) : Byte;
function GetEffectY(ChannelData : TCHNData) : Byte;
function GetEffectXY(ChannelData : TCHNData) : Byte;
function SampleName2Str(SampleName : TSampleName) : String;
function ModName2Str(Name : TModName) : String;
procedure Str2SampleName(S : String; var SampleName : TSampleName);
procedure Str2ModName(S : String; var ModName : TModName);
function ValidSample(Sample : TSampleDescr) : Boolean;
function SampleLen(Sample : TSampleDescr) : Word;
{procedure HeaderMod2Sample(SampleDescr : TSampleDescr; var SampleHeader : TSampleHeader);}
function CountPatterns(Patterns : TSequence) : Byte;
procedure SetMixerFreq;
procedure SoundOn;
procedure SoundOff;

implementation

uses Dos, CrtExt, GnrlFltr, IOErrors, Strings;

function MaxBlock(i : Byte) : Word;
begin
	if Samples[i] <> nil then
		MaxBlock := (Samples[i]^.Length shr 1 shl 1) div 32768
	else MaxBlock := 0;
end;

function PieceLen(i : Byte; b : Word) : Word;
begin
	if Samples[i] <> nil then
		if b < MaxBlock(i) then PieceLen := 32768
		else PieceLen := Samples[i]^.Length shr 1 shl 1 mod 32768
	else PieceLen := 0;
end;

function ReadModule(Mask : Longint) : Integer;
var
	F : file;
	i, PN, SamplesNum : Byte;
	L, NL : Longint;
	m : Word;
	S : String;
	Result : Integer;
const
	UMF = 'Unknown module format';
begin
	ReadModule := -1;
	ClearModInfo;
	SamplesNum := 31;
	if (ModName = '') then
		if Mask and rm_IgnoreError = rm_IgnoreError then begin ClearModInfo; Exit end
		else Abort('No module file specified');
	Assign(F, ModName);
{$I-}
	Reset(F, 1);
{$I+}
	Result := IOResult;
	if Result <> 0 then
		begin
			ReadModule := rmc_FileError+Result;
			if Mask and rm_IgnoreError = rm_IgnoreError then begin ClearModInfo; Exit end
			else Abort('Error opening file : '+ModName+' : '+ErrorMsg(Result));
		end;

	if System.FileSize(F) < SizeOf(TModHeader) then Abort(UMF);
	BlockRead(F, ModHeader, SizeOf(ModHeader));
	if (ModHeader.ModType = '6CHN') or (ModHeader.ModType = '8CHN') then
	begin
		Close(F);
		ReadModule := rmc_NotSupported;
		if Mask and rm_IgnoreError = rm_IgnoreError then begin ClearModInfo; Exit end
		else
			Abort(Copy(ModHeader.ModType, 1, 1)+'-channel modules are not supported');
	end
	else
	if (ModHeader.ModType = 'FLT8') then
	begin
		Close(F);
		ReadModule := rmc_NotSupported;
		if Mask and rm_IgnoreError = rm_IgnoreError then begin ClearModInfo; Exit end
		else
			Abort('8-channel Startracker modules are not supported');
	end
	else
	if (ModHeader.ModType = 'FLT4') then
	begin
		if Mask and rm_WrType = rm_WrType then
			WriteLn('Type: Startracker 4-channel');
	end
	else
	if (ModHeader.ModType = 'M.K.') then
	begin
		if Mask and rm_WrType = rm_WrType then
			WriteLn('Type: Protracker 4-channel');
	end
	else
	if (ModHeader.ModType = 'M!K!') then
	begin
		Close(F);
		ReadModule := rmc_NotSupported;
		if Mask and rm_IgnoreError = rm_IgnoreError then begin ClearModInfo; Exit end
		else
			Abort('extended Protracker modules are not supported');
	end
	else
	begin { only 15 samples }
		SamplesNum := 15;
		if Mask and rm_WrType = rm_WrType then
			WriteLn('Type: Protracker 4-channel with only 15 samples');
		for i := 15 to 30 do ClearModSampleInfo(ModHeader.Samples[i]);
		System.Seek(F, SizeOf(ModHeader.ModName)+15*SizeOf(ModHeader.Samples[0]));
		BlockRead(F, ModHeader.TotalPatterns, SizeOf(ModHeader.TotalPatterns));
		BlockRead(F, ModHeader.RestartPosition, SizeOf(ModHeader.RestartPosition));
		BlockRead(F, ModHeader.Sequence, SizeOf(ModHeader.Sequence));
		ModHeader.ModType := ModType15Samples;
	end;

	if not (ModHeader.TotalPatterns in [1..128]) then
	begin
		Close(F);
		ReadModule := rmc_UnknownFormat;
		if Mask and rm_IgnoreError = rm_IgnoreError then begin ClearModInfo; Exit end
		else
			Abort(UMF);
	end;

	if ModHeader.ModType <> 'M!K!' then
	for i := 0 to 127 do
	if not (ModHeader.Sequence[i] in [0..63]) then
	begin
		Close(F);
		ReadModule := rmc_UnknownFormat;
		if Mask and rm_IgnoreError = rm_IgnoreError then begin ClearModInfo; Exit end
		else
			Abort(UMF);
	end;
	if Mask and rm_HdrOnly = rm_HdrOnly then begin ReadModule := 0; Exit; end;
	PN := CountPatterns(ModHeader.Sequence);
	for i := 0 to 127 do ModPatterns[i] := nil;
	for i := 0 to PN do
	begin
		L := System.FileSize(F)-System.FilePos(F);
		if (L >= Longint(SizeOf(TPattern))) then
		begin
			if MaxAvail < SizeOf(TPattern)+16 then
			begin
				Close(F);
				ReadModule := rmc_OutOfMemory;
				if Mask and rm_IgnoreError = rm_IgnoreError then begin ClearModInfo; Exit end
				else
					Abort('Out of memory to read patterns');
			end;
			New(ModPatterns[i]);
			BlockRead(F, ModPatterns[i]^, SizeOf(TPattern));
		end
		else
		begin
			ClearPattern(ModPatterns[i]);
			if Mask and rm_IgnoreMissPattern = rm_IgnoreMissPattern then
			begin
				ReadModule := rmc_MissPattern;
				Exit;
			end
			else
			begin
				Str(i, S);
				Abort('Error reading pattern '+S);
			end;
		end
	end;
	L := System.FilePos(F);

	for i := 0 to 30 do Samples[i] := nil;

	for i := 0 to SamplesNum-1 do
	begin
		if MaxAvail < SizeOf(Samples[0])+16 then
		begin
			Close(F);
			ReadModule := rmc_OutOfMemory;
			if Mask and rm_IgnoreError = rm_IgnoreError then begin ClearModInfo; Exit end
			else
				Abort('Out of memory to allocate sample info');
		end;
		New(Samples[i]); ResetWaveInfo(Samples[i]^);
		Samples[i]^.Length := SampleLen(ModHeader.Samples[i]);
		L := Samples[i]^.Length;
		if System.FileSize(F)-System.FilePos(F) < L then
		begin
			NL := System.FileSize(F)-System.FilePos(F);
			Write('Error reading sample ', i, ' : ',
				L-NL, ' bytes (');
			WriteFix(4, (L-NL)/L*100);
			WriteLn('%) lost');
			L := NL;
			Samples[i]^.Length := L;
		end;
		Samples[i]^.Freq := 22100;
		Samples[i]^.Channels := 1;
		Samples[i]^.Bits := 8;
		Samples[i]^.PitchHi := 107; { B8 }
		Samples[i]^.PitchLo := 0; { C0 }
		Samples[i]^.PitchUn := 48; { C4 }
		SetWaveAuthor(Samples[i]^, 'Ilja Slepnev');
		SetWaveCopyright(Samples[i]^, '(c) 1996 SIComp');
{		SetWaveName(Samples[i]^, SampleName2Str(ModHeader.Samples[i].Name));}
		Samples[i]^.LB := 2*Swap(ModHeader.Samples[i].LBAm);
		if Samples[i]^.LB < 0 then Samples[i]^.LB := 0;
		Samples[i]^.LE := Samples[i]^.LB+2*Swap(ModHeader.Samples[i].LEAm);
		if Samples[i]^.LE < 0 then Samples[i]^.LE := 0;
		if Samples[i]^.LE > Samples[i]^.Length then Samples[i]^.LE := Samples[i]^.Length;
		if Samples[i]^.LE = 2 then Samples[i]^.LE := 0; { some trackers reserve one word }
{		if Samples[i]^.LB > Samples[i]^.LE then
		begin
			SwapLongint(Samples[i]^.LB, Samples[i]^.LE);
		end;}
		if Abs(Samples[i]^.LE - Samples[i]^.LB) > 1
		then Samples[i]^.Loop := NormLoop else Samples[i]^.Loop := 0;

		for m := 0 to MaxBlock(i) do
		begin
			L := PieceLen(i, m);
			if MaxAvail <= L+16 then
			begin
				Close(F);
				ReadModule := rmc_OutOfMemory;
				if Mask and rm_IgnoreError = rm_IgnoreError then begin ClearModInfo; Exit end
				else
					Abort('Out of memory to allocate sample data');
			end;
			if L > 0 then
			begin
				GetMem(Samples[i]^.Wave^[m], L);
				BlockRead(F, Samples[i]^.Wave^[m]^, L);
			end;
		end;
	end;
	Close(F);
	ReadModule := 0;
end;

procedure ReleaseSample(i : Byte);
var m : Word; L : Longint;
begin
	if i > 30 then Exit;
	if Samples[i] = nil then Exit;
	ReleaseWaveInfo(Samples[i]^);
	Dispose(Samples[i]);
end;

procedure ReleaseModule;
var i : Word;
begin
	for i := 0 to 127 do if ModPatterns[i] <> nil then Dispose(ModPatterns[i]);
	for i := 0 to 30 do ReleaseSample(i);
end;

procedure ClearModInfo;
var i : Word;
begin
	ReleaseModule;
	for i := 0 to 30 do ClearModSampleInfo(ModHeader.Samples[i]);
	with ModHeader do
	begin
		Str2ModName('', ModName);
		TotalPatterns := 0;
		RestartPosition := 127;
		for i := 0 to 127 do
			Sequence[i] := 0;
		ModType := #0#0#0#0;
	end;
end;

procedure ClearModSampleInfo(var Sample : TSampleDescr);
begin
	with Sample do
	begin
		Name := NullName;
		LengthAm := 0;
		Finetune := 0;
		Volume := 0;
		LBAm := 0; LEAm := 0;
	end;
end;

procedure ClearPattern(Patterns : PPattern);
begin
	FillChar(Patterns^, SizeOf(Patterns^), 0);
end;

function GetPatternsNum : Byte;
begin
	GetPatternsNum := ModHeader.TotalPatterns;
end;

function GetMaxPattern : Byte;
begin
	GetMaxPattern := CountPatterns(ModHeader.Sequence);
end;

function GetSampleNum(ChannelData : TCHNData) : Byte;
begin
	BackOrd(ChannelData);
	GetSampleNum :=
		((ChannelData and $F0000000) shr 24) or
		((ChannelData and $0000F000) shr 12);
end;

function GetSampleT(ChannelData : TCHNData) : Word;
begin
	BackOrd(ChannelData);
	GetSampleT := (ChannelData and $0FFF0000) shr 16;
end;

function GetEffect(ChannelData : TCHNData) : Byte;
begin
	BackOrd(ChannelData);
	GetEffect := ChannelData and $00000F00 shr 8;
end;

function GetEffectX(ChannelData : TCHNData) : Byte;
begin
	BackOrd(ChannelData);
	GetEffectX := ChannelData and $000000F0 shr 4;
end;

function GetEffectY(ChannelData : TCHNData) : Byte;
begin
	BackOrd(ChannelData);
	GetEffectY := ChannelData and $0000000F;
end;

function GetEffectXY(ChannelData : TCHNData) : Byte;
begin
	BackOrd(ChannelData);
	GetEffectXY := ChannelData and $000000FF;
end;


function SampleName2Str(SampleName : TSampleName) : String;
var c : Byte; N : String;
begin
	N := '';
	for c := 0 to 21 do
		if (SampleName[c] >= #32) and (SampleName[c] < #128) then N := N + SampleName[c] else Break;
	SampleName2Str := N;
end;

function ModName2Str(Name : TModName) : String;
var c : Byte; N : String;
begin
	N := '';
	for c := 0 to 19 do
		if (Name[c] >= #32) and (Name[c] < #128) then N := N + Name[c] else Break;
	ModName2Str := N;
end;

procedure Str2SampleName(S : String; var SampleName : TSampleName);
var i : Byte;
begin
	for i := 0 to SizeOf(TSampleName)-1 do
		if Length(S) > i
		then SampleName[i] := S[i+1]
		else SampleName[i] := #0;
end;

procedure Str2ModName(S : String; var ModName : TModName);
var i : Byte;
begin
	for i := 0 to SizeOf(TModName)-1 do
		if Length(S) < i
		then ModName[i] := S[i+1]
		else ModName[i] := #0;
end;

function ValidSample(Sample : TSampleDescr) : Boolean;
var L : Longint;
begin
	ValidSample := False;
	if SampleLen(Sample) = 0 then Exit;
	ValidSample := True;
end;

function SampleLen(Sample : TSampleDescr) : Word;
var L : Longint;
begin
	L := 2*Swap(Sample.LengthAm);
	if (L <= 2) or (L > 65528)
	then SampleLen := 0
	else SampleLen := L;
end;

{procedure HeaderMod2Sample(SampleDescr : TSampleDescr; var SampleHeader : TSampleHeader);
begin
	SampleHeader.shID := SPLID;
	SampleHeader.shSize := SampleLen(SampleDescr);
	SampleHeader.shFreq := DefaultSampleFreq;
	SampleHeader.shCRLF := SPLCRLF;
	SampleHeader.shName := SampleDescr.Name;
	SampleHeader.shLBHi := SampleDescr.LBHi;
	SampleHeader.shLBLo := SampleDescr.LBLo;
	SampleHeader.shLEHi := SampleDescr.LEHi;
	SampleHeader.shLELo := SampleDescr.LELo;
	SampleHeader.shMainFreq := DefaultMainFreq;
	SampleHeader.shReserved := NullReserved;
end;}

function CountPatterns(Patterns : TSequence) : Byte;
var p, i, MaxPat : Byte;
	Pr : array[0..127] of Boolean;
begin
{	for p := 0 to 127 do Pr[p] := False;
	for i := 0 to 127 do
	begin
		for p := 0 to 127 do
			if Patterns[i] = p then Pr[p] := True;
	end;
	MaxPat := 0;
	for p := 0 to 127 do if Pr[p] then Inc(MaxPat);}
	MaxPat := 0;
	for i := 0 to 127 do if Patterns[i] > MaxPat then MaxPat := Patterns[i];
	CountPatterns := MaxPat{ - 1};
end;

end.