# Kubernetes Bootstrap on AWS

## \w kubeadm, docker, kubelet, kubectl, and Weavenet: Ubuntu 20.04

### 1. Firewall Rules

#### Kubernetes Host

- Open port 22 for SSH
- Open port 6443 for Kubernetes API
- Open port 10250 for kubelet
- Open port 10251 for kube-scheduler
- Open port 10252 for kube-controller-manager
- Open port 10255 for Read-Only Kubelet API
- Open port 30000-32767 for NodePort Services
- Open port 6783 for Weave Net
- Open port 6784 UDP for Weave Net
- Open standard ports for web services

#### Worker Nodes

- Open port 22 for SSH
- Open port 10250 for kubelet
- Open port 10255 for Read-Only Kubelet API
- Open port 6783 for Weave Net
- Open port 6784 UDP for Weave Net
- Open standard ports for web services
- Open port 6443 for Kubernetes API

### 2. Initial System Setup

```bash
sudo apt update -y &&

sudo apt dist-upgrade -y &&

sudo apt autoremove -y &&

sudo apt install net-tools dstat ranger ncdu htop neofetch neovim vim git build-essential tldr -y && tldr tldr &&

sudo passwd root &&

sudo passwd ubuntu &&

sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config &&

sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config &&

sudo systemctl restart sshd &&

sudo systemctl status sshd
```

### 3. Install Docker

```bash
sudo su -

apt-get update

apt-get install -y apt-transport-https ca-certificates curl software-properties-common &&

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" &&

apt update &&

apt-cache policy docker-ce &&

apt upgrade -y &&

apt install docker-ce -y
```

### 4. Configure Docker Daemon to use systemd for cgroup management

```bash
nvim /etc/docker/daemon.json
```

```json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
```

```bash
systemctl enable --now docker && systemctl enable --now containerd && sudo systemctl daemon-reload && usermod -aG docker ubuntu && systemctl restart docker



# disable swap per kubeadm requirements
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

### 5. Install Kubernetes

```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - &&
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt update -y &&

apt dist-upgrade -y &&

apt install -y kubelet kubeadm kubectl &&

apt-mark hold kubelet kubeadm kubectl &&

sysctl net.bridge.bridge-nf-call-iptables=1 &&

sudo rm -rf /etc/containerd/config.toml &&

sudo systemctl restart containerd
```

### 5. Kubeadm Init -- HOST NODE ONLY

```bash

sudo su ubuntu

sudo kubeadm init --pod-network-cidr 172.23.0.0/24

sudo mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

```

### 6. Kubeadm Join -- WORKER NODES ONLY

```bash
sudo su -

kubeadm join 172.23.0.248:6443 --token hvv5d2.h6u1jrhykemuvmvc \
        --discovery-token-ca-cert-hash sha256:6e48b26af030b20c14426c2f49f54d1d879342a2b56ed6eecfbacf76fd599144

```

### 7. Run a test pod

```bash
nvim nginx-deploy.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      containers:
        - name: nginx-container
          image: nginx
          ports:
            - containerPort: 80



apiVersion: v1
kind: Service
metadata:
  name: nginx-app
spec:
  replicas: 2
  selector:
    app: nginx-app
  type: NodePort
  ports:
    - port: 80
      targetPort: 80
      nodePort: 32001

```
