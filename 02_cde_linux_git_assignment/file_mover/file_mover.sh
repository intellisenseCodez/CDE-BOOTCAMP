#!/bin/bash

# Check if provided arguement is not equal to 2 
if [ "$#" -ne 2 ]; then
    echo "WARNING ❌ :: Invalid arguement provided.
    --------------------------------------------------
    Usage: $0 <source_directory> <destination_directory>
    Example: ./file_mover.sh ./path/to/source_dir ./path/to/destination_dir"
    exit 1
fi


SOURCE_DIR="$1"  # source directory 
TARGET_DIR="$2"  # destination directory 

# Check if source directory exists
if [[ -d "$SOURCE_DIR" ]]; then
    echo "SUCCESS ✅ :: Source directory $SOURCE_DIR found.
    -------------------------------------------------------------------"
    if [[ -d "$TARGET_DIR" ]]; then
        echo "SUCCESS ✅ :: Target directory TARGET_DIR found.
        -------------------------------------------------------------------"
    else
        mkdir -p "$TARGET_DIR"  
        echo "SUCCESS ✅ :: Directory $TARGET_DIR created successfully."
    fi
else
    # Check if destination directory did not exists, iCreate the target directory if it doesn't exist
    echo "WARNING ❌ :: Directory not found.
    --------------------------------------------------"
fi

echo "################## Starting File Moving Process ##################"

# Move all CSV files from the source directory to the target directory
mv "$SOURCE_DIR"/*.csv "$TARGET_DIR" 2>/dev/null

# Move all JSON files from the source directory to the target directory
mv "$SOURCE_DIR"/*.json "$TARGET_DIR" 2>/dev/null

# Print a message indicating the completion of the move
echo "INFO ℹ️ :: All CSV and JSON files have been moved to $TARGET_DIR"

echo "################## File Moved Successfully ##################"
