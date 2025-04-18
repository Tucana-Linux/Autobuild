#!/bin/bash
source autobuild.conf

# Check whether a package is being held for any reason any remove it
# from the currency script
cd "$BUILD_SCRIPTS_ROOT"

# Loop over package names from both version files
cat "$AUTOBUILD_ROOT/latest-ver.txt" "$AUTOBUILD_ROOT/all-pkgver.txt" | sed 's/:.*//g' | sort -u | while IFS= read -r package; do
  # Find matching script files
  matches=$(find . -type f -not -path "./.git*" -name "$package")

  if [[ -n "$matches" ]]; then
    grep -q "HOLD_TUCANA" $matches
    if [[ $? == 0 ]]; then
      sed -i "/^$package:.*/d" "$AUTOBUILD_ROOT/latest-ver.txt"
      sed -i "/^$package:.*/d" "$AUTOBUILD_ROOT/all-pkgver.txt"
    fi
  fi
done


