; thunk1.asm (emx+gcc) -- Copyright (c) 1992-1994 by Eberhard Mattes

                .386

                .MODEL  FLAT

                PUBLIC  _emx_thunk1

TEXT32          SEGMENT DWORD PUBLIC FLAT 'CODE'

;
; unsigned long _emx_thunk1 (void *args, void *fun)
;
; Call 16-bit code
;
; In:   ARGS    Pointer to argument list. The first DWORD contains the
;               number of argument bytes, excluding that DWORD. The
;               remaining values are packed appropriately for calling
;               a 16-bit function. Pointers have been converted to
;               sel:offset format
;
;       FUN     16:16 address of 16-bit function to be called. Both
;               `pascal' and `cdecl' calling conventions are supported.
;               The function must not change the DI register
;
; Out:  EAX     Return value (DX:AX) of 16-bit function
;
; Stack on entry (1):
;
;       ...
;       FUN
;       ARGS
; ESP-> return address
; ---------------------------------------------------------------------------
;
; Stack after setting up stack frame (2):
;
;       ...
;       FUN
;       ARGS
;       return address
; EBP-> caller's EBP
;       caller's ESI
;       caller's EDI
;       caller's EBX
;       caller's ES
; ---------------------------------------------------------------------------
;
; Stack before jumping to 16-bit code (3):
;
;       ...
;       FUN
;       ARGS
;       return address
; EBP-> caller's EBP
;       caller's ESI
;       caller's EDI
;       caller's EBX
;       caller's ES
;       padding                                 (0 to 1000H-4 bytes)
; DI->  SS:ESP -> caller's EBP                  (2 DWORDs, DWORD-aligned)
; SP->  arguments                               (WORD aligned)
; ---------------------------------------------------------------------------
;
; Stack after return from 16-bit code (4):
;
;       ...
;       FUN
;       ARGS
;       return address
;       caller's EBP
;       caller's ESI
;       caller's EDI
;       caller's EBX
;       caller's ES
;       padding                                 (0 to 1000H-4 bytes)
; DI->  SS:ESP -> caller's EBP                  (2 DWORDs, DWORD-aligned)
; SP->  arguments                               (for cdecl functions)
; ---------------------------------------------------------------------------
;
                ALIGN  4
ARGS            EQU     (DWORD PTR [EBP+2*4])
FUN             EQU     (DWORD PTR [EBP+3*4])
_emx_thunk1     PROC                            ; (1)
                PUSH    EBP                     ; Set up stack frame
                MOV     EBP, ESP
                PUSH    ESI                     ; Save ESI
                PUSH    EDI                     ; Save EDI
                PUSH    EBX                     ; Save EBX
                PUSH    ES                      ; (2) Save ES
                MOV     DX, SS                  ; Prepare conversion of
                AND     DL, 3                   ; ESP to SS:SP
                OR      DL, 4                   ; LDT
                MOV     EAX, ESP                ; Check stack
                CMP     AX, 1000H               ; 1000H bytes left in this 64K
                JAE     SHORT THUNK1_1          ; segment? Yes => skip
                XOR     AX, AX                  ; Move ESP down to next 64K seg
                MOV     BYTE PTR [EAX], 0       ; Stack probe
                XCHG    ESP, EAX                ; Set new ESP, EAX := old ESP
THUNK1_1:       PUSH    SS                      ; Save original SS:ESP on
                PUSH    EAX                     ; stack (points to saved EBX)
;
; Copy arguments
;
                MOV     ESI, ARGS
                LODSD
                MOV     ECX, EAX
                SUB     ESP, ECX
                MOV     EDI, ESP
                SHR     ECX, 2
                REP     MOVSD
                MOV     ECX, EAX
                AND     ECX, 03H
                REP     MOVSB                   ; EDI now points to SS:ESP
                LEA     ESI, FUN
;
; Convert ESP to SS:SP
;
                MOV     EAX, ESP
                ROL     EAX, 16
                SHL     AX, 3
                OR      AL, DL
                PUSH    EAX                     ; Push new SS
                SHR     EAX, 16
                PUSH    EAX                     ; Push new ESP
                LSS     ESP, [ESP]              ; Switch to new SS:SP
                JMP     FAR PTR TEXT16:THUNK16_CALL ; (3)
;
; Jump to 16-bit code
;
                RETF

                ALIGN  4
THUNK1_RET::    MOVZX   ESP, DI                 ; (4) Remove arguments
                LSS     ESP, [ESP]              ; Get 32-bit stack pointer
                POP     ES                      ; Restore ES
                POP     EBX                     ; Restore EBX
                POP     EDI                     ; Restore EDI
                POP     ESI                     ; Restore ESI
                POP     EBP                     ; Restore EBP
                MOVZX   EAX, AX                 ; Compute return value
                MOVZX   EDX, DX
                SHL     EDX, 16
                OR      EAX, EDX
                RET                             ; Return to 32-bit code

_emx_thunk1     ENDP

TEXT32          ENDS

;
;
;

TEXT16          SEGMENT DWORD PUBLIC USE16 'CODE'

;
; Call 16-bit function
;
; In:    ESI    Points to 16:16 function address
;
                ALIGN  4
THUNK16_CALL:   CALL    DWORD PTR [ESI]
                JMP     FAR PTR FLAT:THUNK1_RET

TEXT16          ENDS

                END
