# Kubernetes Hetzner Keepalived

Originally forked from [yoshz/docker-hetzner-keepalived](https://github.com/yoshz/docker-hetzner-keepalived). This is now improved to run on a Kubernetes cluster.


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
  iface: ens10 # Use an internal network where VRRP traffic can go over
  vips: 192.168.11.12/32 dev eth0  
  pass: AwesomePasswordLol
  floating_ip: 192.168.11.12
  priority: "100" # You can remove this if you want it done automatically (I prefere it set so all are equally on)
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
