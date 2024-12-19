#!/usr/bin/bash

set -eu -o pipefail

CURRENT_DIR="$(pwd)"
FORCE_BUILD="0"
source "scripts/_utilities.sh"

__build_lua_so() {
  VERSION="$1"
  SO_DEST_PATH="$DIST_DIR"/"liblua$VERSION.so"
  LUA_SOURCE_PATH="$(__get_lua_source_path "$VERSION")"
  if [[ -f "$SO_DEST_PATH" ]] && [[ "$FORCE_BUILD" != "1" ]]; then
    echo "Lua $VERSION shared object have been built, skipped."
  else
    if [[ "$VERSION" == "5.1" ]] || [[ "$VERSION" == "5.2" ]]; then
      cd "$LUA_SOURCE_PATH"/src
      make MYCFLAGS="-fPIC" o
    else
      cd "$LUA_SOURCE_PATH"
      make MYCFLAGS="-fPIC"
    fi

    rm -f lua.o luac.o
    gcc -shared -o liblua.so *.o
    mv -f liblua.so "$SO_DEST_PATH"
    make clean
    cd "$CURRENT_DIR"
  fi
}

__build_lua_jit_so() {
  VERSION="$1"
  SO_DEST_PATH="$DIST_DIR"/"libluajit$VERSION.so"
  LUA_JIT_SOURCE_PATH="$(__get_lua_jit_source_path "$VERSION")"
  if [[ -f "$SO_DEST_PATH" ]] && [[ "$FORCE_BUILD" != "1" ]]; then
    echo "Lua JIT $VERSION shared object have been built, skipped."
  else
    cd "$LUA_JIT_SOURCE_PATH"
    make
    mv -f src/libluajit.so "$SO_DEST_PATH"
    make clean
    cd "$CURRENT_DIR"
  fi
}

__build_so() {
  for VERSION in $LUA_VERSIONS; do
    __build_lua_so "$VERSION"
  done

  for VERSION in $LUA_JIT_VERSIONS; do
    __build_lua_jit_so "$VERSION"
  done
}

if ! [[ -d "$LUA_SOURCE_DIR" ]]; then
  LUA_SOURCE_BASENAME="$(basename "$LUA_SOURCE_DIR")"
  echo "The '$LUA_SOURCE_BASENAME' directory was not found."
  echo "TIPS: Make sure the script runs in the directory where the '$LUA_SOURCE_BASENAME' directory is located."
  exit 1
fi

if ! [ -d "$DIST_DIR" ]; then
  mkdir "$DIST_DIR"
fi

__build_so
