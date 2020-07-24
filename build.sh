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
    gcloud builds submit --config=multiarchBuild.yaml --substitutions=$substitutions
}