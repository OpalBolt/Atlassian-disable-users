# Atlassian User Management Scripts

This repository contains scripts to automate Atlassian user management tasks including disabling users and removing them from groups, all based on CSV files.

## Prerequisites

- Bash shell environment
- curl installed
- An Atlassian API token with appropriate permissions for user management
- Your Atlassian Organization ID
- CSV files with required format

## Scripts

### 1. disable_users.sh
Disables/deactivates Atlassian users based on a list in CSV format.

### 2. remove_from_groups.sh
Removes users from specified Atlassian groups. This is useful for removing access without completely disabling accounts.

## CSV File Overview

This project uses several CSV files to manage user operations:

- **ID.csv** - Maps email addresses to Atlassian account IDs (required for API calls). This file can be exported from admin.atlassian.com
- **disable.csv** - Lists email addresses of users to be disabled/deactivated
- **rm-groups.csv** - Lists group IDs from which users should be removed

## File Format

### ID.csv
This file should contain a mapping between email addresses and their Atlassian account IDs. This file can be exported directly from admin.atlassian.com:

```csv
email,account_id
john.doe@company.com,5d3f1422-c308-4965-8a70-abcde1234567
jane.doe@company.com,6f9a4b31-d216-5873-9b83-fghij5678901
```

### disable.csv
This file should contain the list of email addresses that need to be disabled:

```csv
email
john.doe@company.com
bob.smith@company.com
```

### rm-groups.csv
This file should contain the list of group IDs from which users should be removed:

```csv
group-id-1
group-id-2
admin-group-id
```

## Usage

### Disabling Users

1. Make the script executable:
   ```bash
   chmod +x disable_users.sh
   ```

2. Run the script with your Atlassian API token:
   ```bash
   ./disable_users.sh <YOUR_API_TOKEN>
   ```

### Removing Users from Groups

1. Make the script executable:
   ```bash
   chmod +x remove_from_groups.sh
   ```

2. Run the script with your Atlassian API token and Organization ID:
   ```bash
   ./remove_from_groups.sh <YOUR_API_TOKEN> <ORG_ID>
   ```

## Output

### disable_users.sh Output
The script will:
- Display progress in the terminal
- Create a `disable_log.txt` file with details on each user processed
- Show a summary of successfully disabled and failed users

### remove_from_groups.sh Output
The script will:
- Display progress in the terminal for each user/group combination
- Create a `group_removal_log.txt` file with details on each removal attempt
- Show a summary of successful and failed group removals

## API Details

### User Deactivation API
The `disable_users.sh` script uses the [Atlassian User Management API](https://developer.atlassian.com/cloud/admin/user-management/rest/api-group-lifecycle/#api-users-account-id-manage-lifecycle-disable-post) to deactivate users. The API endpoint requires:
- Account ID
- Authorization token
- Deactivation message

### Group Management API
The `remove_from_groups.sh` script uses the Atlassian Organization API to remove users from groups. The API endpoint requires:
- Organization ID
- Group ID
- Account ID (of the user to remove)
- Authorization token
