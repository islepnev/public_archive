unit XMS;

interface

const MaxXMSBlocks = 128;

type
	TXMSHandle = record
		Hdl : Word;
		Ofs : Longint;
		Len : Longint; { bytes used }
	end;

	PXMSBlocks = ^TXMSBlocks;
	TXMSBlocks = array[1..MaxXMSBlocks] of Word;

const
	NoHandle : TXMSHandle = (Hdl:0; Ofs:0; Len:0);
	XMSError = 'XMS error: ';
var
	XMSRequired : Longint;
	OldExitProc : Pointer;
	XMSBlocks : PXMSBlocks;
	XMSBlocksNum : Word;
{Initialization}
	function InitXMS : Boolean;
	procedure DoneXMS;

	function XMSInstalled: boolean;

{Informational}
	function XMSGetVersion: word;
	function XMSGetFreeMem: word;

{Allocation and deallocation}
	function XMSAllocate(var Handle: word; Size: word): boolean;
	function XMSReallocate(Handle: word; NewSize: word): boolean;
	function XMSFree(Handle: word): boolean;

{Memory moves}
	type
		PMoveParams = ^TMoveParams;
		TMoveParams =
		  record
			 Length       : LongInt;  {Length must be a multiple of two}
			 SourceHandle : word;
			 SourceOffset : LongInt;
			 DestHandle   : word;
			 DestOffset   : LongInt;
		  end;
	function XMSMove(Params: PMoveParams): boolean;

{ File-to-XMS }
function ReadToXMS(var F : file; var Handle : TXMSHandle; StartOfs, Count : Longint; ReAlloc : Boolean) : Integer;

implementation

uses Crt, CrtExt, IOErrors, IOErrDef, Math, Trace, SysInit;

	 var
		XMSDriver: pointer;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

    function XMSInstalled: boolean; assembler;
      asm
        mov    ax, 4300h
        int    2Fh
        cmp    al, 80h
        jne    @NoXMSDriver
        mov    al, TRUE
        jmp    @Done
       @NoXMSDriver:
        mov    al, FALSE
       @Done:
		end;

{ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ}

    procedure XMSInit; assembler;
      asm
        mov    ax, 4310h
        int    2Fh
        mov    word ptr [XMSDriver], bx
        mov    word ptr [XMSDriver+2], es
      end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

    function XMSGetVersion: word; assembler;
      asm
        mov    ah, 00h
        call   XMSDriver
		end;

{ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ}

    function XMSGetFreeMem: word; assembler;
      asm
        mov    ah, 08h
        call   XMSDriver
        mov    ax, dx
      end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

	 function iXMSAllocate(var Handle: word; Size: word): boolean; assembler;
      asm
        mov    ah, 09h
        mov    dx, Size
        call   XMSDriver
		  les    di, Handle
        mov    es:[di], dx
      end;

{ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ}

	 function iXMSReallocate(Handle: word; NewSize: word): boolean; assembler;
      asm
        mov    ah, 0Fh
        mov    bx, NewSize
        mov    dx, Handle
        call   XMSDriver
      end;

{ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ}

	 function iXMSFree(Handle: word): boolean; assembler;
      asm
		  mov    ah, 0Ah
        mov    dx, Handle
        call   XMSDriver
      end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
    function XMSMove(Params: PMoveParams): boolean; assembler;
      asm
        push   ds
        mov    ah, 0Bh
        lds    si, Params
        call   XMSDriver
		  pop    ds
		end;

var
	XMSInited : Boolean;

procedure OurExitProc; far;
	{If the program terminates with a runtime error before the extended memory}
	{is deallocated, then the memory will still be allocated, and will be lost}
	{until the next reboot.  This exit procedure is ALWAYS called upon program}
	{termination and will deallocate extended memory if necessary.            }
begin
	{ Deallocate here }
	DoneXMS;
	ExitProc := OldExitProc; {Chain to next exit procedure}
end;

function InitXMS : Boolean;
var
	S : String[10];
	i : word;
begin
	InitXMS := False;
{$IFDEF DEBUG}
	WriteMsg('XMS initialization');
{$ENDIF}
	if XMSInstalled then XMSInit else
	begin
{$IFDEF DEBUG}
		WriteResult(hError);
{$ENDIF}
		AET := 'Error initializing extended memory. HIMEM.SYS must be installed';
		Exit;
	end;
{$IFDEF DEBUG}
	WriteResult(hOk);
	WriteLn('Free XMS memory:  ', XMSGetFreeMem, 'k  ');
{$ENDIF}

	if XMSGetFreeMem < XMSRequired then
	begin
		Str(XMSRequired - XMSGetFreeMem, S);
		AET := 'Insufficient extended memory: requires '+S+' kBytes';
		Error;
	end;
	if MaxAvail < SizeOf(XMSBlocks^) then
	begin
		AET := NoMemAlloc+'XMS handlers table';
		Error;
	end;
	New(XMSBlocks);
	for i := 1 to MaxXMSBlocks do XMSBlocks^[i] := 0;
	ExitProc := @OurExitProc;
	XMSInited := True;
	InitXMS := True;
end;

procedure DoneXMS;
var i : Word;
begin
	if not XMSInited then Exit;
{$IFDEF DEBUG}
	WriteMsg('XMS shutdown');
{$ENDIF}
	for i := 1 to XMSBlocksNum do
		if XMSBlocks^[i] > 0 then iXMSFree(XMSBlocks^[i]);
	Dispose(XMSBlocks);
{$IFDEF DEBUG}
	WriteResult(hOk);
{$ENDIF}
end;

var
	MoveParams: TMoveParams; {The XMS driver doesn't like this on the stack}
function ReadToXMS(var F : file; var Handle : TXMSHandle; StartOfs, Count : Longint; ReAlloc : Boolean) : Integer;
	function Min(a, b: LongInt): LongInt;
	begin
		if a < b
			then Min := a
			else Min := b;
	end;
const
	BufferLen = 16384;
type
	PBuffer = ^TBuffer;
	TBuffer = array[0..BufferLen-1] of Byte;
var
	Buf : PBuffer;
	Remaining : Longint;
begin
	ReadToXMS := hError;
	if XMSGetFreeMem < (Count + 1023) div 1024 then begin AET := 'Insufficient extended memory'; Exit end;
	if Handle.Hdl = 0 then
	begin
		if not XMSAllocate(Handle.Hdl, (Count + 1023) div 1024) then
			begin AET := 'Error allocating XMS block'; Exit; end;
		MoveParams.DestOffset   := 0;
		Handle.Len := ParL(Count);
	end
	else
	begin
		if Handle.Ofs+StartOfs > Handle.Len then begin AET := XMSError+'start offset exceeds block length'; Exit end;
		if not iXMSReallocate(Handle.Hdl, (Handle.Len+Count + 1023) div 1024) then
			begin AET := 'Error reallocating XMS block'; Exit; end;
		MoveParams.DestOffset   := Handle.Ofs+StartOfs;
		Inc(Handle.Len, ParL(Count));
	end;
	if MaxAvail < SizeOf(Buf) then begin AET := NoMemAlloc+'file buffer'; Exit end;
	New(Buf);
	MoveParams.SourceHandle := 0;
	MoveParams.SourceOffset := LongInt(Buf);
	MoveParams.DestHandle   := Handle.Hdl;
	Remaining := Count;
	while Remaining > 0 do
	begin
		MoveParams.Length := Min(Remaining, BufferLen);
		if BlockRead(F, Buf^, MoveParams.Length) <> hOk then
			begin Dispose(Buf); Exit end;
		MoveParams.Length := ParL(MoveParams.Length);
	{XMS copy lengths must be a multiple of two}
		if not XMSMove(@MoveParams) then
			begin AET := XMSError+'ReadToXMS'; Dispose(Buf); Exit end;
		Inc(MoveParams.DestOffset, MoveParams.Length);
		Dec(Remaining, MoveParams.Length);
	end;
	Dispose(Buf);
	ReadToXMS := hOk;
end;

function XMSAllocate(var Handle: word; Size: word): boolean;
begin
	XMSAllocate := iXMSAllocate(Handle, Size);
	Inc(XMSBlocksNum);
	XMSBlocks^[XMSBlocksNum] := Handle;
end;

function XMSReallocate(Handle: word; NewSize: word): boolean;
begin
	XMSReallocate := iXMSReallocate(Handle, NewSize);
end;

function XMSFree(Handle: word): boolean;
var i : Word;
begin
	for i := 1 to XMSBlocksNum do if XMSBlocks^[i] = Handle then XMSBlocks^[i] := 0;
	XMSFree := iXMSFree(Handle);
end;

begin
	OldExitProc := ExitProc;
	XMSInited := False;
	XMSRequired := 0;
	XMSBlocksNum := 0;
	XMSBlocks := nil;
end.