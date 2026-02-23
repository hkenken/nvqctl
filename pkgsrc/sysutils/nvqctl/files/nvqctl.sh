#!/bin/sh
#
# $NetBSD$
#
# PROVIDE: nvqctl
# REQUIRE: NETWORKING mountall
# BEFORE:  DAEMON
# KEYWORD: shutdown
#
# Add the following to /etc/rc.conf to enable:
#   nvqctl=YES
#   nvqctl_vms="vm1 vm2"
#   nvqctl_shutdown_timeout=120
#

. /etc/rc.subr

name="nvqctl"
rcvar="${name}"

: ${nvqctl_vms:=""}
: ${nvqctl_shutdown_timeout:=120}

NVQCTL="@PREFIX@/sbin/nvqctl"

start_cmd="nvqctl_start"
stop_cmd="nvqctl_stop"
status_cmd="nvqctl_status"

nvqctl_start()
{
	if [ -z "${nvqctl_vms}" ]; then
		echo "No VMs configured in nvqctl_vms."
		return 0
	fi
	for _vm in ${nvqctl_vms}; do
		echo "Starting VM: ${_vm}"
		${NVQCTL} start "${_vm}"
	done
}

nvqctl_stop()
{
	if [ -z "${nvqctl_vms}" ]; then
		return 0
	fi
	for _vm in ${nvqctl_vms}; do
		echo "Stopping VM: ${_vm}"
		${NVQCTL} stop "${_vm}" "${nvqctl_shutdown_timeout}"
	done
}

nvqctl_status()
{
	${NVQCTL} list
}

load_rc_config ${name}
run_rc_command "$1"
