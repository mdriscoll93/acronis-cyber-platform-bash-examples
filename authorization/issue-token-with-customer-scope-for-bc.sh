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

# Call a function to pipe JSON from file, extract JSON property
_customer_tenant_id=$(_get_id_from_file "${DIR}/../customer.json")

# To issue a token with a customer scope
# We need to use --data-urlencode
# So we use a custom curl call
# POST API call with Bearer Authentication
# $1 - an API endpoint to call
# $2 - Content-Type
# $3 - urlencoded data 1st param
# $4 - urlencoded data 2st param
# $5 - urlencoded data 3st param
# The result is stored in api_token_customer_scope.json file
_post_api_call_bearer_urlencoded "idp/token" \
					"application/x-www-form-urlencoded" \
					"grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer"  \
					"assertion=${_access_token}"  \
					"scope=urn:acronis.com:tenant-id:${_customer_tenant_id}" \
					 > "${DIR}/../api_token_customer_scope.json"