#!/usr/bin/env sh
#
# SickBeard service

# import DroboApps framework functions
. /etc/service.subr

framework_version="2.1"
name="sickbeard"
version="0.507.63-1"
description="The ultimate PVR application that searches for and manages your TV shows"
depends="python2"
webui="WebUI"

prog_dir="$(dirname "$(realpath "${0}")")"
daemon="${DROBOAPPS_DIR}/python2/bin/python"
conffile="${prog_dir}/data/config.ini"
tmp_dir="/tmp/DroboApps/${name}"
pidfile="${tmp_dir}/pid.txt"
logfile="${tmp_dir}/log.txt"
statusfile="${tmp_dir}/status.txt"
errorfile="${tmp_dir}/error.txt"

# backwards compatibility
if [ -z "${FRAMEWORK_VERSION:-}" ]; then
  framework_version="2.0"
  . "${prog_dir}/libexec/service.subr"
fi

start() {
  HOME="${prog_dir}/data" \
  PATH="${prog_dir}/libexec:${DROBOAPPS_DIR}/git/bin:${PATH}" \
  PYTHONPATH="${prog_dir}/lib/python2.7/site-packages" \
  "${daemon}" "${prog_dir}/app/SickBeard.py" --datadir="${prog_dir}/data" --pidfile="${pidfile}" --nolaunch --daemon
}

# boilerplate
if [ ! -d "${tmp_dir}" ]; then mkdir -p "${tmp_dir}"; fi
exec 3>&1 4>&2 1>> "${logfile}" 2>&1
STDOUT=">&3"
STDERR=">&4"
echo "$(date +"%Y-%m-%d %H-%M-%S"):" "${0}" "${@}"
set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o xtrace   # enable script tracing

main "${@}"
