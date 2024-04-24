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

DESIGNATED_BRANCH_CHECK=false
RELEASE_BRANCH_CHECK=false

# Start Validation
echo "Starting Tag Validation..."

# Check if the tag format is correct
if [[ ! $CI_COMMIT_TAG =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error_exit "Tag format is incorrect. Tags should follow the format v1.2.3"
fi

# Check if the commit ID is in the designated branch
check_designated_branch() {
    git fetch origin "$DESIGNATED_BRANCH" >/dev/null 2>&1 && git checkout "$DESIGNATED_BRANCH" >/dev/null 2>&1 && git branch --contains "$CI_COMMIT_SHA" >/dev/null 2>&1


    # Check the exit code of the git commands
    if [ $? -eq 0 ]; then
        echo "Within the designated branch"
        DESIGNATED_BRANCH_CHECK=true
    else
        echo "Not in the designated branch"
    fi
}

# Check if the commit ID is in the release branch
check_release_branch() {
    git fetch origin "$RELEASE_BRANCH" >/dev/null 2>&1 && git checkout "$RELEASE_BRANCH" >/dev/null 2>&1 && git branch --contains "$CI_COMMIT_SHA" >/dev/null 2>&1


    # Check the exit code of the git commands
    if [ $? -eq 0 ]; then
        echo "Within the release branch"
        if [ $(git rev-parse "$RELEASE_BRANCH") == "$CI_COMMIT_SHA" ]; then
        echo "Within the release branch and latest commit"
            RELEASE_BRANCH_CHECK=true
        else
        echo "Within the release branch but not the latest commit"
        fi
    else
        echo "Not in the release branch"
    fi
}

check_designated_branch

check_release_branch

# If both conditions are not met, exit with error
if [[ $DESIGNATED_BRANCH_CHECK == false && $RELEASE_BRANCH_CHECK == false ]]; then
    error_exit "Commit is not in the designated branch: $DESIGNATED_BRANCH and Commit's branch name is not release/$CI_COMMIT_TAG"
fi

# If all conditions are met, the tag is valid
echo "Valid Tag: $CI_COMMIT_TAG"
