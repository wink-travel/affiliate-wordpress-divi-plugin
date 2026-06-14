#!/bin/bash

#
# Copyright (c) iko.travel 2022.
#

echo "Disabling git messages for a release"
export GIT_MERGE_AUTOEDIT=no

echo "Releasing new version of iko-travel-affiliate WordPress plugin with git flow..."
echo "Enter version number. E.g. 1.2.3";

read versionNumber

git cliff --unreleased --tag $versionNumber --sort newest --prepend CHANGELOG.md

versionNumber="v${versionNumber}";

echo "Committing version changes for $versionNumber"
git commit -a -m "build: bookmark: merge to master [no ci]

Version bump to $versionNumber registered

Ops: $USER
"

git push --follow-tags origin develop

echo "Calling 'git flow release $versionNumber'"
git flow release start $versionNumber

# Ensure git-flow merge/back-merge commits are skipped by CI, independent of any
# machine-specific global git config. git-flow-next exposes no CLI flag for the
# back-merge message, so the only portable way to tag it [no ci] is local config.
git config --local gitflow.release.finish.mergemessage  "chore: merge %b into %p [no ci]"
git config --local gitflow.release.finish.updatemessage "chore: sync %b from %p [no ci]"

echo "Calling 'git flow finish -m $versionNumber $versionNumber'"
git flow release finish -m "$versionNumber [no ci]" $versionNumber

echo "Checking out master..."
git checkout master

echo "Pulling ORIGIN master into local branch..."
git pull origin

echo "Pushing master (+ tags) to ORIGIN..."
git push
git push --tags

echo "Checking out local develop branch..."
git checkout develop

echo "Pulling ORIGIN develop into local branch..."
git pull origin

echo "Pushing develop to ORIGIN..."
git push

echo "Enabling git messages for a release again"
export GIT_MERGE_AUTOEDIT=yes

echo "affiliate-wp-divi-plugin $versionNumber has been successfully released"
