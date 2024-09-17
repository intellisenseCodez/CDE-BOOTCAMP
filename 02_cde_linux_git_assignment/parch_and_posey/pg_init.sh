#!/bin/bash

# Stop execution on any error
set -e


# load environment variables from a .env file
source ../.env

# Database credentials
DB_NAME="$DB_NAME"
DB_USER="$DB_USER"
DB_PASSWORD="$DB_PASSWORD"
DB_HOST="$DB_HOST"
DB_PORT="$DB_PORT"

# Directory containing CSV files
CSV_DIR="/vagrant_data"



# Iterate over each CSV file in the directory
for csv_file in "$CSV_DIR"/*.csv; do
    echo "Importing $csv_file into $DB_NAME database..."

    table_name=$(basename $csv_file .csv)

    # Command to copy CSV file into PostgreSQL
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "\COPY public.$table_name FROM '$csv_file' WITH (FORMAT csv, HEADER true)"

    if [ $? -eq 0 ]; then
        echo "$csv_file imported successfully."
    else
        echo "Error importing $csv_file."
    fi
done


echo "All CSV files have been imported."
