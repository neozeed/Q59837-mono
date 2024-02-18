; thunk0.asm (emx+gcc) -- Copyright (c) 1992-1993 by Eberhard Mattes

                .386

                .MODEL  FLAT

                PUBLIC  _emx_16to32
                PUBLIC  _emx_32to16

TEXT32          SEGMENT DWORD PUBLIC FLAT 'CODE'

                EXTRN   DosFlatToSel:PROC
                EXTRN   DosSelToFlat:PROC
;
;
;
                ALIGN  4
_emx_32to16     PROC
                MOV     EAX, [ESP+4]
                JMP     DosFlatToSel
_emx_32to16     ENDP

;
;
;
                ALIGN  4
_emx_16to32     PROC
                MOV     EAX, [ESP+4]
                JMP     DosSelToFlat
_emx_16to32     ENDP

TEXT32          ENDS

                END
