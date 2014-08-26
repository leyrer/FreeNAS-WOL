#!/bin/ash
# CHANGE FOR YOUR SETUP -- START
FREENAS_MAC="38:ea:a7:xx:xx:xx"
FREENAS_MASK="192.168.1.255"
FREENAS_IP="192.168.1.24"
# CHANGE FOR YOUR SETUP -- END

NASPING=`ping -c 1 -q $FREENAS_IP | grep -c '1 packets received'`
if [ $NASPING -eq 0 ]; then
    while IFS= read -r MAC <&3; do
        echo "Working on $MAC ..."
        if [ -z "$MAC" ]; then # skip empty lines
            continue
        fi
        VAR=`grep $MAC /proc/net/arp`
        if [ -z "$VAR" ]; then
            :
        else 
            IP=`echo "$VAR" | cut -d ' ' -f1`
            PING=`ping -c 1 -q $IP | grep -c '1 packets received'`
            if [ $PING -eq 0 ]; then
                printf "%s\tPC down\n" $MAC
                :
            else
                echo "$MAC PC online, FreeNAS offline. Therefore waking up FreeNAS."
                /usr/bin/wol -h $FREENAS_MASK $FREENAS_MAC 1>/dev/null
                # echo "Woke up FreeNAS"
                break
            fi
        fi
    done 3< "/etc/pcs.txt"
else
    echo "NAS already running"
    :
fi
