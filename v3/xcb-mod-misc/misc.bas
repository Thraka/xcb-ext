REM ******************************************************************************************************
REM *   misc.bas   XC=BASIC Module V3.X 
REM *
REM *   Misc routines - cut and paste in your program!
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Jan-Feb 2022   
REM *
REM *   added isNumeric and isAlpha methods                                     Apr-11-2022   JakeBullet
REM *   added IFF method                                                        Apr-17-2022   JakeBullet
REM ******************************************************************************************************

CONST TRUE  = 255
CONST FALSE = 0

DECLARE SUB Pause (pSeconds2Sleep AS FLOAT, pPALtiming AS BYTE) STATIC SHARED
DECLARE FUNCTION isNumeric AS BYTE (pStr AS STRING * 1) STATIC SHARED
DECLARE FUNCTION isAlpha AS BYTE (pStr AS STRING * 1) STATIC SHARED
DECLARE FUNCTION IIF AS STRING * 96 (pEvalVar AS BYTE, pRetValTrue AS STRING * 96, pRetValFalse AS STRING * 96) STATIC SHARED

'CALL pause(0.5,true)
'end

FUNCTION IIF AS STRING * 96 (pEvalVar AS BYTE, pRetValTrue AS STRING * 96, pRetValFalse AS STRING * 96) STATIC SHARED
	IF pEvalVar = FALSE THEN RETURN pRetValFalse
	RETURN pRetValTrue
END FUNCTION


FUNCTION isNumeric AS BYTE (pStr AS STRING * 1) STATIC SHARED
	RETURN (ASC (pStr) > 47 AND ASC (pStr) < 58)
END FUNCTION

FUNCTION isAlpha AS BYTE (pStr AS STRING * 1) STATIC SHARED
	RETURN (ASC (pStr) > 64 AND ASC (pStr) < 91)
END FUNCTION

SUB Pause (pSeconds2Sleep AS FLOAT, pPALtiming AS BYTE) STATIC SHARED
	CONST VICII_RASTER = $d012
	DIM numOfSec AS WORD
	
	IF pPALtiming = TRUE THEN 
		numOfSec = CWORD(ABS(CFLOAT(50) * pSeconds2Sleep))
	ELSE
		numOfSec = CWORD(ABS(CFLOAT(60) * pSeconds2Sleep))
	END IF
	
	FOR ii AS WORD = 0 to numOfSec
		REM --> watch the raster line
		DO : LOOP UNTIL PEEK(VICII_RASTER) = 255
	NEXT
END SUB


