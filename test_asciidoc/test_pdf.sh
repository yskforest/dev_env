#!/bin/bash
set -e

IMAGE_NAME="dev_env_test"
INPUT_FILE="sample.adoc"

# Check if image exists
if ! docker inspect --type=image "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "Image '$IMAGE_NAME' not found. Trying 'dev_env-cpu:latest'..."
    IMAGE_NAME="dev_env-cpu"
fi

echo "Converting $INPUT_FILE using $IMAGE_NAME..."

docker run --rm -v "$(pwd):/documents" -w /documents "$IMAGE_NAME" \
    asciidoctor-pdf \
    -r asciidoctor-diagram \
    -a pdf-theme=default-with-font-fallbacks \
    -a pdf-fontsdir=/usr/share/fonts \
    "$INPUT_FILE"

echo "Done! Check sample.pdf"
