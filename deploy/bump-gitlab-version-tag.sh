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
#   export SSH_PRIVATE_KEY=$(cat ~/.ssh/gitlab_id_rsa)
#   docker run --env SSH_PRIVATE_KEY -it --rm -u gradle -v "$PWD":/home/gradle/project -w /home/gradle/project gradle:5.5-jdk8 ./deploy/bump-gitlab-version-tag.sh


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
git remote add gitlab git@gitlab.com:springville/hello-ng.git
git push gitlab --tag
