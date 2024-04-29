#!/bin/bash
set -e

# Function to print error message and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}
# Check if the designated branch is provided
if [[ -z $DESIGNATED_BRANCH ]]; then
    error_exit "Designated branch not provided."
fi



tag_version=$(echo "$CI_COMMIT_TAG" | sed 's/v//')
# Extracting the minor version (e.g., for v1.2.5, it extracts 1.2)
minor_version=$(echo "$tag_version" | cut -d. -f1,2)
RELEASE_BRANCH=release/"$minor_version"

# Start Validation
echo "Starting Tag Validation..."

# Check if the tag format is correct
if [[ ! $CI_COMMIT_TAG =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error_exit "Tag format is incorrect. Tags should follow the format v1.2.3"
fi


# if [[ $(git branch -a --contains tags/$minor_version) == *"$RELEASE_BRANCH"* ]]; then
#     echo "Within the release branch"
#     if [ $(git rev-parse "$RELEASE_BRANCH") == "$CI_COMMIT_SHA" ]; then
#         echo "Tag: "$CI_COMMIT_TAG" is ithin the release branch: "$RELEASE_BRANCH" and latest commit: "$CI_COMMIT_SHA""
#     else
#         error_exit "Within the release branch: "$RELEASE_BRANCH" but not the latest commit"
#     fi
# else
#     echo "Not in the release branch"
#     if [ $(git rev-parse "$DESIGNATED_BRANCH") == "$CI_COMMIT_SHA" ]; then
#         echo "Tag: "$CI_COMMIT_TAG" is ithin the release branch: "$DESIGNATED_BRANCH" and latest commit: "$CI_COMMIT_SHA""
#     else
#         error_exit "Commit is not in the designated branch: "$DESIGNATED_BRANCH" and Commit's branch name is not "$RELEASE_BRANCH""
#     fi
# fi
git pull --all
echo "first: $(git rev-parse "$DESIGNATED_BRANCH")"
echo "DESIGNATED_BRANCH:  "$DESIGNATED_BRANCH""
echo "second: $(git branch -a --contains tags/"$CI_COMMIT_TAG")"
echo "CI_COMMIT_TAG: "$CI_COMMIT_TAG""
echo "third: $(git rev-parse "$RELEASE_BRANCH")"
echo "RELEASE_BRANCH: "$RELEASE_BRANCH""

if [ $(git rev-parse "$DESIGNATED_BRANCH") == "$CI_COMMIT_SHA" ]; then
    echo "Tag: "$CI_COMMIT_TAG" is within the designated branch: "$DESIGNATED_BRANCH" and latest commit: "$CI_COMMIT_SHA""
else
    if [[ $(git branch -a --contains tags/"$CI_COMMIT_TAG") == *"$RELEASE_BRANCH"* ]]; then
        if [ $(git rev-parse "$RELEASE_BRANCH") == "$CI_COMMIT_SHA" ]; then
             echo "Tag: "$CI_COMMIT_TAG" is ithin the release branch: "$RELEASE_BRANCH" and latest commit: "$CI_COMMIT_SHA""
        else
            error_exit "Within the release branch: "$RELEASE_BRANCH" but not the latest commit"
        fi
    else
        error_exit "Commit is not in the designated branch: "$DESIGNATED_BRANCH" and the branch based on is not "$RELEASE_BRANCH""
    fi
fi
