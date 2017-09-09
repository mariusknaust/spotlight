#! /bin/bash

items=$(wget -qO- "https://arc.msn.com/v3/Delivery/Cache?pid=279978&fmt=json&ua=WindowsShellClient&lc=en,en-US&ctry=US" | jq -r ".batchrsp.items")

function decodeURL
{
	printf "%b\n" "$(sed 's/+/ /g; s/%\([0-9A-F][0-9A-F]\)/\\x\1/g')"
}

function setImage
{
	index="$1"
	name="$2"

	item=$(jq -r ".[$index].item" <<< $items | perl -0pe 's/.*?adData = (.*?);.*/\1/s')

	landscapeUrl=$(jq -r ".ad.image_fullscreen_001_landscape.u" <<< $item)
	title=$(jq -r ".ad.title_text.tx" <<< $item)
	searchTerms=$(jq -r ".ad.title_destination_url.u" <<< $item | perl -pe 's/.*?q=(.*?)&.*/\1/' | decodeURL)

	path="$HOME/.spotlight/$name.jpg"

	wget -qO "$path" "$landscapeUrl"

	gsettings set "org.gnome.desktop.$name" picture-options "zoom"
	gsettings set "org.gnome.desktop.$name" picture-uri "file://$path"

	capitalName="$(tr '[:lower:]' '[:upper:]' <<< ${name:0:1})${name:1}"

	notify-send "$capitalName changed" "$title ($searchTerms)" --icon=preferences-desktop-wallpaper --urgency=low #--hint=string:desktop-entry:spotlight
	systemd-cat -t spotlight <<< "$capitalName changed to $title ($searchTerms)"
}

mkdir -p "$HOME/.spotlight"

setImage "0" "background"
setImage "1" "screensaver"
