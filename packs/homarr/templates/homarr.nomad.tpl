job "[[ var "job_name" . ]]" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "namespace" . ]]"
  type        = "service"

  group "homarr" {
    count = 1

    volume "homarr-config" {
      type            = "host"
      source          = "[[ var "config_volume_name" . ]]"
      access_mode     = "single-node-multi-writer"
      attachment_mode = "file-system"
    }

    network {
      mode = "host"
      port "http" {
        static = [[ var "port" . ]]
      }
    }

    task "homarr" {
      driver = "podman"

      resources {
        cpu    = [[ var "cpu" . ]]
        memory = [[ var "memory" . ]]
      }

      config {
        image        = "[[ var "image" . ]]"
        ports        = ["http"]
        network_mode = "host"
      }

      volume_mount {
        volume      = "homarr-config"
        destination = "/appdata"
      }

      template {
        data = <<EOH
TZ=[[ var "timezone" . ]]
PUID=[[ var "homarr_uid" . ]]
PGID=[[ var "homarr_gid" . ]]
DOCKER_IMAGE_VERSION={{- with nomadVar "[[ var "nomad_variable_path" . ]]" -}}{{ .version }}{{- end }}
EOH
        destination = "local/env_vars"
        env         = true
      }

[[- if var "register_consul_service" . ]]
      service {
        name = "[[ var "consul_service_name" . ]]"
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "30s"
          timeout  = "10s"
        }
      }
[[- end ]]
    }
  }
}
