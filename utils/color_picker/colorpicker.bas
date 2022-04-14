CONST TRUE  = 255 : CONST FALSE = 0
CONST C64 = 0 : rem CONST CMDR16 = 1

DIM SHARED MACHINE AS BYTE 
DIM SHARED gScrnWidth AS BYTE  
DIM SHARED gScrnHeight AS BYTE 

Include "colors.bas"  
Include "colors_types.bas"
Include "strings.bas"
Include "box.bas"
Include "screen.bas"
Include "menukeys.bas"
Include "colorutilsDS.bas"

CALL clrInit()        : REM --> set default colors
CALL clrSaveOld() : REM --> saves system color values	
GOSUB setMachineVars
REM ----------------------------------------------------
CALL clrSelector() : REM --> main code
REM ----------------------------------------------------
CALL clrRestoreOld() : REM --> restore system color values
POKE 53272, 21	: REM --> back to upper case (C64)
PRINT "{CLR}end program, have a nice day!"
END


setMachineVars:
	REM -- figure out what machine we are on  -- todo
	MACHINE = C64
	
	POKE 53272, 23  : REM --> Switch to lower case
	'POKE 650,64       : REM --> disable key repeat
	POKE 657,128 		: REM -- Disable SHIFT + Commodore key 

	IF MACHINE = c64 THEN
		gScrnWidth = 39 : gScrnHeight = 24
		POKE 55296, gColors.txtNormal     : REM --> 'POKE 646,     clr_txt_normal     		
		POKE 53280, gColors.border           : REM changes the border color 
		POKE 53281, gColors.background    : REM changes the background color.
		RETURN
	END IF

	RETURN

