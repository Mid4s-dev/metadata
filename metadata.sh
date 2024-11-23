#!/bin/bash

# Force English locale to avoid localized date format issues
export LC_TIME="en_US.UTF-8"

# Check for required arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <folder_path> <start_date>"
    echo "Example: $0 /path/to/folder '2023-01-01'"
    exit 1
fi

# Arguments
FOLDER_PATH=$1
START_DATE=$2

# Check if the folder exists
if [ ! -d "$FOLDER_PATH" ]; then
    echo "Error: Folder '$FOLDER_PATH' does not exist."
    exit 1
fi

# Convert start date to epoch
START_EPOCH=$(date -d "$START_DATE" +%s 2>/dev/null)
if [ -z "$START_EPOCH" ]; then
    echo "Error: Invalid start date format '$START_DATE'. Use 'YYYY-MM-DD'."
    exit 1
fi

# Get the current date in epoch time
END_EPOCH=$(date +%s)

if [ "$START_EPOCH" -gt "$END_EPOCH" ]; then
    echo "Error: Start date cannot be in the future."
    exit 1
fi

# Function to generate a random date in the range
generate_random_date() {
    local RANGE=$((END_EPOCH - START_EPOCH))
    local RANDOM_OFFSET=$(shuf -i 0-"$RANGE" -n 1) # Generate a random offset
    local RANDOM_EPOCH=$((START_EPOCH + RANDOM_OFFSET))
    
    # Generate the random date and remove fractional seconds (using whole seconds)
    date -d "@$RANDOM_EPOCH" +"%Y%m%d%H%M.%S" | sed 's/\.[0-9]*$//'  # Remove decimal seconds
}

# Modify metadata for each file and folder in the target folder
find "$FOLDER_PATH" -print0 | while IFS= read -r -d '' ITEM; do
    RANDOM_DATE=$(generate_random_date)

    # Validate the generated date
    if ! date -d "$RANDOM_DATE" &>/dev/null; then
        echo "Error: Generated invalid date for $ITEM. Skipping."
        continue
    fi

    touch -t "$RANDOM_DATE" "$ITEM"
    echo "Modified '$ITEM' to date: $(date -d "$RANDOM_DATE")"
done

echo "Metadata modification complete."
