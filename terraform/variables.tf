variable "github_org" {
  description = "GitHub organization of Flux repository"
  type        = string
  nullable    = false
}

variable "github_repo" {
  description = "GitHub repository for Flux"
  type        = string
  nullable    = false
}

variable "github_token_path" {
  description = "Path of GitHub token file for accessing Flux repository"
  type        = string
  nullable    = false
  sensitive   = true
}

variable "env" {
  description = "Deployment environment name"
  type        = string
  nullable    = false
}

variable "k8s_version" {
  description = "Kubernetes cluster version"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.k8s_version))
    error_message = "k8s version must be in semantic versioning format (e.g., 1.31.1)."
  }
}

variable "flux_version" {
  description = "Flux version deployed on k8s"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.flux_version))
    error_message = "Flux version must be in semantic versioning format (e.g., 2.4.0)."
  }
}
