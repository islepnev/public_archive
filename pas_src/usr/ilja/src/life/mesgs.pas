unit Mesgs;

interface

procedure Header;
procedure SimpleDialog(Proc: pointer);
procedure mesg_About;
procedure mesg_Help;

implementation

uses Crt, Graph, IOErrors, LifeDef, LifeProc;

procedure Header;
begin
	WriteLn(aName, '  Version ',aVer, ' for ',aARCH);
	WriteLn(Copyright);
	WriteLn;
end;

procedure SimpleDialog(Proc: pointer);
var MyProc : procedure;
begin
	if Proc = nil then Exit;
	@MyProc := Proc;
	ClearDevice;
	DirectVideo := False;
	GotoXY(1, 1);
	Header;
	MyProc;
	WriteLn;
	Write('Press any key to continue');
	ReadKey;
	DirectVideo := True;
	ClearDevice;
	ShowField(True);
end;

procedure mesg_Help;
begin
	WriteLn('Help on keys');
	WriteLn;
	WriteLn('A    - about this program and contact information');
	WriteLn('R    - restart pattern');
	WriteLn('N    - generate new random field');
	WriteLn('F    - refresh screen');
	WriteLn('*    - increase render/view step (if < 32)');
	WriteLn('/    - decrease render/view step (if > 1)');
	WriteLn('X    - refresh screen');
	WriteLn('I    - show statistics');
	WriteLn('G    - draw graphic');
	WriteLn('S    - save current field to file (not implemented yet)');
	WriteLn('F1,H - this screen');
	WriteLn('ESC  - quit');
end;

procedure mesg_About;
begin
	WriteLn('About');
	WriteLn;
	WriteLn('This is an implementation of Conuell''s cellular automate known as ''Life''');
	WriteLn('in 2-dimensional field. The rules of ''Life'' are the following: if a cell');
	WriteLn('has 2 or 3 neighbours, it stays at it''s place till the next generation, ');
	WriteLn('otherwise it dies. If an empty cell has 3 neighbours, next generation it ');
	WriteLn('fills with ''biomass'', i.e. becomes a ''cell''');
	WriteLn;
	WriteLn('This version is implemented using specific assembler instructions');
	WriteLn('of i80386 processor to speed up code by the factor of 10+ compared');
	WriteLn('to simple realization on Pascal ''if'' operators.');
	WriteLn;
	WriteLn('If you want to contribute in any way, or to port to other platforms,');
	WriteLn('you can reach the author by email or ICQ. Bug reports are appreciated.');
	WriteLn;
	WriteLn('email:  ivs@writeme.com');
	WriteLn('UIN: 5433273 - If you don''t know what this mean, visit www.mirabilis.com');
	WriteLn;
	WriteLn('Don''t forget to visit aLife www page: http://pisk.jinr.ru/ilja/aLife/');
end;

end.