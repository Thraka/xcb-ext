rem ******************************
rem * Error extensions
rem * by Thraka
rem * namespace: err_
rem * GitHub: https://github.com/Thraka/xcb-ext
rem * 
rem * version: 1.0 Aug 15, 2020
rem * - Initial release
rem ******************************

rem ******************************
rem * Command:
rem * err_Throw
rem * 
rem * Arguments:
rem * message$  - The message to print.
rem * 
rem * Summary:
rem * Prints the message$ and stops the program.
rem ******************************
proc err_Throw(message$)
    asm"
    lda {self}.message
    pha
    lda {self}.message+1
    pha
    jmp RUNTIME_ERROR
    "
endproc

rem ******************************
rem * Command:
rem * err_ThrowIf
rem * 
rem * Arguments:
rem * message$  - The message to print.
rem * nonzero!  - A non-zero number to trigger the error
rem * 
rem * Summary:
rem * If the nonzero! parameter is 0, this procedure does nothing.
rem * If the nonzero! parameter isn't 0, this procedure prints
rem * the message$ and stops the program.
rem ******************************
proc err_ThrowIf(message$, nonzero!)
    asm"
    lda {self}.nonzero
    cmp #$00
    beq .end
    lda {self}.message
    pha
    lda {self}.message+1
    pha
    jmp RUNTIME_ERROR
.end
    "
endproc