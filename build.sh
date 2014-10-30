#!/usr/bin/env bash

### bash best practices ###
# exit on error code
set -o errexit
# exit on unset variable
set -o nounset
# return error of last failed command in pipe
set -o pipefail
# expand aliases
shopt -s expand_aliases
# print trace
set -o xtrace

### logfile ###
timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
logfile="logfile_${timestamp}.txt"
echo "${0} ${@}" > "${logfile}"
# save stdout to logfile
exec 1> >(tee -a "${logfile}")
# redirect errors to stdout
exec 2> >(tee -a "${logfile}" >&2)

### environment variables ###
source crosscompile.sh
export NAME="sickbeard"
export DEST="/mnt/DroboFS/Shares/DroboApps/${NAME}"
export DEPS="${PWD}/target/install"
export CFLAGS="${CFLAGS:-} -Os -fPIC"
export CXXFLAGS="${CXXFLAGS:-} ${CFLAGS}"
export CPPFLAGS="-I${DEPS}/include"
export LDFLAGS="${LDFLAGS:-} -Wl,-rpath,${DEST}/lib -L${DEST}/lib"
alias make="make -j8 V=1 VERBOSE=1"

# $1: file
# $2: url
# $3: folder
_download_tgz() {
  [[ ! -f "download/${1}" ]] && wget -O "download/${1}" "${2}"
  [[ -d "target/${3}" ]] && rm -v -fr "target/${3}"
  [[ ! -d "target/${3}" ]] && tar -zxvf "download/${1}" -C target
  return 0
}

# $1: file
# $2: url
# $3: folder
_download_zip() {
  [[ ! -f "download/${1}" ]] && wget -O "download/${1}" "${2}"
  [[ -d "target/${3}" ]] && rm -v -fr "target/${3}"
  [[ ! -d "target/${3}" ]] && unzip -d "target" "download/${1}"
  return 0
}

# $1: file
# $2: url
# $3: folder
_download_app() {
  [[ ! -f "download/${1}" ]] && wget -O "download/${1}" "${2}"
  [[ -d "target/${3}" ]] && rm -v -fr "target/${3}"
  mkdir -p "target/${3}"
  tar -zxvf "download/${1}" -C target/${3}
  return 0
}

# $1: branch
# $2: folder
# $3: url
_download_git() {
  [[ -d "target/${2}" ]] && rm -v -fr "target/${2}"
  [[ ! -d "target/${2}" ]] && git clone --branch "${1}" --single-branch --depth 1 "${3}" "target/${2}"
  return 0
}

# $1: file
# $2: url
_download_file() {
  [[ ! -f "download/${1}" ]] && wget -O "download/${1}" "${2}"
  return 0
}

### CHEETAH ###
_build_cheetah() {
local VERSION="2.4.4"
local FILE="Cheetah-${VERSION}-py2.7-linux-armv7l.egg"
local URL="https://github.com/droboports/python-cheetah/releases/download/v${VERSION}/${FILE}"
local XPYTHON=~/xtools/python2/${DROBO}

_download_file "${FILE}" "${URL}"
mkdir -p "${DEST}/lib/python2.7/site-packages"
_PYTHON_HOST_PLATFORM="linux-armv7l" PYTHONPATH="${DEST}/lib/python2.7/site-packages" ${XPYTHON}/bin/easy_install --prefix="${DEST}" --always-copy "download/${FILE}"
}

### PYOPENSSL ###
_build_pyopenssl() {
local VERSION="0.13"
local FILE="pyOpenSSL-${VERSION}-py2.7-linux-armv7l.egg"
local URL="https://github.com/droboports/python-pyopenssl/releases/download/v${VERSION}/${FILE}"
local XPYTHON=~/xtools/python2/${DROBO}

_download_file "${FILE}" "${URL}"
mkdir -p "${DEST}/lib/python2.7/site-packages"
_PYTHON_HOST_PLATFORM="linux-armv7l" PYTHONPATH="${DEST}/lib/python2.7/site-packages" ${XPYTHON}/bin/easy_install --prefix="${DEST}" --always-copy "download/${FILE}"
}

### SICKBEARD ###
_build_sickbeard() {
local BRANCH="master"
local FOLDER="app"
local URL="https://github.com/midgetspy/Sick-Beard.git"

_download_git "${BRANCH}" "${FOLDER}" "${URL}"
mkdir -p "${DEST}/app"
cp -avR "target/${FOLDER}"/* "${DEST}/app/"

#local VERSION="506"
#local FOLDER="Sick-Beard-build-${VERSION}"
#local FILE="build-${VERSION}.tar.gz"
#local URL="https://github.com/midgetspy/Sick-Beard/archive/${FILE}"

#_download_tgz "${FILE}" "${URL}" "${FOLDER}"
#mkdir -p "${DEST}/app"
#cp -avR "target/${FOLDER}"/* "${DEST}/app/"
}

### BUILD ###
_build() {
  _build_cheetah
  _build_pyopenssl
  _build_sickbeard
  _package
}

_create_tgz() {
  local appname="$(basename ${PWD})"
  local appfile="${PWD}/${appname}.tgz"

  if [[ -f "${appfile}" ]]; then
    rm -v "${appfile}"
  fi

  pushd "${DEST}"
  tar --verbose --create --numeric-owner --owner=0 --group=0 --gzip --file "${appfile}" *
  popd
}

_package() {
  mkdir -p "${DEST}"
  cp -avfR src/dest/* "${DEST}"/
  find "${DEST}" -name "._*" -print -delete
  _create_tgz
}

_clean() {
  rm -v -fr "${DEPS}"
  rm -v -fr "${DEST}"
  rm -v -fr target/*
}

_dist_clean() {
  _clean
  rm -v -f logfile*
  rm -v -fr download/*
}

case "${1:-}" in
  clean)     _clean ;;
  distclean) _dist_clean ;;
  package)   _package ;;
  "")        _build ;;
  *)         _build_${1} ;;
esac
