terraform {
  required_version = "1.8.3"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.3.1"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.4.0"
    }
    kind = {
      source  = "tehcyx/kind"
      version = "0.6.0"
    }
  }
}
