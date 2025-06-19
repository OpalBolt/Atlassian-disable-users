# Atlassian User Deactivation Script

This script automates the process of disabling/deactivating Atlassian users based on CSV files.

## Prerequisites

- Bash shell environment
- curl installed
- An Atlassian API token with appropriate permissions for user management
- CSV files with required format

## File Format

### ID.csv
This file should contain a mapping between usernames and their Atlassian account IDs:

```
username,account_id
johndoe,5d3f1422-c308-4965-8a70-abcde1234567
janedoe,6f9a4b31-d216-5873-9b83-fghij5678901
```

### disable.csv
This file should contain the list of usernames that need to be disabled:

```
username
johndoe
bobsmith
```

## Usage

1. Make the script executable:
   ```
   chmod +x disable_users.sh
   ```

2. Run the script with your Atlassian API token:
   ```
   ./disable_users.sh <YOUR_API_TOKEN>
   ```

## Output

The script will:
- Display progress in the terminal
- Create a `disable_log.txt` file with details on each user processed
- Show a summary of successfully disabled and failed users

## API Details

This script uses the [Atlassian User Management API](https://developer.atlassian.com/cloud/admin/user-management/rest/api-group-lifecycle/#api-users-account-id-manage-lifecycle-disable-post) to deactivate users. The API endpoint requires:
- Account ID
- Authorization token
- Deactivation message
