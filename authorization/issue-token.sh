#!/bin/bash

#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************
# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null||echo "$0")

# The directory where current script resides
DIR=$(dirname "${THIS}")

. "${DIR}/../common/basis_functions.sh"

# Pipe JSON from file, extract JSON property, remove quotas from the property's value
_client_id=$(jq '.client_id' < "${DIR}/../api_client.json" | sed -e 's/^"//' -e 's/"$//')
_client_secret=$(jq '.client_secret' < "${DIR}/../api_client.json" | sed -e 's/^"//' -e 's/"$//')

# To issue a token
# POST call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
# $2 - a login for Basic Authentication
# $3 - a password for Basic Authentication
# $4 - POST data
# $5 - Content-Type
# The result is stored in api_token.json file
_post_api_call_basic "api/2/idp/token" \
					"${_client_id}" "${_client_secret}" \
					"grant_type=client_credentials" \
					"application/x-www-form-urlencoded" > "${DIR}/../api_token.json"