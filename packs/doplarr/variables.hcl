variable "job_name" {
  description = "The name to use for the job"
  type        = string
  default     = "doplarr"
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
  description = "The container image to use for Doplarr"
  type        = string
  default     = "ghcr.io/brent-holden/doplarr_rs:latest"
}

variable "timezone" {
  description = "The timezone for the Doplarr container"
  type        = string
  default     = "America/New_York"
}

variable "cpu" {
  description = "The CPU resources to allocate (MHz)"
  type        = number
  default     = 200
}

variable "memory" {
  description = "The memory resources to allocate (MB)"
  type        = number
  default     = 256
}

variable "log_level" {
  description = "Log level: info, debug, doplarr=debug, etc."
  type        = string
  default     = "info"
}

variable "public_followup" {
  description = "Make request confirmations visible to everyone in the channel"
  type        = bool
  default     = true
}

// --- Discord ---

variable "discord_token" {
  description = "Discord bot token (from Discord Developer Portal). Required if not using Slack."
  type        = string
  default     = ""
}

// --- Slack ---

variable "slack_bot_token" {
  description = "Slack bot token (xoxb-...). Required if not using Discord."
  type        = string
  default     = ""
}

variable "slack_signing_secret" {
  description = "Slack app signing secret. Required when using Slack."
  type        = string
  default     = ""
}

variable "slack_port" {
  description = "Port for the Slack HTTP server"
  type        = number
  default     = 3000
}

variable "expose_slack_port" {
  description = "Expose the Slack HTTP port (required when using Slack)"
  type        = bool
  default     = false
}

// --- Radarr ---

variable "radarr_url" {
  description = "Radarr URL (e.g., http://radarr:7878). Leave empty to skip."
  type        = string
  default     = ""
}

variable "radarr_api_key" {
  description = "Radarr API key"
  type        = string
  default     = ""
}

variable "radarr_media" {
  description = "Slash command name for Radarr backend"
  type        = string
  default     = "movie"
}

variable "radarr_quality_profile" {
  description = "Radarr quality profile name (exact match). Leave empty for user selection at request time."
  type        = string
  default     = ""
}

variable "radarr_rootfolder" {
  description = "Radarr root folder path. Leave empty for user selection at request time."
  type        = string
  default     = ""
}

variable "radarr_monitor_type" {
  description = "Radarr monitor type: movieOnly, movieAndCollection, none. Leave empty for user selection."
  type        = string
  default     = ""
}

variable "radarr_minimum_availability" {
  description = "Radarr minimum availability: tba, announced, inCinemas, released. Leave empty for user selection."
  type        = string
  default     = ""
}

// --- Sonarr ---

variable "sonarr_url" {
  description = "Sonarr URL (e.g., http://sonarr:8989). Leave empty to skip."
  type        = string
  default     = ""
}

variable "sonarr_api_key" {
  description = "Sonarr API key"
  type        = string
  default     = ""
}

variable "sonarr_media" {
  description = "Slash command name for Sonarr backend"
  type        = string
  default     = "series"
}

variable "sonarr_quality_profile" {
  description = "Sonarr quality profile name (exact match). Leave empty for user selection at request time."
  type        = string
  default     = ""
}

variable "sonarr_rootfolder" {
  description = "Sonarr root folder path. Leave empty for user selection at request time."
  type        = string
  default     = ""
}

variable "sonarr_monitor_type" {
  description = "Sonarr monitor type. Leave empty for user selection."
  type        = string
  default     = ""
}

variable "sonarr_series_type" {
  description = "Sonarr series type: standard, daily, anime. Leave empty to auto-detect."
  type        = string
  default     = ""
}

variable "sonarr_season_folders" {
  description = "Use season folders in Sonarr. Leave empty for user selection."
  type        = string
  default     = ""
}

variable "sonarr_allow_specials" {
  description = "Offer Season 0 (specials) when requesting seasons. Leave empty for default (false)."
  type        = string
  default     = ""
}

variable "sonarr_allowed_monitor_types" {
  description = "Comma-separated list of allowed monitor types (e.g., firstSeason,lastSeason,recent). Leave empty to allow all."
  type        = string
  default     = ""
}

// --- Seerr ---

variable "seerr_url" {
  description = "Seerr URL (e.g., http://seerr:5055). Leave empty to skip."
  type        = string
  default     = ""
}

variable "seerr_api_key" {
  description = "Seerr admin API key"
  type        = string
  default     = ""
}

variable "seerr_media" {
  description = "Slash command name for Seerr backend"
  type        = string
  default     = "media"
}

variable "seerr_fallback_user_id" {
  description = "Seerr user ID for unlinked users. Leave empty to reject unlinked users."
  type        = string
  default     = ""
}

variable "seerr_allow_4k" {
  description = "Show 4K quality option in Seerr. Leave empty for default (false)."
  type        = string
  default     = ""
}

// --- Consul ---

variable "register_consul_service" {
  description = "Register the Doplarr service with Consul"
  type        = bool
  default     = true
}

variable "consul_service_name" {
  description = "The name to register with Consul"
  type        = string
  default     = "doplarr"
}
