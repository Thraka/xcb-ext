Include "colorsDS.bas"
Include "stringsDS.bas"
Include "menukeysDS.bas"
Include "menuscrollDS.bas"

PRINT "{CLR}"
'GOSUB MENUKEYS_TEST
GOSUB MENUSCROLL_TEST
END

MENUSCROLL_TEST:
	TEXTAT 14,8, "* test menu *",clrGRAY
	call  mnusInit(14,10, clrWHITE)
	call mnusAddItem("change colors","1")
	call mnusAddItem("set hot keys","2")
	call mnusAddItem("set data drive","3")
	call mnusAddItem("change level","4")
	call mnusAddItem("exit program","x")

	dim retkey as string * 1 : retkey = mnusGetKey()
	textat 0,20,"return key value: " + retkey
	RETURN

	
	
MENUKEYS_TEST:
	REM -----------------------------  
	call  mnuInit(14,10, clrWHITE, clrBLACK)
	call mnuAddItem("change disk","c")
	call mnuAddItem("format disk","f")
	call mnuAddItem("check   disk","e")
	call mnuAddItem("","")
	call mnuAddItem("exit program","x")

	dim key as byte : key = mnuGetKey()
	textat 0,20,"key pressed: " + LCASE$(CHR$(key))
	RETURN

