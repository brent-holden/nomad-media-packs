[[- if var "enable_backup" . ]]
job "[[ var "job_name" . ]]-backup" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "namespace" . ]]"
  type        = "batch"

  periodic {
    crons            = ["[[ var "backup_cron_schedule" . ]]"]
    time_zone        = "[[ var "timezone" . ]]"
    prohibit_overlap = true
  }

  group "backup" {
    count = 1

    restart {
      attempts = 2
      interval = "5m"
      delay    = "30s"
      mode     = "fail"
    }

    reschedule {
      attempts  = 0
      unlimited = false
    }

    volume "fileflows-config" {
      type            = "host"
      source          = "[[ var "config_volume_name" . ]]"
      access_mode     = "single-node-multi-writer"
      attachment_mode = "file-system"
      read_only       = true
    }

    volume "backup-drive" {
      type            = "csi"
      source          = "[[ var "backup_volume_name" . ]]"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    task "backup" {
      driver = "podman"

      config {
        image = "docker.io/debian:bookworm-slim"
        args  = ["/bin/sh", "-c", "sleep 1 && /bin/sh /local/backup-fileflows.sh"]
      }

      volume_mount {
        volume      = "fileflows-config"
        destination = "/fileflows-config"
        read_only   = true
      }

      volume_mount {
        volume      = "backup-drive"
        destination = "/backups"
      }

      template {
        data = <<EOF
#!/bin/sh
set -e

echo "Starting FileFlows backup job..."

# Install rsync
echo "Installing rsync..."
apt-get update -qq && apt-get install -y -qq rsync > /dev/null 2>&1

# Source directories (FileFlows stores data under /app/Data)
FILEFLOWS_DB="/fileflows-config/FileFlows.db"
FILEFLOWS_CONFIG="/fileflows-config/fileflows.config"
FILEFLOWS_FLOWS="/fileflows-config/Flows"
FILEFLOWS_LIBRARIES="/fileflows-config/Libraries"
FILEFLOWS_PLUGINS="/fileflows-config/Plugins"
FILEFLOWS_SCRIPTS="/fileflows-config/Scripts"

# Destination directory
BACKUP_DIR="/backups/fileflows"
DATE=$(date +%Y-%m-%d)
BACKUP_DEST="$BACKUP_DIR/$DATE"

# Create backup directory structure
echo "Creating backup directory: $BACKUP_DEST"
mkdir -p "$BACKUP_DEST"

# Backup database file
if [ -f "$FILEFLOWS_DB" ]; then
    echo "Backing up FileFlows database..."
    cp "$FILEFLOWS_DB" "$BACKUP_DEST/"
    echo "Database backup complete."
else
    echo "Warning: FileFlows database not found at $FILEFLOWS_DB"
fi

# Backup config file
if [ -f "$FILEFLOWS_CONFIG" ]; then
    echo "Backing up fileflows.config..."
    cp "$FILEFLOWS_CONFIG" "$BACKUP_DEST/"
    echo "Config backup complete."
else
    echo "Warning: fileflows.config not found at $FILEFLOWS_CONFIG"
fi

# Backup flows directory
if [ -d "$FILEFLOWS_FLOWS" ]; then
    echo "Backing up Flows..."
    rsync -av --progress "$FILEFLOWS_FLOWS/" "$BACKUP_DEST/Flows/"
    echo "Flows backup complete."
else
    echo "Note: Flows directory not found at $FILEFLOWS_FLOWS"
fi

# Backup libraries directory
if [ -d "$FILEFLOWS_LIBRARIES" ]; then
    echo "Backing up Libraries..."
    rsync -av --progress "$FILEFLOWS_LIBRARIES/" "$BACKUP_DEST/Libraries/"
    echo "Libraries backup complete."
else
    echo "Note: Libraries directory not found at $FILEFLOWS_LIBRARIES"
fi

# Backup plugins directory
if [ -d "$FILEFLOWS_PLUGINS" ]; then
    echo "Backing up Plugins..."
    rsync -av --progress "$FILEFLOWS_PLUGINS/" "$BACKUP_DEST/Plugins/"
    echo "Plugins backup complete."
else
    echo "Note: Plugins directory not found at $FILEFLOWS_PLUGINS"
fi

# Backup scripts directory
if [ -d "$FILEFLOWS_SCRIPTS" ]; then
    echo "Backing up Scripts..."
    rsync -av --progress "$FILEFLOWS_SCRIPTS/" "$BACKUP_DEST/Scripts/"
    echo "Scripts backup complete."
else
    echo "Note: Scripts directory not found at $FILEFLOWS_SCRIPTS"
fi

# Clean up old backups (keep last N days)
echo "Cleaning up old backups (keeping last [[ var "backup_retention_days" . ]] days)..."
find "$BACKUP_DIR" -maxdepth 1 -type d -name "20*" -mtime +[[ var "backup_retention_days" . ]] -exec rm -rf {} \; 2>/dev/null || true

# Show backup size
echo "Backup complete. Size:"
du -sh "$BACKUP_DEST"

echo "Successfully backed up FileFlows to $BACKUP_DEST"
EOF
        destination = "local/backup-fileflows.sh"
        perms       = "0755"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
[[- end ]]
