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
if [[ $CI_COMMIT_BRANCH != $DESIGNATED_BRANCH ]]; then
    DESIGNATED_BRANCH_CHECK=false
else
    DESIGNATED_BRANCH_CHECK=true
fi

# Check if the commit's branch name is $RELEASE_BRANCH
if [[ $CI_COMMIT_BRANCH != $RELEASE_BRANCH ]]; then
    RELEASE_BRANCH_CHECK=false
else
    RELEASE_BRANCH_CHECK=true
fi

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
