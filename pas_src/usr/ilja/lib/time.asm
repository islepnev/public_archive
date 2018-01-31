TITLE CLK

;DATA    SEGMENT WORD PUBLIC
;        EXTRN   TEST8086:BYTE
;        EXTRN   XSIZE, YSIZE : WORD
;        EXTRN   FIELD, TEMPFIELD : FAR
;        EXTRN   SHOWCELL : FAR
;DATA    ENDS

CODE SEGMENT BYTE PUBLIC

ASSUME  CS:CODE
;, DS:DATA

PUBLIC  CLOCK
;
;
CLOCK PROC      FAR
.286
             PUSH    DS              ; save caller's data segment
             MOV     DX, 40h
             MOV     DS, DX          ;  access ticker counter
             MOV     BX, 6Ch         ; offset of ticker counter in segm.
             MOV     DX, 43h         ; timer chip control port
             MOV     AL, 4           ; freeze timer 0
             PUSHF                   ; save caller's int flag setting
             CLI                     ; make reading counter an atomic operation
             MOV     DI, DS:[BX]     ; read BIOS ticker counter
             MOV     CX, DS:[BX+2]
             STI                     ; enable update of ticker counter
             OUT     DX, AL          ; latch timer 0
             CLI                     ; make reading counter an atomic operation
             MOV     SI, DS:[BX]     ; read BIOS ticker counter
             MOV     BX, DS:[BX+2]
             IN      AL, 40h         ; read latched timer 0 lo-byte
             MOV     AH, AL          ; save lo-byte
             IN      AL, 40h         ; read latched timer 0 hi-byte
             POPF                    ; restore caller's int flag
             XCHG    AL, AH          ; correct order of hi and lo
             CMP     DI, SI          ; ticker counter updated ?
             JE      @no_update      ; no
             OR      AX, AX          ; update before timer freeze ?
             JNS     @no_update      ; no
             MOV     DI, SI          ; use second
             MOV     CX, BX          ;  ticker counter
@no_update:  NOT     AX              ; counter counts down
             MOV     BX, 36EDh       ; load multiplier
             MUL     BX              ; W1 * M
             MOV     SI, DX          ; save W1 * M (hi)
             MOV     AX, BX          ; get M
             MUL     DI              ; W2 * M
             XCHG    BX, AX          ; AX = M, BX = W2 * M (lo)
             MOV     DI, DX          ; DI = W2 * M (hi)
             ADD     BX, SI          ; accumulate
             ADC     DI, 0           ;  result
             XOR     SI, SI          ; load zero
             MUL     CX              ; W3 * M
             ADD     AX, DI          ; accumulate
             ADC     DX, SI          ;  result in DX:AX:BX
             MOV     DH, DL          ; move result
             MOV     DL, AH          ;  from DL:AX:BX
             MOV     AH, AL          ;   to
             MOV     AL, BH          ;    DX:AX:BH
             MOV     DI, DX          ; save result
             MOV     CX, AX          ;  in DI:CX
             MOV     AX, 25110       ; calculate correction
             MUL     DX              ;  factor
             SUB     CX, DX          ; subtract correction
             SBB     DI, SI          ;  factor
             XCHG    AX, CX          ; result back
             MOV     DX, DI          ;  to DX:AX
             POP     DS              ; restore caller's data segment
             RET     4
CLOCK   ENDP

CODE	ENDS
END
