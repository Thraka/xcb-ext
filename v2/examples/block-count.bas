include "xcb-ext-io.bas"

' Open file number 2 on device 8 on channel 2
' $ Loads track 18, the BAM + Directory
io_OpenName 2, 8, 2, "$"

dim bytes![4]

' Get the first two bytes and ignore them (they are disk format identifiers for 1541)
io_ReadBytes 2, @bytes!, 2

count = 0
i! = 1

' loop for 35 tracks, skip track 18 (the BAM)
repeat

    ' Read the 4 bytes, count of blocks free followed by 3 bytes of bit mapping
    io_ReadBytes 2, @bytes!, 4

    ' First byte is the amount of blocks free on the track
    count = count + bytes![0]

    ' Next track
    inc i!

    ' Skip track 18
    if i! = 18 then inc i!
    
until i! = 36

' Close the file
io_Close 2

print "blocks free: ", count
