#!/bin/bash
function build_from_versions {
    versions_array=$1
    echo "versions_array: ${versions_array[@]}"
    substitutions=""
    for ((i = 0; i < ${#versions_array[@]}; i++)); do
        ver=${versions_array[$i]}
        substitutions+="_VERSION$((i+1))=${versions_array[$i]}," 
        image=$(gcloud compute images list --filter="name:(${ver/ltsc/}-dc-core-for-containers)" --project=windows-cloud --format="value(name)")
        substitutions+="_IMAGE$((i+1))=windows-cloud/global/images/$image,"
    done
    substitutions+="_OUTPUT_IMAGE_NAME=multiarch-demo"
    echo "substitutions: $substitutions"
    gcloud builds submit --config=cloudbuild.yaml --substitutions=$substitutions
}

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
    build_from_versions $versions_array
fi