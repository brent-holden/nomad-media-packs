variable "job_name" {
  description = "The name to use for the job"
  type        = string
  default     = "homarr"
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed"
  type        = string
  default     = "global"
}

variable "namespace" {
  description = "The namespace where the job should be placed"
  type        = string
  default     = "default"
}

variable "image" {
  description = "The container image to use for Homarr"
  type        = string
  default     = "ghcr.io/homarr-labs/homarr:latest"
}

variable "homarr_uid" {
  description = "The UID for the Homarr user inside the container (PUID)"
  type        = number
  default     = 1002
}

variable "homarr_gid" {
  description = "The GID for the Homarr group inside the container (PGID)"
  type        = number
  default     = 1001
}

variable "timezone" {
  description = "The timezone for the Homarr container"
  type        = string
  default     = "America/New_York"
}

variable "cpu" {
  description = "The CPU resources to allocate (MHz)"
  type        = number
  default     = 300
}

variable "memory" {
  description = "The memory resources to allocate (MB)"
  type        = number
  default     = 512
}

variable "port" {
  description = "The port to expose Homarr on"
  type        = number
  default     = 7575
}

variable "config_volume_name" {
  description = "The name of the host volume for Homarr configuration"
  type        = string
  default     = "homarr-config"
}

variable "register_consul_service" {
  description = "Register the Homarr service with Consul"
  type        = bool
  default     = true
}

variable "consul_service_name" {
  description = "The name to register with Consul"
  type        = string
  default     = "homarr"
}

variable "enable_backup" {
  description = "Enable periodic backup job for Homarr configuration"
  type        = bool
  default     = true
}

variable "backup_cron_schedule" {
  description = "Cron schedule for the backup job"
  type        = string
  default     = "0 2 * * *"
}

variable "backup_volume_name" {
  description = "The name of the CSI volume for backups"
  type        = string
  default     = "backup-drive"
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 14
}

variable "enable_update" {
  description = "Enable periodic job to fetch latest Homarr version"
  type        = bool
  default     = true
}

variable "update_cron_schedule" {
  description = "Cron schedule for the update job"
  type        = string
  default     = "0 3 * * *"
}

variable "nomad_variable_path" {
  description = "The Nomad variable path to store the version"
  type        = string
  default     = "nomad/jobs/homarr"
}
