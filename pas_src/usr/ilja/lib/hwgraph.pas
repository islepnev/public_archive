unit HWGraph;

interface
uses dos;

const
	ChipsFileName = 'wlchips.dat';
	DataFileName = 'wlvm.dat';
  ATTR= $3C0;
  SEQ = $3C4;
  GRC = $3CE;
var
	HWGraphDataFilePath : String;
type
  str10=string[10];

  mmods=(_text,
         _text2,
         _text4,
         _herc,   {Hercules mono, 4 "banks" of 8kbytes}
				 _cga1,   {CGA 2 color, 2 "banks" of 16kbytes}
         _cga2,   {CGA 4 color, 2 "banks" of 16kbytes}
         _pl1 ,   {plain mono, 8 pixels per byte}
         _pl1e,   {mono odd/even, 8 pixels per byte, two planes}
         _pl2 ,   {4 color odd/even planes}
			_pk2 ,   {4 color "packed" pixels 4 pixels per byte}
			_pl4 ,   {std EGA/VGA 16 color: 4 planes, 8 pixels per byte}
         _pk4 ,   {ATI mode 65h two 16 color pixels per byte}
         _p8  ,   {one 256 color pixel per byte}
         _p15 ,   {Sierra 15 bit}
         _p16 ,   {Sierra 16bit/XGA}
         _p24 ,   {RGB 3bytes per pixel}
         _p32 );  {RGBa 3+1 bytes per pixel }

  modetype=record
             md,xres,yres,bytes:word;
             memmode:mmods;
           end;

  CHIPS=(__EGA,__VGA,__chips451,__chips452,__chips453,__paradise,__video7
				,__ET3000,__ET4000,__tridBR,__tridCS,__trid89,__everex,__ati1,__ati2
        ,__genoa,__oak,__cirrus,__aheadA,__aheadB,__ncr,__yamaha,__poach
        ,__s3,__al2101,__mxic,__vesa,__realtek,__p2000,__cir54,__cir64
        ,__Weitek,__WeitekP9,__xga,__compaq,__iitagx,__ET4w32,__oak87,__atiGUP
		  ,__UMC,__HMC,__xbe,__none);

  CursorType=Array[0..1,0..31] of longint;  {32 lines of 32 pixels}

const

  header:array[CHIPS] of string[14]=
	 ('EGA','VGA','Chips&Tech','Chips&Tech','Chips&Tech'
	 ,'Paradise','Video7','ET3000','ET4000','Trident','Trident'
         ,'Trident','Everex','ATI','ATI','Genoa','Oak','Cirrus','Ahead'
         ,'Ahead','NCR','Yamaha','Poach','S3','AL2101','MXIC','VESA'
         ,'Realtek','PRIMUS','Cirrus54','Cirrus64','Weitek','WeitekP9'
         ,'XGA','COMPAQ','IITAGX','ET4000W32','Oak','ATI','UMC','HMC'
         ,'XBE','');


const   {Short name for chip families}
  chipnam:array[chips] of string[8]=
        ('EGA','VGA','CT451','CT452','CT453','WD','Video7'
		  ,'ET3000','ET4000','TR8800BR','TR8800CS','TR8900','Everex','ATI18800'
		  ,'ATI28800','Genoa','OAK','Cirrus','Ahead A','Ahead B','NCR','Yamaha','Poach'
        ,'S3','ALG','MXIC','VESA','Realtek','Primus','CL54xx','CL64xx'
        ,'Weitek','P9000','XGA','Compaq','IIT','ET4/W32','OAK 87','Mach 32'
        ,'UMC','HMC','XBE','?');



const

  {DAC types}

  _dac0     =0;   {No DAC (MDA/CGA/EGA ..}
  _dac8     =1;   {Std VGA DAC 256 cols.}
  _dac15    =2;   {Sierra 32k DAC}
  _dac16    =3;   {Sierra 64k DAC}
  _dacss24  =4;   {Sierra?? 24bit RGB DAC}
	_dacatt   =5;   {ATT 20c490/1/2  15/16/24 bit DAC}
  _dacADAC1 =6;   {Acumos ADAC1  15/16/24 bit DAC}

  _dacalg   =7;   {Avance Logic  16 bit DAC}
  _dacSC24  =8;   {Sierra SC15025 24bit DAC}
  _dacCL24  =9;   {Cirrus Logic 24bit RAMDAC for CL542x series}
  _dacMus   =10;  {Music MU9c1740 24bit DAC}
  _dacUnk9  =11;
  _dacBt484 =12;


  _dacCEG   =13;  {Edsun CEG DAC}


  {Flags for special features}

  ft_cursor = 1;   {Has hardware cursor}
  ft_blit   = 2;   {Can do BitBLTs}
  ft_line   = 4;   {Can do lines}
  ft_rwbank = 8;   {Suports seperate R/W banks}



  (* Chip versions *)

  VS_VBE      =   90;
  VS_XBE      =   91;

  CL_Unk54    =  100;
  CL_AVGA1    =  101;
  CL_AVGA2    =  102;
  CL_GD5401   =  103;
  CL_GD5402   =  104;
  CL_GD5402r1 =  105;
  CL_GD5420   =  106;
  CL_GD5420r1 =  107;
  CL_GD5422   =  108;
  CL_GD5424   =  109;
  CL_GD5426   =  110;
  CL_GD5428   =  111;
	CL_GD543x   =  112;

  CL_GD6205   =  115;
  CL_GD6215   =  116;
  CL_GD6225   =  117;
  CL_GD6235   =  118;

  CL_Unk64    =  120;
  CL_GD5410   =  121;
  CL_GD6410   =  122;
  CL_GD6412   =  123;

  CL_GD6420   =  124;
  CL_GD6440   =  125;

  WD_PVGA1A   =  130;
  WD_90c00    =  131;
  WD_90c10    =  132;
  WD_90c11    =  133;
  WD_90c20    =  134;
	WD_90c20A   =  135;
  WD_90c22    =  136;
  WD_90c24    =  137;
  WD_90c26    =  138;
  WD_90c30    =  139;
  WD_90c31    =  140;
  WD_90c33    =  141;

  CT_Unknown  =  160;
  CT_450      =  161;
  CT_451      =  162;
  CT_452      =  163;
  CT_453      =  164;
  CT_455      =  165;
  CT_456      =  166;
  CT_457      =  167;
  CT_65520    =  168;
  CT_65530    =  169;
  CT_65510    =  170;

	CL_old_unk  =  180;
  CL_V7_OEM   =  181;
  CL_GD5x0    =  182;
  CL_GD6x0    =  183;

  NCR_Unknown =  190;
  NCR_77c21   =  191;
  NCR_77c22   =  192;
  NCR_77c22e  =  193;
  NCR_77c22ep =  194;

  OAK_Unknown =  200;
  OAK_037     =  201;
  OAK_057     =  202;
  OAK_067     =  203;
  OAK_077     =  204;
  OAK_083     =  205;
  OAK_087     =  206;

  RT_Unknown  =  210;
	RT_3103     =  211;
  RT_3105     =  212;
  RT_3106     =  213;

  S3_Unknown  =  220;
  S3_911      =  221;
  S3_924      =  222;
  S3_801AB    =  223;
  S3_805AB    =  224;
  S3_801C     =  225;
  S3_805C     =  226;
  S3_801D     =  227;
  S3_805D     =  228;
  S3_928C     =  229;
  S3_928D     =  230;
  S3_928E     =  231;
  S3_928PCI   =  232;

  TR_Unknown  =  240;
  TR_8800BR   =  241;
	TR_8800CS   =  242;
  TR_8900B    =  243;
  TR_8900C    =  244;
  TR_9000     =  245;
  TR_8900CL   =  246;
  TR_9000i    =  247;
  TR_8900CXr  =  248;
  TR_LCD9100B =  249;
  TR_GUI9420  =  250;
  TR_LX8200   =  251;
  TR_LCD9320  =  252;
  TR_9200CXi  =  253;

  AH_A        =  260;
  AH_B        =  261;

  AL_2101     =  270;

  CPQ_Unknown =  280;
  CPQ_IVGS    =  281;
	CPQ_AVGA    =  282;
  CPQ_AVPORT  =  283;
  CPQ_QV1024  =  284;
  CPQ_QV1280  =  285;

  MX_86000    =  290;
  MX_86010    =  291;

  GE_5100     =  301;
  GE_5300     =  302;
  GE_6100     =  303;
  GE_6200     =  304;
  GE_6400     =  305;

  PR_2000     =  310;

  IIT_AGX     =  320;

  ET_4Unk     =  330;
  ET_3000     =  331;
	ET_4000     =  332;
  ET_4W32     =  333;
  ET_4W32i    =  334;
  ET_4W32p    =  335;

  V7_Unknown  =  340;
  V7_VEGA     =  341;
  V7_208_13   =  342;
  V7_208A     =  343;
  V7_208B     =  344;
  V7_208CD    =  345;
  V7_216BC    =  346;
  V7_216D     =  347;
  V7_216E     =  348;
  V7_216F     =  349;

  WT_5086     =  361;
  WT_5186     =  362;
  WT_5286     =  363;

	YA_6388     =  370;

  XGA_org     =  380;
  XGA_NI      =  381;

  UMC_408     =  390;

  ATI_Unknown =  400;
  ATI_EGA     =  401;
  ATI_18800   =  402;
  ATI_18800_1 =  403;
  ATI_28800_2 =  404;
  ATI_28800_4 =  405;
  ATI_28800_5 =  406;
  ATI_GUP_3   =  407;
  ATI_GUP_6   =  408;
  ATI_GUP_AX  =  409;
  ATI_GUP_LX  =  410;

  HMC_304     =  420;


type
  charr =array[1..255] of char;
  chptr =^charr;
  intarr=array[1..100] of word;




  {VESA VBE (VGA) record definitions}
  _vbe0=record
			 sign  :longint;       {Must be 'VESA'}
          vers  :word;          {VBE version.}
          oemadr:chptr;
          capab :longint;
          model :^intarr;       {Ptr to list of modes}
          mem   :byte;          {#64k blocks}
          xx:array[0..499] of byte;   {Buffer is too large, as some cards
                                         can return more than 256 bytes}
				end;


  _vbe1=record
          attr  :word;
          wina  :byte;
          winb  :byte;
          gran  :word;
          winsiz:word;
          sega  :word;
			 segb  :word;
			 pagefunc:pointer;
          bytes :word;
          width :word;
          height:word;
          charw :byte;
          charh :byte;
          planes:byte;
          bits  :byte;   {bits per pixel}
          nbanks:byte;
					model :byte;
          banks :byte;
          images:byte;
          res   :byte;
          redinf:word;   {red   - low byte = #bits, high byte = start pos}
          grninf:word;   {green - }
          bluinf:word;   {blue  - }
          resinf:word;

			 x:array[byte] of byte;    {might get trashed by 4F01h}
		  end;
  _vbe1p=^_vbe1;


  {VESA VXE (XGA) record definitions}
  _xbe0=record
          sign:longint;    {must be 'VESA'}
          vers:word;
          oemadr:chptr;
          capab:longint;
					xgas:word;
          xx:array[1..240] of byte;
        end;

  _xbe1=record
          oemadr:chptr;
          capab:longint;
          romadr:longint;
			 memreg:longint;
			 iobase:word;
          vidadr:longint;  {32bit address of video memory}
          adr4MB:longint;
          adr1MB:longint;
          adr64k:longint;
          adroem:longint;
          sizoem:word;
          modep :^intarr;
          memory:word;
          manid :longint;
          xx:array[1..206] of byte;
				end;

  _xbe2=record
          attrib:word;
          bytes :word;
          pixels:word;
          lins  :word;
			 charw :byte;
			 charh :byte;
          planes:byte;
          bits  :byte;
          model :byte;
          images:byte;
          redinf:word;   {red   - low byte = #bits, high byte = start pos}
          grninf:word;   {green - }
          bluinf:word;   {blue  - }
          resinf:word;
          xx:array[1..234] of byte;
        end;

	_AT0=record
         SWvers:word;  {SW version}
         vid_sys,         {Number of video systems}
         cur_vid:word;    {Currently selected video system (1..)}
         curtime:longint; {Date & time of the test}
       end;
		 {This record followed by: (Email),(Name&Address),(Video desc)
						  ,(System),(modenames)}

  _AT2=record
         mode:word;
        Mmode:mmods;
       pixels,
         lins,
        bytes,
         crtc,
         vseg:word;
      Cpixels,
        Clins,
       Cbytes,
				Cvseg:word;
       CMmode:mmods;
      ChWidth,
     ChHeight,
      ExtPixf,
		ExtLinf:byte;
			Vclk,
         Hclk,
         Fclk:real;
        iLace:boolean;
         Flag:byte;
       end;
       {This record followed by: (Comment), (reg values)}

  _AT3=record
         mode:word;
        Mmode:mmods;
         Flag:byte;
       end;
       {This record followed by: (Comment)}

  _ATff=record
          int10,
          int6D,
			 m4a8,   {0:4A8h}
			 fnt8h,
          fnt8l,
          fnt14,
          fnt14x9,
          fnt16,
          fnt16x9:word;
          Base:word;
          size:byte;
        end;

const

  novgamodes=14;
  stdmodetbl:array[1..novgamodes] of modetype=
	    ((md: 0;xres: 40;yres: 25;bytes: 80;memmode:_TEXT)
			,(md: 1;xres: 40;yres: 25;bytes: 80;memmode:_TEXT)
	    ,(md: 2;xres: 80;yres: 25;bytes:160;memmode:_TEXT)
	    ,(md: 3;xres: 80;yres: 25;bytes:160;memmode:_TEXT)
		 ,(md: 4;xres:320;yres:200;bytes: 80;memmode:_cga2)
		 ,(md: 5;xres:320;yres:200;bytes: 80;memmode:_cga2)
	    ,(md: 6;xres:640;yres:200;bytes: 80;memmode:_cga1)
	    ,(md:13;xres:320;yres:200;bytes: 40;memmode:_pl4)
	    ,(md:14;xres:640;yres:200;bytes: 80;memmode:_pl4)
	    ,(md:15;xres:640;yres:350;bytes: 80;memmode:_pl1)
	    ,(md:16;xres:640;yres:350;bytes: 80;memmode:_pl4)
	    ,(md:17;xres:640;yres:480;bytes: 80;memmode:_pl1)
	    ,(md:18;xres:640;yres:480;bytes: 80;memmode:_pl4)
	    ,(md:19;xres:320;yres:200;bytes:320;memmode:_p8));

  colbits:array[mmods] of integer=
               (0,0,0,1,1,1,1,2,2,2,4,4,8,15,16,24,24);
  modecols:array[mmods] of longint=
               (0,0,0,2,2,2,2,4,4,4,16,16,256,32768,65536,16777216,16777216);

  mdtxt:array[mmods] of string[20]=('Text','2 color Text','4 color Text'
								,'Hercules','CGA 2 color','CGA 4 color','Monochrome','2 colors planar'
                ,'4 colors planar','4 colors packed','16 colors planar','16 colors packed'
					 ,'256 colors packed','32K colors','64K colors'
					 ,'16M colors','16M colors');

  mmodenames:array[mmods] of string[4]=('TXT ','TXT2','TXT4','HERC','CGA1','CGA2'
              ,'PL1 ','PL1E','PL2 ','PK2 ','PL4 ','PK4 ','P8  ','P15 ','P16 ','P24 ','P32 ');

  Debug:boolean=false;      {If set step through video tests one by one}
  Auto_test:boolean=false;  {If set run tests automatically}


  {Keys:}
  Ch_Cr       =  $0D;
  Ch_Esc      =  $1B;
  Ch_ArUp     = $148;
  Ch_ArLeft   = $14B;
  Ch_ArRight  = $14D;
  Ch_ArDown   = $150;
  Ch_PgUp     = $149;
	Ch_PgDn     = $151;
  Ch_Ins      = $152;
  Ch_Del      = $153;


var

  vids:word;
  vid:array[1..10] of
      record
        chip:chips;
        id:word;             {instance}
		  IOadr:word;          {I/O adr}
        Xseg:word;
        Phadr:longint;
        version:word;        {version}
        subver:word;         {Subversion}
        DAC_RS2,DAC_RS3:word;{These address bits are fed to the
                              RS2 and RS3 pins of the palette chip}
        dac:word;            {The dac type}
			dacname:string[20];  {The Name of the DACtype}
		  mem:word;            {#kilobytes of video memory}
        features:word;       {Flags for special features}
        sname:string[8];     {Short chip family name}
        name:string[40];     {Full chip name}
      end;



var
  rp:registers;

  video:string[20];
  dacname:string[20];
  _crt:string[20];
  secondary:string[20];

  planes:word;     {number of video planes}

  nomodes:word;
	modetbl:array[1..50] of modetype;



  dotest:array[CHIPS] of boolean;


  CHIP:CHIPS;
  mm:word;           {Video memory in kilobytes}
  vseg:word;         {Video buffer base segment}
  version:word;      {Version of chip or interface}
  subvers:word;      {Subversion, for Unknown versions}
  IOadr:word;        {I/O select address (ATI, XGA..)}
  instance:word;     {ID for XGA and other multi board systems.}
  features:word;     {Flags for special features   (ft_*) }
  biosseg:word;
  DAC_RS2,
  DAC_RS3:word;      {These address bits are fed to the
							 RS2 and RS3 pins of the palette chip}
  dactype:word;
	name:string[40];

  curmode:word;      {Current mode number}
  memmode:mmods;     {current memory mode}
  crtc:word;         {I/O address of CRTC registers}
  pixels:word;       {Pixels in a scanline in current mode}
  lins:word;         {lines in current mode}
  bytes:longint;     {bytes in a scanline}

  force_mm:word;     {Forced memory size in Kbytes}

  extpixfact:word;  {The number of times each pixel is shown}
  extlinfact:word;  {The number of times each scan line is shown}
  charwid   :word;  {Character width in pixels}
  charhigh  :word;  {Character height in scanlines}
  calcpixels,
  calclines,
  calcvseg,
  calcbytes:word;
  calcmmode:mmods;


  vclk,hclk,fclk:real;
  ilace:boolean;




function getkey:word;             {Waits for a key, and returns the keyID}
function peekkey:word;            {Checks for a key, and returns the keyID}

procedure pushkey(k:word);        {Simulates a keystroke}

function strip(s:string):string;       {strip leading and trailing spaces}
function upstr(s:string):string;       {convert a string to upper case}
function istr(w:longint):str10;
function hex2(w:word):str10;
function hex4(w:word):str10;
function dehex(s:string):word;


procedure vio(ax:word);         {INT 10h reg ax=AX. other reg. set from RP
                                 on return rp.ax=reg AX}

procedure viop(ax,bx,cx,dx:word;p:pointer);
                                {INT 10h reg AX-DX, ES:DI = p}

function inp(reg:word):byte;     {Reads a byte from I/O port REG}

procedure outp(reg,val:word);    {Write the low byte of VAL to I/O port REG}

procedure outpw(reg,val:word);    {Write the word byte of VAL to I/O port REG}

function rdinx(pt,inx:word):word;       {read register PT index INX}

procedure wrinx(pt,inx,val:word);       {write VAL to register PT index INX}

procedure modinx(pt,inx,mask,nwv:word);  {In register PT index INX sets
                                          the bits in MASK as in NWV
                                          the other are left unchanged}

procedure setinx(pt,inx,val:word);

procedure clrinx(pt,inx,val:word);

procedure setbank(bank:word);

procedure setRbank(bank:word);

procedure setvstart(x,y:word);       {Set the display start to (x,y)}

function setmode(md:word):boolean;

procedure setdac6;
procedure setdac8;
function setdac15:boolean;
function setdac16:boolean;
function setdac24:boolean;

procedure vesamodeinfo(md:word;vbe1:_vbe1p);

procedure setHWcurmap(VAR map:CursorType);

procedure HWcuronoff(on:boolean);

procedure setHWcurpos(X,Y:word);

procedure setHWcurcol(fgcol,bkcol:longint);

procedure fillrect(xst,yst,dx,dy:word;col:longint);

procedure copyrect(srcX,srcY,dstX,dstY,dx,dy:word);

procedure line(x0,y0,x1,y1:integer;col:longint);


procedure dac2comm;

procedure dac2pel;

function findvideo : Integer;

{procedure AnalyseMode(mode:word; var pixs,lins,bytes,vseg:word;var mmode:mmods);}

function FormatRgs(var b:byte):word;   {Format registers for dump}

function dumpVGAregs:word;

procedure dumpVGAregfile;

function SelectVideo(item:word) : Integer;

implementation

uses crt, IOErrDef, CrtExt;

procedure testdac;forward;


const
	mmmask :array[0..8] of byte=(0,0,0,0,1,3,3,7,15);

  hx:array[0..15] of char='0123456789ABCDEF';


var

  spcreg:word;    {Special register offset (IIT)}
  xgaseg:word;    {Segment address of memory mapped registers}
  Phadr:longint;  {Physical address of video buffer}

  old,curbank:word;

  vgran:word;



procedure disable; (* Disable interupts *)
begin
  inline($fa);  (* CLI instruction *)
end;

procedure enable;  (* Enable interrupts *)
begin
  inline($fb);  (* STI instruction *)
end;


function gtstr(var c:chptr):string;
var x:word;
  s:string;
begin
  s:='';x:=1;
  if c<>NIL then
    while (x<255) and (c^[x]<>#0) do
    begin
      if c^[x]<>#7 then s:=s+c^[x];
      inc(x);
    end;
  gtstr:=s;
end;

const
  key_stack:word=0;    {Stored key stroke 0=none}

function getkey:word;
var c:char;
begin
  if key_stack<>0 then
  begin
    getkey:=key_stack;
    key_stack:=0;
  end
  else begin
    c:=readkey;
    if c=#0 then getkey:=$100+ord(readkey)
            else getkey:=ord(c);
  end;
end;

function peekkey:word;
begin
  if (key_stack=0) and not keypressed then peekkey:=0
                                      else peekkey:=getkey;
end;

procedure pushkey(k:word);  {Simulates a key stroke}
var ch:char;
begin
  key_stack:=k;
  while keypressed do ch:=readkey;
end;


function strip(s:string):string;       {strip leading and trailing spaces}
begin
  while s[length(s)]=' ' do dec(s[0]);
  while copy(s,1,1)=' ' do delete(s,1,1);
  strip:=s;
end;

function upstr(s:string):string;       {convert a string to upper case}
var x:word;
begin
  for x:=1 to length(s) do
    s[x]:=upcase(s[x]);
  upstr:=s;
end;

function istr(w:longint):str10;
var s:str10;
begin
  str(w,s);
  istr:=s;
end;

function hex2(w:word):str10;
begin
  hex2:=hx[(w shr 4) and 15]+hx[w and 15];
end;

function hex4(w:word):str10;
begin
  hex4:=hex2(hi(w))+hex2(lo(w));
end;

function dehex(s:string):word;
var w,x:word;
    c:char;
begin
  w:=0;
  for x:=1 to length(s) do
  begin
    c:=s[x];
    case c of
      '0'..'9':w:=(w shl 4)+(ord(c) and 15);
      'a'..'f','A'..'F':
               w:=(w shl 4)+(ord(c) and 15 +9);
    end;
  end;
	dehex:=w;
end;



procedure vio(ax:word);         {INT 10h reg ax=AX. other reg. set from RP
                                 on return rp.ax=reg AX}
begin
  rp.ax:=ax;
  intr($10,rp);
end;

procedure viop(ax,bx,cx,dx:word;p:pointer);
begin                            {INT 10h reg AX-DX, ES:DI = p}
  rp.ax:=ax;
  rp.bx:=bx;
  rp.cx:=cx;
  rp.dx:=dx;
  rp.di:=ofs(p^);
  rp.es:=seg(p^);
	intr($10,rp);
end;

function inp(reg:word):byte;     {Reads a byte from I/O port REG}
begin
  reg:=port[reg];
  inp:=reg;
end;

procedure outp(reg,val:word);    {Write the low byte of VAL to I/O port REG}
begin
  port[reg]:=Lo(val);
end;

function inpw(reg:word):word;    {Reads a word from I/O port REG}
begin
  reg:=portw[reg];
  inpw:=reg;
end;

procedure outpw(reg,val:word);
begin
  portw[reg]:=val;
end;

function rdinx(pt,inx:word):word;       {read register PT index INX}
var x:word;
begin
  if pt=$3C0 then x:=inp(CRTC+6);    {If Attribute Register then reset Flip-Flop}
  outp(pt,inx);
  rdinx:=inp(pt+1);
end;

procedure wrinx(pt,inx,val:word);       {write VAL to register PT index INX}
var x:word;
begin
  if pt=$3C0 then
  begin
    x:=inp(CRTC+6);
    outp(pt,inx);
		outp(pt,val);
  end
  else begin
    outp(pt,inx);
    outp(pt+1,val);
  end;
end;

procedure wrinx2(pt,inx,val:word);
begin
  wrinx(pt,inx,lo(val));
  wrinx(pt,inx+1,hi(val));
end;

procedure wrinx3(pt,inx:word;val:longint);
begin
  wrinx(pt,inx,lo(val));
  wrinx(pt,inx+1,hi(val));
  wrinx(pt,inx+2,val shr 16);
end;

procedure wrinx2m(pt,inx,val:word); {Write VAL to the index pair (INX,INX+1)}
begin                               {in motorola (big endian) format}
  wrinx(pt,inx,hi(val));
  wrinx(pt,inx+1,lo(val));
end;

procedure wrinx3m(pt,inx:word;val:longint);
begin
  wrinx(pt,inx+2,lo(val));
  wrinx(pt,inx+1,hi(val));
  wrinx(pt,inx,val shr 16);
end;

procedure modinx(pt,inx,mask,nwv:word);  {In register PT index INX sets
                                          the bits in MASK as in NWV
                                          the other are left unchanged}
var temp:word;
begin
  temp:=(rdinx(pt,inx) and (not mask))+(nwv and mask);
	wrinx(pt,inx,temp);
end;

procedure modreg(reg,mask,nwv:word);  {In register REG sets the bits in
                                       MASK as in NWV other are left unchanged}
var temp:word;
begin
  temp:=(inp(reg) and (not mask))+(nwv and mask);
  outp(reg,temp);
end;


procedure setinx(pt,inx,val:word);
var x:word;
begin
  x:=rdinx(pt,inx);
  wrinx(pt,inx,x or val);
end;

procedure clrinx(pt,inx,val:word);
var x:word;
begin
  x:=rdinx(pt,inx);
  wrinx(pt,inx,x and (not val));
end;


function getbios(offs,lnn:word):string;
var s:string;
begin
  s[0]:=chr(lnn);
  move(mem[biosseg:offs],s[1],lnn);
  getbios:=s;
end;



type
  regblk=record
           base:word;
					 nbr:word;
           x:array[0..255] of byte;
         end;

  regtype=record
            chip:chips;
            mmode:mmods;
            mode,pixels,lins,bytes,tridold0d,tridold0e:word;
            attregs:array[0..31] of byte;
            seqregs,grcregs,crtcregs,xxregs:regblk;
            stdregs:array[$3c0..$3df] of byte;
				xgaregs:array[0..15] of byte;
          end;

var
  rgs:regtype;
  oldreg:boolean;


function opentxtfile(var t:text;name:string) : Integer;
begin
	opentxtfile := hError;
	if ioresult=0 then;  {Clear any old error code}
	if HWGraphDataFilePath <> '' then
	if HWGraphDataFilePath[Length(HWGraphDataFilePath)] <> '\'
	then HWGraphDataFilePath := HWGraphDataFilePath + '\';
	Assign(t, HWGraphDataFilePath+name);
	{$i-}
	reset(t);
	{$i+}
	while ioresult <> 0 do
	begin
		WriteLn('Enter path for '+name+' :');
		if ReadString(HWGraphDataFilePath, 79) = NumError then Exit;
		WriteLn;
		if HWGraphDataFilePath <> '' then
		if HWGraphDataFilePath[Length(HWGraphDataFilePath)] <> '\'
		then HWGraphDataFilePath := HWGraphDataFilePath + '\';
		Assign(t, HWGraphDataFilePath+name);
	{$i-}
		Reset(t);
  {$i+}
	end;
  opentxtfile := hOk;
end;





function loadmodes : Integer;   {Load extended modes for this chip}
var
  t:text;
  s,pat:string;
  md,x,xres,yres,err,mreq,byt:word;
  vbe0:_vbe0;
  vbe1:_vbe1;
  xbe1:_xbe1;
  xbe2:_xbe2;
  ok:boolean;

function unhex(s:string):word;
var x:word;
begin
  for x:=1 to 4 do
	 if s[x]>'9' then
		s[x]:=chr(ord(s[x]) and $5f-7);
  unhex:=(((word(ord(s[1])-48) shl 4
			+  word(ord(s[2])-48)) shl 4
			+  word(ord(s[3])-48)) shl 4
			+  word(ord(s[4])-48));
end;

function mmode(s:string;var md:mmods):boolean;
var x:mmods;
	ok:boolean;
begin
  ok:=false;
  for x:=_text to _p32 do
	 if s=mmodenames[x] then
	 begin
		md:=x;
		ok:=true;
	 end;
  mmode:=ok;
end;

function VESAmemmode(model,bits,redinf,grninf,bluinf,resinf:word):mmods;
const
  mode6s=4;
  mode:array[1..mode6s] of mmods=(_p15,_p16,_p24,_p32);
  blui:array[1..mode6s] of word =(   5,   5,    8,    8);
  grni:array[1..mode6s] of word =($505,$506, $808, $808);
  redi:array[1..mode6s] of word =($A05,$B05,$1008,$1008);
  resi:array[1..mode6s] of word =($f01,   0,    0,$1808);
var x:word;
begin
  VESAmemmode:=_text;  {catch weird modes}
  if (bits=15) and (resinf=0) then resinf:=$F01;   {Bloody ATI Vesa driver @#$}
  case model of
	 0:VESAmemmode:=_text;
	 1:case bits of
		  1:VESAmemmode:=_cga1;
		  2:VESAmemmode:=_cga2;
		end;
	 2:memmode:=_herc;
	 3:case bits of
		  2:VESAmemmode:=_pl2;
		  4:VESAmemmode:=_pl4;
		end;
	 4:case bits of
		  4:VESAmemmode:=_pk4;
		  8:VESAmemmode:=_p8;
		 15:VESAmemmode:=_p15;
		 16:VESAmemmode:=_p16;
		 24:VESAmemmode:=_p24;
		end;
	 5:;
	 6:for x:=1 to mode6s do
		if (redinf=redi[x]) and (grninf=grni[x]) and (bluinf=blui[x])
		  and (resinf=resi[x]) then VESAmemmode:=mode[x];
	 7:;
  end;
end;


procedure addmode(md,xres,yres,bytes:word;memmode:mmods);
begin
  inc(nomodes);
  modetbl[nomodes].md     :=md;
  modetbl[nomodes].xres   :=xres;
  modetbl[nomodes].yres   :=yres;
  modetbl[nomodes].bytes  :=bytes;
  modetbl[nomodes].memmode:=memmode;
end;

begin
  loadmodes := hError;
  nomodes:=0;
  case chip of
   __vesa:begin
            vbe0.sign:=$41534556;    (* VESA *)
            viop($4f00,0,0,0,@vbe0);

               {S3 VESA driver can return wrong segment if run with QEMM}
            IF seg(vbe0.model^)=$e000 then
              vbe0.model:=ptr($c000,ofs(vbe0.model^));
            x:=1;
            while vbe0.model^[x]<>$FFFF do
            begin
              vesamodeinfo(vbe0.model^[x],@vbe1);
              if (vbe1.attr and 1)<>0 then
              begin
                memmode:=VESAmemmode(vbe1.model,vbe1.bits,vbe1.redinf
                   ,vbe1.grninf,vbe1.bluinf,vbe1.resinf);
                addmode(vbe0.model^[x],vbe1.width,vbe1.height,vbe1.bytes,memmode);
              end;
              inc(x);
            end;
          end;
    __xbe:begin
            viop($4E01,0,0,instance,@xbe1);
            x:=1;
            while xbe1.modep^[x]<>$FFFF do
            begin
              viop($4E02,0,xbe1.modep^[x],instance,@xbe2);
              if (rp.ax=$4E) and ((xbe2.attrib and 1)>0) then
              begin
                memmode:=VESAmemmode(xbe2.model,xbe2.bits,xbe2.redinf
                   ,xbe2.grninf,xbe2.bluinf,xbe2.resinf);
                addmode(xbe1.modep^[x],xbe2.pixels,xbe2.lins,xbe2.bytes,memmode);
              end;
              inc(x);
            end;

          end;
  else
    pat:='['+header[chip]+']';
	 if opentxtfile(t, DataFileName) <> hOk then Exit;
	 s:=' ';
    while (not eof(t)) and (s<>pat) do readln(t,s);
    s:=' ';
    readln(t,s);
    while (s[1]<>'[') and (s<>'') do
    begin
      md:=unhex(copy(s,1,4));
      ok:=mmode(copy(s,6,4),memmode);
      val(copy(s,11,5),xres,err);
      val(copy(s,17,4),yres,err);
      case memmode of
 _text,_text2,_text4:bytes:=xres*2;
   _pl1e, _herc,_cga1,_pl1:
                     bytes:=xres shr 3;
     _pk2,_pl2,_cga2:bytes:=xres shr 4;
           _pl4,_pk4:bytes:=xres shr 1;
					  _p8:bytes:=xres;
           _p15,_p16:bytes:=xres*2;
                _p24:bytes:=xres*3;
                _p32:bytes:=xres*4;
      else
      end;
      case dactype of
        _dacCEG,
          _dac8:if memmode>_p8 then ok:=false;
         _dac15:if memmode>_p15 then ok:=false;
         _dac16:if memmode>_p16 then ok:=false;
      end;
      case version of
        S3_911,S3_924:if (md>$105) and (md<$200) then ok:=false;
    ATI_Unknown..ATI_GUP_LX:
          if md<$100 then
          begin
            rp.bx:=$5506;
            rp.bp:=$FFFF;
				rp.si:=0;
            vio($1200+md);
            if rp.bp=$FFFF then ok:=false;
          end;
      end;
      val(copy(s,22,5),byt,err);
      if (err=0) and (byt>0) then bytes:=byt;
      mreq:=(longint(bytes)*yres+1023) div 1024;
      case memmode of
        _pl4:bytes:=xres shr 3;
      end;
      if ok and (mm>=mreq) then
        addmode(md,xres,yres,bytes,memmode);
      readln(t,s);
    end;
    close(t);
  end;
  loadmodes := hOk;
end;

function SelectVideo(item:word) : Integer;
begin
  SelectVideo := hError;
  chip    :=vid[item].chip;
  instance:=vid[item].id;
  IOadr   :=vid[item].IOadr;
  version :=vid[item].version;
  dactype :=vid[item].dac;
  dacname :=vid[item].dacname;
  mm      :=vid[item].mem;
  features:=vid[item].features;
  name    :=vid[item].name;
  XGAseg  :=vid[item].xseg;
  phadr   :=vid[item].phadr;
  subvers :=vid[item].subver;
  DAC_RS2 :=vid[item].DAC_RS2;
  DAC_RS3 :=vid[item].DAC_RS3;
  if loadmodes <> hOk then Exit;
  video:=header[chip];
  SelectVideo := hOk;
end;


function addvideo : Integer;
var nam,s:string;
	 t:text;
	 nr,err:word;
begin
  addvideo := hError;
  nam:='';
  if version<>0 then
  begin
	 if opentxtfile(t, ChipsFileName) <> hOk then Exit;
	 while not eof(t) do
	 begin
		readln(t,s);
		val(copy(s,1,4),nr,err);
		if nr=version then
		begin
		  nam:=copy(s,7,255);
		  if nam[length(nam)]='(' then nam:=nam+hex4(subvers)+')';
		end;
	 end;
	 close(t);
  end;
  nam:=nam+' '+name;
  if dactype=0 then testdac;
  if force_mm<>0 then mm:=force_mm;
  inc(vids);
  vid[vids].chip    :=chip;
  vid[vids].id      :=instance;   {instance (XBE)}
  vid[vids].ioadr   :=IOadr;      {base I/O adr}
  vid[vids].version :=version;
  vid[vids].dac     :=dactype;
  vid[vids].dacname :=dacname;
  vid[vids].mem     :=mm;
  vid[vids].features:=features;
  vid[vids].name    :=nam;
  vid[vids].xseg    :=XGAseg;
  vid[vids].phadr   :=phadr;
  vid[vids].subver  :=subvers;
  vid[vids].DAC_RS2 :=DAC_RS2;
  vid[vids].DAC_RS3 :=DAC_RS3;
  vid[vids].sname   :=chipnam[chip];
  addvideo := hOk;
end;

procedure UNK(vers,code:word);
begin
  version:=vers;
  subvers:=code;
end;

procedure SetVersion(vers:word;nam:string);
begin
  Version:=vers;
  name:=nam;
end;


procedure SetDAC(typ:word;Name:string);
begin
  dactype:=typ;
  dacname:=name;
end;


function tstrg(pt,msk:word):boolean;       {Returns true if the bits in MSK
                                            of register PT are read/writable}
var old,nw1,nw2:word;
begin
  old:=inp(pt);
  outp(pt,old and not msk);
  nw1:=inp(pt) and msk;
  outp(pt,old or msk);
  nw2:=inp(pt) and msk;
  outp(pt,old);
  tstrg:=(nw1=0) and (nw2=msk);
end;

function testinx2(pt,rg,msk:word):boolean;   {Returns true if the bits in MSK
                                              of register PT index RG are
                                              read/writable}
var old,nw1,nw2:word;
begin
  old:=rdinx(pt,rg);
  wrinx(pt,rg,old and not msk);
  nw1:=rdinx(pt,rg) and msk;
  wrinx(pt,rg,old or msk);
  nw2:=rdinx(pt,rg) and msk;
  wrinx(pt,rg,old);
  testinx2:=(nw1=0) and (nw2=msk);
end;

function testinx(pt,rg:word):boolean;     {Returns true if all bits of
                                           register PT index RG are
                                           read/writable.}
var old,nw1,nw2:word;
begin
  testinx:=testinx2(pt,rg,$ff);
end;

procedure dac2pel;    {Force DAC back to PEL mode}
begin
  if inp($3c8)=0 then;
end;

var
  daccomm:word;

function trigdac:word;  {Reads $3C6 4 times}
var x:word;
begin
  x:=inp($3c6);
  x:=inp($3c6);
  x:=inp($3c6);
  trigdac:=inp($3c6);
end;

procedure dac2comm;    {Enter command mode of HiColor DACs}
begin
  dac2pel;
  daccomm:=trigdac;
end;

function getdaccomm:word;
begin
  if DAC_RS2<>0 then getdaccomm:=inp($3C6+DAC_RS2)
  else begin
    dac2comm;
    getdaccomm:=inp($3C6);
    dac2pel;
  end;
end;



procedure checkmem(mx:word);
var
  fail:boolean;
  ma:array[0..99] of byte;
  x:word;
  OldBank : Byte;
begin
  memmode:=_p8;
  OldBank := curbank;
  fail:=true;
  while (mx>1) and fail do
  begin
	 setbank(mx-1);
	 move(mem[SegA000:0],ma,100);
	 for x:=0 to 99 do
		mem[SegA000:x]:=ma[x] xor $aa;
	 setbank(mx-1);
	 fail:=false;
	 for x:=0 to 99 do
		if mem[SegA000:x]<>ma[x] xor $aa then fail:=true;
	 move(ma,mem[SegA000:0],100);
	 if not fail then
	 begin
		setbank((mx shr 1)-1);
		for x:=0 to 99 do
		  mem[SegA000:x]:=ma[x] xor $55;
		setbank(mx-1);
		fail:=true;
		for x:=0 to 99 do
		  if mem[SegA000:x]<>ma[x] xor $55 then fail:=false;
		move(ma,mem[SegA000:0],100);
	 end;
	 mx:=mx shr 1;
  end;
  mm:=mx*128;
  SetBank(OldBank);
end;



    (* Analyse the current mode *)

procedure AnalyseMode; {(mode:word;var pixs,lins,bytes,vseg:word;var mmode:mmods);}


procedure dumprg(base,start,ende:word;var rg:regblk);
var six,ix:word;
  same:boolean;
begin
  rg.base:=base;
  six:=inp(base);
  outp(base,0);
  ix:=inp(base) xor 255;
  outp(base,255);
  ix:=ix and inp(base);

  if ende=0 then
    if ix>127 then ende:=255
    else if ix>63 then ende:=127
    else if ix>31 then ende:=63
    else if ix>15 then ende:=31
    else if ix>7 then ende:=15
    else ende:=7;
  for ix:=start to ende do
    rg.x[ix]:=rdinx(base,ix);
  rg.nbr:=ende;
  outp(base,six);
  same:=true;
  while (rg.nbr>7) and same do    {Check for doubles}
  begin
    six:=succ(rg.nbr) div 2;
    for ix:=0 to six-1 do
      if rg.x[ix]<>rg.x[ix+six] then same:=false;
    if same then rg.nbr:=rg.nbr div 2;
  end;

end;

procedure DumpTridOldRegs;
begin
  wrinx(SEQ,$B,0);
  rgs.tridold0d:=rdinx(SEQ,$D);
  rgs.tridold0e:=rdinx(SEQ,$E);
  oldreg:=true;
end;

procedure DumpXGAregs;
var x:word;
begin
  dumprg(IOadr+10,0,0,rgs.xxregs);
  for x:=0 to 15 do
    rgs.xgaregs[x]:=inp(IOadr+x);
end;
const
  tridclk:array[0..15] of real=(25.175,28.322,44.9,36,57.272,65,50.35,40
			      ,88,98,118.89,108,72,77,80,75);
  triddiv:array[0..3] of real=(1,2,4,1.5);
  HMCclk:array[0..7] of real=(25.175,28.322,0,37.2,40,44.9,0,65);
  v7clk:array[0..7] of real=(25.175,28.322,30,32.514,34,36,38,40);
  aticlk1:array[0..7] of real=(50.175,56.644,0,44.9,44.9,50.157,0,36);
  aticlk2:array[0..15] of real=(42.954,48.771,16.657,36,50.35,56.64
       ,28.322,44.9,30.24,32,37.5,39,40,56.644,75,65);
  atidiv:array[0..3] of integer=(1,2,3,4);
  WDclk:array[0..7] of real=(40,50,0,44.9,25.175,28.322,65,36.242);
var x,m,wid,wordadr,pixwid,clksel:word;
    force256,graph:boolean;
    vtot:word;
begin

  case chip of  (* Enable ext *)
    __S3:begin
	   wrinx(crtc,$38,$48);
	   wrinx(crtc,$39,$A5);
	 end;
  end;
  fillchar(rgs,sizeof(rgs),0);
  oldreg:=false;
  vclk:=0;
  for x:=$3C2 to $3DF do rgs.stdregs[x]:=inp(x);
  rgs.stdregs[$3DA]:=inp(CRTC+6);
  rgs.stdregs[$3C0]:=inp($3C0);
  for x:=0 to 31 do rgs.attregs[x]:=rdinx($3C0,x);
  x:=rdinx($3C0,$30);
  rgs.mode:=curmode;
  dumprg(CRTC,0,0,rgs.crtcregs);
  dumprg(SEQ,0,0,rgs.seqregs);
  dumprg(GRC,0,0,rgs.grcregs);
  case chip of
    __ati1,__ati2,__atiGUP:
	  dumprg(IOadr,$A0,$BF,rgs.xxregs);
  __chips451,__chips452,__chips453:
	  dumprg(IOadr,0,0,rgs.xxregs);
 __compaq:begin
	    for x:=1 to 15 do
	      for m:=0 to 15 do
		rgs.xxregs.x[(x-1)*16+m]:=inp(x*$1000+$3C0+m);
	    rgs.xxregs.base:=$3C;
	    rgs.xxregs.nbr:=240;

	  end;
 __ET4W32:dumprg($217A,0,0,rgs.xxregs);
    __hmc:dumprg(SEQ,$0,$FF,rgs.xxregs);
  __oak87,
    __oak:dumprg($3DE,0,0,rgs.xxregs);
    __trid89,__tridBR,__tridCS:
	  DumpTridOldRegs;
 __iitagx:if (inp(IOadr) and 4)=0 then DumpTridOldRegs
	  else DumpXGAregs;
    __xga:DumpXGAregs;
  else rgs.xxregs.base:=0;
  end;
  case chip of  (* Disable ext *)
    __S3:begin
	   wrinx(crtc,$38,0);
	    wrinx(crtc,$39,$5A);
	 end;
  end;

  m:=rgs.grcregs.x[6];
  case (m shr 2) and 3 of
  0,1:calcvseg:=SegA000;
    2:calcvseg:=$b000;
    3:calcvseg:=$b800;
  end;
  clksel:=(rgs.stdregs[$3CC] shr 2) and 3;

  begin
    ilace:=false;
    extpixfact:=1;
    extlinfact:=1;

    calclines:=rgs.crtcregs.x[$12]+1;
    x:=rgs.crtcregs.x[7];
    if (x and 2)<>0 then inc(calclines,256);
    if (x and 64)<>0 then inc(calclines,512);
    pixwid:=8;
    calcpixels:=rgs.crtcregs.x[1]+1;
    force256:=false;
    vtot:=rgs.crtcregs.x[0]+5;

    graph:=(rgs.attregs[$10] and 1)>0;
    if graph then
    begin
      extlinfact:=(rgs.crtcregs.x[9] and $1F)+1;
      if (rgs.crtcregs.x[9] and $80)>0 then extlinfact:=extlinfact*2;
    end
    else begin
      if (rgs.attregs[$10] and 4)>0 then charwid:=9 else charwid:=8;
      charhigh:=(rgs.crtcregs.x[9] and $1f)+1;
    end;

    wid:=rgs.crtcregs.x[$13];
    wordadr:=2;
    if (rgs.crtcregs.x[$14] and 64)<>0 then wordadr:=8
    else if (rgs.crtcregs.x[$17] and 64)=0 then wordadr:=4;
    case chip of
    __aheada,__aheadb:
	     begin
	       if (rgs.grcregs.x[$1c] and 12)=12 then ilace:=true;
	       if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=16;

	     end;
      __ati1:begin
	       if (rgs.xxregs.x[$B2] and 1)<>0 then ilace:=true;
	       if (rgs.xxregs.x[$B2] and 64)>0 then inc(clksel,4);
	       if (rgs.xxregs.x[$B0] and $20)>0 then
	       begin
		 force256:=true;
		 wordadr:=8;
	       end;
	       vclk:=aticlk1[clksel]/atidiv[rgs.xxregs.x[$B8] shr 6];
	     end;
    __atiGUP,
      __ati2:begin
	       if (rgs.xxregs.x[$BE] and 2)<>0 then ilace:=true;
	       if (rgs.xxregs.x[$B0] and $20)>0 then
	       begin
		 force256:=true;
		 wordadr:=16;
	       end;
	       if version=ATI_18800_1 then
	       begin
		 if (rgs.xxregs.x[$BE] and 16)>0 then inc(clksel,4);
		 vclk:=aticlk1[clksel];
	       end
	       else begin
		 if (rgs.xxregs.x[$B9] and 2)>0 then inc(clksel,4);
		 if (rgs.xxregs.x[$BE] and 16)>0 then inc(clksel,8);
		 vclk:=aticlk2[clksel];
	       end;
	       vclk:=vclk/atidiv[rgs.xxregs.x[$B8] shr 6];
	     end;
    __al2101:begin
	       if ((rgs.grcregs.x[$C] and $10)<>0) then wordadr:=wordadr shl 1;
	       if (rgs.crtcregs.x[$19] and 1)<>0 then
	       begin
		 ilace:=true;
		 wordadr:=wordadr shr 1;
	       end;
	     end;
  __chips451,__chips453,
  __chips452:begin
	       if (rgs.xxregs.x[$D] and 1)<>0 then inc(wid,256);
	       if (rgs.seqregs.x[4] and 8)<>0 then
	       begin
		 wordadr:=8;
		 calcpixels:=calcpixels shr 1;
	       end;
	     end;
     __cir54:begin
	       if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=8;
	       if (rgs.crtcregs.x[$1B] and 16)<>0 then inc(wid,256);
	       if (rgs.crtcregs.x[$1A] and 1)<>0 then ilace:=true;
	       vclk:=(14.31818*rgs.seqregs.x[$B+clksel])/(rgs.seqregs.x[$1B+clksel] shr 1);
	       if (rgs.seqregs.x[$1B+clksel] and 1)>0 then vclk:=vclk/2;
	       case (rgs.seqregs.x[7] and 6) of
		 2:vclk:=vclk/2;
		 4:vclk:=vclk/3;
	       end;
	     end;
     __cir64:begin
	       if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=8;
	       if (rgs.grcregs.x[$82] and 7)=2 then pixwid:=4;
	     end;
    __compaq:begin
	       if (rgs.grcregs.x[$F] and $F0)=0 then wordadr:=8;
	       if (rgs.grcregs.x[$42] and 1)>0 then inc(wid,256);
	       if (rgs.crtcregs.x[$14] and 64)>0 then pixwid:=4;
	     end;
    __ET3000:begin
	       if (rgs.crtcregs.x[$25] and $80)>0 then ilace:=true;
	       if (rgs.grcregs.x[5] and $40)>0 then wordadr:=16;
	       if (rgs.seqregs.x[7] and $40)>0 then
	       begin
		 pixwid:=pixwid*2;
		 wordadr:=wordadr*2;
	       end;
	     end;
    __ET4w32,
    __ET4000:if (rgs.crtcregs.x[$3f] and 128)<>0 then inc(wid,256);
     __genoa:if (rgs.crtcregs.x[$2F] and 1)<>0 then ilace:=true;
       __hmc:begin
               IF (rgs.xxregs.x[$E7] and 1)>0 then ilace:=true;
               if (rgs.xxregs.x[$E7] and 2)>0 then force256:=true;
               if (rgs.xxregs.x[$E7] and 64)>0 then inc(clksel,4);
               vclk:=HMCclk[clksel];
             end;
    __iitagx:if (inp(IOadr) and 4)=0 then
	     begin
	       if (rgs.tridold0d and 16)<>0 then wordadr:=wordadr*2;
	       if (rgs.seqregs.x[4] and 8)>0 then pixwid:=4;
	     end
	     else begin
	       calcpixels:=rgs.xxregs.x[$13]*256+rgs.xxregs.x[$12]+1;
	       pixwid:=8;
	       calclines :=rgs.xxregs.x[$23]*256+rgs.xxregs.x[$22]+1;
	       wid :=rgs.xxregs.x[$44]*256+rgs.xxregs.x[$43];
	       wordadr:=8;
	     end;
      __mxic:if (rgs.seqregs.x[$F0] and 3)=3 then ilace:=true;
       __NCR:begin
	       if (rgs.seqregs.x[$20] and 2)<>0 then
	       begin
		 force256:=true;
		 wordadr:=8;
	       end;
	       if (rgs.seqregs.x[$1F] and $10)<>0 then
		 case rgs.seqregs.x[$1F] and 15 of
		   0:pixwid:=4;
		  11:pixwid:=16;
		 else pixwid:=(rgs.seqregs.x[$1F] and 15)+6;
		 end;
	       if (rgs.crtcregs.x[$30] and 2)<>0 then inc(calcpixels,256);
	       if (rgs.crtcregs.x[$30] and $10)<>0 then
	       begin
		 ilace:=true;
		 extlinfact:=1;
	       end;
	     end;
       __oak:begin
	       if (rgs.xxregs.x[$14] and 128)<>0 then ilace:=true;
	       if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=16;
					  {Cheat for 256 color mode}
	     end;
     __oak87:begin
	       if (rgs.xxregs.x[$14] and 128)<>0 then ilace:=true;
	       if (rgs.seqregs.x[4] and 8)<>0 then
		 if (rgs.xxregs.x[$21] and 4)>0 then wordadr:=16
						else pixwid:=4;
	     end;
     __p2000:begin
	       if (rgs.grcregs.x[$13] and 64)<>0 then
	       begin
		 wordadr:=wordadr shr 1;
		 ilace:=true;
	       end;
	       if (rgs.grcregs.x[$21] and 32)<>0 then inc(wid,256);
	     end;
  __paradise:begin

	       if (version>=WD_90c00) and ((rgs.crtcregs.x[$2D] and $20)<>0) then ilace:=true;
	       if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=8;
					  {Cheat for 256 color mode}
	       if (rgs.grcregs.x[$C] and 2)>0 then inc(clksel,4);
	       vclk:=WDclk[clksel];
	       if (version>=WD_90c33) and ((rgs.crtcregs.x[$3E] and $20)>0) then inc(vtot,256);
	     end;
   __realtek:begin
	       if (rgs.seqregs.x[4] and 8)<>0 then pixwid:=4;
	       if (rgs.grcregs.x[$C] and $10)<>0 then
	       begin
		 pixwid:=pixwid*2;
		 wid:=wid*2;
	       end;
	       if (rgs.crtcregs.x[$19] and 1)<>0 then
	       begin
		 ilace:=true;
		 wid:=wid div 2;
	       end;
	     end;
	__s3:begin
	       if (rgs.crtcregs.x[$42] and $20)<>0 then ilace:=true;
	       if (rgs.crtcregs.x[$43] and 4)<>0   then inc(wid,256);
	       if (rgs.crtcregs.x[$43] and 128)<>0 then pixwid:=pixwid*2;
	       if (rgs.seqregs.x[4] and 8)<>0 then wordadr:=8 else wordadr:=2;
	       if (rgs.attregs[$10] and 1)=0 then wid:=wid*2;
	     end;
    __tridCS,
    __trid89:begin
	       if (rgs.tridold0d and 16)<>0 then wordadr:=wordadr*2
	       else if (rgs.seqregs.x[4] and 8)>0 then pixwid:=pixwid div 2;
	       if (rgs.crtcregs.x[$1e] and 4)<>0 then
	       begin
		 ilace:=true;
		 wordadr:=wordadr div 2;
	       end;
	       if (rgs.tridold0E and $10)>0 then inc(clksel,8)
	       else if (rgs.seqregs.x[$D] and 1)>0 then inc(clksel,4);
	       vclk:=tridclk[clksel]/triddiv[(rgs.seqregs.x[$D] shr 1) and 3];
	     end;
       __UMC:begin
	       if (rgs.crtcregs.x[$2F] and 1)>0 then
	       begin
		 ilace:=true;
		 wordadr:=wordadr div 2;
	       end;
	       if (rgs.crtcregs.x[$33] and $10)>0 then wordadr:=16;
	     end;
    __video7:begin
	       if (rgs.seqregs.x[$E0] and $10)<>0 then ilace:=true;
	       vclk:=v7clk[(rdinx(SEQ,$A4) shr 2) and 7];
	     end;
       __xbe,
       __xga:begin
	       calcpixels:=rgs.xxregs.x[$13]*256+rgs.xxregs.x[$12]+1;
	       pixwid:=8;
	       calclines:=rgs.xxregs.x[$23]*256+rgs.xxregs.x[$22]+1;
	       wid :=rgs.xxregs.x[$44]*256+rgs.xxregs.x[$43];
	       wordadr:=8;
	     end;
    end;
    if ilace then calclines:=calclines*2;
    if (rgs.attregs[$10] and 1)=0 then  {Text}
    begin
      calclines:=calclines div ((rgs.crtcregs.x[9] and $1F)+1);
      if (rgs.attregs[$10] and 2)=0 then calcmmode:=_TEXT
				    else calcmmode:=_TEXT4;
      pixwid:=charwid;
    end
    else begin
      if (rgs.crtcregs.x[$17] and 1)=0 then {CGA}
      begin
	if (rgs.crtcregs.x[$17] and $40)>0 then calcmmode:=_cga1
					   else calcmmode:=_cga2;
	extlinfact:=extlinfact shr 1;
      end
      else if ((rgs.attregs[$10] and 64)=0) and ((rgs.grcregs.x[5] and 64)=0)
       and not force256 then  {16 color}
      begin
	if {((rgs.crtcregs.x[$17] and $20)=0)
	 or} ((rgs.attregs[$10] and 2)>0) then calcmmode:=_pl1
	else if (rgs.attregs[$12]=5) then
	begin
	  calcmmode:=_pl2;
	  pixwid:=pixwid*2;
	end
	else if (rgs.seqregs.x[4] and 8)>0 then calcmmode:=_pk4
					   else calcmmode:=_pl4;
      end
      else begin
	calcmmode:=_p8;
	if dactype>_dac8 then
	begin
	  x:=getdaccomm;

	  case dactype of
	    _dac15:if x>127 then calcmmode:=_p15;
	    _dac16:case (x and $c0) of
		     $80:calcmmode:=_p15;
		     $c0:calcmmode:=_p16;
		   end;
	  _dacss24:begin
		 (*    while x<>$8e do x:=inp($3C6); *)
		     x:=inp($3C6);
		     rgs.stdregs[$3c1]:=x;
		     case x of
		      $a6:calcmmode:=_p16;
		      $A0:calcmmode:=_p15;
		      $9E:calcmmode:=_p24;
		     end;
		   end;
	   _dacatt:case (x and $E0) of
		 $80,$A0:calcmmode:=_p15;
		     $C0:calcmmode:=_p16;
		     $E0:calcmmode:=_p24;
		   end;
	 _dacadac1:case (x and $C7) of
		     $C1:calcmmode:=_p16;
		     $C5:calcmmode:=_p24;
		     $80:calcmmode:=_p15;
		   end;
	  _dacSC24:case (x and $E0) of
		 $80,$A0:calcmmode:=_p15;
		 $C0,$E0:calcmmode:=_p16;
		     $60:calcmmode:=_p24;
		   end;
	  _dacCL24:case x of
		     $F0:calcmmode:=_p15;
		     $E1:calcmmode:=_p16;
		     $E5:calcmmode:=_p24;
		   end;
	   _dacmus:case (x and $e0) of
		     $a0:calcmmode:=_p15;
		     $c0:calcmmode:=_p16;
		     $e0:calcmmode:=_p24;
		   end;
	   _dacalg:if (rgs.crtcregs.x[$19] and 16)<>0 then calcmmode:=_p16;
         _dacBt484:case inp($3C8+DAC_RS3) and $78 of
                     $10:calcmmode:=_p32;
                     $30:calcmmode:=_p15;
                     $38:calcmmode:=_p16;
                   end;
	  end;
	  if (dactype<>_dacCL24) and (dactype<>_dacBt484) then
	    case calcmmode of               {Adjust for HiColor}
	  _p15,_p16:calcpixels:=calcpixels div 2;
	       _p24:calcpixels:=calcpixels div 3;
	    end;
	end;
      end;
      calcpixels:=calcpixels*pixwid;
    end;
    calcbytes:=wid*wordadr;
  end;
  if (rgs.seqregs.x[1] and 8)>0 then vclk:=vclk/2;
  if vclk>0 then
  begin
    hclk:=(vclk*1000)/(vtot*pixwid);
    x:=rgs.crtcregs.x[6]+2;
    if (rgs.crtcregs.x[7] and 1)>0 then inc(x,256);
    if (rgs.crtcregs.x[7] and $20)>0 then inc(x,512);
    fclk:=hclk*1000/x;
  end;
  if extlinfact>0 then calclines:=calclines div extlinfact;

  rgs.bytes :=calcbytes;
  rgs.pixels:=calcpixels;
  rgs.lins  :=calclines;
  rgs.mmode :=calcmmode;
  rgs.chip  :=chip;
end;



procedure wrregs(var rg:regblk);
var x:word;
begin
  write(hex4(rg.base)+':');
  for x:=0 to rg.nbr do
  begin
    if (x mod 25=0) and (x>0) then
      write('('+hex2(x)+'):');

    write(' '+hex2(rg.x[x]));
  end;
  writeln;
end;

function dumpVGAregs:word;
var x:word;
begin
  textmode($103);  {Set 43/50 line text mode}
  writeln('Mode: '+hex2(rgs.mode)+'h Pixels: '+istr(rgs.pixels)+' lines: '+istr(rgs.lins)
       +' bytes: '+istr(rgs.bytes)+' colors: '+istr(modecols[rgs.mmode]));
  writeln;
  if oldreg then writeln('SEQ (OLD): 0Dh: ',hex2(rgs.tridold0d)
				  ,' 0Eh: ',hex2(rgs.tridold0e));

  for x:=$3C0 to $3CF do write(' '+hex2(rgs.stdregs[x]));
  writeln;
  for x:=$3D0 to $3DF do write(' '+hex2(rgs.stdregs[x]));
  writeln;
  write('03C0:');
  for x:=0 to 31 do
  begin
    if x=25 then write('(19):');
    write(' '+hex2(rgs.attregs[x]));
  end;
  writeln;
  wrregs(rgs.seqregs);
  wrregs(rgs.grcregs);
  wrregs(rgs.crtcregs);
  if rgs.xxregs.base<>0 then
  begin
    if (rgs.xxregs.base and $ff8f)=$210A then
    begin
      write(hex4(rgs.xxregs.base and $fff0)+':');
      for x:=0 to 15 do write(' '+hex2(rgs.xgaregs[x]));
      writeln;
    end;
    wrregs(rgs.xxregs);
  end;
  writeln;
  dumpVGAregs:=getkey;
end;

function FormatRgs(var b:byte):word;   {Format registers for dump}
type
  barr=array[1..2000] of byte;
var
  blk:^barr;
  bts,x:word;

procedure appb(b:byte);
begin
  inc(bts);
  blk^[bts]:=b;
end;

procedure appw(w:word);
begin
  appb(lo(w));
  appb(hi(w));
end;

procedure apprgs(var r:regblk);
var x:word;
begin
  appw(1);
  appw(r.base);
  appb(0);
  appb(r.nbr);
  for x:=0 to r.nbr do appb(r.x[x]);
end;

begin
  blk:=@b;
  bts:=0;
  appw(1);
  appw($3C0);
  appb(0);
  appb(31);
  for x:=0 to 31 do appb(rgs.attregs[x]);
  apprgs(rgs.seqregs);
  apprgs(rgs.grcregs);
  apprgs(rgs.crtcregs);
  if rgs.xxregs.base<>0 then apprgs(rgs.xxregs);
  if oldreg then
  begin
    appw($FF);
    appw(0);
    appb(rgs.tridold0d);
    appw($FF);
    appw(1);
    appb(rgs.tridold0e);
  end;
  if (rgs.xxregs.base and $FF8F)=$210A then
  begin
    appw(16);
    appw(rgs.xxregs.base-$A);
    for x:=0 to 15 do appb(rgs.xgaregs[x]);
  end;
  appw($3C2);
  appb(rgs.stdregs[$3C2]);
  appw(8);
  appw($3C6);
  for x:=$3C6 to $3CD do appb(rgs.stdregs[x]);
  appw(8);
  appw(crtc+4);
  for x:=$3D8 to $3DF do appb(rgs.stdregs[x]);
  appw(0);
  FormatRgs:=bts;
end;


procedure dumpVGAregfile;
var
  f:file of regtype;
begin
  assign(f,'register.vga');
  {$i-}
  reset(f);
  {$i+}
  if ioresult=0 then System.seek(f,System.filesize(f)) else rewrite(f);
  write(f,rgs);
  close(f);
end;





   (*  Tests for various adapters  *)


function _ahead : Integer;
var old:word;
begin
  _ahead := hError;
  old:=rdinx(GRC,$F);
  wrinx(GRC,$F,0);
  if not testinx2(GRC,$C,$FB) then
  begin
	 wrinx(GRC,$F,$20);
	 if testinx2(GRC,$C,$FB) then
	 begin
		case rdinx(GRC,$F) and 15 of
	0:begin
		 Version:=AH_A;
		 chip:=__aheadA;
	  end;
	1:begin
		 Version:=AH_B;
		 chip:=__aheadB;
		 features:=ft_rwbank;
	  end;
		end;
		case rdinx(GRC,$1F) and 3 of
	0:mm:=256;
	1:mm:=512;
	2:;
	3:mm:=1024;
		end;
		if addvideo <> hOk then begin wrinx(GRC,$F,old); Exit end;
	 end;
  end;
  wrinx(GRC,$F,old);
  _ahead := hOk;
end;

function _al2101 : Integer;
begin
  _al2101 := hError;
  old:=rdinx(crtc,$1A);
  clrinx(crtc,$1A,$10);
  if not testinx(crtc,$19) then
  begin
	 setinx(crtc,$1A,$10);
	 if testinx(crtc,$19) and testinx2(crtc,$1A,$3F) then
	 begin
		Version:=AL_2101;
		chip:=__al2101;
		features:=ft_rwbank+ft_blit+ft_cursor+ft_line;
		case rdinx(crtc,$1e) and 3 of
	0:mm:=256;
	1:mm:=512;
	2:mm:=1024;
	3:mm:=2048;
		end;
		SetDAC(_dacalg,'ALG1101');
		if addvideo <> hOk then begin wrinx(crtc,$1A,old); Exit end;
	 end;
  end;
  wrinx(crtc,$1A,old);
  _al2101 := hOk;
end;

function _ati : Integer;
var w:word;
begin
  _ati := hError;
  if getbios($31,9)='761295520' then
  begin
	 case memw[biosseg:$40] of
	  $3133:begin
		  IOadr:=memw[biosseg:$10];
		  w:=rdinx(IOadr,$BB);
		  case w and 15 of
			 0:_crt:='EGA';
			 1:_crt:='Analog Monochrome';
			 2:_crt:='Monochrome';
			 3:_crt:='Analog Color';
			 4:_crt:='CGA';
			 6:_crt:='';
			 7:_crt:='IBM 8514/A';
		  else _crt:='Multisync';
		  end;
		  chip:=__ati2;
		  SubVers:=mem[biosseg:$43];
		  case SubVers of
			$31:begin
			 Version:=ATI_18800;
			 chip:=__ati1;
		  end;
			$32:Version:=ATI_18800_1;
			$33:Version:=ATI_28800_2;
			$34:Version:=ATI_28800_4;
			$35:Version:=ATI_28800_5;
			$61:begin
			 chip:=__atiGUP;
			 SubVers:=inpw($FAEE);
			 case SubVers and $3FF of
			  $2F7:Version:=ATI_GUP_6;
			  $177:Version:=ATI_GUP_LX;
			  $017:Version:=ATI_GUP_AX;
			0:Version:=ATI_GUP_3;
			 end;
			 SetDAC(_daccl24,'ATI Bogus DAC');
		  end;
		  else Version:=ATI_Unknown;
		  end;
		  if Version>=ATI_18800_1 then features:=ft_rwbank;
		  case Version of
		ATI_18800,ATI_18800_1:
				 if (rdinx(IOadr,$bb) and 32)<>0 then mm:=512;
		ATI_28800_2:if (rdinx(IOadr,$b0) and 16)<>0 then mm:=512;
		ATI_28800_4,ATI_28800_5:
				 case rdinx(IOadr,$b0) and $18 of
				0:mm:=256;
			 $10:mm:=512;
				 8,$18:mm:=1024;
				 end;
		ATI_GUP_3..ATI_GUP_LX:
				 case inp($36EE) and $C of
			 0:mm:=512;
			 4:mm:=1024;
			 8:mm:=2048;
			12:mm:=4096;
				 end;
		  end;
		end;
	  $3233:begin
		  Version:=ATI_EGA;
		  video:='EGA';
		  chip:=__ega;
		end;
	 end;
	 if addvideo <> hOk then Exit;
  end;
  _ati := hOk;
end;

function _chipstech : Integer;
var prt,old,x:word;
begin
  _chipstech := hError;
  prt:=$46E8;    {Should be $94 for MCA systems}
  old:=inp(prt);     {This can cause problems for non-CT chips,
				as their 46E8h port may be updated incorrectly}
  outp(prt,$E);
  if inp($104)<>$A5 then
  begin
	 outp(prt,$1E);

	 if inp($104)=$A5 then
	 begin
		x:=inp($103);
		outp($103,x or $80);  {Enable extensions}
		outp(prt,$E);
		if (x and $40)=0 then IOadr:=$3D6 else IOadr:=$3B6;
		SubVers:=rdinx(IOadr,0);
		case SubVers shr 4 of
	0:Version:=CT_451;
	1:Version:=CT_452;
	2:Version:=CT_455;
	3:Version:=CT_453;
	4:Version:=CT_450;
	5:Version:=CT_456;
	6:Version:=CT_457;
	7:Version:=CT_65520;
	8:Version:=CT_65530;
		  9:Version:=CT_65510;
		else Version:=CT_Unknown;
		end;
		case Version of
	CT_452:begin
		 CHIP:=__chips452;
		 features:=ft_cursor;
			 end;
	CT_450,
	CT_453:CHIP:=__chips453;
		else chip:=__chips451;
		end;
		case rdinx(IOadr,4) and 3 of
	1:mm:=512;
		2,3:mm:=1024;
		end;
		if addvideo <> hOk then Exit;
	 end;
  end;
  _chipstech := hOk;
end;

function _cirrus : Integer;
var old,old6:word;
begin
  _cirrus := hOk;
  old6:=rdinx(SEQ,6);
  old:=rdinx(crtc,$C);
  outp(crtc+1,0);
  SubVers:=rdinx(crtc,$1F);
  wrinx(SEQ,6,lo(Subvers shr 4) or lo(Subvers shl 4));
								 {The SubVers value is rotated by 4}
  if inp(SEQ+1)=0 then
  begin
	 outp($3c5,SubVers);
	 if inp($3c5)=1 then
	 begin
		case SubVers of
	$EC:Version:=CL_GD5x0;
	$CA:Version:=CL_GD6x0;
	$EA:Version:=CL_V7_OEM;
		else Version:=CL_old_unk;
		end;
		chip:=__cirrus;
		if addvideo <> hOk then
			begin
				wrinx(crtc,$C,old);
				wrinx(SEQ,6,old6);
				Exit;
			end;
	 end;
  end;
  wrinx(crtc,$C,old);
  wrinx(SEQ,6,old6);
  _cirrus := hOk;
end;


function _cirrus54 : Integer;
var x,old:word;
begin
  _cirrus54 := hError;
  old:=rdinx(SEQ,6);
  wrinx(SEQ,6,0);
  if (rdinx(SEQ,6)=$F) then
  begin
    wrinx(SEQ,6,$12);
    if (rdinx(SEQ,6)=$12) and testinx2(SEQ,$1E,$3F) {and testinx2(crtc,$1B,$ff)} then
    begin
      case rdinx(SEQ,$A) and $18 of    {memory}
	0:mm:=256;
	8:mm:=512;
       16:mm:=1024;
       24:mm:=2048;
      end;
      SubVers:=rdinx(crtc,$27);
      if testinx(GRC,9) then
      begin
	case SubVers of
            $18:Version:=CL_AVGA2;
            $88:Version:=CL_GD5402;
            $89:Version:=CL_GD5402r1;
            $8A:Version:=CL_GD5420;
            $8B:Version:=CL_GD5420r1;
       $8C..$8F:Version:=CL_GD5422;
       $90..$93:Version:=CL_GD5426;
       $94..$97:Version:=CL_GD5424;
       $98..$9B:Version:=CL_GD5428;
       $A4..$A7:Version:=CL_GD543x;
	else Version:=CL_Unk54;
	end;
	SetDAC(_dacCL24,'Cirrus CL24');
      end
      else if testinx(SEQ,$19) then
	case SubVers shr 6 of
	  0:Version:=CL_GD6205;
	  1:Version:=CL_GD6235;
	  2:Version:=CL_GD6215;
	  3:Version:=CL_GD6225;
	end
      else begin
	Version:=CL_AVGA2;
	case rdinx(SEQ,$A) and 3 of
	  0:mm:=256;
	  1:mm:=512;
	  2:mm:=1024;
	end;
      end;
      features:=ft_cursor;
      chip:=__cir54;
      if addvideo <> hOk then Exit;
    end;
  end
  else wrinx(SEQ,6,old);
  _cirrus54 := hOk;
end;

function _cirrus64 : Integer;
var x,old:word;
begin
  _cirrus64 := hError;
  old:=rdinx(GRC,$A);
  wrinx(GRC,$A,$CE);  {Lock}
  if (rdinx(GRC,$A)=0) then
  begin
	 wrinx(GRC,$A,$EC);  {unlock}
	 if (rdinx(GRC,$A)=1) then
	 begin
		SubVers:=rdinx(GRC,$AA);
		case SubVers shr 4 of
	4:Version:=CL_GD6440;
	5:Version:=CL_GD6412;
	6:Version:=CL_GD5410;
	7:Version:=CL_GD6420;
	8:Version:=CL_GD6410;
		else Version:=CL_Unk64;
		end;
		case rdinx(GRC,$BB) shr 6 of
	0:mm:=256;
	1:mm:=512;
	2:mm:=768;
	3:mm:=1024;
		end;
		chip:=__cir64;
		if addvideo <> hOk then begin wrinx(GRC,$A,old); Exit; end;
	 end;
  end;
  wrinx(GRC,$A,old);
  _cirrus64 := hOk;
end;


function _compaq : Integer;
var old,x:word;
begin
  _compaq := hError;
  old:=rdinx(GRC,$F);
  wrinx(GRC,$F,0);
  if not testinx(GRC,$45) then
  begin
	 wrinx(GRC,$F,5);
	 if testinx(GRC,$45) then
	 begin
		chip:=__compaq;
		features:=ft_blit;
		SubVers:=rdinx(GRC,$C) shr 3;
		case SubVers of
	3:Version:=CPQ_IVGS;
	5:Version:=CPQ_AVGA;
	6:Version:=CPQ_QV1024;
		 $E:if (rdinx(GRC,$56) and 4)<>0 then Version:=CPQ_QV1280
													else Version:=CPQ_QV1024;
		$10:Version:=CPQ_AVPort;
		else Version:=CPQ_Unknown;
		end;
		if (rdinx(GRC,$C) and $B8)=$30 then  {QVision}
		begin
	features:=features + ft_cursor;
	wrinx(GRC,$F,$F);
	case rdinx(GRC,$54) of
	  0:mm:=1024;  {QV1024 fix}
	  2:mm:=512;
	  4:mm:=1024;
	  8:mm:=2048;
	end;
		  DAC_RS2:=$8000;
		  DAC_RS3:=$1000;
		end
		else begin
	rp.bx:=0;
	rp.cx:=0;
	vio($BF03);
	if (rp.ch and 64)=0 then mm:=512;
		end;
		if addvideo <> hOk then begin wrinx(GRC,$F,old); Exit end;
	 end
  end;
  wrinx(GRC,$F,old);
  _compaq := hOk;
end;

function _everex : Integer;
var x:word;
begin
  _everex := hError;
  rp.bx:=0;
  vio($7000);
  if rp.al=$70 then
  begin
    x:=rp.dx shr 4;
    if  (x<>$678) and (x<>$236)
    and (x<>$620) and (x<>$673) then     {Some Everex boards use Trident chips.}
    begin
      case rp.ch shr 6 of
	0:mm:=256;
	1:mm:=512;
	2:mm:=1024;
	3:mm:=2048;
      end;
      name:='Everex Ev'+hx[x shr 8]+hx[(x shr 4) and 15]+hx[x and 15];
      chip:=__everex;
		if addvideo <> hOk then Exit;
	 end;
  end;
  _everex := hOk;
end;

function _genoa : Integer;
var ad:word;
begin
  _genoa := hError;
  ad:=memw[biosseg:$37];
  if (memw[biosseg:ad+2]=$6699) and (mem[biosseg:ad]=$77) then
  begin
	 case mem[biosseg:ad+1] of
		0:Version:=GE_6200;
	 $11:begin
	  Version:=GE_6400;
	  mm:=512;
	end;
	 $22:Version:=GE_6100;
	 $33:Version:=GE_5100;  {Do we need to detect the Tseng versions ??}
	 $55:begin
	  Version:=GE_5300;
	  mm:=512;
	end;
	 end;
	 if mem[biosseg:ad+1]<$33 then chip:=__genoa else chip:=__ET3000;
	 if addvideo <> hOk then Exit;
  end;
  _genoa := hOk;
end;

function _hmc : Integer;
begin
  _hmc := hError;
  if testinx(SEQ,$E7) and testinx(SEQ,$EE) then
  begin
	 if (rdinx(SEQ,$E7) and $10)>0 then mm:=512;
	 chip:=__HMC;
	 Version:=HMC_304;
	 if addvideo <> hOk then Exit;
  end;
  _hmc := hOk;
end;

function _mxic : Integer;
begin
  _mxic := hError;
  old:=rdinx(SEQ,$A7);
  wrinx(SEQ,$A7,0);       {disable extensions}
  if not testinx(SEQ,$C5) then
  begin
	 wrinx(SEQ,$A7,$87);   {enable extensions}
	 if testinx(SEQ,$C5) then
	 begin
		chip:=__mxic;
		if (rdinx(SEQ,$26) and 1)=0 then Version:=MX_86010
		else Version:=MX_86000;   {Does this work, else test 85h bit 1 ??}
		case (rdinx(SEQ,$C2)  shr 2) and 3 of
	0:mm:=256;
	1:mm:=512;
	2:mm:=1024;
		end;
		if addvideo <> hOk then begin wrinx(SEQ,$A7,old); Exit end;
	 end;
  end;
  wrinx(SEQ,$A7,old);
  _mxic := hOk;
end;

function _ncr : Integer;
var x:word;
begin
  _ncr := hError;
  if testinx2(SEQ,5,5) then
  begin
	 wrinx(SEQ,5,0);        {Disable extended registers}
	 if not testinx(SEQ,$10) then
	 begin
		wrinx(SEQ,5,1);        {Enable extended registers}
		if testinx(SEQ,$10) then
		begin
	chip:=__ncr;
	SubVers:=rdinx(SEQ,8);
	case SubVers shr 4 of
	  0:Version:=NCR_77C22;
	  1:Version:=NCR_77C21;
	  2:Version:=NCR_77C22E;
		8..15:Version:=NCR_77C22Ep;
	else Version:=NCR_Unknown;
	end;
	features:=ft_rwbank+ft_cursor;
	name:=name+' Rev. '+istr(rdinx(SEQ,8) and 15);
	if setmode($13) then;
	checkmem(64);
	if addvideo <> hOk then Exit;
		end;
	 end;
  end;
  _ncr := hOk;
end;

function _oak : Integer;
var i:word;
begin
  _oak := hError;
  if testinx2($3DE,$D,$38) then
  begin
	 features:=ft_rwbank;
	 if testinx2($3DE,$23,$1F) then
	 begin
		case rdinx($3DE,2) and 6 of
	0:mm:=256;
	2:mm:=512;
	4:mm:=1024;
	6:mm:=2048;
		end;
		chip:=__oak87;
		if (rdinx($3DE,0) and 2)=0 then Version:=OAK_087
				 else version:=OAK_083;
	 end
	 else begin
		SubVers:=inp($3DE) shr 5;
		case SubVers of
	0:Version:=OAK_037;
	2:Version:=OAK_067;
	5:Version:=OAK_077;
	7:Version:=OAK_057;
		else Version:=OAK_Unknown;
		end;

		case rdinx($3de,13) shr 6 of
	2:mm:=512;
		1,3:mm:=1024;    {1 might not give 1M??}
		end;
		chip:=__oak;
	 end;
	 features:=ft_rwbank;
	 if addvideo <> hOk then Exit;
  end;
  _oak := hOk;
end;

function _p2000 : Integer;
begin
  _p2000 := hError;
  if testinx2(GRC,$3D,$3F) and tstrg($3D6,$1F) and tstrg($3D7,$1F) then
  begin
	 Version:=PR_2000;
	 chip:=__p2000;
	 features:=ft_rwbank+ft_blit;
	 if setmode($13) then;
	 checkmem(32);
	 if addvideo <> hOk then Exit;
  end;
  _p2000 := hOk;
end;

function _paradise : Integer;
var old,old2:word;
begin
  _paradise := hError;
  old:=rdinx(GRC,$F);
  setinx(GRC,$F,$17);   {Lock registers}

  if not testinx2(GRC,9,$7F) then
  begin
	 wrinx(GRC,$F,5);      {Unlock them again}
	 if testinx2(GRC,9,$7F) then
	 begin
		old2:=rdinx(crtc,$29);
		modinx(crtc,$29,$8F,$85);   {Unlock WD90Cxx registers}
		if not testinx(crtc,$2B) then Version:=WD_PVGA1A
		else begin
	wrinx(SEQ,6,$48);   {Enable C1x extensions}
	if not testinx2(SEQ,7,$F0) then Version:=WD_90C00
	else if not testinx(SEQ,$10) then
	begin
			 if testinx2(crtc,$31,$68) then Version:=WD_90c22
			 else if testinx2(crtc,$31,$90) then Version:=WD_90c20A
			 else Version:=WD_90C20;
	  wrinx(crtc,$34,$A6);
	  if (rdinx(crtc,$32) and $20)<>0 then wrinx(crtc,$34,0);
	end
	else begin
	  features:=ft_rwbank;
	  if testinx2(SEQ,$14,$F) then
	  begin
		 SubVers:=(rdinx(crtc,$36) shl 8)+rdinx(crtc,$37);
		 case SubVers of
			$3234:Version:=WD_90c24;
			$3236:Version:=WD_90C26;
			$3330:Version:=WD_90c30;
			$3331:begin
							 Version:=WD_90C31;
							 features:=features+ft_cursor+ft_blit;
						  end;
			$3333:begin
							 Version:=WD_90C33;
							 features:=features+ft_cursor;
						  end;
		 end;
	  end
	  else if not testinx2(SEQ,$10,4) then Version:=WD_90C10
					  else Version:=WD_90C11;
	end;
		end;
		case rdinx(GRC,11) shr 6 of
		  2:mm:=512;
		  3:mm:=1024;
		end;
		if (Version>=WD_90c33) and ((rdinx(crtc,$3E) and $80)>0) then mm:=2048;
		wrinx(crtc,$29,old2);
		chip:=__paradise;
		if addvideo <> hOk then begin wrinx(GRC,$F,old); Exit end;
	 end;
  end;
  wrinx(GRC,$F,old);
  _paradise := hOk;
end;

function _realtek : Integer;
var x:word;
begin
  _realtek := hError;
  if testinx2(crtc,$1F,$3F) and tstrg($3D6,$F) and tstrg($3D7,$F) then
  begin
	 chip:=__realtek;
	 SubVers:=rdinx(crtc,$1A) shr 6;
	 case SubVers of
		0:Version:=RT_3103;
		1:Version:=RT_3105;
		2:Version:=RT_3106;
	 else Version:=RT_unknown;
	 end;
	 case rdinx(crtc,$1e) and 15 of
		0:mm:=256;
		1:mm:=512;
		2:if x=0 then mm:=768  else mm:=1024;
		3:if x=0 then mm:=1024 else mm:=2048;
	 end;
	 features:=ft_rwbank;
	 if addvideo <> hOk then Exit;
  end;
  _realtek := hOk;
end;

function _s3 : Integer;
begin
  _s3 := hError;
  wrinx(crtc,$38,0);
  if not testinx2(crtc,$35,$F) then
  begin
	 wrinx(crtc,$38,$48);
	 if testinx2(crtc,$35,$F) then
	 begin
		features:=ft_blit+ft_line+ft_cursor;
		SubVers:=rdinx(crtc,$30);
		case SubVers of
	$81:Version:=S3_911;
	$82:Version:=S3_924;
	$90:Version:=S3_928C;
	$91:Version:=S3_928D;
	$94..$95:Version:=S3_928E;
	$A0:if (rdinx(crtc,$36) and 2)<>0 then Version:=S3_801AB
					  else Version:=S3_805AB;
	$A2..$A4:if (rdinx(crtc,$36) and 2)<>0 then Version:=S3_801C
					  else Version:=S3_805C;
		  $A5:if (rdinx(crtc,$36) and 2)<>0 then Version:=S3_801D
					  else Version:=S3_805D;
	$B0:Version:=S3_928PCI;
		else Version:=S3_Unknown;
		end;
		if (SubVers<$90) then    (* 911 and 924 *)
		begin
	if (rdinx(crtc,$41) and $10)<>0 then mm:=1024
					else mm:=512;
		end
		else case rdinx(crtc,$36) and $E0 of
		0,$80:mm:=2048;
	 $C0,$40:mm:=1024;
	 $E0,$60:mm:=512;
		end;
		chip:=__S3;
		if addvideo <> hOk then Exit;
	 end;
  end;
  _s3 := hOk;
end;

function _trident : Integer;
var old,val,Xseg:word;
  Phadr:longint;
begin
  _trident := hError;
  wrinx(SEQ,$B,0);
  SubVers:=inp(SEQ+1);
  old:=rdinx(SEQ,$E);
  outp(SEQ+1,0);
  val:=inp(SEQ+1);
  outp(SEQ+1,old);
  if (val and 15)=2 then
  begin
	 outp($3c5,old xor 2);   (* Trident should restore bit 1 reversed *)
	 case SubVers of
		1:Version:=TR_8800BR;   {This'll never happen}
		2:Version:=TR_8800CS;
		3:Version:=TR_8900B;
  4,$13:Version:=TR_8900C;
	 $23:Version:=TR_9000;
	 $33:Version:=TR_8900CL;
	 $43:Version:=TR_9000i;
	 $53:Version:=TR_8900CXr;
	 $63:Version:=TR_LCD9100B;
	 $83:Version:=TR_LX8200;
	 $93:Version:=TR_9200CXi;
	 $A3:Version:=TR_LCD9320;
$73,$F3:Version:=TR_GUI9420;
	 else Version:=TR_Unknown;
	 end;
	 case SubVers and 15 of
		1:chip:=__tridbr;
		2:chip:=__tridCS;
	 3,4:chip:=__trid89;
	 end;
	 if (pos('Zymos Poach 51',getbios(0,255))>0) or
		 (pos('Zymos Poach 51',getbios(230,255))>0) then
	 begin
		name:=name+' (Zymos Poach)';
		chip:=__poach;
	 end;
	 if (SubVers=2) and (tstrg($2168,$f)) then
	 begin
		IOadr:=$2160;
		chip:=__IITAGX;
		Version:=IIT_AGX;
		if setmode($65) then;
		checkmem(32);
		XGAseg:=$B1F0;
		Phadr:=$FF800000;

	 end
	 else begin
		if (SubVers>=3) then
		begin
	case rdinx(crtc,$1f) and 3 of
	  0:mm:=256;
	  1:mm:=512;
	  2:mm:=768;
	  3:mm:=1024;
	end;
		end
		else
		if (rdinx(crtc,$1F) and 2)>0 then mm:=512;
	 end;
	 addvideo;
  end
  else begin  {Trident 8800BR tests}
	 if (subvers=1) and testinx2(SEQ,$E,6) then
	 begin
		Version:=TR_8800BR;
		chip:=__tridBR;
		if (rdinx(crtc,$1F) and 2)>0 then mm:=512;
		if addvideo <> hOk then Exit;
	 end;
  end;
  _trident := hOk;
end;

function _tseng : Integer;
var x,vs:word;
begin
  _tseng := hError;
  outp($3bf,3);
  outp(crtc+4,$A0);    {Enable Tseng 4000 extensions}
  if tstrg($3CD,$3F) then
  begin
	 features:=ft_rwbank;
	 if testinx2(crtc,$33,$F) then
	 begin
		if tstrg($3CB,$33) then
		begin
		  features:=features+ft_cursor;
	chip:=__ET4w32;
	SubVers:=rdinx($217A,$EC);
	case SubVers shr 4 of
	  0:Version:=ET_4W32;
	  3:Version:=ET_4W32i;
	  2:Version:=ET_4W32p;
	else Unk(ET_4Unk,SubVers);
	end;
	case rdinx(crtc,$37) and $9 of
			  0:mm:=2048;
		1:mm:=4096;
	 {  9:mm:=256;}
		8:mm:=512;
		9:mm:=1024;
	end;
		  if (Version<>ET_4W32) and ((rdinx(crtc,$32) and $80)>0) then
			 mm:=mm*2;
	 end
		else begin
	chip:=__ET4000;
	Version:=ET_4000;
	case rdinx(crtc,$37) and $B of
	 3,9:mm:=256;
	  10:mm:=512;
	  11:mm:=1024;
	end;
		end;
	 end
	 else begin
		Version:=ET_3000;
		chip:=__ET3000;
		if setmode($13) then;
		x:=inp(CRTC+6);
		x:=rdinx($3c0,$36);
		outp($3C0,x or $10);
		case (rdinx(GRC,6) shr 2) and 3 of
		 0,1:vs:=SegA000;
	 2:vs:=$b000;
	 3:vs:=$b800;
		end;

		meml[vs:1]:=$12345678;
		if memw[vs:2]=$3456 then mm:=512;

		wrinx($3c0,$36,x);     {reset value and reenable DAC}
	 end;
	 if addvideo <> hOk then Exit;
  end;
  _tseng := hOk;
end;

function _UMC : Integer;
begin
  _UMC := hError;
  old:=inp($3BF);
  outp($3BF,3);
  if not testinx(SEQ,6) then
  begin
	 outp($3BF,$AC);
	 if testinx(SEQ,6) then
	 begin
		version:=UMC_408;
		chip:=__UMC;
		case rdinx(SEQ,7) shr 6 of
	1:mm:=512;
		2,3:mm:=1024;
		end;
		features:=ft_rwbank;
		if addvideo <> hOk then begin outp($3BF,old); Exit end;
	 end;
  end;
  outp($3BF,old);
  _UMC := hOk;
end;


function _video7 : Integer;
var ram:string[10];
begin
  _video7 := hError;
  vio($6f00);
  if rp.bx=$5637 then
  begin
	 vio($6f07);
	 if rp.ah<128 then ram:='VRAM' else ram:='FASTWRITE';

 (* old:=rdinx(crtc,$C);
  wrinx(crtc,$C,old);
  wrinx($3C4,6,$EA);    {Enable Extensions}
  if rdinx(crtc,$1F)=(old XOR $EA) then
  begin
	 wrinx(crtc,$C,old XOR $FF);
	 if rdinx(crtc,$1F)=(old XOR $15) then
	 begin
		SubVers:=(rdinx($3C4,$8F) shl 8)+rdinx($3C4,$8E);
	 end;
  end;

  wrinx(crtc,$C,old);  *)


	 Subvers:=(rdinx(SEQ,$8F) shl 8)+rdinx(SEQ,$8E);
	 case Subvers of
  $8000..$FFFF:Version:=V7_VEGA;
  $7000..$70FF:Version:=V7_208_13;
  $7140..$714F:Version:=V7_208A;
	 $7151:Version:=V7_208B;
	 $7152:Version:=V7_208CD;
	 $7760:Version:=V7_216BC;
	 $7763:Version:=V7_216D;
	 $7764:Version:=V7_216E;
	 $7765:Version:=V7_216F;
	 else Version:=V7_Unknown;
	 end;
	 case rp.ah and 127 of
		2:mm:=512;
		4:mm:=1024;
	 end;
	 chip:=__video7;
	 features:=ft_cursor;
	 if Version>=V7_208A then Features:=features+ft_rwbank;
	 if addvideo <> hOk then Exit;
  end;
  _video7 := hOk;
end;

function _Weitek : Integer;
var x:word;
begin
  _Weitek := hError;
  old:=rdinx(SEQ,$11);
  outp(SEQ+1,old);
  outp(SEQ+1,old);
  outp(SEQ+1,inp(SEQ+1) or $20);
  if not testinx(SEQ,$12) then
  begin
	 x:=rdinx(SEQ,$11);
	 outp(SEQ+1,old);
	 outp(SEQ+1,old);
	 outp(SEQ+1,inp(SEQ+1) and $DF);
	 if testinx(SEQ,$12) and tstrg($3CD,$FF) then
	 begin
		chip:=__Weitek;
		Version:=WT_5186;  {Should check for version and memory}
		mm:=256;
		if addvideo <> hOk then begin wrinx(SEQ,$11,old); Exit end;
	 end;
  end;
  wrinx(SEQ,$11,old);
  _Weitek := hOk;
end;

function _XGA : Integer;
var p:pointer;
 posbase,cardid,xga_base,x,cx:word;
 temp0,temp1,temp2,temp3:byte;
begin
  _XGA := hError;
  getintvec($15,p);
  if (seg(p^)<>0) then
  begin
	 rp.ax:=$C400;
	 rp.dx:=$ffff;
	 intr($15,rp);
	 if not odd(rp.flags) and (rp.dx<>$ffff) then
	 begin
		posbase:=rp.dx;
		for cx:=0 to 9 do
		begin
	disable;   (* CLI -  Disable interrupts *)
	if cx=0 then outp($94,$DF)
	else begin
	  rp.ax:=$C401;
	  rp.bx:=cx;
	  intr($15,rp);
	end;
	cardid:=inpw(posbase);
	temp0:=inp(posbase+2);
	temp1:=inp(posbase+3);
	temp2:=inp(posbase+4);
	temp3:=inp(posbase+5);
	if cx=0 then outp($94,$FF)
	else begin
	  rp.ax:=$C402;
	  rp.bx:=cx;
	  intr($15,rp);
	end;
	enable;   (* STI -  Enable interrupts *)
	if (cardid>=$8FD8) and (cardid<=$8FDB) then
	begin
	  IOadr:=$2100+(temp0 and $E)*8;
	  x:=rdinx(IOadr+10,$52) and 15;
	  if (x<>0) and (x<>15) then
	  begin
		 chip:=__XGA;
		 outp(IOadr+4,0);
		 outp(IOadr,4);
		 checkmem(16);
		 case cardid of
		  $8FDA:Version:=XGA_NI;
		  $8FDB:Version:=XGA_org;
		 end;

		 XGAseg:=(temp0 shr 4)*$2000+$C1C0+(temp0 and $E)*4;
		 Phadr:=((temp2 and $FE)*word(8)+(temp0 and $E))*longint($200000);
		 if addvideo <> hOk then Exit;
	  end;
	end;
		end;
	 end;
  end;
  _XGA := hOk;
end;

function _yamaha : Integer;
begin
  _yamaha := hError;
  if testinx2(crtc,$7C,$7C) then
  begin
	 Version:=YA_6388;
	 if addvideo <> hOk then Exit;
  end;
  _yamaha := hOk;
end;

function _xbe : Integer;
var
  x:word;
  xbe0:_xbe0;
  xbe1:_xbe1;

begin
  _xbe := hError;
  viop($4E00,0,0,0,@xbe0);
  if (rp.ax=$4E) and (xbe0.sign=$41534556) then
  begin
	 for x:=0 to xbe0.xgas-1 do
	 begin
		viop($4E01,0,0,x,@xbe1);
		if (rp.ax=$4E) then
		begin
	chip:=__xbe;
	mm:=xbe1.memory*longint(64);
	Instance:=x;
	IOadr :=xbe1.iobase;
	XGAseg:=xbe1.memreg;
	Phadr :=xbe1.vidadr;
	name:=gtstr(xbe1.oemadr);
	UNK(VS_XBE,xbe0.vers);
	if addvideo <> hOk then Exit;
		end;
	 end;
  end;
  _xbe := hOk;
end;

function _vesa : Integer;
var
  vesarec:_vbe0;
  x:word;
begin
  _vesa := hError;
  viop($4f00,0,0,0,@vesarec);
  if (rp.ax=$4f) and (vesarec.sign=$41534556) then
  begin
	 chip:=__vesa;
	 mm:=vesarec.mem*longint(64);
	 name:=gtstr(vesarec.oemadr);
	 UNK(VS_VBE,vesarec.vers);
	 dactype:=_dac8;    {Dummy, to keep Cirrus 542x out of trouble}
	 if addvideo <> hOk then Exit;
  end;
  _vesa := hOk;
end;


type
  pel=record
	index,red,green,blue:byte;
		end;

procedure readpelreg(index:word;var p:pel);
begin
  p.index:=index;
  disable;
  outp($3C7,index);
  p.red  :=inp($3C9);
  p.blue :=inp($3C9);
  p.green:=inp($3C9);
  enable;
end;

procedure writepelreg(var p:pel);
begin
  disable;
  outp($3C8,p.index);
  outp($3C9,p.red);
  outp($3C9,p.blue);
  outp($3C9,p.green);
  enable;
end;

function setcomm(cmd:word):word;
begin
  dac2comm;
  outp($3c6,cmd);
  dac2comm;
  setcomm:=inp($3c6);
end;


procedure testdac;      {Test for type of DAC}
var
  x,y,z,v,oldcomm,oldpel,notcomm:word;
  dac8,dac8now:boolean;


procedure waitforretrace;
begin
  repeat until (inp(CRTC+6) and 8)=0;
  repeat until (inp(CRTC+6) and 8)>0;    {Wait until we're in retrace}
end;

function dacis8bit:boolean;
var
  pel2,x,v:word;
  pel1:pel;
begin
  pel2:=inp($3C8);
  readpelreg(255,pel1);
  v:=pel1.red;
  pel1.red:=255;
  writepelreg(pel1);
  readpelreg(255,pel1);
  x:=pel1.red;
  pel1.red:=v;
  writepelreg(pel1);
  outp($3C8,pel2);
  dacis8bit:=(x=255);
end;

function testdacbit(bit:word):boolean;
var v:word;
begin
  dac2pel;
  outp($3C6,oldpel and (bit xor $FF));
  dac2comm;
  disable;
  outp($3C6,oldcomm or bit);
  v:=inp($3C6);
  outp($3C6,v and (bit xor $FF));
  enable;
  testdacbit:=(v and bit)<>0;
end;

begin
  setDAC(_dac8,'Normal');
  dac2comm;
  oldcomm:=inp($3c6);
  dac2pel;
  oldpel:=inp($3c6);

  dac2comm;
  outp($3C6,0);
  dac8:=dacis8bit;
  dac2pel;

  notcomm:=oldcomm xor 255;
  outp($3C6,notcomm);
  dac2comm;
  v:=inp($3C6);
  if v<>notcomm then
  begin
    if (setcomm($E0) and $E0)<>$E0 then
    begin
      dac2pel;
      x:=inp($3C6);
      repeat
	y:=x;         {wait for the same value twice}
	x:=inp($3C6);
      until (x=y);
      z:=x;
      dac2comm;
      if daccomm<>$8E then
      begin                 {If command register=$8e, we've got an SS24}
	y:=8;
	repeat
	  x:=inp($3C6);
	  dec(y);
	until (x=$8E) or (y=0);
      end
      else x:=daccomm;
      if x=$8e then setDAC(_dacss24,'SS24')
	       else setDAC(_dac15,'Sierra SC11486');
      dac2pel;
    end
    else begin
      if (setcomm($60) and $E0)=0 then
      begin
        if (setcomm(2) and 2)>0 then setDAC(_dacatt,'ATT 20c490')
                                else setDAC(_dacatt,'ATT 20c493');
      end
      else begin
	x:=setcomm(oldcomm);
	if inp($3C6)=notcomm then
	begin
	  if setcomm($FF)<>$FF then setDAC(_dacadac1,'Acumos ADAC1')
	  else begin
	    dac8now:=dacis8bit;
	    dac2comm;
	    outp($3C6,(oldcomm or 2) and $FE);
	    dac8now:=dacis8bit;
	    if dac8now then
	      if dacis8bit then setDAC(_dacatt,'ATT 20c491')
			   else setDAC(_dacCL24,'Cirrus 24bit DAC')
	    else setDAC(_dacatt,'ATT 20c492');
	  end;
	end
	else begin
	  if trigdac=notcomm then setDAC(_dacCL24,'Cirrus 24bit DAC')
	  else begin
	    dac2pel;
	    outp($3C6,$FF);
	    case trigdac of
              $44:setDAC(_dacmus,'MUSIC ??');  {4870 ??}
	      $82:setDAC(_dacmus,'MUSIC MU9C4910');
	      $8E:setDAC(_dacss24,'Diamond SS2410');
	    else
              if testdacbit($10) then setDAC(_dacsc24,'Sierra 16m')
              else if testdacbit(4) then setDAC(_dacUnk9,'Unknown DAC #9')
				else setDAC(_dac16,'Sierra 32k/64k');
	    end;
	  end;
	end;
      end;
    end;

    dac2comm;
    outp($3c6,oldcomm);
  end;
  dac2pel;
  outp($3c6,oldpel);

  if (dactype=_dac8) and (DAC_RS2<>0) and (DAC_RS3<>0) then
  begin
    oldpel :=inp($3C6);
    oldcomm:=inp($3C6+DAC_RS2);
    outp($3C6+DAC_RS2,oldpel xor $FF);
    if (inp($3C6)=oldpel) and (inp($3C6+DAC_RS2)=(oldpel xor $FF)) then
      SetDAC(_dacBt484,'Brooktree Bt484');

    outp($3C6+DAC_RS2,oldcomm);
    outp($3C6,oldpel);
  end;



  if dactype=_dac8 then
  begin
    WaitforRetrace;
    outp($3C8,222);
    outp($3C9,$43);
    outp($3C9,$45);
    outp($3C9,$47);    {Write 'CEGEDSUN' + mode to DAC index 222}
    outp($3C8,222);
    outp($3C9,$45);
    outp($3C9,$44);
    outp($3C9,$53);
    outp($3C8,222);
    outp($3C9,$55);
    outp($3C9,$4E);
    outp($3C9,13);     {Should be in CEG mode now}
    outp($3C6,255);
    x:=(inp($3c6) shr 4) and 7;
    if x<7 then
    begin
      setDAC(_dacCEG,'Edsun CEG rev. '+chr(x+48));
      WaitforRetrace;
      outp($3C8,223);
      outp($3C9,0);    {Back in normal dac mode}
    end;
  end;
end;


procedure findbios;     {Finds the most likely BIOS segment}
var
  score:array[0..7] of byte;
  x,y:word;
begin
  biosseg:=$c000;
  for x:=0 to 6 do score[x]:=1;
  for x:=0 to 7 do
  begin
    rp.bh:=x;
    vio($1130);
    if (rp.es>=$c000) and ((rp.es and $7ff)=0) then
      inc(score[(rp.es-$c000) shr 11]);
  end;

  for x:=0 to 6 do
  begin
    y:=$c000+(x shl 11);
    if (memw[y:0]<>$aa55) or (mem[y:2]<48) then
      score[x]:=0;                       {fail if no rom}
  end;
  for x:=6 downto 0 do
    if score[x]>0 then
      biosseg:=$c000+(x shl 11);
end;

type
  fnctyp=procedure;

const
  chps=24;
  chptype:array[1..chps] of chips=(__paradise,__Video7,__MXIC,__UMC
	    ,__Genoa,__Everex,__Trid89,__ati2,__Aheadb,__NCR,__S3,__AL2101
	    ,__Cir54,__Cir64,__Weitek,__ET4000,__Realtek,__P2000
	    ,__Yamaha,__Oak,__Cirrus,__Compaq,__HMC,__chips451);

var
  chp,vid1:word;

function findvideo : Integer;
begin
  findvideo := hError;
  vids:=0;
  dactype:=_dac0;
  features:=0;
  if odd(inp($3CC)) then CRTC:=$3D4 else CRTC:=$3B4;
  if dotest[__VESA] then if _vesa <> hOk then Exit;
  if dotest[__XBE] then if _xbe <> hOk then Exit;
  if dotest[__XGA] then if _XGA <> hOk then Exit;

  _crt:='';
  chip:=__none;
  secondary:='';
  name:='';
  DAC_RS2:=0;DAC_RS3:=0;
  video:='none';
  rp.bx:=$1010;
  vio($1200);
  if rp.bh<=1 then
  begin
    video:='EGA';
    chip:=__ega;

    mm:=rp.bl;
    vio($1a00);
    if rp.al=$1a then
    begin
      if (rp.bl<4) and (rp.bh>3) then
      begin
	old:=rp.bl;
	rp.bl:=rp.bh;
	rp.bh:=old;
      end;
      video:='MCGA';
      case rp.bl of
	2,4,6,10:_crt:='TTL Color';
	1,5,7,11:_crt:='Monochrome';
	    8,12:_crt:='Analog Color';
      end;
      case rp.bh of
	1:secondary:='Monochrome';
	2:secondary:='CGA';
      end;
      findbios;
      if (getbios($31,9)='') and (getbios($40,2)='22') then
      begin
	video:='EGA';       {@#%@  lying ATI EGA Wonder !}
	name:='ATI EGA Wonder';
	if addvideo <> hOk then Exit;
		end else
		if (rp.bl<10) or (rp.bl>12) then
		begin

	chp:=0;vid1:=vids;
	while (vids=vid1) and (chp<chps) do
	begin
	  inc(chp);

	  video:='VGA';
	  chip:=__vga;
	  mm:=256;
	  features:=0;
	  dactype:=_dac0;
	  version:=0;
	  subvers:=0;

	  if debug then
	  begin
		 writeln('Testing: '+header[chptype[chp]]);
		 if readkey='' then;
	  end;

	  if dotest[chptype[chp]] then
				case chptype[chp] of
				  __Aheadb: if _Ahead <> hOk then Exit;
				  __AL2101: if _AL2101 <> hOk then Exit;
					 __ati2: if _Ati <> hOk then Exit;
				__chips451: if _chipstech <> hOk then Exit;
					__Cir54: if _Cirrus54 <> hOk then Exit;
					__Cir64: if _Cirrus64 <> hOk then Exit;
				  __Cirrus: if _Cirrus <> hOk then Exit;
				  __Compaq: if _Compaq <> hOk then Exit;
				  __Everex: if _Everex <> hOk then Exit;
					__Genoa: if _Genoa <> hOk then Exit;
					  __HMC: if _HMC <> hOk then Exit;
					 __MXIC: if _MXIC <> hOk then Exit;
					  __NCR: if _NCR <> hOk then Exit;
					  __Oak: if _Oak <> hOk then Exit;
					__P2000: if _P2000 <> hOk then Exit;
				__paradise: if _paradise <> hOk then Exit;
				 __Realtek: if _Realtek <> hOk then Exit;
						__S3: if _S3 <> hOk then Exit;
				  __Trid89: if _Trident <> hOk then Exit;
				  __ET4000: if _Tseng <> hOk then Exit;
					  __UMC: if _UMC <> hOk then Exit;
				  __Video7: if _Video7 <> hOk then Exit;
				  __Weitek: if _weitek <> hOk then Exit;
				  __Yamaha: if _Yamaha <> hOk then Exit;
				end;
	end;
	if vids=vid1 then if addvideo <> hOk then Exit;
		end;
	 end;
  end;
  findvideo := hOk;
end;


  (*  Set memory bank  *)

procedure setbank(bank:word);
var x:word;
begin
  if bank=curbank then exit;   {Only set bank if diff. from current value}
  vseg:=SegA000;
  curbank:=bank;
  case chip of
    __aheadA:begin
               wrinx(GRC,13,bank shr 1);
               x:=inp($3cc) and $df;
               if odd(bank) then inc(x,32);
               outp($3c2,x);
             end;
    __aheadB:wrinx(GRC,13,bank*17);
    __al2101:begin
               outp($3d7,bank);
               outp($3D6,bank);
             end;
      __ati1:modinx(IOadr,$b2,$1e,bank shl 1);
      __ati2:begin
               x:=bank*$22;          {Roll bank nbr into bit 0}
               modinx(IOadr,$b2,$ff,hi(x) or lo(x));
             end;
    __atiGUP:begin
               x:=(bank and 15)*$22;          {Roll bank nbr into bit 0}
               modinx(IOadr,$b2,$ff,hi(x) or lo(x));
               modinx(IOadr,$AE,3,bank shr 4);
             end;
  __chips451:wrinx(IOadr,$B,bank);
  __chips452:begin
               if memmode<=_pl4 then bank:=bank shl 2;
               wrinx(IOadr,$10,bank shl 2);
             end;
  __chips453:begin
               if memmode<=_pl4 then bank:=bank shl 2;
               wrinx(IOadr,$10,bank shl 4);
             end;
     __cir54:begin
               if (rdinx(GRC,$B) and 32)=0 then bank:=bank shl 2;
               wrinx(GRC,9,bank shl 2);
             end;
     __cir64:begin
               bank:=bank shl 4;
               wrinx(GRC,$E,bank);
               wrinx(GRC,$F,bank);
             end;
    __compaq:begin
               wrinx(GRC,$f,5);
               bank:=bank shl 4;
               wrinx(GRC,$45,bank);
               if (rdinx(GRC,$40) and 1)>0 then inc(bank,8);
               wrinx(GRC,$46,bank);
             end;
    __ET3000:outp($3cd,bank*9+64);
    __Weitek,
    __ET4000:outp($3cd,bank*17);
    __ET4w32:begin
               outp($3cd,(bank and 15)*17);
               outp($3cb,(bank shr 4)*17);
             end;
    __everex:begin
               x:=inp($3cc) and $df;
               if (bank and 2)>0 then inc(x,32);
               outp($3c2,x);
               modinx(SEQ,8,$80,bank shl 7);
             end;
     __genoa:wrinx(SEQ,6,bank*9+64);
       __HMC:begin
               if memmode=_p8 then modinx(SEQ,$EE,$70,bank shl 4)
					else if bank=0 then vseg:=SegA000 else vseg:=$B000;
             end;
    __iitagx:if (inp(IOadr) and 4)>0 then outp(IOadr+8,bank)
             else begin
               wrinx(SEQ,$B,0);
               if rdinx(SEQ,$B)=0 then;
               modinx(SEQ,$E,$f,bank xor 2);
             end;
      __mxic:wrinx(SEQ,$c5,bank*17);
       __ncr:begin
               if memmode<=_pl4 then bank:=bank shl 2;
               wrinx(SEQ,$18,bank shl 2);
               wrinx(SEQ,$1C,bank shl 2);
             end;
       __oak:wrinx($3de,$11,bank*17);
     __oak87:begin
               wrinx($3DE,$23,bank);
               wrinx($3DE,$24,bank);
             end;
  __paradise:begin
               wrinx(GRC,9,bank shl 4);
               wrinx(GRC,$A,bank shl 4);
             end;

     __p2000,
   __realtek:begin
               outp($3d6,bank);
               outp($3d7,bank);
             end;
        __s3:begin
               wrinx(crtc,$38,$48);
               wrinx(crtc,$39,$A5);
               setinx(crtc,$31,9);
               if memmode<=_pl4 then bank:=bank*4;
               modinx(crtc,$35,$f,bank);
               modinx(crtc,$51,$C,bank shr 2);
               wrinx(crtc,$39,$5A);
               wrinx(crtc,$38,0);
             end;
    __tridBR:begin
               modinx(SEQ,$E,6,bank);
					if (bank and 1)>0 then vseg:=$B000 else vseg:=SegA000;
             end;
    __tridCS,__poach,__trid89
            :if version=TR_8900CL then outp($3D8,bank)
             else begin
        (*       wrinx(SEQ,$B,0);
               if rdinx(SEQ,$B)=0 then;  {New mode}
               modinx(SEQ,$E,$f,bank xor 2);  *)
               wrinx(SEQ,$B,0);
               if rdinx(SEQ,$B)=0 then;  {New mode}
               if (memmode<=_pl4) and (bank>1) then inc(bank,2);
               modinx(SEQ,$E,$f,bank xor 2);
             end;
    __video7:if Version<V7_208A then
             begin
               x:=inp($3cc) and $df;
               if (bank and 2)>0 then inc(x,32);
               outp($3c2,x);
               modinx(SEQ,$f9,1,bank);
               modinx(SEQ,$f6,$80,(bank shr 2)*5);
             end
             else begin
               wrinx(SEQ,$E8,bank);
               wrinx(SEQ,$E9,bank);
             end;
       __UMC:wrinx(SEQ,6,bank*17);
      __vesa:begin
               rp.bx:=0;
               bank:=bank*longint(64) div vgran;
               rp.dx:=bank;
               vio($4f05);
               rp.bx:=1;
               rp.dx:=bank;
               vio($4f05);
             end;
 __xbe,__xga:outp(IOadr+8,bank);
  __WeitekP9:outp($3CD,bank or $20);
  end;
end;

procedure setRbank(bank:word);
var x:word;
begin
  curbank:=$FFFF;    {always flush}
  case chip of
   __aheadB:modinx(GRC,$D,$F,bank);
   __al2101:outp($3D6,bank);
     __ati2:begin
              x:=bank shl 5;          {Roll bank nbr into bit 0}
              modinx(IOadr,$b2,$e1,hi(x) or lo(x));
            end;
   __atiGUP:begin
              x:=(bank and 15) shl 5;          {Roll bank nbr into bit 0}
              modinx(IOAdr,$b2,$e1,hi(x) or lo(x));
              modinx(IOadr,$AE,$C,bank shr 2);
            end;
    __cir64:wrinx(GRC,$E,bank shl 4);
   __ET3000:modreg($3CD,$38,bank shl 3);
   __Weitek,
   __ET4000:modreg($3CD,$F0,bank shl 4);
   __ET4w32:begin
              modreg($3cd,$F0,bank shl 4);
              modreg($3cb,$F0,bank);
            end;
     __mxic:modinx(SEQ,$C5,$f0,bank shl 4);
      __ncr:begin
               if memmode<=_pl4 then bank:=bank shl 2;
               wrinx(SEQ,$1C,bank shl 2);
            end;
      __oak:modinx($3de,$11,$f,bank);
    __oak87:wrinx($3DE,$23,bank);
 __paradise:wrinx(GRC,9,bank shl 4);
    __p2000:outp($3D7,bank);
  __realtek:outp($3D6,bank);
   __Video7:wrinx(SEQ,$E9,bank);
      __UMC:modinx(SEQ,6,$F,bank);
  end;
end;



procedure vesamodeinfo(md:word;vbe1:_vbe1p);
const
  width :array[$100..$11b] of word=
      (640,640,800,800,1024,1024,1280,1280,80,132,132,132,132
      ,320,320,320,640,640,640,800,800,800,1024,1024,1024,1280,1280,1280);
  height:array[$100..$11b] of word=
      (400,480,600,600, 768, 768,1024,1024,60, 25, 43, 50, 60
      ,200,200,200,480,480,480,600,600,600, 768, 768, 768,1024,1024,1024);
  bits  :array[$100..$11b] of byte=
      (  8,  8,  4,  8,   4,   8,   4,   8, 0,  0,  0,  0,  0
      , 15, 16, 24, 15, 16, 24, 15, 16, 24,  15,  16,  24,  15,  16,  24);


var
  vbxx:_vbe1;
begin
  if vbe1=NIL then vbe1:=@vbxx;
  fillchar(vbe1^,sizeof(_vbe1),0);
  viop($4f01,0,md,0,vbe1);
  if ((vbe1^.attr and 2)=0) and (md>=$100) and (md<=$11b)
   then  (* optional info missing *)
  begin
    vbe1^.width :=width[md];
    vbe1^.height:=height[md];
    vbe1^.bits  :=bits[md];
  end;


  vgran :=vbe1^.gran;
  bytes :=vbe1^.bytes;
  pixels:=vbe1^.width;
  lins  :=vbe1^.height;
end;


procedure initxga;
var xbe1:_xbe1;
  phadr:longint;
  x:word;
begin
  outp(IOAdr+1,1);
  modreg(IOadr+9,$8,0);

  mem [xgaseg:$12]:=1;
  meml[xgaseg:$14]:=phadr;
  memw[xgaseg:$18]:=pixels;
  memw[xgaseg:$1A]:=lins;
  case memmode of
   _pk4:x:=2;
    _p8:x:=3;
   _p16:x:=4;
  end;
  mem [xgaseg:$1C]:=x;

end;

function safemode(md:word):boolean;
var x,y:word;
begin                 {Checks if we entered a Graph. mode}
  safemode:=false;
  wrinx(crtc,$11,0);
  wrinx(crtc,1,0);
  vio(lo(md));
  if (rdinx(crtc,1)<>0) or (rdinx(crtc,$11)<>0) then
  begin
    if (md<=$13) or (mem[0:$449]<>3) then safemode:=true;
  end;
end;

function tsvio(ax,bx:word):boolean;   {Tseng 4000 Hicolor mode set}
begin
  rp.bx:=bx;
  vio(ax);
  tsvio:=rp.ax=16;
end;

function setATImode(md:word):boolean;
begin
  rp.bx:=$5506;
  rp.bp:=$ffff;
  rp.si:=0;
  vio($1200+md);
  if rp.bp=$ffff then setATImode:=false
  else begin
    vio(md);
    setATImode:=true;
  end;
end;

function setmode(md:word):boolean;
var x,y,prt:word;
	OldBank : Byte;
begin
	OldBank := curbank;
  setmode:=true;
  curmode:=md;
  case chip of
__ati1,__ati2:setmode:=setATImode(md);
     __atiGUP:if md<$100 then setmode:=setATImode(md)
              else begin
                case memmode of
                 _p15:x:=$6;
                 _p16:x:=$E;
                 _p24:x:=$7;
                end;
                  {mov al,[md]  mov ah,[x]  mov bx,1  call C000h:64h
                    mov al,1  call C000h:68h}
                inline($8A/$46/<md/$8A/$66/<x/$BB/>1/$9A/>$64/>$C000
                      /$B8/>1/$9A/>$68/>$C000);
              end;
     __compaq:begin
                setmode:=safemode(md);
                if memmode=_p16 then outp($3C8+DAC_RS3,$38);
              end;
     __ET4w32,
     __ET4000:case hi(md) of
                0:setmode:=safemode(md);
                1:if tsvio($10e0,lo(md)) then
                  begin
                    {Diamond SpeedStar 24 does not clear memory}
                    for x:=0 to 15 do         {clear memory}
                    begin
                      setbank(x);
							 mem[SegA000:0]:=0;
							 fillchar(mem[SegA000:1],65535,0);
                    end;
                  end else setmode:=false;
                2:if tsvio($10f0,md shl 8+$ff) then
                  begin
                    if bytes=2048 then
                    begin         {Bug correction for the MEGAVGA BIOS}
                      outp($3bf,3);
                      outp(crtc+4,$a0);   {enable Tseng 4000 Extensions}
                      wrinx(crtc,$13,0);
                      setinx(crtc,$3f,$80);
                    end
                  end else setmode:=false;
                3:if tsvio($10f0,lo(md)) and setdac15 then
                  else setmode:=false;
                4:if tsvio($10f0,lo(md)) and setdac16 then
                  else setmode:=false;
              end;
     __everex:begin
                rp.bl:=md;
                vio($70);
              end;
      __oak87:if safemode(md) then
                case memmode of
                  _p15:setmode:=setdac15;
                  _p16:setmode:=setdac16;
                  _p24:setmode:=setdac24;
                end
              else setmode:=false;
         __s3:if md<$100 then setmode:=safemode(md)
              else begin
                rp.bx:=md;
                vio($4f02);
                if rp.ax=$4f then
                begin
                  if md<$200 then vesamodeinfo(md,NIL);
                  if (memmode=_p16) and setdac16 then;
                end
                else begin
                  setmode:=false;
                  dac2comm;
                  outp($3C6,0);
                  dac2pel;
                end;
              end;
     __iitagx,
     __trid89:begin
                vio(md);
                if (rp.ah<>0) then setmode:=false;
                case memmode of   {9000i doesn't set HiColor modes}
                  _p15:if not setdac15 then setmode:=false;
                  _p16:if not setdac16 then setmode:=false;
                end;


              end;
     __video7:begin
                rp.bl:=md;
                vio($6f05);
              end;
       __vesa:begin
                rp.bx:=md;
                vio($4f02);
                if rp.ax<>$4f then setmode:=false
                else begin
                  vesamodeinfo(md,NIL);
                  chip:=__vesa;
                end;
              end;
        __UMC:begin
                setmode:=safemode(md);
                case memmode of
                  _p15:setmode:=setdac15;
                  _p16:setmode:=setdac16;
                end;
              end;
        __xbe:begin
                viop($4E03,md,0,instance,NIL);
                if rp.ax<>$4E then setmode:=false;
              end;
  else setmode:=safemode(md);
  end;

  if (inp($3CC) and 1)=0 then crtc:=$3B4 else crtc:=$3D4;
  case (rdinx(GRC,6) shr 2) and 3 of
	 0,1:vseg:=SegA000;
      2:vseg:=$B000;
      3:vseg:=$B800;
  end;


  case chip of
     __aheadA,
     __aheadB:begin
                setinx(GRC,$F,$20);
                if (memmode>_cga2) and (md<>$13) then setinx(GRC,$C,$20);
              end;
     __al2101:begin
                setinx(crtc,$1A,$10);    {Enable extensions}
                setinx(crtc,$19,2);      {Enable >256K}
                setinx(GRC,$F,4);        {Enable RWbank}
              end;
     __atiGUP,
       __ati2:begin
                setinx(IOadr,$B6,1);    {enable display >256K}
                setinx(IOAdr,$Be,8);    {enable RWbanks}
                setinx(IOAdr,$Bf,$1);
              end;
   __chips451,__chips452,__chips453:
              begin
                prt:=$46E8;
                x:=inp(prt);
                outp(prt,x or $10);
                y:=inp($103);
                outp($103,y or $80);
                outp(prt,x and $EF);
                if (y and $40)=0 then IOadr:=$3D6 else IOadr:=$3B6;
                setinx(IOadr,4,4);
                if chip<>__chips451 then
                begin
                  modinx(IOadr,$B,3,1);
                  wrinx(IOadr,$C,0);
                end;
              end;
      __cir54:begin
                wrinx(SEQ,6,$12);
                setinx(crtc,$1B,2);      {Enable mem >256K}
                if mm>1024 then
                begin
                  setinx(GRC,11,$20);    {Set 16K banks}
                  setinx(SEQ,$f,$80);    {Enable Ext mem}
                end;
                wrinx(crtc,$25,$FF);
              end;
      __cir64:begin
                wrinx(GRC,$A,$EC);       {Enable extensions}
                if memmode>_cga2 then setinx(GRC,$D,7);
              end;
     __compaq:begin
                modinx(GRC,$F,$f,5);
                setinx(GRC,$10,8);
              end;
     __ET3000:setinx(SEQ,4,2);
        __HMC:if memmode>=_cga2 then
              begin
                if memmode=_pl4 then
                begin
                  setinx(SEQ,$E7,$4);
                  clrinx(GRC,6,$C);
                end;
                setinx(SEQ,$E8,$9);

              end;
     __iitagx:begin
                modinx(GRC,6,$C,4);
                spcreg:=0;
                if (inp(IOadr) and 4)>0 then
                begin
                  initxga;
                  spcreg:=$1F0-(rdinx(IOadr+10,$75) and 3)*$10;
                end;
              end;
       __mxic:begin
                setinx(SEQ,$65,$40);
                wrinx(SEQ,$a7,$87);    {enable extensions}
                setinx(SEQ,$c3,4);     {Enable banks}
                setinx(SEQ,$f0,8);     {Enable display >256k}
              end;
        __ncr:begin
                wrinx(SEQ,5,5);
                wrinx(SEQ,$18,0);
                wrinx(SEQ,$19,0);
                wrinx(SEQ,$1A,0);
                wrinx(SEQ,$1B,0);
                wrinx(SEQ,$1C,0);
                wrinx(SEQ,$1D,0);
                setinx(SEQ,$1e,$1C);
              end;
        __oak:begin
                if memmode>=_pl4 then setinx($3DE,$D,$1C);
              end;
      __oak87:begin
                if memmode=_pl4 then setinx($3DE,$D,$10);
             (*   if md=$13 then
                begin
                  wrinx(crtc,$14,0);
                  wrinx(crtc,$13,20);
                  wrinx(crtc,$17,$c3);
                  setinx($3DE,$21,4);
                end; (* Creates a 320x200 mode without 64K limitations
                        however there is no pixel doubling, creating a
                        "double screen"  *)
              end;
   __paradise:begin
                modinx(GRC,$F,$17,5); {Enable extensions}
                wrinx(crtc,$29,$85);  {Enable extensions 2}
                clrinx(GRC,$B,8);
                clrinx(crtc,$2F,$62);
                setinx(SEQ,$11,$80);  {enable dual bank}
              end;
      __p2000:begin
                if memmode=_p16 then
                begin
                  dac2comm;
                  outp($3c6,$c0);
                end;
         (*       if memmode=_p24 then
                begin            {This can trick a ATT20c492 into 24bit mode}
                  dactocomm;
                  outp($3c6,$e0);
                  bytes:=1600;
                  pixels:=530;
                end;  *)
              end;
    __realtek:begin
                setinx(crtc,$19,$A2);   {display from upper 512k}
                setinx(GRC,$C,32);
                setinx(GRC,$F,4);       {dual bank}
              end;
         __s3:if memmode>_CGA2 then
              begin
                wrinx(crtc,$38,$48);
                wrinx(crtc,$39,$A5);
                setinx(crtc,$31,8);   {Enable access >256K}
                wrinx(crtc,$38,0);
                wrinx(crtc,$39,$5A);
              end;
     __trid89:begin
                setinx(crtc,$1e,$80);   (* Enable 17bit display start *)
                if (memmode>_cga2) AND (Version=TR_8900C) then
                begin
                  wrinx(SEQ,$B,0);
                  x:=inp(SEQ+1);    {Switch to new mode}
                  x:=rdinx(SEQ,$E);
                  wrinx(SEQ,$E,$80);
                  setinx(SEQ,$C,$20);
                  wrinx(SEQ,$E,x);
                end;
              end;
        __umc:begin
                OUTP($3BF,$AC);     {Enable extensions}
                setinx(SEQ,8,$80);    {Enable banks bit0}
                clrinx(crtc,$2F,$2);  {Enable >256K}
              end;
     __video7:begin
                wrinx(SEQ,6,$EA);  (* Enable extensions *)
                if Version>=V7_208A then
                  setinx(SEQ,$E0,$80);  {Enable Dual bank}
              end;
     __Weitek:begin
                x:=rdinx(SEQ,$11);
                outp(SEQ+1,x);
                outp(SEQ+1,x);
                outp(SEQ+1,inp(SEQ+1) and $DF);
              end;
  __xbe,__xga:initxga;
  end;
  curbank:=$ffff;    {Set curbank invalid }
  planes:=1;
  setinx(SEQ,4,2);    {Set "more than 64K" flag}

  case memmode of
  _text,_text2,_text4,
  _pl1e,_pl2:planes:=2;
        _pl4:planes:=4;
  end;
  if vseg=SegA000 then
    for x:=1 to mm div 64 do
    begin
      setbank(x-1);
      mem[vseg:$FFFF]:=0;
      fillchar(mem[vseg:0],$ffff,0);
    end;
  AnalyseMode;
  SetBank(OldBank);
end;

const
  set15:array[0..13] of byte=(0,0,$A0,$A0,$A0,$A0,$C1,0,$80,$F0,$A0,0,0,0);
  msk15:array[0..13] of byte=(0,0,$80,$C0,$FF,$E0,$C7,0,$C0,$FF,$E0,0,0,0);

  set16:array[0..13] of byte=(0,0,  0,$E0,$A6,$C0,$C5,0,$C0,$E1,$C0,0,0,0);
  msk16:array[0..13] of byte=(0,0,  0,$C0,$FF,$E0,$C7,0,$C0,$FF,$E0,0,0,0);

  set24:array[0..13] of byte=(0,0,  0,  0,$9E,$E0,$80,0,$60,$E5,$E0,0,0,0);
  msk24:array[0..13] of byte=(0,0,  0,  0,$FF,$E0,$C7,0,$E0,$FF,$E0,0,0,0);


function prepDAC:word;     {Sets DAC up to receive command word}
var x:word;
begin
  dac2comm;
  if dactype=_dacss24 then
  begin
    dac2comm;
    x:=8;
    while (x>0) and (daccomm<>$8E) do
    begin
      daccomm:=inp($3C6);
      dec(x);
    end;
    prepDAC:=daccomm;
  end
  else begin
    prepDAC:=inp($3C6);
    dac2comm;
  end;
end;

procedure dacmode(andmsk,ormsk:word);
begin
  ormsk:=ormsk and (not andmsk);
  if DAC_RS2<>0 then
  begin
    outp($3C6+DAC_RS2,(inp($3C6+DAC_RS2) and andmsk) or ormsk);
  end
  else begin
    outp($3C6,(prepDAC and andmsk) or ormsk);
    dac2pel;

  end;
end;

procedure setdac6;
var m:word;
begin
  case dactype of
   _dacSC24:begin
              dac2comm;
              outp($3C6,$10);
              outp($3C7,8);
              outp($3C8,0);
              outp($3C9,0);
              outp($3C6,0);
              dac2pel;
            end;
    _dacATT,_dacBt484:
            dacmode(0,0);
    _dacCEG,
      _dac8:;
  end;
end;

procedure setdac8;
begin
  case dactype of
   _dacSC24:begin
              dac2comm;
              outp($3C6,$10);
              outp($3C7,8);
              outp($3C8,1);
              outp($3C9,0);
              outp($3C6,0);
              dac2pel;
            end;
    _dacATT,_dacBt484:
            dacmode($FD,2);
    _dacCEG,
      _dac8:;
  end;
end;

function setdac15:boolean;
var m:word;
begin
  if msk15[dactype]=0 then setdac15:=false
  else begin
    m:=msk15[dactype];
    if (chip<>__ET4000) and (chip<>__ET4W32) and
      (dactype<=_dac16) then m:=m or $20;
    dacmode(not m,set15[dactype]);
    setdac15:=true;
  end;
end;

function setdac16:boolean;
var m:word;
begin
  if msk16[dactype]=0 then setdac16:=false
  else begin
    m:=msk15[dactype];
    if (chip<>__ET4000) and (chip<>__ET4W32) and
      (dactype<=_dac16) then m:=m or $20;
    dacmode(not m,set16[dactype]);
    setdac16:=true;
  end;
end;

function setdac24:boolean;
begin
  if msk24[dactype]=0 then setdac24:=false
  else begin
    dacmode(not msk24[dactype],set24[dactype]);
    setdac24:=true;
  end;
end;



procedure setvstart(x,y:word);       {Set the display start address}
var
  l:longint;
  stdvga:boolean;
begin
  stdvga:=true;

  case chip of
    __vesa:begin
               rp.bx:=0;
               rp.cx:=x;
               rp.dx:=y;
               vio($4f07);
               if rp.ax=0 then;
               stdvga:=false;
             end;
  else
    case memmode of
        _text,_text2,_text4:
                  l:=(bytes*y+x*2)*2;
            _cga2:l:=(bytes*y+(x shr 2))*4;
  _cga1,_pl1,_pl2,_pl4:
                  l:=(bytes*y+(x shr 3))*4;
             _pk4:l:=bytes*y+x shr 1;
              _p8:l:=bytes*y+x;
        _p15,_p16:l:=bytes*y+x*2;
             _p24:l:=bytes*y+x*3;
             _p32:l:=bytes*y+x*4;
    end;

    y:=(l shr 18) and (pred(mm) shr 8);
    case chip of
      __aheadb:begin
                 if (memmode=_p8) and ((rdinx(GRC,$C) and $20)>0) then
                 begin
                   y:=y shr 1;
                   l:=l shr 1;
                 end;
                 modinx(GRC,$1c,3,y);
               end;
        __ati1:modinx(IOAdr,$b0,$40,y shl 6);
      __atiGUP,
        __ati2:begin
                 if (rdinx(IOadr,$B0) and $20)>0 then
                 begin
                   l:=l shr 1;
                   y:=y shr 1;
                 end;
                 modinx(IOadr,$b0,$40,y shl 6);
                 modinx(IOadr,$A3,$10,y shl 3);
                 modinx(IOadr,$AD,4,y);
               end;
      __al2101:begin
                 if (rdinx(GRC,$C) and $10)<>0 then
                 begin
                   l:=l shr 1;
                   y:=y shr 1;
                 end;
                 modinx(crtc,$20,7,y);
               end;
    __chips452,__chips453:
               wrinx(IOadr,$C,y);
       __cir54:begin
                 inc(y,y and 6);     {move bit 1-2 to 2-3}
                 modinx(crtc,$1b,$d,y);
               end;
       __cir64:wrinx(GRC,$7C,y);
      __compaq:modinx(GRC,$42,$C,y shl 2);
      __ET3000:begin
                 if (memmode=_p8) or ((rdinx(SEQ,7) and $40)>0) then
                 begin
                   l:=l shr 1;
                   y:=y shr 1;
                 end;
                 modinx(crtc,$23,2,y shl 1);
               end;
      __ET4000:modinx(crtc,$33,3,y);
      __ET4W32:modinx(crtc,$33,$F,y);
         __HMC:begin
                 if (rdinx(SEQ,$E7) and 1)>0 then
                 begin
                   l:=l shr 1;
                   y:=y shr 1;
                 end;
                 modinx(SEQ,$ED,1,y);
               end;
      __iitagx:if (inp(IOadr) and 4)=0 then modinx(crtc,$1e,$20,y shl 5)
               else begin
                 stdvga:=false;
                 wrinx3(IOadr+10,$40,l shr 2);
               end;
        __mxic:modinx(SEQ,$F1,3,y);
         __ncr:modinx(crtc,$31,$f,y);
         __oak:begin
                 if (memmode>_pl4) and (curmode<>$13) then
                 begin
                   l:=l shr 1;
                   y:=y shr 1;
                 end;
                 modinx($3DE,$14,8,y shl 3);  {lower bit}
                 modinx($3DE,$16,8,y shl 2);  {upper bit}
               end;
       __oak87:begin
                 if (memmode>_pl4) and ((rdinx($3DE,$21) and 4)>0) then
                 begin
                   l:=l shr 1;
                   y:=y shr 1;
                 end;
                 modinx($3DE,$17,7,y);
               end;
       __p2000:modinx(GRC,$21,$7,y);
    __paradise:modinx(GRC,$d,$18,y shl 3);
     __realtek:begin
                 if (rdinx(GRC,$C) and $10)<>0 then
                 begin
                   l:=l shr 1;
                   y:=y shr 1;
                 end;
                 if y>1 then inc(y,y and 2);   {shift high bit one up.}
                 modinx(crtc,$19,$50,y shl 4);
               end;
          __s3:begin
                 wrinx(crtc,$38,$48);
                 wrinx(crtc,$39,$A5);
                 modinx(crtc,$31,$30,y shl 4);
                 modinx(crtc,$51,1,y shr 2);
                 wrinx(crtc,$39,$5A);
                 wrinx(crtc,$38,0);
               end;
      __tridcs:modinx(crtc,$1e,$20,y shl 5);
      __trid89:begin
        (*         wrinx(SEQ,$B,0);
                 if (rdinx(SEQ,$D) and $10)>0 then l:=l shr 1;
                 y:=rdinx(SEQ,$B);
                 y:=l shr 18;
                 modinx(crtc,$1E,$20,(y and 1) shl 5);
                 wrinx(SEQ,$B,0);          {select old mode regs}
                 modinx(SEQ,$E,1,y shr 1);
                 if rdinx(SEQ,$B)=0 then;  {Select new mode regs}  *)

                 wrinx(SEQ,$B,0);          {select old mode regs}
                 if (rdinx(SEQ,$D) and $10)>0 then
                 begin
                   l:=l shr 1;
                   y:=y shr 1;
                 end;
                 modinx(SEQ,$E,1,y shr 1);
                 if rdinx(SEQ,$B)=0 then;  {Select new mode regs}
                 modinx(crtc,$1E,$20,y shl 5);
                 if Version=TR_8900CL then modinx(crtc,$27,3,y shr 1);
               end;
         __UMC:begin
                if (rgs.crtcregs.x[$33] and $10)>0 then
                begin
                  l:=l shr 1;
                  y:=y shr 1;
                end;
                modinx(crtc,$33,1,y);
               end;
      __video7:modinx(SEQ,$f6,$70,(y shl 4) and $30);
      __Weitek:modinx(GRC,$D,$18,y shl 3);
   __xbe,__xga:begin
                 stdvga:=false;
                 wrinx3(IOadr+10,$40,l shr 2);
               end;
    end;
  end;
  if stdvga then
  begin
    x:=l shr 2;
    wrinx(crtc,13,lo(x));
    wrinx(crtc,12,hi(x));
  end;
end;



procedure WD_wait;
begin
  if version=WD_90c33 then
  begin
    repeat until (inp($23CE) and 15)=0;
  end
  else
    repeat
      outpw($23C0,$1001);
    until (inpw($23C2) and $800)=0;
end;

procedure WD_outl(index:word;l:longint);
begin
  outpw($23C2,index+(l and $FFF));
  outpw($23C2,index+$1000+(l shr 12));
end;

procedure setHWcurmap(VAR map:CursorType);
var x,y,z,w,lbank,x0,y0:word;
  l:longint;
  bm:array[0..127] of byte;
  mp:record
       case integer of
        0:(b:array[0..2047] of byte);
        1:(w:array[0..1023] of word);
        2:(l:array[0..511] of longint);
	  end;

procedure copyCurMap(bytes:word);
var x,y:word; oldbank : Byte;
begin
	oldbank := curbank;
  setbank(lbank);
  if memmode=_pl4 then
  begin
	 wrinx(GRC,3,0);
	 clrinx(GRC,5,$3);
	 wrinx(GRC,8,$FF);
	 y:=Word(-Integer(bytes div 4));
	 for x:=0 to bytes-1 do
	 begin
		wrinx(SEQ,2,1 shl (x and 3));
		y0:=mem[SegA000:y];
		mem[SegA000:y]:=mp.b[x];
		if (x and 3)=3 then inc(y);
	 end;
  end
  else move(mp,mem[SegA000:Word(-bytes)],bytes);
  setbank(OldBank);
end;

function al_packmap(map:byte):word;
var i,j:word;
begin
  j:=0;
  for i:=0 to 7 do
  begin
    j:=j shl 2+2;
    if ((map shr i) and 1)>0 then dec(j);
  end;
  al_packmap:=j;
end;

function al_packmap2(map:byte):longint;
var i:word;
    j:longint;
begin
  j:=0;
  for i:=0 to 7 do
  begin
    j:=j shl 4+$A;
    if ((map shr i) and 1)>0 then dec(j,5);
  end;
  al_packmap2:=j;
end;

function pack8to16(w:word):word;
var x,i:word;
begin
  i:=0;
  for x:=0 to 7 do
  begin
    i:=i shl 2;
    if ((w shl x) and 128)>0 then inc(i,3);
  end;
  pack8to16:=i;
end;

function swapb(b:word):word;
var i,j:word;
begin
  j:=0;
  for i:=0 to 7 do
    if ((b shr i) and 1)>0 then inc(j,128 shr i);
  swapb:=j;
end;

begin
  if memmode=_pl4 then lbank:=(mm div 256)-1
                  else lbank:=(mm div 64)-1;
  move(map,mp,128);
  move(map,bm,128);
  case chip of
	 __al2101:begin
					x0:=0;
					w:=mm-1;
					fillchar(mp,1024,$aa);
					if memmode<=_p8 then
					begin
					  y:=0;
					  for x:=0 to 127 do
					  begin
						 mp.w[y+x]:=al_packmap(bm[x]);
						 if (x and 3)=3 then inc(y,4);
					  end;
					end
               else
                 for x:=0 to 127 do  {Double size for 64k mode}
                   mp.l[x]:=al_packmap2(bm[x]);
					CopyCurMap(1024);

					wrinx2(crtc,$27,w);
					x:=inp(crtc+6);     {force DAC to address mode}
					x:=inp($3C0);
					y:=rdinx($3C0,$31);
					z:=rdinx($3C0,$32);
					wrinx($3C0,$35,$f);
					wrinx($3C0,$36,0);
					wrinx($3C0,$31,y);
					wrinx($3C0,$32,z);
					outp($3C0,x);
				 end;
    __atiGUP:begin          {Doesn't work yet}
               for x:=0 to 127 do mp.l[x]:=$ffaa5500;

               CopyCurMap(512);
               outpw($1AEE,$5533);
               outpw($1EEE,$2020);
               l:={(mm*longint(1024)-512) div 4} 0;
               outpw($AEE,l);
               outpw($EEE,(l shr 16) or $8000);
             end;
  __chips452:begin
               for x:=255 downto 0 do
                 mp.w[x]:=mp.w[x div 4];
               CopyCurMap(512);

               wrinx(IOadr,$A,0);
               wrinx2m(IOadr,$30,mm*longint(64)-$20);
               wrinx(IOadr,$32,$ff);
               wrinx(IOadr,$37,1);
               wrinx(IOadr,$38,$FF);
               wrinx(IOadr,$39,0);
               wrinx(IOadr,$3A,$F);
             end;
    __compaq:begin
               outp($3C8,$80);
               for x:=0 to 127 do outp($13C7,255);
               outp($3C8,0);
               for x:=0 to 127 do outp($13C7,mp.b[x]);
               outp($13C9,(inp($13C9) and $FC) or 2);
             end;
	  __cir54:begin
					clrinx(SEQ,$12,3);
{					wrinx(GRC,11,$24);} { This caused strange effects with BGI }
{					move(mp,mp.b[128],128);}
					CopyCurMap(256);
					setHWcurcol($ff0000,$ff);
					wrinx(SEQ,$13,$3f);
				 end;
    __ET4W32:begin
               for x:=0 to 511 do mp.l[x]:=$AAAAAAAA;
               y:=128;
            {   if memmode>_p8 then
               begin
                 for x:=127 downto 0 do
                 begin
                   mp.l[x+y]:=al_packmap2(bm[x]);
                   if (x and 3)=0 then dec(y,4);
                 end;
                 CopyCurMap(2048);
                 wrinx($217A,$EE,2);
                 wrinx($217A,$EB,4);
                 l:=mm*longint(256)-512;
               end
               else} begin
                 for x:=127 downto 0 do
                 begin
                   mp.w[x+y]:=al_packmap(bm[x]);
                   if (x and 3)=0 then dec(y,4);
                 end;
                 CopyCurMap(1024);
                 wrinx($217A,$EE,1);
                 wrinx($217A,$EB,2);
                 l:=mm*longint(256)-256;
               end;
               wrinx3($217A,$E8,l);

               wrinx($217A,$EF,2);
               wrinx($217A,$ED,0);
               wrinx($217A,$EC,0);
               wrinx($217A,$E2,0);
               wrinx($217A,$E6,0);
               setinx($217A,$F7,$80);
             end;
    __IITAGX:if spcreg<>0 then
             begin
               outp(IOadr+10,$51);
               outp(spcreg+3,$ff);
               outp(IOadr+10,0);
               outp($3C8,1);
               outp(IOadr+10,$51);
               outp($3C9,0);
               outp($3C9,0);
               outp($3C9,0);
               outp($3C9,$FF);
               outp($3C9,$FF);
               outp($3C9,$FF);
               outp(IOadr+10,0);
               outp($3C8,$80);
               for x:=1 to 128 do outp(spcreg+3,$ff);
               for x:=1 to 128 do outp(spcreg+3,0);
             end;
       __ncr:begin
               w:=(mm*longint(16))-4;    {256 bytes from the end of Vmem.}
               y:=128;
               for x:=127 downto 0 do
               begin
                 mp.b[x+y]:=swapb(mp.b[x]);
                 if (x and 3)=0 then dec(y,4);
               end;
               for x:=0 to 31 do
                 mp.l[x*2]:=mp.l[x*2+1] xor $FFFFFFFF;

               wrinx2m(SEQ,$11,$101);
               CopyCurMap(256);

               wrinx(SEQ,$A,$f);
               wrinx(SEQ,$B,$0);
               wrinx2m(SEQ,$13,0);
               wrinx2m(SEQ,$15,w);
               wrinx(SEQ,$17,$ff);
               wrinx(SEQ,$C,3);
             end;
  __PARADISE:begin
               WD_wait;
               outp($23C0,2);
               for x:=127 downto 0 do
                 mp.w[x]:=mp.b[x] shl 8+$ff;  {XOR cursor, how to set
                                               fore&bkground colors ?}


							 CopyCurMap(256);
							 l:=mm*longint(256)-64;
							 WD_outl($1000,l);

							 if version=WD_90c33 then w:=$C000
																	 else w:=$5000;
							 outpw($23C2,w);
							 if memmode>_p8 then w:=$810 else w:=$800;
							 outpw($23C2,w);
							 outpw($23C0,1);
						 end;
				__S3:begin
							 if memmode>_p8 then
							 begin
								 for x:=0 to 127 do
								 begin
									 y:=pack8to16(bm[x]);
									 mp.l[x]:=(longint(lo(y)) shl 24)+(y and $FF00)+$FF00FF;
								 end;
								 for x:=256 to 511 do mp.w[x]:=$ff;
					end
					else begin
						for x:=0 to 255 do mp.l[x]:=$0000FFFF;  {xor|and}
						y:=376;
						for x:=127 downto 0 do
						begin
						 mp.b[x+y]:=bm[x];
						 if (x and 1)=0 then dec(y,2);
						 if (x and 3)=0 then dec(y,8);
						end;
						if memmode=_pk4 then
						 for x:=0 to 511 do
							mp.b[x]:=lo((mp.b[x] shl 4)+(mp.b[x] shr 4));
					end;
							 CopyCurMap(1024);
							 wrinx(crtc,$39,$A0);
							 wrinx(crtc,$45,2);
							 wrinx2(crtc,$4E,0);
							 wrinx(crtc,$4A,$FF);
							 wrinx(crtc,$4B,0);
							 wrinx2m(crtc,$4C,mm-1);
							 wrinx(crtc,$39,0);
						 end;
		__Video7:begin
               for x:=0 to 63 do mp.w[x]:=mp.w[x] xor $FFFF;
               move(map,mp.b[128],128);
               CopyCurMap(256);
               wrinx(SEQ,$94,$FF);
               modinx(SEQ,$FF,$60,(mm-1) shr 3);
               setinx(SEQ,$A5,$80); {Enable cursor}
             end;
 __xbe,__xga:begin
               wrinx(IOadr+10,$36,0);
               fillchar(mp,1024,$ff);
               wrinx2(IOadr+10,$60,0);
               for x:=0 to 1024 do wrinx(IOadr+10,$6A,mp.b[x]);


               setHWcurcol($ff0000,$ff);
               wrinx(IOadr+10,$32,0);
               wrinx(IOadr+10,$35,0);
               wrinx(IOadr+10,$36,1);
             end;
  end;
end;

procedure setHWcurcol(fgcol,bkcol:longint);
begin
  case chip of
     __cir54:begin
               modinx(SEQ,$12,3,2);
               outp($3C8,$ff);
               outp($3C9,lo(fgcol) shr 2);
               outp($3C9,hi(fgcol) shr 2);
               outp($3C9,fgcol shr 18);
               outp($3C8,0);
               outp($3C9,lo(bkcol) shr 2);
               outp($3C9,hi(bkcol) shr 2);
               outp($3C9,bkcol shr 18);
               modinx(SEQ,$12,3,1);
             end;
    __IITAGX,
 __xbe,__XGA:begin
               wrinx3m(IOadr+10,$38,fgcol);
               wrinx3m(IOadr+10,$3B,bkcol);
             end;
  end;
end;

procedure HWcuronoff(on:boolean);
begin
  case chip of

       __S3:begin
              wrinx(crtc,$39,$a0);
              modinx(crtc,$45,3,2+ord(on));
              wrinx(crtc,$39,0);
            end;
 __paradise:begin
              outp($23C0,2);
              outpw($23C2,ord(on)*$800);
            end;
__xbe,__xga:wrinx(IOadr+10,$36,0);
  end;
end;

procedure setHWcurpos(X,Y:word);
var l:longint;
begin

  if extpixfact>1 then x:=x*extpixfact;
  if extlinfact>1 then Y:=Y*extlinfact;
  case chip of
	 __al2101:begin
					if (rdinx(crtc,$19) and 1)=0 then y:=y*2;
					if memmode>_p8 then x:=x*2;
					wrinx(crtc,$21,x shr 3);
					wrinx(crtc,$23,y shr 1);
					modinx(crtc,$25,$7f,((x and 7) shl 2) + (y shr 9)
										+((y and 1) shl 6) or $20);
				 end;
	 __atiGUP:begin
					outpw($12EE,x and 7);
					outpw($16EE,y and 7);
					x:=x and $FFF8;
					case memmode of
				_p15,_p16:x:=x*2;
					  _p24:x:=x*3;
					end;
					l:=((y and $FFF8)*bytes+x) div 4;
					outpw($2AEE,l);
					outpw($2EEE,l shr 16);
				 end;
  __chips452:begin
					wrinx2m(IOadr,$33,x);
					wrinx2m(IOadr,$35,y);
				 end;
	  __CIR54:BEGIN
					outpw(SEQ,(x shl 5) or $10);
					outpw(SEQ,(y shl 5) or $11);
				 END;
	 __compaq:begin
					inline($fa);
					outpw($93C8,x+32);
					outpw($93C6,y+32);
               inline($fb);
             end;
    __ET4W32:begin
               case memmode of
            _p15,_p16:x:=x*2;
                 _p24:x:=x*3;
               end;
               wrinx2($217A,$E0,x);
               wrinx2($217A,$E4,y);
             end;
    __IITAGX:if spcreg<>0 then
             begin
               outp(IOadr+10,$51);
               outpw(spcreg,x);
               outpw(spcreg,y);
               outp(IOadr+10,0);
             end;
       __ncr:begin
               wrinx2m(SEQ,$D,x);
               wrinx2m(SEQ,$F,y);
             end;
  __PARADISE:begin
               case memmode of
            _p15,_p16:x:=x*2;
                 _p24:x:=x*3;
               end;
               outp($23C0,2);
               if version=WD_90c33 then
               begin
                 outpw($23C2,$D000+x);
                 outpw($23C2,$E000+y);
               end
               else begin
                 outpw($23C2,$6000+x);
                 outpw($23C2,$7000+y);
               end;
             end;
        __S3:begin
               if memmode>_p8 then x:=x*2;
               wrinx(crtc,$39,$A0);
               wrinx2m(crtc,$46,x);
               wrinx2m(crtc,$48,y);
               wrinx(crtc,$45,3);
               wrinx(crtc,$39,0);
             end;
    __Video7:begin
               wrinx2m(SEQ,$9C,X);
               wrinx2m(SEQ,$9E,Y);
             end;
 __xbe,__XGA:begin
               wrinx2(IOadr+10,$30,x);
               wrinx2(IOadr+10,$33,y);
             end;
  end;
end;



procedure AL_DstCoor(xst,yst:word);
var l:longint;
    w:word;
begin
  l:=yst*longint(pixels)+xst;
  repeat until (inp($82AA) and $F)=0;
  if memmode>_p8 then
  begin
    l:=l*2;
    outpw($828A,pixels*2);
  end
  else outpw($828A,pixels);
  outpw($8286,l);
  outp( $8288,l shr 16);
  outpw($829C,xst);
  outpw($829E,yst);
end;

procedure AL_BlitArea(dx,dy:word);
begin
  if memmode>_p8 then dx:=dx*2;
  outpw($828C,dx);
  outpw($828E,dy);
end;

procedure AL_SrcCoor(xst,yst:word);
var l:longint;
    w:word;
begin
  l:=yst*longint(pixels)+xst;
  if memmode>_p8 then
  begin
    l:=l*2;
    outpw($8284,pixels*2);
  end
  else outpw($8284,pixels);
  outpw($8280,l);
  outp( $8282,l shr 16);
end;

procedure WD_coor(index,x,y:word);
var l,b:longint;
begin
  b:=bytes;
  if memmode<=_pl4 then b:=b*8;
  case memmode of
  _p15,_p16:x:=x*2;
       _p24:x:=x*3;
  end;
  l:=b*y+x;
  WD_outl(index,l);
end;

procedure WD_DstCoor(X,Y,dx,dy:word);
var b:longint;
begin
  WD_coor($4000,X,Y);
  b:=bytes;
  if memmode<=_pl4 then b:=b*8;
  case memmode of
  _p15,_p16:dx:=dx*2;
       _p24:dx:=dx*3;
  end;
  outpw($23C2,$6000+dx);
  outpw($23C2,$7000+dy);
  outpw($23C2,$8000+b);
end;

procedure P2000_DstCoor(X,Y,dx,dy:word);
var l:longint;
begin
  l:=longint(pixels)*y+x;
  if memmode>_p8 then
  begin
    dx:=dx*2;
    l:=l*2;
    wrinx2(GRC,$3A,pixels*2);
  end
  else wrinx2(GRC,$3A,pixels);
  wrinx2(GRC,$33,dx);
  wrinx3(GRC,$37,l);
  wrinx2(GRC,$35,dy);
end;

procedure P2000_SrcCoor(X,Y:word);
var l:longint;
begin
  l:=longint(pixels)*y+x;
  if memmode>_p8 then l:=l*2;
  if memmode=_pl4 then wrinx(GRC,5,0);  {set write mode 0}
  wrinx3(GRC,$30,l);
  wrinx2(GRC,$1E,pixels);
end;

procedure P2000_cmd(cmd:word);
begin
  wrinx(GRC,$3D,cmd);
  repeat until (rdinx(GRC,$3D) and 1)=0;
  wrinx(GRC,$3D,0);
end;

procedure S3_fill(xst,yst,dx,dy,col:word);
begin
  repeat until (inp($9AE8) and $FF)=0;
  outpw($82E8,yst);
  outpw($86E8,Xst);
  outpw($96E8,dx);
  outpw($A6E8,col);
  outpw($BAE8,$27);
  outpw($BEE8,dy-1);
  outpw($BEE8,SegA000);
  outpw($9AE8,$40F1);
end;

procedure fillrect(xst,yst,dx,dy:word;col:longint);
const
  masks:array[0..3] of byte=(0,7,3,1);
  maske:array[0..3] of byte=($F8,$FC,$FE,$FF);
  masks4:array[0..7] of byte=(0,$7F,$3F,$1F,$F,7,3,1);
  maske4:array[0..7] of byte=($80,$C0,$E0,$F0,$F8,$FC,$FE,$FF);
var w:word;
    l:longint;
begin
  case chip of
    __al2101:begin
               AL_DstCoor(xst,yst);
               AL_BlitArea(dx,dy);
               wrinx(GRC,$D,col);
               outp( $8290,7);
               outp( $8292,$D);
               outp( $82AA,1);
             end;
    __compaq:begin
               case memmode of
            _pl4,_pk4:col:=(col and 15)*$11111111;
                  _p8:col:=lo(col)*$1010101;
               end;
               repeat until (inp($33CE) and 1)=0;
               if rdinx(GRC,$F)=$A5 then
               begin
                 if memmode=_p8 then
                 begin
                   l:=(yst*bytes+xst) shr 2;
                   w:=bytes shr 2;
                   outp($33C0,masks[xst and 3]);
                   outp($33C1,maske[((xst+dx-1) and 3)]);
                   outp($33C8,(-dx) and 3);
                   outp($33C9,masks[dx and 3]);
                   if ((xst and 3)=0) and ((dx and 3)=0) then inc(dx,4);
                   outpw($23C2,(dx +(xst and 3) +3) shr 2);
                 end
                 else begin
                   l:=yst*bytes+(xst shr 3);
                   w:=bytes;
                   outp($33C0,masks4[xst and 7]);
                   outp($33C1,maske4[(xst+dx-1) and 7]);
                   outp($33C8,(-dx) and 7);
                   outp($33C9,masks4[dx and 7]);
                   if ((xst and 7)=0) and ((dx and 7)=0) then inc(dx,8);
                   outpw($23C2,(dx +(xst and 7) +7) shr 3);
                 end;
                 outpw($23C0,l);
                 outpw($23CA,w);
                 outpw($23CC,w);
                { outpw($33C0,$ffff); }
                 outp($33c7,$c);
                { outpw($33c8,0); }
                 w:=(l shr 2) and $C000;
                 w:=w or ((dy shl 4) and $3000);
                 outpw($23C4,dy+w);
              {   if (xst and 3)>0 then inc(dx,4);
                 if ((xst+dx-1) and 3)>0 then inc(dx,4); }
                 outp($33CF,$30);
               end
               else begin
                 outpw($63CC,xst);
                 outpw($63CE,yst);
                 outpw($23C2,dx);
                 outpw($23C4,dy);
                 outp($33CF,$C0);
                 wrinx(GRC,$5A,2);
               end;
               outpw($33CA,col);
               outpw($33CA,col);
               outpw($33CC,col);
               outpw($33CC,col);
               outp($33CE,9);
             end;
     __cir54:begin
             end;
     __P2000:begin
               wrinx(GRC,$3E,col);
               P2000_DstCoor(xst,yst,dx,dy);
               P2000_cmd($19);
             end;
  __paradise:begin
               WD_wait;
               outpw($23C2,$1000);
               outpw($23C2,$E0FF);
               outpw($23C2,$2000);
               outpw($23C2,$3000);
               WD_DstCoor(xst,yst,dx,dy);
               outpw($23C2,$9300);
					outpw($23C2,SegA000+col);
               w:=$808;
               if memmode>_pl4 then w:=w+$100;
               outpw($23C2,w);
               WD_wait;
             end;
        __S3:if bytes>=1024 then
             begin
               S3_fill(xst,yst,dx,dy,lo(col));
               if (memmode>_p8) then
                 S3_fill(xst+1024,yst,dx,dy,hi(col));
             end;
{ __xbe,__xga:begin
               repeat until (mem[xgaseg:$11] and $80)=0;
               mem[xgaseg:$12]:=1;
               mem[xgaseg:$48]:=3;
               memw[xgaseg:$58]:=col;
               memw[xgaseg:$78]:=xst;
               memw[xgaseg:$7A]:=yst;
               memw[xgaseg:$60]:=dx-1;
               memw[xgaseg:$62]:=dy-1;


               meml[xgaseg:$7C]:=$8118000;
             end; }
  end;
end;

procedure S3_copy(srcX,srcY,dstX,dstY,dx,dy:word);
begin
  repeat until (inp($9AE8) and $FF)=0;
  outpw($82E8,SrcY);
  outpw($86E8,SrcX);
  outpw($8AE8,DstY);
  outpw($8EE8,DstX);

  outpw($96E8,dx);
  outpw($BAE8,$67);
  outpw($BEE8,dy-1);
  outpw($BEE8,SegA000);
  repeat until (inp($9AE8) and $80)=0;
  outpw($9AE8,$C0F1);
end;

procedure copyrect(srcX,srcY,dstX,dstY,dx,dy:word);
var l:longint;
    w,dir:word;
    i1,i2:integer;
begin
  if (DstY<SrcY) or ((SrcY=DstY) and (DstX<SrcX)) then dir:=0
  else begin
    dir:=1;
    SrcX:=SrcX+dx-1;
    SrcY:=SrcY+dy-1;
    DstX:=DstX+dx-1;
    DstY:=DstY+dy-1;
  end;
  case chip of
    __al2101:begin
               AL_DstCoor(DstX,DstY);
               AL_BlitArea(dx,dy);
               AL_SrcCoor(SrcX,SrcY);
               outp( $8290,7);
               outpw($8292,$D);
               outp( $82AA,2);
             end;
    __compaq:begin
               repeat until (inp($33CE) and 1)=0;
               if rdinx(GRC,$F)=$A5 then   {AVGA}
               begin
                 l :=srcy*bytes+srcx;
                 w:=256;
                 if (dir>0) then w:=$FF00;
            {     begin
                   l:=l+(dy-1)*bytes+(dx-1);
                   w:=$ff00;
                 end; }
                 i1:=dsty-srcy;
                 i2:=dstx-srcx;
                 outpw($23C0,l shr 2);
                 outpw($23CC,lo(i1)*256+lo(i2 shr 2));
                 outp($23C2,dx shr 2);
                 outpw($23CA,w{bytes shr 2});
                 outpw($33C0,$ffff);
                 outp($33c7,$c);
                 outpw($33c8,0);
                 w:=(w and $c00) or ((l shr 4) and $C000);
                 w:=w or ((i1 shl 4) and $3000);
                 outpw($23C4,dy+w);
                 outp($33CF,$30);
               end
               else begin            {QVision}
                 outpw($63CC,DstX);
                 outpw($63CE,DstY);
                 outpw($63C0,SrcX);
                 outpw($63C2,SrcY);
                 outpw($23C2,dx);
                 outpw($23C4,dy);
                 outpw($23CA,256);
                 outpw($23CC,256);
                 outp($33CF,$C0);
                 wrinx(GRC,$5A,1);
               end;
               outp($33CE,$11);
             end;
     __cir54:begin
               repeat until (rdinx(GRC,$31) and 1)=0;
               case memmode of
             _p15,_p16:w:=2;
                  _p24:w:=3;
               else w:=1;
               end;
               wrinx2(GRC,$20,dx*w);
               wrinx2(GRC,$22,dy);
               wrinx2(GRC,$24,bytes);
               wrinx2(GRC,$26,bytes);
               wrinx3(GRC,$28,dstY*bytes+dstX*w);
               wrinx3(GRC,$2C,srcY*bytes+srcX*w);
               wrinx(GRC,$32,$d);
               wrinx(GRC,$31,2);
             end;
     __P2000:begin
               P2000_SrcCoor(SrcX,SrcY);
               P2000_DstCoor(DstX,DstY,dx,dy);
               P2000_Cmd(5);
             end;
  __paradise:begin
               WD_wait;
               outpw($23C2,$1000);
               outpw($23C2,$E0FF);
               WD_DstCoor(DstX,DstY,dx,dy);
               WD_Coor($2000,SrcX,SrcY);
               outpw($23C2,$9300);
               w:=$800;
               if memmode>_pl4 then w:=w+$100;
               if dir>0 then w:=w+$400;
               outpw($23C2,w);
               WD_wait;
             end;
        __S3:if bytes>=1024 then
             begin
               S3_copy(SrcX,SrcY,DstX,DstY,dx,dy);
               if (memmode>_p8) then
                 S3_copy(SrcX+1024,SrcY,DstX+1024,DstY,dx,dy);
             end;
 __xbe,__xga:begin
               repeat until (mem[xgaseg:$11] and $80)=0;
               mem[xgaseg:$48]:=3;
               memw[xgaseg:$70]:=SrcX;
               memw[xgaseg:$72]:=SrcY;
               memw[xgaseg:$78]:=DstX;
               memw[xgaseg:$7A]:=DstY;
               memw[xgaseg:$60]:=dx-1;
               memw[xgaseg:$62]:=dy-1;


               memw[xgaseg:$7C]:=$8000;
               memw[xgaseg:$7E]:=$811;
             end;
  end;
end;

procedure swp(var i,j:integer);
var z:integer;
begin
  z:=i;
  i:=j;
  j:=z;
end;

procedure S3_line(x0,y0,x1,y1,col:integer);
var w,z:word;
begin
  repeat until (inp($9AE8) and $FF)=0;
  outpw($82E8,Y0);
  outpw($86E8,X0);
  w:=0;z:=0;
  x1:=x1-x0;
  if x1<0 then
  begin
    x1:=-x1;
    w:=w or $20;
    z:=1;
  end;
  y1:=y1-y0;
  if y1<0 then
  begin
    y1:=-y1;
    w:=w or $80;
  end;
  if x1<y1 then
  begin
    swp(x1,y1);
    w:=w or $40;
  end;
  outpw($8AE8,2*y1);
  outpw($8EE8,2*(y1-x1));
  outpw($92E8,2*y1-x1-z);
  repeat until (inp($9AE8) and $FF)=0;
  outpw($96E8,x1);
  outpw($A6E8,col);
  outpw($BAE8,$27);
  outpw($BEE8,SegA000);
  outpw($9AE8,$2017+w);
end;


procedure line(x0,y0,x1,y1:integer;col:longint);
var l:longint;
  z,w:word;
begin
  case chip of
    __al2101:begin
               AL_DstCoor(x0,y0);
               wrinx(GRC,$D,col);
               outpw($82A8,$FFFF);
               w:=0;
               x1:=x1-x0;
               if x1<0 then
               begin
                 x1:=-x1;
                 w:=w or $100;
               end;
               if memmode>_p8 then x1:=x1*2;
               y1:=y1-y0;
               if y1<0 then
               begin
                 y1:=-y1;
                 w:=w or $200;
               end;
               if x1<y1 then
               begin
                 swp(x1,y1);
                 w:=w or $400;
               end;
               outpw($82A2,2*y1);
               outpw($82A6,2*y1-x1);
               outpw($82A4,2*(y1-x1));
               outpw($828E,x1+1);
               outpw($8292,$80D+w);
               outp ($8290,0);
               outp ($82AA,8);
             end;
        __S3:if bytes>=1024 then
             begin
               S3_line(x0,y0,x1,y1,lo(col));
               if (memmode>_p8) then
                 S3_line(x0+1024,y0,x1+1024,y1,hi(col));
             end;
 __xbe,__xga:begin
               repeat until (mem[xgaseg:$11] and $80)=0;
               meml[xgaseg:$7C]:=$5010000;

             end;
  end;
end;

begin
	HWGraphDataFilePath := '\BP\BGI';
end.