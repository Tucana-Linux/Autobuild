#!/bin/bash
PACKAGE=$1
wget "https://storage.googleapis.com/aom-releases/" --output-document index.xml &> /dev/null
latest=$(cat index.xml | grep -oP '(?<=<Key>libaom-)[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.gz)' \
    | sort -V \
    | tail -n 1)

echo "$latest"
