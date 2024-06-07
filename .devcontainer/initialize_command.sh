#!/bin/bash
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

# Obtained and modified from:
# https://github.com/PACE-INT/pace/blob/c6554255fbb6ed49a6a835fe9e703bb2283f1ed7/.devcontainer/initializeCommand.sh

success() {
  echo >&2 -en "\e[32m" # Green
  echo >&2 -e "success: $1"
  echo >&2 -en "\e[0m" # Normal
}

warn() {
  echo >&2 -en "\e[33m" # Yellow
  echo >&2 -e "$1"
  echo >&2 "The container will attempt to be started despite this problem."
  echo >&2 -en "\e[0m" # Normal
}

fatal_fail() {
  echo >&2 -en "\e[31m" # Red
  echo >&2 -e "$1"
  echo >&2 "Container will not start properly due to this error. Please resolve and try again."
  echo >&2 -en "\e[0m" # Normal
  exit 1
}

create_bind_targets() {
  touch ${HOME}/.netrc
  touch ${HOME}/.Xauthority
  mkdir -p /tmp/.X11-unix
  mkdir -p ${HOME}/.config/nvim
  mkdir -p ${HOME}/.ssh
}

create_bind_targets || warn "Could not create bind targets in your home folder. Please check that your home folder is writable."
