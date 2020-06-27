#!/bin/bash
RANCHER_SERVER_ADDRESS=${RANCHER_SERVER_ADDRESS}
RANCHER_PASSWORD=${RANCHER_PASSWORD:-admin}

#credits https://gist.github.com/superseb/29af10c2de2a5e75ef816292ef3ae426

# Login
LOGINRESPONSE=`curl -s https://${RANCHER_SERVER_ADDRESS}/v3-public/localProviders/local?action=login -H 'content-type: application/json' --data-binary '{"username":"admin","password":"'"${RANCHER_PASSWORD}"'"}' --insecure`
LOGINTOKEN=`echo $LOGINRESPONSE | jq -r .token`
echo "Login-Token:" $LOGINTOKEN

# Create API key
APIRESPONSE=`curl -s https://${RANCHER_SERVER_ADDRESS}/v3/token -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure`
# Extract and store token
APITOKEN=`echo $APIRESPONSE | jq -r .token`
echo "API-Token:" $APITOKEN

# Generate docker run
echo 'curl -s -H \"Authorization: Bearer $APITOKEN\" https://${RANCHER_SERVER_ADDRESS}/v3/clusterregistrationtokens --insecure | jq -r .data[0].nodeCommand'
AGENTCOMMAND=`curl -s -H "Authorization: Bearer $APITOKEN" https://${RANCHER_SERVER_ADDRESS}/v3/clusterregistrationtokens --insecure | jq -r .data[0].nodeCommand`
ROLEFLAGS="--etcd --controlplane --worker"

# Assemble the docker run command
# Show the command
FULLAGENTCOMMAND="${AGENTCOMMAND} ${ROLEFLAGS}"
echo $FULLAGENTCOMMAND

echo $FULLAGENTCOMMAND > rancher_node_add.sh
bash ./rancher_node_add.sh
