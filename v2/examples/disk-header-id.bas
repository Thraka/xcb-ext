include "xcb-ext-io.bas"
include "xcb-ext-string.bas"

; uses file numbers 15 and 2, and channels 15 and 2, repsectively
fun io_FloppyGetName$(device!)

    dim diskName![17]
    let diskNameStr$ = @diskName!
    let index! = 0
    let char! = 0

    io_Open 15, device!, 15
    io_OpenName 2, device!, 2, "#"

    io_WriteString 15, "b-r 2 0 18 0"
    io_WriteString 15, "b-p 2 144"
    
    repeat

        diskName![index!] = io_ReadByte!(2)
        if diskName![index!] = 160 then goto exit_repeat

        inc index!

    until index! = 16

exit_repeat:
    diskName![index!] = 0

    io_Close 2
    io_Close 15

    return diskNameStr$

endfun

fun io_FloppyGetID$(device!)

    dim diskID![3]
    let diskIDStr$ = @diskID!
    let char! = 0

    io_Open 15, device!, 15
    io_OpenName 2, device!, 2, "#"

    io_WriteString 15, "b-r 2 0 18 0"
    io_WriteString 15, "b-p 2 162"
    
    diskID![0] = io_ReadByte!(2)
    diskID![1] = io_ReadByte!(2)
    diskID![2] = 0

    io_Close 2
    io_Close 15

    return diskIDStr$

endfun

print "disk name: ", io_FloppyGetName$(8)
print "disk id: ", io_FloppyGetID$(8)
