#!/bin/bash

export $(cat .env | xargs)

if [ $BACKUP_TO_RCLONE != true ]; then
    mkdir -p backups
    BACKUPS_ROOT="backups"
else
    BACKUPS_ROOT="."
fi

while true; do
    BACKUP_FILE_NAME="$(date +%s).archive"
    docker-compose exec -e \
    MONGO_INITDB_ROOT_USERNAME="${MONGO_INITDB_ROOT_USERNAME}" \
    -e MONGO_INITDB_ROOT_PASSWORD="${MONGO_INITDB_ROOT_PASSWORD}" \
    -e MONGO_DB_TO_BACKUP="${MONGO_DB_TO_BACKUP}" \
    mongo sh -c 'exec mongodump -d "$MONGO_DB_TO_BACKUP" -u \
    "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" \
    --authenticationDatabase admin --archive' \
    > $BACKUPS_ROOT/$BACKUP_FILE_NAME

    if [ $BACKUP_TO_RCLONE = true ]; then
        rclone move $BACKUPS_ROOT/$BACKUP_FILE_NAME \
        "$RCLONE_REMOTE_NAME:mongodb-backups/$MONGO_DB_TO_BACKUP" -P
    fi

    if [[ $1 = '--once' ]]; then
        break
    elif [[ $1 = '--every' ]]; then
        echo "Sleeping for $2 ..."
        sleep $2
    else
        sleep 1d
    fi
done
