REM ******************************************************************************************************
REM *    disk.bas   XC=BASIC Module V3.X 
REM *
REM *
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                     Jan-Feb 2022   
REM ******************************************************************************************************

DECLARE FUNCTION dskBlocksFree AS INT (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskDriveModel AS STRING * 4 (driveNum AS BYTE) STATIC SHARED 
DECLARE FUNCTION dskDriveModelConst AS BYTE (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskStatus AS STRING * 30 (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskStatusOK AS BYTE (driveNum AS BYTE) STATIC SHARED
DECLARE FUNCTION dskGetCurrentDriveInUse AS BYTE () STATIC SHARED

CONST TRUE  = 255 : CONST FALSE = 0

SHARED CONST DRIVE_1541 = 170 : SHARED CONST DRIVE_1541II = 76
SHARED CONST DRIVE_1581 = 108 : SHARED CONST DRIVE_1571 = 173

DIM x$ AS STRING * 1 : DIM y$ AS STRING * 1
DIM counter AS BYTE

REM ========== TESTING =======================
'PRINT STR$(dskBlocksFree(8))
'PRINT dskDriveModel(8)
'PRINT dskStatus(8)
'PRINT dskStatusOK(8)
'END
REM ===========================================

FUNCTION dskGetCurrentDriveInUse AS BYTE () STATIC SHARED
	RETURN PEEK(186)
END FUNCTION

FUNCTION dskStatusOK AS BYTE (driveNum AS BYTE) STATIC SHARED
	RETURN VAL(RIGHT$(dskStatus(driveNum),2)) = 0
END FUNCTION

FUNCTION dskStatus AS STRING * 30 (driveNum AS BYTE) STATIC SHARED
	DIM track$     AS STRING * 2 : DIM sector$   AS STRING * 2
	DIM ecode$    AS STRING * 2  : DIM msg$       AS STRING * 30
	OPEN 15, driveNum, 15, "i0"
	INPUT #15, ecode$, msg$, track$, sector$ : CLOSE 15
	RETURN  ecode$ +  msg$ : REM  +  " " + track$ + " " +  sector$ 
END FUNCTION

FUNCTION dskDriveModelConst AS BYTE (driveNum AS BYTE) STATIC SHARED
	OPEN 1, driveNum, 15
	PRINT #1,"m-r" ; CHR$(51) ; CHR$(255)
	GET #1, x$ : CLOSE 1
	RETURN ASC(x$)
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
		GET #100,x$
	NEXT
	GET #100, y$ : CLOSE 100
	RETURN ASC(x$ + CHR$(0)) + 256 * ASC(y$ + CHR$(0))
END FUNCTION

FUNCTION Disk_GetBlocksFree AS INT (device AS BYTE) STATIC SHARED

	REM Open command channel 15 followed by data channel 2
	OPEN 15, device, 15
    OPEN 2, device, 2, "#"

	REM BLOCK-READ with data channel 2 at track 18 sector 0
	REM BLOCK-POINTER moved to byte 4
    PRINT #15, "u1 2 0 18 0"
    PRINT #15, "b-p 2 4"

	DIM bamBlocksFree AS BYTE
	DIM dead AS BYTE

	Disk_GetBlocksFree = 0

	FOR counter AS BYTE = 1 TO 35
		IF counter = 18 THEN CONTINUE
		READ #2, bamBlocksFree, dead, dead, dead
		Disk_GetBlocksFree = Disk_GetBlocksFree + bamBlocksFree
	NEXT

	CLOSE 2
	CLOSE 15

END FUNCTION

FUNCTION Disk_GetDiskName AS STRING * 16 (device AS BYTE) STATIC SHARED

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
        POKE @Disk_GetDiskName + index, value

    LOOP UNTIL value = INVERTED_SPACE OR index = NAME_MAX_LENGTH

    CLOSE 2
    CLOSE 15

    REM set the size if the return string
    POKE @Disk_GetDiskName, index - 1

END FUNCTION
