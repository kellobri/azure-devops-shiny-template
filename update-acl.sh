#!/usr/bin/env bash
#
# Update the ACL settings for a piece of content on RSC
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

# Build the JSON request data for adding a Viewer Group to the content ACL
DATA=$(jq --arg principal_guid "${GROUP_GUID}" \
   --arg principal_type group \
   --arg role viewer \
   '. | .["principal_guid"]=$principal_guid | .["principal_type"]=$principal_type' | .["role"]=$role' \
   <<<'{}')

echo "${DATA}"

RESULT=$(curl --silent --show-error -L --max-redirs 0 --fail -X POST \
    -H "Authorization: Key ${CONNECT_API_KEY}" \
    --data-binary "${DATA}" \
    "${CONNECT_SERVER}__api__/v1/content/${CONTENT}/permissions")
RESPONSE=$(echo "$RESULT" | jq -r .id)

echo "ACL permissions: ${RESPONSE} Update Complete."
