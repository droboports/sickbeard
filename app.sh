### python2 module ###
# Build a python2 module from source
__build_module() {
local VERSION="${2}"
local FOLDER="${1}-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://pypi.python.org/packages/source/$(echo ${1} | cut -c 1)/${1}/${FILE}"
local HPYTHON="${DROBOAPPS}/python2"
local XPYTHON="${HOME}/xtools/python2/${DROBO}"
export QEMU_LD_PREFIX="${TOOLCHAIN}/${HOST}/libc"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
sed -e "s/from distutils.core import setup/from setuptools import setup/g" \
    -i setup.py
PKG_CONFIG_PATH="${XPYTHON}/lib/pkgconfig" \
  LDFLAGS="${LDFLAGS} -Wl,-rpath,${HPYTHON}/lib -L${XPYTHON}/lib" \
  PYTHONPATH="${DEST}/lib/python2.7/site-packages" \
  "${XPYTHON}/bin/python" setup.py \
    build_ext --include-dirs="${XPYTHON}/include" --library-dirs="${XPYTHON}/lib" --force \
    build --force \
    build_scripts --executable="${HPYTHON}/bin/python" --force \
    install --prefix="${DEST}"
popd
}

### DEPENDENCIES ###
_build_modules() {
  mkdir -p "${DEST}/lib/python2.7/site-packages"

    __build_module Markdown 2.6.2
  __build_module Cheetah 2.4.4

  rm -vf "${DEST}/bin/cheetah"*
}

### SICKBEARD ###
_build_sickbeard() {
# 63rd commit after 0.507 in the development branch
local VERSION="0.507.63"
local COMMIT="7cfff7f0fa69946d37be8762b71b88ac60f10505"
local FOLDER="Sick-Beard-${COMMIT}"
local FILE="${FOLDER}.zip"
local URL="https://github.com/midgetspy/Sick-Beard/archive/${COMMIT}.zip"

_download_zip "${FILE}" "${URL}" "${FOLDER}"
mkdir -p "${DEST}/app"
sed -e "s|ssl_certificate_chain = None|ssl_certificate_chain = '/mnt/DroboFS/Shares/DroboApps/python2/etc/ssl/certs/ca-certificates.crt'|g" \
    -i "target/${FOLDER}/cherrypy/_cpserver.py"
cp -vfaR "target/${FOLDER}/"* "${DEST}/app/"
echo "SICKBEARD_VERSION = \"${VERSION} ${COMMIT:0:7}\"" > "${DEST}/app/sickbeard/version.py"
}

### BUILD ###
_build() {
  _build_modules
  _build_sickbeard
  _package
}
