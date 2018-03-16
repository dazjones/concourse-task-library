#!/bin/bash
STEMCELL_VERSION=$(cat gcs-bucket/version)
STEMCELL_SHA=$(cat gcs-bucket/sha1)
STEMCELL_URL=$(cat gcs-bucket/url)

cat <<EOF > git-buildstack-deployment/new-stemcell.yml
---
stemcells:
- alias: default
  os: ubuntu-trusty
  version: "${STEMCELL_VERSION}"
EOF

cat git-buildstack-deployment/new-stemcell.yml

spruce merge git-buildstack-deployment/${YAML_FILE} git-buildstack-deployment/new-stemcell.yml > git-buildstack-deployment-modified/${YAML_FILE}

pushd git-buildstack-deployment-modified
cat ${YAML_FILE}
git config user.name "${GIT_COMMIT_USERNAME}"
git config user.email "${GIT_COMMIT_EMAIL}"
if [[ -n $(git status --porcelain) ]]; then
    echo "Changes"
    git add .
    git commit -m "Updated stemcell to version ${STEMCELL_VERSION}"
else
    echo "No changes"
fi
popd
