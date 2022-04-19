REM ******************************************************************************************************
REM *    screen.bas   XC=BASIC Module V3.X 
REM *
REM *   Misc screen subs and functions
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Jan-Feb 2022   
REM ******************************************************************************************************
'Include "strings.bas"

CONST TRUE  = 255 : CONST FALSE = 0
DECLARE FUNCTION scrnReadKey AS BYTE () SHARED STATIC 
DECLARE SUB scrnDebugTextTop (txt AS STRING * 40) SHARED STATIC 
DECLARE SUB scrnDebugTextBtm (txt AS STRING * 40) SHARED STATIC 
DECLARE SUB scrnTextAtWithHilight (xCol AS BYTE, xRow AS BYTE, txt AS STRING * 40, txtColor AS BYTE, txtHilightColor AS BYTE, char2Hilight as string * 1) SHARED STATIC
DECLARE SUB scrnPRINTAT (xCol AS BYTE, xRow AS BYTE, xText AS STRING * 40) SHARED STATIC
DECLARE SUB scrnPRINTAT (xCol AS BYTE, xRow AS BYTE, xText AS STRING * 40, xColor AS BYTE) SHARED STATIC  OVERLOAD

DECLARE SUB scrnMsgBoxOk(xTextLine1 AS STRING * 30,xTextLine2 AS STRING * 30,xColorBox AS BYTE, xColorText AS BYTE) SHARED STATIC
DECLARE SUB scrnBusyMsgBox(pStr AS STRING * 30) SHARED STATIC

DIM junkVar AS BYTE

'=========================================================================================================  
DIM lastDebugMessageLen AS BYTE : lastDebugMessageLen = 1

SUB scrnBusyMsgBox(pStr AS STRING * 30) SHARED STATIC
	CALL boxDraw(3,10,32,4,gColors.box, TRUE)
	TEXTAT 5,12, strCenterString(pStr ,30),gColors.txtNormal
END SUB


SUB scrnMsgBoxOk(xTextLine1 AS STRING * 30,xTextLine2 AS STRING * 30,xColorBox AS BYTE, xColorText AS BYTE) SHARED STATIC
	CALL screenSave()
	
	junkVar = 0 
	IF LEN(xTextLine2) > 0 THEN junkVar = 1 
	
	CALL boxDraw(3,10,32,6 + junkVar,xColorBox, TRUE)
		
	TEXTAT 5,12, strCenterString(xTextLine1 ,30),xColorText
	IF junkVar = 1 THEN
		TEXTAT 5,13, strCenterString(xTextLine2,30),xColorText
	END IF
	TEXTAT 5,15 + junkVar, strCenterString("< press any key to continue >",30),xColorText

	junkVar = scrnReadKey()
	CALL screenRestore()
END SUB


FUNCTION scrnReadKey AS BYTE () SHARED STATIC 
	DIM tmp AS BYTE
	DO
		GET tmp
	LOOP UNTIL tmp > 0
	RETURN tmp
END FUNCTION

'--- Same as TEXTAT except respects PET codes
SUB scrnPRINTAT (xCol AS BYTE, xRow AS BYTE, xText AS STRING * 40) SHARED STATIC
  LOCATE xCol, xRow : PRINT xText ;
END SUB

'--- Same as TEXTAT except respects PET codes
SUB scrnPRINTAT (xCol AS BYTE, xRow AS BYTE, xText AS STRING * 40, xColor AS BYTE) SHARED STATIC  OVERLOAD
	'DIM tmp1 AS BYTE
	'tmp1 = PEEK(646) : REM -->  save old color
	'POKE 646,xColor : REM --- C64 only?
	LOCATE xCol, xRow :  PRINT xText ;
	'POKE 646,tmp1 : REM --- C64 only?
END SUB

'--- Print a string at x, y location and hilights a letter
SUB scrnTextAtWithHilight (xCol AS BYTE, xRow AS BYTE, txt AS STRING * 40, txtColor AS BYTE, txtHilightColor AS BYTE, char2Hilight as string * 1) SHARED STATIC
	DIM tmp1 AS BYTE
	TEXTAT xCol, xRow, txt, txtColor
	tmp1 = strInstr(txt,char2Hilight)
	IF tmp1 = 0 THEN RETURN
	TEXTAT xCol + tmp1 - 1, xRow, char2Hilight, txtHilightColor
END SUB

SUB scrnDebugTextTop (txt AS STRING * 39) SHARED STATIC 
	CALL scrnPRINTAT(0,0,strSPC(lastDebugMessageLen)) : REM --> clear old msg if any
	CALL scrnPRINTAT(0,0,"dbg: " + txt )
	lastDebugMessageLen = LEN(txt) + 5
END SUB
SUB scrnDebugTextBtm (txt as string * 39) SHARED STATIC 
	CALL scrnPRINTAT(0,24,strSPC(lastDebugMessageLen)) : REM --> clear old msg if any
	CALL scrnPRINTAT(0,24,"dbg: " + txt )
	lastDebugMessageLen = LEN(txt) + 5
END SUB



