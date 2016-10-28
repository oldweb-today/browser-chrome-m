#!/bin/bash

#fluxbox -display $DISPLAY -log /tmp/fluxbox.log &
run_browser jwm -display $DISPLAY &

if [[ -n "$PROXY_GET_CA" ]]; then
    curl -x "$PROXY_HOST:$PROXY_PORT"  "$PROXY_GET_CA" > /tmp/proxy-ca.pem

    mkdir -p $HOME/.pki/nssdb
    certutil -d $HOME/.pki/nssdb -N
    certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "Proxy" -i /tmp/proxy-ca.pem
fi

mkdir ~/.config/
mkdir ~/.config/google-chrome
touch ~/.config/google-chrome/First\ Run
mkdir ~/.config/google-chrome/Default/

sudo chown browser ~/Preferences

if [ "$SCREEN_WIDTH" -lt "$SCREEN_HEIGHT" ]; then
    sed -i s/'\\"orientation\\":\\"horizontal\\",\\"mode'/'\\"orientation\\":\\"vertical\\",\\"mode'/g Preferences 
fi


cp ~/Preferences ~/.config/google-chrome/Default/

URL="http://webrecorder.io/_homepage"

run_browser google-chrome --disable-gpu --no-default-browser-check --disable-background-networking --disable-client-side-phishing-detection --disable-component-update --safebrowsing-disable-auto-update --auto-open-devtools-for-tabs --disable-session-crashed-bubble --disable-infobars --new-window "$URL" &

pid=$!

count=0
wid=""

while [ -z "$wid" ]; do
    wid=$(wmctrl -l | grep "Developer Tools - " | cut -f 1 -d ' ')
    if [ -n "$wid" ]; then
        wmctrl -i -r $wid -b add,below
        echo "DevTools Found"
        break
    fi
    sleep 0.5
    count=$[$count + 1]
    echo "DevTools Not Found"
    if [ $count -eq 6 ]; then
        echo "Restarting process"
        kill $(ps -ef | grep "/chrome/chrome --disable" | awk '{ print $2 }')
        count=0
    fi
done

python /app/hidedt.py &


wait $pid

