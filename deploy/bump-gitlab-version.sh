#!/bin/bash

# NOTE:
#   Need env SSH_PRIVATE_KEY to include ssh private key loaded in gitlab
#
# Test
# docker run -it --rm -u gradle -v "$PWD":/home/gradle/project -w /home/gradle/project gradle:5.5-jdk8 /bin/bash

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
VERSION_BUILD=`grep 'VERSION_BUILD=' version.properties | tail -n1 | cut -d"=" -f2`
export VERSION_BUILD

#
# Commit and push to gitlab
#
git config --global user.email "daniel@cybercow.se"
git config --global user.name "Gradle"
git add version.properties
git commit -m"Bump version build to $VERSION_BUILD"
git push gitlab