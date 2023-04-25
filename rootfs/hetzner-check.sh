#!/bin/bash
echo $(date): $* >>/tmp/master.log
echo "Executing $0" >>/tmp/master.log

if grep -q MASTER "/tmp/endstate"; then

    SERVER_ID=$(curl -s -H "Authorization: Bearer $HETZNER_TOKEN" "https://api.hetzner.cloud/v1/servers?name=$(hostname -f)" | jq '.servers[].id')
    FLOATING_IP_ID=$(curl -s -H "Authorization: Bearer $HETZNER_TOKEN" "https://api.hetzner.cloud/v1/floating_ips" | jq ".floating_ips[] | select (.ip | contains(\"$FLOATING_IP\")).id")

    CHECK=$(curl -s -H "Authorization: Bearer $HETZNER_TOKEN" "https://api.hetzner.cloud/v1/floating_ips/$FLOATING_IP_ID" | jq '.floating_ips[].server')
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
