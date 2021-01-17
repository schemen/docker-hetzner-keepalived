#!/bin/bash -e

K8S_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

HOST_IP=$(ip addr show dev $IFACE | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | awk '{print $2}')
PEER_IPS=$(curl -sS --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    -H "Authorization: Bearer $K8S_TOKEN" \
    https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/nodes \
    | awk '/"type": "InternalIP"/{getline; gsub(/"/, ""); print $2}' \
    | grep -vw $HOST_IP)

if [ -z "$PRIORITY" ]; then
    HOST_ID=$(echo $HOST_IP | grep -o "[0-9]*$")
    PRIORITY=$((100 + $HOST_ID))
fi

cat <<EOF > /etc/keepalived/keepalived.conf
global_defs {
    script_user root
    enable_script_security
}

vrrp_instance vips {
    state BACKUP
    priority ${PRIORITY}
    interface ${IFACE}
    track_interface {
        ${IFACE}
    }
    unicast_src_ip ${HOST_IP}
    unicast_peer {
        ${PEER_IPS}
    }

    authentication {
        auth_type PASS
        auth_pass ${PASS}
    }

    garp_master_delay 5
    virtual_router_id 10
    advert_int 1
    virtual_ipaddress {
        ${VIPS}
    }

    notify /hetzner-notify.sh
}
EOF

rm -f /var/run/keepalived.pid

exec "$@"
