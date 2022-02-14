#!/bin/bash

#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null||echo "$0")

# The directory where current script resides
DIR=$(dirname "${THIS}")

. "${DIR}/../common/basis_functions.sh"

. "${DIR}/../common/basic_api_checks.sh"

# Get Root tenant_id for the API Client
# Call a function to pipe JSON from file, extract JSON property, remove quotas from the property's value
_tenant_id=$(_get_tenant_id_from_file "${DIR}/../api_client.json")

# Construct JSON to create a report
# Expected to provide full month for period JSON object
_json='{
    "parameters": {
        "kind": "usage_summary",
        "tenant_id": "'$_tenant_id'",
        "level": "direct_partners",
        "formats": [
            "csv_v2_0"
        ],
		"show_skus": true,
        "hide_zero_usage": "false",
        "period": {
            "start": "2021-10-01",
            "end": "2021-10-31"
        }
    },
    "schedule": {
        "type": "once"
    },
    "result_action": "save"
}'

# To create a report
# POST API call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
# $2 - Content-Type
# $3 - POST data
# The result is stored in created_report.json file
_post_api_call_bearer "api/2/reports" \
					"application/json" \
					"${_json}" > "${DIR}/../created_report_with_sku.json"

# Get report_id from saved file
# Call a function to pipe JSON from file, extract JSON property, remove quotas from the property's value
_report_id=$(_get_id_from_file "${DIR}/../created_report_with_sku.json")

# Init $_report_status to have at least 1 loop execution
_report_status="not saved"

# A report is not produced momently, so we need to wait for it to become saved
# Here is a simple implementation for sample purpose expecting that
# For sample purposes we use 1 report from stored -- as we use once report
while [[ $_report_status != "saved" ]] ; do

	# To get a saved report info
	# GET call using function defined in basis_functions.sh
	# with following parameters
	# $1 - an API endpoint to call
	# The result is stored in "${_report_id}_report.json" file
	_get_api_call_bearer "api/2/reports/${_report_id}/stored" \
					  > "${DIR}/../${_report_id}_report_status_with_sku.json"


	_report_status=$(jq '.items[0].status' < "${DIR}/../${_report_id}_report_status_with_sku.json" | sed -e 's/^"//' -e 's/"$//')

	sleep 2s
done

# For sample purposes we use 1 report from stored -- as we use once report
# MUST BE CHANGED if you want to deal with scheduled one or you have multiple reports
_stored_report_id=$(jq '.items[0].id' < "${DIR}/../${_report_id}_report_status_with_sku.json" | sed -e 's/^"//' -e 's/"$//')

# Download the report
# The result is stored in "${_report_id}_report.csv" file
# Response is gzip-ed so we need to add --compressed to have an output file decompressed
# _base_url is loaded from config file in basis_functions.sh
curl	--compressed \
		-X GET \
		--url "${_base_url}api/2/reports/${_report_id}/stored/${_stored_report_id}" \
		-H "Authorization: Bearer ${_access_token}" \
		-o "${DIR}/../${_report_id}_report_with_sku.csv"
