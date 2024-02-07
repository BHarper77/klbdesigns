#!/bin/bash

PARAMS=('-m 6 -q 70 -mt -af -progress')

if [ $# -ne 0 ]; then
    PARAMS=$@;
fi

# Find all image files recursively in the current directory and its subdirectories
find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.tif" -o -iname "*.tiff" -o -iname "*.png" \) | while read -r FILE; do
    # Convert each image file to WebP format
    libwebp-1.3.2-windows-x64/bin/cwebp.exe $PARAMS "$FILE" -o "${FILE%.*}".webp;
done
