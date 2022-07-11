REM MONITEST.BAS, a CRT monitor alignment tool.


REM Enter the machine code subroutine for colour control...
POKE 156 65500
POKE 80 65501
POKE 83 65502
POKE 81 65503
POKE 184 65504
POKE 32 65505
POKE 9 65506
POKE 183 65507
POKE 0 65508
POKE 179 65509
POKE 7 65510
POKE 185 65511
POKE 1 65512
POKE 0 65513
POKE 205 65514
POKE 16 65515
POKE 89 65516
POKE 91 65517
POKE 88 65518
POKE 157 65519
POKE 195 65520


start:
REM Set all variables here.
c = 0
l = 0
k = 27
n = 1


REM Set up the main screen here.
CLS
CURSOR ON
MOVE 16 1
PRINT "Full pattern generator to test CRT type monitors."
MOVE 16 2
PRINT "(C)2022 CrepeOS."
MOVE 30 4
PRINT "X) Centre Cross..."
MOVE 30 5
PRINT "H) Crosshatch....."
MOVE 30 6
PRINT "C) Colour Bars...."
MOVE 30 7
PRINT "G) Grey Scales...."
MOVE 30 8
PRINT "P) Purity........."
MOVE 30 9
PRINT "W) Black To White."
MOVE 30 10
PRINT "F) Focus Dots....."
MOVE 30 11
PRINT "B) Chequerboard..."
MOVE 30 12
PRINT "M) Multiburst....."
MOVE 29 14
PRINT "[U) Pulse_&_Bar....]"
MOVE 29 15
PRINT "[L) Line_&_Block...]"
MOVE 29 16
PRINT "[A) Astigmatism....]"
MOVE 29 17
PRINT "[I) Moire Patterns.]"
MOVE 30 19
PRINT "Esc) To Quit......"
MOVE 27 22
PRINT "Press the required key:- " ;


keyboardhold:
REM This is the holding routine...
GETKEY k
IF k = 88 THEN GOTO centrecross
IF k = 120 THEN GOTO centrecross
IF k = 72 THEN GOTO crosshatch
IF k = 104 THEN GOTO crosshatch
IF k = 67 THEN GOTO colourbar
IF k = 99 THEN GOTO colourbar
IF k = 65 THEN GOTO astigmatism
IF k = 97 THEN GOTO astigmatism
IF k = 71 THEN GOTO greyscale
IF k = 103 THEN GOTO greyscale
IF k = 73 THEN GOTO moire
IF k = 105 THEN GOTO moire
IF k = 76 THEN GOTO lineandblock
IF k = 108 THEN GOTO lineandblock
IF k = 85 THEN GOTO pulseandbar
IF k = 117 THEN GOTO pulseandbar
IF k = 80 THEN GOTO purity
IF k = 112 THEN GOTO purity
IF k = 87 THEN GOTO whitetoblack
IF k = 119 THEN GOTO whitetoblack
IF k = 77 THEN GOTO multiburst
IF k = 109 THEN GOTO multiburst
IF k = 66 THEN GOTO chequerboard
IF k = 98 THEN GOTO chequerboard
IF k = 70 THEN GOTO focus
IF k = 102 THEN GOTO focus
IF k = 27 THEN GOTO cleanexit
GOTO keyboardhold
REM End of keyboardhold loop.


cleanexit:
REM Clean exit to CrepeOS.
CLS
END
REM End of program...


crosshatch:
REM The standard dynamic convergence crosshatch test.
CLS
REM Draw the horizontal lines.
n = 196
l = 0
lines:
FOR c = 1 TO 78
MOVE c l
PRINT CHR n ;
NEXT c
l = l + 3
IF l >= 24 THEN GOTO columnstart
GOTO lines
columnstart:
REM Draw the vertical lines.
n = 179
c = 0
columns:
FOR l = 1 TO 23
MOVE c l
PRINT CHR n ;
NEXT l
c = c + 8
IF c >= 78 THEN GOTO lastcolumn
GOTO columns
lastcolumn:
c = 79
FOR l = 1 TO 23
MOVE c l
PRINT CHR n ;
NEXT l
REM Draw the crossover points.
n = 197
c = 8
l = 3
crosses:
MOVE c l
PRINT CHR n ;
c = c + 8
IF c >= 73 THEN l = l + 3
IF c >= 73 THEN c = 8
IF l >= 22 THEN GOTO corners
GOTO crosses
corners:
REM Draw the corners.
n = 218
MOVE 0 0
PRINT CHR n ;
n = 191
MOVE 79 0
PRINT CHR n ;
n = 192
MOVE 0 24
PRINT CHR n ;
MOVE 79 24
POKE 7 65510
POKE 217 65505
CALL 65500
REM Draw all the `T` pieces to finalise the crosshatch.
n = 194
c = 8
top:
MOVE c 0
PRINT CHR n ;
c = c + 8
IF c >= 78 THEN GOTO bottomstart
GOTO top
bottomstart:
n = 193
c = 8
bottom:
MOVE c 24
PRINT CHR n ;
c = c + 8
IF c >= 78 THEN GOTO leftstart
GOTO bottom
leftstart:
n = 195
l = 3
left:
MOVE 0 l
PRINT CHR n ;
l = l + 3
IF l >= 23 THEN GOTO rightstart
GOTO left
rightstart:
n = 180
l = 3
right:
MOVE 79 l
PRINT CHR n ;
l = l + 3
IF l >= 23 THEN GOTO keyhold
GOTO right
REM End of crosshatch test.


moire:
REM Attempt, (badly), to generate moire patterning using CGA text mode.
REM This will NOT be successful on ALL machines.
CLS
REM Choose character from 176, 177 or 178...
n = 176
MOVE 0 1
FOR c = 0 TO 1839
PRINT CHR n ;
NEXT c
GOTO keyhold
REM Moire patterning end.


chequerboard:
REM Start of chequerboard subroutine.
CLS
REM Print 24 lines of alternate white and black blocks.
n = 219
FOR l = 0 TO 11
FOR c = 0 TO 19
PRINT CHR n ;
PRINT CHR n ;
PRINT "  " ;
NEXT c
FOR c = 0 TO 19
PRINT "  " ;
PRINT CHR n ;
PRINT CHR n ;
NEXT c
NEXT l
REM Print the last line to the last but one pair of blocks.
FOR c = 0 TO 18
PRINT CHR n ;
PRINT CHR n ;
PRINT "  " ;
NEXT c
REM Now print the LAST white block.
PRINT CHR n ;
PRINT CHR n ;
GOTO keyhold
REM End of chequerboard routine.


pulseandbar:
REM The old pulse and bar test mainly for monochrome systems.
CLS
REM Generate left hand side pulse.
n = 179
FOR l = 0 TO 24
MOVE 0 l
PRINT CHR n ;
NEXT l
REM Generate the bar section per line.
n = 219
FOR l = 0 TO 23
FOR c = 40 TO 79
MOVE c l
PRINT CHR n ;
NEXT c
NEXT l
MOVE 40 24
FOR c = 40 TO 78
PRINT CHR n ;
NEXT c
MOVE 79 24
REM Finish the last character without generating a CR/NL.
POKE 7 65510
POKE 219 65505
CALL 65500
GOTO keyhold
REM End of pulse and bar routine.


lineandblock:
REM The old line and block test mainly for monochrome systems.
CLS
REM Generate the top line.
n = 196
FOR c = 0 TO 79
PRINT CHR n ;
NEXT c
REM Generate the half screen block.
MOVE 0 13
n = 219
FOR l = 0 TO 958
PRINT CHR n ;
NEXT l
MOVE 79 24
REM Finish the last character without generating a CR/NL.
POKE 7 65510
POKE 219 65505
CALL 65500
GOTO keyhold
REM End of line and block routine.


multiburst:
REM Frequency response test, multiburst.
CLS
REM For each line printed........
FOR l = 1 TO 23
n = 219
REM Print LF frequency.
MOVE 0 l
FOR c = 1 TO 5
PRINT CHR n ;
PRINT CHR n ;
PRINT "  " ;
NEXT c
REM Print LF * 2 frequency.
MOVE 20 l
FOR c = 1 TO 10
PRINT CHR n ;
PRINT " " ;
NEXT c
REM Print LF * 4 frequency.
n = 221
MOVE 40 l
FOR c = 1 TO 20
PRINT CHR n ;
NEXT c
REM Print HF frequency.
n = 186
MOVE 60 l
FOR c = 1 TO 20
PRINT CHR n ;
NEXT c
REM Next line to be printed.
NEXT l
GOTO keyhold
REM Multiburst subroutine end.


centrecross:
REM Convergence centre cross generator.
REM Set colour to bright white on black.
CLS
POKE 15 65510
REM Do the vertical line first'
POKE 179 65505
MOVE 40 10
CALL 65500
MOVE 40 11
CALL 65500
MOVE 40 13
CALL 65500
MOVE 40 14
CALL 65500
REM Do the horizontal line second.
POKE 196 65505
FOR n = 35 TO 45
MOVE n 12
CALL 65500
NEXT n
REM Do the cross in the middle.
POKE 197 65505
MOVE 40 12
CALL 65500
GOTO keyhold
REM End of centre cross generator.


astigmatism:
REM A B&W test of a single white line across the screen.
CLS
REM Set the character and its start position.
n = 196
MOVE 0 12
REM Print the line white on black.
FOR c = 0 TO 79
PRINT CHR n ;
NEXT c
GOTO keyhold
REM Astigmatism test end.


focus:
REM Focus dot generator.
CLS
FOR c = 1 TO 38
FOR l = 0 TO 24
n = c * 2
MOVE n l
PRINT ". " ;
NEXT l
NEXT c
GOTO keyhold
REM End of focus dot routine.


whitetoblack:
REM The black to white full screen test.
REM Select the levels of full screens of grey
FOR n = 1 TO 4
CLS
IF n = 1 THEN POKE 0 65510
IF n = 2 THEN POKE 8 65510
IF n = 3 THEN POKE 7 65510
IF n = 4 THEN POKE 15 65510
REM The character to be printed.
POKE 219 65505
REM Clear the screen in each grey level.
FOR c = 0 TO 79
FOR l = 0 TO 24
MOVE c l
CALL 65500
NEXT l
NEXT c
MOVE 0 0
CURSOR OFF
whitetoblackkey:
REM Hold each screen.
GETKEY k
IF k = 13 THEN GOTO whitetoblackloop
GOTO whitetoblackkey
whitetoblackloop:
REM Next grey screen.
NEXT n
GOTO start
REM End of grey screen routine.


purity:
REM The three primary colours for purity tests.
REM Select the primary colours one at a time.
FOR n = 1 TO 3
CLS
IF n = 1 THEN POKE 4 65510
IF n = 2 THEN POKE 2 65510
IF n = 3 THEN POKE 1 65510
REM The character to be printed.
POKE 219 65505
REM Clear the screen in each primary colour.
FOR c = 0 TO 79
FOR l = 0 TO 24
MOVE c l
CALL 65500
NEXT l
NEXT c
MOVE 0 0 
CURSOR OFF
puritykey:
REM Hold each screen.
GETKEY k
IF k = 13 THEN GOTO purityloop
GOTO puritykey
purityloop:
REM Next purity screen.
NEXT n
GOTO start
REM End of purity routine...


colourbar:
REM Start of the colour bar generator.
REM Block character to be printed.
CLS
POKE 219 65505
FOR c = 0 TO 79
FOR l = 0 TO 24
REM Position to print a simple series of characters.
MOVE c l
REM This generates the colours for the colour bars.
IF c = 0 THEN POKE 15 65510
IF c = 10 THEN POKE 14 65510
IF c = 20 THEN POKE 3 65510
IF c = 30 THEN POKE 2 65510
IF c = 40 THEN POKE 5 65510
IF c = 50 THEN POKE 4 65510
IF c = 60 THEN POKE 1 65510
IF c = 70 THEN POKE 0 65510
CALL 65500
NEXT l
NEXT c
GOTO keyhold
REM End of colour bar routine...


greyscale:
REM Start of the greyscale generator.
REM Block character to be printed.
CLS
POKE 219 65505
FOR c = 0 TO 79
FOR l = 0 TO 24
REM Print position for the greyscale characters.
MOVE c l
REM This generates the greys for the greyscales.
IF c = 0 THEN POKE 0 65510
IF c = 20 THEN POKE 8 65510
IF c = 40 THEN POKE 7 65510
IF c = 60 THEN POKE 15 65510
CALL 65500
NEXT l
NEXT c
GOTO keyhold
REM End of greyscale routine.

keyhold:
REM Move the cursor to the top left hand corner and turn it off.
MOVE 0 0
CURSOR OFF
keyholdpause:
REM This holds any display using space bar to go to start...
GETKEY k
IF k = 32 THEN GOTO start
GOTO keyholdpause
REM End of keyhold routine.


