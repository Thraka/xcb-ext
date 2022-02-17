
INCLUDE "drive.bas"

PRINT "{CLR}{DOWN}"
PRINT "drive module testing"

REM ============================================
REM Testing expected name of disk
REM Functions tested:
REM   Disk_GetDiskName
REM ============================================

PRINT "{down}--------------------"
PRINT "type the name of the disk:"

DIM inputName AS STRING * 16
INPUT inputName

DIM diskName AS STRING * 16
diskName =  Disk_GetDiskName(8)

IF inputName = diskName THEN
    PRINT "pass"
ELSE
    PRINT "fail, name was "; diskName
END IF

REM ============================================
REM Checking blocks free count
REM Functions tested:
REM   Disk_GetBlocksFree
REM   dskBlocksFree
REM ============================================

DIM free1 AS INT: free1 = Disk_GetBlocksFree(8)
DIM free2 AS INT: free2 = dskBlocksFree(8)

PRINT "{down}--------------------"
PRINT "checking blocks free..."

IF free1 = free2 THEN
    PRINT "pass"
ELSE
    PRINT "fail, first count "; free1; " second count "; free2
END IF
