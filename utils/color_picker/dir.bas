REM ******************************************************************************************************
REM *    dir.bas   XC=BASIC Module V3.X 
REM *
REM *
REM *
REM *   (c)sadLogic and all of Humankind - Use as you see fit                           Apr 2022   
REM ******************************************************************************************************

DECLARE FUNCTION GetFileType AS STRING * 3 (fileTypeByte AS BYTE) STATIC
DECLARE SUB dskPrintFiles(device AS BYTE) STATIC SHARED
'Include "drive.bas"


FUNCTION GetFileType AS STRING * 3 (fileTypeByte AS BYTE) STATIC
	
	CONST FILE_TYPE_PRG = 130
    CONST FILE_TYPE_SEQ = 129
    CONST FILE_TYPE_USR = 131
    CONST FILE_TYPE_REL = 132
    CONST FILE_TYPE_CBM = 133 : REM 1581 DIR
    CONST FILE_TYPE_DEL = 0

	IF fileTypeByte = FILE_TYPE_PRG  THEN RETURN "prg"
	IF fileTypeByte = FILE_TYPE_SEQ THEN RETURN "seq"
	IF fileTypeByte = FILE_TYPE_USR THEN RETURN "usr"
	IF fileTypeByte = FILE_TYPE_CBM THEN RETURN "dir"
	IF fileTypeByte = FILE_TYPE_REL  THEN RETURN "rel"
	IF fileTypeByte = FILE_TYPE_DEL THEN RETURN "del"
	
	REM -- should never get here
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
    DIM counter AS BYTE
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
