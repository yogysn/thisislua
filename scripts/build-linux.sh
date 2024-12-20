#!/usr/bin/env bash

set -eu -o pipefail

CURRENT_DIR="$(pwd)"
CC_X86_64="$(which x86_64-linux-gnu-gcc)"
CC_AARCH64="$(which aarch64-linux-gnu-gcc)"
FORCE_BUILD="0"
source "scripts/_utilities.sh"

__build_lua_so() {
  SRC_DIR="$1"
  DEST_FILE="$2"
  CC="$3"
  MYCFLAGS="$4"

  if [[ -f "$DEST_FILE" ]] && [[ "$FORCE_BUILD" != "1" ]]; then
    echo "Lua $VERSION shared object have been built, skipped."
  else

    if [[ "$VERSION" == "5.1" ]] || [[ "$VERSION" == "5.2" ]]; then
      cd "$SRC_DIR"/src
    else
      cd "$SRC_DIR"
    fi

    make clean

    # The lua Makefile in version 5.4 has the -march=native option in CFLAGS,
    # which causes error for non-arm computers. To fix this,
    # the -march option will be removed in Makefile during the build process.
    if [[ "$VERSION" == "5.4" ]]; then
      __MAKEFILE_LINE_79="$(sed '79!d' makefile)"
      sed -i '79s/-march=native/ /' makefile
    fi

    make MYCFLAGS="-fPIC $MYCFLAGS" CC="$CC" o
    rm -f lua.o luac.o
    "$CC" -shared -o liblua.so *.o
    mv -f liblua.so "$DEST_FILE"

    [[ "$VERSION" == "5.4" ]] && sed -i "79s/.*/$__MAKEFILE_LINE_79/" makefile
    cd "$CURRENT_DIR"
  fi
}

__build_lua_jit_so() {
  SRC_DIR="$1"
  DEST_DIR="$2"
  ARCH="$3"

  if [[ -f "$DEST_DIR" ]] && [[ "$FORCE_BUILD" != "1" ]]; then
    echo "Lua JIT $VERSION shared object have been built, skipped."
  else
    cd "$SRC_DIR"

    make clean
    [[ "$ARCH" == "aarch64" ]] && make CROSS=aarch64-linux-gnu- || make
    mv -f src/libluajit.so "$DEST_DIR"

    cd "$CURRENT_DIR"
  fi
}

__build_so() {
  for VERSION in $LUA_VERSIONS; do
    SRC_DIR="$(__get_lua_source_path "$VERSION")"
    __build_lua_so "$SRC_DIR" "$DIST_DIR"/"liblua-$VERSION-x86_64.so" "$CC_X86_64" "-march=x86-64"
    __build_lua_so "$SRC_DIR" "$DIST_DIR"/"liblua-$VERSION-aarch64.so" "$CC_AARCH64" "-march=armv8-a"
  done

  for VERSION in $LUA_JIT_VERSIONS; do
    SRC_DIR="$(__get_lua_jit_source_path "$VERSION")"
    __build_lua_jit_so "$SRC_DIR" "$DIST_DIR"/"libluajit-$VERSION-x86_64.so" "x86_64"
    __build_lua_jit_so "$SRC_DIR" "$DIST_DIR"/"libluajit-$VERSION-x86_64.so" "aarch64"
  done
}

if ! [[ -d "$LUA_SOURCE_DIR" ]]; then
  LUA_SOURCE_BASENAME="$(basename "$LUA_SOURCE_DIR")"
  echo "The '$LUA_SOURCE_BASENAME' directory was not found."
  echo "TIPS: Make sure the script runs in the directory where the '$LUA_SOURCE_BASENAME' directory is located."
  exit 1
fi

! [ -d "$DIST_DIR" ] && mkdir "$DIST_DIR"
__build_so
