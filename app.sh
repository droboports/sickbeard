### CHEETAH ###
_build_cheetah() {
local VERSION="2.4.4"
local FILE="Cheetah-${VERSION}-py2.7-linux-armv7l.egg"
local URL="https://github.com/droboports/python-cheetah/releases/download/v${VERSION}/${FILE}"
local XPYTHON="${HOME}/xtools/python2/${DROBO}"
export QEMU_LD_PREFIX="${TOOLCHAIN}/${HOST}/libc"

_download_file "${FILE}" "${URL}"
mkdir -p "${DEST}/lib/python2.7/site-packages"
PYTHONPATH="${DEST}/lib/python2.7/site-packages" \
  "${XPYTHON}/bin/easy_install" --prefix="${DEST}" --always-copy "download/${FILE}"
}

### CFFI ###
_build_cffi() {
# also installs pycparser
local VERSION="1.1.2"
local FILE="cffi-${VERSION}-py2.7-linux-armv7l.egg"
local URL="https://github.com/droboports/python-cffi/releases/download/v${VERSION}/${FILE}"
local XPYTHON="${HOME}/xtools/python2/${DROBO}"
export QEMU_LD_PREFIX="${TOOLCHAIN}/${HOST}/libc"

_download_file "${FILE}" "${URL}"
mkdir -p "${DEST}/lib/python2.7/site-packages"
PYTHONPATH="${DEST}/lib/python2.7/site-packages" \
  "${XPYTHON}/bin/easy_install" --prefix="${DEST}" --always-copy "download/${FILE}"
}

### CRYPTOGRAPHY ###
_build_cryptography() {
# also installs ipaddress enum34 six pyasn1 idna
# depends on cffi
local VERSION="0.9.1"
local FILE="cryptography-${VERSION}-py2.7-linux-armv7l.egg"
local URL="https://github.com/droboports/python-cryptography/releases/download/v${VERSION}/${FILE}"
local XPYTHON="${HOME}/xtools/python2/${DROBO}"
export QEMU_LD_PREFIX="${TOOLCHAIN}/${HOST}/libc"

_download_file "${FILE}" "${URL}"
mkdir -p "${DEST}/lib/python2.7/site-packages"
PYTHONPATH="${DEST}/lib/python2.7/site-packages" \
  "${XPYTHON}/bin/easy_install" --prefix="${DEST}" --always-copy "download/${FILE}"
}

### PYOPENSSL ###
_build_pyopenssl() {
# depends on cryptography
local VERSION="0.15.1"
local FILE="pyOpenSSL-${VERSION}-py2.7.egg"
local URL="https://github.com/droboports/python-pyopenssl/releases/download/v${VERSION}/${FILE}"
local XPYTHON="${HOME}/xtools/python2/${DROBO}"
export QEMU_LD_PREFIX="${TOOLCHAIN}/${HOST}/libc"

_download_file "${FILE}" "${URL}"
mkdir -p "${DEST}/lib/python2.7/site-packages"
PYTHONPATH="${DEST}/lib/python2.7/site-packages" \
  "${XPYTHON}/bin/easy_install" --prefix="${DEST}" --always-copy "download/${FILE}"
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
sed -e "s|ssl_certificate_chain = None|ssl_certificate_chain = '/mnt/DroboFS/Shares/DroboApps/python2/etc/ssl/certs/ca-certificates.crt'|g" -i "target/${FOLDER}/cherrypy/_cpserver.py"
cp -vfaR "target/${FOLDER}/"* "${DEST}/app/"
echo "SICKBEARD_VERSION = \"${VERSION} ${COMMIT:0:7}\"" > "${DEST}/app/sickbeard/version.py"
}

### BUILD ###
_build() {
  _build_cheetah
  _build_cffi
  _build_cryptography
  _build_pyopenssl
  _build_sickbeard
  _package
}
