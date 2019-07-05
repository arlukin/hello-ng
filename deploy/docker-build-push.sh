#!/bin/sh

# Push docker image too google cloud registry.
#
#
# Setup GITLAB
#
# * mkfifo key key.pub && cat key key.pub & echo "y" | ssh-keygen -f key -q -N "" ; rm key key.pub
# * Add settings to project
#   * Add deploy key to gitlab Settings -> Repository
#   * Add the private part as a new Variable in the Settings/CI/CD section, name it SSH_PRIVATE_KEY
#
# NOTE
#   Need env SSH_PRIVATE_KEY to include ssh private key loaded in gitlab
#
# Read more
#   https://threedots.tech/post/automatic-semantic-versioning-in-gitlab-ci/
#
# Test
#   docker run -it --rm --privileged -v "$PWD":/home/docker/project -w /home/docker/project docker:18 /bin/sh


#
# Configuration, needs to be done per project.
#
export PROJECT=springville
export APP=hello-ng
export KEY_NAME=gitlab-ci-push
export KEY_DISPLAY_NAME="Gitlab CI Push"
export DOCKER_IMAGE_LOCAL=${PROJECT}/${APP}:latest
export DOCKER_IMAGE_REMOTE=gcr.io/${PROJECT}/${APP}:${VERSION_FULL}

#
# Get version number
#
VERSION_NAME=`grep 'VERSION_NAME=' version.properties | tail -n1 | cut -d"=" -f2`
VERSION_BUILD=`grep 'VERSION_BUILD=' version.properties | tail -n1 | cut -d"=" -f2`
VERSION_FULL="${VERSION_NAME}.${VERSION_BUILD}"
[ -z "$VERSION_FULL" ] && echo "Failed to get VERSION_FULL" && exit


#
# Build, tag and push the image
#
docker build -t $DOCKER_IMAGE_LOCAL . || { echo 'docker build failed' ; exit 1; }
docker tag $DOCKER_IMAGE_LOCAL $DOCKER_IMAGE_REMOTE

echo $GOOGLE_CLOUD_REGISTRY_PASS
echo $GOOGLE_CLOUD_REGISTRY_PASS | docker login -u _json_key --password-stdin https://gcr.io
docker push $DOCKER_IMAGE_REMOTE

exit 0

#
# Setup service account
#
gcloud iam service-accounts create ${KEY_NAME} --display-name="${KEY_DISPLAY_NAME}"
gcloud iam service-accounts list
gcloud iam service-accounts keys create --iam-account ${KEY_NAME}@${PROJECT}.iam.gserviceaccount.com key.json

# TODO check other permissions https://cloud.google.com/storage/docs/access-control/iam-roles
gcloud projects add-iam-policy-binding ${PROJECT} \
    --member serviceAccount:${KEY_NAME}@${PROJECT}.iam.gserviceaccount.com \
    --role roles/storage.admin