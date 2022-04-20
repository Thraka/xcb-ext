REM ******************************************************************************************************
REM *    drive.bas   XC=BASIC Module V3.X 
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
REM *   Fixed dskIsDriveAttatched method                                                      JakeBullet  April-13-2022  Will this war ever end?
REM *   Updated filetype method                                                                        JakeBullet  April-20-2022  No meds in the city
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

SHARED CONST FILE_TYPE_CBM = $85 : REM 1581 DIR / Partition
'$A4 : REM ---      Relative @ replacement    Cannot occur
SHARED CONST FILE_TYPE_DEL_LOCKED = $C0 : REM ---      Locked deleted            DEL<
SHARED CONST FILE_TYPE_SEQ_LOCKED = $C1 : REM ---      Locked sequential         SEQ<
SHARED CONST FILE_TYPE_PRG_LOCKED = $C2 : REM ---      Locked program            PRG<
SHARED CONST FILE_TYPE_USR_LOCKED = $C3 : REM ---      Locked user               USR<
SHARED CONST FILE_TYPE_REL_LOCKED = $C4 : REM ---      Locked relative           REL<
SHARED CONST FILE_TYPE_SCRATCHED = $00 : REM ---      Scratched 
SHARED CONST FILE_TYPE_DEL = $80 : REM ---      Deleted                   DEL
SHARED CONST FILE_TYPE_SEQ = $81 : REM ---      Sequential            SEQ
SHARED CONST FILE_TYPE_PRG = $82 : REM ---      Program                   PRG
SHARED CONST FILE_TYPE_USR = $83 : REM ---      User                      USR
SHARED CONST FILE_TYPE_REL = $84 : REM ---      Relative                  REL
SHARED CONST FILE_TYPE_DEL_REPLACED = $A0 : REM ---      Deleted @ replacement     DEL
SHARED CONST FILE_TYPE_SEQ_REPLACED = $A1 : REM ---      Sequential @ replacement  SEQ
SHARED CONST FILE_TYPE_PRG_REPLACED = $A2 : REM ---      Program @ replacement     PRG
SHARED CONST FILE_TYPE_USR_REPLACED = $A3 : REM ---      User @ replacement        USR
'$04 : REM ---      Unclosed relative         Cannot occur
SHARED CONST FILE_TYPE_SEQ_SPLAT = $01 : REM ---      Unclosed sequential       *SEQ
SHARED CONST FILE_TYPE_PRG_SPLAT = $02 : REM ---      Unclosed program          *PRG
SHARED CONST FILE_TYPE_USR_SPLAT = $03 : REM ---      Unclosed user             *USR

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


FUNCTION GetFileType AS STRING * 4 (fileTypeByte AS BYTE) STATIC SHARED

	IF fileTypeByte = FILE_TYPE_PRG OR fileTypeByte = FILE_TYPE_PRG_REPLACED  THEN RETURN "prg"
	IF fileTypeByte = FILE_TYPE_SEQ OR fileTypeByte = FILE_TYPE_SEQ_REPLACED THEN RETURN "seq"
	IF fileTypeByte = FILE_TYPE_USR OR fileTypeByte = FILE_TYPE_USR_REPLACED THEN RETURN "usr"
	IF fileTypeByte = FILE_TYPE_SCRATCHED OR fileTypeByte = FILE_TYPE_DEL OR fileTypeByte = FILE_TYPE_DEL_REPLACED THEN RETURN "del"
	
	IF fileTypeByte = FILE_TYPE_SEQ_SPLAT THEN RETURN "seq*"
	IF fileTypeByte = FILE_TYPE_PRG_SPLAT  THEN RETURN "prg*"
	IF fileTypeByte = FILE_TYPE_USR_SPLAT THEN RETURN "usr*"
	
	IF fileTypeByte = FILE_TYPE_CBM THEN RETURN "par" : REM - dir / partition
	IF fileTypeByte = FILE_TYPE_REL  THEN RETURN "rel"
	 
	IF fileTypeByte = FILE_TYPE_SEQ_LOCKED THEN RETURN "seq<"
	IF fileTypeByte = FILE_TYPE_PRG_LOCKED  THEN RETURN "prg<"
	IF fileTypeByte = FILE_TYPE_USR_LOCKED THEN RETURN "usr<"
	IF fileTypeByte = FILE_TYPE_REL_LOCKED  THEN RETURN "rel<"
	IF fileTypeByte = FILE_TYPE_DEL_LOCKED  THEN RETURN "del<"
	
	REM -- should never get here
	'CALL debugOutVice( "splat file" + str$(fileTypeByte ) )
	RETURN STR$(fileTypeByte)
END FUNCTION

SUB dskPrintFiles(device AS BYTE) STATIC SHARED

    CONST INVERTED_SPACE = 160
    CONST NAME_MAX_LENGTH = 16
    
    DIM dead AS BYTE
    DIM index as BYTE
    DIM value AS BYTE

	dim BlocksUsed as int  
	dim BlocksUsedLo as byte
	dim BlocksUsedHi as byte
	DIM BlocksCounter AS BYTE FAST

    DIM dirTrack AS BYTE: dirTrack = 18
    DIM dirSector AS BYTE: dirSector = 1
    
    DIM fileName AS STRING * 16
    DIM fileTrack AS BYTE
    DIM fileSector AS BYTE
    DIM fileType AS BYTE
    DIM fileEntryNameBytePointer AS BYTE

    IF dskDriveModelConst(device) = DRIVE_1581 THEN dirTrack = 40

    REM Open command channel 15 followed by data channel 2
    OPEN 15, device, 15
    OPEN 2, device, 2, "#"

    REM To support multiple devices, we should read the first two bytes of the main track, this
    REM indicates where the directory is located. Generally a 1541 should point to 18 1 and a 
    REM 1581 should point to 40 1
    PRINT #15, "u1 2 0 " ; dirTrack ; " 0"
    READ #2, dirTrack, dirSector

    PRINT #15, "u1 2 0 " ; dirTrack ; " " ; dirSector

    REM start at end of DO which reads the bytes to indicate the "next" block of directory entries
    REM in this case, it's the first block of directories and obtains the next set of entries, if any.
    GOTO readtrack

    DO

        REM the byte of the start of a file entry
        fileEntryNameBytePointer = 2

        REM cycle files in block
        FOR counter = 0 to 7

            REM set pointer
            fileEntryNameBytePointer = fileEntryNameBytePointer + counter * 32

            REM move to the start position of this file entry
            PRINT #15, "b-p 2 "; fileEntryNameBytePointer

            REM read first 3 bytes of dir entry, if 00 (DEL file) and 00,00 there is no file here, move on
            READ #2, fileType, fileTrack, fileSector

            REM if there is no data for this directory entry, move to next
            'IF fileType = 0 AND fileTrack = 0 AND fileSector = 0 THEN CONTINUE FOR
            IF fileType = 0 THEN 	CONTINUE FOR

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
            
            REM -- block size of file
            BlocksUsed = 0
            BlocksUsedLo = 0
            BlocksUsedHi = 0
            FOR BlocksCounter = index  TO 24
				GET #2, dead
            NEXT
            GET #2, BlocksUsedLo 
            GET #2, BlocksUsedHi 
            BlocksUsed = (BlocksUsedHi * 256)  +  (BlocksUsedLo  MOD 256)
            
            REM set file name actual buffer size and print
            POKE @fileName, index - 1
            'print "-------" ; "lo:" ; (BlocksUsedLo) ; "   hi:" ; (BlocksUsedHi ) 
            PRINT BlocksUsed ; "   "  ; fileName ; "." ; GetFileType(fileType) 
            'print "----------------------------------------"

        NEXT counter

        REM no more directory blocks to read
        IF dirTrack = 0 AND dirSector = $FF THEN EXIT DO

        readtrack:
        PRINT #15, "u1 2 0 " ; dirTrack ; " " ; dirSector
        REM PRINT #15, "u1 2 0 " , dirTrack , dirSector
        PRINT #15, "b-p 2 0"
    
        REM read the next track/sector for directory
        READ #2, dirTrack, dirSector

    LOOP

    CLOSE 2
    CLOSE 15

END SUB
