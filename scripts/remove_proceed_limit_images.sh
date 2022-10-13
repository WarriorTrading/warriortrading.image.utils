#!/usr/bin/env bash

# exit immediately if a command exits with a non-zero status
set -e

usage()
{
    echo "example :"
    echo "   bash $0 -g DOCKER_HUB_ORG -u DOCKER_HUB_USER -p DOCKER_HUB_PASSWORD -r DOCKER_HUB_REPO -b DOCKER_HUB_BRANCH -l LIMIT_NUM"
    echo "parameters :"
    echo "   DOCKER_HUB_ORG => oranization name for docker hub."
    echo "   DOCKER_HUB_USER => user for docker hub."
    echo "   DOCKER_HUB_PASSWORD => password for docker hub."
    echo "   DOCKER_HUB_REPO => the checking and removing repo ."
    echo "   DOCKER_HUB_BRANCH => the branch of the repo."
    echo "   LIMIT_NUM => the limited number of the repo."
    exit 1
}

# parse input parameters
while getopts "g:u:p:r:b:l:" opt; do
    case "$opt" in
        g) DOCKER_HUB_ORG="$OPTARG";;
        u) DOCKER_HUB_USER="$OPTARG";;
        p) DOCKER_HUB_PASSWORD="$OPTARG";;
        r) DOCKER_HUB_REPO="$OPTARG";;
        b) DOCKER_HUB_BRANCH="$OPTARG";;
        l) LIMIT_NUM="$OPTARG";;
        ?) usage;;
    esac
done

# export DOCKER_HUB_BRANCH for jq utiliz it
export DOCKER_HUB_BRANCH=$DOCKER_HUB_BRANCH

HUB_DOMAIN="hub.docker.com"

# get token to be able to talk to Docker Hub
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_HUB_USER}'", "password": "'${DOCKER_HUB_PASSWORD}'"}' https://${HUB_DOMAIN}/v2/users/login/ | jq -r .token)

# get tags for repo
RES_TAGS=$(curl -s -H "Authorization: JWT ${TOKEN}" https://${HUB_DOMAIN}/v2/repositories/${DOCKER_HUB_ORG}/${DOCKER_HUB_REPO}/tags/?page_size=10000 | jq -r '.results')

BRANCH_TAGS=$(echo $RES_TAGS | jq 'map(.name) | map(select(test($ENV.DOCKER_HUB_BRANCH + "-.*")))')

NUM_TAGS=$(echo $BRANCH_TAGS | jq 'length')

echo "Checking the images of ${DOCKER_HUB_ORG}/${DOCKER_HUB_REPO}:${DOCKER_HUB_BRANCH}-*"
if [ $NUM_TAGS -eq 0 ]; then
  echo "[Warning] There are no images of ${DOCKER_HUB_BRANCH}. Just go ahead."
  echo ""
  exit 0
fi

NUM_REMOVE=$(($NUM_TAGS - $LIMIT_NUM))
if [ $NUM_REMOVE -le 0 ]; then
  echo "[Info] There are only ${NUM_TAGS} of ${DOCKER_HUB_BRANCH} images. The number is less or equal than the limit ${LIMIT_NUM}. No need to remove them."
  echo ""
  exit 0
fi

REMOVE_TAGS=$(echo $BRANCH_TAGS | jq 'map(split("-")[-1] | tonumber)' | jq 'sort | .[]' | head -n $NUM_REMOVE)
echo "Version numbers on branch ${DOCKER_HUB_BRANCH} to be removed: $REMOVE_TAGS"

for i in $REMOVE_TAGS; do 
  tag="${DOCKER_HUB_BRANCH}-$i"
  res_delete=$(curl -X DELETE -H "Authorization: JWT ${TOKEN}" https://${HUB_DOMAIN}/v2/repositories/${DOCKER_HUB_ORG}/${DOCKER_HUB_REPO}/tags/${tag}/)
  if [ $? -eq 0 ]; then
    echo "Deleted tag:${tag}"
  fi
done

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# scripts done
echo "script $0 done"
echo ""