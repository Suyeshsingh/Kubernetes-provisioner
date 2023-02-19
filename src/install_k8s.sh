#!/bin/sh

echo "Disabling swap"
swapoff -a; sed -i '/swap/d' /etc/fstab

echo "Disabling Firewall"
systemctl disable --now ufw

echo "Enabling and Loading Kernel modules"
{
cat >> /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter
}
echo "Adding Kernel settings"
{
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system
}

echo "Containerd"
{
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt install -y containerd.io
}
{
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
}
sudo systemctl restart containerd

sudo systemctl enable containerd

echo "Installing Kubernetes"
{
 curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
 echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
}

apt update && apt install -y kubeadm=1.25.0-00 kubelet=1.25.0-00 kubectl=1.25.0-00

