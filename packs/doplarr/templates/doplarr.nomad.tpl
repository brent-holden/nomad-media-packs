job "[[ var "job_name" . ]]" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "namespace" . ]]"
  type        = "service"

  group "doplarr" {
    count = 1

    network {
      mode = "host"
    }

    task "doplarr" {
      driver = "podman"

      resources {
        cpu    = [[ var "cpu" . ]]
        memory = [[ var "memory" . ]]
      }

      config {
        image        = "[[ var "image" . ]]"
        force_pull   = true
        network_mode = "host"
      }

      template {
        data = <<EOH
TZ=[[ var "timezone" . ]]
LOG_LEVEL=[[ var "log_level" . ]]
PUBLIC_FOLLOWUP=[[ var "public_followup" . ]]

# Platform tokens are read from Nomad variables so they stay out of job specs.
# Set them with:
#   nomad var put nomad/jobs/doplarr discord_token="YOUR_TOKEN"
#   nomad var put nomad/jobs/doplarr slack_bot_token="xoxb-..." slack_app_token="xapp-..."
{{- with nomadVar "nomad/jobs/doplarr" }}
{{ if .discord_token }}DISCORD__TOKEN={{ .discord_token }}{{ end }}
{{ if .slack_bot_token }}SLACK__BOT_TOKEN={{ .slack_bot_token }}{{ end }}
{{ if .slack_app_token }}SLACK__APP_TOKEN={{ .slack_app_token }}{{ end }}
{{- end }}

[[- if ne (var "radarr_url" .) "" ]]
RADARR__URL=[[ var "radarr_url" . ]]
RADARR__API_KEY=[[ var "radarr_api_key" . ]]
RADARR__MEDIA=[[ var "radarr_media" . ]]
[[- if ne (var "radarr_quality_profile" .) "" ]]
RADARR__QUALITY_PROFILE=[[ var "radarr_quality_profile" . ]]
[[- end ]]
[[- if ne (var "radarr_rootfolder" .) "" ]]
RADARR__ROOTFOLDER=[[ var "radarr_rootfolder" . ]]
[[- end ]]
[[- if ne (var "radarr_monitor_type" .) "" ]]
RADARR__MONITOR_TYPE=[[ var "radarr_monitor_type" . ]]
[[- end ]]
[[- if ne (var "radarr_minimum_availability" .) "" ]]
RADARR__MINIMUM_AVAILABILITY=[[ var "radarr_minimum_availability" . ]]
[[- end ]]
[[- end ]]

[[- if ne (var "sonarr_url" .) "" ]]
SONARR__URL=[[ var "sonarr_url" . ]]
SONARR__API_KEY=[[ var "sonarr_api_key" . ]]
SONARR__MEDIA=[[ var "sonarr_media" . ]]
[[- if ne (var "sonarr_quality_profile" .) "" ]]
SONARR__QUALITY_PROFILE=[[ var "sonarr_quality_profile" . ]]
[[- end ]]
[[- if ne (var "sonarr_rootfolder" .) "" ]]
SONARR__ROOTFOLDER=[[ var "sonarr_rootfolder" . ]]
[[- end ]]
[[- if ne (var "sonarr_monitor_type" .) "" ]]
SONARR__MONITOR_TYPE=[[ var "sonarr_monitor_type" . ]]
[[- end ]]
[[- if ne (var "sonarr_series_type" .) "" ]]
SONARR__SERIES_TYPE=[[ var "sonarr_series_type" . ]]
[[- end ]]
[[- if ne (var "sonarr_season_folders" .) "" ]]
SONARR__SEASON_FOLDERS=[[ var "sonarr_season_folders" . ]]
[[- end ]]
[[- if ne (var "sonarr_allow_specials" .) "" ]]
SONARR__ALLOW_SPECIALS=[[ var "sonarr_allow_specials" . ]]
[[- end ]]
[[- if ne (var "sonarr_allowed_monitor_types" .) "" ]]
SONARR__ALLOWED_MONITOR_TYPES=[[ var "sonarr_allowed_monitor_types" . ]]
[[- end ]]
[[- end ]]

[[- if ne (var "seerr_url" .) "" ]]
SEERR__URL=[[ var "seerr_url" . ]]
SEERR__API_KEY=[[ var "seerr_api_key" . ]]
SEERR__MEDIA=[[ var "seerr_media" . ]]
[[- if ne (var "seerr_fallback_user_id" .) "" ]]
SEERR__FALLBACK_USER_ID=[[ var "seerr_fallback_user_id" . ]]
[[- end ]]
[[- if ne (var "seerr_allow_4k" .) "" ]]
SEERR__ALLOW_4K=[[ var "seerr_allow_4k" . ]]
[[- end ]]
[[- end ]]
EOH
        destination = "local/env_vars"
        env         = true
      }

[[- if var "register_consul_service" . ]]
      service {
        name = "[[ var "consul_service_name" . ]]"
      }
[[- end ]]
    }
  }
}
