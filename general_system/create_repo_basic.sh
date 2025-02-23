#!/bin/bash

# Script to create an GitHub Repository via CLI
# Create local folder with git initiaded and repo URL configured

echo "Starting the script ...."


while [[ -z "$accessToken" ]]; do
	read -r -p 'Provide your GitHub personal access Token: ' accessToken
done

while [[ -z "$repoName" ]]; do
	read -r -p 'Repository name: ' repoName
done

echo -e "Creating repository '$repoName' in your GitHub . . . \n"

# Create repository
response=$(curl -s -o response.json -w "%{http_code}" \
    -H "Authorization: token $accessToken" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user/repos \
    -d "{\"name\": \"$repoName\", \"private\": false}")

echo "Response received from GitHub API."

# Check HTTP status code (expected 201 for success)
http_code=$(echo "$response" | tail -n1)

if [[ "$http_code" != "201" ]]; then
    echo "Error: Failed to create repository. HTTP status code: $http_code"
    cat response.json
    rm response.json
    exit 1
fi

# Retrieve repository URL using jq
GIT_URL=$(jq -r '.clone_url' response.json)

if [[ "$GIT_URL" == "null" || -z "$GIT_URL" ]]; then
    echo "Error: Failed to retrieve repository URL."
    cat response.json
    rm response.json
    exit 1
fi

echo "Repository successfully created: $GIT_URL"

# Display the remote URL
echo "To clone your repository, use the following URL:"
echo "$GIT_URL"

# Clean up response.json
rm response.json
