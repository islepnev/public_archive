TITLE LIFE

DATA	SEGMENT	WORD PUBLIC

	EXTRN	TEST8086:BYTE
	EXTRN	XSIZE, YSIZE : WORD
	EXTRN	FIELD, TEMPFIELD : FAR
	EXTRN	SHOWCELL : FAR
DATA	ENDS

CODE SEGMENT BYTE PUBLIC

ASSUME	CS:CODE, DS:DATA

PUBLIC	ITERATE, EDGES, SHOWF
;
;
ITERATE	PROC	FAR
.386
	PUSH	ES
	PUSH	DI
	PUSH	DS
	PUSH	BP

	MOVZX	EAX, XSIZE
	MOVZX	EDX, YSIZE
	MUL	EDX
	SHL	EDX, 16
	OR	EAX, EDX
	MOV	ECX, EAX
; now in ECX we have number of cells
	MOVZX	EBX, XSIZE ; EBX = xSize
;
	LES	DI,DWORD PTR [TEMPFIELD]
; now ES:[DI] points to the top of TEMPFIELD
	LDS	BP,DWORD PTR [FIELD] ;                     *** DS changed ***
; now DS:[BP] points to the top of FIELD
;

@CYCLE:	DEC	ECX
; in ECX we have the number of current cell
; null neighbours
	MOV	DL, 0
; DL  = neighbours
; ECX = 'cell number'
; EBX = xSize
	MOV	EAX, ECX      ;
	DEC	EAX           ; here we find the left-top neighbour
	SUB	EAX, EBX      ;
	BT	DWORD PTR DS:[BP], EAX ; CF = ' cell present'
	ADC	DL, 0

	INC	EAX
	BT	DWORD PTR DS:[BP], EAX ; CF = ' cell present'
	ADC	DL, 0

	INC	EAX
	BT	DWORD PTR DS:[BP], EAX ; CF = ' cell present'
	ADC	DL, 0

	ADD	EAX, EBX
	BT	DWORD PTR DS:[BP], EAX ; CF = ' cell present'
	ADC	DL, 0

	ADD	EAX, EBX
	BT	DWORD PTR DS:[BP], EAX ; CF = ' cell present'
	ADC	DL, 0

	DEC	EAX
	BT	DWORD PTR DS:[BP], EAX ; CF = ' cell present'
	ADC	DL, 0

	DEC	EAX
	BT	DWORD PTR DS:[BP], EAX ; CF = ' cell present'
	ADC	DL, 0

	SUB	EAX, EBX
	BT	DWORD PTR DS:[BP], EAX ; CF = ' cell present'
	ADC	DL, 0

	CMP	DL, 3
	JNE	@@10
	BTS	DWORD PTR ES:[DI], ECX ; born cell
	JMP	@@11
@@10:
;	CMP	DL,3
;	JE	@@11
	CMP	DL,2
	JE	@@11
	BTR	DWORD PTR ES:[DI], ECX ; kill cell

@@11:	CMP	ECX, 0
	JNE	@CYCLE

	POP	BP
	POP	DS
	POP	DI
	POP	ES
	RET
ITERATE ENDP

EDGES	PROC	FAR
.386
	PUSH	ES
	PUSH	DI
	LES	DI,DWORD PTR [TEMPFIELD]
; now correct bounds
;     dst = left,top
	MOV	EBX, 0
	BTR     DWORD PTR ES:[DI], EBX ; left,top = 0
	MOVZX	EAX, XSIZE   ;
	MOVZX	EDX, YSIZE   ;
	DEC	EDX          ;
	MUL	EDX          ;
	SHL	EDX, 16      ;
	OR	EAX, EDX     ; EAX = right-1,bottom-1
	SUB	EAX, 2       ; EAX = right-1,bottom-1
	BT	DWORD PTR ES:[DI], EAX
	JNC	@@a
	BTS     DWORD PTR ES:[DI], EBX ; left,top = 1
@@A:
; dst = right,top
	MOVZX	EBX, XSIZE   ;
	DEC	EBX          ;
	BTR     DWORD PTR ES:[DI], EBX
	MOVZX	EAX, XSIZE   ;
	MOVZX	EDX, YSIZE   ;
	SUB	EDX,2        ;
	MUL	EDX          ;
	SHL	EDX, 16      ;
	OR	EAX, EDX     ;
	INC	EAX
	BT	DWORD PTR ES:[DI], EAX
	JNC	@@b
	BTS     DWORD PTR ES:[DI], EBX
@@B:
; dst = right,bottom
	MOVZX	EAX, XSIZE   ;
	MOVZX	EDX, YSIZE   ;
	MUL	EDX          ;
	SHL	EDX, 16      ;
	OR	EAX, EDX     ;
	MOV	EBX, EAX     ;
	DEC	EBX          ; EBX = left,bottom
	MOVZX	EAX, XSIZE   ;
	INC	EAX          ; EAX = right-1,top+1
	BTR     DWORD PTR ES:[DI], EBX ; right,top = 0
	BT	DWORD PTR ES:[DI], EAX
	JNC	@@d
	BTS     DWORD PTR ES:[DI], EBX
@@d:
; dst = left,bottom
	MOVZX	EAX, XSIZE   ;
	MOVZX	EDX, YSIZE   ;
	DEC	EDX
	MUL	EDX          ;
	SHL	EDX, 16      ;
	OR	EAX, EDX     ;
	MOV	EBX, EAX     ;
	MOVZX	EAX, XSIZE
	ADD	EAX, EAX
	SUB	EAX, 2
	BTR     DWORD PTR ES:[DI], EBX ; right,top = 0
	BT	DWORD PTR ES:[DI], EAX
	JNC	@@c
	BTS     DWORD PTR ES:[DI], EBX
@@C:
; bottom -> top
	MOVZX	EAX, XSIZE   ;
	MOVZX	EDX, YSIZE   ;
	SUB	EDX, 2       ;
	MUL	EDX          ;
	SHL	EDX, 16      ;
	OR	EAX, EDX     ;
	INC	EAX          ; EAX = src
	MOV	EBX, 1       ; EBX = dst
	MOVZX	ECX, XSIZE   ;
	SUB	ECX, 2       ; ECX = xSize - 2
@@e:
	BTR     DWORD PTR ES:[DI], EBX
	BT	DWORD PTR ES:[DI], EAX
	JNC	@@e1
	BTS     DWORD PTR ES:[DI], EBX
@@e1:
	INC	EAX
	INC	EBX
	LOOP	@@e

; top -> bottom
	MOVZX	EAX, XSIZE   ;
	MOVZX	EDX, YSIZE   ;
	DEC	EDX          ;
	MUL	EDX          ;
	SHL	EDX, 16      ;
	OR	EAX, EDX     ;
	INC	EAX          ;
	MOV	EBX, EAX     ; EBX = dst
	MOVZX	EAX, XSIZE   ;
	INC	EAX          ; EAX = src
	MOVZX	ECX, XSIZE   ;
	SUB	ECX, 2       ; ECX = xSize - 2
@@f:
	BTR     DWORD PTR ES:[DI], EBX
	BT	DWORD PTR ES:[DI], EAX
	JNC	@@f1
	BTS     DWORD PTR ES:[DI], EBX
@@f1:
	INC	EAX
	INC	EBX
	LOOP	@@f

; left -> right
	MOVZX	EDX, XSIZE   ;
	MOV	EBX, EDX
	ADD	EBX, EBX
	DEC	EBX          ; EBX = dst
	MOV	EAX, EDX
	INC	EAX          ; EAX = src
	MOVZX	ECX, XSIZE   ;
	SUB	ECX, 2       ; ECX = xSize - 2
@@g:
	BTR     DWORD PTR ES:[DI], EBX
	BT	DWORD PTR ES:[DI], EAX
	JNC	@@g1
	BTS     DWORD PTR ES:[DI], EBX
@@g1:
	ADD	EAX, EDX
	ADD	EBX, EDX
	LOOP	@@g

; right -> left
	MOVZX	EDX, XSIZE   ;
	MOV	EBX, EDX     ; EBX = dst
	MOV	EAX, EDX
	ADD	EAX, EAX
	SUB	EAX, 2       ; EAX = src
	MOVZX	ECX, XSIZE   ;
	SUB	ECX, 2       ; ECX = xSize - 2
@@h:
	BTR     DWORD PTR ES:[DI], EBX
	BT	DWORD PTR ES:[DI], EAX
	JNC	@@h1
	BTS     DWORD PTR ES:[DI], EBX
@@h1:
	ADD	EAX, EDX
	ADD	EBX, EDX
	LOOP	@@h


	POP	DI
	POP	ES
	RET
EDGES	ENDP

SHOWF	PROC	FAR
.386
	PUSH	BP
	MOV	BP, SP
; count FiedSize in DW
	XOR	EAX, EAX      ;
	MOV	AX, SS:[BP+6]   ; ySize
	XOR	EDX, EDX        ;
	MOV	DX, SS:[BP+8]   ; xSize
	MUL	EDX          ;
	SHL	EDX, 16      ;
	OR	EAX, EDX     ;
	ADD	EAX, 31      ;
	XOR	EDX, EDX     ;
	MOV	ECX, 32      ;
	DIV	ECX          ;
	MOV	CX, AX       ;

; load ES:SI = NewField;
; load FS:DI = OldField;
	LES	SI, SS:[BP+14]
	LFS	DI, SS:[BP+10]
	MOV	GS, SI
	CLD
@@SC:
	MOV	EDX, ES:[SI]
	XOR	EDX, FS:[DI]
@@BTB:
	MOV	EAX, 0
	BSF	EAX, EDX       ; find first '1'
	JZ	@@BTE          ; all '0's?
	PUSH	ECX
	PUSH	ES
	PUSH	SI
	PUSH	DI
	BTR	EDX, EAX       ; clear bit #EAX
	PUSH	EDX
	XOR	DI, DI
	BT	DWORD PTR ES:[SI], EAX
	ADC	DI, 0
	XOR	EBX, EBX
	MOV	BX, SI
	MOV	CX, GS
	SUB	BX, CX
	SHL	EBX, 3
	ADD	EAX, EBX       ; EAX = index

	XOR	EDX, EDX
	XOR	EBX, EBX
	MOV	BX, SS:[BP+8] ; xSize
	DIV	EBX
; window checking
;       CMP     DX, 0
;       JE      @@XX
;       CMP     AX, 0
;       JE      @@XX
;       MOV     BX, SS:[BP+8] ; xSize
;       DEC     BX
;       CMP     DX, BX
;       JE      @@XX
;       MOV     BX, SS:[BP+6] ; ySize
;       DEC     BX
;       CMP     AX, BX
;       JE      @@XX
	PUSH	DX ; x-coord
	PUSH	AX ; y-coord
	PUSH	DI ; state
	CALL	DWORD PTR [SHOWCELL]
@@XX:	POP	EDX
	POP	DI
	POP	SI
	POP	ES
	POP	ECX
	JMP	@@BTB
@@BTE:
	DEC	CX
	ADD	SI,4
	ADD	DI,4
;	cld
;	REPE CMPSD ; find next different cells
;	JZ	@@SE
;	LOOP	@@SC
	CMP	CX, 0
	JNZ	@@SC
@@SE:
;	CMP	DI, SI
;	JL	@@SCAN
;
	LEAVE
	RET	12
SHOWF	ENDP

CODE	ENDS
END
