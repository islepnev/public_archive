TITLE	CPU_ID

DATA	SEGMENT	WORD PUBLIC

	EXTRN	TEST8086:BYTE

DATA	ENDS

CODE SEGMENT BYTE PUBLIC

ASSUME	CS:CODE, DS:DATA

PUBLIC	TEST80X86
; procedure TEST80X86 sets Test8086 variable as follows:
; 0: 8086
; 1: 80286
; 2: 80386
; 3: 80486
;
TEST80X86	PROC	NEAR
	CMP	TEST8086,2
	JB	@@1
	.386
	MOV	EDX,ESP
	AND	ESP,NOT 3
	PUSHFD
	POP	EAX
	MOV	ECX,EAX
	XOR	EAX,4000H
	PUSH	EAX
	POPFD
	PUSHFD
	POP	EAX
	XOR	EAX,ECX
	SHR	EAX,18
	AND	EAX,1
; EAX=1 IF 386
; EAX=0 IF 486
	CMP	EAX,1
	JE	@@2
	MOV	TEST8086,3
@@2:	PUSH	ECX
	POPFD
	MOV	ESP,EDX
@@1:	RET
TEST80X86	ENDP

CODE	ENDS
END
