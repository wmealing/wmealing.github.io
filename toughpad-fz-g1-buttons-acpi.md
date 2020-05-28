## FZ-G1-Mk3

## Purpose:

The A1 and A2 buttons on the panasonic toughpad FZ-G1-mk3 that I have don't work in Linux.  They are supposed to work and 
rumour has it that newer models have it working.  I'm documenting the path that explains the path that I have had to take
to get this working.

The purpose of this document is to ouline what I have learned about this process, with an intent that it may also help
someone else along their journey.  I plan to map my path to understanding how to get the buttons to work on this device and
all the steps that I have taken along the way.

### Enabling ACPI events

As per ( https://www.kernel.org/doc/Documentation/acpi/debug.txt ), it mentions that you must be booting a kernel
with CONFIG_ACPI_DEBUG=y enabled.  The standard fedora kernel does is not compiled with this parameter.

```
# dnf install kernel-debug
```

Reboot the system, and choose the debug kernel.


```
[wmealing@toughpad ~]$ uname -a
Linux toughpad.localdomain 5.6.14-300.fc32.x86_64+debug #1 SMP Wed May 20 20:26:12 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

When you're booting the right kernel, the acpi module should have this file created in sysfs.

```
/sys/module/acpi/parameters/debug_layer 
```

The kernel acpi debug.txt above mentions that there are different layers that you can 'enable' debugging of,
this is a 'button' so why not start there.

What is in that file:

```
[wmealing@toughpad parameters]$ cat debug_layer 
Description              	Hex        SET
ACPI_UTILITIES           	0x00000001 [ ]
ACPI_HARDWARE            	0x00000002 [ ]
ACPI_EVENTS              	0x00000004 [ ]
ACPI_TABLES              	0x00000008 [ ]
ACPI_NAMESPACE           	0x00000010 [ ]
ACPI_PARSER              	0x00000020 [ ]
ACPI_DISPATCHER          	0x00000040 [ ]
ACPI_EXECUTER            	0x00000080 [ ]
ACPI_RESOURCES           	0x00000100 [ ]
ACPI_CA_DEBUGGER         	0x00000200 [ ]
ACPI_OS_SERVICES         	0x00000400 [ ]
ACPI_CA_DISASSEMBLER     	0x00000800 [ ]
ACPI_COMPILER            	0x00001000 [ ]
ACPI_TOOLS               	0x00002000 [ ]
ACPI_BUS_COMPONENT       	0x00010000 [ ]
ACPI_AC_COMPONENT        	0x00020000 [ ]
ACPI_BATTERY_COMPONENT   	0x00040000 [ ]
ACPI_BUTTON_COMPONENT    	0x00080000 [ ]
ACPI_SBS_COMPONENT       	0x00100000 [ ]
ACPI_FAN_COMPONENT       	0x00200000 [ ]
ACPI_PCI_COMPONENT       	0x00400000 [ ]
ACPI_POWER_COMPONENT     	0x00800000 [ ]
ACPI_CONTAINER_COMPONENT 	0x01000000 [ ]
ACPI_SYSTEM_COMPONENT    	0x02000000 [ ]
ACPI_THERMAL_COMPONENT   	0x04000000 [ ]
ACPI_MEMORY_DEVICE_COMPONENT	0x08000000 [ ]
ACPI_VIDEO_COMPONENT     	0x10000000 [ ]
ACPI_PROCESSOR_COMPONENT 	0x20000000 [ ]
ACPI_ALL_DRIVERS         	0xFFFF0000 [ ]
--
debug_layer = 0x00000000 ( * = enabled)

```

Wow, thats kinda nice, a nice layout of the bitwise debugging.  Lets enable the button ( 0x00080000 )

```
# echo 0x00080000 > /sys/module/acpi/parameters/debug_layer 
# cat  /sys/module/acpi/parameters/debug_layer  |grep BUTTON
ACPI_BUTTON_COMPONENT    	0x00080000 [*]
```

The * implies that it is enabled.

Lets watch the logs... 

```
# journalctl -xef

```

And press the physical button. And no debugging events appear..  Ok, so I infer that perhaps this is the 'kernel' side of the handler code that we'd be looking at and there are no 'kernel' style events that are executing, now perhaps lets look at the ACPI.

The same debug.txt talks about "debug_level" file in the same module directory.

```
# cat /sys/module/acpi/parameters/debug_level 
Description              	Hex        SET
ACPI_LV_INIT             	0x00000001 [ ]
ACPI_LV_DEBUG_OBJECT     	0x00000002 [ ]
ACPI_LV_INFO             	0x00000004 [*]
ACPI_LV_REPAIR           	0x00000008 [*]
ACPI_LV_TRACE_POINT      	0x00000010 [ ]
ACPI_LV_INIT_NAMES       	0x00000020 [ ]
ACPI_LV_PARSE            	0x00000040 [ ]
ACPI_LV_LOAD             	0x00000080 [ ]
ACPI_LV_DISPATCH         	0x00000100 [ ]
ACPI_LV_EXEC             	0x00000200 [ ]
ACPI_LV_NAMES            	0x00000400 [ ]
ACPI_LV_OPREGION         	0x00000800 [ ]
ACPI_LV_BFIELD           	0x00001000 [ ]
ACPI_LV_TABLES           	0x00002000 [ ]
ACPI_LV_VALUES           	0x00004000 [ ]
ACPI_LV_OBJECTS          	0x00008000 [ ]
ACPI_LV_RESOURCES        	0x00010000 [ ]
ACPI_LV_USER_REQUESTS    	0x00020000 [ ]
ACPI_LV_PACKAGE          	0x00040000 [ ]
ACPI_LV_ALLOCATIONS      	0x00100000 [ ]
ACPI_LV_FUNCTIONS        	0x00200000 [ ]
ACPI_LV_OPTIMIZATIONS    	0x00400000 [ ]
ACPI_LV_MUTEX            	0x01000000 [ ]
ACPI_LV_THREADS          	0x02000000 [ ]
ACPI_LV_IO               	0x04000000 [ ]
ACPI_LV_INTERRUPTS       	0x08000000 [ ]
ACPI_LV_AML_DISASSEMBLE  	0x10000000 [ ]
ACPI_LV_VERBOSE_INFO     	0x20000000 [ ]
ACPI_LV_FULL_TABLES      	0x40000000 [ ]
ACPI_LV_EVENTS           	0x80000000 [ ]
--
debug_level = 0x0000000C (* = enabled)
```

By default there are a few, but from what I can see, there is nothing that happens with the current 'button press'.

So, I choose some values from the internet:

```
echo 0x8400082 > /sys/module/acpi/parameters/debug_layer
echo 0x31000200 > /sys/module/acpi/parameters/debug_level
```

Now when pressed the syste logs contain out a LOT of data.  This at least confirms my suspicion that this is an ACPI related device.  For the bulk of it , see here https://gist.github.com/wmealing/c050d23fd252667a2c420e2172bcefca .  I figured that a lot of that may be duplicated as it executes for 'up' and 'down' of the keypress.

This is an 'opcode' and execution dump of the ACPI tables.  I can't make much sense of this at the moment, however I think these might be important.

$ dmesg |grep Notify

[ 3161.313553]    exdump-0603 ex_dump_operand       : 0000000077ead245 Namespace Node:  0  HKEY Device       0000000077ead245 001 Notify Object: 0000000037c289c4

[ 3182.328379]    exdump-0603 ex_dump_operand       : 0000000077ead245 Namespace Node:  0  HKEY Device       0000000077ead245 001 Notify Object: 0000000037c289c4

[ 3205.726665]    exdump-0603 ex_dump_operand       : 0000000077ead245 Namespace Node:  0  HKEY Device       0000000077ead245 001 Notify Object: 0000000037c289c4

So, if i'm reading the spec ( https://www.intel.com/content/dam/www/public/us/en/documents/articles/acpi-config-power-interface-spec.pdf ) correctly, page 501.  It says that "Notify" is notifying the OS that the event has happened.

So.. the OS must be ignoring it.

But that doesn't help me, i am distracted.. I can't find out if there is supposed to be handler there, if something 'is supposed to get called'.




### ACPI tables

Grab the dstd from the system.

$ cat /sys/firmware/acpi/tables/DSDT >> /home/wmealing/DSTD

Maybe.. I see "HKEY" being mentioned in the in the debugging code above, this might be related

Decompile the code with the command.

$ iasl -d DSTD

In an attempt to figure out what the hell this is I came across:

```
    Scope (_SB) // system bus ?
    {
        Device (HKEY) //  hardware key
        {
            Name (_HID, EisaId ("MAT0019"))  // _HID: Hardware ID

            <SNIP>
            
            Method (HINF, 0, Serialized) // I'm guessing this is like a method in C++ speak ?
            {
                Acquire (HDMX, 0xFFFF)
                If ((HINP == HOUP)) // is this some kind of keyboard 'debounce' logic ?
                {
                    Local0 = Zero
                }
                Else
                {
                    Local0 = DerefOf (HDAT [HOUP])
                    HOUP++
                    HOUP %= 0x20
                }

                Local1 = (HINP != HOUP)
                Release (HDMX)
                If (Local1)
                {
                    Notify (HKEY, 0x80) // Status Change , and notify the os.
                }

                Return (Local0)
            }
            
            <SNIP>
            
     }
```

Unlike a real programming language, "Notify" isnt exacltly clear on what it does, i'm sure its clear to someone a lot more familiar with ACPI.  In this case I can immediately see a problem, that the APCI code in the toshiba-laptop code doesn't deal with this "EisaId ("MAT0019")". 

A simple test of just adding this to the list of supported drivers, recompiling , reloading the module did not prove fruitful.

TBC.

Resources:

https://lwn.net/Articles/367630/
https://www.slideshare.net/suselab/acpi-debugging-from-linux-kernel
https://gist.github.com/wmealing/c050d23fd252667a2c420e2172bcefca
https://www.kernel.org/doc/Documentation/acpi/debug.txt
https://wiki.ubuntu.com/Kernel/Reference/ACPITricksAndTips
https://github.com/torvalds/linux/blob/9331b6740f86163908de69f4008e434fe0c27691/drivers/platform/x86/panasonic-laptop.c
https://www.intel.com/content/dam/www/public/us/en/documents/articles/acpi-config-power-interface-spec.pdf
