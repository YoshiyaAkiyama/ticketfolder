#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title mf
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖

#!/bin/bash

homePath="$HOME"
configFilePath=$homePath/tickets/current_ticket

# Validate that the config file exists
if [ -f "$configFilePath" ]; then
  # shellcheck disable=SC1090
  source "$configFilePath"

else
  echo "Error: Config file not found: $configFilePath"
  exit 1
fi



if [ -z "$TF_COMMAND_TIME" ]; then
  echo "Error: LAST_RUN_TIME not found in the config file."
  exit 1
fi

# Convert the config timestamp and current time to Unix time
tf_command_time_unix=$(gdate -d "$TF_COMMAND_TIME" +%s 2>/dev/null)
current_time_unix=$(date +%s)

if [ -z "$tf_command_time_unix" ]; then
  echo "Error: Invalid timestamp in config file: $configFilePath"
  exit 1
fi

# Calculate the time difference in seconds
time_difference=$((current_time_unix - tf_command_time_unix))

# 4 hours in seconds
four_hours=$((4 * 3600))

# Check if the time difference is greater than or equal to 4 hours
if [ "$time_difference" -ge "$four_hours" ]; then
  echo "It has been more than 4 hours since the last run. Exiting."
  exit 0
fi

# If less than 4 hours, proceed with the script
echo "It has been less than 4 hours since the last run. Proceeding with the script..."

# Your main script logic here
download_dir="$HOME/Downloads"
target_dir="$HOME/tickets/$ZD_TICKET_NUMBER"
tf_command_time_gdate=$(gdate -d "$TF_COMMAND_TIME")
find "$download_dir" -type f -newermt "$tf_command_time_gdate" -exec mv {} "$target_dir"* \;