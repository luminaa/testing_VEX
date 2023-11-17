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
        trivy "$image" -o "$output_file" -f table
        ;;
    "cyclonedx")
        output_file="trivy_${image//:/_}_${format}.json"
        trivy "$image" -o "$output_file" -f cyclonedx
        ;;
    *)
        echo "Invalid format. Supported formats: table, cyclonedx"
        exit 1
        ;;
esac

echo "Trivy scan completed for $image with format $format. Results saved to $output_file."