REM ***********************************************************************************************************
REM *    StrHelper.Bas   XC=BASIC Module  V3.X 
REM *    
REM *	  High level string routines. 
REM *    Note:: This is not the fastest or cleanest code. As XC=BASIC supports inline ASM all these  
REM *               methods could / should / maybe...  end up being rewriten.  BUT...  THIS DOES WORK JUST FINE!  ;) 
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Dec 2021 - Jan 2022        V1.02
REM *   
REM *   Feb-05-2022, Added strCenterString function
REM *   Feb-21-2022, Added strParse function
REM *   Apr-11-2022, Fixed strPadR, strPadL and strStrings methods
REM ***********************************************************************************************************
'DECLARE FUNCTION strStrings AS STRING * 96 (count AS BYTE, character AS BYTE) STATIC SHARED
DECLARE FUNCTION strStrings AS STRING * 96 (count AS BYTE, character AS STRING * 1) STATIC  SHARED  
DECLARE FUNCTION strSPC AS STRING * 96 (count AS BYTE) STATIC  SHARED
DECLARE FUNCTION strPadR AS STRING * 96 (padme AS STRING * 96,count AS BYTE) STATIC SHARED
DECLARE FUNCTION strPadR AS STRING * 96 (padme AS STRING * 96,count AS BYTE, char AS STRING * 1) STATIC SHARED OVERLOAD
DECLARE FUNCTION strPadL AS STRING * 96 (padme AS STRING * 96,count AS BYTE) STATIC SHARED
DECLARE FUNCTION strPadL AS STRING * 96 (padme AS STRING * 96,count AS BYTE, char AS STRING * 1) STATIC SHARED OVERLOAD
DECLARE FUNCTION strBoolToStr AS STRING * 5 (bool AS BYTE) STATIC SHARED 
DECLARE FUNCTION strStrToBool AS BYTE (strbool AS STRING * 5) STATIC SHARED
DECLARE FUNCTION strInstr AS BYTE( startidx AS BYTE,searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED
DECLARE FUNCTION strInstr AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC OVERLOAD SHARED
DECLARE FUNCTION strContains AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED  
DECLARE FUNCTION strContains AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE) STATIC OVERLOAD SHARED  
DECLARE FUNCTION strStartsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED
DECLARE FUNCTION strStartsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE) STATIC OVERLOAD SHARED
DECLARE FUNCTION strEndsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED
DECLARE FUNCTION strEndsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE) STATIC OVERLOAD SHARED
DECLARE FUNCTION strLTrim AS STRING * 96 (trimMe AS STRING * 96) STATIC SHARED
DECLARE FUNCTION strRTrim AS STRING * 96 (trimMe AS STRING * 96) STATIC SHARED
DECLARE FUNCTION strReplace as string * 96 (searchme as string * 96, findme as string * 96, ReplaceWithMe as string * 96) STATIC SHARED
DECLARE FUNCTION strCenterString AS STRING * 96 (xText AS STRING * 94, xWidth AS BYTE) STATIC SHARED
DECLARE FUNCTION strParse AS STRING * 96 (ParseMe AS STRING * 95, DelemChar AS STRING * 1, ElemNum2Return AS BYTE) STATIC SHARED
REM ================================================================================================================

CONST TRUE  = 255 : CONST FALSE = 0

DIM mTMP AS BYTE

'textat 0,20, strStrings(20,"g")
'end 

REM print strParse("firstone1$findme2$ok3","$",1) - returns 'firstone1'
REM print strParse("firstone1$findme2$ok3","$",3) - returns 'ok3'
FUNCTION strParse AS STRING * 96 (ParseMe AS STRING * 95, DelemChar AS STRING * 1, ElemNum2Return AS BYTE) STATIC SHARED
	CONST IS_1ST = 255
	DIM FoundCount AS BYTE : FoundCount = 0
	DIM idx AS BYTE FAST
	DIM idxStart AS BYTE : idxStart = IS_1ST
	DIM idxEnd AS BYTE : idxEnd = 0
	
	IF ElemNum2Return = 1 THEN idxStart = 0
	
	FOR idx = 0 TO LEN(ParseMe) - 1
		IF PEEK(@ParseMe + 1 + idx) = ASC(DelemChar) THEN 
			FoundCount = FoundCount + 1
			IF idxStart = IS_1ST THEN
				IF FoundCount = ElemNum2Return - 1 THEN
					idxStart = idx + 1
				END IF
			ELSE
				idxEnd = idx - idxStart
				EXIT FOR
			END IF
		END IF
	NEXT
	
	IF idxStart = IS_1ST THEN RETURN "" 		     : REM --> nothing found
	IF idxEnd = 0 THEN idxEnd = PEEK(@ParseMe ) : REM --> end of string
	RETURN MID$(ParseMe, idxStart, idxEnd)
	
END FUNCTION



FUNCTION strCenterString AS STRING * 96 (xText AS STRING * 94, xWidth AS BYTE) STATIC SHARED
	mTMP = (xWidth - LEN(xText)) / 2
	RETURN (strSTRINGS(mTMP," ") + xText + strSTRINGS(mTMP," "))
END FUNCTION

REM =================================================================================================
FUNCTION strReplace AS STRING * 96 (searchme AS STRING * 96, findme AS STRING * 96, ReplaceWithMe AS STRING * 96) STATIC SHARED
	DIM idx AS BYTE : idx = 1
	DIM tmp AS STRING * 96 : tmp = ""
 
	DO WHILE idx <> 0
		idx = strInStr(searchme, findme)
		IF idx = 0 THEN EXIT DO
		tmp = tmp + LEFT$(searchme,  idx - 1) + ReplaceWithMe
		searchme = RIGHT$(searchme, LEN(searchme) - (idx + LEN(findme) - 1))
	LOOP

	RETURN (tmp + searchme)
    
END FUNCTION


REM =================================================================================================
FUNCTION strStrings AS STRING * 96 (count AS BYTE, character AS STRING * 1) STATIC  SHARED  
	REM *** THIS WORKED AT ONE TIME ***
	'POKE @strStrings, count   
	'MEMSET @strStrings + 1, count, ASC(character)
	REM ---------------------------------------------------
	 strStrings = ""
	for x as byte = 1 to count 
		strStrings = strStrings + character
	next
END FUNCTION
FUNCTION strSPC AS STRING * 96 (count AS BYTE) STATIC  SHARED
	RETURN strStrings(count," ")
END FUNCTION



REM =================================================================================================
FUNCTION strPadR AS STRING * 96 (padme AS STRING * 96,count AS BYTE) STATIC  SHARED
	RETURN strPadR(padme,count," ")
END FUNCTION
FUNCTION strPadR AS STRING * 96 (padme AS STRING * 96,count AS BYTE, char AS STRING * 1) STATIC SHARED OVERLOAD
	mTMP = LEN(padme)
	IF mTMP > count THEN RETURN LEFT$(padme,count)
	RETURN (padme + (strStrings(count - mTMP, " ")))
END FUNCTION
FUNCTION strPadL AS STRING * 96 (padme AS STRING * 96,count AS BYTE) STATIC  SHARED
	RETURN strPadL(padme,count," ")
END FUNCTION
FUNCTION strPadL AS STRING * 96 (padme AS STRING * 96,count AS BYTE, char AS STRING * 1) STATIC SHARED OVERLOAD
	mTMP = LEN(padme)
	IF mTMP > count THEN RETURN LEFT$(padme,count)
	RETURN (strStrings(count - mTMP, char) + padme)
END FUNCTION


REM =================================================================================================
FUNCTION strLTrim AS STRING * 96 (trimMe AS STRING * 96) STATIC SHARED
  DIM length AS BYTE : length = LEN(trimMe)
  FOR index AS BYTE = 1 TO length - 1
      IF PEEK(@trimMe + index) <> 32 THEN RETURN MID$(trimMe, index - 1, length - index)
  NEXT
  RETURN trimMe
 END FUNCTION
 FUNCTION strRTrim AS STRING * 96 (trimMe AS STRING * 96) STATIC SHARED
	  DIM length AS INT : length = LEN(trimMe)
	  FOR index AS INT = length TO 1 STEP -1 
		  IF PEEK(@trimMe + index) <> 32 THEN RETURN LEFT$(trimMe,  CBYTE(length) - CBYTE(length - index))
	  NEXT		  
	  RETURN trimMe
END FUNCTION


REM =================================================================================================
FUNCTION strBoolToStr AS STRING * 5 (bool AS BYTE) STATIC SHARED
  if bool = FALSE THEN RETURN "false"
  RETURN "true"  
END FUNCTION
FUNCTION strStrToBool AS BYTE (strbool AS STRING * 5) STATIC SHARED
  RETURN LCASE$(strbool) <> "false"
END FUNCTION


REM =================================================================================================
FUNCTION strInstr AS BYTE (startidx AS BYTE,searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED

	REM ** will be replaced soon by the internal command in V3.1
	DIM lenStr AS BYTE : lenStr = LEN(searchme)
	DIM lenFind AS BYTE : lenFind = LEN(findme)
	DIM start AS BYTE : start = startidx 
	  
	IF lenFind = 0 THEN RETURN FALSE  
	IF lenFind > lenStr THEN RETURN FALSE

	DIM idx AS BYTE FAST
	FOR idx  = start TO lenStr

		IF MID$(searchme,idx,lenFind) = findme THEN RETURN idx + 1
		IF (lenFind + idx) >= lenStr THEN RETURN FALSE
		
	NEXT idx
END FUNCTION
FUNCTION strInstr AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC OVERLOAD SHARED 
  RETURN strInstr(0,searchme,findme)
END FUNCTION  
    


REM =================================================================================================
FUNCTION strContains AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED
  RETURN strInstr(searchme, findme)
END FUNCTION
FUNCTION strContains AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE) STATIC OVERLOAD SHARED
  IF IgnoreCase THEN RETURN strInstr(LCASE$(searchme), LCASE$(findme))
  RETURN strInstr(searchme, findme)
END FUNCTION
REM =================================================================================================
FUNCTION strStartsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED
  RETURN (strInstr(searchme, findme) = 1)
END FUNCTION
FUNCTION strStartsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE) STATIC OVERLOAD SHARED
  IF IgnoreCase THEN RETURN (strInstr(LCASE$(searchme), LCASE$(findme)) = 1)
  RETURN (strInstr(searchme, findme) = 1)
END FUNCTION
REM =================================================================================================
FUNCTION strEndsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED
  RETURN (RIGHT$(searchme,LEN(findme)) = findme)
END FUNCTION
FUNCTION strEndsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE) STATIC OVERLOAD SHARED
  IF IgnoreCase THEN RETURN (LCASE$(RIGHT$(searchme,LEN(findme))) = LCASE$(findme))
  RETURN (RIGHT$(searchme,LEN(findme)) = findme)
END FUNCTION


