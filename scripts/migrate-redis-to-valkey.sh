#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Migration script: Redis 7.x/older to Valkey 8.x/9.x
# Manually run this script to migrate your Redis database to Valkey format

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REDIS_SERVICE="redis-xo"
REDIS_SOCKET="/run/redis-xo/redis.sock"
BACKUP_DIR="/var/lib/redis-xo-backup-$(date +%Y%m%d-%H%M%S)"
REDIS_DATA_DIR="/var/lib/redis-xo"
RDB_FILE="dump.rdb"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_service_exists() {
    if ! systemctl list-unit-files | grep -q "^${REDIS_SERVICE}.service"; then
        log_error "Service ${REDIS_SERVICE} not found"
        exit 1
    fi
}

create_backup() {
    log_info "Creating backup directory: ${BACKUP_DIR}"
    mkdir -p "${BACKUP_DIR}"

    log_info "Saving current Redis data..."

    # Try to trigger a save using redis-cli if available
    if command -v redis-cli &> /dev/null; then
        if [[ -S "${REDIS_SOCKET}" ]]; then
            log_info "Triggering Redis SAVE via socket..."
            redis-cli -s "${REDIS_SOCKET}" SAVE || log_warn "Could not trigger SAVE command"
            sleep 2
        fi
    fi

    # Backup the entire Redis data directory
    if [[ -d "${REDIS_DATA_DIR}" ]]; then
        log_info "Backing up Redis data directory..."
        cp -a "${REDIS_DATA_DIR}" "${BACKUP_DIR}/redis-data"
        log_success "Backup created at: ${BACKUP_DIR}"
    else
        log_warn "Redis data directory not found: ${REDIS_DATA_DIR}"
        log_info "This might be a fresh installation"
    fi
}

verify_rdb_file() {
    local rdb_path="${REDIS_DATA_DIR}/${RDB_FILE}"

    if [[ -f "${rdb_path}" ]]; then
        local file_size=$(stat -f%z "${rdb_path}" 2>/dev/null || stat -c%s "${rdb_path}" 2>/dev/null)
        log_info "Found RDB file: ${rdb_path} (${file_size} bytes)"

        # Check if file is readable
        if [[ -r "${rdb_path}" ]]; then
            log_success "RDB file is readable"
            return 0
        else
            log_warn "RDB file exists but is not readable"
            return 1
        fi
    else
        log_warn "No RDB file found at: ${rdb_path}"
        log_info "This might be a fresh installation with no data yet"
        return 1
    fi
}

get_redis_info() {
    if command -v redis-cli &> /dev/null && [[ -S "${REDIS_SOCKET}" ]]; then
        log_info "Current Redis/Valkey information:"
        redis-cli -s "${REDIS_SOCKET}" INFO server | grep -E "redis_version|redis_mode|os|process_id" || true

        local key_count=$(redis-cli -s "${REDIS_SOCKET}" DBSIZE 2>/dev/null || echo "unknown")
        log_info "Database size: ${key_count} keys"
    else
        log_warn "Cannot connect to Redis - service might be stopped"
    fi
}

stop_service() {
    log_info "Stopping ${REDIS_SERVICE} service..."
    systemctl stop "${REDIS_SERVICE}"
    sleep 2

    if systemctl is-active --quiet "${REDIS_SERVICE}"; then
        log_error "Failed to stop ${REDIS_SERVICE}"
        exit 1
    fi
    log_success "Service stopped"
}

start_service() {
    log_info "Starting ${REDIS_SERVICE} service..."
    systemctl start "${REDIS_SERVICE}"
    sleep 3

    if systemctl is-active --quiet "${REDIS_SERVICE}"; then
        log_success "Service started successfully"
    else
        log_error "Failed to start ${REDIS_SERVICE}"
        log_error "Check status with: systemctl status ${REDIS_SERVICE}"
        exit 1
    fi
}

verify_migration() {
    log_info "Verifying migration..."

    # Wait for service to be ready
    local retries=10
    while [[ $retries -gt 0 ]]; do
        if [[ -S "${REDIS_SOCKET}" ]]; then
            break
        fi
        log_info "Waiting for socket to be ready..."
        sleep 1
        ((retries--))
    done

    if ! [[ -S "${REDIS_SOCKET}" ]]; then
        log_error "Socket not available after migration"
        return 1
    fi

    if command -v redis-cli &> /dev/null; then
        log_info "Testing connection to Valkey..."
        if redis-cli -s "${REDIS_SOCKET}" PING | grep -q "PONG"; then
            log_success "Valkey is responding to PING"

            local key_count=$(redis-cli -s "${REDIS_SOCKET}" DBSIZE 2>/dev/null || echo "0")
            log_info "Current database size: ${key_count} keys"

            # Get server info
            log_info "Valkey server information:"
            redis-cli -s "${REDIS_SOCKET}" INFO server | grep -E "redis_version|redis_mode" || true

            return 0
        else
            log_error "Valkey is not responding to PING"
            return 1
        fi
    else
        log_warn "redis-cli not available, cannot verify connection"
        log_info "Manually verify with: systemctl status ${REDIS_SERVICE}"
    fi
}

show_rollback_instructions() {
    cat << EOF

${YELLOW}=== ROLLBACK INSTRUCTIONS ===${NC}

If you need to rollback to the old Redis data:

1. Stop the service:
   sudo systemctl stop ${REDIS_SERVICE}

2. Restore the backup:
   sudo rm -rf ${REDIS_DATA_DIR}
   sudo cp -a ${BACKUP_DIR}/redis-data ${REDIS_DATA_DIR}

3. Start the service:
   sudo systemctl start ${REDIS_SERVICE}

Backup location: ${BACKUP_DIR}

EOF
}

main() {
    echo -e "${GREEN}===================================${NC}"
    echo -e "${GREEN}Redis to Valkey Migration Script${NC}"
    echo -e "${GREEN}===================================${NC}"
    echo ""

    check_root
    check_service_exists

    log_info "Starting migration process..."
    echo ""

    # Pre-migration checks
    log_info "Step 1: Pre-migration verification"
    get_redis_info
    verify_rdb_file
    echo ""

    # Confirm with user
    read -p "$(echo -e ${YELLOW}Do you want to continue with the migration? [y/N]: ${NC})" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Migration cancelled by user"
        exit 0
    fi
    echo ""

    # Create backup
    log_info "Step 2: Creating backup"
    create_backup
    echo ""

    # Stop service
    log_info "Step 3: Stopping Redis service"
    stop_service
    echo ""

    # Since NixOS configuration already has Valkey configured,
    # we just need to start the service with the new package
    log_info "Step 4: Starting Valkey service"
    log_info "Note: Your NixOS configuration should already have 'services.redis.package = pkgs.valkey'"
    start_service
    echo ""

    # Verify
    log_info "Step 5: Verifying migration"
    if verify_migration; then
        echo ""
        log_success "Migration completed successfully!"
        show_rollback_instructions
    else
        echo ""
        log_error "Migration verification failed"
        log_error "Check logs with: journalctl -u ${REDIS_SERVICE} -n 50"
        show_rollback_instructions
        exit 1
    fi
}

main "$@"
