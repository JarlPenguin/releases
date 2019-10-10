#!/bin/bash

export my_dir=$(pwd)

source "${my_dir}/config.sh"

# Email for git
git config --global user.email "${GITHUB_EMAIL}"
git config --global user.name "${GITHUB_USER}"

cd "${ROM_DIR}"

source "${my_dir}/sync.sh"
