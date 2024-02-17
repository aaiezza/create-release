#!/bin/sh -l

set -u

cd /github/workspace || exit 1

# Env and options
if [ -z "${GITHUB_TOKEN}" ]
then
    echo "The GITHUB_TOKEN environment variable is not defined."
    exit 1
fi

BRANCH="${1}"
NAME="${2}"
MESSAGE="${3}"
DRAFT="${4}"
PRERELEASE="${5}"
CREATE_RELEASE="${6}"
TAG="${7}"

# Fetch git tags
git fetch --depth=1 origin +refs/tags/*:refs/tags/*

LAST_HASH=$(git rev-list --tags --max-count=1)
echo "Last hash : ${LAST_HASH}"

LAST_RELEASE=$(git describe --tags "${LAST_HASH}")
echo "Last release : ${LAST_RELEASE}"
MAJOR_LAST_RELEASE=$(echo "${LAST_RELEASE}" | awk -v l=${#TAG} '{ string=substr($0, 1, l); print string; }' )
echo "Last major release : ${MAJOR_LAST_RELEASE}"

if [ "${NAME}" = "0" ]; then
	NAME="release: version ${TAG}"
fi

if [ "${MESSAGE}" = "0" ]; then
  MESSAGE=$(conventional-changelog)
fi

echo "Next release : ${TAG}"

echo "${MESSAGE}"

echo "Create release : ${CREATE_RELEASE}"

if [ "${CREATE_RELEASE}" = "true" ] || [ "${CREATE_RELEASE}" = true ]; then
  JSON_STRING=$( jq -n \
                    --arg tn "$TAG" \
                    --arg tc "$BRANCH" \
                    --arg n "$NAME" \
                    --arg b "$MESSAGE" \
                    --argjson d "$DRAFT" \
                    --argjson p "$PRERELEASE" \
                    '{tag_name: $tn, target_commitish: $tc, name: $n, body: $b, draft: $d, prerelease: $p}' )
  echo ${JSON_STRING}
  OUTPUT=$(curl -s --data "${JSON_STRING}" -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases")
  echo ${OUTPUT} | jq
fi;

echo ::set-output name=release::${TAG}
echo ::set-output name=upload_url::`echo ${OUTPUT} | jq --raw-output '.upload_url'`
