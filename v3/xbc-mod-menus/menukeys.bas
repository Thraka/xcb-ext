REM ***********************************************************************************************************
REM *    Menukeys.Bas   XC=BASIC Module  V3.X 
REM *    
REM *	 Simple MENU routine. 
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Jan 2022    
REM *    
REM *   Updated to get around some string bugs                                    JakeBullet  Mar-29-2022   Watch RU soldiers driving stolen cars...    
REM ***********************************************************************************************************
'Include "strings.bas"
'Include "colors.bas"

CONST TRUE  = 255 : CONST FALSE = 0

DECLARE SUB mnuInit(xLeft AS BYTE ,xTop AS BYTE , NormalColor as BYTE, HilightColor AS BYTE ) STATIC SHARED
DECLARE SUB mnuAddItem(menuStr as STRING * 39, HilightLetter as STRING * 1)  STATIC SHARED
DECLARE SUB mnuAddItemRev(menuStr AS STRING  * 39, HilightLetter as STRING * 1 )  STATIC SHARED
DECLARE SUB mnuAddItemSpacer()  STATIC SHARED
DECLARE FUNCTION mnuGetKey AS BYTE ()  STATIC SHARED
DECLARE SUB mnuAddToKeyTrap(xKey AS STRING * 1) STATIC SHARED

DIM mLeft AS BYTE 
DIM mNormalClr AS BYTE
DIM mHilightClr AS BYTE
DIM mKeys AS STRING * 40
DIM mCurrrentRow AS BYTE
DIM mTMP AS BYTE


SUB mnuInit(xLeft AS BYTE ,xTop AS BYTE , NormalColor as BYTE, HilightColor AS BYTE ) STATIC SHARED
	mLeft = xLeft
	mKeys = "`" : REM -- should be blank, BUG!!!!!
	mNormalClr = NormalColor
	mHilightClr = HilightColor
	mCurrrentRow = xTop
END SUB

SUB mnuAddItemSpacer()  STATIC SHARED SHARED
	mCurrrentRow = mCurrrentRow + 1
END SUB


SUB mnuAddToKeyTrap(xKey AS STRING * 1) STATIC SHARED
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


SUB mnuAddItem(menuStr as string * 39, HilightLetter as string * 1 )  STATIC SHARED
	TEXTAT mLeft, mCurrrentRow, menuStr, mNormalClr
	IF LEN(HilightLetter) = 1 THEN
		TEXTAT  mLeft + strInstr(menuStr,HilightLetter) - 1, mCurrrentRow, HilightLetter, mHilightClr
		CALL mnuAddToKeyTrap(HilightLetter)
	END IF
	mCurrrentRow = mCurrrentRow + 1
END SUB

SUB mnuAddItemRev(menuStr as string * 39, HilightLetter as string * 1 )  STATIC SHARED
	TEXTAT mLeft, mCurrrentRow,  menuStr, mNormalClr
	IF LEN(HilightLetter) = 1 THEN
	
		LOCATE mLeft + strInstr(menuStr,HilightLetter) - 1, mCurrrentRow 
		PRINT  "{REV_ON}" + HilightLetter + "{REV_OFF}" ; : REM '--- Same as TEXTAT except respects PET codes
		
		CALL mnuAddToKeyTrap(HilightLetter)
	END IF
	mCurrrentRow = mCurrrentRow + 1
END SUB


FUNCTION mnuGetKey AS BYTE ()  STATIC SHARED
	
	mnuDoAgain:
	mTMP = 0
	DO
		GET mTMP
	LOOP UNTIL mTMP > 0
	'POKE 54296,15 : POKE 54296,0 : rem make a click sound
	'CALL scrn_DebugTextBtm(str$(aa))
	IF strInstr(mKeys, CHR$(mTMP)) = 0 THEN GOTO mnuDoAgain		
	RETURN mTMP
	
END FUNCTION



