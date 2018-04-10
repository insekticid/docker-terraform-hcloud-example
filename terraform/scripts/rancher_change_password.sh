#!/bin/bash
RANCHER_PASSWORD=${RANCHER_PASSWORD:-admin}
RANCHER_CLUSTER_NAME=${RANCHER_CLUSTER_NAME:-playground}
RANCHER_KUBERNETES_VERSION=${RANCHER_KUBERNETES_VERSION:-v1.10.0-rancher1-1}

#credits https://gist.github.com/superseb/29af10c2de2a5e75ef816292ef3ae426

while ! curl -k https://localhost/ping; do sleep 5; done

while [ -z $LOGINTOKEN ];
do
# Login
LOGINRESPONSE=`curl -s 'https://127.0.0.1/v3-public/localProviders/local?action=login' -H 'content-type: application/json' --data-binary '{"username":"admin","password":"admin"}' --insecure`
LOGINTOKEN=`echo $LOGINRESPONSE | jq -r .token`
echo $LOGINTOKEN
sleep 5;
done

# Change password
curl -s 'https://127.0.0.1/v3/users?action=changepassword' -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"currentPassword":"admin","newPassword":"'"${RANCHER_PASSWORD}"'"}' --insecure

# Create API key
APIRESPONSE=`curl -s https://127.0.0.1/v3/token -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure`
# Extract and store token
APITOKEN=`echo $APIRESPONSE | jq -r .token`
echo $APITOKEN

# Create cluster
CLUSTERRESPONSE=`curl -s https://127.0.0.1/v3/cluster -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"cluster","nodes":[],"rancherKubernetesEngineConfig":{"ignoreDockerVersion":true, "kubernetesVersion": "'"${RANCHER_KUBERNETES_VERSION}"'"},"name":"'"${RANCHER_CLUSTER_NAME}"'"}' --insecure`
# Extract clusterid to use for generating the docker run command
CLUSTERID=`echo $CLUSTERRESPONSE | jq -r .id`
echo $CLUSTERID

# Generate token (clusterRegistrationToken)
AGENTTOKEN=`curl -s 'https://127.0.0.1/v3/clusterregistrationtoken' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"clusterRegistrationToken","clusterId":"'$CLUSTERID'"}' --insecure | jq -r .token`
