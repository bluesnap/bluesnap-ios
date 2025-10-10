#!/bin/bash

# Check if a version number was provided
if [ -z "$1" ]
then
    echo "No version number provided. Usage: ./release_git_tag.sh version_number"
    exit 1
fi

# Use the provided version number
version=$1

# Create a new branch for this tag
git checkout -b "release-$version"

# Update the BLUESNAP_API_VERSION_HEADER_VAL in BSApiCaller.swift
sed -i '' "s/let BLUESNAP_API_VERSION_HEADER_VAL = \".*\"/let BLUESNAP_API_VERSION_HEADER_VAL = \"$version\"/g" Sources/BluesnapSdk/BSApiCaller.swift

# Add the changes to git
# git add Sources/BluesnapSdk/BSApiCaller.swift
git add .

# Commit the changes
git commit -m "Update BLUESNAP_API_VERSION_HEADER_VAL to $version"

# Push the changes and tags to the remote repository
git push origin "release-$version"

# Create a new git tag  
git tag $version

git push origin --tags