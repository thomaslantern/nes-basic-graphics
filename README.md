# nes-basic-graphics
Basic graphics for NES using VASM compiler

<h1>UNDER CONSTRUCTION</h1>

This is a pretty basic program for making graphics on the NES (Nintendo Entertainment System). It is a simple, static screen, which contains both background tiles and "foreground tiles" AKA sprites.
<h1> How to Compile basicgfx.asm </h1>
If you're looking to compile the code, you'll need to use the VASM compiler. You can get it here: http://www.compilers.de/vasm.html . It's a great compiler that can be used for a variety of systems, and it was made by Dr. Volker Barthelmann. Check it out! To compile simply use: <code>vasm6502_oldstyle.exe DIR/basicgfx.asm -chklabels -nocase -Fbin -o "DIR2/basicgfx.nes"</code> where DIR and DIR2 are the paths/directories for the source file and target file, respectively. (If you have the win32 version of vasm, you may need to use vasm_oldstyle_win32.exe instead).

<h1>How to Run the Program</h1>
Assuming you've successfully followed the steps to compile above, you should now have an .nes file, "basicgfx.nes". This file can be run in any NES (Nintendo Entertainment System) emulator. I tend to use Nestopia, but other NES developers really seem to enjoy FCEUX, so use whichever emulator you like to run it!
