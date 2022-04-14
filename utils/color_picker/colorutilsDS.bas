CONST TRUE  = 255 : CONST FALSE = 0
Include "drive.bas"
Include "dir.bas"

 'TYPE clrColors 
	'txtNormal    AS BYTE
	'txtBright     AS BYTE
	'txtAlert      AS BYTE
	'border         AS BYTE
	'background  AS BYTE
	'frame          AS BYTE
	'box             AS BYTE
	'box3d         AS BYTE
'END TYPE

'DIM SHARED gColors AS clrColors 
DIM mOldColorText AS BYTE : DIM mOldColorBorder AS BYTE : DIM mOldColorBGround AS BYTE
DIM mLastColorPressed AS BYTE : mLastColorPressed = 255
DIM mProgramTitle AS STRING * 42
DIM mCurrentDrive AS BYTE
DIM mFirstRun as BYTE : mFirstRun = TRUE
DIM junkVar AS BYTE
    
'CHANGE THE COLOR RAM!!!!!!!!!!!!!!!!!!!!!!!!
CONST COLORRAM = $d800
CONST LAST_DRIVE = 11

DECLARE FUNCTION clrGetPETCodeStringNane AS STRING * 16 (clrCode AS BYTE) STATIC 
DECLARE SUB ShowCurrentDrive() STATIC
DECLARE SUB showScreen()  STATIC
DECLARE SUB ShowColorPressed() STATIC
DECLARE FUNCTION incColorCode AS BYTE(num AS BYTE) STATIC
DECLARE SUB clrLoad(filename AS STRING  * 30) STATIC SHARED
DECLARE SUB clrSave(filename AS STRING  * 30) STATIC SHARED
DECLARE SUB clrSaveOld() STATIC SHARED
DECLARE SUB clrRestoreOld() STATIC SHARED
DECLARE SUB clrSelector() STATIC SHARED
DECLARE SUB clrInit() STATIC SHARED
DECLARE SUB clrInit(filename AS STRING  * 30) STATIC SHARED OVERLOAD

SUB clrSelector() STATIC SHARED
	DIM keyPress$ AS STRING * 1
	CALL boxInit()
	mCurrentDrive = PEEK(186)
	mProgramTitle = "{REV_ON}" + strCenterString("** color selector **",40) +  "{REV_OFF}"
	PRINT "{CLR}"
	
DrawColorMenu:
	CALL showScreen()
	CALL mnuInit(27,8, gColors.txtNormal ,gColors.txtBright)
	CALL mnuAddItem("BackGround","G")
	CALL mnuAddItem("Border","B")
	CALL mnuAddItem("Text Normal","N")
	CALL mnuAddItem("Text Bright","h")
	CALL mnuAddItem("Text Alert","A")
	CALL mnuAddItem("Box","x")
	CALL mnuAddItem("Box 3d","d")
	CALL mnuAddItem("Frame","F")
	CALL mnuAddItemSpacer()
	CALL mnuAddItem("1 - Save","1")
	CALL mnuAddItem("2 - Load","2")
	CALL mnuAddToKeyTrap("o") : REM --> to exit program
	CALL mnuAddToKeyTrap("#") : REM --> change drive #
		
GetKeyMenu:
	keyPress$ = LCASE$(CHR$(mnuGetKey()))
	'textat 0,15,keyPress$
	IF keyPress$ = "#" THEN : REM --> change drive #
		mCurrentDrive = mCurrentDrive + 1
		IF mCurrentDrive = LAST_DRIVE + 1 THEN mCurrentDrive = 8
		CALL ShowCurrentDrive()
		GOTO GetKeyMenu
	END IF
	IF keyPress$ = "o" THEN RETURN
	IF keyPress$ = "b" THEN
		gColors.border = incColorCode(gColors.border) 
		CALL ShowColorPressed()
		POKE 53280, gColors.border 
		GOTO GetKeyMenu
	END IF
	IF keyPress$ = "g" THEN
		gColors.background = incColorCode(gColors.background) 
		CALL ShowColorPressed()		
		POKE 53281, gColors.background 
		GOTO GetKeyMenu
	END IF
	IF keyPress$ = "n" THEN gColors.txtNormal = incColorCode(gColors.txtNormal)
	IF keyPress$ = "h" THEN gColors.txtBright  = incColorCode(gColors.txtBright)
	IF keyPress$ = "a" THEN gColors.txtAlert    = incColorCode(gColors.txtAlert)
	IF keyPress$ = "x" THEN gColors.box           = incColorCode(gColors.box)
	IF keyPress$ = "d" THEN gColors.box3d       = incColorCode(gColors.box3d)
	IF keyPress$ = "f" THEN gColors.frame        = incColorCode(gColors.frame)
	IF keyPress$ = "1" THEN CALL clrSave("")
	IF keyPress$ = "2" THEN CALL clrLoad("")
	GOTO DrawColorMenu

END SUB

SUB showScreen()  STATIC

	DIM Counter AS BYTE 
	DIM Col AS BYTE : Col = gScrnWidth - 14
	CONST hzLine = 64 : CONST vrLine = 93  : REM --> lower case 
	FOR Counter = 0 TO gScrnWidth : CHARAT Counter, 3,hzLine,gColors.frame     : NEXT
	FOR Counter = 3 TO gScrnHeight : CHARAT Col, Counter,vrLine,gColors.frame  :  NEXT
	CHARAT Col, 3,114,gColors.frame
	CHARAT Col, gScrnHeight ,93,gColors.frame
	
	CALL scrnTextAtWithHilight(Col + 5, gScrnHeight ,"Close",gColors.txtNormal ,gColors.txtBright,"o")	
	LOCATE 0,0 : PRINT clrGetPETCodeString(gColors.txtBright)  +  mProgramTitle
	
	CALL boxDraw(2,6,21,6,gColors.box, FALSE, "Title  Here")	
	IF mFirstRun THEN
		LOCATE 4,8 : PRINT clrGetPETCodeString(gColors.txtNormal) + "text normal {REV_ON}normal{REV_OFF}" ; 
		LOCATE 4,9 : PRINT clrGetPETCodeString(gColors.txtBright)  + "text bright {REV_ON}bright{REV_OFF}" ;  
		LOCATE 4,10 : PRINT clrGetPETCodeString(gColors.txtalert)    + "text alert  {REV_ON}alert{REV_OFF}" ;
	ELSE
		MEMSET COLORRAM + CWORD(320) + CWORD(4), 18, gColors.txtNormal 
		MEMSET COLORRAM + CWORD(360) + CWORD(4), 18, gColors.txtBright 
		MEMSET COLORRAM + CWORD(400) + CWORD(4), 18, gColors.txtalert 
	END IF
	 	
	CALL boxDraw3D(2,15,21,6,gColors.box, gColors.box3d ,FALSE)
	IF mFirstRun THEN
		LOCATE 4,17 : PRINT clrGetPETCodeString(gColors.txtNormal) + "text normal {REV_ON}normal{REV_OFF}" ; 
		LOCATE 4,18 : PRINT clrGetPETCodeString(gColors.txtBright)  + "text bright {REV_ON}bright{REV_OFF}" ;  
		LOCATE 4,19 : PRINT clrGetPETCodeString(gColors.txtalert)     + "text alert  {REV_ON}alert{REV_OFF}" ;
	ELSE
		MEMSET COLORRAM + CWORD(680) + CWORD(4), 18, gColors.txtNormal 
		MEMSET COLORRAM + CWORD(720) + CWORD(4), 18, gColors.txtBright 
		MEMSET COLORRAM + CWORD(760) + CWORD(4), 18, gColors.txtalert 
	END IF
	  
	mFirstRun = FALSE
	CALL ShowColorPressed() 
	CALL ShowCurrentDrive()
END SUB

SUB ShowCurrentDrive() STATIC
	DIM drv AS STRING * 2
	drv = STR$(mCurrentDrive)
	IF LEN(drv) = 1 THEN drv = "0" + drv
	CALL scrnTextAtWithHilight(3, 24 ,"save/load drive #" + drv, gColors.txtNormal ,gColors.txtBright,"#")
END SUB

SUB clrRestoreOld() STATIC SHARED
	REM --> call on program exit
	POKE 646,mOldColorText
	POKE 53280, mOldColorBorder        
	POKE 53281, mOldColorBGround               
END SUB

SUB clrSaveOld() STATIC SHARED
	REM --> call on program startup
	mOldColorText       = PEEK(55296)
	mOldColorBorder    = PEEK(53280)
	mOldColorBGround = PEEK(53281)
END SUB

FUNCTION incColorCode AS BYTE(num as BYTE) STATIC
	num = num + 1
	IF num >= 16 THEN num = 0
	mLastColorPressed = num
	RETURN num
END FUNCTION

SUB clrInit() STATIC SHARED
	gColors.txtNormal = COLOR_CYAN
	gColors.txtBright = COLOR_BLACK
	gColors.txtAlert = COLOR_GREEN
	gColors.border  = COLOR_CYAN
	gColors.background = COLOR_DARK_GRAY
	gColors.frame = COLOR_CYAN
	gColors.box     =  COLOR_WHITE
	gColors.box3d = COLOR_BLACK
END SUB
SUB clrInit(filename AS STRING  * 30) STATIC SHARED OVERLOAD
	REM --> see if file exists, if not create
END SUB

SUB clrLoad(filename AS STRING  * 30) STATIC SHARED
	IF LEN(filename) = 0 THEN filename = "colors-data"
	CALL screenSave()
	CALL boxDraw(3,10,32,4,gColors.box, TRUE)
	TEXTAT 5,12, strCenterString("checking file...",30),gColors.txtnormal
	 
	IF  dskFileExists(filename, mCurrentDrive) = FALSE THEN
		CALL screenRestore()
		CALL scrnMsgBoxOk("** file not found **" ,filename + ".seq",gColors.box,gColors.txtNormal)
		RETURN
	END IF
	TEXTAT 5,12, strCenterString("loading file...",30),gColors.txtnormal
	
	OPEN 2,mCurrentDrive,2, filename + ",s,r"
	READ #2, gColors : CLOSE 2
	CALL screenRestore()
END SUB

SUB clrSave(filename AS STRING  * 30) STATIC SHARED
	IF LEN(filename) = 0 THEN filename = "colors-data"
		
	REM --> tell them what we are doing	
	CALL screenSave()
	CALL boxDraw(3,10,32,4,gColors.box, TRUE)
	TEXTAT 5,12, strCenterString("saving file...",30),gColors.txtnormal
	CALL dskSafeKill (filename,mCurrentDrive)

	REM --> do the save
	OPEN 2,mCurrentDrive,2, "@0:" + filename + ",s,w"
	WRITE #2, gColors : CLOSE 2
	CALL screenRestore()

	REM --> tell them its done
	CALL scrnMsgBoxOk("** file saved **","",gColors.box,gColors.txtNormal)
	RETURN

errhandler:
	IF ERR() = 5 THEN
		TEXTAT 5,12, strCenterString("error, drive in not valid.",30),gColors.txtnormal
	ELSE
		ERROR ERR() : REM --> program will end here
	END IF
	junkVar = scrnReadKey()
	CALL screenRestore()
	
END SUB

SUB ShowColorPressed() STATIC
	IF mLastColorPressed <> 255 THEN
		TEXTAT 0,2 ,strCenterString("last color pressed: " + clrGetPETCodeStringNane(mLastColorPressed),40),gColors.txtNormal
	END IF
END SUB


FUNCTION clrGetPETCodeStringNane AS STRING * 16 (clrCode AS BYTE) STATIC 
	IF clrCode = COLOR_BLACK             THEN RETURN "black"
	IF clrCode = COLOR_WHITE            THEN RETURN "white"
	IF clrCode = COLOR_CYAN               THEN RETURN "cyan"
	IF clrCode = COLOR_BLUE                THEN RETURN "blue"
	IF clrCode = COLOR_RED                  THEN RETURN "red"
	IF clrCode = COLOR_YELLOW           THEN RETURN "yellow"
	IF clrCode = COLOR_GRAY                THEN RETURN "gray"
	IF clrCode = COLOR_PURPLE            THEN RETURN "purple"
	IF clrCode = COLOR_GREEN             THEN RETURN "green"
	IF clrCode = COLOR_ORANGE           THEN RETURN "orange"
	IF clrCode = COLOR_BROWN            THEN RETURN "brown"
	IF clrCode = COLOR_LIGHT_RED      THEN RETURN "light red"
	IF clrCode = COLOR_DARK_GRAY      THEN RETURN "dark gray"
	IF clrCode = COLOR_LIGHT_GREEN THEN RETURN "light green"
	IF clrCode = COLOR_LIGHT_BLUE    THEN RETURN "light blue"
	IF clrCode = COLOR_LIGHT_GRAY    THEN RETURN "light gray"
	TEXTAT 0,24,"Err! clrGetPETCodeStringNane - value:"  + STR$(clrCode)
	ERROR 14
END FUNCTION
