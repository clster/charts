#!/usr/bin/env bash
set -euo pipefail

# TODO add simple function to get env or from file var
RESTIC_HOSTNAME="${RESTIC_HOSTNAME:-$(hostname)}"
RESTIC_BACKUP_FLAGS="${RESTIC_BACKUP_FLAGS:-}"
IONICE_CLASS="${IONICE_CLASS:-2}"
IONICE_CLASSDATA="${IONICE_CLASSDATA:-7}"
NICE_ADJUSTMENT="${NICE_ADJUSTMENT:-19}"
# S3FS variables
S3FS_ENABLED="${S3FS_ENABLED:-true}"
S3FS_FLAGS="${S3FS_FLAGS:-}"
S3FS_AWS_ACCESS_KEY_ID="${S3FS_AWS_ACCESS_KEY_ID:-}"
S3FS_AWS_SECRET_ACCESS_KEY="${S3FS_AWS_SECRET_ACCESS_KEY:-}"
S3FS_MOUNTMODE="${S3FS_MOUNTMODE:-}"

# MountMode "obc" only variables
S3_PROTOCOL="${S3_PROTOCOL:-https}"
URL_PATH="${URL_PATH:-/}"

if [ -z "$BACKUP_TARGET" ]; then
    echo "Empty or no BACKUP_TARGET env var set."
    exit 1
fi

# Check if S3FS access and secret key are non-empty
if [ -n "$S3FS_AWS_ACCESS_KEY_ID" ] && [ -n "$S3FS_AWS_SECRET_ACCESS_KEY" ]; then
    echo "$S3FS_AWS_ACCESS_KEY_ID:$S3FS_AWS_SECRET_ACCESS_KEY" > /tmp/.passwd-s3fs
    chmod 600 /tmp/.passwd-s3fs
fi

if [ "$S3FS_ENABLED" = "true" ]; then
    echo "Mounting bucket using s3fs ..."
    mkdir -p "$BACKUP_TARGET"
    if [ "$S3FS_MOUNTMODE" = "obc" ]; then
        # shellcheck disable=SC2086
        s3fs "$S3FS_BUCKET_NAME" "$BACKUP_TARGET" \
            -o passwd_file=/tmp/.passwd-s3fs \
            -o url="$S3_PROTOCOL://$BUCKET_HOST:$BUCKET_PORT$URL_PATH" \
            $S3FS_FLAGS
    else
        # shellcheck disable=SC2086
        s3fs "$S3FS_BUCKET_NAME" "$BACKUP_TARGET" $S3FS_FLAGS
    fi
    echo "Mounted bucket using s3fs."
else
    echo "S3FS mount not enabled."
fi

echo "Running restic backup ..."
# shellcheck disable=SC2086
ionice -c "$IONICE_CLASS" -n "$IONICE_CLASSDATA" \
    nice -n "$NICE_ADJUSTMENT" \
        restic \
            backup \
            $RESTIC_BACKUP_FLAGS \
            --host "$RESTIC_HOSTNAME" \
            "$BACKUP_TARGET"

sleep 1
if [ "$S3FS_ENABLED" = "true" ]; then
    echo "Unmounting bucket using fuse ..."
    fusermount -u "$BACKUP_TARGET"
fi
