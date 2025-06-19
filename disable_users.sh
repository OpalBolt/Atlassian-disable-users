#!/bin/bash
# Script to disable Atlassian users based on CSV files
# Usage: ./disable_users.sh <API_TOKEN>

# Error handling
set -e
set -o pipefail

# Check if API token is provided
if [ $# -lt 1 ]; then
    echo "Usage: ./disable_users.sh <API_TOKEN>"
    echo "  API_TOKEN: Your Atlassian API token"
    exit 1
fi

API_TOKEN="$1"
ID_CSV="ID.csv"
DISABLE_CSV="disable.csv"
LOG_FILE="disable_log.txt"
DISABLE_REASON="Account has been deactivated as per organizational policy"

# Check if required CSV files exist
if [ ! -f "$ID_CSV" ]; then
    echo "Error: $ID_CSV file not found"
    exit 1
fi

if [ ! -f "$DISABLE_CSV" ]; then
    echo "Error: $DISABLE_CSV file not found"
    exit 1
fi

# Create or clear log file
> "$LOG_FILE"
echo "$(date): Starting user deactivation process" | tee -a "$LOG_FILE"
echo "----------------------------------------" | tee -a "$LOG_FILE"

# Read users to be disabled
echo "Reading list of users to be disabled..."
mapfile -t USERS_TO_DISABLE < <(tail -n +2 "$DISABLE_CSV" | cut -d, -f1 | tr -d '\r')

# Count of users
TOTAL_USERS=${#USERS_TO_DISABLE[@]}
echo "Found $TOTAL_USERS users to disable" | tee -a "$LOG_FILE"

# Process each user
DISABLED_COUNT=0
FAILED_COUNT=0

for USERNAME in "${USERS_TO_DISABLE[@]}"; do
    echo -n "Processing user: $USERNAME... " | tee -a "$LOG_FILE"
    
    # Find the account ID from the ID CSV
    ACCOUNT_ID=$(grep -i "^$USERNAME," "$ID_CSV" | cut -d, -f2 | tr -d '\r')
    
    if [ -z "$ACCOUNT_ID" ]; then
        echo "FAILED (Account ID not found)" | tee -a "$LOG_FILE"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        continue
    fi
    
    # Make the API call to disable the user
    RESPONSE=$(curl --write-out '%{http_code}' --silent --output /dev/null \
      --request POST \
      --url "https://api.atlassian.com/users/$ACCOUNT_ID/manage/lifecycle/disable" \
      --header "Authorization: Bearer $API_TOKEN" \
      --header "Content-Type: application/json" \
      --data "{\"message\": \"$DISABLE_REASON\"}")
    
    if [ "$RESPONSE" == "204" ]; then
        echo "SUCCESS" | tee -a "$LOG_FILE"
        DISABLED_COUNT=$((DISABLED_COUNT + 1))
    else
        echo "FAILED (API returned status: $RESPONSE)" | tee -a "$LOG_FILE"
        FAILED_COUNT=$((FAILED_COUNT + 1))
    fi
done

echo "----------------------------------------" | tee -a "$LOG_FILE"
echo "Deactivation process completed" | tee -a "$LOG_FILE"
echo "- Total users processed: $TOTAL_USERS" | tee -a "$LOG_FILE"
echo "- Successfully disabled: $DISABLED_COUNT" | tee -a "$LOG_FILE"
echo "- Failed: $FAILED_COUNT" | tee -a "$LOG_FILE"
echo "----------------------------------------" | tee -a "$LOG_FILE"

echo "Results have been saved to $LOG_FILE"
