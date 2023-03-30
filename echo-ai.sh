#!/bin/bash

# Check if ncurses is installed
if ! dpkg -s libncurses5-dev >/dev/null 2>&1; then
    # Install ncurses using package manager
    echo "ncurses not found. Installing..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y libncurses5-dev
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Syu
        sudo pacman -S --noconfirm ncurses5-compat-libs
    elif command -v yum >/dev/null 2>&1; then
        sudo yum update
        sudo yum install -y ncurses-devel
    elif command -v brew >/dev/null 2>&1; then
        brew install ncurses
    else
        echo "Unable to find package manager. Please install ncurses manually."
        exit 1
    fi
fi

# Check if data.json exists, and create it if it doesn't
if [ ! -f "data.json" ]; then
    echo "{}" > data.json
fi

# Set up ncurses environment
export TERM=xterm-256color
tput clear
tput civis  # Hide cursor

# Define menu options
options=("Option 1" "Option 2" "Option 3" "Quit")
selected=0
num_options=${#options[@]}

# Define function to display menu
display_menu() {
    tput reset
    tput bold
    tput cup 3 20
    echo "Echo AI Menu"
    tput sgr0
    tput cup 5 20
    for i in "${!options[@]}"; do
        if [[ $i -eq $selected ]]; then
            tput smso  # Start standout mode (reverse video)
        fi
        echo "${options[$i]}"
        tput sgr0
    done
}

# Display initial menu
display_menu

# Handle arrow key input to navigate menu
while true; do
    read -s -n3 key
    case $key in
        $'\e[A')  # Up arrow
            ((selected--))
            ((selected+=num_options))
            ((selected%=num_options))
            display_menu
            ;;
        $'\e[B')  # Down arrow
            ((selected++))
            ((selected%=num_options))
            display_menu
            ;;
        '')  # Enter key
            if [[ $selected -eq $((num_options-1)) ]]; then
                tput clear
                tput cnorm  # Restore cursor
                exit 0
            fi
            # Handle selected option
            # ...
            ;;
    esac
done


# Define UI function
ui() {
    # Set terminal title
    echo -ne "\033]0;Echo AI v1.0\007"

    # Create menu options
    options=("Chat" "Data" "Exit")

    # Loop through options
    while true; do
        # Clear screen
        clear

        # Print title
        echo "Echo AI v1.0"

        # Print menu options
        for i in "${!options[@]}"; do
            echo "$((i+1)). ${options[$i]}"
        done

        # Get user input
        read -p "Enter choice: " choice

        # Handle user input
        case $choice in
            1)
                # Call chat function
                chat
                ;;
            2)
                # Call data function
                data
                ;;
            3)
                # Exit program
                exit 0
                ;;
            *)
                # Invalid input
                echo "Invalid choice. Press enter to try again."
                read -n 1
                ;;
        esac
    done
}

chat_bot() {
  # Check if data file exists
  if [ ! -f data.json ]; then
    touch data.json
    echo '{"conversations":[]}' > data.json
  fi

  # Check for dependencies
  check_dependencies

  # Log session start time
  log_data '{"session_start":"'$(date +%s)'"}'

  # Welcome message
  print_message "Welcome to Echo AI! Type 'exit' to quit at any time."

  # Start conversation loop
  while true; do
    # Get user input
    input=$(get_input)

    # Check if user wants to exit
    if [[ "$input" == "exit" ]]; then
      log_data '{"session_end":"'$(date +%s)'"}'
      print_message "Goodbye!"
      break
    fi

    # Generate response
    response=$(get_response "$input")

    # Print response
    print_message "$response"
  done
}

# Define data function
data() {
    # Print data.json
    cat data.json

    # Wait for user input
    read -n 1 -s -r -p "Press any key to continue..."
}

# Call the UI function to start the program
ui
