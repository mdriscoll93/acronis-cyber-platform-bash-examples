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
else
	_die "You can create a static group only with a customer scoped token. Please, create one."
fi

# Construct JSON to request
# 301d1574-849e-4714-859f-3a2ec12a218b is predefined id for "Machines with agents" static group
# Thus this Static group is expected to contain machines with agents
# We need to have at least 1 machine w/agent to see that groups
# ****************************************************
# NOTICE. You can't add a sub-group to a dynamic group
# ****************************************************
_json='{
  	  "type": "resource.group.computers",
   	   "parent_group_ids": [
        	"301d1574-849e-4714-859f-3a2ec12a218b"
    	],
		"group_condition": "test*",
    	"allowed_member_types": [
        	"resource.machine"
    	],
    	"name": "My Dynamic Group",
    	"user_defined_name": "My Dynamic Group"
}'

_post_api_call_bearer "api/resource_management/v4/resources" \
					  "application/json" \
					  "${_json}"