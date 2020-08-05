include "xcb-ext-io.bas"

' Print to a file
io_OpenName 3,8,3,"output.text,s,w"
io_WriteString 3, "this is some text to print!{CR}"
io_Close 3
