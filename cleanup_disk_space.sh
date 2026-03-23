set -e
cd /workspace

# Function to print section headers
print_header() {
    echo "===================================================================="
    echo "= $1"
    echo "===================================================================="
}

# Function to log actions
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to get human-readable size from bytes
human_size() {
    local bytes=$1
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$(( (bytes + 512) / 1024 ))K"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$(( (bytes + 524288) / 1048576 ))M"
    else
        echo "$(( (bytes + 536870912) / 1073741824 ))G"
    fi
}

# Record initial space usage
print_header "INITIAL DISK SPACE SITUATION"
log_action "Current disk space usage:"
df -h
echo ""

# Identify filesystem with the workspace directory
WORKSPACE_FS=$(df -P /workspace | awk 'NR==2 {print $1}')
WORKSPACE_MOUNT=$(df -P /workspace | awk 'NR==2 {print $6}')
log_action "Workspace is on filesystem: $WORKSPACE_FS mounted at $WORKSPACE_MOUNT"

# Find largest files and directories
print_header "IDENTIFYING LARGE FILES AND DIRECTORIES"
log_action "Top 10 largest directories:"
du -xh $WORKSPACE_MOUNT | sort -rh | head -n 10
echo ""

log_action "Top 10 largest files:"
find $WORKSPACE_MOUNT -type f -exec du -h {} \; | sort -rh | head -n 10
echo ""

# Check for common space consumers
print_header "CHECKING COMMON SPACE CONSUMERS"

# Docker image and container cleanup
if command -v docker &> /dev/null; then
    log_action "Checking for unused Docker resources..."
    DOCKER_IMAGES_SPACE=$(docker system df 2>/dev/null | grep "Images" | awk '{print $4}' || echo "0B")
    DOCKER_CONTAINERS_SPACE=$(docker system df 2>/dev/null | grep "Containers" | awk '{print $4}' || echo "0B")
    log_action "Docker images space: $DOCKER_IMAGES_SPACE, containers space: $DOCKER_CONTAINERS_SPACE"

    log_action "Cleaning up Docker resources..."
    docker system prune -af &>/dev/null || log_action "Docker cleanup failed or not needed"
    SPACE_RECLAIMED="$(docker system df 2>/dev/null | grep "Reclaimable" | awk '{print $4}' || echo "Unknown")"
    log_action "Docker space reclaimed: $SPACE_RECLAIMED"
fi

# Check for temporary directories
log_action "Checking temporary directories..."
for tmp_dir in /tmp /var/tmp; do
    if [[ -d "$tmp_dir" ]]; then
        SIZE_BEFORE=$(du -s "$tmp_dir" 2>/dev/null | awk '{print $1}' || echo "0")
        log_action "Cleaning old files in $tmp_dir (excluding currently used files)..."
        find "$tmp_dir" -type f -atime +1 -delete 2>/dev/null || true
        find "$tmp_dir" -type d -empty -delete 2>/dev/null || true
        SIZE_AFTER=$(du -s "$tmp_dir" 2>/dev/null | awk '{print $1}' || echo "0")
        RECLAIMED=$((SIZE_BEFORE - SIZE_AFTER))
        log_action "Reclaimed approximately $(human_size $RECLAIMED) from $tmp_dir"
    fi
done

# Check for log files
log_action "Checking for large log files..."
LOG_SIZE_BEFORE=$(find /var/log -type f -name "*.log*" -o -name "*.gz" 2>/dev/null | xargs du -sc 2>/dev/null | tail -n 1 | awk '{print $1}' || echo "0")
find /var/log -type f -name "*.log*" -o -name "*.gz" -mtime +7 -delete 2>/dev/null || true
LOG_SIZE_AFTER=$(find /var/log -type f -name "*.log*" -o -name "*.gz" 2>/dev/null | xargs du -sc 2>/dev/null | tail -n 1 | awk '{print $1}' || echo "0")
RECLAIMED=$((LOG_SIZE_BEFORE - LOG_SIZE_AFTER))
log_action "Reclaimed approximately $(human_size $RECLAIMED) from log files"

# Check for package manager caches
if command -v apt-get &> /dev/null; then
    log_action "Cleaning APT cache..."
    SIZE_BEFORE=$(du -s /var/cache/apt 2>/dev/null | awk '{print $1}' || echo "0")
    apt-get clean &>/dev/null || true
    SIZE_AFTER=$(du -s /var/cache/apt 2>/dev/null | awk '{print $1}' || echo "0")
    RECLAIMED=$((SIZE_BEFORE - SIZE_AFTER))
    log_action "Reclaimed approximately $(human_size $RECLAIMED) from APT cache"
fi

if command -v pip &> /dev/null; then
    log_action "Cleaning pip cache..."
    PIP_CACHE_DIR=$(pip cache dir 2>/dev/null || echo "$HOME/.cache/pip")
    SIZE_BEFORE=$(du -s "$PIP_CACHE_DIR" 2>/dev/null | awk '{print $1}' || echo "0")
    pip cache purge &>/dev/null || true
    SIZE_AFTER=$(du -s "$PIP_CACHE_DIR" 2>/dev/null | awk '{print $1}' || echo "0")
    RECLAIMED=$((SIZE_BEFORE - SIZE_AFTER))
    log_action "Reclaimed approximately $(human_size $RECLAIMED) from pip cache"
fi

# Clean up old Python cache files
log_action "Cleaning Python cache files..."
find $WORKSPACE_MOUNT -type d -name "__pycache__" -o -name "*.pyc" -o -name "*.pyo" | xargs du -sc 2>/dev/null | tail -n 1 | { read size name; log_action "Found $size bytes in Python cache files"; }
find $WORKSPACE_MOUNT -type d -name "__pycache__" | xargs rm -rf 2>/dev/null || true
find $WORKSPACE_MOUNT -name "*.pyc" -o -name "*.pyo" -delete 2>/dev/null || true

# Clean up any previous failed git repositories
log_action "Cleaning up any incomplete Git repositories..."
find $WORKSPACE_MOUNT -name ".git" -type d | while read git_dir; do
    if [[ -d "$git_dir" && ! -f "$git_dir/config" ]]; then
        du -sh "$git_dir" 2>/dev/null | { read size dir; log_action "Removing incomplete Git repository at $dir ($size)"; }
        rm -rf "$git_dir" 2>/dev/null || true
    fi
done

# Clean up Node.js related files if they exist
if command -v npm &> /dev/null; then
    log_action "Cleaning npm cache..."
    npm cache clean --force &>/dev/null || true
    log_action "Looking for node_modules directories..."
    find $WORKSPACE_MOUNT -name "node_modules" -type d | xargs du -sh 2>/dev/null || echo "No node_modules found"
    # Only delete node_modules if they're not part of the canonical structure
    find $WORKSPACE_MOUNT -name "node_modules" -type d | grep -v "^$WORKSPACE_MOUNT/node_modules$" | xargs rm -rf 2>/dev/null || true
fi

# Implement a solution to prevent future space issues
print_header "IMPLEMENTING PREVENTIVE MEASURES"

# Create a Git configuration file to use less space
log_action "Configuring Git to use less disk space..."
cat <<'EOG' > /workspace/.gitconfig
[core]
    compression = 9
    bigFileThreshold = 1m
[fetch]
    recurseSubmodules = false
[gc]
    auto = 0
[protocol]
    version = 2
EOG
log_action "Git configured to optimize space usage"

# Add a regular cleanup job in crontab
if command -v crontab &> /dev/null; then
    log_action "Setting up regular cleanup job..."
    (crontab -l 2>/dev/null; echo "0 * * * * $WORKSPACE_MOUNT/cleanup_disk_space.sh > $WORKSPACE_MOUNT/cleanup.log 2>&1") | crontab - 2>/dev/null || log_action "Failed to set up crontab job"
    log_action "Regular cleanup job configured (hourly)"
fi

# Configure logrotate if available
if command -v logrotate &> /dev/null && [[ -d "/etc/logrotate.d" ]]; then
    log_action "Setting up log rotation for application logs..."
    cat <<'EOL' > /etc/logrotate.d/workspace_app
/workspace/*.log {
    daily
    rotate 3
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOL
    log_action "Log rotation configured"
fi

# Create a disk space monitoring script
log_action "Creating disk space monitoring script..."
cat <<'EOD' > /workspace/monitor_disk_space.sh

THRESHOLD=90
WORKSPACE_FS=$(df -P /workspace | awk 'NR==2 {print $1}')
USAGE=$(df -P | grep "$WORKSPACE_FS" | awk '{print $5}' | tr -d '%')

if [[ $USAGE -gt $THRESHOLD ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Disk space usage is critical: ${USAGE}%"
    echo "Running emergency cleanup..."
    bash /workspace/cleanup_disk_space.sh
fi
EOD
chmod +x /workspace/monitor_disk_space.sh
log_action "Disk space monitoring script created"

# Record final space usage
print_header "FINAL DISK SPACE SITUATION"
log_action "Current disk space usage after cleanup:"
df -h
echo ""

print_header "RECOMMENDATIONS FOR LONG-TERM SOLUTIONS"
cat <<'EOH'
1. Increase the container disk size if possible
2. Implement regular cleanup of temporary and cache files
3. Use shallow Git clones when possible (git clone --depth=1)
4. Consider implementing a log rotation policy
5. Monitor disk space usage regularly and set up alerts
6. Review application data storage patterns to minimize disk usage
7. Consider using external storage for large assets or data files
8. Optimize Docker image size and clean up unused images/containers regularly
9. Configure Git to use compression and avoid storing large files
10. Regularly run 'git gc' to optimize Git repositories
EOH

print_header "CLEANUP COMPLETE"
log_action "Disk space optimization completed successfully"
log_action "Regular automated maintenance has been set up"
