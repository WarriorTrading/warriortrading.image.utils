#!/usr/bin/env bash

# exit immediately if a command exits with a non-zero status
set -e

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# define default values
DEFAULT_IMAGE_TAG="DEV-0"
DEFAULT_DOCKER_REGISTRY_USER=warriortrading
DEFAULT_BUILD_ARGS=
DEFAULT_BRANCH_IMAGE_LIMIT=69
DEFAULT_BRANCH_DEV_LIMIT=24
DEFAULT_BRANCH_LIMIT=4

# set default values of parameters
IMAGE_TAG=$DEFAULT_IMAGE_TAG
DOCKER_REGISTRY_USER=$DEFAULT_DOCKER_REGISTRY_USER
BUILD_ARGS=$DEFAULT_BUILD_ARGS

usage()
{
    echo "example :"
    echo "   bash $0 -f FOLDER -n IMAGE_NAME [-t IMAGE_TAG] [-u DOCKER_REGISTRY_USER] -p DOCKER_REGISTRY_PW [-b BUILD_ARGS]"
    echo "parameters :"
    echo "   FOLDER => folder contains Dockerfile, or Dockerfile path"
    echo "   IMAGE_NAME => image name."
    echo "   IMAGE_TAG => image tag. default is ${DEFAULT_IMAGE_TAG}"
    echo "   DOCKER_REGISTRY_USER => user name of docker hub. default is ${DEFAULT_IMAGE_TAG}"
    echo "   DOCKER_REGISTRY_PW => user password of docker hub."
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
must_param DOCKER_REGISTRY_PW

# list parameters
echo "Parameters:"
print_param FOLDER
print_param IMAGE_NAME
print_param IMAGE_TAG
print_param DOCKER_REGISTRY_USER
print_param BUILD_ARGS
echo ""

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# add execute commands below

SHELL_FOLDER=$(cd `dirname -- $0` && pwd)

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# check the limit of the tags and remove older ones.
if [[ $IMAGE_TAG != *"-"* ]]; then
  echo "Tag name should be an uppercase branch name joined a version number by '-'"
  exit 1
fi
# get branch
tag_arr=(${IMAGE_TAG//\-/ })
branch="${tag_arr[0]}"
# get limit number
limit=$DEFAULT_BRANCH_LIMIT
if [ $branch == "IMAGE" ]; then
  limit=$DEFAULT_BRANCH_IMAGE_LIMIT
elif [ $branch == "DEV" ]; then
  limit=$DEFAULT_BRANCH_DEV_LIMIT
fi

# remove old image tags
LIMIT_ARGS="-g $DOCKER_REGISTRY_USER -u $DOCKER_REGISTRY_USER -p $DOCKER_REGISTRY_PW -r $IMAGE_NAME -b $branch -l $limit"
echo "LIMIT_ARGS=$LIMIT_ARGS"
if [ $IMAGE_NAME != "jenkins-agent" ]; then
    bash $SHELL_FOLDER/remove_proceed_limit_images.sh $LIMIT_ARGS
fi

BUILD_IMAGES_ARGS="-f $FOLDER -n $IMAGE_NAME -t $IMAGE_TAG -u $DOCKER_REGISTRY_USER -p $DOCKER_REGISTRY_PW"
if [ ! -z "$BUILD_ARGS" ]; then
    echo "BUILD_ARGS: $BUILD_ARGS"
    BUILD_IMAGES_ARGS="$BUILD_IMAGES_ARGS -b $BUILD_ARGS"
fi
bash $SHELL_FOLDER/build_image_v3.sh $BUILD_IMAGES_ARGS

bash $SHELL_FOLDER/push_image_to_docker_hub.sh -n $IMAGE_NAME -t $IMAGE_TAG -u $DOCKER_REGISTRY_USER -p $DOCKER_REGISTRY_PW

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# scripts done
echo "script $0 done"
echo ""

