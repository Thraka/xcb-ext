# xc-ext-file
Extension for XC=BASIC that handles IO routines. Compatible with XC=BASIC v2.2 or higher. [Click here to learn about XC=BASIC](https://xc-basic.net).

# Usage

Include the file `xcb-ext-joystick.bas` in the top of your program:

    include "path/to/xcb-ext-io.bas"
    
That's it, you can now use all the procedures, functions, and symbols defined by this extension. Avoid naming collisions by not defining symbols starting with `io_` in your program.

# Examples

Please refer to the file [examples/io_test.bas](examples/io_test.bas) for an example.
	
## Constants defined by this extension

	const JOY_PORT2 = $dc00
	const JOY_PORT1 = $dc01
	
## Commands defined by this extension

This extension does not define any commands.
	
## Functions defined by this extension

	joy_1_up!()
	
Returns 1 if the up switch in port one is active, 0 otherwise.

	joy_1_down!()
	
Returns 1 if the down switch in port one is active, 0 otherwise.

	joy_1_left!()
	
Returns 1 if the left switch in port one is active, 0 otherwise.

	joy_1_right!()
	
Returns 1 if the right switch in port one is active, 0 otherwise.

	joy_1_fire!()
	
Returns 1 if the fire button in port one is active, 0 otherwise.

	joy_2_up!()
	
Returns 1 if the up switch in port two is active, 0 otherwise.

	joy_2_down!()
	
Returns 1 if the down switch in port two is active, 0 otherwise.

	joy_2_left!()
	
Returns 1 if the left switch in port two is active, 0 otherwise.

	joy_2_right!()
	
Returns 1 if the right switch in port two is active, 0 otherwise.

	joy_2_fire!()
	
Returns 1 if the fire button in port two is active, 0 otherwise.

