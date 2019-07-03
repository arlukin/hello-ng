#!/usr/bin/env python3

# Copied from
# https://threedots.tech/post/automatic-semantic-versioning-in-gitlab-ci/
#
# * mkfifo key key.pub && cat key key.pub & echo "y" | ssh-keygen -f key -q -N "" ; rm key key.pub
# * Add settings to project
#   * Add deploy key to gitlab Settings -> Repository
#   * Add the private part as a new Variable in the Settings/CI/CD section, name it SSH_PRIVATE_KEY
#
import os
import re
import sys
import semver
import subprocess


def git(*args):
    return subprocess.check_output(["git"] + list(args))


def tag_repo(tag):
    url = os.environ["CI_REPOSITORY_URL"]

    # Transforms the repository URL to the SSH URL
    # Example input: https://gitlab-ci-token:xxxxxxxxxxxxxxxxxxxx@gitlab.com/threedotslabs/ci-examples.git
    # Example output: git@gitlab.com:threedotslabs/ci-examples.git
    push_url = re.sub(r'.+@([^/]+)/', r'git@\1:', url)

    git("remote", "set-url", "--push", "origin", push_url)
    git("tag", tag)
    git("push", "origin", tag)


def bump(latest):
    # TODO decide what to bump
    # Then use bump_patch, bump_minor or bump_major
    return semver.bump_patch(latest)


def main():
    try:
        latest = git("describe", "--tags").decode().strip()
    except subprocess.CalledProcessError:
        # No tags in the repository
        version = "1.0.0"
    else:
        # Skip already tagged commits
        if '-' not in latest:
            print(latest)
            return 0

        version = bump(latest)

    tag_repo(version)
    print(version)

    return 0


if __name__ == "__main__":
    sys.exit(main())