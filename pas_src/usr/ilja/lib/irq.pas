unit IRQ;

interface

function Hrd2Sft(IRQN : Byte) : Byte;
function Sft2Hrd(IntN : Byte) : Byte;
procedure SetIRQ(INum : Byte; State : Boolean);

implementation

function Hrd2Sft(IRQN : Byte) : Byte;
begin
	if IRQN > 15 then Hrd2Sft := $FF
	else
	if IRQN > 7 then Hrd2Sft := IRQN+$68
	else Hrd2Sft := IRQN+$08;
end;

function Sft2Hrd(IntN : Byte) : Byte;
begin
	Sft2Hrd := $FF;
	if (IntN in [$08..$0F]) then Sft2Hrd := IntN-8;
	if (IntN in [$70..$77]) then Sft2Hrd := IntN-$68;
end;

procedure SetIRQ(INum : Byte; State : Boolean);
var
	IRQFlags : Byte;
	IC: Byte;
begin
	if INum < 8 then IC := $20;
	if INum < 16 then IC := $A0;
	if INum >= 16 then Exit;
	IRQFlags := Port[IC+1];
		if State then
		case INum of
			0 : IRQFlags := IRQFlags and $FE;
			1 : IRQFlags := IRQFlags and $FD;
			2 : IRQFlags := IRQFlags and $FB;
			3 : IRQFlags := IRQFlags and $F7;
			4 : IRQFlags := IRQFlags and $EF;
			5 : IRQFlags := IRQFlags and $DF;
			6 : IRQFlags := IRQFlags and $BF;
			7 : IRQFlags := IRQFlags and $7F;
		end
		else
		case INum of
			0 : IRQFlags := IRQFlags or not $FE;
				1 : IRQFlags := IRQFlags or not $FD;
			2 : IRQFlags := IRQFlags or not $FB;
			3 : IRQFlags := IRQFlags or not $F7;
			4 : IRQFlags := IRQFlags or not $EF;
			5 : IRQFlags := IRQFlags or not $DF;
			6 : IRQFlags := IRQFlags or not $BF;
			7 : IRQFlags := IRQFlags or not $7F;
		end;
		Port[IC+1] := IRQFlags;
end;

end.
