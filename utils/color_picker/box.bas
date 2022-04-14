REM ******************************************************************************************************
REM *    box.bas   XC=BASIC Module V3.X 
REM *
REM *
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Jan-Feb 2022   
REM ******************************************************************************************************
'Include "strings.bas"
'Include "colors.bas"

CONST TRUE  = 255 : CONST FALSE = 0

REM --> box char's
CONST hzCharUC = 67 : CONST vtCharUC  = 66 : CONST tlCharUC = 85 :  CONST trCharUC  = 73 : CONST blCharUC = 74  : CONST brCharUC  = 75
CONST hzCharLC = 64 :  CONST vtCharLC  = 93 : CONST tlCharLC = 112 :  CONST trCharLC  = 110 : CONST blCharLC = 109 : CONST brCharLC  = 125
DIM hzChar AS BYTE  :  DIM vtChar AS  BYTE  : DIM tlChar AS  BYTE   : DIM trChar AS  BYTE    : DIM blChar AS  BYTE   : DIM brChar AS  BYTE 
DIM tmp AS BYTE 

CONST SCREENRAM = $0400 : CONST COLORRAM = $d800
DIM SCREENBUFFER(1000) AS BYTE  
DIM COLORBUFFER(1000) AS BYTE

DECLARE SUB boxDraw(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE) STATIC
DECLARE SUB boxDraw(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE, xClear AS BYTE) STATIC OVERLOAD SHARED
DECLARE SUB boxDraw(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE, xClear AS BYTE, xTitle AS STRING * 38) STATIC OVERLOAD SHARED
DECLARE SUB boxDraw3d(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE, xColor3d AS BYTE) STATIC
DECLARE SUB boxDraw3d(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE, xColor3d AS BYTE, xClear AS BYTE) STATIC OVERLOAD SHARED
DECLARE SUB boxDraw3d(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE, xColor3d AS BYTE, xClear AS BYTE, xTitle AS STRING * 38) STATIC OVERLOAD SHARED

DECLARE SUB screenSave() STATIC SHARED
DECLARE SUB screenRestore() STATIC SHARED
DECLARE SUB boxInit() STATIC SHARED : REM --> call 1st

SUB screenSave() STATIC SHARED
	REM --> saves the whole screen - 2k, ouch! - need something better
	MEMCPY SCREENRAM, @SCREENBUFFER, 1000
	MEMCPY COLORRAM, @COLORBUFFER, 1000
END SUB

SUB screenRestore() STATIC SHARED
	MEMCPY @SCREENBUFFER, SCREENRAM,  1000
	MEMCPY @COLORBUFFER, COLORRAM,  1000
END SUB

SUB boxInit() STATIC SHARED
	CONST UPPERCASE = 21
	IF PEEK(53272) = UPPERCASE THEN
		hzChar = hzCharUC : vtChar = vtCharUC   
		tlChar = tlCharUC : trChar = trCharUC 
		blChar = blCharUC : brChar = brCharUC 		
	ELSE : REM --> lower case
		hzChar = hzCharLC : vtChar = vtCharLC   
		tlChar = tlCharLC : trChar =  trCharLC 
		blChar = blCharLC : brChar = brCharLC
	END IF
END SUB

SUB boxDraw3d(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE, xColor3d AS BYTE, xClear AS BYTE) STATIC OVERLOAD SHARED
	CALL boxDraw(xLeft, xTop, xWidth, xHeight, xColor, xClear)
	CALL boxDraw3d(xLeft, xTop , xWidth, xHeight, xColor,xColor3d)
END SUB
SUB boxDraw3d(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE, xColor3d AS BYTE, xClear AS BYTE, xTitle AS STRING * 38) STATIC OVERLOAD SHARED
	CALL boxDraw(xLeft, xTop, xWidth, xHeight, xColor, xClear, xTitle)
	CALL boxDraw3d(xLeft, xTop , xWidth, xHeight, xColor,xColor3d)
END SUB
SUB boxDraw3d(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE, xColor3d AS BYTE) STATIC
	REM --> draw over the existing chars with new color
	REM --> draw horizonal lines
	FOR tmp = 0 to xWidth
		CHARAT tmp + xLeft, xTop + xHeight,hzChar,xColor3d 
	NEXT
	REM --- draw vertical lines
	FOR tmp AS BYTE  = xTop to xHeight + xTop	
		CHARAT xLeft + xWidth, tmp,vtChar,xColor3d 
	NEXT
	REM --- draw the 4 corners
	CHARAT xLeft + xWidth, xTop,trChar,xColor : REM -- top right
	CHARAT xLeft, xTop + xHeight,blChar,xColor3d  : REM -- bottom left
	CHARAT xLeft + xWidth, xTop + xHeight,brChar,xColor3d : REM -- bottom right
END SUB

SUB boxDraw(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE, xClear AS BYTE, xTitle  AS STRING * 38) STATIC OVERLOAD SHARED
	CALL boxDraw(xLeft, xTop, xWidth, xHeight, xColor, xClear)
	REM --> redraw header
	CHARAT xLeft, xTop, tlChar, xColor  : REM -- top left
	LOCATE  xLeft + 1,xTop
	PRINT "{REV_ON}" +  clrGetPETCodeString(xColor) + strCenterString(xTitle,xWidth) + "{REV_OFF}" ;
	CHARAT xLeft + xWidth, xTop, trChar, xColor : REM -- top right
END SUB	

SUB boxDraw(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE, xClear AS BYTE) STATIC OVERLOAD SHARED
	CALL boxDraw(xLeft, xTop, xWidth, xHeight, xColor)
	IF xClear = TRUE THEN
		FOR tmp = 1 TO xHeight - 1 
			TEXTAT xLeft + 1, xTop  + tmp, strSPC(xWidth - 1)
		NEXT 
	END IF
END SUB

SUB boxDraw(xLeft AS BYTE, xTop AS BYTE, xWidth AS BYTE, xHeight AS BYTE, xColor AS BYTE) STATIC
	REM --> draw horizonal lines
	FOR tmp = 0 to xWidth
		CHARAT tmp + xLeft, xTop,hzChar,xColor 
		CHARAT tmp + xLeft, xTop + xHeight,hzChar,xColor 
	NEXT
	REM --- draw vertical lines
	FOR tmp = xTop to xHeight + xTop	
		CHARAT xLeft, tmp,vtChar,xColor 
		CHARAT xLeft + xWidth, tmp,vtChar,xColor 
	NEXT
	REM --- draw the 4 corners
	CHARAT xLeft, xTop,tlChar,xColor  : REM -- top left
	CHARAT xLeft + xWidth, xTop,trChar,xColor : REM -- top right
	CHARAT xLeft, xTop + xHeight,blChar,xColor  : REM -- bottom left
	CHARAT xLeft + xWidth, xTop + xHeight,brChar,xColor : REM -- bottom right
END SUB

