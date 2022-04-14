REM ******************************************************************************************************
REM *    drive.bas   XC=BASIC Module V3.X 
REM *
REM *
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                           Jan-Feb 2022   
REM *   Added dskFileDelete method.                                                                JakeBullet   Mar 2022   Between artillery shells! Ukraine!
REM *   Added dskFileExists method.                                                                JakeBullet   Mar 2022   Watching people stand in line for bread...
REM *   Added dskFormat,dskFormatFast  method.                                          JakeBullet   Mar 2022   Quiet for the moment...
REM *   Added dskInitialize,dskValidate,dskFileRename,dskFileCopy,dskCMD  JakeBullet   Mar 2022   Watching RU AFV patrolling the streets
REM *   Updated for 1581: dskGetDiskName,dskPrintFiles                                 Thraka       Mar24-2022 Reading news... Don't read the news
REM *   Updated dskPrintFiles to include file size                                            JakeBullet   Mar-19-2022  Bombing in the distance...
REM *   Added dskSafeKill method                                                                    JakeBullet  April-7-2022  City still occupied.
REM *   Fixed dskFileExists method                                                                   JakeBullet  April-8-2022  City still occupied. 2 weeks of medication left
REM *   Removed dskPrintFiles to its own file - Dir.bas                                      JakeBullet  April-9-2022   Bombing all night, last night
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

DIM xTMP$  AS STRING * 1 
DIM yTMP$  AS STRING * 1
DIM counter AS BYTE FAST
DIM track$  AS STRING * 2  
DIM sector$ AS STRING * 2  
DIM ecode$ AS STRING * 2  
DIM msg$    AS STRING * 30


REM ========== TESTING =======================
'PRINT STR$(dskBlocksFree(8))
'PRINT dskDriveModel(8)
'PRINT dskStatus(8)
'PRINT dskStatusOK(8)
'END
REM ===========================================

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
	ON ERROR GOTO errOut
	OPEN 101,driveNum,1 : CLOSE 101
	'IF ST() THEN RETURN FALSE : REM --> c64 basic ONLY
	RETURN TRUE
errOut:
	RETURN FALSE
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

REM FUNCTION dskGetBlocksFree AS INT (device AS BYTE) STATIC SHARED
REM 
REM     REM Open command channel 15 followed by data channel 2
REM     OPEN 15, device, 15
REM     OPEN 2, device, 2, "#"
REM 
REM     REM BLOCK-READ with data channel 2 at track 18 sector 0
REM     REM BLOCK-POINTER moved to byte 4
REM     PRINT #15, "u1 2 0 18 0"
REM     PRINT #15, "b-p 2 4"
REM 
REM     DIM bamBlocksFree AS BYTE
REM     DIM dead AS BYTE
REM 
REM     dskGetBlocksFree = 0
REM 
REM     FOR counter AS BYTE = 1 TO 35
REM         IF counter = 18 THEN CONTINUE FOR
REM         READ #2, bamBlocksFree, dead, dead, dead
REM         dskGetBlocksFree = dskGetBlocksFree + bamBlocksFree
REM     NEXT
REM 
REM     CLOSE 2
REM     CLOSE 15
REM 
REM END FUNCTION

FUNCTION dskGetDiskName AS STRING * 16 (device AS BYTE) STATIC SHARED

    CONST INVERTED_SPACE = 160
    CONST NAME_MAX_LENGTH = 16

    REM Taken from page 108 of "the anatomy of the 1541"
    
    DIM driveType AS BYTE : driveType = dskDriveModelConst(device)

    REM Open command channel 15 followed by data channel 2
    OPEN 15, device, 15
    OPEN 2, device, 2, "#"

    IF driveType = DRIVE_1581 THEN
        REM BLOCK-READ with data channel 2 at track 40 sector 0
        REM BLOCK-POINTER moved to byte 4
        PRINT #15, "u1 2 0 40 0"
        PRINT #15, "b-p 2 4"
    ELSE
        REM BLOCK-READ with data channel 2 at track 18 sector 0
        REM BLOCK-POINTER moved to byte 144
        PRINT #15, "u1 2 0 18 0"
        PRINT #15, "b-p 2 144"
    END IF

    'DIM index AS BYTE : index = 0
    counter = 0
    DIM value AS BYTE

    DO

        counter = counter + 1

        REM read a string character and poke into the return string
        GET #2, value
        POKE @dskGetDiskName + counter, value

    LOOP UNTIL value = INVERTED_SPACE OR counter = NAME_MAX_LENGTH

    CLOSE 2
    CLOSE 15

    REM set the size if the return string
    POKE @dskGetDiskName, counter - 1

END FUNCTION

