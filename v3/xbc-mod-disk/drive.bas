REM ******************************************************************************************************
REM *    drive.bas   XC=BASIC Module V3.X 
REM *
REM *
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                                            Jan-Feb 2022   
REM *   Added dskFileDelete method.                                                                                Mar 2022   Between artillery shells! Ukraine!
REM *   Added dskFileExists method.                                                                                 Mar 2022   Wathcing people stand in line for bread...
REM *   Added dskFormat,dskFormatFast  method.                                                            Mar 2022   Quiet for the moment...  
REM *   Added dskInitialize,dskValidate,dskFileRename,dskFileCopy,dskCMD  methods.   Mar 2022   Watching RU AFV patrolling the streets  
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
	RETURN dskCMD(xFileName + ",s,r",driveNum)
END FUNCTION
	
	
FUNCTION dskFileDelete AS BYTE (xFileName AS STRING * 16, driveNum AS BYTE) STATIC SHARED
	OPEN 15,driveNum,15,"s0:" + xFileName 
	INPUT #15, ecode$, msg$, track$, sector$  : CLOSE 15
	RETURN CBYTE(VAL(track$)) : REM Track holds # of files deleted
END FUNCTION


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
    IF tt = DRIVE_1541II  THEN RETURN "41ii"
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

FUNCTION dskGetBlocksFree AS INT (device AS BYTE) STATIC SHARED

    REM Open command channel 15 followed by data channel 2
    OPEN 15, device, 15
    OPEN 2, device, 2, "#"

    REM BLOCK-READ with data channel 2 at track 18 sector 0
    REM BLOCK-POINTER moved to byte 4
    PRINT #15, "u1 2 0 18 0"
    PRINT #15, "b-p 2 4"

    DIM bamBlocksFree AS BYTE
    DIM dead AS BYTE

    dskGetBlocksFree = 0

    FOR counter AS BYTE = 1 TO 35
        IF counter = 18 THEN CONTINUE FOR
        READ #2, bamBlocksFree, dead, dead, dead
        dskGetBlocksFree = dskGetBlocksFree + bamBlocksFree
    NEXT

    CLOSE 2
    CLOSE 15

END FUNCTION

FUNCTION dskGetDiskName AS STRING * 16 (device AS BYTE) STATIC SHARED

    CONST INVERTED_SPACE = 160
    CONST NAME_MAX_LENGTH = 16

    REM Taken from page 108 of "the anatomy of the 1541"
    
    REM Open command channel 15 followed by data channel 2
    OPEN 15, device, 15
    OPEN 2, device, 2, "#"

    REM BLOCK-READ with data channel 2 at track 18 sector 0
    REM BLOCK-POINTER moved to byte 144
    PRINT #15, "u1 2 0 18 0"
    PRINT #15, "b-p 2 144"

    DIM index AS BYTE : index = 0
    DIM value AS BYTE

    DO

        index = index + 1

        REM read a string character and poke into the return string
        GET #2, value
        POKE @dskGetDiskName + index, value

    LOOP UNTIL value = INVERTED_SPACE OR index = NAME_MAX_LENGTH

    CLOSE 2
    CLOSE 15

    REM set the size if the return string
    POKE @dskGetDiskName, index - 1

END FUNCTION

SUB dskPrintFiles(device AS BYTE) STATIC SHARED

    CONST INVERTED_SPACE = 160
    CONST NAME_MAX_LENGTH = 16

    REM Open command channel 15 followed by data channel 2
    OPEN 15, device, 15
    OPEN 2, device, 2, "#"

    DIM dead AS BYTE
    DIM index as BYTE
    DIM value AS BYTE

    DIM dirTrack AS BYTE: dirTrack = 18
    DIM dirSector AS BYTE: dirSector = 1
    
    DIM fileName AS STRING * 16
    DIM fileTrack AS BYTE
    DIM fileSector AS BYTE
    DIM fileType AS BYTE
    DIM fileEntryNameBytePointer AS BYTE

    REM start at end of DO which reads the bytes to indicate the "next" block of directory entries
    REM in this case, it's the first block of directories and obtains the next set of entries, if any.
    GOTO readtrack

    DO

        REM the byte of the start of a file entry
        fileEntryNameBytePointer = 2

        REM cycle files in block
        FOR counter AS BYTE = 0 to 7

            REM set pointer
            fileEntryNameBytePointer = fileEntryNameBytePointer + counter * 32

            REM move to the start position of this file entry
            PRINT #15, "b-p 2 "; fileEntryNameBytePointer

            REM read first 3 bytes of dir entry, if 00 (DEL file) and 00,00 there is no file here, move on
            READ #2, fileType, fileTrack, fileSector

            REM if there is no data for this directory entry, move to next
            IF fileType = 0 AND fileTrack = 0 AND fileSector = 0 THEN CONTINUE FOR 

            REM reset file name buffer
            index = 0
            value = 0

            POKE @fileName, 16

            DO

                index = index + 1

                REM read a string character and poke into the return string
                GET #2, value
                POKE @fileName + index, value

            LOOP UNTIL value = INVERTED_SPACE OR index = NAME_MAX_LENGTH

            REM set file name actual buffer size and print
            POKE @fileName, index
            PRINT fileName

        NEXT counter

        REM no more directory blocks to read
        IF dirTrack = 0 AND dirSector = $FF THEN EXIT DO

        readtrack:
        PRINT #15, "u1 2 0 " , dirTrack , dirSector
        PRINT #15, "b-p 2 0"
    
        REM read the next track/sector for directory
        READ #2, dirTrack, dirSector

    LOOP

    CLOSE 2
    CLOSE 15

END SUB
