#!/bin/bash

cd /home/pi
CHANGED=0

if ! [ "$(ping -c 1 heise.de)" ]; then
	logger -s "Restarting internet!"
    	sudo ifdown wlan0
	sleep 5
    	sudo ifup wlan0
	sleep 20
else
	#logger -s "Internet is up and running."
	echo "Internet is up and running."
fi

if nc -z -w5 localhost 5000; then
	#logger -s "Server is up an running."
	echo "Server is up an running."
else
	logger -s "Server is NOT running. Will try to restart."
	CHANGED=1
fi


### OEC_WEB
pushd oec_web
git fetch
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})
if [ $LOCAL = $REMOTE ]; then
	echo "Up-to-date"
else
        logger -s "Need to pull oec_web"
	CHANGED=1
	git pull
fi
popd


## RESTARTING SERVER
if [[ "$CHANGED" -eq 1 ]]; then
	logger -s "Restarting python server and chromium!"
	sudo killall python
	sudo killall chromium
	pushd oec_web
	source venv/bin/activate
	nohup python oec_web.py  &
	deactivate
	popd
	sleep 30
	DISPLAY=":0" nohup chromium --noerrdialogs --kiosk http://127.0.0.1:5000/kiosk/ --incognito &
else
	#logger -s "Nothing to do. Everything is up-to-date!"
	echo "Nothing to do. Everything is up-to-date!"
fi

