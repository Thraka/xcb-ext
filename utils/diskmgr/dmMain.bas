CONST TRUE  = 255 : CONST FALSE = 0

DIM mJunkVarByte AS BYTE FAST
DIM mJunkVarStr AS STRING * 96
DIM mDirPointer AS BYTE

DECLARE SUB RunPrg(pNdx as BYTE, pDisk AS BYTE) STATIC SHARED
DECLARE SUB ClearFilesWindow() STATIC   
DECLARE SUB logDrive(xDrive AS BYTE) STATIC SHARED
DECLARE SUB ReadDiskHeader(xDrive AS BYTE) STATIC 
DECLARE SUB populateArr() STATIC
DECLARE FUNCTION menuGetDrive AS BYTE (pPrompt AS STRING * 20) STATIC SHARED


SUB logDrive(xDrive AS BYTE) STATIC SHARED
	CALL ClearFilesWindow()

	CALL screenSave()
	CALL boxDraw(3,10,32,4,gColors.box, TRUE)
	TEXTAT 5,12, strCenterString("Reading disk #" + STR$(xDrive),30),gColors.txtnormal
	
	REM --- populate dir array
	CALL dirGetDir(xDrive)
	
	CALL screenRestore()
	
	CALL ReadDiskHeader(xDrive)
	
	REM -- logging a new drive
	mDirPointer = 0
	
	CALL  mnusInit(0,4, gColors.txtnormal)
	CALL populateArr()
	
	REM --- call dir scroll menu 
	mJunkVarByte = mnusProcessKey(SCROLL_MENU_1ST_RUN)
		
END SUB


SUB populateArr() STATIC
	CONST SCREEN_PAGE_SIZE = 20
	
	FOR mJunkVarByte = mDirPointer TO mDirPointer + SCREEN_PAGE_SIZE
	
		IF gDirDirectory(mJunkVarByte).status = DIR_END_ARRAY THEN 
			mJunkVarByte = mJunkVarByte - 1
			EXIT FOR
		END IF
		
		mJunkVarStr = strPadL(STR$(gDirDirectory(mJunkVarByte).size),4," ") + " " + strPadR(gDirDirectory(mJunkVarByte).fileName,16) + " " + LEFT$(GetFileType(gDirDirectory(mJunkVarByte).fileType),1)
		CALL mnusAddItem(mJunkVarStr, gDirDirectory(mJunkVarByte).index)	
	NEXT
	
	REM -- page ends at
	mDirPointer = gDirDirectory(mJunkVarByte).index
	
END SUB


SUB RunPrg(pNdx as BYTE, pDisk AS BYTE) static shared
	
	IF gDirDirectory(pNdx).fileType = FILE_TYPE_PRG THEN
		REM --- this will end this program and run the new one
		CALL diskChain(gDirDirectory(pNdx).fileName, "loading...", pDisk,  FALSE)
	ELSE
		CALL scrnMsgBoxOk("Cannot run this program",gDirDirectory(pNdx).fileName, gColors.Box,gColors.txtNormal)
	END IF

END SUB



SUB popupValidateDisk(curDisk AS BYTE) STATIC SHARED

	DIM disknum AS BYTE
	disknum = menuGetDrive("Validate Disk")
	IF disknum <> 255 THEN 
		IF disknum = 0 THEN disknum = 10
		IF disknum = 1 THEN disknum = 11
		
		CALL screenSave()
		CALL boxDraw(3,10,32,4,gColors.box, TRUE)
		TEXTAT 5,12, strCenterString(("Validating disk #" + STR$(disknum)) ,30),gColors.txtNormal
		mJunkVarByte = dskValidate(disknum)
		CALL screenRestore()
		
		IF curDisk = disknum THEN 
			CALL logDrive(disknum)
		END IF	
		
	END IF
	
END SUB


FUNCTION popupLogDisk AS BYTE (curDisk AS BYTE)  STATIC SHARED

	DIM disknum AS BYTE
	disknum = menuGetDrive("Log Disk")
	IF disknum <> 255 THEN 
		IF disknum = 0 THEN disknum = 10
		IF disknum = 1 THEN disknum = 11
		CALL logDrive(disknum)
		RETURN disknum
	END IF
	
	RETURN curDisk
	
END FUNCTION


SUB popupFormatDisk(curDisk AS BYTE) STATIC SHARED

	DIM disknum AS BYTE
	disknum = menuGetDrive("Format Disk")
	IF disknum <> 255 THEN 
		IF disknum = 0 THEN disknum = 10
		IF disknum = 1 THEN disknum = 11
		
		CALL screenSave()
		CALL boxDraw(3,6,17,8,gColors.box, TRUE,"Format method")
		CALL mnuInit(7,9, gColors.txtNormal ,gColors.txtBright)
		CALL mnuAddItem("Format new","n") 
		CALL mnuAddItem("Format fast","F")
		CALL mnuAddItemSpacer()
		CALL mnuAddItem("Cancel","C")
		
		DIM KPressed AS BYTE : KPressed = mnuGetKey()
		CALL screenRestore()
		
		mJunkVarStr = LCASE$(CHR$(KPressed)) 
		IF mJunkVarStr = "c" THEN RETURN : REM ---out of here
				
		CALL screenSave()
		
		REM ----------------------------------------------
		dim dn$ as string * 16
		dim id$ as string * 2
		print "{clr}"
		print "Needs to write an editor!"
		input "{down}Enter disk name (16 char)" ; dn$
		IF mJunkVarStr <> "f" THEN
			input "Enter disk id (2 char)" ; id$
		else
			id$ ="1"
		end if
		iF dn$ = "" or id$ = "" THEN
			CALL screenRestore()
			RETURN
		END IF
		
		REM ----------------------------------------------
				
		CALL boxDraw(3,10,32,4,gColors.box, TRUE)
		TEXTAT 5,12, strCenterString(("Formating disk #" + STR$(disknum)) ,30),gColors.txtNormal
		IF mJunkVarStr = "f" THEN
			mJunkVarByte = dskFormatFast(dn$,disknum)
		ELSE
			mJunkVarByte = dskFormat(dn$,id$,disknum)
		END IF	
		CALL screenRestore()
			
		IF curDisk = disknum THEN 
			CALL logDrive(disknum)
		END IF	
		
	END IF
	
END SUB



FUNCTION menuGetDrive AS BYTE (pPrompt AS STRING * 20) STATIC SHARED
	
	dim height as byte : height = 10
	CALL screenSave()
	CALL boxDraw(3,6,15,height,gColors.box, TRUE,pPrompt)
	CALL mnuInit(7,9, gColors.txtNormal ,gColors.txtBright)
	IF dskIsDriveAttatched(8)  THEN CALL mnuAddItem("Disk #08","8") 
	IF dskIsDriveAttatched(9)  THEN CALL mnuAddItem("Disk #09","9")
	IF dskIsDriveAttatched(10) THEN CALL mnuAddItem("Disk #10","0")
	IF dskIsDriveAttatched(11) THEN CALL mnuAddItem("Disk #11","1")
	CALL mnuAddItemSpacer()
	CALL mnuAddItem("Cancel","C")
	
	DIM KPressed AS BYTE : KPressed = mnuGetKey()
	CALL screenRestore()
	
	IF LCASE$(CHR$(KPressed)) = "c" THEN RETURN 255 : REM --- cancel
	RETURN CBYTE(VAL(CHR$(KPressed))) 
	
END FUNCTION


SUB ReadDiskHeader(xDrive AS BYTE) STATIC 
	
	REM --- show drive
	mJunkVarStr = STR$(xDrive)
	IF LEN(mJunkVarStr) = 1 THEN 
		mJunkVarStr = "#0" + mJunkVarStr
	ELSE
		mJunkVarStr = "#" + mJunkVarStr
	END IF
	TEXTAT 37,2, LEFT$(mJunkVarStr,3), gColors.txtAlert
	
	REM --- read disk header
	DIM xTMP$ AS STRING * 1
	DIM yTMP$ AS STRING * 1
	mJunkVarStr = ""
	OPEN 10,xDrive,0,"$u=u"
    FOR mJunkVarByte = 1 TO 34
        GET #10,xTMP$
        IF isAlpha(xTMP$) OR isNumeric(xTMP$) THEN
			mJunkVarStr = mJunkVarStr + xTMP$
		END IF
    NEXT
    GET #10, xTMP$
    GET #10, yTMP$
    CLOSE 10
  
	REM --- disk label
	mJunkVarStr = UCASE$(mJunkVarStr)
	mJunkVarStr = LEFT$(mJunkVarStr,LEN(mJunkVarStr) - 2) + "," + RIGHT$(mJunkVarStr,2)
    TEXTAT 0,2, strPADR(mJunkVarStr ,20), gColors.txtAlert
    
    REM --- BLOCKS FREE
    DIM BF AS INT
    BF = ASC(xTMP$ + CHR$(0)) + 256 * ASC(yTMP$ + CHR$(0))
    TEXTAT 23,2,  "Bks Free:" + strPadR(STR$(BF),4," "), gColors.txtAlert
	
END SUB

SUB ClearFilesWindow() STATIC
	' TODO  change to memset
	mJunkVarStr = strSPC(23)
	FOR mJunkVarByte = 4 TO 24
		TEXTAT 0, mJunkVarByte, mJunkVarStr
	NEXT
END SUB

