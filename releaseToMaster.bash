#!/bin/bash

#
# Copyright (c) iko.travel 2022.
#

echo "Disabling git messages for a release"
export GIT_MERGE_AUTOEDIT=no

echo "Releasing new version of iko-travel-affiliate WordPress plugin with git flow..."
echo "Enter version number. E.g. 1.2.3";

read versionNumber

# --- Pre-flight conflict guard (run BEFORE release-start / any mutation) ---
# Releasing merges develop into master. If develop has diverged (a previous
# release's back-merge was lost, or commits landed straight on master), that
# merge can CONFLICT and break the release AFTER the release branch already
# exists -- stranding you on a half-built branch. Detect it here, in memory:
# `git merge-tree` never touches the working tree (requires git >= 2.38).
echo "==> Pre-flight: checking develop merges into master without conflicts..."
if git merge-base --is-ancestor master develop; then
  echo "OK: master already contained in develop -- release merge will be clean"
elif _gtout=$(git merge-tree --write-tree --name-only develop master 2>/dev/null); then
  echo "WARN: develop diverged from master but merges cleanly -- proceeding."
  git --no-pager log --oneline master ^develop | sed 's/^/     /'
else
  echo ""
  echo "RELEASE STOPPED -- nothing changed; no release branch was created."
  echo "   Merging 'develop' into 'master' would CONFLICT and break the release."
  echo "   Conflicting files:"
  printf '%s\n' "$_gtout" | tail -n +2 | sed 's/^/     - /'
  echo ""
  echo "   Reconcile develop first, then re-run:"
  echo "     git checkout develop && git merge master   # resolve toward develop, commit"
  echo "     git push origin develop"
  echo ""
  echo "   Commits on master missing from develop:"
  git --no-pager log --oneline master ^develop | sed 's/^/     /'
  exit 1
fi

# --- release hardening: never let an ambient pull.rebase=true / pull.ff turn a
# sync-pull into a history-rewriting rebase or surprise merge. Pin every pull to
# fast-forward-only so a diverged shared branch FAILS LOUDLY instead of silently
# rebasing a just-finished release onto origin. Overrides personal git config. ---
git config --local pull.ff only
git config --local pull.rebase false
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
git pull --ff-only origin

echo "Pushing master (+ tags) to ORIGIN..."
git push
git push --tags

echo "Checking out local develop branch..."
git checkout develop

echo "Pulling ORIGIN develop into local branch..."
git pull --ff-only origin

echo "Pushing develop to ORIGIN..."
git push

echo "Enabling git messages for a release again"
export GIT_MERGE_AUTOEDIT=yes

echo "affiliate-wp-divi-plugin $versionNumber has been successfully released"
