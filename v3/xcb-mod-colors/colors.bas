REM ******************************************************************************************************
REM *    colors.bas   XC=BASIC Module V3.X 
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Jan-Feb 2022   
REM ******************************************************************************************************

SHARED CONST clrBLACK = 0
SHARED CONST clrWHITE = 1
SHARED CONST clrRED = 2
SHARED CONST clrYELLOW = 7
SHARED CONST clrCYAN = 3
SHARED CONST clrPURPLE  = 4
SHARED CONST clrGREEN = 5
SHARED CONST clrBLUE = 6
SHARED CONST clrORANGE= 8
SHARED CONST clrBROWN = 9
SHARED CONST clrLIGHT_RED= 10
SHARED CONST clrDARK_GREY = 11
SHARED CONST clrGREY = 12
SHARED CONST clrLIGHT_GREEN= 13
SHARED CONST clrLIGHT_BLUE = 14
SHARED CONST clrLIGHT_GREY = 15

'CONST clrBLACK = 0
'CONST clrWHITE = 1
'CONST clrRED = 2
'CONST clrYELLOW = 7
'CONST clrCYAN = 3
'CONST clrPURPLE  = 4
'CONST clrGREEN = 5
'CONST clrBLUE = 6
'CONST clrORANGE= 8
'CONST clrBROWN = 9
'CONST clrLIGHT_RED= 10
'CONST clrDARK_GREY = 11
'CONST clrGREY = 12
'CONST clrLIGHT_GREEN= 13
'CONST clrLIGHT_BLUE = 14
'CONST clrLIGHT_GREY = 15

DECLARE FUNCTION clrGetPETCodeString AS STRING * 16(clrCode AS BYTE) STATIC SHARED

REM --- Needs to be a SELECT CASE -- Coming in V3.1
FUNCTION clrGetPETCodeString AS STRING * 16(clrCode AS BYTE) STATIC SHARED
	IF clrCode = clrBLACK            THEN RETURN "{BLACK}"
	IF clrCode = clrWHITE           THEN RETURN "{WHITE}"
	IF clrCode = clrCYAN              THEN RETURN "{CYAN}"
	IF clrCode = clrBLUE               THEN RETURN "{BLUE}"
	IF clrCode = clrRED                  THEN RETURN "{RED}"
	IF clrCode = clrYELLOW          THEN RETURN "{YELLOW}"
	IF clrCode = clrGREY               THEN RETURN "{GREY}"
	IF clrCode = clrPURPLE           THEN RETURN "{PURPLE}"
	IF clrCode = clrGREEN            THEN RETURN "{GREEN}"
	IF clrCode = clrORANGE          THEN RETURN "{ORANGE}"
	IF clrCode = clrBROWN           THEN RETURN "{BROWN}"
	IF clrCode = clrLIGHT_RED     THEN RETURN "{LIGHT_RED}"
	IF clrCode = clrDARK_GREY     THEN RETURN "{DARK_GRAY}"
	IF clrCode = clrLIGHT_GREEN THEN RETURN "{LIGHT_GREEN}"
	IF clrCode = clrLIGHT_BLUE    THEN RETURN "{LIGHT_BLUE}"
	IF clrCode = clrLIGHT_GREY    THEN RETURN "{LIGHT_GREY}"
	REM -- if you made it this far something is wrong
	ERROR 14
END FUNCTION

