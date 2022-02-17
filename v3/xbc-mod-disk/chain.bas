REM ******************************************************************************************************
REM *    chain.bas   XC=BASIC Module V3.X 
REM *
REM *	 Allows an XC=BASIC program TO LOAD another XC=BASIC program
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Feb 2022   
REM ******************************************************************************************************

'include "strings.bas"
DECLARE SUB diskChain(pProgram AS STRING * 32, pDescription AS STRING * 36, pDriveNum AS BYTE, pHideSystemLoadingText AS BYTE) STATIC SHARED


CONST TRUE  = 255 : CONST FALSE = 0
'CALL diskChain("menu","** loading my program **",9,TRUE)

REM --> code will never get here as the method will end the program
end

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
	PRINT"load " + CHR$(34) + "0:" + pProgram + CHR$(34) + "," +  STR$(pDriveNum) + "{up}{up}" ;
    
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

