#!/bin/bash
URL="https://sourceforge.net/projects/gmerlin/rss?path=/gavl"
VERSION="$(curl -s "$URL" | grep -oP 'gavl-\K[0-9.]+(?=\.tar\.gz)')"
echo "$VERSION" | sort -rV | head -1
