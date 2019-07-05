#!/bin/bash

# Bumps VERSION_BUILD in version.properties and push file to gitlab.
# Will set environment variable VERSION_FULL, VERSION_NAME, VERSION_BUILD.
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
#   docker run -it --rm -u gradle -v "$PWD":/home/gradle/project -w /home/gradle/project gradle:5.5-jdk8 /bin/bash


#
# Validate needed environment variables
#
[ -z "$SSH_PRIVATE_KEY" ] && echo "Need SSH_PRIVATE_KEY" && exit

#
# Bump VERSION_BUILD
#
sed -i -r 's/(.*)(VERSION_BUILD=)([0-9]+)(.*)/echo "\1\2$((\3+1))\4"/ge'  version.properties
sed -r 's/(.*)(VERSION_BUILD=)([0-9]+)(.*)/echo "\3"/ge'  version.properties


#
# Set up ssh keys for git
#
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && chmod 644 ~/.ssh/known_hosts
eval $(ssh-agent -s)
ssh-add <(echo "$SSH_PRIVATE_KEY")

#
# Read VERSION_BUILD from version.properties  file
#
VERSION_NAME=`grep 'VERSION_NAME=' version.properties | tail -n1 | cut -d"=" -f2`
VERSION_BUILD=`grep 'VERSION_BUILD=' version.properties | tail -n1 | cut -d"=" -f2`
VERSION_FULL="${VERSION_NAME}.${VERSION_BUILD}
export VERSION_FULL
export VERSION_NAME
export VERSION_BUILD


#
# Commit and push to gitlab
#
git config --global user.email "daniel@cybercow.se"
git config --global user.name "Gradle"
git add version.properties
git commit -m"Bump version build to $VERSION_FULL"
git push gitlab