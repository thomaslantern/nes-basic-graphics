# nes-basic-graphics
Basic graphics for NES using VASM compiler

<h1>still UNDER CONSTRUCTION</h1>

This is a pretty basic program for making graphics on the NES (Nintendo Entertainment System). It is a simple, static screen, which contains both background tiles and "foreground tiles" AKA sprites.
<h2>Note:</h2>
This program/tutorial is a continuation of my "Hello World" NES program, which I strongly recommend you check out first (especially if you have any trouble with this program). The link is here:
https://github.com/thomaslantern/nes-hello-world

<h1> How to Compile "basicgfx.asm" </h1>
If you're looking to compile the code, you'll need to use the VASM compiler. You can get it here: http://www.compilers.de/vasm.html . It's a great compiler that can be used for a variety of systems, and it was made by Dr. Volker Barthelmann. Check it out! To compile simply use: <code>vasm6502_oldstyle.exe DIR/basicgfx.asm -chklabels -nocase -Fbin -o "DIR2/basicgfx.nes"</code> where DIR and DIR2 are the paths/directories for the source file and target file, respectively. (If you have the win32 version of vasm, you may need to use vasm_oldstyle_win32.exe instead).

<h1>How to Run "basicgfx.asm"</h1>
Assuming you've successfully followed the steps to compile above, you should now have an .nes file, "basicgfx.nes". This file can be run in any NES (Nintendo Entertainment System) emulator. I tend to use Nestopia, but other NES developers really seem to enjoy FCEUX, so use whichever emulator you like to run it!

<h1>How to Use (and Learn From) "basicgfx.asm"</h1>
While it's maybe not the most exciting program (whoever heard of a game that's just a static screen?), there's lots to be learned from this program! In particular, aside from learning how to put graphics on the screen of an NES game, you can modify the tiles yourself and make your own graphics! The "0"s and "1"s you see at the end of the code (in the "chr_rom_start" section near the end) are all the tiles - try changing some of the zeroes and ones around and see what happens!

	<table id="vram">
		<tr>
			<td>$0000-$0FFF</td>
			<td>Pattern Table 0</td>
		</tr>
		<tr>
			<td>$1000-$1FFF</td>
			<td>Pattern Table 1</td>
		</tr>
		<tr>
			<td>$2000-$23BF</td>
			<td>NameTable 0 (32x30)</td>
		</tr>
		<tr>
			<td>$23C0-$23FF</td>
			<td>Attribute Table 0</td>
		</tr>
		<tr>
			<td>$2400-$27BF</td>
			<td>NameTable 1 (32x30)</td>
		</tr>
		<tr>
			<td>$27C0-$27FF</td>
			<td>Attribute Table 1</td>
		</tr>
		<tr>
			<td>$2800-$2BBF</td>
			<td>NameTable 2 (32x30) (Extra Ram Only)</td>
		</tr>
		<tr>
			<td>$2BC0-$2BFF</td>
			<td>Attribute Table 2 (Extra Ram Only)</td>
		</tr>
		<tr>
			<td>$2C00-$2FBF</td>
			<td>NameTable 3 (32x30) (Extra Ram Only)</td>
		</tr>
		<tr>
			<td>$2FC0-$2FFF</td>
			<td>Attribute Table 3 (Extra Ram Only)</td>
		</tr>
		<tr>
			<td>$3000-$3EFF</td>
			<td>Copy of $2000-$2FFF</td>
		</tr>
		<tr>
			<td>$3F00-$3F1F</td>
			<td>Palette Definitions</td>
		</tr>
		<tr>
			<td>$3F20-$3FFF</td>
			<td>Copies of $3F00-$3F1F</td>
		</tr>
	</table>

