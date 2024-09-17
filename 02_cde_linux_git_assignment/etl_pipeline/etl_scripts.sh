#!/bin/bash

# Stop execution on any error
set -e

# load environment variables from a .env file
source ../.env
URL="$URL"


# Define directory paths and file names
RAW_PATH="./raw"
RAW_FILE="annual-enterprise-survey-2023-financial-year-provisional.csv"
TRANSFORM_PATH="transformed"
TRANSFORM_FILE="2023_year_finance.csv"
GOLD_PATH="Gold"
GOLD_FILE="2023_year_finance_gold.csv"

# dowload data using wget or curl with a given url
function download(){
    # check if data url exist and valid
    if [ -z "$URL" ] || [[ "$URL" != *.csv ]]; then
        echo "ERROR ❌ :: Invalid or missing URL.
        -------------------------------------------------------------------
        Possible issues:
        1. Download URL not found.
        2. Download URL is not a .csv file."
        exit 1
    fi


    if command -v wget &>/dev/null; then
        echo "################## Downloading using wget ##################"
        wget -O "$RAW_PATH/$RAW_FILE" "$URL"
    elif command -v curl &>/dev/null; then
        echo "################## Downloading using curl ##################"
        curl -o "$RAW_PATH/$RAW_FILE" "$URL"
    else
        echo "ERROR ❌ :: Neither wget nor curl is installed.
        -------------------------------------------------------------------
        Please install one of these tools to proceed."
        exit 1
    fi

    if [ $? -eq 0 ]; then
        echo "Raw file downloaded successfully."
    else
        echo "ERROR ❌ :: Failed to download the file."
        exit 1
    fi
}

# Create directory if it does not exist
function create_directory() {
    if [[ ! -d "$1" ]]; then
        mkdir "$1"
        echo "INFO ℹ️  :: Directory does not exit.
        -------------------------------------------------------------------
        Directory 📁 $1 created."
    else
        echo "INFO ℹ️ ::  Directory $1 already exists."       
    fi 
}

# Check if RAW_PATH directory exists or create it
create_directory "$RAW_PATH"

# Download the file if RAW_PATH exists
download "${URL}" "${RAW_PATH}"

# check if raw file exist
if [[ -f "$RAW_PATH/$RAW_FILE" ]]; then

    echo "################## Starting ETL Process ##################"

    echo "Raw File 🗂 $RAW_PATH/$RAW_FILE found."
    
    # Create TRANSFORM_PATH directory if it does not exist
    create_directory "$TRANSFORM_PATH"

    # Extract columns and rename the header
    echo "Transforming the data..."
    cut -d ',' -f1,5,6,9 "$RAW_PATH/$RAW_FILE" > "$TRANSFORM_PATH/$TRANSFORM_FILE"
    # Use 'sed' to replace the old column name with the new one
    # sed -i '' "1s/Variable_code/variable_code/" "$TRANSFORM_PATH/$TRANSFORM_FILE"
    # head -n 1 "$RAW_PATH/$RAW_FILE" | sed 's/Variable_code/variable_code/' > "$TRANSFORM_PATH/$TRANSFORM_FILE"
    # tail -n +2 "$RAW_PATH/$RAW_FILE" | cut -d ',' -f1,5,6,9 >> "$TRANSFORM_PATH/$TRANSFORM_FILE"
    echo "Data transformed successfully."
    
    # Create GOLD_PATH directory if it does not exist
    create_directory "$GOLD_PATH"
    
    # Move the transformed file to the Gold directory
    cp "$TRANSFORM_PATH/$TRANSFORM_FILE" "$GOLD_PATH/$GOLD_FILE"
    
    # Confirm that the file has been saved to the Gold directory
    if [[ -f "$GOLD_PATH/$GOLD_FILE" ]]; then
        echo "File successfully saved to $GOLD_PATH/$GOLD_FILE."
    else
        echo "Failed to save the file to $GOLD_PATH/$GOLD_FILE."
    fi
else
    echo "File $RAW_PATH/$RAW_FILE not found."
fi

echo "################## ETL Process Completed Successfully ##################"
