#!/bin/bash
echo $(date): $* >>/tmp/master.log
echo "Executing $0" >>/tmp/master.log
ENDSTATE=$3
NAME=$2
TYPE=$1
if [ "$ENDSTATE" == "MASTER" ] ; then
    echo "Transitioning Floating ip to $(hostname -f)..." >>/tmp/master.log
    SERVER_ID=$(curl -s -H "Authorization: Bearer $HETZNER_TOKEN" "https://api.hetzner.cloud/v1/servers?name=$(hostname -f)" | grep -C 2 servers | grep id | awk '{ print $2 }' | sed -e s/,//)
    FLOATING_IP=$(echo $VIPS | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
    FLOATING_IP_ID=$(curl -s -H "Authorization: Bearer $HETZNER_TOKEN" "https://api.hetzner.cloud/v1/floating_ips" | grep "\"ip\": \"$FLOATING_IP" -B 3  | grep id | awk '{ print $2 }' | sed -e s/,//)

    while :
    do
        CHECK=$(curl -s -H "Authorization: Bearer $HETZNER_TOKEN" "https://api.hetzner.cloud/v1/floating_ips/$FLOATING_IP_ID" | grep  \"server\": | awk '{ print $2 }' | sed -e s/,//) 
        if [ "$CHECK" == "$SERVER_ID" ] ; then
            echo "Floating IP $FLOATING_IP already assigned to server $(hostname -f)"  >>/tmp/master.log
            echo "Waiting for 1 minute to recheck."  >>/tmp/master.log
            sleep 60
        else
            curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HETZNER_TOKEN" -d "{\"server\":$SERVER_ID}" "https://api.hetzner.cloud/v1/floating_ips/$FLOATING_IP_ID/actions/assign" >>/tmp/master.log
            echo "Setting Floating IP $FLOATING_IP to $(hostname -f)" >>/tmp/master.log
            sleep 5
        fi
    done


fi
