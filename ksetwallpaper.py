#!/usr/bin/env python3
import time
import dbus
import argparse
import glob
import random
import os
import subprocess
from pathlib import Path
HOME = str(Path.home())
SCREEN_LOCK_CONFIG = HOME+"/.config/kscreenlockerrc"
def setwallpaper(filepath, plugin='org.kde.image'):
    jscript = """
    var allDesktops = desktops();
    print (allDesktops);
    for (i=0;i<allDesktops.length;i++) {
        d = allDesktops[i];
        d.wallpaperPlugin = "%s";
        d.currentConfigGroup = Array("Wallpaper", "%s", "General");
        d.writeConfig("Image", "file://%s")
    }
    """
    bus = dbus.SessionBus()
    plasma = dbus.Interface(bus.get_object(
        'org.kde.plasmashell', '/PlasmaShell'), dbus_interface='org.kde.PlasmaShell')
    plasma.evaluateScript(jscript % (plugin, plugin, filepath))

def set_lockscreen_wallpaper(filepath,plugin='org.kde.image'):
    if os.path.exists(SCREEN_LOCK_CONFIG):
        new_data=[]
        with open(SCREEN_LOCK_CONFIG, "r") as kscreenlockerrc:
            new_data = kscreenlockerrc.readlines()
            is_wallpaper_section=False
            for num,line in enumerate(new_data,1):
                if "[Greeter][Wallpaper]["+plugin+"][General]" in line:
                    is_wallpaper_section = True
                if "Image=" in line and is_wallpaper_section:
                    new_data[num-1] = "Image="+filepath+"\n"
                    break

        with open(SCREEN_LOCK_CONFIG, "w") as kscreenlockerrc:
            kscreenlockerrc.writelines(new_data)

def is_locked():
    is_locked=subprocess.check_output("qdbus org.kde.screensaver /ScreenSaver org.freedesktop.ScreenSaver.GetActive",shell=True,universal_newlines=True).strip()
    if is_locked == "true":
        is_locked = True
    else:
        is_locked = False
    return is_locked

def get_walls_from_folder(directory):
    return glob.glob(directory+'/*')


def wallpaper_slideshow(wallapapers, plugin, timer, lock_screen):
    if timer > 0:
        wallpaper_count = len(wallapapers)
        delta_s = timer
        s = int(delta_s % 60)
        m = int((delta_s / 60) % 60)
        h = int((delta_s / 3600) % 3600)
        if h > 0:
            timer_show = f"{h}h {m}m {s}s"
        elif m > 0:
            timer_show = f"{m}m {s}s"
        elif s > 0:
            timer_show = f"{s}s"
        print(
            f"Looping through {wallpaper_count} wallpapers every  {timer_show}")
        while True:
            if is_locked() != True:
                random_int = random.randint(0, wallpaper_count-1)
                wallpaper_now = wallapapers[random_int]
                setwallpaper(wallpaper_now, plugin)
                if lock_screen == True:
                    set_lockscreen_wallpaper(wallpaper_now, plugin)
            time.sleep(timer)
    else:
        raise ValueError('Invalid --timer value')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='KDE Wallpaper setter')
    parser.add_argument('--file','-f', help='Wallpaper file name', default=None)
    parser.add_argument(
        '--plugin', '-p', help='Wallpaper plugin (default is org.kde.image)', default='org.kde.image')
    parser.add_argument('--dir', '-d', type=str,
                        help='Absolute path of folder containging your wallpapers for slideshow', default=None)
    parser.add_argument('--timer', '-t', type=int,
                        help='Time in seconds between wallpapers', default=900)
    parser.add_argument('--lock-screen', '-l', action="store_true",
                        help="Set lock screen wallpaper")
    args = parser.parse_args()

    if args.file != None:
        setwallpaper(filepath=args.file, plugin=args.plugin)
        if args.lock_screen == True:
            set_lockscreen_wallpaper(filepath=args.file, plugin=args.plugin)
            
    elif args.dir != None:
        wallpapers = get_walls_from_folder(args.dir)
        
        wallpaper_slideshow(wallapapers=wallpapers,
                            plugin=args.plugin, timer=args.timer,lock_screen=args.lock_screen)
    else:
        print("Need help? use -h or --help")
