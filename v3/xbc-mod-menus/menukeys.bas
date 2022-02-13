REM ***********************************************************************************************************
REM *    Menukeys.Bas   XC=BASIC Module  V3.X 
REM *    
REM *	  Simple MENU routine. 
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Jan 2022        V1.00
REM ***********************************************************************************************************
'Include "strings.bas"
'Include "colors.bas"

CONST TRUE  = 255 : CONST FALSE = 0

DECLARE SUB mnuInit(xLeft AS BYTE ,top AS BYTE , NormalColor as BYTE, HilightColor AS BYTE ) STATIC SHARED
DECLARE SUB mnuAddItem(menuStr as STRING * 39, HilightLetter as STRING * 1 )  STATIC SHARED
DECLARE SUB mnuAddItemRev(menuStr AS STRING  * 39, HilightLetter as STRING * 1 )  STATIC SHARED
DECLARE FUNCTION mnuGetKey AS BYTE ()  STATIC SHARED
DECLARE SUB mnuAddKey(key AS STRING * 1  )  STATIC SHARED

DIM mLeft AS BYTE 
DIM mNormalClr AS BYTE
DIM mHilightClr AS BYTE
DIM mKeys AS STRING * 40
DIM mCurrrentRow AS BYTE

SUB mnuAddKey(key AS STRING * 1 )  STATIC SHARED
	mKeys = mKeys + UCASE$(key) + LCASE$(key)
END SUB

SUB mnuInit(xLeft AS BYTE ,top AS BYTE , NormalColor as BYTE, HilightColor AS BYTE ) STATIC SHARED
	mLeft = xleft
	mKeys = ""
	mNormalClr = NormalColor
	mHilightClr = HilightColor
	mCurrrentRow = Top
	'POKE 646, NormalColor : REM - C64 only? - needed for mnuAddItemRev Method - TODO
END SUB

SUB mnuAddItem(menuStr as string * 39, HilightLetter as string * 1 )  STATIC SHARED
	IF LEN(menuStr) > 0 THEN TEXTAT mLeft, mCurrrentRow, menuStr, mNormalClr
	IF LEN(HilightLetter) = 1 THEN
		TEXTAT  mLeft + strInstr(menuStr,HilightLetter) - 1, mCurrrentRow, HilightLetter, mHilightClr
		mKeys = mKeys + UCASE$(HilightLetter) + LCASE$(HilightLetter)
	END IF
	mCurrrentRow = mCurrrentRow + 1
END SUB

SUB mnuAddItemRev(menuStr as string * 39, HilightLetter as string * 1 )  STATIC SHARED
	IF LEN(menuStr) > 0 THEN TEXTAT mLeft, mCurrrentRow,  menuStr, mNormalClr
	IF LEN(HilightLetter) = 1 THEN
		LOCATE mLeft + strInstr(menuStr,HilightLetter) - 1, mCurrrentRow : PRINT  "{REV_ON}" + HilightLetter + "{REV_OFF}" ; : REM '--- Same as TEXTAT except respects PET codes
		mKeys = mKeys + UCASE$(HilightLetter) + LCASE$(HilightLetter)		
	END IF
	mCurrrentRow = mCurrrentRow + 1
END SUB


FUNCTION mnuGetKey AS BYTE ()  STATIC SHARED
	DIM aa AS BYTE
	
mnuDoAgain:
	aa = 0
	DO
		GET aa
	LOOP UNTIL aa > 0
	'POKE 54296,15 : POKE 54296,0 : rem make a click sound
	'CALL scrn_DebugTextBtm(str$(aa))
	IF strInstr(mKeys, CHR$(aa)) = 0 THEN GOTO mnuDoAgain		
	RETURN aa
	
END FUNCTION



