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

# Page size
_page_size=10

# Get list of all activities for all subtenants
# of the tenant for which the API Client was issue
# using pagination retrieve a cursor pointer to make the next request
# GET API call with Bearer Authentication
# $1 - an API endpoint to call
_after_cursor=$(_get_api_call_bearer "api/task_manager/v2/activities?limit=${_page_size}&order=desc(completedAt)" \
					 | jq '.paging.cursors.after' | sed -e 's/^"//' -e 's/"$//')

_page_number=1


while [ -n "${_after_cursor}" ] && [ "${_after_cursor}" != "null" ]; do
echo "The page number ${_page_number}"

# Get list of all activities for all subtenants
# of the tenant for which the API Client was issue
# using pagination and retrieve a cursor pointer to make the next request
# GET API call with Bearer Authentication
# $1 - an API endpoint to call

_after_cursor=$(_get_api_call_bearer "api/task_manager/v2/activities?limit=${_page_size}&after=${_after_cursor}" \
					 | jq '.paging.cursors.after' | sed -e 's/^"//' -e 's/"$//')

_page_number=$((_page_number+1))
done

echo "The activities were paged to the end."
