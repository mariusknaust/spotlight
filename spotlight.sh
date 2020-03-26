#!/usr/bin/env bash

dataPath="${XDG_DATA_HOME:-$HOME/.local/share}/spotlight"
store=false

while getopts ":hp:s" opt; do
  case ${opt} in
    h ) echo "spotlight.sh - Windows 10 Spotlight Background images for Gnome"
        echo ""
        echo "Options:"
        echo "  -h shows this message"
        echo "  -p specifies a working path. Defaults to \"$HOME/.local/share/spotlight\""
        echo "  -s stores the images at path/archive/"
      ;;
    p ) dataPath=$OPTARG
      ;;
    s ) store=true
      ;;
    \? ) echo "Usage: spotlight.sh [-p working path] [-s save images]"
      ;;
  esac
done

function decodeURL
{
	printf "%b\n" "$(sed 's/+/ /g; s/%\([0-9A-F][0-9A-F]\)/\\x\1/g')"
}

response=$(wget -qO- "https://arc.msn.com/v3/Delivery/Cache?pid=279978&fmt=json&ua=WindowsShellClient&lc=en,en-US&ctry=US")
status=$?

if [ $status -ne 0 ]
then
	systemd-cat -t spotlight -p emerg <<< "Query failed"
	exit $status
fi

item=$(jq -r ".batchrsp.items[0].item" <<< $response)

landscapeUrl=$(jq -r ".ad.image_fullscreen_001_landscape.u" <<< $item)
sha256=$(jq -r ".ad.image_fullscreen_001_landscape.sha256" <<< $item | base64 -d | hexdump -ve "1/1 \"%.2x\"")
title=$(jq -r ".ad.title_text.tx" <<< $item)
searchTerms=$(jq -r ".ad.title_destination_url.u" <<< $item | perl -pe 's/.*?q=(.*?)&.*/\1/' | decodeURL)

mkdir -p "$dataPath"
img="$dataPath/current_background.jpg"

wget -qO "$img" "$landscapeUrl"
sha256calculated=$(sha256sum $img | cut -d " " -f 1)

if [ "$sha256" != "$sha256calculated" ]
then
	systemd-cat -t spotlight -p emerg <<< "Checksum incorrect"
	exit 1
fi

if [ "$save" = true ] 
then
        mkdir -p "$dataPath/archive"
	cp "$img" "$dataPath/archive/$(date +%Y%m%d) $title ($searchTerms).jpg"
fi

gsettings set "org.gnome.desktop.background" picture-options "zoom"
gsettings set "org.gnome.desktop.background" picture-uri "file://$img"

notify-send "Background changed" "$title ($searchTerms)" --icon=preferences-desktop-wallpaper --urgency=low #--hint=string:desktop-entry:spotlight
systemd-cat -t spotlight -p info <<< "Background changed to $title ($searchTerms)"
