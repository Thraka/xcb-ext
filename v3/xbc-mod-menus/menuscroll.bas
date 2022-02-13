REM ***********************************************************************************************************
REM *    Menuscroll.Bas   XC=BASIC Module  V3.X 
REM *    
REM *	  Simple MENU SCROLLIBLE routine. 
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Jan-Feb 2022        V1.00
REM ***********************************************************************************************************
'Include "strings.bas"
'Include "colors.bas"

CONST TRUE  = 255 : CONST FALSE = 0
CONST keyDOWN = 17
CONST keyUP = 145
CONST keyRETURN = 13

DECLARE SUB PRINTAT (xCol AS BYTE, xRow AS BYTE, xText AS STRING * 40, xColor AS BYTE) STATIC 
DECLARE FUNCTION ASCII2PETSCII AS BYTE (ascii AS BYTE) STATIC
DECLARE FUNCTION RemoveReverseCharAttr AS BYTE (ascii AS BYTE) STATIC
DECLARE FUNCTION readCharsFromScreen AS STRING * 39 (xCol AS BYTE, xRow AS BYTE, xLength AS BYTE) STATIC
DECLARE SUB mnusInit(xLeft AS BYTE ,xTop AS BYTE , xColor AS BYTE ) STATIC SHARED
DECLARE SUB mnusAddItem(menuStr AS STRING * 39, returnkey AS STRING * 1 )  STATIC SHARED
DECLARE FUNCTION mnusGetKey AS STRING  * 1 ()  STATIC SHARED
DECLARE SUB hiLightMenuItem(Row2hiLight AS BYTE, oldItem AS BYTE) STATIC

DIM mLeft AS BYTE  : DIM mTop AS BYTE
DIM mColor AS BYTE
DIM mCurrrentRow AS INT
DIM mKeys AS STRING * 40
DIM mMaxLength AS BYTE : mMaxLength = 0
DIM mLastRow AS INT
DIM mLastRowHilighted AS BYTE

DIM tmp AS BYTE  
DIM strtmp AS STRING * 39

FUNCTION mnusGetKey AS STRING  * 1 ()  STATIC SHARED
	POKE 650,127 : REM --> no keys repeat
	REM --> Hilight 1st item
	mLastRow = mCurrrentRow - mTop
	mCurrrentRow = 0
	CALL hiLightMenuItem(CBYTE(mCurrrentRow),255)
	
mnuDoAgain:
	tmp = 0
	DO : GET tmp : LOOP UNTIL tmp > 0
	
	IF tmp = keyDOWN THEN
		mCurrrentRow = mCurrrentRow + 1
		IF mCurrrentRow >= mLastRow THEN mCurrrentRow = 0
		CALL hiLightMenuItem(CBYTE(mCurrrentRow), mLastRowHilighted)
	END IF
	IF tmp = keyUP THEN
		mCurrrentRow = mCurrrentRow - 1
		IF mCurrrentRow < 0 THEN mCurrrentRow = mLastRow - 1
		CALL hiLightMenuItem(CBYTE(mCurrrentRow), mLastRowHilighted)
	END IF
	IF tmp = keyRETURN THEN 
		POKE 650,0 : REM --> set keyboard normal repeat	
		RETURN MID$(mKeys, CBYTE(mCurrrentRow), 1)
	END IF		
	GOTO mnuDoAgain	
	
END FUNCTION

SUB hiLightMenuItem(Row2hiLight AS BYTE, oldItem AS BYTE) STATIC
	'locate 0,0 : print "row2hilight: " + str$(Row2hiLight) + "      "  ;
	'locate 0,1 : print "olditem: " + str$(oldItem)  + "      ";
	IF olditem <> 255 THEN
		REM --> un-hilighted OLD entry
		strtmp = readCharsFromScreen(mLeft, mTop + oldItem, mMaxLength)  
		CALL PRINTAT(mLeft, mTop +  oldItem, strtmp, mColor)
	END IF
	REM --> hilighted NEW entry
	strtmp = readCharsFromScreen(mLeft, mTop + Row2hiLight,mMaxLength)  
	CALL PRINTAT(mLeft, mTop +  Row2hiLight,"{REV_ON}" + strtmp + "{REV_OFF}",mColor)
	mLastRowHilighted = Row2hiLight
END SUB

SUB mnusAddItem(menuStr AS STRING * 39, returnkey AS STRING * 1 )  STATIC SHARED
	TEXTAT  mLeft, CBYTE(mCurrrentRow), menuStr, mColor
	mKeys = mKeys + returnkey
	mCurrrentRow = mCurrrentRow + 1 
	IF LEN(menuStr) > mMaxLength THEN
		mMaxLength = LEN(menuStr)
	END IF
END SUB

SUB mnusInit(xLeft AS BYTE ,xTop AS BYTE , xColor AS BYTE ) STATIC SHARED
	mLeft = xLeft
	mTop = xTop
	mColor = xColor
	mCurrrentRow = xTop
END SUB

FUNCTION readCharsFromScreen AS STRING * 39 (xCol AS BYTE, xRow AS BYTE, xLength AS BYTE) STATIC
	CONST SCREENMEM = $0400
	DIM addr AS WORD : addr = SCREENMEM + (CWORD(xRow) * 40) + CWORD(xCol) 
	DIM idx AS BYTE FAST
	readCharsFromScreen = ""
	FOR idx = 0 to xLength - 1
		readCharsFromScreen = readCharsFromScreen + CHR$(ASCII2PETSCII(RemoveReverseCharAttr(PEEK(addr + idx))))
	NEXT
END FUNCTION	

FUNCTION RemoveReverseCharAttr AS BYTE (ascii AS BYTE) STATIC
	REM --> converts a reversed char to a NON reversed char
	IF ascii >= 128 THEN
		RETURN ascii - 128
	END IF
	RETURN ascii
END FUNCTION

SUB PRINTAT (xCol AS BYTE, xRow AS BYTE, xText AS STRING * 40, xColor AS BYTE) STATIC
	DIM tmp1 AS BYTE
	tmp1 = PEEK(646) : REM -->  save old color
	POKE 646,xColor : REM --- C64 only
	LOCATE xCol, xRow :  PRINT xText ;
	POKE 646,tmp1 : REM --- C64 only
END SUB

FUNCTION ASCII2PETSCII AS BYTE (ascii AS BYTE) STATIC
	REM --> https://sta.c64.org/cbm64pettoscr.html
	IF ascii >= 128 AND ascii <= 159 THEN RETURN ascii - 128
	IF ascii >= 32  AND ascii <= 63   THEN RETURN ascii 
	IF ascii >= 0    AND ascii <= 31   THEN RETURN ascii + 64
	IF ascii >= 64  AND ascii <= 95   THEN RETURN ascii + 32
	IF ascii >= 192 AND ascii <= 223  THEN RETURN ascii - 64
	IF ascii >= 96  AND ascii <= 127  THEN RETURN ascii + 64
	IF ascii >= 64  AND ascii <= 95   THEN RETURN ascii + 128
	IF ascii >= 96  AND ascii <= 126  THEN RETURN ascii + 128
	RETURN ascii
END FUNCTION



