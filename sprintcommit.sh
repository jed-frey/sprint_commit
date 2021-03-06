#!/usr/bin/env bash
# sprintcommit.sh [COMMIT_TIME]
#  Arguments:
#     COMMIT_TIME: Time (s) to sleep between commits.
#        Default: 300s (5 minutes)
#        If the value is zero (0) sprintcommit.sh runs once and exits.
#
#  A tool for commiting code changes during 'in the zone' development sprints.
#
#  A brute force hammer written by a Mechanical/Industrial Engineer frustrated
#  at the disproportonate amount of time 'managing' git when we were supposed
#  to be working.

#MIT License
#
#Copyright (c) 2018 Jed Frey
#
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

### Variables
##
COMMIT_TIME=${1:-300}

## Configurable Variables
# Binary to use for git.
#  Use 'echo git' to debug.
#  Example usage:
#     export GIT_BIN=`echo git'
#     setenv GIT_BIN 'echo git'
#     DEBUG=0 GIT_BIN='echo git' ./sprintcommit.sh
GIT_BIN=${GIT_BIN:-git}

# Print off variables and exit.
# If DEBUG is not 0, print off variables and exit.
#  Example usage:
#     export DEBUG=1
#     setenv DEBUG 1
#     DEBUG=1 ./sprintcommit.sh
DEBUG=${DEBUG:-0}

# Files to add to git during development.
# Before commiting
#  Example usage:
#     export ADD_PATHSPEC='*.py *.ipynb'
#     setenv ADD_PATHSPEC '*.py *.ipynb'
#     ADD_PATHSPEC='*.py *.ipynb' DEBUG=0 GIT_BIN='echo git' ./sprintcommit.sh
#     ADD_PATHSPEC='*.sh' DEBUG=0 GIT_BIN='echo git' ./sprintcommit.sh
ADD_PATHSPEC=${ADD_PATHSPEC:-}

## Ground Truth Variables
export SPRINT_SCRIPT=`realpath ${0}`
export SPRINT_DIRECTORY=`dirname ${SPRINT_SCRIPT}`
export SPRINT_T0=`date --universal`
PYTHON=`which python`
if [ "${?}" -eq "0" ]; then
export SPRINT_VERSION=`${PYTHON} ${SPRINT_DIRECTORY}/setup.py --version`
else
export SPRINT_VERSION=UNKNOWN
fi

# exit 0

## Script Body
# If DEBUG is not equal to 0.
if [ "${DEBUG}" -ne "0" ]; then
# Print off all of the variables.
echo \${SPRINT_SCRIPT}=${SPRINT_SCRIPT}
echo \${SPRINT_DIRECTORY}=${SPRINT_DIRECTORY}
echo \${SPRINT_T0}=${SPRINT_T0}
echo \${SPRINT_VERSION}=${SPRINT_VERSION}
echo \$COMMIT_TIME=${COMMIT_TIME}
echo \$ADD_PATHSPEC=${ADD_PATHSPEC}
echo \$GIT_BIN=${GIT_BIN}
echo \$DEBUG=${DEBUG}
exit 0
fi
# The boring stuff of git, automated.
while [ 1 ];
do
# Fetch.
echo
echo ----------------
echo --- Fetching ---
echo ----------------
${GIT_BIN} fetch \
   --verbose \
   --all \
   --depth=100 \
   --force \
   --tags \
   --recurse-submodules=no \
   --jobs=8
echo

# Add.
if [ "${ADD_PATHSPEC}" != "" ]; then
echo
echo ----------------
echo --- Adding "${ADD_PATHSPEC}"  ---
echo ----------------
bak=${GLOBIGNORE}
export GLOBIGNORE="*"
for PATHSPEC in ${ADD_PATHSPEC}; do
${GIT_BIN} add --verbose -- "${PATHSPEC}"
done
export GLOBIGNORE=${bak}
fi

# Commit.
COMMIT_MSG=${COMMIT_MSG:-"`hostname`: `date --universal`"}
echo
echo ----------------
echo --- Committing ${COMMIT_MSG}  ---
echo ----------------
${GIT_BIN} commit \
   --all \
   --message "${COMMIT_MSG}"\
   --verbose
echo

# Push.
echo
echo ----------------
echo --- Pushing ---
echo ----------------
${GIT_BIN} push \
   --signed=false \
   --set-upstream \
   --verbose \
   --progress \
   --recurse-submodules=on-demand \
   --verify \
   --ipv4 \
   origin-ssh
echo

# Break if asked.
if [ "${COMMIT_TIME}" == "0" ]; then
   exit 0
fi

# Sleep for given time.
echo
echo --- Sleeping until `date -d "+${COMMIT_TIME} second"` ---
echo ---------------------------------------------------------
echo `fortune`
echo ---------------------------------------------------------
sleep ${COMMIT_TIME}
done
