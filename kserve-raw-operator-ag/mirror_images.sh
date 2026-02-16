#!/bin/bash
# mirror_images.sh
# Usage: ./mirror_images.sh <LOCAL_REGISTRY>

LOCAL_REGISTRY=$1

if [ -z "$LOCAL_REGISTRY" ]; then
    echo "Usage: ./mirror_images.sh <LOCAL_REGISTRY>"
    echo "Example: ./mirror_images.sh my-private-registry.com:5000"
    exit 1
fi

IMAGE_LIST="image_list.txt"

if [ ! -f "$IMAGE_LIST" ]; then
    echo "Error: image_list.txt not found."
    exit 1
fi

echo "Starting image mirroring to $LOCAL_REGISTRY..."

while IFS= read -r image || [ -n "$image" ]; do
    # Skip comments and empty lines
    [[ "$image" =~ ^#.*$ ]] && continue
    [[ -z "$image" ]] && continue

    echo "---------------------------------------------------"
    echo "Processing $image..."

    # Pull the image
    docker pull "$image"

    # Define the new tag
    # Remove registry prefix if present to normalize for local registry
    # e.g., quay.io/olm -> local-registry/olm
    IMAGE_NAME=$(echo "$image" | sed -E 's|^([^/]+\.[^/]+/)?||')
    NEW_TAG="$LOCAL_REGISTRY/$IMAGE_NAME"

    echo "Tagging as $NEW_TAG..."
    docker tag "$image" "$NEW_TAG"

    echo "Pushing to $LOCAL_REGISTRY..."
    docker push "$NEW_TAG"

done < "$IMAGE_LIST"

echo "Mirroring complete!"
echo "Now you can update your manager.yaml and helm values to use $LOCAL_REGISTRY."
