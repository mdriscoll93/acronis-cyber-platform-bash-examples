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

# Create an acceptable date for tasks filtering
_last_week=$(date --date="-7 days" +%Y-%m-%dT00:00:00Z)

# Get list of all tasks completed during last 7 days for all subtenants
# of the tenant for which the API Client was issue
# GET API call with Bearer Authentication
# $1 - an API endpoint to call
_get_api_call_bearer "api/task_manager/v2/tasks?completedAt=gt(${_last_week})" \
					> "${DIR}/../all_task_for_the_last_week.json"