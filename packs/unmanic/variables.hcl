variable "job_name" {
  description = "The name to use for the job"
  type        = string
  default     = "unmanic"
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
  description = "The container image to use for Unmanic"
  type        = string
  default     = "docker.io/josh5/unmanic:latest"
}

variable "gpu_transcoding" {
  description = "Enable GPU passthrough for hardware transcoding (Intel B580 on /dev/dri/card1)"
  type        = bool
  default     = true
}

variable "unmanic_uid" {
  description = "The UID for the Unmanic user inside the container (PUID)"
  type        = number
  default     = 1002
}

variable "unmanic_gid" {
  description = "The GID for the Unmanic group inside the container (PGID)"
  type        = number
  default     = 1001
}

variable "timezone" {
  description = "The timezone for the Unmanic container"
  type        = string
  default     = "America/New_York"
}

variable "cpu" {
  description = "The CPU resources to allocate (MHz)"
  type        = number
  default     = 4000
}

variable "memory" {
  description = "The memory resources to allocate (MB)"
  type        = number
  default     = 4096
}

variable "port" {
  description = "The port to expose Unmanic on"
  type        = number
  default     = 8888
}

variable "config_volume_name" {
  description = "The name of the host volume for Unmanic configuration"
  type        = string
  default     = "unmanic-config"
}

variable "media_volume_name" {
  description = "The name of the CSI volume for media files"
  type        = string
  default     = "media-drive"
}

variable "cache_path" {
  description = "Host path for Unmanic's temporary encoding cache (/tmp/unmanic)"
  type        = string
  default     = "/tmp/unmanic"
}

variable "register_consul_service" {
  description = "Register the Unmanic service with Consul"
  type        = bool
  default     = true
}

variable "consul_service_name" {
  description = "The name to register with Consul"
  type        = string
  default     = "unmanic"
}
