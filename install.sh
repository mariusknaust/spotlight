#!/usr/bin/env bash

# This script installs the relevant files as the current user. You can also use it to update
# the installation using "./install.sh update".

set -e

action="install"

if [ "$1" -a "$1" == "uninstall" ]; then
  action="uninstall"
elif [ "$1" -a "$1" == "update" ]; then
  action="update"
elif [ "$1" -a "$1" == "install" ]; then
  action="install"
else
  echo "error: unknown action (accepting 'install', 'update', and 'uninstall'), exiting."
  exit 1
fi

if [ "$action" == "install" ]; then
  sudo apt install jq wget sed libglib2.0-0 python3
  mkdir -p ~/.local/share/systemd/user/
  mkdir -p ~/.local/bin/

  cp spotlight.desktop ~/.local/share/applications/spotlight.desktop
  cp spotlight.timer ~/.local/share/systemd/user/spotlight.timer
  cp spotlight.service ~/.local/share/systemd/user/spotlight.service
  cp spotlight.sh ~/.local/bin/spotlight.sh
  cp ksetwallpaper.py ~/.local/bin/ksetwallpaper.py
  systemctl --user enable spotlight.timer
elif [ "$action" == "update" ]; then
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    git remote update > /dev/null 2>&1
    UPSTREAM="master"
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    if [ $LOCAL = $REMOTE ]; then
      echo "Already up-to-date."
      exit 0
    fi
    git pull
  else
    echo "Not in a git repository. Please change to the spotlight git repository, exiting."
    exit 1
  fi
  systemctl --user stop spotlight.timer
  cp spotlight.desktop ~/.local/share/applications/spotlight.desktop
  cp spotlight.timer ~/.local/share/systemd/user/spotlight.timer
  cp spotlight.service ~/.local/share/systemd/user/spotlight.service
  cp spotlight.sh ~/.local/bin/spotlight.sh
  cp ksetwallpaper.py ~/.local/bin/ksetwallpaper.py
  systemctl --user enable spotlight.timer
else
  systemctl --user stop spotlight.timer
  systemctl --user disable spotlight.timer
  rm -f ~/.local/share/applications/spotlight.desktop
  rm -f ~/.local/share/systemd/user/spotlight.timer
  rm -f ~/.local/share/systemd/user/spotlight.service
  rm -f ~/.local/bin/spotlight.sh
  rm -f ~/.local/bin/ksetwallpaper.py

  # Delete directory only if it is empty:
  if [ -z "$(ls -A ~/.local/share/systemd/user/)" ]; then
    rm -rf ~/.local/share/systemd/user/
  fi
fi

exit 0
