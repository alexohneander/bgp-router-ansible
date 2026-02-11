#!/bin/sh
#
# PROVIDE: rclone
# REQUIRE: NETWORKING DAEMON
# BEFORE: LOGIN
# KEYWORD: shutdown
#
# Add the following lines to /etc/rc.conf to enable rclone:
#
# rclone_enable (bool): Set to "YES" to enable rclone mount at boot.
#                       Default: "NO"
# rclone_config (str):  Path to rclone config. Default: "/root/.config/rclone/rclone.conf"
# rclone_remote (str):  Remote name to mount. Default: "remote-ksb:Backups/hetzner/rclone/bgp-router"
# rclone_mount (str):   Mount point. Default: "/mnt/backup"
#

. /etc/rc.subr

name="rclone"
rcvar="${name}_enable"
command="/usr/local/bin/rclone"

load_rc_config $name

# Defaults
: ${rclone_enable:="NO"}
: ${rclone_config:="/root/.config/rclone/rclone.conf"}
: ${rclone_remote:="remote-ksb:Backups/hetzner/rclone/bgp-router"}
: ${rclone_mount:="/mnt/backup"}

# Create mount point if it doesn't exist
if [ ! -d "${rclone_mount}" ]; then
    mkdir -p "${rclone_mount}"
fi

# rclone mount command with options
start_cmd="${name}_start"
stop_cmd="${name}_stop"

rclone_start()
{
    echo "Mounting rclone remote..."
    ${command} mount \
        "${rclone_remote}" \
        "${rclone_mount}" \
        --config "${rclone_config}" \
        --daemon \
        --log-file="/var/log/rclone.log" \
        --log-level=INFO \
        --allow-other \
        --default-permissions
    
    if [ $? -eq 0 ]; then
        echo "rclone mounted successfully at ${rclone_mount}"
    else
        echo "Failed to mount rclone"
        return 1
    fi
}

rclone_stop()
{
    echo "Unmounting rclone..."
    umount "${rclone_mount}" 2>/dev/null || fusermount -u "${rclone_mount}" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "rclone unmounted successfully"
    fi
}

run_rc_command "$1"
