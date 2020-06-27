#!/bin/bash

source $PWD/profile

docker run -it \
        -v $PWD/app:/root/app \
        -v $PWD/hetzner:/root/app/hetzner \
        -v $PWD/terraform:/root/app/terraform \
        -v $PWD/kubespray/inventory/mycluster:/root/kubespray/inventory/mycluster \
        --name kubespray-infra eu.gcr.io/stich-karl-my-k8s/kubespray-infra:latest
