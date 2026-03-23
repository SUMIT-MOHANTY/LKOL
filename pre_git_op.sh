# Check disk space and run cleanup if needed before Git operations
THRESHOLD=80
USAGE=$(df -P /workspace | awk 'NR==2 {print $5}' | tr -d '%')

if [[ $USAGE -gt $THRESHOLD ]]; then
    echo "Disk space usage is high (${USAGE}%). Running cleanup before Git operation..."
    /workspace/cleanup_disk_space.sh
fi
