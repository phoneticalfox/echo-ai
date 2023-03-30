#!/bin/bash

# Create or update data.json
if [ ! -f "data.json" ]; then
  echo '{"prompts": []}' > data.json
fi

# Define functions
function ui {
  # Clear screen
  clear

  # Display header
  echo -e "\n\t\e[1mEcho AI Chat Bot\e[0m\n"

  # Display instructions
  echo -e "\tInstructions: Use the arrow keys to navigate and Enter to select.\n"

  # Read data from JSON file
  local options=($(jq -r '.prompts[] | "\(.prompt)"' data.json))

  # Add option to enter a new prompt
  options+=("Add New Prompt")

  # Display options using dialog
  local choice=$(dialog --clear \
                   --backtitle "Echo AI Chat Bot" \
                   --title "Select a Prompt" \
                   --menu "Choose one of the following options:" \
                   15 50 6 \
                   "${options[@]}" \
                   2>&1 >/dev/tty)

  # Handle user choice
  case "$choice" in
    "Add New Prompt")
      add_prompt
      ;;
    *)
      get_response "$choice"
      ;;
  esac
}

function add_prompt {
  # Prompt user for new prompt
  local prompt=$(dialog --clear \
                 --backtitle "Echo AI Chat Bot" \
                 --title "Add New Prompt" \
                 --inputbox "Enter a new prompt:" \
                 10 50 \
                 2>&1 >/dev/tty)

  # Add new prompt to JSON file
  jq ".prompts |= . + [{\"prompt\":\"$prompt\", \"responses\":[] }]" data.json > tmp.json && mv tmp.json data.json

  # Display confirmation message
  dialog --clear \
         --backtitle "Echo AI Chat Bot" \
         --title "Prompt Added" \
         --msgbox "The prompt \"$prompt\" has been added." \
         10 50 \
         2>&1 >/dev/tty

  # Reload UI
  ui
}

function get_response {
  # Read responses from JSON file
  local responses=($(jq -r --arg choice "$1" '.prompts[] | select(.prompt == $choice) | .responses[]' data.json))

  # Choose a random response
  local response=${responses[$RANDOM % ${#responses[@]}]}

  # Display response using dialog
  dialog --clear \
         --backtitle "Echo AI Chat Bot" \
         --title "$1" \
         --msgbox "$response" \
         10 50 \
         2>&1 >/dev/tty

  # Reload UI
  ui
}

# Call the UI function to start the program
ui
