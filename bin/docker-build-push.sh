#!/bin/sh

# Build and push docker image too google cloud registry.
#
# NOTE
#   Need env $GOOGLE_CLOUD_REGISTRY_PASS to include ssh private key loaded in gitlab
#   The env represent the service account for Cloud Registry. Instructions for this
#   can be found in the readme file in springville-cluster project.
#
# Test
#   export GOOGLE_CLOUD_REGISTRY_PASS=`cat key.json`
#   docker run --name "docker-builder" -d --privileged docker:18-dind
#   docker run -it --rm --link docker-builder:docker --env GOOGLE_CLOUD_REGISTRY_PASS  -v "$PWD":/home/docker/project -w /home/docker/project docker:18  ./deploy/docker-build-push.sh
#   docker kill docker-builder

#
# Configuration, needs to be done per project.
#
export PROJECT=springville
export APP=hello-ng


#
# Get version number
#
VERSION=`grep 'version=' build/generated-resources/version.config | tail -n1 | cut -d"=" -f2`
[ -z "$VERSION" ] && echo "Failed to get VERSION." && exit
[ -z "$GOOGLE_CLOUD_REGISTRY_PASS" ] && echo "Failed to get GOOGLE_CLOUD_REGISTRY_PASS." && exit


#
# Variables used in script
#
export DOCKER_IMAGE_LOCAL=${PROJECT}/${APP}:latest
export DOCKER_IMAGE_REMOTE=gcr.io/${PROJECT}/${APP}:${VERSION}
echo "Build $DOCKER_IMAGE_REMOTE"


#
# Build, tag and push the image
#
docker build -t $DOCKER_IMAGE_LOCAL . || { echo 'docker build failed' ; exit 1; }
docker tag $DOCKER_IMAGE_LOCAL $DOCKER_IMAGE_REMOTE

echo $GOOGLE_CLOUD_REGISTRY_PASS | docker login -u _json_key --password-stdin https://gcr.io
docker push $DOCKER_IMAGE_REMOTE