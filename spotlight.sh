#! /bin/bash

item=$(wget -qO- "https://arc.msn.com/v3/Delivery/Cache?pid=279978&fmt=json&ua=WindowsShellClient&lc=en,en-US&ctry=US" | jq -r ".batchrsp.items | .[0].item")

landscapeUrl=$(echo $item | jq -r ".ad.image_fullscreen_001_landscape.u")
title=$(echo $item | jq -r ".ad.title_text.tx")
titleUrl=$(echo $item | jq -r ".ad.title_destination_url.u" | perl -pe 's/.*?(http.*)/\1/')

mkdir -p "$HOME/.spotlight"
path="$HOME/.spotlight/background.jpg"
	
wget -qO "$path" "$landscapeUrl"

if [ "$XDG_CURRENT_DESKTOP" = "XFCE" ]; then
	monis=$(xfconf-query -c xfce4-desktop -p /backdrop -l | \
			egrep -e "screen.*/monitor.*image-path$" \
				  -e "screen.*/monitor.*/last-image$")

	for i in $monis; do
		xfconf-query -c xfce4-desktop -p $i -s $path
	done

	notify-send "Background changed" "$title" \
				--icon=preferences-desktop-wallpaper \
				--urgency=low --hint=string:desktop-entry:spotlight\
				--hint=string:desktop-entry:spotlight

	echo "Background changed to $title ($titleUrl)" | systemd-cat -t spotlight

elif [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
	gsettings set org.gnome.desktop.background picture-options "zoom"
	gsettings set org.gnome.desktop.background picture-uri "file://$path"

	notify-send "Background changed" "$title ($titleUrl)" --icon=preferences-desktop-wallpaper --urgency=low --hint=string:desktop-entry:spotlight
	echo "Background changed to $title ($titleUrl)" | systemd-cat -t spotlight

else
	echo "DE not supported" | systemd-cat -t spotlight
fi
