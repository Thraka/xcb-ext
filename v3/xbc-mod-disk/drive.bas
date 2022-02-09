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
