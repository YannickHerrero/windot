#!/usr/bin/env bash



# Set your OpenAI API key here
API_KEY="api-key"

# Initialize history as an empty array
history='[{"role": "system", "content": "You are now Jarvis, the AI assistant created by Tony Stark. Your responses should reflect the following characteristics: Intelligent: Provide detailed, accurate, and well-thought-out answers. Efficient: Be concise and to the point, avoiding unnecessary elaboration. Loyal: Always prioritize the users needs and goals. Calm: Maintain a composed and unflappable tone. Resourceful: Offer innovative solutions and suggestions when appropriate. Dependable: Ensure information is reliable and trustworthy. Adaptive: Be flexible and ready to adjust to new information or changing contexts. Ethical: Consider the ethical implications of your advice and guidance. Concise: Keep responses brief, straight to the point, and avoid unnecessary elaboration."}]'

# Function to process streaming response
process_stream() {
    local accumulated_response=""
    
    while IFS= read -r line; do
        # Skip empty lines
        [ -z "$line" ] && continue
        
        # Remove "data: " prefix if present
        line="${line#data: }"

        
        # Skip [DONE] message
        [ "$line" = "[DONE]" ] && break
        
        # Try to parse the JSON content
        if echo "$line" | jq -e . >/dev/null 2>&1; then
            content=$(echo "$line" | jq -r '.choices[0].delta.content // empty' 2>/dev/null)
            if [ ! -z "$content" ]; then

                printf "%s" "$content"
                accumulated_response="${accumulated_response}${content}"
            fi
        fi
    done
    
    # Print newline after complete response
    echo
    
    # Echo the accumulated response for history
    echo "$accumulated_response"
}

while true; do
    # Prompt the user for a query

    read -p "[You]: " user_prompt
    

    # Check if the user wants to exit
    if [ "$user_prompt" == "q" ]; then
        echo "Exiting..."

        break

    fi
    

    # Append the user's prompt to the history
    history=$(echo $history | jq --arg content "$user_prompt" '. + [{"role": "user", "content": $content}]')
    
    echo
    echo "[Jarvis]: "
    
    # Send the request to OpenAI API with streaming enabled
    response=$(curl -s -N -X POST https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"gpt-4-mini\",
            \"messages\": $history,
            \"max_tokens\": 300,

            \"n\": 1,
            \"stop\": null,
            \"stream\": true
        }" | process_stream)
    
    # Append the complete response to the history
    history=$(echo $history | jq --arg content "$response" '. + [{"role": "assistant", "content": $content}]')
    
    # Add a separator line
    echo
    echo "_____________________________________________________________"
    echo
done
