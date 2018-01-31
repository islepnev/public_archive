unit Font2;

interface

{$L tscr.obj}
{$L bold.obj}
{$L goth.obj}
{$L lcom.obj}

procedure TscrProc;
procedure BoldProc;
procedure GothProc;
procedure LcomProc;

implementation

procedure TscrProc; external;
procedure BoldProc; external;
procedure GothProc; external;
procedure LcomProc; external;

end.
