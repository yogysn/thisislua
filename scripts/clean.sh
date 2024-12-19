#!/usr/bin/bash

set -eu -o pipefail

CURRENT_DIR="$(pwd)"
source "scripts/_utilities.sh"

__clean_lua_so() {
  VERSION="$1"
  LUA_SOURCE_PATH="$(__get_lua_source_path "$VERSION")"
  if [[ "$VERSION" == "5.1" ]] || [[ "$VERSION" == "5.2" ]]; then
    cd "$LUA_SOURCE_PATH"/src
  else
    cd "$LUA_SOURCE_PATH"
  fi

  make clean
  cd "$CURRENT_DIR"
}

__clean_lua_jit_so() {
  VERSION="$1"
  LUA_JIT_SOURCE_PATH="$(__get_lua_jit_source_path "$VERSION")"
  cd "$LUA_JIT_SOURCE_PATH"

  make clean
  cd "$CURRENT_DIR"
}

__clean_so() {
  for VERSION in $LUA_VERSIONS; do
    __clean_lua_so "$VERSION"
  done

  for VERSION in $LUA_JIT_VERSIONS; do
    __clean_lua_jit_so "$VERSION"
  done
}

if ! [[ -d "$LUA_SOURCE_DIR" ]]; then
  LUA_SOURCE_BASENAME="$(basename "$LUA_SOURCE_DIR")"
  echo "The '$LUA_SOURCE_BASENAME' directory was not found."
  echo "TIPS: Make sure the script runs in the directory where the '$LUA_SOURCE_BASENAME' directory is located."
  exit 1
fi

if [ -d "$DIST_DIR" ]; then
  rm -rf "$DIST_DIR"
fi
__clean_so
