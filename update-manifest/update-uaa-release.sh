#!/bin/bash

RELEASE_VERSION=$(cat gcs-bucket/version)
RELEASE_SHA=$(cat gcs-bucket/sha1)
RELEASE_URL=$(cat gcs-bucket/url)

cat <<EOF > git-buildstack-deployment/new-release.yml
---
releases:
- name: ${RELEASE}
url: ${RELEASE_URL}
version: ${RELEASE_VERSION}
sha1: ${RELEASE_SHA}
EOF

cat git-buildstack-deployment/new-release.yml

spruce merge git-buildstack-deployment/${YAML_FILE} git-buildstack-deployment/new-release.yml > git-buildstack-deployment-modified/${YAML_FILE}

pushd git-buildstack-deployment-modified
cat ${YAML_FILE}
git config user.name "${GIT_COMMIT_USERNAME}"
git config user.email "${GIT_COMMIT_EMAIL}"
if [[ -n $(git status --porcelain) ]]; then
    echo "Changes"
    git add .
    git commit -m "Updated ${RELEASE} release to version ${RELEASE_VERSION}"
else
    echo "No changes"
fi
popd
