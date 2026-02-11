#!/bin/sh

# Backup script for FreeBSD using rclone
# Backs up important system files and home directory to remote storage via rclone mount

set -e

# Configuration
BACKUP_MOUNT="/mnt/backup/$(date +%Y-%m-%d)"
RCLONE_CONFIG="${RCLONE_CONFIG:-/root/.config/rclone/rclone.conf}"
RCLONE_REMOTE="${RCLONE_REMOTE:-remote-ksb:Backups/hetzner/rclone/bgp-router}"
LOG_FILE="/var/log/backup.log"

# Backup directories to sync
BACKUP_DIRS=(
    "/boot/loader.conf"
    "/etc"
    "/usr/local/etc"
    "/home"
)

# Colors for output (only if terminal)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    GREEN=''
    RED=''
    YELLOW=''
    NC=''
fi

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

# Error handling
cleanup() {
    if [ $? -ne 0 ]; then
        log "ERROR" "Backup failed with exit code $?"
        exit 1
    fi
}
trap cleanup EXIT


# Create necessary backup directories
create_dirs() {
    log "INFO" "Creating backup directories..."
    # create dir for the date if not exists
    mkdir -p "${BACKUP_MOUNT}/boot"
    mkdir -p "${BACKUP_MOUNT}/etc"
    mkdir -p "${BACKUP_MOUNT}/usr/local/etc"
    mkdir -p "${BACKUP_MOUNT}/home"
    log "INFO" "Backup directories created/verified"
}

# Backup installed packages list
backup_installed_packages() {
    log "INFO" "Backing up list of installed packages..."
    pkg prime-list > "${BACKUP_MOUNT}/pkglist" || log "ERROR" "Failed to backup installed packages list"
}

# Perform rsync backups
perform_backup() {
    log "INFO" "Starting backup of system files and home directory..."
    
    # Backup boot configuration
    if [ -f "/boot/loader.conf" ]; then
        log "INFO" "Backing up /boot/loader.conf..."
        rsync -a --delete "/boot/loader.conf" "${BACKUP_MOUNT}/boot/" || log "ERROR" "Failed to backup /boot/loader.conf"
    fi
    
    # Backup /etc
    if [ -d "/etc" ]; then
        log "INFO" "Backing up /etc..."
        rsync -a --delete "/etc/" "${BACKUP_MOUNT}/etc/" || log "ERROR" "Failed to backup /etc"
    fi
    
    # Backup /usr/local/etc
    if [ -d "/usr/local/etc" ]; then
        log "INFO" "Backing up /usr/local/etc..."
        rsync -a --delete "/usr/local/etc/" "${BACKUP_MOUNT}/usr/local/etc/" || log "ERROR" "Failed to backup /usr/local/etc"
    fi
    
    # Backup /home
    if [ -d "/home" ]; then
        log "INFO" "Backing up /home..."
        rsync -a --delete "/home/" "${BACKUP_MOUNT}/home/" || log "ERROR" "Failed to backup /home"
    fi
    
    log "INFO" "Backup completed successfully"
}

# Delete Backups older than 7 days
clean_old_backups() {
    log "INFO" "Cleaning up backups older than 7 days..."
    find /mnt/backup/ -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \; && \
    log "INFO" "Old backups cleaned up"
}

# Generate backup report
report() {
    log "INFO" "Backup Statistics:"
    log "INFO" "==================="
    log "INFO" "Backup location: ${BACKUP_MOUNT}"
    log "INFO" "Backup size: $(du -sh ${BACKUP_MOUNT} 2>/dev/null | cut -f1)"
    log "INFO" "Backup timestamp: $(date)"
}

# Main execution
main() {
    log "INFO" "==============================================="
    log "INFO" "Starting backup process"
    log "INFO" "==============================================="
    

    create_dirs
    backup_installed_packages
    perform_backup
    clean_old_backups
    report
    

    log "INFO" "==============================================="
    log "INFO" "Backup process completed successfully"
    log "INFO" "==============================================="
}

# Run main function
main
