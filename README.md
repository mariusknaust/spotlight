# spotlight
Windows 10 Spotlight Background images for Gnome

## Installation
### System-wide
* /usr/bin/spotlight.sh
* /usr/lib/systemd/user/spotlight.service
* /usr/lib/systemd/user/spotlight.timer
* /usr/share/applications/spotlight.desktop
### Local
* ~/.local/bin/spotlight.sh
* ~/.local/share/systemd/user/spotlight.service
* ~/.local/share/systemd/user/spotlight.timer
* ~/.local/share/applications/spotlight.desktop
### Dependencies
* wget
* jq
* sed
* glib2 (gnome)
* systemd

## Usage
Run `systemctl --user enable spotlight.timer` to get a new picture every day.

To trigger it manually you can either use the desktop entry by looking for _spotlight_ in your gnome application menu, run `spotlight.sh` in a terminal, or trigger the service manually with `systemctl --user start spotlight.service`.

Use the system log to get the past image descriptions, e.g. for the the current background `journalctl -t spotlight -n 1`.

## Configuration

Spotlight does not require particular configuration.

The default behavior of spotlight is to discard the previous image when it fetches a new one. This behavior can be alter from the command line:

 * -h shows a help message
 * -k keeps the previous image
 * -d stores the image into the given destination. Defaults to "$HOME/.local/share/backgrounds".

### Service

In order to modify the behavior of the service `systemctl edit --user spotlight.service` can be used to overwrite the program invocation:

```
[Service]
ExecStart=
ExecStart=/usr/bin/env bash spotlight.sh -k -d %h/Pictures/Spotlight
```

## Packages
### Arch Linux
[aur/spotlight](https://aur.archlinux.org/packages/spotlight/)
