#!/bin/bash

# Define the domain and service details
CORALOGIX_DOMAIN="ng-api-grpc.eu2.coralogix.com:443"
SERVICE="com.coralogix.datausage.v2.DataUsageService/GetTeamDetailedDataUsage"

# Loop through each API key in the file
while IFS=',' read -r TEAM_NAME API_KEY; do
    # Log the current API key and team name to the console
    echo "Using API key: ${API_KEY} for Team: ${TEAM_NAME}"

    # Use the team name in the filename to create unique output files
    OUTPUT_FILE="output_${TEAM_NAME}_.json"

    # Run the grpcurl command with the current API key, wrap the output in an array, replace the pattern, and save to the output file
    grpcurl -H "Authorization: Bearer ${API_KEY}" -d @ "${CORALOGIX_DOMAIN}" "${SERVICE}" <<EOF | jq -s . | sed -e ':a' -e 'N' -e '$!ba' -e 's/]\n}/]\n},/g' > "${OUTPUT_FILE}"
{
  "resolution": "24h",
  "date_range": {
    "from_date": "2023-08-31T01:30:15.01Z",
    "to_date": "2023-10-31T01:30:15.01Z"
  }
}
EOF

    # Check if grpcurl command was successful
    if [ $? -ne 0 ]; then
        echo "Error with API key: ${API_KEY} for Team: ${TEAM_NAME}. Moving to the next key."
    fi

done < api_keys.txt