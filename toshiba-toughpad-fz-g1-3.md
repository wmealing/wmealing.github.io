# Toshiba toughpad FZ-G1 mk3

Ive got Fedora 32 installed on this system.  The advice below may work on other distributions.


## Brightness:

The brightness controls in gnome 3 / Fedora 32 do not work out of the box.

You need to create file /usr/share/X11/xorg.conf.d/20-intel.conf and place this in file:

Section "Device"
            Identifier  "card0"
            Driver      "intel"
            Option      "Backlight"  "intel_backlight"
            BusID       "PCI:0:2:0"
EndSection


Restart X11, or reboot the system for the changes to take effect.
