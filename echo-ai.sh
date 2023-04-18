#!/bin/bash

# Check dependencies and install if necessary
check_dependencies() {
    declare -a dependencies=("ncurses" "jq")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" > /dev/null; then
            echo "Installing $dep..."
            if command -v apt > /dev/null; then
                sudo apt install -y "$dep"
            elif command -v pacman > /dev/null; then
                sudo pacman -S --noconfirm "$dep"
            elif command -v pkg > /dev/null; then
                sudo pkg install -y "$dep"
            elif command -v yum > /dev/null; then
                sudo yum install -y "$dep"
            else
                echo "Error: Package manager not found."
                exit 1
            fi
        fi
    done
}

# Initialize dataset file if it doesn't exist
initialize_dataset() {
    if [[ ! -f dataset.json ]]; then
        echo '{"prompts":[], "responses":[]}' > dataset.json
    fi
}

# Prompt user for feedback on chatbot response
get_feedback() {
    local prompt="$1"
    local response="$2"
    local valid_responses=("helpful" "neutral" "not helpful")
    local feedback=""
    while ! [[ "${valid_responses[@]}" =~ "$feedback" ]]; do
        echo "Was the response helpful, neutral, or not helpful? (h/n/b)"
        read -r feedback
        case "$feedback" in
            h)
                echo "{\"prompt\":\"$prompt\",\"response\":\"$response\",\"feedback\":\"helpful\"}" \
                    | jq --arg date "$(date +%s)" '. + {"timestamp":$date}' \
                    >> dataset.json
                ;;
            n)
                echo "{\"prompt\":\"$prompt\",\"response\":\"$response\",\"feedback\":\"neutral\"}" \
                    | jq --arg date "$(date +%s)" '. + {"timestamp":$date}' \
                    >> dataset.json
                ;;
            b)
                echo "{\"prompt\":\"$prompt\",\"response\":\"$response\",\"feedback\":\"not helpful\"}" \
                    | jq --arg date "$(date +%s)" '. + {"timestamp":$date}' \
                    >> dataset.json
                ;;
            *)
                echo "Invalid input."
                ;;
        esac
    done
}

# Display chat screen and save chat session to file
chat() {
    local prompt=""
    while true; do
        clear
        echo "echo ai v1.0"
        echo "Chat"
        echo ""
        echo "Enter a prompt (q to quit):"
        read -r prompt
        if [[ "$prompt" == "q" ]]; then
            break
        fi
        # Simulate chatbot response by echoing the prompt
        local response="$prompt"
        get_feedback "$prompt" "$response"
        echo "{\"prompt\":\"$prompt\",\"response\":\"$response\"}" \
            | jq --arg date "$(date +%s)" '. + {"timestamp":$date}' \
            >> "chat_$(date +%Y%m%d%H%M%S).json"
    done
}

# Display history screen and allow user to view, search, and call chat sessions
history() {
    clear
    echo "echo ai v1.0"
    echo "History"
    echo ""
    echo "Enter a chat session to view (q to quit):"
    read -r session
    # Simulate chat history by echoing the session ID
    echo "Session ID: $session"
}

check_dependencies
initialize_dataset

# Main loop
while true; do
    clear
    echo "echo ai v1.0"
    echo "Main Menu"
    echo ""
    echo "1. Chat"
    echo "2. History"
    echo "3. Quit"
    read -r choice
    case "$choice" in
        1)
            chat
            ;;
        2)
            history
            ;;
        3)
            exit 0
            ;;
        *)
            echo "Invalid input."
            ;;
    esac
done

