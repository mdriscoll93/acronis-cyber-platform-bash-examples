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

# Get Root personal_tenant_id for a user
_user_personal_tenant_id=$(_get_personal_tenant_id_from_file "${DIR}/../user.json")

# Construct JSON to request a token
_json='{
  "expires_in": 3600,
  "scopes": [
    "urn:acronis.com:tenant-id::backup_agent_admin"
  ]
}'

# To create an agent installation token
# POST API call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
# $2 - Content-Type
# $3 - POST data
_post_api_call_bearer_fixed "api/2/tenanats/${_user_personal_tenant_id}/registration_tokens" \
					"application/json" \
					"${_json}" > "${DIR}/../agent_installation_token.json"
