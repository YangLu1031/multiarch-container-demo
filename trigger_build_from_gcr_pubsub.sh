#!/bin/bash
while true; do
    image=$(gcloud pubsub subscriptions pull windows_container_update --auto-ack --format='value(DATA)' | jq -r '.tag | split(":")[0]')
    echo "image: $image"
    if [[ $image =~ "gke-windows-builder" ]]
    then
        echo "found the image update: $image"
        gcloud builds submit --config=cloudbuild.yaml .
    fi
    sleep 5
done