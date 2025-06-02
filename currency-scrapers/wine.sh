#!/bin/bash
PACKAGE=$1

cd $BUILD_SCRIPTS_ROOT
REPO=wine/$1
PROJECT_ID=$(echo $REPO | sed 's!/!%2F!')
GITLAB_SERVER="https://gitlab.winehq.org"
LATEST_VER=$(curl \
  -Ls "$GITLAB_SERVER/api/v4/projects/$PROJECT_ID/releases/permalink/latest" | grep tag_name | sed 's/.$//' | sed 's/\"//g' | sed 's/.*://' | sed 's/^.//' | sed 's/.*-//g' | sed 's/v//' | sed 's!.*/!!' | sed 's/.$//' )
# Some apps have TAG_OVERRIDE because the tags are newer than the releases, in that case use those instead
echo $LATEST_VER
