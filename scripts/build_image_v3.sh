#!/usr/bin/env bash

# exit immediately if a command exits with a non-zero status
set -e

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# define default values
DEFAULT_IMAGE_TAG="DEV-0"
DEFAULT_DOCKER_REGISTRY_USER=warriortrading
DEFAULT_BUILD_ARGS=

# set default values of parameters
IMAGE_TAG=$DEFAULT_IMAGE_TAG
DOCKER_REGISTRY_USER=$DEFAULT_DOCKER_REGISTRY_USER
BUILD_ARGS=$DEFAULT_BUILD_ARGS

usage()
{
    echo "example :"
    echo "   bash $0 -f FOLDER -n IMAGE_NAME [-t IMAGE_TAG] [-u DOCKER_REGISTRY_USER] [-p DOCKER_REGISTRY_PW] [-b BUILD_ARGS]"
    echo "parameters :"
    echo "   FOLDER => folder contains Dockerfile, or Dockerfile path"
    echo "   IMAGE_NAME => image name."
    echo "   IMAGE_TAG => image tag. default is ${DEFAULT_IMAGE_TAG}"
    echo "   DOCKER_REGISTRY_USER => user name of docker hub. default is ${DEFAULT_IMAGE_TAG}"
    echo "   DOCKER_REGISTRY_PW => user password of docker hub. if not filled, will ignore login and logout"
    echo "   BUILD_ARGS => Optional args when execute docker build, use ; to join multi-args. For example: GITHUB_TOKEN=token1;GITHUB_USER=user1"
    exit 1
}

# parse input parameters
while getopts "f:n:t:u:p:b:" opt; do
    case "$opt" in
        f) FOLDER="$OPTARG";;
        n) IMAGE_NAME="$OPTARG";;
        t) IMAGE_TAG="$OPTARG";;
        u) DOCKER_REGISTRY_USER="$OPTARG";;
        p) DOCKER_REGISTRY_PW="$OPTARG";;
        b) BUILD_ARGS="$OPTARG";;
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
must_param FOLDER
must_param IMAGE_NAME

# list parameters
echo "Parameters:"
print_param FOLDER
print_param IMAGE_NAME
print_param IMAGE_TAG
if [ ! -z "$DOCKER_REGISTRY_PW" ]; then
    print_param DOCKER_REGISTRY_USER
fi

BUILD_ARGS_FINAL=
if [ ! -z "$BUILD_ARGS" ]; then
    BUILD_ARGS_LIST=($(echo "$BUILD_ARGS" | tr ';' '\n'))
    for i in "${!BUILD_ARGS_LIST[@]}"
    do
        BUILD_ARGS_FINAL="${BUILD_ARGS_FINAL} --build-arg ${BUILD_ARGS_LIST[i]}"
    done
fi
print_param BUILD_ARGS_FINAL
echo ""

# check Folder
if [[ -d $FOLDER ]]; then
    DOCKERFILE_ARG=

elif [[ -f $FOLDER ]]; then
    DOCKERFILE_ARG="-f $FOLDER"
    FOLDER=$(dirname "${FOLDER}")
else
    echo "$FOLDER is not valid or exists"
    exit 1
fi

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# add execute commands below
image=$IMAGE_NAME:$IMAGE_TAG

echo "->: begin build docker image with command: docker build $BUILD_ARGS_FINAL -t $image $DOCKERFILE_ARG -f $FOLDER/Dockerfile ."
if [ ! -z "$DOCKER_REGISTRY_PW" ]; then
    echo "->: will login dockerhub before build this image"
    docker logout
    docker login --username $DOCKER_REGISTRY_USER --password $DOCKER_REGISTRY_PW
fi

docker build $BUILD_ARGS_FINAL -t $image $DOCKERFILE_ARG -f $FOLDER/Dockerfile .

if [ ! -z "$DOCKER_REGISTRY_PW" ]; then
    echo "->: will logout dockerhub after build this image"
    docker logout
fi

if [ $? -ne 0 ]; then
	echo "     Build image Fail"
	exit 1
else
	echo "     done"
fi

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# scripts done
echo "script $0 done"
echo ""