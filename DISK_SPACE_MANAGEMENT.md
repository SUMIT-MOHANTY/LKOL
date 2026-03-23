# Disk Space Management

This document describes the disk space management solution implemented to resolve the "No space left on device" issues during Git operations.

## Implemented Solution

1. **Cleanup Script**: `/workspace/cleanup_disk_space.sh`
   - Identifies and removes temporary files, caches, and logs
   - Cleans up package manager caches (apt, pip)
   - Removes Python cache files and incomplete Git repositories

2. **Preventive Measures**:
   - Git configuration optimized for space efficiency
   - Regular cleanup job via crontab (if available)
   - Log rotation configured (if logrotate is available)
   - Disk space monitoring script (`/workspace/monitor_disk_space.sh`)

3. **Pre-Git Operation Check**: `/workspace/pre_git_op.sh`
   - Runs before Git operations to ensure sufficient disk space

## How to Use

### Manual Cleanup

Run the cleanup script manually when needed:
