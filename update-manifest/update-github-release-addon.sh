#!/bin/bash

RELEASE_FILE=`find gcs-bucket -name '*.tgz'`
RELEASE_NUMBER=$(echo ${RELEASE_FILE} | sed -e 's:.*-\([0-9]\+\.[0-9]\+\.[0-9]\+\).*:\1:')
RELEASE_SHA=$(shasum ${RELEASE_FILE} | awk '{ print $1 }')
RELEASE_URL=https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/download/v${RELEASE_NUMBER}/${RELEASE}-${RELEASE_NUMBER}.tgz

cat <<EOF > git-buildstack-deployment/new-version.yml
---
releases:
- name: ${RELEASE}
  url: ${RELEASE_URL}
  version: ${RELEASE_NUMBER}
  sha1: ${RELEASE_SHA}
EOF
mkdir -p git-buildstack-deployment/operations

if [! -f git-buildstack-deployment/operations/add-${RELEASE}.yml ]
then
    echo "---" > git-buildstack-deployment/operations/add-${RELEASE}.yml
fi

cat git-buildstack-deployment/operations/add-${RELEASE}.yml

spruce merge git-buildstack-deployment/operations/add-${RELEASE}.yml git-buildstack-deployment/new-version.yml > git-buildstack-deployment-modified/operations/add-${RELEASE}.yml

pushd git-buildstack-deployment-modified
  cat ${YAML_FILE}
  git config user.name "${GIT_COMMIT_USERNAME}"
  git config user.email "${GIT_COMMIT_EMAIL}"
  if [[ -n $(git status --porcelain) ]]; then
    echo "Changes"
    git add .
    git commit -m "Updated ${RELEASE} release to version ${RELEASE_NUMBER}"
  else
    echo "No changes"
  fi
popd
