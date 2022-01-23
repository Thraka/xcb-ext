rem ******************************
rem * File IO extension
rem * by Thraka
rem * namespace: io_
rem * GitHub: https://github.com/Thraka/xcb-ext-io
rem *
rem * version: 1.1 Aug 6, 2020
rem * - Added io_WriteByte and io_WriteBytes
rem *
rem * version: 1.0 Aug 4, 2020
rem * - Initial release
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
const KERNAL_READST = $FE07

proc io_PrintError
    asm "
    pha
    jsr _KERNAL_CLRCHN
    pla
    cmp #$02
    beq .error_file_open
    cmp #$03
    beq .error_file_not_open
    cmp #$05
    beq .error_device_not_ready
    jmp .error_unknown
.error_file_open
    lda #<.string_error_file_already_open
    pha
    lda #>.string_error_file_already_open
    pha
    jmp RUNTIME_ERROR
.error_file_not_open
    lda #<.string_error_file_not_open
    pha
    lda #>.string_error_file_not_open
    pha
    jmp RUNTIME_ERROR
.error_device_not_ready
    lda #<.string_error_device_not_ready
    pha
    lda #>.string_error_device_not_ready
    pha
    jmp RUNTIME_ERROR
.error_unknown
    sta .string_error_unknown+13
    lda #<.string_error_unknown
    pha
    lda #>.string_error_unknown
    pha
    jmp RUNTIME_ERROR
.string_error_file_already_open     HEX 45 52 52 3A 20 46 49 4C 45 20 4F 50 45 4E 00
.string_error_file_not_open         HEX 45 52 52 3A 20 46 49 4C 45 20 4E 4F 54 20 4F 50 45 4E 00
.string_error_device_not_ready      HEX 45 52 52 3A 20 44 45 56 49 43 45 20 4D 49 53 53 49 4E 47 00
.string_error_unknown               HEX 45 52 52 3A 20 55 4E 4B 4E 4F 57 4E 20 20 00
    "
endproc

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
    bcs .error
    jmp .end
.error
    jmp _Pio_PrintError
.end
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
    jsr _KERNAL_OPEN
    bcs .error
    jmp .end
.error
    jmp _Pio_PrintError
.end
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
    jsr _KERNAL_CLRCHN
    ldx {self}.logicalFile
    jsr _KERNAL_CHKIN
    bcs .error
    jsr _KERNAL_CHRIN
    ; - do readst 
    ; - destroys A so that needs to be saved
    ; - if A is 00 then all is good
    ; - restore A 
    tax
    jsr _KERNAL_READST
    cmp #$00
    bne .error
    stx {self}.result
    jsr _KERNAL_CLRCHN
    jmp .end
.error
    jmp _Pio_PrintError
.end
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
rem * io_WriteByte
rem * 
rem * Arguments:
rem * logicalFile!  - Logical file number.
rem * byte!         - The byte to write.
rem * 
rem * Summary:
rem * Writes the specified byte to a logical file that has been opened
rem * with either io_Open or io_OpenName.
rem * 
rem * Calls the kernal routines CHKOUT, CHROUT, and CLRCHN.
rem ******************************

proc io_WriteByte(logicalFile!, byte!)
    asm "
    ldx {self}.logicalFile
    jsr _KERNAL_CHKOUT
    ;readst
    lda {self}.byte
    jsr _KERNAL_CHROUT
    ;readst
    jsr _KERNAL_CLRCHN
    "
endproc

rem ******************************
rem * Command:
rem * io_WriteBytes
rem * 
rem * Arguments:
rem * logicalFile!  - Logical file number.
rem * bufferAddress - The address of a byte array.
rem * byteCount!    - The count of bytes to write.
rem * 
rem * Summary:
rem * Writes the total bytes specified by the byteCount!
rem * parameter to the logical file.
rem * 
rem * The bufferAddress parameter is the address of the byte
rem * array to store.
rem * 
rem * Calls the kernal routines CHKOUT, CHROUT, and CLRCHN.
rem ******************************

proc io_WriteBytes(logicalFile!, bufferAddress, byteCount!)
    asm "
    ldx {self}.logicalFile
    jsr _KERNAL_CHKOUT
    ;readst
    ldy #$00
    lda {self}.bufferAddress
    sta .buff+1
    lda {self}.bufferAddress+1
    sta .buff+2
.start
.buff
    lda {self}.bufferAddress,Y
    jsr _KERNAL_CHROUT
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
