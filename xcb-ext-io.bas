rem ******************************
rem * File IO extension
rem * by Thraka
rem * namespace: io_
rem * version: 1.0
rem ******************************

const KERNAL_SETLFS = $FFBA
const KERNAL_SETNAM = $FFBD
const KERNAL_OPEN   = $FFC0
const KERNAL_CLOSE  = $FFC3
const KERNAL_CHKIN  = $FFC6
const KERNAL_CHKOUT = $FFC9
const KERNAL_CLRCHN = $FFCC
const KERNAL_CHRIN  = $FFCF
const KERNAL_CHROUT = $FFD2
const KERNAL_LOAD   = $FFD5

rem ******************************
rem * Command:
rem * io_Open   
rem * 
rem * Arguments:
rem * logicalFile! - Logical file number.
rem * device!      - Device to open.
rem * channel!     - Secondary address.
rem * 
rem * Summary:
rem * Opens a logical file targeting the specified device and channel.
rem * Doesn't open a specific file.
rem * 
rem * Calls the kernal routines SETNAM, SETLFS, and OPEN.
rem ******************************

proc io_Open(logicalFile!, device!, channel!)
    asm "
    lda #0
    jsr _KERNAL_SETNAM
    lda {self}.logicalFile
    ldx {self}.device
    ldy {self}.channel
    jsr _KERNAL_SETLFS
    jsr _KERNAL_OPEN
    "
endproc

rem ******************************
rem * Command:
rem * io_OpenName
rem * 
rem * Arguments:
rem * logicalFile! - Logical file number.
rem * device!      - Device to open.
rem * channel!     - Secondary address.
rem * filename$    - The file name to open.
rem * 
rem * Summary:
rem * Opens a logical file targeting the specified device and channel.
rem * Sends the file name to the device to open.
rem * 
rem * Calls the kernal routines SETNAM, SETLFS, and OPEN.
rem ******************************

proc io_OpenName(logicalFile!, device!, channel!, filename$)
    length! = strlen!(filename$)
    asm "
    lda {self}.length
    ldx {self}.filename
    ldy {self}.filename+1
    jsr _KERNAL_SETNAM
    lda {self}.logicalFile
    ldx {self}.device
    ldy {self}.channel
    jsr _KERNAL_SETLFS
    clc
    jsr _KERNAL_OPEN

    ;bcs .error
;.error
    ;investigate READST from kernal
    ;kernal print error
    ; Value of A:
    ;$05 device not present
    ;$04 file not found
    ;$1D load error
    ;$00 break run/stop pressed during loading
    "
endproc

rem ******************************
rem * Command:
rem * io_Close
rem * 
rem * Arguments:
rem * logicalFile! - Logical file number.
rem * 
rem * Summary:
rem * Closes a logical file that has been opened with either
rem * io_Open or io_OpenName.
rem * 
rem * Calls the kernal routine CLOSE.
rem ******************************

proc io_Close(logicalFile!)
    asm "
    lda {self}.logicalFile
    jsr _KERNAL_CLOSE
    "
endproc

'proc io_WriteByte(logicalFile!)
'
'endproc
'
'proc io_WriteBytes(logicalFile!)
'
'endproc
'
rem ******************************
rem * Command:
rem * io_ReadByte
rem * 
rem * Arguments:
rem * logicalFile!  - Logical file number.
rem * 
rem * Returns:
rem * The byte read from the logical file.
rem * 
rem * Summary:
rem * Reads a byte from a logical file that has been opened
rem * with either io_Open or io_OpenName.
rem * 
rem * Calls the kernal routines CHKIN, CHRIN, and CLRCHN.
rem ******************************

fun io_ReadByte!(logicalFile!)
    let result! = 0
    asm "
    ldx {self}.logicalFile
    jsr _KERNAL_CHKIN
    ;readst
    jsr _KERNAL_CHRIN
    sta {self}.result
    ;readst
    jsr _KERNAL_CLRCHN
    "
    return result!
endfun

rem ******************************
rem * Command:
rem * io_ReadBytes
rem * 
rem * Arguments:
rem * logicalFile!  - Logical file number.
rem * bufferAddress - The address of a byte array.
rem * byteCount!    - The count of bytes to read.
rem * 
rem * Summary:
rem * Reads the total bytes specified by the byteCount!
rem * parameter and stores them in the byte array specified by
rem * the bufferAddress parameter.
rem * 
rem * Operates on a logical file that has been opened
rem * with either io_Open or io_OpenName.
rem * 
rem * Calls the kernal routines CHKIN, CHRIN, and CLRCHN.
rem ******************************

proc io_ReadBytes(logicalFile!, bufferAddress, byteCount!)
    asm "
    ldx {self}.logicalFile
    jsr _KERNAL_CHKIN
    ;readst
    ldy #$00
    lda {self}.bufferAddress
    sta .buff+1
    lda {self}.bufferAddress+1
    sta .buff+2
.start
    jsr _KERNAL_CHRIN
.buff
    sta {self}.bufferAddress,Y
    ;readst
    iny
    cpy {self}.byteCount
    bne .start
    jsr _KERNAL_CLRCHN
    "
endproc

rem ******************************
rem * Command:
rem * io_WriteString
rem * 
rem * Arguments:
rem * logicalFile! - Logical file number.
rem * text$        - The string to print to the logical file.
rem * 
rem * Summary:
rem * Writes the string prived to the logical file that has been
rem * opened with either io_Open or io_OpenName.
rem * 
rem * Calls the kernal routines CHKOUT, CHROUT, and CLRCHN.
rem ******************************

proc io_WriteString(logicalFile!, text$)
    asm "
    ldx {self}.logicalFile
    jsr _KERNAL_CHKOUT
    ;readst
    ldy #$00
    lda {self}.text
    sta .buff+1
    lda {self}.text+1
    sta .buff+2
.start
.buff
    lda {self}.text,Y
    beq .end
    jsr _KERNAL_CHROUT
    ;readst
    iny
    jmp .start
.end
    jsr _KERNAL_CLRCHN
    "
endproc
