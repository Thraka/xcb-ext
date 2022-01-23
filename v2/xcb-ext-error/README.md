
Extension for [XC=BASIC](https://github.com/neilsf/XC-BASIC/) that provides a way to test for errors and return an error string. Compatible with XC=BASIC v2.2 or higher. [Click here to learn about XC=BASIC](https://xc-basic.net).

_**Version: 1.0**_

## Usage

Include the file `xcb-ext-error.bas` in the top of your program:

```vb
include "path/to/xcb-ext-error.bas"
```

That's it, you can now use all the procedures, functions, and symbols defined by this extension. Avoid naming collisions by not defining symbols starting with `err_` in your program.

## Examples

None

## Constants

None

## Commands

| Command                       | Summary                                                                        |
|-------------------------------|--------------------------------------------------------------------------------|
| [`err_Throw`](#err_Throw)     | Prints a message and stops the program.                                        |
| [`err_ThrowIf`](#err_ThrowIf) | Prints a message and stops the program if the parameter passed doesn't equal 0 |

---

### err_Throw

**`err_Throw(message$)`**

#### Arguments

| Argument   | Description           |
|------------|-----------------------|
| `message$` | The message to print. |

#### Summary

Prints the message$ and stops the program.

---

### err_ThrowIf

**`err_ThrowIf(message$, nonzero!)`**

#### Arguments

| Argument   | Description           |
|------------|-----------------------|
| `message$` | The message to print. |
| `nonzero!` | The value to test.    |

#### Summary

If the nonzero! parameter is 0, this procedure does nothing. If the nonzero! parameter isn't 0, this procedure prints the message$ and stops the program.

---
