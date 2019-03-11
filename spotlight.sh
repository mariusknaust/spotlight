#!/usr/bin/env bash

dataPath="${XDG_DATA_HOME:-$HOME/.local/share}/spotlight"

function decodeURL
{
	printf "%b\n" "$(sed 's/+/ /g; s/%\([0-9A-F][0-9A-F]\)/\\x\1/g')"
}

function setImage
{
	local name="$1"

	response=$(wget -qO- "https://arc.msn.com/v3/Delivery/Cache?pid=279978&fmt=json&ua=WindowsShellClient&lc=en,en-US&ctry=US")
	status=$?

	if [ $status -ne 0 ]
	then
		systemd-cat -t spotlight -p emerg <<< "Query for $name failed"
		exit $status
	fi

	item=$(jq -r ".batchrsp.items[0].item" <<< $response)

	landscapeUrl=$(jq -r ".ad.image_fullscreen_001_landscape.u" <<< $item)
	sha256=$(jq -r ".ad.image_fullscreen_001_landscape.sha256" <<< $item | base64 -d | hexdump -ve "1/1 \"%.2x\"")
	title=$(jq -r ".ad.title_text.tx" <<< $item)
	searchTerms=$(jq -r ".ad.title_destination_url.u" <<< $item | perl -pe 's/.*?q=(.*?)&.*/\1/' | decodeURL)

	mkdir -p "$dataPath"
	path="$dataPath/$name.jpg"

	wget -qO "$path" "$landscapeUrl"
	sha256calculated=$(sha256sum $path | cut -d " " -f 1)

	if [ "$sha256" != "$sha256calculated" ]
	then
		systemd-cat -t spotlight -p emerg <<< "Checksum for $name incorrect"
		exit 1
	fi

	if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]
	then
		gsettings set "org.gnome.desktop.$name" picture-options "zoom"
		gsettings set "org.gnome.desktop.$name" picture-uri "file://$path"
	elif [ "$XDG_CURRENT_DESKTOP" = "X-Cinnamon" ]
	then
		gsettings set "org.cinnamon.desktop.$name" picture-options "zoom"
		gsettings set "org.cinnamon.desktop.$name" picture-uri "file://$path"
	elif [ "$XDG_CURRENT_DESKTOP" = "XFCE" ]
	then
		monitorProperties=$(xfconf-query -c xfce4-desktop --property /backdrop -l | \
			egrep -e "screen[0-9]+/monitor[0-9]+/image-path$" \
				-e "screen[0-9]+/monitor[0-9]+/last-image$")

		for property in $monitorProperties
		do
			xfconf-query --channel xfce4-desktop --property $property --set $path
		done
	else
		systemd-cat -t spotlight -p emerg <<< "Unsupported desktop envoironment: ${XDG_CURRENT_DESKTOP:-None}"
		exit 1
	fi

	capitalName="$(tr '[:lower:]' '[:upper:]' <<< ${name:0:1})${name:1}"

	notify-send "$capitalName changed" "$title ($searchTerms)" --icon=preferences-desktop-wallpaper --urgency=low #--hint=string:desktop-entry:spotlight
	systemd-cat -t spotlight -p info <<< "$capitalName changed to $title ($searchTerms)"
}

setImage "background"

if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]
then
	setImage "screensaver"
fi
