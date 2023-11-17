#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <format> <image:tag>"
    exit 1
fi

format=$1
image=$2

case "$format" in
    "table")
        output_file="trivy_${image//:/_}_${format}.txt"
        trivy image "$image" -o "$output_file" -f table
        ;;
    "cyclonedx")
        output_file="trivy_${image//:/_}_${format}.json"
        trivy image "$image" -o "$output_file" -f cyclonedx
        ;;
    *)
        echo "Invalid format. Supported formats: table, cyclonedx"
        exit 1
        ;;
esac
