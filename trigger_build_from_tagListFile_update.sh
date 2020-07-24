#!/bin/bash
source ./build.sh
mapfile -t versions_array < tagListFile.txt
build_from_versions $versions_array
