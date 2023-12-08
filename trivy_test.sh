#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <format> <input>"
    exit 1
fi

format=$1
input=$2

# extract name from input
extract_app_name() {
    local name
    if [[ "$1" =~ ^https://github.com/ ]]; then
        # Extract repository name from GitHub URL
        name=$(basename "$1")
    elif [[ "$1" =~ / ]]; then
        # Extract image name from Docker image
        name="${1##*/}"
    else
        name="$1"
    fi
    echo "${name//:/_}"
}

app_name=$(extract_app_name "$input")

# check if input is a Docker image
is_docker_image() {
    docker image inspect "$1" > /dev/null 2>&1
    echo "Is Docker Image: $?"  # debugging
    return $?
}

# check if input is a GitHub repo
is_github_repo() {
    [[ $1 =~ ^https://github.com/ ]]
    echo "Is GitHub Repo: $?"  # debugging
    return $?
}

# run Trivy and output to file
run_trivy() {
    local input_type=$1
    local input_value=$2
    local output_ext="txt"
    [ "$format" == "cyclonedx" ] || [ "$format" == "json" ] && output_ext="json"
    local output_file="trivy_output_${app_name}_${format}.${output_ext}"

    trivy "$input_type" "$input_value" -o "$output_file" -f "$format" --ignore-status fixed
}

case "$format" in
    "table"|"cyclonedx"|"json")
        ;;
    *)
        echo "Invalid format. Supported formats: table, cyclonedx, json"
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
