#!/bin/bash
source autobuild.conf
URL=https://gstreamer.freedesktop.org/src/gst-plugins-bad/
PACKAGE_PREFIX=gst-plugins-bad

VERSIONS_REPEAT=$(python3 $SCRAPER_LOCATIONS/classic-scrape.py $URL | grep $PACKAGE_PREFIX- | sed 's/.*-//g' | sed 's/.[a-z].*//g')
VERSIONS=$(awk 'BEGIN{RS=ORS="\n"}!a[$0]++' <<< $VERSIONS_REPEAT)

echo $VERSIONS  | sed -e 's/\ /\n/g'  -e 's/[[:alpha:]]//g' | grep -E '[0-9]\.[0-9][0,2,4,6,8].[0-9]+' | sort -rV | head -1
