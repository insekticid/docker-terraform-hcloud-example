#!/bin/bash
set -eu
DOCKER_VERSION=${DOCKER_VERSION:-}
KUBERNETES_VERSION=${KUBERNETES_VERSION:-}

echo "
Package: docker-ce
Pin: version ${DOCKER_VERSION}.*
Pin-Priority: 1000
" > /etc/apt/preferences.d/docker-ce
sleep 30
apt-get -qq update
apt-get -qq install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    jq \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get -qq update && apt-get -qq install -y docker-ce

cat > /etc/docker/daemon.json <<EOF
{
  "storage-driver":"overlay2" 
}
EOF

systemctl restart docker.service