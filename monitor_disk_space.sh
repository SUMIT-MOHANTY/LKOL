
THRESHOLD=90
WORKSPACE_FS=$(df -P /workspace | awk 'NR==2 {print $1}')
USAGE=$(df -P | grep "$WORKSPACE_FS" | awk '{print $5}' | tr -d '%')

if [[ $USAGE -gt $THRESHOLD ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Disk space usage is critical: ${USAGE}%"
    echo "Running emergency cleanup..."
    bash /workspace/cleanup_disk_space.sh
fi
