# Toshiba toughpad FZ-G1 mk3

Ive got Fedora 32 installed on this system.  The advice below may work on other distributions.


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



## Front facing buttons.

The front facing buttons on the toughpad mostly worked out of the box.  I had done 

### A1 and A2

Currently not working.  I bet its acpi related.


### Volume up and volume  down

Status: working

### Windows key

Status: working (Looks like its working.. not sure what it sends) 


#### Rotate key

Status: working (screen doesn't rotate, not sure what it sends) 

#### Power button

