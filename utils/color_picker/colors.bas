REM ******************************************************************************************************
REM *    colors.bas   XC=BASIC Module V3.X 
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Jan-Feb 2022   
REM ******************************************************************************************************

SHARED CONST COLOR_BLACK = 0
SHARED CONST COLOR_WHITE = 1
SHARED CONST COLOR_RED = 2
SHARED CONST COLOR_CYAN = 3
SHARED CONST COLOR_PURPLE  = 4
SHARED CONST COLOR_GREEN = 5
SHARED CONST COLOR_BLUE = 6
SHARED CONST COLOR_YELLOW = 7
SHARED CONST COLOR_ORANGE = 8
SHARED CONST COLOR_BROWN = 9
SHARED CONST COLOR_LIGHT_RED = 10
SHARED CONST COLOR_DARK_GRAY = 11
SHARED CONST COLOR_GRAY = 12
SHARED CONST COLOR_LIGHT_GREEN = 13
SHARED CONST COLOR_LIGHT_BLUE = 14
SHARED CONST COLOR_LIGHT_GRAY = 15

DECLARE FUNCTION clrGetPETCodeString AS STRING * 16 (clrCode AS BYTE) STATIC SHARED

REM --- Needs to be a SELECT CASE -- Coming in V3.1
FUNCTION clrGetPETCodeString AS STRING * 16 (clrCode AS BYTE) STATIC SHARED
	IF clrCode = COLOR_BLACK             THEN RETURN "{BLACK}"
	IF clrCode = COLOR_WHITE            THEN RETURN "{WHITE}"
	IF clrCode = COLOR_CYAN               THEN RETURN "{CYAN}"
	IF clrCode = COLOR_BLUE                THEN RETURN "{BLUE}"
	IF clrCode = COLOR_RED                  THEN RETURN "{RED}"
	IF clrCode = COLOR_YELLOW           THEN RETURN "{YELLOW}"
	IF clrCode = COLOR_GRAY                THEN RETURN "{GRAY}"
	IF clrCode = COLOR_PURPLE            THEN RETURN "{PURPLE}"
	IF clrCode = COLOR_GREEN             THEN RETURN "{GREEN}"
	IF clrCode = COLOR_ORANGE           THEN RETURN "{ORANGE}"
	IF clrCode = COLOR_BROWN            THEN RETURN "{BROWN}"
	IF clrCode = COLOR_LIGHT_RED      THEN RETURN "{LIGHT_RED}"
	IF clrCode = COLOR_DARK_GRAY      THEN RETURN "{DARK_GRAY}"
	IF clrCode = COLOR_LIGHT_GREEN THEN RETURN "{LIGHT_GREEN}"
	IF clrCode = COLOR_LIGHT_BLUE    THEN RETURN "{LIGHT_BLUE}"
	IF clrCode = COLOR_LIGHT_GRAY    THEN RETURN "{LIGHT_GRAY}"
	REM -- if you made it this far something is wrong
	TEXTAT 0,24,"Err! clrGetPETCodeString - value:"  + STR$(clrCode)
	ERROR 14
END FUNCTION



