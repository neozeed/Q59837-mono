/*
 * MONO.C
 *
 * Writes directly to the monochrome screen buffer.
 *
 * Uses VioScrLock and VioScrUnlock to ensure that the program doesn't
 * get swapped to the background while writing to the video buffer.
 *
 * This program basically clears the monochrome screen buffer.
 *
 */

#define INCL_VIO
#define INCL_DOSPROCESS

#define MONOBUF     (char  *) 0xB8000L  /* Address of mono screen
                                           /* buffer */
#define BYTE_SIZE   4000                   /* 80x25 * 2 */

#include <os2.h>
#include <stdio.h>
#include "conio.h"

#ifndef _OS2THUNK_H
#define _OS2THUNK_H

typedef unsigned long _far16ptr;

_far16ptr _emx_32to16 (void *ptr);
void *_emx_16to32 (_far16ptr ptr);

unsigned long _emx_thunk1 (void *args, void *fun);

#define _THUNK_PASCAL_PROLOG(SIZE) \
  ({ char _tb[(SIZE)+4]; void *_tp = _tb + sizeof (_tb); \
       *(unsigned long *)_tb = (SIZE);
#define _THUNK_PASCAL_CHAR(ARG)     _THUNK_PASCAL_SHORT (ARG)
#define _THUNK_PASCAL_SHORT(ARG)    (*--((unsigned short *)_tp) = (ARG))
#define _THUNK_PASCAL_LONG(ARG)     (*--((unsigned long *)_tp) = (ARG))
#define _THUNK_PASCAL_FLAT(ARG)     _THUNK_PASCAL_LONG (_emx_32to16 (ARG))
#define _THUNK_PASCAL_FAR16(ARG)    _THUNK_PASCAL_LONG (ARG)
#define _THUNK_PASCAL_FUNCTION(FUN) _16_##FUN
#define _THUNK_PASCAL_CALL(FUN)     _emx_thunk1 (_tb, (void *)(_16_##FUN)); })
#define _THUNK_PASCAL_CALLI(FUN)    _emx_thunk1 (_tb, (void *)(FUN)); })

#define _THUNK_C_PROLOG(SIZE) \
  ({ char _tb[(SIZE)+4]; void *_tp = _tb + sizeof (unsigned long); \
       *(unsigned long *)_tb = (SIZE);
#define _THUNK_C_CHAR(ARG)     _THUNK_C_SHORT (ARG)
#define _THUNK_C_SHORT(ARG)    (*((unsigned short *)_tp)++ = (ARG))
#define _THUNK_C_LONG(ARG)     (*((unsigned long *)_tp)++ = (ARG))
#define _THUNK_C_FLAT(ARG)     _THUNK_C_LONG (_emx_32to16 (ARG))
#define _THUNK_C_FAR16(ARG)    _THUNK_C_LONG (ARG)
#define _THUNK_C_FUNCTION(FUN) _16__##FUN
#define _THUNK_C_CALL(FUN)     _emx_thunk1 (_tb, (void *)(_16__##FUN)); })
#define _THUNK_C_CALLI(FUN)    _emx_thunk1 (_tb, (void *)(FUN)); })

#define _THUNK_PROLOG(SIZE)  _THUNK_PASCAL_PROLOG (SIZE)
#define _THUNK_CHAR(ARG)     _THUNK_PASCAL_CHAR (ARG)
#define _THUNK_SHORT(ARG)    _THUNK_PASCAL_SHORT (ARG)
#define _THUNK_LONG(ARG)     _THUNK_PASCAL_LONG (ARG)
#define _THUNK_FLAT(ARG)     _THUNK_PASCAL_FLAT (ARG)
#define _THUNK_FAR16(ARG)    _THUNK_PASCAL_FAR16 (ARG)
#define _THUNK_FUNCTION(FUN) _THUNK_PASCAL_FUNCTION (FUN)
#define _THUNK_CALL(FUN)     _THUNK_PASCAL_CALL (FUN)
#define _THUNK_CALLI(FUN)    _THUNK_PASCAL_CALLI (FUN)

#define MAKE16P(sel,off)   ((_far16ptr)((sel) << 16 | (off)))
#define MAKEP(sel,off)     _emx_16to32 (MAKE16P (sel, off))
#define SELECTOROF(farptr) ((SEL)((farptr) >> 16))
#define OFFSETOF(farptr)   ((USHORT)(farptr))

/* Return true iff the block of SIZE bytes at PTR does not cross a
   64Kbyte boundary. */

#define _THUNK_PTR_SIZE_OK(ptr,size) \
  (((ULONG)(ptr) & ~0xffff) == (((ULONG)(ptr) + (size) - 1) & ~0xffff))

/* Return true iff the structure pointed to by PTR does not cross a
   64KByte boundary. */

#define _THUNK_PTR_STRUCT_OK(ptr) _THUNK_PTR_SIZE_OK ((ptr), sizeof (*(ptr)))

#endif /* not _OS2THUNK_H */



void main (void)
{
    VIOPHYSBUF viopbBuf;
    PCH pchScreen;
    USHORT usStatus;
    int i;

    viopbBuf.pBuf = MONOBUF;
    viopbBuf.cb = BYTE_SIZE;

    /* Lock the video buffer so bad things don't happen. */
    VioScrLock(LOCKIO_NOWAIT, (PBYTE) &usStatus, 0);

    if (usStatus != LOCK_SUCCESS) {
        printf ("ERROR: Somebody else has the video buffer.\n");
	exit(0);
        //DosExit (EXIT_PROCESS, usStatus);
    }

    /* Grab the video buffer. */
    usStatus = VioGetPhysBuf(&viopbBuf, 0);
    if (usStatus) {
        printf ("VioGetPhysBuf failed returncode %d.\n",usStatus);
	exit(0);
        //DosExit (EXIT_PROCESS, usStatus);
    }

    /* Make a 32 bit pointer from a segment selector. */
    pchScreen = MAKEP(viopbBuf.asel[0], 0);

    /* Loop through memory writing spaces. Jump over attribute byte.*/
    for (i=0; i < BYTE_SIZE; i+=2)
        pchScreen[i] = ' ';

    /* We're done, so we can unlock the video buffer. */
    VioScrUnLock(0);
}

USHORT _16_Vio16ScrLock     ();
USHORT _THUNK_FUNCTION (Vio16GetPhysBuf) ();
USHORT _THUNK_FUNCTION (Vio16ScrUnLock) ();


USHORT VioScrLock (USHORT fWait, PUCHAR pfNotLocked, HVIO hvio)
{
  return ((USHORT)
          (_THUNK_PROLOG (2+4+2);
           _THUNK_SHORT (fWait);
           _THUNK_FLAT (pfNotLocked);
           _THUNK_SHORT (hvio);
           _THUNK_CALL (Vio16ScrLock)));
}


USHORT VioGetPhysBuf (PVIOPHYSBUF pvioPhysBuf, USHORT usReserved)
{
  return ((USHORT)
          (_THUNK_PROLOG (4+2);
           _THUNK_FLAT (pvioPhysBuf);
           _THUNK_SHORT (usReserved);
           _THUNK_CALL (Vio16GetPhysBuf)));
}


USHORT VioScrUnLock (HVIO hvio)
{
  return ((USHORT)
          (_THUNK_PROLOG (2);
           _THUNK_SHORT (hvio);
           _THUNK_CALL (Vio16ScrUnLock)));
}
