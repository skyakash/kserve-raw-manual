#!/bin/bash
# save_images.sh
# Run this on a machine WITH internet/Docker access.

IMAGE_LIST="image_list.txt"
TARS_DIR="tars"

if [ ! -f "$IMAGE_LIST" ]; then
    echo "Error: image_list.txt not found."
    exit 1
fi

mkdir -p "$TARS_DIR"

echo "Saving images to $TARS_DIR..."

while IFS= read -r image || [ -n "$image" ]; do
    [[ "$image" =~ ^#.*$ ]] && continue
    [[ -z "$image" ]] && continue

    # Create a safe filename from the image name
    FILE_NAME=$(echo "$image" | sed 's|/|_|g' | sed 's|:|--|g').tar
    
    echo "---------------------------------------------------"
    echo "Pulling $image..."
    docker pull "$image"

    echo "Saving to $TARS_DIR/$FILE_NAME..."
    docker save "$image" -o "$TARS_DIR/$FILE_NAME"

done < "$IMAGE_LIST"

echo "All images saved to $TARS_DIR. You can now zip this package and ship it to the customer."
