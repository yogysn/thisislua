const isDeno = typeof Deno !== 'undefined'
  && typeof Deno[Deno.internal].core !== 'undefined';
const isBun = typeof process !== 'undefined'
  && typeof process.versions.bun !== 'undefined';
const isNode = typeof process !== 'undefined'
  && process.release.name === 'node'
  && !isBun
  && !isDeno;

function getLibExtension() {
  const platform = getPlatform();
  if (platform === 'windows') {
    return 'dll';
  } else if (platform === 'macos') {
    return 'dylib';
  }

  return 'so';
}

function getPlatform() {
  if (isDeno) {
    return Deno.build.os;
  }

  const platform = process.platform;
  if (platform === 'win32') {
    return 'windows';
  }
  return platform;
}

function getArchitecture() {
  if (isDeno) {
    return Deno.build.arch;
  }

  const architecture = process.arch;
  if (architecture === 'x64') {
    return 'x86_64';
  } else if (architecture === 'arm64') {
    return 'aarch64'
  }

  return architecture;
}

function LuaWrapperNode(version, libFilePath, symbols) {
  // Not yet implemented
  // Possibly for nodejs I will use the ffi library or node-gyp, but for now I can't decide which one I will use.
  throw new Error('Not yet implemented');
}

function LuaWrapperDeno(version, libFilePath, symbols) {
  this.version = version;
  this._dl = Deno.dlopen(libFilePath, symbols);
}

function LuaWrapperBun(version, libFilePath, symbols) {
  const ffi = require('bun:ffi');
  this.version = version;
  this._dl = ffi.dlopen(libFilePath, symbols);
}

