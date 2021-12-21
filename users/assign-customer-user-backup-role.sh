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
_user_id=$(_get_id_from_file "${DIR}/../user.json")
_customer_tenant_id=$(_get_id_from_file "${DIR}/../customer.json")

# Construct JSON to apply a user backup_user role
_json='{"items": [
     {"id": "00000000-0000-0000-0000-000000000000",
     "issuer_id": "00000000-0000-0000-0000-000000000000",
     "role_id": "backup_user",
     "tenant_id": "'${_customer_tenant_id}'",
     "trustee_id": "'${_user_id}'",
     "trustee_type": "user",
     "version": 0}
     ]}'

# To assign a user a role
# POST API call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
# $2 - Content-Type
# $3 - POST data
_put_api_call_bearer "api/2/users/${_user_id}/access_policies" \
					"application/json" \
					"${_json}"
