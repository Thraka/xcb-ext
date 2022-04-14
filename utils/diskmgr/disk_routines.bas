REM ******************************************************************************************************
REM *    drive.bas   XC=BASIC Module V3.X 
REM *
REM ******************************************************************************************************

DECLARE FUNCTION dskBlocksFree AS INT (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskDriveModel AS STRING * 4 (driveNum AS BYTE) STATIC SHARED 
DECLARE FUNCTION dskDriveModelConst AS BYTE (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskStatus AS STRING * 96 (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskStatusOK AS BYTE (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskGetCurrentDriveInUse AS BYTE () STATIC SHARED
DECLARE FUNCTION dskIsDriveAttatched AS BYTE (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskFileDelete AS BYTE (xFileName AS STRING * 16, driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskFileExists AS BYTE (xFileName AS STRING * 16, driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskFormat AS BYTE  (xDiskName AS STRING * 16, xDiskID AS STRING * 2, driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskFormatFast AS BYTE  (xDiskName AS STRING * 16,driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskRescan AS BYTE (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskInitialize  AS BYTE (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskValidate AS BYTE (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskCheckDisk AS BYTE (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskFileRename AS BYTE  (xOldFileName AS STRING * 16,xNewFileName AS STRING * 16,driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskFileCopy AS BYTE  (xOldFileName AS STRING * 16,xNewFileName AS STRING * 16,driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskCMD AS BYTE  (xCMD AS STRING * 94,driveNum AS BYTE) STATIC SHARED
DECLARE SUB dskSafeKill (xFileName AS STRING * 16, driveNum AS BYTE) STATIC SHARED	

CONST TRUE  = 255 : CONST FALSE = 0

SHARED CONST DRIVE_1541 = 170 : SHARED CONST DRIVE_1541II = 76
SHARED CONST DRIVE_1581 = 108 : SHARED CONST DRIVE_1571 = 173
	
SHARED CONST FILE_TYPE_PRG = 130
SHARED CONST FILE_TYPE_SEQ = 129
SHARED CONST FILE_TYPE_USR = 131
SHARED CONST FILE_TYPE_REL = 132
SHARED CONST FILE_TYPE_CBM = 133 : REM 1581 DIR
SHARED CONST FILE_TYPE_DEL = 0


DIM xTMP$  AS STRING * 1 
DIM yTMP$  AS STRING * 1
DIM counter AS BYTE FAST
DIM track$  AS STRING * 2  
DIM sector$ AS STRING * 2  
DIM ecode$ AS STRING * 2  
DIM msg$    AS STRING * 30


REM -- https://en.wikipedia.org/wiki/Commodore_DOS

FUNCTION dskCMD AS BYTE  (xCMD AS STRING * 94,driveNum AS BYTE) STATIC SHARED	
	OPEN 9,driveNum,15, xCMD
	CLOSE 9
	RETURN dskStatusOK(driveNum)
END FUNCTION

FUNCTION dskFileCopy AS BYTE  (xOldFileName AS STRING * 16,xNewFileName AS STRING * 16,driveNum AS BYTE) STATIC SHARED
	REM -- PRINT dskFileCopy("oldfile1.prg","oldfile1-bak.prg",8)
	RETURN dskCMD("c0:" + xNewFileName + "=" + xOldFileName,driveNum)
END FUNCTION

FUNCTION dskFileRename AS BYTE  (xOldFileName AS STRING * 16,xNewFileName AS STRING * 16,driveNum AS BYTE) STATIC SHARED
	REM -- PRINT dskFileRename("oldfile.prg","newfile.prg",8)
	RETURN dskCMD("r0:" + xNewFileName + "=" + xOldFileName,driveNum)
END FUNCTION

FUNCTION dskInitialize  AS BYTE (driveNum AS BYTE) STATIC SHARED
	RETURN dskCMD("i0",driveNum)
END FUNCTION

FUNCTION dskValidate AS BYTE (driveNum AS BYTE) STATIC SHARED
	RETURN dskCMD("v0",driveNum)
END FUNCTION

FUNCTION dskCheckDisk AS BYTE (driveNum AS BYTE) STATIC SHARED
	RETURN dskValidate(driveNum)
END FUNCTION

FUNCTION dskRescan  AS BYTE (driveNum AS BYTE) STATIC SHARED
	RETURN dskInitialize(driveNum)
END FUNCTION

FUNCTION dskFormat AS BYTE (xDiskName AS STRING * 16, xDiskID AS STRING * 2, driveNum AS BYTE) STATIC SHARED
	REM -- full format
	RETURN dskCMD("n0:" + xDiskName + "," + xDiskID, driveNum)
END FUNCTION

FUNCTION dskFormatFast AS BYTE (xDiskName AS STRING * 16, driveNum AS BYTE) STATIC SHARED
	REM -- basicly just deletes all files
	RETURN dskCMD("n0:" + xDiskName,driveNum)
END FUNCTION
	
FUNCTION dskFileExists AS BYTE (xFileName AS STRING * 16, driveNum AS BYTE) STATIC SHARED
	OPEN 9,driveNum,9, "0:" + xFileName + ",s,r" : REM --- open file as SEQ
	CLOSE 9
	counter = CBYTE(VAL(LEFT$(dskStatus(driveNum),2))) : REM --- counter is just a dummy var
	IF counter =  0 THEN RETURN TRUE     : REM --- file  found
	IF counter = 62 THEN RETURN FALSE  : REM --- file not found
	IF counter = 64 THEN RETURN TRUE   : REM --- file found but not SEQ (file type mismatch)
	RETURN FALSE
END FUNCTION
		
FUNCTION dskFileDelete AS BYTE (xFileName AS STRING * 16, driveNum AS BYTE) STATIC SHARED
	OPEN 15,driveNum,15,"s0:" + xFileName 
	INPUT #15, ecode$, msg$, track$, sector$  : CLOSE 15
	RETURN CBYTE(VAL(track$)) : REM Track holds # of files deleted
END FUNCTION

SUB dskSafeKill (xFileName AS STRING * 16, driveNum AS BYTE) STATIC SHARED
	REM --- kill the file if it exists, return nothing, we do not care
	counter = dskFileDelete(xFileName,driveNum) 
END SUB

FUNCTION dskIsDriveAttatched AS BYTE (driveNum AS BYTE) STATIC SHARED
	REM --> tells you if a drive is on the IEC bus and powered on, not if it has a disk or is ready
	REM --> just that its there
	OPEN 101,driveNum,1 : CLOSE 101
	IF ST() = 128 THEN RETURN FALSE 
	RETURN TRUE
END FUNCTION

FUNCTION dskGetCurrentDriveInUse AS BYTE () STATIC SHARED
    RETURN PEEK(186)
END FUNCTION

FUNCTION dskStatusOK AS BYTE (driveNum AS BYTE) STATIC SHARED
	IF LEFT$(dskStatus(driveNum),2) = "00" THEN RETURN TRUE
	RETURN FALSE
END FUNCTION

FUNCTION dskStatus AS STRING * 96 (driveNum AS BYTE) STATIC SHARED
	OPEN 15, driveNum, 15
	INPUT #15, ecode$, msg$, track$, sector$ : CLOSE 15
	RETURN  ecode$ + "," +  msg$ +  "," + track$ + ","  +  sector$ 
END FUNCTION

FUNCTION dskDriveModelConst AS BYTE (driveNum AS BYTE) STATIC SHARED
    OPEN 15, driveNum, 15
    PRINT #15,"m-r" ; CHR$(51) ; CHR$(255)
    GET #15, xTMP$ 
    CLOSE 15
    RETURN ASC(xTMP$)
END FUNCTION 

FUNCTION dskDriveModel AS STRING * 4 (driveNum AS BYTE) STATIC SHARED
    DIM tt AS INT : tt = dskDriveModelConst(driveNum)
    IF tt = DRIVE_1581     THEN RETURN "1581"
    IF tt = DRIVE_1571     THEN RETURN "1571"
    IF tt = DRIVE_1541     THEN RETURN "1541"
    IF tt = DRIVE_1541II   THEN RETURN "41ii"
    RETURN "n/a"
END FUNCTION

FUNCTION dskBlocksFree AS INT (driveNum AS BYTE) STATIC SHARED
    OPEN 100,driveNum,0,"$u=u"
    FOR counter = 1 TO 35
        GET #100,xTMP$
    NEXT
    GET #100, yTMP$ : CLOSE 100
    RETURN ASC(xTMP$ + CHR$(0)) + 256 * ASC(yTMP$ + CHR$(0))
END FUNCTION


FUNCTION GetFileType AS STRING * 3 (fileTypeByte AS BYTE) STATIC SHARED

	IF fileTypeByte = FILE_TYPE_PRG  THEN RETURN "prg"
	IF fileTypeByte = FILE_TYPE_SEQ THEN RETURN "seq"
	IF fileTypeByte = FILE_TYPE_USR THEN RETURN "usr"
	IF fileTypeByte = FILE_TYPE_CBM THEN RETURN "dir"
	IF fileTypeByte = FILE_TYPE_REL  THEN RETURN "rel"
	IF fileTypeByte = FILE_TYPE_DEL THEN RETURN "del"
	
	REM -- should never get here
	RETURN STR$(fileTypeByte)
END FUNCTION
