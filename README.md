# Scripts
```shell
bash scripts/build_and_push_image.sh -f ${DOCKERFILE_FOLDER} -n ${IMGAE_NAME} -t ${IMAGE_TAG} -p ${DOCKER_REGISTRY_PW} -b "PARAM1=${PARAM1};PARAM2=${PARAM2}"
```

# Jenkins Agent

## Build And Push
```shell
bash scripts/build_and_push_image.sh -f jenkins-agent -n jenkins-agent -t 1.0.0 -p ${DOCKER_REGISTRY_PW}
```

## Mark It Public In Dockerhub
https://hub.docker.com/repository/docker/warriortrading/jenkins-agent/settings
