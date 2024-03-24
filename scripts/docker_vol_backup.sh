#!/bin/bash

BACKUP_DIR="/tmp/volumes-backup"
S3_BUCKET="s3://backup-c-bv.dev"
DAYS_TO_KEEP=5

echo "🚀 Starting backup of Docker volumes"

# Check if the backup directory exists, and create it if it doesn't
if [ ! -d "${BACKUP_DIR}" ]; then
    echo "Creating backup directory ${BACKUP_DIR}"
    mkdir -p "${BACKUP_DIR}"
fi

# Loop over each Docker volume
for VOLUME in $(docker volume ls -q); do
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    BACKUP_NAME="${VOLUME}_${TIMESTAMP}.tar.gz"

    # Create a backup of the volume
    CONTAINER_ID=$(docker run -d -v ${VOLUME}:/volume busybox true)
    docker cp ${CONTAINER_ID}:/volume ${BACKUP_DIR}/${VOLUME}
    docker rm -v ${CONTAINER_ID}

    # Compress the backup
    tar -czf ${BACKUP_DIR}/${BACKUP_NAME} -C ${BACKUP_DIR} ${VOLUME}
    rm -rf ${BACKUP_DIR}/${VOLUME}

    # Upload the compressed backup to an S3 bucket and delete local backup
    aws s3 cp ${BACKUP_DIR}/${BACKUP_NAME} ${S3_BUCKET}/volumes/${BACKUP_NAME} && rm ${BACKUP_DIR}/${BACKUP_NAME}
    echo "✅ Backup of volume ${VOLUME} completed"
done

# Remove S3 backups older than X days
OLDER_THAN_DATE=$(date -d "-${DAYS_TO_KEEP} days" +%Y%m%d)
aws s3 ls ${S3_BUCKET}/volumes/ | grep 'tar.gz' | awk '{print $4}' | while read BACKUP; do
    if [ -z "$BACKUP" ]; then
        echo "No backup file name found, skipping..."
        continue
    fi

    # Extract the YYYYMMDD part from the backup file name for comparison
    BACKUP_DATE=$(echo ${BACKUP} | grep -oP "\d{8}")
    if [[ ! -z ${BACKUP_DATE} && ${BACKUP_DATE} -lt ${OLDER_THAN_DATE} ]]; then
        aws s3 rm "${S3_BUCKET}/volumes/${BACKUP}"
        echo "❌ Removed old backup ${BACKUP}"
    fi
done


echo "🎉 Backup of Docker volumes completed"