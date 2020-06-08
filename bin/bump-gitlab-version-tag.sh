#!/bin/bash

# Bumps version tag in last GIT commit.
#
# This script can be used from a CD/CI scripting environment, such as gitlab.
#
# Run Locally
#   export SSH_PRIVATE_KEY=$(cat ~/.ssh/gitlab_id_rsa)
#   ./bin/bump-gitlab-version-tag.sh
#
# Setup GITLAB
#
# * Generate keys, first value in output is private key and second public key
#   mkfifo key key.pub && cat key key.pub & echo "y" | ssh-keygen -f key -q -N "" ; rm key key.pub
# * Goto gitlab Settings -> Settings/CI/CD -> Variables
#   https://gitlab.com/springville/hello-ng/-/settings/ci_cd
#   Add private key (first value) to SSH_PRIVATE_KEY Variable, mark it protected.
# * Goto gitlab Settings -> Repository -> Deploy keys
#   https://gitlab.com/springville/hello-ng/-/settings/repository
#   Add a deploy key with title "gitlab-ci" with the value of the public key (second value), set "write access allowed".
#
# NOTE
#   Need env SSH_PRIVATE_KEY to include ssh private key loaded in gitlab
#
# Read more
#   https://threedots.tech/post/automatic-semantic-versioning-in-gitlab-ci/
#
# Test to run from same docker container as in gitlab.
#   export SSH_PRIVATE_KEY=$(cat ~/.ssh/gitlab_id_rsa)
#   docker run --env SSH_PRIVATE_KEY -it --rm -u gradle -v "$PWD":/home/gradle/project -w /home/gradle/project gradle:5.5-jdk8 ./bin/bump-gitlab-version-tag.sh docker

#
# Configuration, needs to be done per project.
#
export PROJECT=springville
export APP=hello-ng

#
# Check command line parameter
#
[ -z "$1" ] && echo "$0 [local|docker]"
ENVIRONMENT=$1

#
# Validate needed environment variables
#
[ -z "$SSH_PRIVATE_KEY" ] && echo "Need SSH_PRIVATE_KEY" && exit

echo "Bump version read from last git tag"
echo "====================================="
{
  VERSION=$(git log --tags --simplify-by-decoration --pretty="format:%D" | sed 's/^[^0-9]*\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/' | head -n1 | awk 'BEGIN{FS=".";OFS="."} {$NF+=1; print $0}')
} &>/dev/null
[ "$VERSION" == "1.." ] && VERSION="1.0.0"
[ -z "$VERSION" ] && VERSION="1.0.0"
echo -n "  Last 10 versions: "
echo $(git log --tags --simplify-by-decoration --pretty="format:%D" | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/' | tr "\n" " ")
echo "  New version $VERSION"

[ $ENVIRONMENT == "docker" ] && {
  echo
  echo "Setup SSH keys for git"
  echo "========================"
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  ssh-keyscan gitlab.com >>~/.ssh/known_hosts && chmod 644 ~/.ssh/known_hosts
  cp ~/.ssh/known_hosts ~/.ssh/known_hosts.bak
  sort ~/.ssh/known_hosts.bak | uniq > ~/.ssh/known_hosts
  eval $(ssh-agent -s)
  ssh-add <(echo "$SSH_PRIVATE_KEY")
}
echo
echo "Commit and push to gitlab"
echo "========================="
[ $ENVIRONMENT == "docker" ] && {
  git config --global user.email "daniel@cybercow.se"
  git config --global user.name "bump-gitlab-version-tag.sh"
}
git tag $VERSION
[ $ENVIRONMENT == "docker" ] && {
  git remote add gitlab git@gitlab.com:${PROJECT}/${APP}.git
  git push gitlab --tag
}
