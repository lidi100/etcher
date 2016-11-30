#!/bin/bash

###
# Copyright 2016 resin.io
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###

# See http://www.davidpashley.com/articles/writing-robust-shell-scripts/
set -u
set -e

function check_dep() {
  if ! command -v $1 2>/dev/null 1>&2; then
    echo "Dependency missing: $1" 1>&2
    exit 1
  fi
}

function get_package_setting() {
  node -e "console.log(require('./package.json').$1)"
}

check_dep aws

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <file>" 1>&2
  exit 1
fi

APPLICATION_VERSION=$(get_package_setting "version")
S3_BUCKET="resin-production-downloads"

aws s3api put-object \
  --bucket "$S3_BUCKET" \
  --acl public-read \
  --key "etcher/$APPLICATION_VERSION/$(basename "$1")" \
  --body "$1"