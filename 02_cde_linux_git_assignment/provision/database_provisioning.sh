#!/bin/bash

# Stop execution on any error
set -e

echo "-------------------- updating package lists --------------------"
sudo apt-get update

echo "-------------------- installing postgres --------------------"
sudo apt-get install -y postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql


# source path of the .env file
SOURCE_ENV_PATH="/vagrant/.env"

# destination path in the Vagrant VM
DEST_ENV_PATH="/vagrant_data/.env"

# copy the .env into /vagrant_data/.env
if [ -f "$SOURCE_ENV_PATH" ]; then
  # Copy the .env file to the destination path
  cp "$SOURCE_ENV_PATH" "$DEST_ENV_PATH"
  echo ".env file has been copied to $DEST_ENV_PATH"
else
  echo "Error: .env file not found at $SOURCE_ENV_PATH"
  exit 1
fi

# load environment variables from a .env file
source $DEST_ENV_PATH

# Database credentials
DB_NAME="$DB_NAME"
DB_USER="$DB_USER"
DB_PASSWORD="$DB_PASSWORD"
DB_HOST="$DB_HOST"
DB_PORT="$DB_PORT"


# Set up PostgreSQL user and database
echo "-------------------- creating postgres role with password --------------------"
sudo -u postgres psql -c "CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "ALTER ROLE $DB_USER WITH SUPERUSER;"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

 # Create necessary tables in the 'posey' database
sudo -u postgres psql -d $DB_NAME -c "
    CREATE TABLE accounts (
    id integer NOT NULL,
    name character varying NOT NULL,
    website character varying,
    lat numeric,
    long numeric,
    primary_poc character varying,
    sales_rep_id integer
);


CREATE TABLE orders (
    id integer NOT NULL,
    account_id integer NOT NULL,
    occurred_at timestamp NOT NULL,
    standard_qty integer,
    gloss_qty integer,
    poster_qty integer,
    total integer,
    standard_amt_usd numeric,
    gloss_amt_usd numeric,
    poster_amt_usd numeric,
    total_amt_usd numeric
);

CREATE TABLE region (
    id integer NOT NULL,
    name character varying NOT NULL
);

CREATE TABLE sales_reps (
    id integer NOT NULL,
    name character varying NOT NULL,
    region_id integer NOT NULL
);

CREATE TABLE web_events (
    id integer NOT NULL,
    account_id integer NOT NULL,
    occurred_at timestamp NOT NULL,
    channel character varying NOT NULL
);
    "



