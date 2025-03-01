#!/bin/bash
source autobuild.conf
PACKAGE=$1

cd $BUILD_SCRIPTS_ROOT
cat $(find . -name $PACKAGE) | grep git &> /dev/null
if [[ $? -ne 0 ]]; then
   exit 1
fi
REPO=$(cat $(find . -name $PACKAGE) | grep URL | head -1 | sed 's/.*\.com//' | sed 's/.*\.org//' | sed 's|/|!|3' | sed 's/!.*//' | sed 's/^.//')
PROJECT_ID=$(echo $REPO | sed 's!/!%2F!')
GITLAB_SERVER=$(cat $(find . -name $PACKAGE)  | grep URL= | sed 's/URL=//' | sed 's/.com.*/.com\//g' | sed 's/.org.*/.org\//g' )
LATEST_VER=$(curl \
  -Ls "$GITLAB_SERVER/api/v4/projects/$PROJECT_ID/releases/" | jq | grep tag_name | grep -v dev | grep -v rc | grep -Eo '[0-9+]\.[0-9]+\.[0-9+]' | sort -rV | head -1)
echo $LATEST_VER
