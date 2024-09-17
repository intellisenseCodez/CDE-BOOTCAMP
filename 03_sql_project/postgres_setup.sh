#!/bin/bash

# Stop execution on any error
set -e

source /vagrant/.env

TAR_DIR="/vagrant/dvdrental.tar"

# Database credentials
DB_NAME="$DB_NAME"
DB_USER="$DB_USER"
DB_PASSWORD="$DB_PASSWORD"
DB_HOST="$DB_HOST"
DB_PORT="$DB_PORT"

print_db_usage () {
  echo "Your PostgreSQL database has been setup and can be accessed on your local machine on the forwarded port (default: 15432)"
  echo "  Host: localhost"
  echo "  Port: 15432"
  echo "  Database: $DB_NAME"
  echo "  Username: $DB_USER"
  echo "  Password: $DB_PASSWORD"
  echo ""
  echo "Admin access to postgres user via VM:"
  echo "  vagrant ssh"
  echo "  sudo su - postgres"
  echo ""
  echo "psql access to app database user via VM:"
  echo "  vagrant ssh"
  echo "  sudo su - postgres"
  echo "  PGUSER=$DB_USER PGPASSWORD=$DB_PASS psql -h localhost $DB_NAME"
  echo ""
  echo "Env variable for application development:"
  echo "  DATABASE_URL=postgresql://$DB_USER:$DB_PASS@localhost:15432/$DB_NAME"
  echo ""
  echo "Local command to access the database via psql:"
  echo "  PGUSER=$ADB_USER PGPASSWORD=$DB_PASS psql -h localhost -p 15432 $DB_NAME"
}

echo "-------------------- update package lists and upgrade all packages --------------------"
sudo apt-get update
sudo apt-get -y upgrade

echo "-------------------- installing postgres --------------------"
sudo apt-get -y install "postgresql" "postgresql-contrib"

PG_VERSION=$(psql -V | awk '{print $3}')

# Output the PostgreSQL version to confirm
echo "PostgreSQL version $PG_VERSION has been installed."


# Set up PostgreSQL user and database
echo "-------------------- creating postgres role with password --------------------"
sudo -u postgres psql -c "CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "ALTER ROLE $DB_USER WITH SUPERUSER;"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME WITH OWNER $DB_USER;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"


# Restore the database from the /vagrant/dvdrental.tar file
if [ -f /vagrant/dvdrental.tar ]; then
    echo "Restoring the dvdrental database from /vagrant/dvdrental.tar..."
    PGPASSWORD="$DB_PASSWORD" pg_restore -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" "$TAR_DIR"

    echo "Database restored successfully."
else
    echo "Error: /vagrant/dvdrental.tar file not found."
fi

echo "Successfully created PostgreSQL dev virtual machine."
echo ""
print_db_usage