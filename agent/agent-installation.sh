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

# Get installation token for the agent installation
_installation_token=$(_get_installation_token_from_file "${DIR}/../agent_installation_token.json")

export HISTIGNORE='*sudo -S*'

echo "<your_sudo_password>" | sudo -S -k ./Cyber_Protection_Agent_for_Linux_x86_64.bin -a --rain "${_base_url}"  --token "${_installation_token}"
