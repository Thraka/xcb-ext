REM ******************************************************************************************************
REM *   misc.bas   ----- MISC CODE 
REM ******************************************************************************************************

CONST TRUE  = 255
CONST FALSE = 0

'---   call debugOutVice( " " + str$( ) )
'---   call debugOutVice( " "  )
SUB debugOutVice(pStr AS STRING * 90) STATIC SHARED
	OPEN 4,4
	PRINT #4, pStr
	PRINT #4 ,"";
	CLOSE 4
END SUB


DECLARE SUB Pause (pSeconds2Sleep AS FLOAT, pPALtiming AS BYTE) STATIC SHARED
DECLARE FUNCTION isNumeric AS BYTE (pStr AS STRING * 1) STATIC SHARED
DECLARE FUNCTION isAlpha AS BYTE (pStr AS STRING * 1) STATIC SHARED

'CALL pause(0.5,true)
'end

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

'=======================================================================================

DECLARE SUB diskChain(pProgram AS STRING * 32, pDescription AS STRING * 36, pDriveNum AS BYTE, pHideSystemLoadingText AS BYTE) STATIC SHARED

SUB diskChain(pProgram AS STRING * 32, pDescription AS STRING * 36, pDriveNum AS BYTE,  pHideSystemLoadingText AS BYTE) STATIC SHARED

    CONST KB_BUFFER_NUM_CHARS = 198
    CONST KB_BUFFER = 631
    CONST KEY_ENTER = 13    
    CONST SET_SCREEN_TEXT_COLOR = 646    
    CONST CURRENT_SCREEN_TEXT_COLOR = 53281 

	PRINT "{clr}{down}{down}"
	TEXTAT 0,1, strCenterString(pDescription,39)
    
    IF pHideSystemLoadingText THEN
        REM --> this will change the text color to the screens background color (so no text is seen)
        REM --> the program that is called MUST set its own color scheme as NO text will be visible!
        POKE SET_SCREEN_TEXT_COLOR, PEEK(CURRENT_SCREEN_TEXT_COLOR)
    END IF
    
	PRINT " "
	PRINT "load " + CHR$(34) + "0:" + pProgram + CHR$(34) + "," +  STR$(pDriveNum) + "{up}{up}" ;
    
    REM --> Put some charactors in the keyboard buffer, these survive the call to end this program and will excecute. 
	POKE KB_BUFFER , KEY_ENTER
	POKE KB_BUFFER + 1, ASC("r")
	POKE KB_BUFFER + 2, ASC("u")
	POKE KB_BUFFER + 3, ASC("n")
	POKE KB_BUFFER + 4, KEY_ENTER
    
    REM --> flush the keyboard
	POKE KB_BUFFER_NUM_CHARS,5
    
    REM --> end this program. The new program will load and runs
	END
END SUB




