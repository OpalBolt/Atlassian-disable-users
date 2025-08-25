#!/bin/bash
# Script to remove users from Atlassian groups
# Usage: ./remove_from_groups.sh <API_TOKEN> <ORG_ID>

# Error handling
set -e
set -o pipefail

# Check if API token and org ID are provided
if [ $# -lt 2 ]; then
    echo "Usage: ./remove_from_groups.sh <API_TOKEN> <ORG_ID>"
    echo "  API_TOKEN: Your Atlassian API token"
    echo "  ORG_ID: Your Atlassian Organization ID"
    exit 1
fi

API_TOKEN="$1"
ORG_ID="$2"
ID_CSV="ID.csv"
DISABLE_CSV="disable.csv"
GROUPS_CSV="rm-groups.csv"
LOG_FILE="group_removal_log.txt"

# Check if required CSV files exist
if [ ! -f "$ID_CSV" ]; then
    echo "Error: $ID_CSV file not found"
    exit 1
fi

if [ ! -f "$DISABLE_CSV" ]; then
    echo "Error: $DISABLE_CSV file not found"
    exit 1
fi

if [ ! -f "$GROUPS_CSV" ]; then
    echo "Error: $GROUPS_CSV file not found"
    exit 1
fi

# Create or clear log file
: > "$LOG_FILE"
echo "$(date): Starting group removal process" | tee -a "$LOG_FILE"
echo "----------------------------------------" | tee -a "$LOG_FILE"

# Read users to be removed
echo "Reading list of users to be removed from groups..."
mapfile -t USERS_TO_REMOVE < <(tail -n +2 "$DISABLE_CSV" | cut -d, -f1 | tr -d '\r')

# Read groups from which users will be removed
echo "Reading list of groups..."
mapfile -t GROUPS < <(tail -n +2 "$GROUPS_CSV" | tr -d '\r')

# Count of users and groups
TOTAL_USERS=${#USERS_TO_REMOVE[@]}
TOTAL_GROUPS=${#GROUPS[@]}
echo "Found $TOTAL_USERS users to remove from $TOTAL_GROUPS groups" | tee -a "$LOG_FILE"

# Process each user and group
REMOVED_COUNT=0
FAILED_COUNT=0

for USERNAME in "${USERS_TO_REMOVE[@]}"; do
    # Find the account ID from the ID CSV
    ACCOUNT_ID=$(grep -i "^$USERNAME," "$ID_CSV" | cut -d, -f2 | tr -d '\r')
    
    if [ -z "$ACCOUNT_ID" ]; then
        echo "User $USERNAME: FAILED (Account ID not found)" | tee -a "$LOG_FILE"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        continue
    fi
    
    for GROUP_ID in "${GROUPS[@]}"; do
        echo -n "Removing user $USERNAME ($ACCOUNT_ID) from group $GROUP_ID... " | tee -a "$LOG_FILE"
        
        # Make the API call to remove the user from the group
        RESPONSE=$(curl --write-out '%{http_code}' --silent --output /dev/null \
          --request DELETE \
          --url "https://api.atlassian.com/v1/orgs/$ORG_ID/directory/groups/$GROUP_ID/memberships/$ACCOUNT_ID" \
          --header "Authorization: Bearer $API_TOKEN" \
          --header "Accept: application/json")
        
        if [ "$RESPONSE" == "204" ]; then
            echo "SUCCESS" | tee -a "$LOG_FILE"
            REMOVED_COUNT=$((REMOVED_COUNT + 1))
        else
            echo "FAILED (API returned status: $RESPONSE)" | tee -a "$LOG_FILE"
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    done
done

echo "----------------------------------------" | tee -a "$LOG_FILE"
echo "Group removal process completed" | tee -a "$LOG_FILE"
echo "- Total users processed: $TOTAL_USERS" | tee -a "$LOG_FILE"
echo "- Total groups processed: $TOTAL_GROUPS" | tee -a "$LOG_FILE"
echo "- Successful removals: $REMOVED_COUNT" | tee -a "$LOG_FILE"
echo "- Failed removals: $FAILED_COUNT" | tee -a "$LOG_FILE"
echo "----------------------------------------" | tee -a "$LOG_FILE"

echo "Results have been saved to $LOG_FILE"
