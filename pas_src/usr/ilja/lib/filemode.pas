const
	fm_ReadOnly = $00;
	fm_WriteOnly = $01;
	fm_ReadWrite = $02;
	fm_DenyRead = $30;
	fm_DenyWrite = $20;
	fm_DenyReadWrite = $10;
	fm_Exclusive = fm_DenyReadWrite;
	fm_DenyNone = $40;
	fm_Inherit = $80;
