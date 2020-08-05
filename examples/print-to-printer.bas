include "xcb-ext-io.bas"

' print a string to the printer
io_Open 4, 4, 0
io_WriteString 4, "1. this is output from xc=basic!!{CR}"
io_WriteString 4, "2. this is output from xc=basic!!{CR}"
io_Close 4
