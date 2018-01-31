unit WinError;

interface

procedure ErrorStd(Title : PChar; ErrorID : Word);
procedure ErrorBox(Title, Text : PChar);

implementation

uses BWCC, WinTypes;

function ErrorMsg(ErrorID : Word) : PChar;
begin
	case ErrorID of
		0 : ErrorMsg := 'No error';
		1 : ErrorMsg := 'Invalid function number';
		2 : ErrorMsg := 'File not found';
		3 : ErrorMsg := 'Path not found';
		4 : ErrorMsg := 'Too many open files';
		5 : ErrorMsg := 'Access denied';
		6 : ErrorMsg := 'Invalid file handle';
		7 : ErrorMsg := 'Memory ctrl blocks destroyed';
		8 : ErrorMsg := 'Not enough memory';
		9 : ErrorMsg := 'Invalid memory block address';
		10: ErrorMsg := 'Invalid environment';
		11: ErrorMsg := 'Invalid format';
		12: ErrorMsg := 'Invalid file access code';
		13: ErrorMsg := 'Invalid data';
		15: ErrorMsg := 'Invalid drive number';
		16: ErrorMsg := 'Can''t remove current dir';
		17: ErrorMsg := 'Can''t rename across drives';
		18: ErrorMsg := 'No more matching files';
		100 :ErrorMsg := 'Disk read error';
		101 :ErrorMsg := 'Disk write error (disk full)';
		102 :ErrorMsg := 'File not assigned';
		103 :ErrorMsg := 'File not open';
		104 :ErrorMsg := 'File not open for input';
		105 :ErrorMsg := 'File not open for output';
		106 :ErrorMsg := 'Invalid numeric format';
		150: ErrorMsg := 'Attempted write on write-protected disk';
		151: ErrorMsg := 'Inknown unit ID';
		152: ErrorMsg := 'Drive not ready';
		153: ErrorMsg := 'Unknown command';
		154: ErrorMsg := 'Disk data error (CRC error)';
		155: ErrorMsg := 'Bad request structure lenght';
		156: ErrorMsg := 'Disk seek error';
		157: ErrorMsg := 'Unknown disk media type';
		158: ErrorMsg := 'Disk sector not found';
		159: ErrorMsg := 'Printer out of paper';
		160: ErrorMsg := 'Device write fault error';
		161: ErrorMsg := 'Device read fault error';
		162: ErrorMsg := 'General (hardware) failure';
		200 :ErrorMsg := 'Division by zero';
		201 :ErrorMsg := 'Range check error';
		202 :ErrorMsg := 'Stack overflow error';
		203 :ErrorMsg := 'Heap overflow error';
		204 :ErrorMsg := 'Invalid pointer operation';
		205 :ErrorMsg := 'Floating point overflow';
		206 :ErrorMsg := 'Floating point underflow';
		207 :ErrorMsg := 'Invalid floating point operation';
		208 :ErrorMsg := 'Overlay manager not installed';
		209 :ErrorMsg := 'Overlay file read error';
		210 :ErrorMsg := 'Object not initialized';
		211 :ErrorMsg := 'Call to abstract method';
		212 :ErrorMsg := 'Stream registration error';
		213 :ErrorMsg := 'Collection index out of range';
		214 :ErrorMsg := 'Collection overflow error';
		215 :ErrorMsg := 'Arithmetic overflow error';
		216 :ErrorMsg := 'General Protection fault';
		else ErrorMsg := 'Unknown Error';
	end;
end;

procedure ErrorStd(Title : PChar; ErrorID : Word);
begin
	ErrorBox(Title, ErrorMsg(ErrorID));
end;

procedure ErrorBox(Title, Text : PChar);
begin
	if Title = nil then Title := 'Error';
	BWCCMessageBox(0, Text, Title, MB_OK or MB_IconHand);
end;

end.