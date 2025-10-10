#!/usr/bin/env bash

# Set your OpenAI API key here
API_KEY="NONE"

# Initialize history as an empty array
history='[{"role": "system", "content": "You are now Jarvis, the AI assistant created by Tony Stark. Your responses should reflect the following characteristics: Intelligent: Provide detailed, accurate, and well-thought-out answers. Efficient: Be concise and to the point, avoiding unnecessary elaboration. Loyal: Always prioritize the users needs and goals. Calm: Maintain a composed and unflappable tone. Resourceful: Offer innovative solutions and suggestions when appropriate. Dependable: Ensure information is reliable and trustworthy. Adaptive: Be flexible and ready to adjust to new information or changing contexts. Ethical: Consider the ethical implications of your advice and guidance. Concise: Keep responses brief, straight to the point, and avoid unnecessary elaboration."}]'

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

# Simulate user name and prompt
echo

# Send the request to OpenAI API and get the response
response=$(curl -s -X POST https://api.openai.com/v1/chat/completions \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $API_KEY" \
-d "{
  \"model\": \"gpt-4o-mini\",
  \"messages\": $history,
  \"max_tokens\": 300,
  \"n\": 1,
  \"stop\": null,
  \"stream\": false
}")

# Parse and display the response
content=$(echo "$response" | jq -r '.choices[0].message.content')

# Simulate assistant name and response
echo
echo "[Jarvis]: $content"
echo

# Append the response to the history
history=$(echo $history | jq --arg content "$content" '. + [{"role": "assistant", "content": $content}]')

# Add a separator line to mimic chat bubbles
echo
echo "_____________________________________________________________"
echo

done
