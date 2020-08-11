#!/usr/bin/env bash

# exit immediately if a command exits with a non-zero status
set -e

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# define default values

# set default values of parameters

usage()
{
    echo "example :"
    echo "   bash $0 -t TAG"
    echo "parameters :"
    echo "   TAG => git commit tag. default is ${DEFAULT_TAG}"
    exit 1
}

# parse input parameters
while getopts "t:" opt; do
    case "$opt" in
        t) TAG="$OPTARG";;
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
must_param TAG

# list parameters
echo "Parameters:"
print_param TAG

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# add execute commands below

# remove tag if exists
git tag -d ${TAG} || true

# tags
git tag -a ${TAG} -m "auto-generated tag"

# deletes tag on remote in order not to fail pushing the new one
git push origin :refs/tags/${TAG}

# push tag
git push --tags

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# scripts done
echo "script $0 done"
echo ""