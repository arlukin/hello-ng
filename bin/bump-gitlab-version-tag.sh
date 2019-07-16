#!/bin/bash

# Bumps VERSION_BUILD in version.properties and push file to gitlab.
# Will set environment variable VERSION_FULL, VERSION_NAME, VERSION_BUILD.
#
# Setup GITLAB
#
# * Generate keys, first value is private key and second public key
#   mkfifo key key.pub && cat key key.pub & echo "y" | ssh-keygen -f key -q -N "" ; rm key key.pub
# * Goto gitlab Settings -> Settings/CI/CD -> Variables
#   https://gitlab.com/springville/hello-ng/-/settings/ci_cd
#   Add private key (first value) to SSH_PRIVATE_KEY Variable, mark it protected.
# * Goto gitlab Settings -> Repository -> Deploy keys
#   https://gitlab.com/springville/hello-ng/-/settings/repository
#   Add a deploy key with title "gitlab-ci" with the value of the public key (second value), set "write access allowed".
# NOTE
#   Need env SSH_PRIVATE_KEY to include ssh private key loaded in gitlab
#
# Read more
#   https://threedots.tech/post/automatic-semantic-versioning-in-gitlab-ci/
#
# Test
#   export SSH_PRIVATE_KEY=$(cat ~/.ssh/gitlab_id_rsa)
#   docker run --env SSH_PRIVATE_KEY -it --rm -u gradle -v "$PWD":/home/gradle/project -w /home/gradle/project gradle:5.5-jdk8 ./bin/bump-gitlab-version-tag.sh

#
# Configuration, needs to be done per project.
#
export PROJECT=springville
export APP=hello-ng

#
# Validate needed environment variables
#
[ -z "$SSH_PRIVATE_KEY" ] && echo "Need SSH_PRIVATE_KEY" && exit


echo "Bump version read from last git tag"
echo "====================================="
{
    VERSION=`git for-each-ref refs/tags --sort=-taggerdate --format='%(refname:short)' --count=1 |  awk 'BEGIN{FS=".";OFS="."} {$NF+=1; print $0}'`
} &> /dev/null
[ "$VERSION" == "1.." ] && VERSION="1.0.0"
[ -z "$VERSION" ] && VERSION="1.0.0"
echo -n "  Last 10 versions: "
echo `git for-each-ref refs/tags --sort=-taggerdate --format='%(refname:short)' --count=10`
echo "  New version $VERSION"


echo
echo "Setup SSH keys for git"
echo "========================"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && chmod 644 ~/.ssh/known_hosts
eval $(ssh-agent -s)
ssh-add <(echo "$SSH_PRIVATE_KEY")


echo
echo "Commit and push to gitlab"
echo "========================="
git config --global user.email "daniel@cybercow.se"
git config --global user.name "Gradle"
git tag $VERSION
git remote add gitlab git@gitlab.com:${PROJECT}/${APP}.git
git push gitlab --tag
