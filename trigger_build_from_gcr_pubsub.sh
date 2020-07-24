#!/bin/bash
image=$(gcloud pubsub subscriptions pull windows_container_update --auto-ack --format='value(DATA)' | jq -r '.tag | split(":")[0]')
if [ -n "$image" ]
then
    echo "image: $image"
    tag_list=$(gcloud container images list-tags $image --format='value(TAGS)' --filter='tags:*') 
    echo "tag_list: ${tag_list[@]}"
    declare -a versions_array
    for tag in ${tag_list[@]}; do
        versions_array+=(`echo $tag | tr ',' ' '`)
    done
    echo "versions_array: ${versions_array[@]}"
    source ./build.sh
    build_from_versions $versions_array
fi