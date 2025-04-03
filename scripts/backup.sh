#!/bin/bash
# AI Model Backup Script
set -euo pipefail  # Enable strict error handling

# Configuration
MODEL_DIR="${HOME}/models"
S3_BUCKET="chatpodman-backups"
BACKUP_NAME="model-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/var/log/chatpodman_backup.log"
MAX_BACKUPS=5  # Keep last 5 backups

# Verify prerequisites
command -v aws >/dev/null 2>&1 || { 
  echo "AWS CLI not found. Please install: https://aws.amazon.com/cli/"
  exit 1
}

[ -d "$MODEL_DIR" ] || {
  echo "Model directory not found: $MODEL_DIR"
  exit 1
}

# Initialize logging
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec &> >(tee -a "$LOG_FILE")

echo "=== Starting backup $(date) ==="

# Create compressed archive first (better for large files)
echo "Creating local archive..."
tar -czf "/tmp/${BACKUP_NAME}.tar.gz" -C "$MODEL_DIR" .

# Upload to S3 with progress tracking
echo "Uploading to S3..."
aws s3 cp "/tmp/${BACKUP_NAME}.tar.gz" "s3://${S3_BUCKET}/${BACKUP_NAME}.tar.gz" \
  --storage-class STANDARD_IA \
  --acl bucket-owner-full-control \
  --no-progress \
  --only-show-errors

# Cleanup old backups
echo "Rotating old backups..."
aws s3 ls "s3://${S3_BUCKET}/" | grep -o "model-.*\.tar\.gz" | sort -r | \
  tail -n +$(($MAX_BACKUPS + 1)) | while read -r old_backup; do
    echo "Deleting old backup: $old_backup"
    aws s3 rm "s3://${S3_BUCKET}/$old_backup"
  done

# Local cleanup
rm -f "/tmp/${BACKUP_NAME}.tar.gz"

echo "Backup completed successfully: s3://${S3_BUCKET}/${BACKUP_NAME}.tar.gz"
echo "Size: $(aws s3 ls "s3://${S3_BUCKET}/${BACKUP_NAME}.tar.gz" | awk '{print $3/1048576 "MB"}')"
