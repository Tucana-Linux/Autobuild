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
GITLAB_SERVER=$(find . -name "$PACKAGE" -exec grep -m1 '^URL=' {} \; | cut -d'=' -f2 | sed -E 's|(https?://[^/]+).*|\1|')
LATEST_VER=$(curl \
  -Ls "${GITLAB_SERVER}/api/v4/projects/$PROJECT_ID/releases/permalink/latest"  |  jq -r '.tag_name' | sed  -e 's/^v//' -e 's/.*-//')
if [[ $LATEST_VER == "null" ]]; then
   LATEST_VER=$(curl \
     -Ls "${GITLAB_SERVER}/api/v4/projects/$PROJECT_ID/repository/tags"  |  jq -r 'map(select(.name | test("-(dev|rc)") | not)) | .[0].name'  | sed  -e 's/^v//' -e 's/.*-//')
  
fi
echo $LATEST_VER
