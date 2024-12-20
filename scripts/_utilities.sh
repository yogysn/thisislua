set -eu -o pipefail

LUA_SOURCE_DIR="$CURRENT_DIR"/lua
DIST_DIR="$CURRENT_DIR"/dist
LUA_VERSIONS="5.1 5.2 5.3 5.4"
LUA_JIT_VERSIONS="2.0 2.1"

__is_installed() {
  command -v "$1" > /dev/null
}

__get_lua_source_path() {
  echo "$LUA_SOURCE_DIR/lua$1"
}

__get_lua_jit_source_path() {
  echo "$LUA_SOURCE_DIR/luajit$1"
}
