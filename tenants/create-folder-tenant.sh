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
_tenant_id=$(_get_id_from_file "${DIR}/../partner.json")

# Ask for proposed tenant name
printf "\n"
read -rp 'Folder tenant name: ' _tenant_name
printf "\n\n"

# Construct JSON to request a folder tenant creation
_json='{
		"name": "'$_tenant_name'",
		"parent_id": "'$_tenant_id'",
		"kind": "folder"
	}'

# To create a folder tenant
# POST API call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
# $2 - Content-Type
# $3 - POST data
# The result is stored in partner.json file
_post_api_call_bearer "api/2/tenants" \
					"application/json" \
					"${_json}" > "${DIR}/../folder.json"

# Get Kind of a tenant from config file
_kind=$(_config_get_value folder_tenant)

# Get Edition we plan to enable from config file
_edition=$(_config_get_value edition)

# To get a list of offering ite,s available for a child tenant
# GET call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call

# The result is stored in offering_items_available_for_child.json file
_get_api_call_bearer "api/2/tenants/${_tenant_id}/offering_items/available_for_child?kind=${_kind}&edition=${_edition}" \
					 > "${DIR}/../offering_items_available_for_child.json"


# Replace "items" with "offering_items" as the following API call expects to have it as a root JSON element
 sed 's/"items"/"offering_items"/g' < "${DIR}/../offering_items_available_for_child.json" > "${DIR}/../offering_items_to_put.json"


# Call a function to pipe JSON from file, extract JSON property
_partner_tenant_id=$(_get_id_from_file "${DIR}/../folder.json")

# To update offering item for a tenant
# PUT API call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
# $2 - Content-Type
# $4 - PUT data
_put_api_call_bearer "api/2/tenants/${_partner_tenant_id}/offering_items" \
					"application/json" \
					"$(cat "${DIR}/../offering_items_to_put.json")" > /dev/null