unit DrvLink;

interface

{procedure ATTProc;
procedure HercProc;
procedure IBM8514Proc;
procedure PC3270Proc;
procedure VGA256Proc;}
procedure CGAProc;
procedure EGAVGAProc;
procedure VESA16Proc;
procedure SVGA16Proc;
procedure SVGA256Proc;
procedure SVGA32kProc;
procedure SVGA64kProc;


implementation
(*
procedure ATTProc;     external; {$L ATT.OBJ }
procedure HercProc;    external; {$L HERC.OBJ }
procedure IBM8514Proc; external; {$L IBM8514.OBJ }
procedure PC3270Proc;  external; {$L PC3270.OBJ }
procedure VGA256Proc;  external; {$L vga256.OBJ }*)
procedure CGAProc;     external; {$L CGA.OBJ }
procedure EGAVGAProc;  external; {$L EGAVGA.OBJ }
procedure VESA16Proc;  external; {$L vesa16.OBJ }
procedure SVGA16Proc;  external; {$L svga16.OBJ }
procedure SVGA256Proc;  external; {$L svga256.OBJ }
procedure SVGA32kProc;  external; {$L svga32k.OBJ }
procedure SVGA64kProc;  external; {$L svga64k.OBJ }

end.
