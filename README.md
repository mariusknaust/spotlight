# spotlight
Windows 10 Spotlight Background images for Gnome

## Installation
System-wide:
```
/usr/bin/spotlight.sh
/usr/lib/systemd/user/spotlight.service
/usr/lib/systemd/user/spotlight.timer
/usr/share/applications/spotlight.desktop
```
Local:
```
~/.local/bin/spotlight.sh
~/.local/share/systemd/user/spotlight.service
~/.local/share/systemd/user/spotlight.timer
~/.local/share/applications/spotlight.desktop
```

## Usage
Run `systemctl --user enable spotlight.timer` to get a new picture every day

## Arch Linux
https://aur.archlinux.org/packages/spotlight/
