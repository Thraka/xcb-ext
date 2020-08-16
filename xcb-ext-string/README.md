
Extension for XC=BASIC that provides helper methods for working with strings. Compatible with XC=BASIC v2.2 or higher. [Click here to learn about XC=BASIC](https://xc-basic.net).

_**Version: 1.0**_

## Usage

Include the file `xcb-ext-string.bas` in the top of your program:

```vb
include "path/to/xcb-ext-string.bas"
```

That's it, you can now use all the procedures, functions, and symbols defined by this extension. Avoid naming collisions by not defining symbols starting with `str_` in your program.

## Examples

None

## Constants

None

## Commands

| Command                                             | Summary                                                                    |
|-----------------------------------------------------|----------------------------------------------------------------------------|
| [`str_Concat2`](#str_Concat2)                       | Concatenates two strings into a buffer string.                             |
| [`str_Concat3`](#str_Concat3)                       | Concatenates three strings into a buffer string.                           |
| [`str_Concat4`](#str_Concat4)                       | Concatenates four strings into a buffer string.                            |
| [`str_ByteToString`](#str_ByteToString)             | Returns a string representation of a byte number.                          |
| [`str_ByteToStringPadded`](#str_ByteToStringPadded) | Returns a string representation of a byte number with padded 0 characters. |

---

### str_Concat2

**`str_Concat2(target$, param1$, param2$)`**

#### Arguments

| Argument  | Description                                 |
|-----------|---------------------------------------------|
| `target$` | The destination buffer to store the result. |
| `param1$` | The first string to add to the buffer.      |
| `param2$` | The second string to add to the buffer.     |

#### Summary

Concatenates two strings into a buffer string.

---

### str_Concat3

**`str_Concat3(target$, param1$, param2$, param3$)`**

#### Arguments

| Argument  | Description                                 |
|-----------|---------------------------------------------|
| `target$` | The destination buffer to store the result. |
| `param1$` | The first string to add to the buffer.      |
| `param2$` | The second string to add to the buffer.     |
| `param3$` | The third string to add to the buffer.      |

#### Summary

Concatenates three strings into a buffer string.

---

### str_Concat4

**`str_Concat4(target$, param1$, param2$, param3$, param4$)`**

#### Arguments

| Argument  | Description                                 |
|-----------|---------------------------------------------|
| `target$` | The destination buffer to store the result. |
| `param1$` | The first string to add to the buffer.      |
| `param2$` | The second string to add to the buffer.     |
| `param3$` | The third string to add to the buffer.      |
| `param3$` | The forth string to add to the buffer.      |

#### Summary

Concatenates four strings into a buffer string.

---

### str_ByteToString

**`str_ByteToString(num!, target$)`**

#### Arguments

| Argument  | Description                                 |
|-----------|---------------------------------------------|
| `num!`    | The byte to convert.                        |
| `target$` | The destination buffer to store the result. |

#### Summary

Converts a byte into a string representation. For example, byte 21 will be added to the string as "21".

---

### str_ByteToStringPadded

**`str_ByteToStringPadded(num!, target$)`**

#### Arguments

| Argument  | Description                                 |
|-----------|---------------------------------------------|
| `num!`    | The byte to convert.                        |
| `target$` | The destination buffer to store the result. |


#### Summary

Converts a byte into a string representation always using three characters for the byte, padding with 0 as needed. For example, byte 21 will be added to the string as "021".

---
