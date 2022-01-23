REM ***********************************************************************************************************
REM *    xcb-mod-strings.Bas   XC=BASIC Module  V3.X 
REM *    
REM *
REM *
REM *
REM *    Note:: This is not the fastest or cleanest code. As XC=BASIC supports inline ASM all these  
REM *               methods could / should / maybe...  end up being rewriten.  BUT...  THIS DOES WORK JUST FINE!  ;) 
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Dec 2021 - Jan 2022        V0.90
REM ***********************************************************************************************************
DECLARE FUNCTION str_Strings AS STRING * 96 (count AS BYTE, character AS STRING * 1) STATIC  SHARED 
DECLARE FUNCTION str_Strings AS STRING * 96 (count AS BYTE, character AS BYTE) STATIC SHARED OVERLOAD
DECLARE FUNCTION str_SPC AS STRING * 96 (count AS BYTE) STATIC  SHARED
DECLARE FUNCTION str_PadR AS STRING * 96 (padme AS STRING * 96,count AS BYTE) STATIC SHARED
DECLARE FUNCTION str_PadL AS STRING * 96 (padme AS STRING * 96,count AS BYTE) STATIC SHARED
DECLARE FUNCTION str_BoolToStr AS STRING * 5 (bool AS BYTE) STATIC SHARED 
DECLARE FUNCTION str_StrToBool AS BYTE (strbool AS STRING * 5) STATIC SHARED
DECLARE FUNCTION str_Instr AS BYTE( startidx AS BYTE,searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED
DECLARE FUNCTION str_Instr AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC OVERLOAD SHARED
DECLARE FUNCTION str_Contains AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED  
DECLARE FUNCTION str_Contains AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE) STATIC OVERLOAD SHARED  
DECLARE FUNCTION str_StartsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED
DECLARE FUNCTION str_StartsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE) STATIC OVERLOAD SHARED
DECLARE FUNCTION str_EndsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96) STATIC SHARED
DECLARE FUNCTION str_EndsWith AS BYTE(searchme AS STRING * 96, findme AS STRING * 96, IgnoreCase AS BYTE) STATIC OVERLOAD SHARED
DECLARE FUNCTION str_LTrim AS STRING * 96 (s AS STRING * 96) STATIC SHARED
DECLARE FUNCTION str_RTrim AS STRING * 96 (s AS STRING * 96) STATIC SHARED
DECLARE FUNCTION str_Replace as string * 96 (searchme as string * 96, findme as string * 96, ReplaceWithMe as string * 96) STATIC SHARED
REM ================================================================================================================

'--- TODO
'declare function str_Split as string* 96 (splitme as string * 96, splitchar as string * 6) STATIC SHARED
'declare function str_Join as string* 96 (splitme as string * 96, splitchar as string * 6) STATIC SHARED

CONST TRUE  = 255
CONST FALSE = 0


REM =================================================================================================
FUNCTION str_Replace AS STRING * 96 (searchme AS STRING * 96, findme AS STRING * 96, ReplaceWithMe AS STRING * 96) STATIC SHARED
	DIM idx AS BYTE : idx = 1
	DIM tmp AS STRING * 96 : tmp = ""
 
	DO WHILE idx <> 0
		idx = str_InStr(searchme, findme)
		IF idx = 0 THEN EXIT DO
		tmp = tmp + LEFT$(searchme,  idx - 1) + ReplaceWithMe
		searchme = RIGHT$(searchme, LEN(searchme) - (idx + LEN(findme) - 1))
	LOOP

	RETURN (tmp + searchme)
    
END FUNCTION


REM =================================================================================================
FUNCTION str_Strings as string * 96 (count as byte, character as string * 1) STATIC  SHARED 
    RETURN str_Strings(count, ASC(character))
END FUNCTION
FUNCTION str_Strings AS STRING * 96 (count AS BYTE, character AS BYTE) STATIC SHARED OVERLOAD
	IF count < 1 THEN ERROR 14: REM ILLEGAL QUANTITY
	IF count > 96 THEN count = 96
	POKE @str_Strings, count
	MEMSET @str_Strings + 1, count, character
END FUNCTION
FUNCTION str_SPC as string * 96 (count as byte) STATIC  SHARED
	RETURN str_Strings(count," ")
END FUNCTION


REM =================================================================================================
FUNCTION str_PadR as string * 96 (padme as string * 96,count as byte) STATIC  SHARED
	RETURN padme + (str_SPC(count))
END FUNCTION
FUNCTION str_PadL as string * 96 (padme as string * 96,count as byte) STATIC  SHARED
	RETURN (str_SPC(count) + padme)
END FUNCTION

REM =================================================================================================
FUNCTION str_LTrim as string * 96 (s as string * 96) STATIC SHARED
  DIM length AS BYTE : length = LEN(s)
  FOR index AS BYTE = 1 TO length - 1
      IF PEEK(@s + index) <> 32 THEN RETURN MID$(s, index - 1, length - index)
  NEXT
  RETURN s
 END FUNCTION
 FUNCTION str_RTrim as string * 96 (s as string * 96) STATIC SHARED
	  DIM length AS BYTE : length = LEN(s)
	  FOR index AS BYTE = length TO 1 STEP -1 
		  IF PEEK(@s + index) <> 32 THEN RETURN LEFT$(s,  length - (length - index))
	  NEXT		  
	  RETURN s
END FUNCTION


REM =================================================================================================
FUNCTION str_BoolToStr as string * 5 (bool as byte) STATIC SHARED
  if bool = FALSE then RETURN "false"
  RETURN "true"  
END FUNCTION
FUNCTION str_StrToBool as byte (strbool as string * 5) STATIC SHARED
  RETURN LCASE$(strbool) <> "false"
END FUNCTION


REM =================================================================================================
FUNCTION str_Instr as byte(startidx as byte,searchme as string * 96, findme as string * 96) STATIC SHARED

	REM ** will be replaced soon by the internal command in V3.1
	DIM lenStr AS BYTE : lenStr = LEN(searchme)
	DIM lenFind AS BYTE : lenFind = LEN(findme)
	DIM start AS BYTE : start = startidx 
	  
	IF lenFind > lenStr THEN RETURN FALSE

	FOR idx AS BYTE = start TO lenStr

		IF MID$(searchme,idx,lenFind) = findme THEN RETURN idx + 1
		IF (lenFind + idx) >= lenStr THEN RETURN FALSE
		
	NEXT idx
END FUNCTION
FUNCTION str_Instr as byte(searchme as string * 96, findme as string * 96) STATIC OVERLOAD SHARED 
  RETURN str_Instr(0,searchme,findme)
END FUNCTION  
    


REM =================================================================================================
FUNCTION str_Contains as byte(searchme as string * 96, findme as string * 96) STATIC SHARED
  RETURN str_Instr(searchme, findme)
END FUNCTION
FUNCTION str_Contains as byte(searchme as STRING * 96, findme as STRING * 96, IgnoreCase as byte) STATIC OVERLOAD SHARED
  IF IgnoreCase THEN RETURN str_Instr(LCASE$(searchme), LCASE$(findme))
  RETURN str_Instr(searchme, findme)
END FUNCTION
REM =================================================================================================
FUNCTION str_StartsWith as byte(searchme as STRING * 96, findme as STRING * 96) STATIC SHARED
  RETURN (str_Instr(searchme, findme) = 1)
END FUNCTION
FUNCTION str_StartsWith as byte(searchme as STRING * 96, findme as STRING * 96, IgnoreCase as byte) STATIC OVERLOAD SHARED
  IF IgnoreCase THEN RETURN (str_Instr(LCASE$(searchme), LCASE$(findme)) = 1)
  RETURN (str_Instr(searchme, findme) = 1)
END FUNCTION
REM =================================================================================================
FUNCTION str_EndsWith as BYTE(searchme as STRING * 96, findme as STRING * 96) STATIC SHARED
  RETURN (RIGHT$(searchme,LEN(findme)) = findme)
END FUNCTION
FUNCTION str_EndsWith as byte(searchme as STRING * 96, findme as STRING * 96, IgnoreCase as byte) STATIC OVERLOAD SHARED
  IF IgnoreCase THEN RETURN (LCASE$(RIGHT$(searchme,LEN(findme))) = LCASE$(findme))
  RETURN (RIGHT$(searchme,LEN(findme)) = findme)
END FUNCTION


