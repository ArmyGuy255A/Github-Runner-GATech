#!/bin/bash

#Derived from: https://dev.to/pwd9000/create-a-docker-based-self-hosted-github-runner-linux-container-48dh
#Author: Marcel L
#Author Email: pwd9000@hotmail.co.uk
#Modified by Phil Dieppa
#Modification Email: pdieppa3@gatech.edu

GH_OWNER=$GH_OWNER
GH_REPOSITORY=$GH_REPOSITORY
GH_PAT=$GH_PAT
REG_TOKEN=$REG_TOKEN
GH_URL=https://github.gatech.edu/${GH_OWNER}/${GH_REPOSITORY}

RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="runner-${RUNNER_SUFFIX}"

cd /home/docker/actions-runner

# Check if runner is already registered
if [ -f ".runner" ]
then
    echo "Runner already registered. Skipping registration"
else

    if [ -z "$REG_TOKEN" ]
    then
        # Set REG_TOKEN here
        # API ref: https://docs.github.com/en/enterprise-server@3.4/rest/actions/self-hosted-runners#create-a-registration-token-for-a-repository
        REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GH_PAT}" https://github.gatech.edu/api/v3/repos/${GH_OWNER}/${GH_REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)
    else
        # Do nothing
        echo "REG_TOKEN is already set"
    fi
    

    echo "Registering runner at URL: ${GH_URL}"
    sudo -u docker ./config.sh --unattended --url ${GH_URL} --token ${REG_TOKEN} --name ${RUNNER_NAME}

fi


cleanup() {
    echo "Stopping the runner! Be sure to remove it from the repository manually if you're finished!"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

sudo -u docker ./run.sh & wait $!