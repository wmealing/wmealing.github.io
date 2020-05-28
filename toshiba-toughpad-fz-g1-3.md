# Toshiba toughpad FZ-G1 mk3

Ive got Fedora 32 installed on this system.  The advice below may work on other distributions.  I'd be happy to do more of these if anyone wanted to throw their a few toughpads my way.


## Brightness:

The brightness controls in gnome 3 / Fedora 32 do not work out of the box.  These instructions have also been tested on Red Hat Enterprise Linux 8.

You need to create file /usr/share/X11/xorg.conf.d/20-intel.conf and place this in file:

```shell
Section "Device"
            Identifier  "card0"
            Driver      "intel"
            Option      "Backlight"  "intel_backlight"
            BusID       "PCI:0:2:0"
EndSection
```

This will create an additional backlight directory in /sys/class/backlight .  At this point you might find there are two possible backlights, 'panasonic' and 'intel_backlight'

The nexts step was to blacklist the 'panasonic_laptop' kernel module.  This ensured that the gnome 3 brightness/contrast functionality would find ONLY the intel_backlight backlight controls and work correctly.

I achieved this by creating a file in /etc/modprobe.d/panasonic-backlist.conf

```shell
blacklist panasonic_laptop
```

If you want these changes to take effect immediately run the command

```shell
rmmod panasonic_laptop
```

And restart the X session by logging in and out.

There should only be a single directory in /sys/class/backlight and the gnome brightness controls should work correctly.


## DOCK PINOUT

I'm interested in building a dock for this laptop.  There are a lot of docks availabe for it, some as expensive as 1.5k, which are well beyond the acceptable price range that I'm willing to pay for a dock.

I'm going to do some research on the systems pins, and then find out what I can build that will be a suitable dock.

```text
| PIN |         | Description         |
|-----+---------+---------------------+
|  01 | Shield  |                     |
|  02 |         |                     |
|  03 |         |                     |
|  04 | GRND    |                     |
|  05 | 16V     | Supply (for dock ?) |
|  06 | 16V     |                     |
|  07 | 16V     |                     |
|  08 | 5V      | Supply for usb ?    |
|  09 | 5V      |                     |
|  10 | 5V      |                     |
|  11 | GRND    |                     |
|  12 | D-      | USB D-              |
|  13 | D+      | USB D+              |
|  14 | GRND    |                     |
|  15 | TX+     | ETHERNET TX+        |
|  16 | TX-     | ETHERNET TX-        |
|  17 | GRND    |                     |
|  18 | RX +    | ETHERNET RX+        |
|  19 | RX-     | ETHERNET RX-        |
|  20 | GRND    |                     |
|  21 |         |                     |
|  22 | SHORT ? |                     |
|  23 |         |                     |
|  24 |         |                     |
|-----|---------|---------------------|
```
All of these are unconfirmed, please leave me a note if you can confirm any of these.

From what I read the MK1 to MK3 have the same pinout.

I have to assume that the system can also be charged through the dock, I just dont know what pins.

## Front facing buttons.

The front facing buttons on the toughpad mostly worked out of the box.  I had done 

### A1 and A2

Currently not working. I've started [chronicaling my investigation](./toughpad-fz-g1-buttons-acpi.md).

### Volume up and volume  down

Status: working

### Windows key

Status: working (Looks like its working.. not sure what it sends) 


#### Rotate key

Status: working (screen doesn't rotate, not sure what it sends) 

#### Power button

Status: working (This can power off system)
