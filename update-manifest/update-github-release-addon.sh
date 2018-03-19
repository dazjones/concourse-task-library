#!/bin/bash

RELEASE_FILE=`find gcs-bucket -name '*.tgz'`
RELEASE_NUMBER=$(echo ${RELEASE_FILE} | sed -e 's:.*-\([0-9]\+\.[0-9]\+\.[0-9]\+\).*:\1:')
RELEASE_SHA=$(shasum ${RELEASE_FILE} | awk '{ print $1 }')
RELEASE_URL=https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/download/v${RELEASE_NUMBER}/${RELEASE}-${RELEASE_NUMBER}.tgz
YAML_FILE="git-buildstack-deployment/operations/add-${RELEASE}.yml"
YAML_FILE_MODIFIED="git-buildstack-deployment-modified/operations/add-${RELEASE}.yml"

cat <<EOF > git-buildstack-deployment/new-version.yml
---
releases:
- name: ${RELEASE}
  url: ${RELEASE_URL}
  version: ${RELEASE_NUMBER}
  sha1: ${RELEASE_SHA}
EOF

cat ${YAML_FILE}

spruce merge ${YAML_FILE} git-buildstack-deployment/new-version.yml > ${YAML_FILE_MODIFIED}

pushd git-buildstack-deployment-modified
  cat operations/add-${RELEASE}.yml
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
