CONST TRUE  = 255 : CONST FALSE = 0
Include "colors.bas"  
Include "strings.bas"
Include "box.bas"

PRINT "{CLR}"
CALL boxInit()

CALL boxDraw3d(3,2,32,4,COLOR_BLACK,COLOR_DARK_GRAY, TRUE)
TEXTAT 5,4, strCenterString("its a box! 3d",30),COLOR_WHITE

CALL boxDraw3d(3,8,32,4,COLOR_BLACK,COLOR_GRAY, TRUE,"box title 3d")
TEXTAT 5,10, strCenterString("its a box! 3d",30),COLOR_WHITE

CALL boxDraw(3,14,32,4,COLOR_PURPLE, TRUE)
TEXTAT 5,16, strCenterString("its a box!",30),COLOR_GREEN	

CALL boxDraw(3,20,32,4,COLOR_CYAN, TRUE,"box title")
TEXTAT 5,22, strCenterString("its a box!",30),COLOR_BLACK

DIM tmp AS BYTE
DO 
	GET tmp
LOOP UNTIL tmp > 0
END
