# Scripts
```shell
bash scripts/build_and_push_image.sh -f ${DOCKERFILE_FOLDER} -n ${IMGAE_NAME} -t ${IMAGE_TAG} -p ${DOCKER_REGISTRY_PW} -b "PARAM1=${PARAM1};PARAM2=${PARAM2}"
```

# Jenkins Agent

## Build And Push
```shell
DOCKER_REGISTRY_PW=******
NEW_AGENT_TAG=IMAGE-10
bash scripts/build_and_push_image.sh -f . -n jenkins-agent -t ${NEW_AGENT_TAG} -p ${DOCKER_REGISTRY_PW}

# test it
docker run  --privileged --name jenkins-agent warriortrading/jenkins-agent:${NEW_AGENT_TAG}
```

## Mark It Public In Dockerhub
https://hub.docker.com/repository/docker/warriortrading/jenkins-agent/settings
