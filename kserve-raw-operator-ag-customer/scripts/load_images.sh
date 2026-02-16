#!/bin/bash
# load_images.sh
# Run this on the CUSTOMER machine (air-gapped) with access to a local registry.

LOCAL_REGISTRY=$1
TARS_DIR="tars"
IMAGE_LIST="image_list.txt"

if [ -z "$LOCAL_REGISTRY" ]; then
    echo "Usage: ./load_images.sh <LOCAL_REGISTRY>"
    exit 1
fi

if [ ! -d "$TARS_DIR" ]; then
    echo "Error: $TARS_DIR directory not found. Did you run save_images.sh first?"
    exit 1
fi

echo "Loading images and pushing to $LOCAL_REGISTRY..."

while IFS= read -r image || [ -n "$image" ]; do
    [[ "$image" =~ ^#.*$ ]] && continue
    [[ -z "$image" ]] && continue

    FILE_NAME=$(echo "$image" | sed 's|/|_|g' | sed 's|:|--|g').tar
    
    echo "---------------------------------------------------"
    echo "Loading $TARS_DIR/$FILE_NAME..."
    docker load -i "$TARS_DIR/$FILE_NAME"

    # Tag and push
    IMAGE_NAME=$(echo "$image" | sed -E 's|^([^/]+\.[^/]+/)?||')
    NEW_TAG="$LOCAL_REGISTRY/$IMAGE_NAME"

    echo "Tagging as $NEW_TAG..."
    docker tag "$image" "$NEW_TAG"

    echo "Pushing to $LOCAL_REGISTRY..."
    docker push "$NEW_TAG"

done < "$IMAGE_LIST"

echo "Images loaded and pushed successfully!"
