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

# If we have _access_token_bc set, change access token to bc customer level token
# We don't need change bc access token to normal token
# as we re-read access_token in every call flow
# _access_token_bc and _access_token are defined in ../common/basic_api_checks.sh
# ********************************************************************************************************
# NOTICE. You need to re-issue a bc token with a customer scope if you re-crate a customer
# to have this code works correctly. The code doesn't check if the bc token is connected to a proper customer
# form the current customer.json file.
# ********************************************************************************************************
if [ -n "${_access_token_bc}" ]; then
	_access_token="${_access_token_bc}"
fi

# Generate plans UUIDs for new plans
_total_protection_plan_id=$(uuidgen)
_backup_plan_id=$(uuidgen)

# Replace templates with generated UUIDs
_plan_json=$(sed -e "s/{{parent_plan_uuid}}/${_total_protection_plan_id}/g" -e "s/{{plan_uuid}}/${_backup_plan_id}/g" ./base_plan.json)

# To create a backup only plan (as stated in the used template file)
# POST API call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
# $2 - Content-Type
# $4 - POST data
_post_api_call_bearer_fixed "api/policy_management/v4/policies" \
						"application/json" \
						"${_plan_json}" >"${DIR}/../policy_creation_results.json"
