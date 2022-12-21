# Scripts
```shell
bash scripts/build_and_push_image.sh -f ${DOCKERFILE_FOLDER} -n ${IMGAE_NAME} -t ${IMAGE_TAG} -p ${DOCKER_REGISTRY_PW} -b "PARAM1=${PARAM1};PARAM2=${PARAM2}"
```

# Jenkins Agent

## Build And Push
```shell
bash scripts/build_and_push_image.sh -f . -n jenkins-agent -t IMAGE-4 -p ${DOCKER_REGISTRY_PW}

# test it
docker run  --privileged --name jenkins-agent warriortrading/jenkins-agent:IMAGE-4
```

## Mark It Public In Dockerhub
https://hub.docker.com/repository/docker/warriortrading/jenkins-agent/settings
