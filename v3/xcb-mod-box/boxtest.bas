CONST TRUE  = 255 : CONST FALSE = 0
Include "colors.bas"  
Include "strings.bas"
Include "box.bas"

PRINT "{CLR}"
CALL boxInit()

CALL boxDraw3d(3,2,32,4,clrBLACK,clrDARK_GRAY, TRUE)
TEXTAT 5,4, strCenterString("its a box! 3d",30),clrWHITE

CALL boxDraw3d(3,8,32,4,clrBLACK,clrGRAY, TRUE,"box title 3d")
TEXTAT 5,10, strCenterString("its a box! 3d",30),clrWHITE

CALL boxDraw(3,14,32,4,clrPURPLE, TRUE)
TEXTAT 5,16, strCenterString("its a box!",30),clrGREEN	

CALL boxDraw(3,20,32,4,clrCYAN, TRUE,"box title")
TEXTAT 5,22, strCenterString("its a box!",30),clrBLACK

DIM tmp AS BYTE
DO 
	GET tmp
LOOP UNTIL tmp > 0
END
