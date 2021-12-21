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

# Set response code to 400 -- login availability check failed
_response_code=400

# Ask for proposed username and e-mail to activate account
printf "\n"
read -rp 'Username: ' _username
read -rp 'Please enter a valid email, it will be used for account activation: ' _email
printf "\n\n"

# To get an availability status of a username
# GET call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
_get_api_call_bearer_with_response_code "api/2/users/check_login?username=${_username}" \
										| {
											read -r _response_code
											read -r # here we would read the response body if need it
											if [[ $_response_code != 204 ]] ; then
  												_die  "The username ${_username} is already exists."
											fi
										}

# Here we can be only if _username is available

# Call a function to pipe JSON from file, extract JSON property
_customer_tenant_id=$(_get_id_from_file "${DIR}/../customer.json")


# Construct JSON to request a user creation
_json='{
		"tenant_id": "'${_customer_tenant_id}'",
		"login": "'${_username}'",
		"contact": {
      				"email": "'${_email}'"
					}
	  }'

# To create a user
# POST API call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
# $2 - Content-Type
# $3 - POST data
# The result is stored in user.json file
_post_api_call_bearer "api/2/users" \
					"application/json" \
					"${_json}" > "${DIR}/../user.json"

# Call a function to pipe JSON from file, extract JSON property
_user_id=$(_get_id_from_file "${DIR}/../user.json")

# To activate a user by sending an e-mail
# POST API call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
# $2 - Content-Type
# $3 - POST data
# NEED TO POST WITH EMPTY BODY
# FOR SOME INTERNAL REST CALL IMPLEMENTATION REASON
# AN ERROR IS OCCURRED WITHOUT EMPTY BODY
_post_api_call_bearer "api/2/users/${_user_id}/send-activation-email" \
					  "application/json" \
					  ""