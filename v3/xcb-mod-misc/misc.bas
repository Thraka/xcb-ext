REM ******************************************************************************************************
REM *   misc.bas   XC=BASIC Module V3.X 
REM *
REM *   Misc routines - cut and paste in your program!
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Jan-Feb 2022   
REM ******************************************************************************************************

CONST TRUE  = 255
CONST FALSE = 0

DECLARE SUB Pause (pSeconds2Sleep AS FLOAT, pPALtiming AS BYTE) STATIC SHARED


'CALL pause(0.5,true)
'end


SUB Pause (pSeconds2Sleep AS FLOAT, pPALtiming AS BYTE) STATIC SHARED
	CONST VICII_RASTER = $d012
	DIM numOfSec AS WORD
	
	IF pPALtiming = TRUE THEN 
		numOfSec = ABS(CFLOAT(50) * pSeconds2Sleep)
	ELSE
		numOfSec = ABS(CFLOAT(60) * pSeconds2Sleep)
	END IF
	
	FOR ii AS WORD = 0 to numOfSec
		REM --> watch the raster line
		DO : LOOP UNTIL PEEK(VICII_RASTER) = 255
	NEXT
END SUB


