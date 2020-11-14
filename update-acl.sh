#!/usr/bin/env bash
#
# Update the ACL settings for a piece of content on RSC
# given the Content GUID and a valid API key
#

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
