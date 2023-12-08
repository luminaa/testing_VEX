#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <format> <input>"
    exit 1
fi

format=$1
input=$2

output_file_base="trivy_output_${format}"

# Function to check if input is a Docker image
is_docker_image() {
    docker image inspect "$1" > /dev/null 2>&1
}

# Function to check if input is a GitHub repo
is_github_repo() {
    [[ $1 =~ ^https://github\.com/ ]]
}

# Function to run Trivy and filter for not fixed vulnerabilities
run_trivy() {
    local input_type=$1
    local input_value=$2
    local output_file="${output_file_base}_${input_type}.txt"

    trivy "$input_type" "$input_value" -o "$output_file" -f "$format" --ignore-unfixed false
    grep -v "FIXED" "$output_file" > "${output_file_base}_not_fixed_${input_type}.txt"
}

case "$format" in
    "table"|"cyclonedx")
        ;;
    *)
        echo "Invalid format. Supported formats: table, cyclonedx"
        exit 1
        ;;
esac

if is_docker_image "$input"; then
    run_trivy image "$input"
elif is_github_repo "$input"; then
    run_trivy repo "$input"
elif [ -d "$input" ]; then
    run_trivy fs "$input"
else
    echo "Invalid input. Must be a Docker image, GitHub repo URL, or file directory."
    exit 1
fi
