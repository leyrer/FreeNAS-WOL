 #!/bin/bash

# REPLACE WITH YOUR SUBNET START
SUBNET=192.168.123.
# REPLACE WITH YOUR SUBNET END

SHUTDOWN=true

# Fill ARP cache
export COUNTER=1
while [ $COUNTER -lt 255 ]
do
    ping -c 1 -t 1 $SUBNET$COUNTER 1>/dev/null &
    COUNTER=$(( $COUNTER + 1 ))
done

#wait for pings to finish
sleep 3

while IFS= read -r MAC <&3; do

    # skip empty lines in file
    if [ -z "$MAC" ]; then
        continue        
    fi

    # Let's see, if we find a IP for the current MAC
    VAR=`arp -a | grep $MAC`
    if [ -z "$VAR" ]; then
        :
    else
        # We have an IP for the MAC, so the PC might still be on. Check with ping
        IP=`echo "$VAR" | cut -d ' ' -f1`
        PING=`ping -c 1 -q $IP | grep -c '1 packets received'`
        if [ $PING -eq 0 ]; then
            printf "%s\tPC down\n" $MAC
            :
        else
            echo "$MAC PC online"
            # Abort shutdown
            SHUTDOWN=false

            # One PC running is enough to keep the server running
            break 
        fi
    fi
done 3< "./pcs.txt"

if [ "$SHUTDOWN" = true ] ; then
    echo "Shutdown this server"
    /sbin/shutdown -p now
else
    echo "Do nothing, keep server running"
fi
