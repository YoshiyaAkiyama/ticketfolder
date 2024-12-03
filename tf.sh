#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title tf
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Function to display a dialog and return the entered text

check_and_install_ggrep() {
  echo "Checking if ggrep is installed..."
  
  if ! command -v ggrep &>/dev/null; then
    echo "ggrep is not installed. Installing via Homebrew..."
    
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
      echo "Homebrew is not installed. Please install Homebrew first: https://brew.sh/"
      exit 1
    fi

    # Install ggrep using Homebrew
    brew install grep

    if [ $? -ne 0 ]; then
      echo "Failed to install ggrep. Exiting."
      exit 1
    fi
    
    echo "ggrep installed successfully."
  else
    echo "ggrep is already installed."
  fi
}

ensure_directory_exists() {
  local targetPath="$1"

  if [ ! -d "$targetPath" ]; then
    echo "Path does not exist. Creating: $targetPath"
    mkdir -p "$targetPath"
    if [ $? -eq 0 ]; then
      echo "Path created successfully."
    else
      echo "Failed to create the path. Check permissions."
      exit 1
    fi
  else
    echo "Path already exists: $targetPath"
  fi
}

function displayDialog {
    osascript <<EOF
    tell application "System Events"
        text returned of (display dialog "$1" default answer "")
    end tell
EOF
}

check_and_install_ggrep
echo "ggrep is ready for use."

homePath="$HOME"
ticketPath="$homePath/tickets/"
ensure_directory_exists "$ticketPath"


# Look for number that is 7digits or longer in clipboard(if yes, assumes its valid zendesk number and proceeds)
clipboard_content=$(pbpaste)
ticketNumber=$(echo "$clipboard_content" | ggrep -oP '\b\d{7,}\b')
if [ ${#ticketNumber} -ge 7 ]; then
  echo "The content is exactly 7 characters long."
else
  echo "Clipboard does not contain valid zendesk ID."
  exit
fi

echo "$ticketNumber" > "$homePath/tickets/current_ticket"
cat <<EOL > "$homePath/tickets/current_ticket"
# Config file for mf
ZD_TICKET_NUMBER="$ticketNumber"
TF_COMMAND_TIME="$(date)"
EOL

# Try to open the file or folder
if open "$homePath/tickets/$ticketNumber"* 2> /dev/null; then
    echo "Opened $ticketNumber"
    open "$homePath/tickets/$ticketNumber"*/*"_notes.md" 2> /dev/null
else
    # If the file/folder doesn't exist, prompt for a new folder name
    folderName=$(displayDialog "Enter Folder Name")
    if  [[ "$folderName" == "" ]]; then 
    echo "empty"
    else 
        fullFolderName="${ticketNumber}_${folderName}"

        # Create folder and a notes file
        mkdir -p "$homePath/tickets/$fullFolderName"
        touch "$homePath/tickets/$fullFolderName/${fullFolderName}_notes.md"
        echo "$homePath/tickets/$fullFolderName" > "$homePath/tickets/$fullFolderName/${fullFolderName}_notes.md"
        # Try to open the file or folder again
        open "$homePath/tickets/$ticketNumber"* 2>/dev/null

        # Open the notes file
        open "$homePath/tickets/$ticketNumber"*/"${fullFolderName}_notes.md" 2> /dev/null
    fi
fi