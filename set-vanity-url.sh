#!/usr/bin/env bash
#
# Set the vanity URL for a piece of Content forcefully 
# given the Content GUID and a valid API key
#

set -e

if [ -z "${CONNECT_API_KEY}" ] ; then
    echo "The CONNECT_API_KEY environment variable is not defined. It must contain"
    echo "an API key owned by a 'publisher' account in your RStudio Connect instance."
    echo
    echo "    export CONNECT_API_KEY='jIsDWwtuWWsRAwu0XoYpbyok2rlXfRWa'"
    exit 1
fi

if [ -z "${CONTENT}" ] ; then
    echo "The CONTENT (GUID) environment variable is not defined. A content GUID is returned"
    echo "by calling the POST /v1/content API endpoint."
    echo
    echo "    export CONTENT='4c0475df-f573-4880-886c-dd0d3a3094f7'"
    exit 1
fi

if [ $# -eq 0 ] ; then
    echo "usage: $0 <content-title>"
    exit 1
fi

# Build the JSON to create a vanity force update request
DATA=$(jq --arg path "${VANITY_NAME}" \
   --argjson force true \
   '. | .["path"]=$path | .["force"]=$force' \
   <<<'{}')
   
echo "Trying: ${CONNECT_SERVER}__api__/v1/content/${CONTENT}/vanity"

echo "${DATA}"

RESULT=$(curl --silent --show-error -L --max-redirs 0 --fail -X PUT \
    -H "Authorization: Key ${CONNECT_API_KEY}" \
    --data-binary "${DATA}" \
    "${CONNECT_SERVER}__api__/v1/content/${CONTENT}/vanity")
RESPONSE=$(echo "$RESULT" | jq -r .path)

echo "Vanity URL: ${RESPONSE} Update Complete."
