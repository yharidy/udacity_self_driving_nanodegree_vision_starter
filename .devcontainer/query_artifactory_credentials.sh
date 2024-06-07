#!/usr/bin/env bash
#============================================================================================================
# C O P Y R I G H T
#------------------------------------------------------------------------------------------------------------
# \copyright (C) 2022 Robert Bosch GmbH and Cariad SE. All rights reserved.
#============================================================================================================

# File copied and modified from: https://github.com/PACE-INT/pace/

# Initialize vars
REPO_ROOT="${WORKSPACE_FOLDER:-$(git rev-parse --show-toplevel)}"
ARTIFACTORY_URL="jfrog.ad-alliance.biz"
export ARTIFACTORY_CREDENTIALS_VALIDATED=FALSE
NETRC_ARTIFACTORY_USER=
NETRC_ARTIFACTORY_TOKEN=

# Helper functions
function error_msg() {
  echo >&2 -en "\e[31m" # Red
  echo >&2 "error: $1"
  echo >&2 -en "\e[0m" # Normal
}
function info_msg() {
  echo >&1 -en "\e[32m" # Green
  echo >&1 "info: $1"
  echo >&1 -en "\e[0m" # Normal
}
function is_curl_available {
  command -v curl &>/dev/null
}
function is_artifactory_reachable {
  curl --silent --fail -X GET "https://$ARTIFACTORY_URL/router/api/v1/system/health" -o /dev/null
}
function are_credentials_set_as_env_vars {
  [[ -n "${ARTIFACTORY_USER:-}" && -n "${ARTIFACTORY_TOKEN:-}" ]]
}
function are_artifactory_credentials_valid {
  if ! are_credentials_set_as_env_vars; then return 1; fi
  if ! curl --silent --fail -u "${ARTIFACTORY_USER}":"${ARTIFACTORY_TOKEN}" -X GET "https://$ARTIFACTORY_URL/artifactory/api/system/ping" -o /dev/null; then
    error_msg "Can not login to '${ARTIFACTORY_URL}'."
    return 1
  else
    info_msg "Credentials successfully validated against '${ARTIFACTORY_URL}'."
    export ARTIFACTORY_CREDENTIALS_VALIDATED=TRUE
  fi
}
function retrieve_or_query {
  if are_credentials_set_as_env_vars; then
    info_msg "Artifactory credentials taken from existing env vars."
    return
  fi

  if [ -f "${HOME}/.netrc" ]; then
    NETRC_ARTIFACTORY_USER=$(awk "/machine ${ARTIFACTORY_URL}/ {f=1} f && /login/ {print \$2;f=0}" ${HOME}/.netrc)
    NETRC_ARTIFACTORY_TOKEN=$(awk "/machine ${ARTIFACTORY_URL}/ {f=1} f && /password/ {print \$2;f=0}" ${HOME}/.netrc)
  fi

  if [[ -n "${NETRC_ARTIFACTORY_USER}" && -n "${NETRC_ARTIFACTORY_TOKEN}" ]]; then
    export ARTIFACTORY_USER="${NETRC_ARTIFACTORY_USER}"
    export ARTIFACTORY_TOKEN="${NETRC_ARTIFACTORY_TOKEN}"
  else
    query_credentials
  fi
}
function query_credentials {
  echo
  info_msg "Please provide credentials for Artifactory:"
  echo
  echo " ----------------------------------  HINT  ---------------------------------- "
  echo "| User?                                                                      |"
  echo "|     Bosch:  <full.name>@de.bosch.com                                       |"
  echo "|     Cariad: <full.name>@cariad.technology                                  |"
  echo "| Identity Token?                                                            |"
  echo "|     See '${ARTIFACTORY_URL}' -> Edit profile -> Generate an Identity Token |"
  echo " ---------------------------------------------------------------------------- "
  echo -n "Username: "
  read -r ARTIFACTORY_USER
  echo -n "Identity Token: "
  read -r -s ARTIFACTORY_TOKEN
  echo
  export ARTIFACTORY_USER
  export ARTIFACTORY_TOKEN
}

# Main usecase
retrieve_or_query

# Missing tools on host scenario
if ! is_curl_available; then
  error_msg "'curl' is missing, therefore credentials cannot be validated and stored. Install with e.g. 'sudo apt install curl'"
  return # Exit early for this boundary case
fi

# Check connectivity
if ! is_artifactory_reachable; then
  error_msg "Can not reach artifactory, therefore credentials cannot be validated and stored. Are you connected to the internet?"
  return # Exit early for this boundary case
fi

# Validate credentials
while ! are_artifactory_credentials_valid; do
  query_credentials
done
