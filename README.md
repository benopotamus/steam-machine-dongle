steam-machine-dongle
=====================

Scripts and instructions for booting a Linux PC into Steam Big Picture mode using a dongle - and no keyboard.

## How it works ##

As couches aren't for keyboards, we need a way to tell the computer to launch Steam Big Picture mode. This can be done by inserting a USB drive before turning the computer on, and the system detects the presence of the drive and configures itself accordingly.

__.steambox.sh__ is run when you log into your window manager. It switches the audio output and launches Steam

__steambox_dongle__ (optional) is run on system startup (as root) and switches default window managers 

The end result is we can insert a USB drive, turn the computer on, and the next thing we know we're in Steam Big Picture mode and using a gamepad to launch and play games!


## Installation ##

You will need a USB drive. It can have data on it. The scripts just rely on the presence of the drive, not the data on it itself. Focal price has some interesting ones: [http://search.focalprice.com/search?keyword=usb+drive&categoryid=]

### 1. Auto log in with GDM ###

Keyboards are required for manual log ins, and we don't like keyboards on couches, so we'll enable auto log in.

	sudo /etc/gdm3/daemon.conf
	
Uncomment (remove #'s) from the automatic log in section and make sure it is enabled and has the user to auto log in as

	[daemon]
	# Enabling automatic login
	AutomaticLoginEnable = true
	AutomaticLogin = your user name here
	
_Note: there's a bug in GDM 3.8 that _can_ prevent auto log in's from working_

### 2. .steambox.sh setup ###

Insert the USB drive and get its UUID (block id)

	sudo blkid
	
Put the UUID into .steambox.sh

This script assumes your distribution is using PulseAudio (which seems like a safe bet). In the future PulseAudio will allow you to configure a hierarchy of audio outputs and it will work out the highest one that is connected and use that as the output source. It's not there yet so for now we need to do that ourselves. Audio outputs in PulseAudio land are called "sinks". You need to choose which sink you would like to use when running in Steam Machine mode - and which sink you would like when booting in normal PC mode.

	pacmd list-sinks

The names should be a giveaway. Put the sink indexes in .steambox.sh, make it executable, and move it to your home directory

	chmod o+x .steambox.sh
	mv .steambox.sh ~/

Add .steambox.sh to the list of startup applications in your window manager and the main part is done!


### 3. (optional) steambox_dongle setup  ###

Some window managers aren't optimal for Steam Big Picture with just a controller. E.g. Gnome 3 will display a pop-up over the top of Steam when it detects the USB dongle - not optimal. This script resolves this by configuring the window manager preference based on dongle presence. 

Window manager preference is controlled by a file in /var/lib/AccountsService/users. We're going to make a file for our Steam machine configuration and another for our default (no dongle) configuration.

	cd /var/lib/AccountsService/users/
	sudo cp [your username] [your username].default
	sudo cp [your username] [your username].steam-machine
	
You will need to manually edit these files

	sudo gedit [your username].default
	sudo gedit [your username].steam-machine

The XSession variable is the important one. My preference files look like:

__default__

	[User]
	Language=
	XSession=gnome
	SystemAccount=false
	
	
__steam-machine__

	[User]
	Language=
	XSession=gnome-fallback
	SystemAccount=false

gnome-fallback is Gnome 3 without the fancyness


Edit steambox_dongle to use your dongle's UUID and your user name

Make steambox_dongle executable, move it to the init.d (start up script) directory, and use insserv to add it to the appropriate runlevels (insserv will work it out for you)

	sudo chown your-user-name:your-user-name steambox_dongle
	sudo chmod o+x steambox_dongle
	sudo mv steambox_dongle /etc/init.d/
	sudo insserv /etc/init.d/steambox_dongle



### 4. Grub set up ###

If you're using Grub as your boot loader and would like it to boot a bit quicker, you can reduce the amount of time it waits for user input

	sudo gedit /etc/default/grub
	
set GRUB_TIMEOUT=1

And run update
	
	sudo update-grub


## TODO ##

If there's demand for it...

* Remove reliance on GDM3 for auto log ins
* Cater for non-Debian based distros
* Create an installation script/program to present the user with just the options they need to choose (e.g. a list of PulseAudio sinks to choose from), and automate the file editing process.
* Package above script/program as DEB, RPM, etc.
