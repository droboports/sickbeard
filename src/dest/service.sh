#!/usr/bin/env sh
#
# SickBeard service

# import DroboApps framework functions
. /etc/service.subr

# DroboApp framework version
framework_version="2.0"

# app description
name="sickbeard"
version="0.506"
description="Internet PVR for TV shows"

# framework-mandated variables
pidfile="/tmp/DroboApps/${name}/pid.txt"
logfile="/tmp/DroboApps/${name}/log.txt"
statusfile="/tmp/DroboApps/${name}/status.txt"
errorfile="/tmp/DroboApps/${name}/error.txt"

# app-specific variables
prog_dir=$(dirname $(readlink -fn ${0}))
python="${DROBOAPPS_DIR}/python2/bin/python"
conffile="${prog_dir}/data/config.ini"

# script hardening
set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o pipefail # propagate last error code on pipe

# ensure log folder exists
logfolder="$(dirname ${logfile})"
if [[ ! -d "${logfolder}" ]]; then mkdir -p "${logfolder}"; fi

# redirect all output to logfile
exec 3>&1 1>> "${logfile}" 2>&1

# log current date, time, and invocation parameters
echo $(date +"%Y-%m-%d %H-%M-%S"): ${0} ${@}

# enable script tracing
set -o xtrace

# _is_running
# args: path to pid file
# returns: 0 if pid is running, 1 if not running or if pidfile does not exist.
_is_running() {
  /sbin/start-stop-daemon -K -s 0 -x "${python}" -p "${pidfile}" -q
}

_create_config() {
  if [[ ! -f "${conffile}" ]]; then
    cp "${conffile}.default" "${conffile}"
  fi
}

start() {
  _create_config
  rm -f "${pidfile}"
  PATH="${prog_dir}/libexec:${DROBOAPPS_DIR}/git/bin:${PATH}" PYTHONPATH="${prog_dir}/lib/python2.7/site-packages" "${python}" "${prog_dir}/app/SickBeard.py" --datadir="${prog_dir}/data" --pidfile="${pidfile}" --nolaunch --daemon
}

_service_start() {
  set +e
  set +u
  if _is_running "${pidfile}"; then
    echo ${name} is already running >&3
    return 1
  fi
  start_service
  set -u
  set -e
}

_service_stop() {
  /sbin/start-stop-daemon -K -x "${python}" -p "${pidfile}" -v || echo "${name} is not running" >&3
}

_service_restart() {
  service_stop
  sleep 3
  service_start
}

_service_status() {
  status >&3
}

_service_help() {
  echo "Usage: $0 [start|stop|restart|status]" >&3
  set +e
  exit 1
}

case "${1:-}" in
  start|stop|restart|status) _service_${1} ;;
  *) _service_help ;;
esac
