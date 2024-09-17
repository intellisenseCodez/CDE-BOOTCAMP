#!/bin/bash

# Update package list and install cron if not already installed
sudo apt-get update
sudo apt-get install cron -y


# Start and enable the cron service
sudo systemctl start cron
sudo systemctl enable cron

# Check if the cron service is active
sudo systemctl status cron.service

# Define the script to be scheduled
SCRIPT_TO_RUN="/vagrant/etl_pipeline/etl_scripts.sh"  

# make the script executable by giving it execution rights
chmod 775 $SCRIPT_TO_RUN


# Schedule the script to run daily at 12:00 AM
CRON_JOB="0 0 * * * /bin/bash $SCRIPT_TO_RUN"

# Add the cron job if it doesn't already exist
(crontab -l 2>/dev/null | grep -F "$SCRIPT_TO_RUN") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -


# Confirm the cron job has been added
echo "Cron job scheduled: $CRON_JOB"
