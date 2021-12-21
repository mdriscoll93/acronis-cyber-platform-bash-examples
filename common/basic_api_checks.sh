#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null||echo "$0")

# The directory where current script resides
DIR=$(dirname "${THIS}")

# Basic checks to ensure needed file availability
if test -f "${DIR}/../api_client.json" ; then
	_check_tenant_id=$(_get_tenant_id_from_file "${DIR}/../api_client.json")

	if [[ "$_check_tenant_id" = "null" ]]; then
		_die "The file ${DIR}/../api_client.json has incorrect format. Please call ${DIR}/../authorization/01.create-api-client.sh to create it."
	fi
else
	_die "The file ${DIR}/../api_client.json doesn't exist. Please call ${DIR}/../authorization/01.create-api-client.sh to create it."
fi

# Check an authorization token and renew if needed
# Need to have valid api_client.json
_renew_token_if_needed

# Call a function to pipe JSON from file, extract JSON property, remove quotas from the property's value
_access_token=$(_get_access_token_from_file "${DIR}/../api_token.json")

# If we have bc token, read it to variable
if test -f "${DIR}/../api_token_customer_scope.json" ; then
	# Call a function to pipe JSON from file, extract JSON property, remove quotas from the property's value
	_access_token_bc=$(_get_access_token_from_file "${DIR}/../api_token_customer_scope.json")
fi