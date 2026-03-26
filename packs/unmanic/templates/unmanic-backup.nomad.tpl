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

    volume "unmanic-config" {
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
        args  = ["/bin/sh", "-c", "sleep 1 && /bin/sh /local/backup-unmanic.sh"]
      }

      volume_mount {
        volume      = "unmanic-config"
        destination = "/unmanic-config"
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

echo "Starting Unmanic backup job..."

# Install rsync
echo "Installing rsync..."
apt-get update -qq && apt-get install -y -qq rsync > /dev/null 2>&1

# Source directories (Unmanic stores data under .unmanic/)
UNMANIC_DB="/unmanic-config/.unmanic/config/unmanic.db"
UNMANIC_SETTINGS="/unmanic-config/.unmanic/config/settings.json"
UNMANIC_PLUGINS="/unmanic-config/.unmanic/plugins"

# Destination directory
BACKUP_DIR="/backups/unmanic"
DATE=$(date +%Y-%m-%d)
BACKUP_DEST="$BACKUP_DIR/$DATE"

# Create backup directory structure
echo "Creating backup directory: $BACKUP_DEST"
mkdir -p "$BACKUP_DEST"

# Backup database file
if [ -f "$UNMANIC_DB" ]; then
    echo "Backing up Unmanic database..."
    cp "$UNMANIC_DB" "$BACKUP_DEST/"
    echo "Database backup complete."
else
    echo "Warning: Unmanic database not found at $UNMANIC_DB"
fi

# Backup settings file
if [ -f "$UNMANIC_SETTINGS" ]; then
    echo "Backing up settings.json..."
    cp "$UNMANIC_SETTINGS" "$BACKUP_DEST/"
    echo "Settings backup complete."
else
    echo "Warning: settings.json not found at $UNMANIC_SETTINGS"
fi

# Backup plugins directory
if [ -d "$UNMANIC_PLUGINS" ]; then
    echo "Backing up Unmanic plugins..."
    rsync -av --progress "$UNMANIC_PLUGINS/" "$BACKUP_DEST/plugins/"
    echo "Plugins backup complete."
else
    echo "Warning: Plugins directory not found at $UNMANIC_PLUGINS"
fi

# Clean up old backups (keep last N days)
echo "Cleaning up old backups (keeping last [[ var "backup_retention_days" . ]] days)..."
find "$BACKUP_DIR" -maxdepth 1 -type d -name "20*" -mtime +[[ var "backup_retention_days" . ]] -exec rm -rf {} \; 2>/dev/null || true

# Show backup size
echo "Backup complete. Size:"
du -sh "$BACKUP_DEST"

echo "Successfully backed up Unmanic to $BACKUP_DEST"
EOF
        destination = "local/backup-unmanic.sh"
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
