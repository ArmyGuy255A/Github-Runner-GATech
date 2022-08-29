#!/bin/bash

#Derived from: https://dev.to/pwd9000/create-a-docker-based-self-hosted-github-runner-linux-container-48dh
#Author: Marcel L
#Author Email: pwd9000@hotmail.co.uk
#Modified by Phil Dieppa
#Modification Email: pdieppa3@gatech.edu

GH_OWNER=$GH_OWNER
GH_REPOSITORY=$GH_REPOSITORY
GH_PAT=$GH_PAT

RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="dockerNode-${RUNNER_SUFFIX}"

# API ref: https://docs.github.com/en/enterprise-server@3.4/rest/actions/self-hosted-runners#create-a-registration-token-for-a-repository
REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GH_PAT}" https://github.gatech.edu/api/v3/repos/${GH_OWNER}/${GH_REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)


cd /home/docker/actions-runner

./config.sh --unattended --url https://github.gatech.edu/${GH_OWNER}/${GH_REPOSITORY} --token ${REG_TOKEN} --name ${RUNNER_NAME}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token $GH_TOKEN
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!