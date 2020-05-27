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

###
