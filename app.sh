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
