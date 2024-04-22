#!/bin/bash

# Function to print error message and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Check if the designated branch is provided
if [[ -z $DESIGNATED_BRANCH ]]; then
    error_exit "Designated branch not provided."
fi

# Check if the release branch is provided
if [[ -z $RELEASE_BRANCH ]]; then
    error_exit "Release branch not provided."
fi

# Start Validation
echo "Starting Tag Validation..."

# Check if the tag format is correct
if [[ ! $CI_COMMIT_TAG =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error_exit "Tag format is incorrect. Tags should follow the format v1.2.3"
fi

# Check if the commit ID is in the designated branch
if git branch --contains "$DESIGNATED_BRANCH" >/dev/null 2>&1; then
    DESIGNATED_BRANCH_CHECK=false
else
    DESIGNATED_BRANCH_CHECK=true
fi

# Check if the commit's branch name is $RELEASE_BRANCH
if git branch --contains "$RELEASE_BRANCH" >/dev/null 2>&1; then
    RELEASE_BRANCH_CHECK=false
else
    RELEASE_BRANCH_CHECK=true
fi

echo "RELEASE_BRANCH: $RELEASE_BRANCH"
echo "DESIGNATED_BRANCH: $DESIGNATED_BRANCH"
echo "CI_COMMIT_BRANCH: $CI_COMMIT_BRANCH"
echo "CI_COMMIT_REF_NAME: $CI_COMMIT_REF_NAME"
echo "CI_COMMIT_SHA: $CI_COMMIT_SHA"
COMMIT_BRANCH=$(git branch -r --contains $CI_COMMIT_SHA)
echo "COMMIT_BRANCH: $COMMIT_BRANCH"
echo "COMMIT_BRANCH2: $(git branch -r --contains $CI_COMMIT_SHA)"
echo "COMMIT_BRANCH3: $(git branch --contains $CI_COMMIT_SHA)"
echo "COMMIT_BRANCH4: $(git describe --contains $CI_COMMIT_TAG)"
echo "COMMIT_BRANCH4: $(git branch --contains $(git rev-list -n 1 $CI_COMMIT_TAG))"

# Check if CI_COMMIT_BEFORE_SHA is not all zeros
if [[ "$CI_COMMIT_BEFORE_SHA" != "0000000000000000000000000000000000000000" ]]; then
    # Check if the tag is created on the latest commit of either the designated branch or the release branch
    if [[ $CI_COMMIT_SHA != $CI_COMMIT_BEFORE_SHA ]]; then
        error_exit "Tag is not created on the latest commit of the designated branch or the release branch."
    fi
fi

# If both conditions are not met, exit with error
if [[ $DESIGNATED_BRANCH_CHECK == false && $RELEASE_BRANCH_CHECK == false ]]; then
    error_exit "Commit is not in the designated branch: $DESIGNATED_BRANCH and Commit's branch name is not release/$CI_COMMIT_TAG"
fi

# If all conditions are met, the tag is valid
echo "Valid Tag: $CI_COMMIT_TAG"
