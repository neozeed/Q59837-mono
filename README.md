![os2-thunk](https://github.com/neozeed/Q59837-mono/assets/9031439/d9c7aa35-0fc2-47f1-bdf8-076b7ebfef42)

I extracted the EMX calls for 32bit to 16bit thunking so I could make a stand alone program to erase the text buffer, leaning heavily on the Q59837 sample from Microsoft.

This only works in full screen and assumes a VGA card!

You need a GA or release os2386.lib, as the ability to thunk is not in the Pre-Release 2 SDK

`thunk0.obj(thunk0.asm) :  error L2029: 'DosSelToFlat' : unresolved external`

`thunk0.obj(thunk0.asm) :  error L2029: 'DosFlatToSel' : unresolved external`
