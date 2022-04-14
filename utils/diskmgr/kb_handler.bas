REM

CONST TRUE  = 255 : CONST FALSE = 0
SHARED CONST KEY_DOWN = 17
SHARED CONST KEY_UP = 145
SHARED CONST KEY_RETURN = 13

DECLARE SUB mnumInit(xLeft AS BYTE ,xTop AS BYTE , NormalColor as BYTE, HilightColor AS BYTE ) STATIC SHARED
DECLARE SUB mnumAddItem(menuStr as STRING * 39, HilightLetter as STRING * 1)  STATIC SHARED
DECLARE SUB mnumAddItemSpacer()  STATIC SHARED
DECLARE FUNCTION mnumGetKey AS BYTE ()  STATIC SHARED
DECLARE SUB mnumAddToKeyTrap(xKey AS STRING * 1) STATIC SHARED

DIM mLeft AS BYTE 
DIM mNormalClr AS BYTE
DIM mHilightClr AS BYTE
DIM mKeys AS STRING * 40
DIM mCurrrentRow AS BYTE
DIM mTMP AS BYTE

'------------------------------------------------------------------------------------------------
DECLARE SUB PRINTAT (xCol AS BYTE, xRow AS BYTE, xText AS STRING * 40, xColor AS BYTE) STATIC 
DECLARE FUNCTION ASCII2PETSCII AS BYTE (ascii AS BYTE) STATIC
DECLARE FUNCTION RemoveReverseCharAttr AS BYTE (ascii AS BYTE) STATIC
DECLARE FUNCTION readCharsFromScreen AS STRING * 39 (xCol AS BYTE, xRow AS BYTE, xLength AS BYTE) STATIC
DECLARE SUB mnusInit(xLeft AS BYTE ,xTop AS BYTE , xColor AS BYTE ) STATIC SHARED
DECLARE SUB mnusAddItem(menuStr AS STRING * 39, returnkey AS byte)  STATIC SHARED
DECLARE FUNCTION mnusProcessKey AS BYTE (pKeyPressed)  STATIC SHARED
DECLARE SUB hiLightMenuItem(Row2hiLight AS BYTE, oldItem AS BYTE) STATIC

DIM mLeftSC AS BYTE  : DIM mTopSC AS BYTE
DIM mColorSC AS BYTE
DIM SHARED gCurrrentRowSC AS INT
DIM mKeysSC AS STRING * 96 : mKeysSC = ""
DIM mMaxLengthSC AS BYTE : mMaxLengthSC = 0
DIM mLastRowSC AS INT
DIM mLastRowHilightedSC AS BYTE

DIM tmp AS BYTE  
DIM strtmp AS STRING * 39

SUB mnumInit(xLeft AS BYTE ,xTop AS BYTE , NormalColor as BYTE, HilightColor AS BYTE ) STATIC SHARED
	mLeft = xLeft
	mKeys = "" 
	mNormalClr = NormalColor
	mHilightClr = HilightColor
	mCurrrentRow = xTop
END SUB

SUB mnumAddItemSpacer()  STATIC SHARED 
	mCurrrentRow = mCurrrentRow + 1
END SUB


SUB mnumAddToKeyTrap(xKey AS STRING * 1) STATIC SHARED
	CONST KEY_9 = 57
	CONST KEY_0 = 48
	
	mTMP = ASC(xKey)
	IF mTMP >= KEY_0 AND mTMP <= KEY_9 THEN 
		REM -- Numeric, add once
		mKeys = mKeys + xKey
		RETURN
	END IF
	
	REM -- AlphaNumeric, trap both
	mKeys = mKeys + UCASE$(xKey) + LCASE$(xKey)
END SUB


SUB mnumAddItem(menuStr as string * 39, HilightLetter as string * 1 )  STATIC SHARED
	TEXTAT mLeft, mCurrrentRow, menuStr, mNormalClr
	IF LEN(HilightLetter) = 1 THEN
		TEXTAT  mLeft + strInstr(menuStr,HilightLetter) - 1, mCurrrentRow, HilightLetter, mHilightClr
		CALL mnumAddToKeyTrap(HilightLetter)
	END IF
	mCurrrentRow = mCurrrentRow + 1
END SUB


FUNCTION mnumGetKey AS BYTE ()  STATIC SHARED
	
	mnuDoAgain:
	mTMP = 0
	DO
		GET mTMP
	LOOP UNTIL mTMP > 0
	
	REM --- keys for the scroll menu
	IF mTMP = KEY_DOWN OR mTMP = KEY_UP OR mTMP = KEY_RETURN THEN	
		RETURN mTMP
	END IF
	
	REM --- regular menu keys
	IF strInstr(mKeys, CHR$(mTMP)) = 0 THEN 
		GOTO mnuDoAgain		
	END IF
	RETURN mTMP
	
END FUNCTION

'=======================================================================================
SHARED CONST SCROLL_MENU_1ST_RUN = 254
SHARED CONST SCROLL_MENU_OK = 255


FUNCTION GetArrIndexOfSelected AS BYTE () STATIC SHARED
	RETURN CBYTE(VAL(strParse(mKeysSC,",",CBYTE(gCurrrentRowSC+1))))
ENd FUNCTION


FUNCTION mnusProcessKey AS BYTE (pKeyPressed)  STATIC SHARED
	'POKE 650,127 : REM --> no keys repeat 
	
	IF pKeyPressed = SCROLL_MENU_1ST_RUN THEN 
		REM --> Hilight 1st item
		mLastRowSC = gCurrrentRowSC - mTopSC
		gCurrrentRowSC = 0
		CALL hiLightMenuItem(CBYTE(gCurrrentRowSC),255)
		RETURN SCROLL_MENU_OK
	END IF
	
mnuDoAgain:
	
	IF pKeyPressed = KEY_DOWN THEN
		gCurrrentRowSC = gCurrrentRowSC + 1
		IF gCurrrentRowSC >= mLastRowSC THEN gCurrrentRowSC = 0
		CALL hiLightMenuItem(CBYTE(gCurrrentRowSC), mLastRowHilightedSC)
		RETURN SCROLL_MENU_OK
	END IF
	IF pKeyPressed = KEY_UP THEN
		gCurrrentRowSC = gCurrrentRowSC - 1
		IF gCurrrentRowSC < 0 THEN gCurrrentRowSC = mLastRowSC - 1
		CALL hiLightMenuItem(CBYTE(gCurrrentRowSC), mLastRowHilightedSC)
		RETURN SCROLL_MENU_OK
	END IF
	IF pKeyPressed = KEY_RETURN THEN 
		'POKE 650,0 : REM --> set keyboard normal repeat	
		RETURN GetArrIndexOfSelected()
	END IF		
	'GOTO mnuDoAgain	
	
END FUNCTION


SUB SetTagUnTagOnScreen(pRow AS BYTE,pSetTagOn AS BYTE) STATIC SHARED
	mTMP = pRow + mTopSC
	
	'call debugOutVice(" row: " +  str$( mTMP) )

	IF pSetTagOn = TRUE THEN
		TEXTAT 21, mTMP,"!",mColorSC
		return
		IF gCurrrentRowSC = pRow THEN
			CALL PRINTAT(21, mTMP,"{REV_ON}-{REV_OFF}",mColorSC)
		ELSE
			'TEXTAT 21, mTMP,"-",mColorSC
			CALL PRINTAT(21, mTMP,"-",mColorSC)
		END IF
	ELSE
		TEXTAT 21, mTMP," ",mColorSC
		return
		IF gCurrrentRowSC = pRow THEN
			CALL PRINTAT(21, mTMP,"{REV_ON} {REV_OFF}",mColorSC)
		ELSE
			'TEXTAT 21, mTMP," ",mColorSC
			CALL PRINTAT(21, mTMP," ",mColorSC)
		END IF
	END IF
END SUB

SUB hiLightMenuItem(Row2hiLight AS BYTE, oldItem AS BYTE) STATIC
	IF olditem <> 255 THEN
		REM --> un-hilighted OLD entry
		strtmp = readCharsFromScreen(mLeftSC, mTopSC + oldItem, mMaxLengthSC)  
		CALL PRINTAT(mLeftSC, mTopSC +  oldItem, strtmp, mColorSC)
	END IF
	REM --> hilighted NEW entry
	strtmp = readCharsFromScreen(mLeftSC, mTopSC + Row2hiLight,mMaxLengthSC)  
	CALL PRINTAT(mLeftSC, mTopSC +  Row2hiLight,"{REV_ON}" + strtmp + "{REV_OFF}",mColorSC)
	mLastRowHilightedSC = Row2hiLight
END SUB

SUB mnusAddItem(menuStr AS STRING * 39, returnkey AS byte)  STATIC SHARED
	TEXTAT  mLeftSC, CBYTE(gCurrrentRowSC), menuStr, mColorSC
	mKeysSC = mKeysSC + STR$(returnkey) + ","
	gCurrrentRowSC = gCurrrentRowSC + 1 
	IF LEN(menuStr) > mMaxLengthSC THEN
		mMaxLengthSC = LEN(menuStr)
	END IF
END SUB

SUB mnusInit(xLeft AS BYTE ,xTop AS BYTE , xColor AS BYTE ) STATIC SHARED
	mLeftSC = xLeft
	mTopSC = xTop
	mColorSC = xColor
	gCurrrentRowSC = xTop
	mKeysSC = "" 
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
	POKE 646,xColor 
	LOCATE xCol, xRow :  PRINT xText ;
	POKE 646,tmp1 : REM --- C64 only
END SUB

FUNCTION ASCII2PETSCII AS BYTE (ascii AS BYTE) STATIC
	REM --> https://sta.c64.org/cbm64pettoscr.html
	REM --> needs to be revisited,. not quite correct
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







