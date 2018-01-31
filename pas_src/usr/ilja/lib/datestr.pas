const
	days : array [0..6] of String[9] =
	('Sunday','Monday','Tuesday',
	 'Wednesday','Thursday','Friday',
	 'Saturday');
	months : array[1..12] of String[3] =
	('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
	days3 : array [0..6] of String[3] =
	('Sun','Mon','Tue','Wed','Thr','Fri','Sat');
function DateFName:String;
var
	y, m, d, dow, hr, mn, sc, sch, r : Word;
	sy,sm,sd,sr,hrs,mns,scs,schs,s: String[8];
begin
	GetDate(y,m,d,dow);
	GetTime(hr,mn,sc,sch);
	Str(y,sy); sy[0] := #2; Str(m,sm);
	Str(d,sd); if d<10 then sd := '0'+sd;
	Str(hr,hrs); if hr<10 then hrs := '0'+hrs;
	Str(mn,mns); if mn<10 then mns := '0'+mns;
{	r := 0; Str(r,sr);}
	DateFName := months[m]+sd+'-'+hrs+'.'+mns;
end;

function DateStr:String;
var
	y, m, d, dow, hr, mn, sc, sch : Word;
	sy,sm,sd,hrs,mns,scs,schs,s: String[8];
begin
	GetDate(y,m,d,dow);
	GetTime(hr,mn,sc,sch);
	Str(y,sy);
	Str(d,sd); if d<10 then sd := '0'+sd;
	Str(hr,hrs); if hr<10 then hrs := '0'+hrs;
	Str(mn,mns); if mn<10 then mns := '0'+mns;
	Str(sc,scs); if sc<10 then scs := '0'+scs;
	DateStr := days3[dow]+' '+sd+' '+months[m]+' '+sy+'  '+hrs+':'+mns+':'+scs;
end;
