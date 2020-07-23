#!/usr/bin/env bash

# exit immediately if a command exits with a non-zero status
set -e

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# define default values
DEFAULT_IMAGE_TAG=1.0.0
DEFAULT_DOCKER_REGISTRY_USER=warriortrading

# set default values of parameters
IMAGE_TAG=$DEFAULT_IMAGE_TAG
DOCKER_REGISTRY_USER=$DEFAULT_DOCKER_REGISTRY_USER

usage()
{
    echo "example :"
    echo "   bash $0 -n IMAGE_NAME [-t IMAGE_TAG] [-u DOCKER_REGISTRY_USER] -p DOCKER_REGISTRY_PW"
    echo "parameters :"
    echo "   IMAGE_NAME => image name."
    echo "   IMAGE_TAG => image tag. default is ${DEFAULT_IMAGE_TAG}"
    echo "   DOCKER_REGISTRY_USER => user name of docker hub. default is ${DEFAULT_IMAGE_TAG}"
    echo "   DOCKER_REGISTRY_PW => user password of docker hub."
    exit 1
}

# parse input parameters
while getopts "n:t:u:p:" opt; do
    case "$opt" in
        n) IMAGE_NAME="$OPTARG";;
        t) IMAGE_TAG="$OPTARG";;
        u) DOCKER_REGISTRY_USER="$OPTARG";;
        p) DOCKER_REGISTRY_PW="$OPTARG";;
        ?) usage;;
    esac
done
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

print_param()
{
    param=$1
    echo "   $param --> ${!param}"
}
must_param()
{
    param=$1
    if [ -z "${!param}" ]; then
        echo "Error: empty parameter ${param}"
        usage
    fi
}

# validate parameters
must_param IMAGE_NAME
must_param DOCKER_REGISTRY_PW

# list parameters
echo "Parameters:"
print_param IMAGE_NAME
print_param IMAGE_TAG
print_param DOCKER_REGISTRY_USER
echo ""

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# add execute commands below
image=$IMAGE_NAME:$IMAGE_TAG

# upload to docker hub
docker logout
docker login --username $DOCKER_REGISTRY_USER --password $DOCKER_REGISTRY_PW
docker tag $image $DOCKER_REGISTRY_USER/$image
docker push $DOCKER_REGISTRY_USER/$image
docker logout

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# scripts done
echo "script $0 done"
echo ""





