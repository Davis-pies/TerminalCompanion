#!/bin/bash

# Configuration

API_KEY=$OPENAI_API_KEY
API_URL="https://api.openai.com/v1"
ASSISTANT_ENDPOINT="$API_URL/assistants"
FUNCTION_ENDPOINT="$API_URL/functions"

# Helper function to make API requests
make_request() {
    local method=$1
    local url=$2
    local data=$3
    local headers=(-H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -H "OpenAI-Beta: assistants=v1")

    if [ "$method" == "POST" ] && [ -n "$data" ]; then
        curl -s -X $method "${headers[@]}" -d "$data" "$url"
    else
        curl -s -X $method "${headers[@]}" "$url"
    fi
}

# Create an assistant
create_assistant() {
    local name=$1
    local description=$2
    local model=$3
    local data=$(jq -n --arg name "$name" --arg desc "$description" --arg model "$model" \
        '{name: $name, description: $desc, model: $model}')

    make_request "POST" "$ASSISTANT_ENDPOINT" "$data"
}

# List all assistants
list_assistants() {
    make_request "GET" "$ASSISTANT_ENDPOINT"
}

# Get assistant details
get_assistant() {
    local assistant_id=$1
    make_request "GET" "$ASSISTANT_ENDPOINT/$assistant_id"
}

# Delete an assistant
delete_assistant() {
    local assistant_id=$1
    make_request "DELETE" "$ASSISTANT_ENDPOINT/$assistant_id"
}

# Create a function
create_function() {
    local function_id=$1
    local name=$2
    local description=$3
    local data=$(jq -n --arg id "$function_id" --arg name "$name" --arg desc "$description" \
        '{function_id: $id, name: $name, description: $desc}')

    make_request "POST" "$FUNCTION_ENDPOINT" "$data"
}

# List all functions
list_functions() {
    make_request "GET" "$FUNCTION_ENDPOINT"
}

# Get function details
get_function() {
    local function_id=$1
    make_request "GET" "$FUNCTION_ENDPOINT/$function_id"
}

# Delete a function
delete_function() {
    local function_id=$1
    make_request "DELETE" "$FUNCTION_ENDPOINT/$function_id"
}

# Invoke a function
invoke_function() {
    local function_id=$1
    local inputs=$2
    local data=$(jq -n --arg inputs "$inputs" '{inputs: $inputs}')

    make_request "POST" "$FUNCTION_ENDPOINT/$function_id/call" "$data"
}

# Main function to handle script arguments
main() {
    case "$1" in
        create-assistant)
            create_assistant "$2" "$3" "$4"
            ;;
        list-assistants)
            list_assistants
            ;;
        get-assistant)
            get_assistant "$2"
            ;;
        delete-assistant)
            delete_assistant "$2"
            ;;
        create-function)
            create_function "$2" "$3" "$4"
            ;;
        list-functions)
            list_functions
            ;;
        get-function)
            get_function "$2"
            ;;
        delete-function)
            delete_function "$2"
            ;;
        invoke-function)
            invoke_function "$2" "$3"
            ;;
        *)
            echo "Usage: $0 {create-assistant|list-assistants|get-assistant|delete-assistant|create-function|list-functions|get-function|delete-function|invoke-function}"
            exit 1
    esac
}

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install jq to use this script."
    exit 1
fi

# Call main function with all script arguments
main "$@"


