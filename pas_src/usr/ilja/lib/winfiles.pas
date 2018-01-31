unit WinFiles;

interface

uses IOErrDef;

procedure BackOrd(var L : Longint);
procedure SwapLongint(var a, b : Longint);
procedure SwapWord(var a, b : Word);
procedure SwapInt(var a, b : Integer);
procedure SwapByte(var a, b : Byte);
procedure SwapShortint(var a, b : Shortint);
procedure SwapReal(var a, b : Real);
procedure SwapPtr(var a, b : Pointer);
function ParL(N : Longint) : Longint;
function ParW(N : Word) : Word;
function ResetFile(var F : file; FileName : PChar) : Integer;
function RewriteFile(var F : file; FileName : PChar) : Integer;
function CloseFile(var F : file) : Integer;
function EraseFile(FileName : String) : Integer;
function RenameFile(var F : file; NewName : String) : Integer;
function BlockRead(var F: File; var Buf; Count: Word) : Integer;
function BlockWrite(var F: File; var Buf; Count: Word) : Integer;
function FilePos(var F : file; var Pos : Longint) : Integer;
function FileSize(var F : file; var Size : Longint) : Integer;
function Seek(var F : file; Pos : Longint) : Integer;
function SeekW(var F : file; Pos : Longint) : Integer; { word aligned }

function ReadByte(var F : file; var B : Byte) : Integer;
function ReadIWord(var F : file; var W : Word) : Integer;
function ReadMWord(var F : file; var W : Word) : Integer;
function ReadIInt(var F : file; var I : Integer) : Integer;
function ReadMInt(var F : file; var I : Integer) : Integer;
function ReadILong(var F : file; var L : Longint) : Integer;
function ReadMLong(var F : file; var L : Longint) : Integer;
function WriteByte(var F : file; B : Byte) : Integer;
function WriteIWord(var F : file; W : Word) : Integer;
function WriteMWord(var F : file; W : Word) : Integer;
function WriteIInt(var F : file; I : Integer) : Integer;
function WriteMInt(var F : file; I : Integer) : Integer;
function WriteILong(var F : file; L : Longint) : Integer;
function WriteMLong(var F : file; L : Longint) : Integer;

function ReadIEEExtended(var F : file; var E : Extended) : Integer;
function WriteIEEExtended(var F : file; R : Extended) : Integer;

implementation

uses WinDos, WinError, WinTypes;

{ Byte order functions }

procedure BackOrd(var L : Longint);
begin
	L := Longint(Swap(L and $FFFF)) shl 16 or Swap(L shr 16);
end;

procedure SwapLongint(var a, b : Longint);
var x : Longint;
begin
	x := a; a := b; b := x;
end;

procedure SwapWord(var a, b : Word);
var x : Word;
begin
	x := a; a := b; b := x;
end;

procedure SwapInt(var a, b : Integer);
var x : Integer;
begin
	x := a; a := b; b := x;
end;

procedure SwapByte(var a, b : Byte);
var x : Byte;
begin
	x := a; a := b; b := x;
end;

procedure SwapShortint(var a, b : Shortint);
var x : Shortint;
begin
	x := a; a := b; b := x;
end;

procedure SwapReal(var a, b : Real);
var x : Real;
begin
	x := a; a := b; b := x;
end;

procedure SwapPtr(var a, b : Pointer);
var x : Pointer;
begin
	x := a; a := b; b := x;
end;

function ParL(N : Longint) : Longint;
begin
	ParL := (N+1) shr 1 shl 1;
end;

function ParW(N : Word) : Word;
begin
	ParW := (N+1) shr 1 shl 1;
end;
{---------------------------------------------------------------------------}
function ResetFile(var F : file; FileName : PChar) : Integer;
var Result : Integer;
begin
	ResetFile := idError;
	Assign(F, FileName);
{$I-}
	Reset(F, 1);
	Result := IOResult;
	if Result <> 0 then begin ErrorStd('ResetFile', Result); Exit end;
	ResetFile := idOk;
end;

function RewriteFile(var F : file; FileName : PChar) : Integer;
var Result : Integer;
begin
	RewriteFile := idError;
	Assign(F, FileName);
{$I-}
	Rewrite(F, 1);
	Result := IOResult;
	if Result <> 0 then begin ErrorStd('RewriteFile', Result); Exit end;
	RewriteFile := idOk;
end;

function CloseFile(var F : file) : Integer;
var Result : Integer;
begin
	CloseFile := idError;
{$I-}
	Close(F);
	Result := IOResult;
	if Result <> 0 then begin ErrorStd('CloseFile', Result); Exit end;
	CloseFile := idOk;
end;

function EraseFile(FileName : String) : Integer;
var
	Result : Integer;
	F : file;
begin
	EraseFile := idError;
	Assign(F, FileName);
{$I-}
	Erase(F);
	Result := IOResult;
	if Result <> 0 then begin ErrorStd('EraseFile', Result); Exit end;
	EraseFile := idOk;
end;

function RenameFile(var F : file; NewName : String) : Integer;
var Result : Integer;
begin
	RenameFile := idError;
{$I-}
	Rename(F, NewName);
	Result := IOResult;
	if Result <> 0 then begin ErrorStd('RenameFile', Result); Exit end;
	RenameFile := idOk;
end;

function BlockRead(var F: File; var Buf; Count: Word) : Integer;
var BytesRead : Word;
begin
	System.BlockRead(F, Buf, Count, BytesRead);
	if BytesRead <> Count then BlockRead := idError else BlockRead := idOk;
end;

function BlockWrite(var F: File; var Buf; Count: Word) : Integer;
var BytesWritten : Word;
begin
	System.BlockWrite(F, Buf, Count, BytesWritten);
	if BytesWritten <> Count then BlockWrite := idError else BlockWrite := idOk;
end;

function FilePos(var F : file; var Pos : Longint) : Integer;
begin
	{$R-}
	Pos := System.FilePos(F);
	if IOResult <> 0 then FilePos := idError else FilePos := idOk;
end;

function FileSize(var F : file; var Size : Longint) : Integer;
begin
	{$R-}
	Size := System.FileSize(F);
	if IOResult <> 0 then FileSize := idError else FileSize := idOk;
end;

function Seek(var F : file; Pos : Longint) : Integer;
begin
	{$R-}
	System.Seek(F, Pos);
	if IOResult <> 0 then Seek := idError else Seek := idOk;
end;

function SeekW(var F : file; Pos : Longint) : Integer;
begin
	{$R-}
	System.Seek(F, ParL(Pos));
	if IOResult <> 0 then SeekW := idError else SeekW := idOk;
end;

function ReadByte(var F : file; var B : Byte) : Integer;
begin
	ReadByte := BlockRead(F, B, 1);
end;

function ReadMWord(var F : file; var W : Word) : Integer;
begin  (* reads Amiga word --- byte swap *)
	ReadMWord := BlockRead(F, W, 2);
	W := Swap(W);
end;

function ReadIWord(var F : file; var W : Word) : Integer;
begin  (* reads Intel word *)
	ReadIWord := BlockRead(F, W, 2);
end;

function ReadIInt(var F : file; var I : Integer) : Integer;
begin  (* reads Intel integer *)
	ReadIInt := BlockRead(F, I, 2);
end;

function ReadMInt(var F : file; var I : Integer) : Integer;
begin  (* reads Motorola integer *)
	ReadMInt := BlockRead(F, I, 2);
	I := Swap(I);
end;

function ReadMLong(var F : file; var L : Longint) : Integer;
begin  (* reads Amiga long --- byte swap *)
	ReadMLong := BlockRead(F, L, 4);
	BackOrd(L);
end;

function ReadILong(var F : file; var L : Longint) : Integer;
begin  (* reads Intel long *)
	ReadILong := BlockRead(F, L, 4);
end;

function WriteByte(var F : file; B : Byte) : Integer;
begin
	WriteByte := idError;
	if DiskFree(0) < 1 then begin ErrorBox('WriteByte','Disk full'); Exit; end;
	if BlockWrite(F, B, 1) <> idOk then Exit;
	WriteByte := idOk;
end;

function WriteMWord(var F : file; W : Word) : Integer;
begin  (* writes Amiga word --- byte swap *)
	WriteMWord := idError;
	if DiskFree(0) < 2 then begin ErrorBox('WriteMWord','Disk full'); Exit; end;
	W := Swap(W);
	if BlockWrite(F, W, 2) <> idOk then Exit;
	WriteMWord := idOk;
end;

function WriteIWord(var F : file; W : Word) : Integer;
begin  (* writes Intel word *)
	WriteIWord := idError;
	if DiskFree(0) < 2 then begin ErrorBox('WriteIWord','Disk full'); Exit; end;
	if BlockWrite(F, W, 2) <> idOk then Exit;
	WriteIWord := idOk;
end;

function WriteIInt(var F : file; I : Integer) : Integer;
begin  (* writes Intel integer *)
	WriteIInt := idError;
	if DiskFree(0) < 2 then begin ErrorBox('WriteIInt','Disk full'); Exit; end;
	if BlockWrite(F, I, 2) <> idOk then Exit;
	WriteIInt := idOk;
end;

function WriteMInt(var F : file; I : Integer) : Integer;
begin  (* writes Motorola integer *)
	WriteMInt := idError;
	I := Swap(I);
	if DiskFree(0) < 2 then begin ErrorBox('WriteMInt','Disk full'); Exit; end;
	if BlockWrite(F, I, 2) <> idOk then Exit;
	WriteMInt := idOk;
end;

function WriteMLong(var F : file; L : Longint) : Integer;
begin  (* writes Amiga long --- byte swap *)
	WriteMLong := idError;
	if DiskFree(0) < 4 then begin ErrorBox('WriteMLong','Disk full'); Exit; end;
	BackOrd(L);
	if BlockWrite(F, L, 4) <> idOk then Exit;
	WriteMLong := idOk;
end;

function WriteILong(var F : file; L : Longint) : Integer;
begin  (* writes Intel long *)
	WriteILong := idError;
	if DiskFree(0) < 4 then begin ErrorBox('WriteILong','Disk full'); Exit; end;
	if BlockWrite(F, L, 4) <> idOk then Exit;
	WriteILong := idOk;
end;

function ReadIEEExtended(var F : file; var E : Extended) : Integer;
var B10Num : array[0..9] of Byte; i : Byte;
begin  (* reads IEEE Extended (byte orded - Intel) *)
	ReadIEEExtended := idError;
	if BlockRead(F, B10Num, 10) <> idOk then Exit;
	for i := 0 to 4 do SwapByte(B10Num[i], B10Num[9-i]);
	Move(B10Num, E, 10);
	ReadIEEExtended := idOk;
end;

function WriteIEEExtended(var F : file; R : Extended) : Integer;
var E : Extended; B10Num : array[0..9] of Byte; i : Byte;
begin  (* writes IEEE Extended (byte orded - Intel) *)
	WriteIEEExtended := idError;
	if DiskFree(0) < 10 then begin ErrorBox('WriteIEEEExtended','Disk full'); Exit; end;

	E := R;
	Move(E, B10Num, 10);
	for i := 0 to 4 do SwapByte(B10Num[i], B10Num[9-i]);
	if BlockWrite(F, B10Num, 10) <> idOk then Exit;

	WriteIEEExtended := idOk;
end;

end.