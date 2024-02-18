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
#include <conio.h>

#include <os2thunk.h>

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
