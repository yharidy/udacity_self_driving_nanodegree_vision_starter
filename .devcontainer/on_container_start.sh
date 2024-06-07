#!/usr/bin/env bash
# ==============================================================================
#  C O P Y R I G H T
# ------------------------------------------------------------------------------
#  Copyright (c) 2021 by Robert Bosch GmbH. All rights reserved.
#
#  The reproduction, distribution and utilization of this file as
#  well as the communication of its contents to others without express
#  authorization is prohibited. Offenders will be held liable for the
#  payment of damages. All rights reserved in the event of the grant
#  of a patent, utility model or design.
# ==============================================================================
printf "\n✨ Preparing your DevEnv ✨\n"

echo "Setting up conan..."
#source .devcontainer/query_artifactory_credentials.sh
#conan user ${ARTIFACTORY_USER} -p ${ARTIFACTORY_TOKEN} -r shared-conan-prod 1>/dev/null
#conan user ${ARTIFACTORY_USER} -p ${ARTIFACTORY_TOKEN} -r shared-conan-dev 1>/dev/null

echo "Setting up env..."
mkdir -p $XDG_CONFIG_HOME/direnv/
printf '[whitelist]\nprefix = [ "%s" ]\n' "${WORKSPACE_FOLDER}" >$XDG_CONFIG_HOME/direnv/config.toml
