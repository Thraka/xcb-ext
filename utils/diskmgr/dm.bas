CONST TRUE  = 255 : CONST FALSE = 0

DIM SHARED gScrnWidth AS BYTE  : DIM SHARED gScrnHeight AS BYTE 
DIM mOldColorText AS BYTE : DIM mOldColorBorder AS BYTE : DIM mOldColorBGround AS BYTE
DIM mCurrentDisk AS BYTE
DIM mFirstRun AS BYTE : mFirstRun = TRUE
DIM mTMP AS BYTE

DECLARE SUB StartUp() STATIC
DECLARE SUB EndPrg() STATIC	
DECLARE SUB MainMenu() STATIC SHARED
DECLARE SUB drawScreen()  STATIC
DECLARE SUB clrSaveOld() STATIC SHARED
DECLARE SUB clrRestoreOld() STATIC SHARED
DECLARE SUB clrInit() STATIC SHARED
DECLARE SUB clrInit(filename AS STRING  * 30) STATIC SHARED OVERLOAD
DECLARE SUB clrLoad(filename AS STRING  * 30) STATIC SHARED

Include "colors.bas"  
Include "colors_types.bas"
Include "strings.bas"
Include "misc.bas"
Include "box.bas"
Include "screen.bas"
Include "kb_handler.bas"
Include "disk_routines.bas"
Include "dir.bas"
Include "menukeys.bas"
Include "dmmain.bas"


CALL StartUp()
REM ----------------------------------------------------
CALL MainMenu() : REM --> main code
REM ----------------------------------------------------
CALL EndPrg()	


SUB MainMenu() STATIC SHARED
	DIM keyPress$ AS STRING * 1
	DIM DirSelectedNdx AS BYTE
	DIM KPressed AS BYTE 
	
DrawColorMenu:
	
	CALL mnumInit(25,5, gColors.txtNormal ,gColors.txtBright)
	CALL mnumAddItem("Log new disk","L")
	CALL mnumAddItem("Filter by name","F")
	CALL mnumAddItem("Filter by ext","e")
	CALL mnumAddItem("Copy file(s)","C")
	CALL mnumAddItem("Duplicate file","a")
	CALL mnumAddItem("Move file(s)","M")
	CALL mnumAddItem("Delete file(s)","D")
	CALL mnumAddItem("Rename file","R")
	CALL mnumAddItem("Tag file","T")
	CALL mnumAddItem("Un-Tag file","U")
	CALL mnumAddItem("Multi tag","M")
	CALL mnumAddItemSpacer()
	CALL mnumAddItem("Format disk","k")
	CALL mnumAddItem("Validate disk","i")
	CALL mnumAddItem("Copy disk","y")
	CALL mnumAddItemSpacer()
	CALL mnumAddItem("<RETURN> Run","")
	
	CALL mnumAddToKeyTrap("Q") : REM --> to exit program
	CALL scrnTextAtWithHilight(25,22,"Quit program",gColors.txtNormal ,gColors.txtBright,"Q")
	
	IF mFirstRun THEN 
		mCurrentDisk = 9
		CALL logDrive(mCurrentDisk)
		mFirstRun = FALSE
	END IF
	
GetKeyMenu:
	KPressed = mnumGetKey()

ForceScroll:	
	REM -------------- DIR SCROLL MENU KEYS  -----------------------------------
	IF KPressed = KEY_DOWN OR KPressed = KEY_UP OR KPressed = KEY_RETURN THEN
	
		REM --- pass key to dir scroll menu
		DirSelectedNdx = mnusProcessKey(KPressed) 

		REM --- Enter was hit, run program
		IF DirSelectedNdx <> SCROLL_MENU_OK THEN CALL RunPrg(DirSelectedNdx, mCurrentDisk)
		
		GOTO GetKeyMenu
	END IF


	REM ------------------  MENU KEY PRESSES -----------------------------
	keyPress$ = LCASE$(CHR$(KPressed))
	
	REM --- tag / un-tag single file -------------------------------------------------
	IF keyPress$ = "t" THEN 
		IF gDirDirectory(GetArrIndexOfSelected()).tagged = TRUE THEN GOTO GetKeyMenu
		gDirDirectory(GetArrIndexOfSelected()).tagged = TRUE
		CALL SetTagUnTagOnScreen(CBYTE(gCurrrentRowSC) ,TRUE)
		KPressed = KEY_DOWN
		GOTO ForceScroll
	END IF
	IF keyPress$ = "u" THEN 
		IF gDirDirectory(GetArrIndexOfSelected()).tagged = FALSE THEN GOTO GetKeyMenu
		gDirDirectory(GetArrIndexOfSelected()).tagged = FALSE
		CALL SetTagUnTagOnScreen(CBYTE(gCurrrentRowSC) ,FALSE)
		KPressed = KEY_DOWN
		GOTO ForceScroll
	END IF
	
	REM --- log new disk -------------------------------------------------
	IF keyPress$ = "l" THEN 
		mCurrentDisk =  popupLogDisk(mCurrentDisk)
		GOTO GetKeyMenu
	END IF
	
	REM --- validate disk -------------------------------------------------
	IF keyPress$ = "i" THEN 
		CALL popupValidateDisk(mCurrentDisk )
		GOTO GetKeyMenu
	END IF
		
	REM --- format new disk -------------------------------------------------
	IF keyPress$ = "k" THEN 
		CALL popupFormatDisk(mCurrentDisk)
		GOTO GetKeyMenu
	END IF
	
	REM --- out of here ------------------------------------------------
	IF keyPress$ = "q" THEN RETURN
	GOTO GetKeyMenu

END SUB

SUB drawScreen()  STATIC

	DIM Counter AS BYTE 
	DIM Col AS BYTE : Col = gScrnWidth - 16
	CONST hzLine = 64 : CONST vrLine = 93  : REM --> lower case 
	FOR Counter = 0 TO gScrnWidth 
		CHARAT Counter, 3,hzLine,gColors.frame     
	NEXT
	FOR Counter = 3 TO gScrnHeight 
		CHARAT Col, Counter,vrLine,gColors.frame  
	NEXT
	CHARAT Col, 3,114,gColors.frame
	CHARAT Col, gScrnHeight ,93,gColors.frame
	return
	

END SUB


'---------------------------------------------------------------------------------------------


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
	'IF LEN(filename) = 0 THEN filename = "colors-data"
	'CALL screenSave()
	'CALL boxDraw(3,10,32,4,gColors.box, TRUE)
	'TEXTAT 5,12, strCenterString("checking file...",30),gColors.txtnormal
	 
	'IF  dskFileExists(filename, mCurrentDisk) = FALSE THEN
		'CALL screenRestore()
		'CALL scrnMsgBoxOk("** file not found **" ,filename + ".seq",gColors.box,gColors.txtNormal)
		'RETURN
	'END IF
	'TEXTAT 5,12, strCenterString("loading file...",30),gColors.txtnormal
	
	'OPEN 2,mCurrentDisk,2, filename + ",s,r"
	'READ #2, gColors : CLOSE 2
	'CALL screenRestore()
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

'---------------------------------------------------------------------------------------------

sub EndPrg() static
	CALL clrRestoreOld() : REM --> restore system color values
	POKE 53272, 21          : REM --> back to upper case (C64)
	PRINT "{CLR}end program, have a nice day!"
	END
end sub

sub StartUp() static
	CALL clrInit()        : REM --> set default colors
	CALL clrSaveOld() : REM --> saves system color values	
	mCurrentDisk = PEEK(186)
	PRINT "{CLR}"
	gScrnWidth = 39 : gScrnHeight = 24
	POKE 53272, 23  : REM --> Switch to lower case
	POKE 657,128 		: REM -- Disable SHIFT + Commodore key 
	POKE 55296, gColors.txtNormal     : REM --> 'POKE 646,     clr_txt_normal     		
	POKE 53280, gColors.border           : REM changes the border color 
	POKE 53281, gColors.background    : REM changes the background color
	CALL boxInit()
	CALL drawScreen() 
end sub
