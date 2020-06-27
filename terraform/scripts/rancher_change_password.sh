#!/bin/bash
RANCHER_PASSWORD=${RANCHER_PASSWORD:-admin}
RANCHER_CLUSTER_NAME=${RANCHER_CLUSTER_NAME:-playground}
RANCHER_KUBERNETES_VERSION=${RANCHER_KUBERNETES_VERSION:-v1.10.1-rancher2-1}

#credits https://gist.github.com/superseb/29af10c2de2a5e75ef816292ef3ae426

while ! curl -k https://localhost/ping; do sleep 5; done

while [ -z $LOGINTOKEN ];
do
# Login
# Login
RANCHER_CONTAINER_ID=`docker ps | awk 'NR > 1 {print $1; exit}'`
echo "Rancher Container ID:" $RANCHER_CONTAINER_ID
RANCHER_DEFAULT_PASSWORD=`docker exec -it $RANCHER_CONTAINER_ID reset-password | sed -e 's/\r//g' | awk 'END { print $1 }'`
LOGINRESPONSE=`curl -s 'https://127.0.0.1/v3-public/localProviders/local?action=login' -H 'content-type: application/json' --data-binary  '{"username":"admin","password":"'"${RANCHER_DEFAULT_PASSWORD}"'"}' --insecure`
echo $LOGINRESPONSE
LOGINTOKEN=`echo $LOGINRESPONSE | jq -r .token`
echo "Login-Token:" $LOGINTOKEN
sleep 10;
done

# Change password
CHANGE_PW_RESPONSE=`curl -s 'https://127.0.0.1/v3/users?action=changepassword' -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"currentPassword":"'"${RANCHER_DEFAULT_PASSWORD}"'","newPassword":"'"${RANCHER_PASSWORD}"'"}' --insecure`
echo "Change Password Response:" $CHANGE_PW_RESPONSE

# Create API key
APIRESPONSE=`curl -s https://127.0.0.1/v3/token -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure`
# Extract and store token
APITOKEN=`echo $APIRESPONSE | jq -r .token`
echo "API Token:" $APITOKEN

# Create cluster
CLUSTERRESPONSE=`curl -s https://127.0.0.1/v3/cluster -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"cluster","nodes":[],"rancherKubernetesEngineConfig":{"ignoreDockerVersion":true, "kubernetesVersion": "'"${RANCHER_KUBERNETES_VERSION}"'"},"name":"'"${RANCHER_CLUSTER_NAME}"'"}' --insecure`
# Extract clusterid to use for generating the docker run command
CLUSTERID=`echo $CLUSTERRESPONSE | jq -r .id`
echo "Cluster ID:" $CLUSTERID

# Generate token (clusterRegistrationToken)
AGENTTOKEN=`curl -s 'https://127.0.0.1/v3/clusterregistrationtoken' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"clusterRegistrationToken","clusterId":"'$CLUSTERID'"}' --insecure | jq -r .token`
echo "Agent-Token:" $AGENTTOKEN
