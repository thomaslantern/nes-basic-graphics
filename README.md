# nes-basic-graphics
Basic graphics for NES using VASM compiler

This is a pretty basic program for making graphics on the NES (Nintendo Entertainment System). It is a simple, static screen, which contains both background tiles and "foreground tiles" AKA sprites.
<h2>Note:</h2>
This program/tutorial is a continuation of my "Hello World" NES program, which I <em>strongly</em> recommend you check out first (especially if you have any trouble with this program). The link is here:
https://github.com/thomaslantern/nes-hello-world

<h1> How to Compile "basicgfx.asm" </h1>
If you're looking to compile the code, you'll need to use the VASM compiler. You can get it here: http://www.compilers.de/vasm.html . It's a great compiler that can be used for a variety of systems, and it was made by Dr. Volker Barthelmann. To compile simply use: 
<pre><code>vasm6502_oldstyle.exe DIR/basicgfx.asm -chklabels -nocase -Fbin -o "DIR2/basicgfx.nes"</code></pre> 
where DIR and DIR2 are the paths/directories for the source file and target file, respectively. (If you have the win32 version of vasm, you may need to use vasm_oldstyle_win32.exe instead).

<h1>How to Run "basicgfx.asm"</h1>
Assuming you've successfully followed the steps to compile above, you should now have an .nes file, "basicgfx.nes". This file can be run in any NES (Nintendo Entertainment System) emulator. I tend to use Nestopia, but other NES developers really seem to enjoy FCEUX, so use whichever emulator you like!

<h1>How to Use (and Learn From) "basicgfx.asm"</h1>
While it's not the most exciting program (whoever heard of a game that's just a static screen?), there's lots to be learned from this program! In particular, aside from learning how to put graphics on the screen of an NES game, you can modify the tiles yourself and make your own graphics. 
<p> To do this, look at the graphics (all the 0's and 1's at the end of the .asm file). It's the section that looks a bit like this:
<pre><code>
db %00000000  ; Letter I
db %11111111
db %00011000
db %00011000
db %00011000
db %00011000
db %00011000
db %01111110

db %00000000  ; Bitplane 2
db %11111111
db %00011000
db %00011000
db %00011000
db %00011000
db %00011000
db %11111111
</code></pre>
</p>

The "0"s and "1"s you see at the end of the code (in the "chr_rom_start" section near the end) are all the tiles - try changing some of the zeroes and ones around and see what happens!
<h2>Learn More About Graphics on the NES</h2>
Let's learn a little about how the NES actually uses graphics. First we'll start by learning about a few important memory addresses that we use for all of our graphics programming:
<ul>
  <li><strong>$2002</strong>: This is PPU Status address. You want to load this (e.g. LDA $2002) every time you're about to load in some new addresses for graphics (using LDA on this address resets the address "latch" so you can set it for wherever you're placing graphics - this will make more sense in a moment)</li>
  <li><strong>$2006</strong>: This is where we assign an address to put some data. It's a 16-bit address, so we have to load it in one byte at a time, starting with the high byte. This is called "big-endian" - most parts of NES programming require "little endian", which is when you load in the lower byte first! For example, with the 16-bit address $1234, if you are using "little endian", you first load in $34, then $12 (big endian would load in the way you would expect).</li>
  <li><strong>$2007</strong>: This is the address where we actually load in data, which will then go wherever the address we loaded in $2006 tells it to go</li>
  <li><strong>$2005</strong>: Yes, I know I didn't put these in numerical order. This is what we use at the end of, say, loading in background tiles, because this is for the background scroll. If you don't load 0 into this (twice, once for X, once for Y) after loading in graphics, your screen may scroll (this is due to $2005 sharing a register with $2006)</li>
</ul>
<h2>Background Graphics Sample Template</h2>
<p> To set up your background graphics, you might do something like this:
<pre><code>
  lda $2002    ; Reset address latch
  lda $20      ; Load high byte of background address
  sta $2006    ; Store $20 as high byte
  lda $09      ; Load low byte of background address
  sta $2006    ; Store $09 as low byte (so we're doing graphics at $2009
  ldx #0       ; load 0 into x (our loop counter)
loop:
  lda bkgd_table,x      ; Load the xth byte from our bkgd_table
  sta $2007             ; Store this byte in $2007 to put data at tile address $2009
  inx                   ; Increase our counter 1
  cpx #20               ; We're putting 20 tiles down, so stop at x == 20
  bne loop              ; Keep looping if branch is not equal to zero (ie. x isn't 20)
</code>
</pre>

A little bit confusing but basically, _cpx #20_ and _bne loop_ combined means something like, "Subtract 20 from x, if the result is zero, exit the loop, otherwise keep looping."
</ul></p>

<h2>Look Up Tables (LATs) and Graphics</h2>
Generally speaking, a lot of what we do with graphics involves <em>look up tables</em>, which I tend to place after my game loop, but before my footer and tile code. Look up tables allow you to efficiently set up your background and initial sprite positions, as well as allowing you to store values that might be too costly to calculate (sine values, etc). In the case of graphics, their use is fairly straightforward: you create a loop to place your data on the screen (similar to the one above), and repeat the process, creating as many loops as you need until your screen is appropriately populated with the graphics you want. Awesome!

<h2>What now?</h2>
If you've managed to understand what's going on with this code, great job! It's a little tough at first, but your persistence paid off. If you're still struggling, don't worry - join the club! While studying ASM6502/NES programming has continued to help me level up my skills, I still find it a challenge from time to time, so it's perfectly natural to run into a brick wall now and again. Just keep working at it, and before you know it, it'll make more sense to you!
<h3>Keep going!</h3>
I have other "tutorials" on NES programming on my github:
<ul>
  <li>https://github.com/thomaslantern/nes-hello-world</li>
  <li>https://github.com/thomaslantern/nes-basic-sound</li>
  <li>https://github.com/thomaslantern/nes-basic-controls</li>
  <li>https://github.com/thomaslantern/nes-birthday-blast</li>
</ul>
