#!/bin/bash
echo $(date): $* >>/tmp/master.log
echo "Executing $0" >>/tmp/master.log

if grep -q MASTER "/tmp/endstate"; then

    SERVER_ID=$(curl -s -H "Authorization: Bearer $HETZNER_TOKEN" "https://api.hetzner.cloud/v1/servers?name=$(hostname -f)" | grep -C 2 servers | grep id | awk '{ print $2 }' | sed -e s/,//)
    FLOATING_IP_ID=$(curl -s -H "Authorization: Bearer $HETZNER_TOKEN" "https://api.hetzner.cloud/v1/floating_ips" | grep "\"ip\": \"${FLOATING_IP}" -B 10  | grep id | awk '{ print $2 }' | sed -e s/,//)

    CHECK=$(curl -s -H "Authorization: Bearer $HETZNER_TOKEN" "https://api.hetzner.cloud/v1/floating_ips/$FLOATING_IP_ID" | grep  \"server\": | awk '{ print $2 }' | sed -e s/,//) 
    if [ "$CHECK" == "$SERVER_ID" ] ; then
        echo "Floating IP ${FLOATING_IP} already assigned to server $(hostname -f). All good."  >>/tmp/master.log
        exit 0
    else
        echo "Floating IP ${FLOATING_IP} is not assigned to me $(hostname -f) - running FAULT" >>/tmp/master.log
        exit 1
    fi
else
    exit 0
fi
