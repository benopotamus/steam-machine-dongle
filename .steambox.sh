if [ -e /dev/disk/by-uuid/blockid here ]
then
	pactl unload-module 1
	pacmd set-default-sink 0
	steam -bigpicture
else
	pacmd set-default-sink 1
fi
