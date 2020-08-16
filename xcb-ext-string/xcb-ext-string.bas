rem ******************************
rem * String extensions
rem * by Thraka
rem * namespace: str_
rem * GitHub: https://github.com/Thraka/xcb-ext
rem * 
rem * version: 1.0 Aug 15, 2020
rem * - Initial release
rem ******************************

; This is a buffer for working with strings.
; For example, concat a string, this will happen in the buffer
; and then the result copied into the output.
;dim str_buffer![255]



rem ******************************
rem * Command:
rem * str_Concat2
rem * 
rem * Arguments:
rem * target$  - The destination buffer to store the result.
rem * param1$  - The first string to add to the buffer.
rem * param2$  - The second string to add to the buffer.
rem * 
rem * Summary:
rem * Concatenates two strings into a buffer string.
rem ******************************
proc str_Concat2(target$, param1$, param2$)

    let pointer$ = target$
    strcpy pointer$, param1$
    
    pointer$ = pointer$ + strlen!(pointer$)
    strcpy pointer$, param2$

endproc

rem ******************************
rem * Command:
rem * str_Concat3
rem * 
rem * Arguments:
rem * target$  - The destination buffer to store the result.
rem * param1$  - The first string to add to the buffer.
rem * param2$  - The second string to add to the buffer.
rem * param3$  - The second string to add to the buffer.
rem * 
rem * Summary:
rem * Concatenates three strings into a buffer string.
rem ******************************
proc str_Concat3(target$, param1$, param2$, param3$)

    let pointer$ = target$
    strcpy pointer$, param1$
    
    pointer$ = pointer$ + strlen!(pointer$)
    strcpy pointer$, param2$

    pointer$ = pointer$ + strlen!(pointer$)
    strcpy pointer$, param3$

endproc

rem ******************************
rem * Command:
rem * str_Concat4
rem * 
rem * Arguments:
rem * target$  - The destination buffer to store the result.
rem * param1$  - The first string to add to the buffer.
rem * param2$  - The second string to add to the buffer.
rem * param3$  - The second string to add to the buffer.
rem * param4$  - The second string to add to the buffer.
rem * 
rem * Summary:
rem * Concatenates four strings into a buffer string.
rem ******************************
proc str_Concat4(target$, param1$, param2$, param3$, param4$)

    let pointer$ = target$
    strcpy pointer$, param1$

    pointer$ = pointer$ + strlen!(pointer$)
    strcpy pointer$, param2$

    pointer$ = pointer$ + strlen!(pointer$)
    strcpy pointer$, param3$

    pointer$ = pointer$ + strlen!(pointer$)
    strcpy pointer$, param4$
endproc

rem ******************************
rem * Command:
rem * str_ByteToString
rem * 
rem * Arguments:
rem * num!     - The byte to convert to a string.
rem * target$  - The destination buffer to store the result.
rem * 
rem * Summary:
rem * Converts a byte into a string representation. For example,
rem * byte 21 will be added to the string as "21".
rem ******************************
proc str_ByteToString(num!, target$)
  asm "
    lda {self}.target
    sta R0
    lda {self}.target + 1
    sta R0 + 1
    lda {self}.num
;; .a contains byte to convert
    jsr STDLIB_BYTE_TO_PETSCII
;; after routine, the following is true:
;; .a = ones petscii
;; .x = tens petscii
;; .y = hundreds petscii
    pha             ; push a (ones) to stack
    txa             ; transfer x (tens) to a
    pha             ; push a (tens) to stack
    tya             ; transfer y (hundreds) to a
;; check_hundreds
    cmp #$30        ; compare a (hundreds) with petscii 0 character
    beq .check_tens ; if petscii 0, check tens
    ;; restore hundreds, tens, leave ones on stack
    tay             ; restore (hundreds) to y
    pla             ; pull (tens) from stack to a
    tax             ; restore (tens) to x
    jmp .hundreds   ; process normal
.check_tens
    pla             ; pull (tens) from stack to a
    cmp #$30        ; compare a (tens) with petscii 0 character
    beq .check_ones ; if petscii 0, check ones
    ;; restore tens, leave ones on stack
    tax             ; restore (tens) to x
    ldy #$00        ; load offset y with 0 for processing start
    jmp .tens       ; process tens and below
.check_ones
    ;; ones is setup and ready, configure y offset and go
    ldy #$00        ; load offset y with 0 for processing start
    jmp .ones       ; process ones
.hundreds
    tya             ; transfer y (hundreds) to a
    ldy #$00        ; load offset y with 0
    sta (R0),y      ; store a at string address + y (hundreds)
    iny             ; increase index y to next digit position
.tens
    txa             ; transfer x (tens) to a
    sta (R0),y      ; store a at string address + y (tens)
    iny             ; increase index y to next digit position
.ones
    pla             ; pull stack (ones) to a
    sta (R0),y      ; store a to string address + y (ones)
    lda #$00        ; load a with end-of-string 0
    iny             ; increase index y to end-of-string position
    sta (R0),y      ; store end-of-string 0
  "
endproc

rem ******************************
rem * Command:
rem * str_ByteToStringPadded
rem * 
rem * Arguments:
rem * num!     - The byte to convert to a string.
rem * target$  - The destination buffer to store the result.
rem * 
rem * Summary:
rem * Converts a byte into a string representation always using
rem * three characters for the byte, padding with 0 as needed.
rem * For example, byte 21 will be added to the string as "021".
rem ******************************
proc str_ByteToStringPadded(num!, target$)
    asm "
    lda {self}.target
    sta R0
    lda {self}.target + 1
    sta R0 + 1
    lda {self}.num
;; .a contains byte to convert
    jsr STDLIB_BYTE_TO_PETSCII
;; after routine, the following is true:
;; .a = ones petscii
;; .x = tens petscii
;; .y = hundreds petscii
    pha             ; push a (ones) to stack
.hundreds
    tya             ; transfer y (hundreds) to a
    ldy #$00        ; load offset y with 0
    sta (R0),y      ; store a at string address + y (hundreds)
.tens
    txa             ; transfer x (tens) to a
    iny             ; increase index y to next digit position
    sta (R0),y      ; store a at string address + y (tens)
.ones
    pla             ; pull stack (ones) to a
    iny             ; increase index y to next digit position
    sta (R0),y      ; store a to string address + y (ones)
    lda #$00        ; load a with end-of-string 0
    iny             ; increase index y to end-of-string position
    sta (R0),y      ; store end-of-string 0
    "
endproc

