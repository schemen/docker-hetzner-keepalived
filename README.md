# Hetzner Keepalived

Docker image running keepalived and Hetzner notify script to assign a floating ip to a node with automatic failover.

## Kubernetes deployment

Create namespace

```bash
kubectl create namespace keepalived
```

Create a configmap, for example:

```bash
cat <<EOF | kubectl create -n keepalived -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: keepalived
data:
  iface: ens10
  vips: 192.168.11.12/32 dev eth0
EOF
```

Create a secret with Hetzner API token

```bash
kubectl create secret generic hetzner -n keepalived --from-literal=token=YOUR_TOKEN
```

Install hetzner-keepalived

```bash

kubectl apply -f k8s/hetzner-keepalived.yaml
```