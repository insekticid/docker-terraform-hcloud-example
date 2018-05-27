#!/bin/bash
set -eu
RANCHER_VERSION=${RANCHER_VERSION:-v2.0.2}
ACME_DOMAIN=${ACME_DOMAIN:-example.com}

sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:${RANCHER_VERSION}
# --acme-domain ${ACME_DOMAIN}