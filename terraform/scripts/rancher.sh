#!/bin/bash
set -eu
RANCHER_VERSION=${RANCHER_VERSION:-stable}

sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/server:${RANCHER_VERSION}