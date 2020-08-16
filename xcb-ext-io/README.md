
Extension for XC=BASIC that handles I/O routines. Compatible with XC=BASIC v2.2 or higher. [Click here to learn about XC=BASIC](https://xc-basic.net).

_**Version: 1.1**_

> **NOTE**\
> This extension is not finished.

To do:

- [ ] Add error checking with READST.
- [x] Add `io_WriteByte`.
- [x] Add `io_WriteBytes`.

## Usage

Include the file `xcb-ext-io.bas` in the top of your program:

```vb
include "path/to/xcb-ext-io.bas"
```

That's it, you can now use all the procedures, functions, and symbols defined by this extension. Avoid naming collisions by not defining symbols starting with `io_` in your program.

## Examples

- **Read blocks free from the disk BAM**
  
  [examples\\block-count.bas](../examples/block-count.bas)

- **Print string to a file**
  
  [examples\\print-to-file.bas](../examples/print-to-file.bas)

- **Print string to printer**
  
  [examples\\print-to-printer.bas](../examples/print-to-printer.bas)

## Constants

```vb
const KERNAL_SETLFS = $FFBA
const KERNAL_SETNAM = $FFBD
const KERNAL_OPEN   = $FFC0
const KERNAL_CLOSE  = $FFC3
const KERNAL_CHKIN  = $FFC6
const KERNAL_CHKOUT = $FFC9
const KERNAL_CLRCHN = $FFCC
const KERNAL_CHRIN  = $FFCF
const KERNAL_CHROUT = $FFD2
const KERNAL_LOAD   = $FFD5
```

## Commands

| Command                             | Summary                                                 |
|-------------------------------------|---------------------------------------------------------|
| [`io_Open`](#io_Open)               | Opens a logical file.                                   |
| [`io_OpenName`](#io_OpenName)       | Opens a logical file and file name on the device.       |
| [`io_Close`](#io_Close)             | Closes a logical file.                                  |
| [`io_ReadByte`](#io_ReadByte)       | Reads a single byte from a logical file.                |
| [`io_ReadBytes`](#io_ReadBytes)     | Reads multiple bytes from a logical file into a buffer. |
| [`io_WriteByte`](#io_WriteByte)     | Writes a single byte to a logical file.                 |
| [`io_WriteBytes`](#io_WriteBytes)   | Writes multiple bytes from a buffer to a logical file.  |
| [`io_WriteString`](#io_WriteString) | Writes a string to the logical file that has been.      |

---

### io_Open

**`io_Open(logicalFile!, device!, channel!)`**

#### Arguments

| Argument       | Description          |
|----------------|----------------------|
| `logicalFile!` | Logical file number. |
| `device!`      | Device to open.      |
| `channel!`     | Secondary address.   |

#### Summary

Opens a logical file targeting the specified device and channel.
Doesn't open a specific file.

Calls the kernal routines `SETNAM`, `SETLFS`, and `OPEN`.

---

### io_OpenName

**`io_OpenName(logicalFile!, device!, channel!, filename$)`**

#### Arguments

| Argument       | Description            |
|----------------|------------------------|
| `logicalFile!` | Logical file number.   |
| `device!`      | Device to open.        |
| `channel!`     | Secondary address.     |
| `filename$`    | The file name to open. |

#### Summary

Opens a logical file targeting the specified device and channel.
Sends the file name to the device to open.

Calls the kernal routines SETNAM, SETLFS, and OPEN.

---

### io_Close

**`io_Close(logicalFile!)`**

#### Arguments

| Argument       | Description            |
|----------------|------------------------|
| `logicalFile!` | Logical file number.   |

#### Summary

Closes a logical file that has been opened with either
io_Open or io_OpenName.

Calls the kernal routine CLOSE.

---

### io_ReadByte

**`io_ReadByte!(logicalFile!)`**

#### Arguments

| Argument       | Description            |
|----------------|------------------------|
| `logicalFile!` | Logical file number.   |

#### Return

The byte read from the logical file.

#### Summary

Reads a byte from a logical file that has been opened
with either io_Open or io_OpenName.

Calls the kernal routines CHKIN, CHRIN, and CLRCHN.

---

### io_ReadBytes

**`io_ReadBytes(logicalFile!, bufferAddress, byteCount!)`**

#### Arguments

| Argument        | Description                  |
|-----------------|------------------------------|
| `logicalFile!`  | Logical file number.         |
| `bufferAddress` | The address of a byte array. |
| `byteCount!`    | The count of bytes to read.  |

#### Summary

Reads the total bytes specified by the byteCount!
parameter and stores them in the byte array specified by
the bufferAddress parameter.

Operates on a logical file that has been opened
with either io_Open or io_OpenName.

Calls the kernal routines CHKIN, CHRIN, and CLRCHN.

---

### io_WriteByte

**`io_WriteByte(logicalFile!, byte!)`**

#### Arguments

| Argument       | Description            |
|----------------|------------------------|
| `logicalFile!` | Logical file number.   |
| `byte!`        | The byte to write.   |

#### Summary

Writes the specified byte to a logical file that has been opened
with either io_Open or io_OpenName.

Calls the kernal routines CHKOUT, CHROUT, and CLRCHN.

---

### io_WriteBytes

**`io_WriteBytes(logicalFile!, bufferAddress, byteCount!)`**

#### Arguments

| Argument        | Description                  |
|-----------------|------------------------------|
| `logicalFile!`  | Logical file number.         |
| `bufferAddress` | The address of a byte array. |
| `byteCount!`    | The count of bytes to write. |

#### Summary

Writes the total bytes specified by the byteCount!
parameter to the logical file.

The bufferAddress parameter is the address of the byte
array to store.

Calls the kernal routines CHKOUT, CHROUT, and CLRCHN.

---

### io_WriteString

**`io_WriteString(logicalFile!, text$)`**

#### Arguments

| Argument       | Description                              |
|----------------|------------------------------------------|
| `logicalFile!` | Logical file number.                     |
| `text$`        | The string to print to the logical file. |

#### Summary

Writes a string to the logical file that has been
opened with either io_Open or io_OpenName.

Calls the kernal routines CHKOUT, CHROUT, and CLRCHN.

---
