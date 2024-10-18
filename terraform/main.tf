locals {
  secrets = yamldecode(file(pathexpand(var.secrets_yaml_path)))

  # we don't want to configure this one...
  flux_namespace = "flux-system"
}

data "github_repository" "this" {
  full_name = "${var.github_org}/${var.github_repo}"
}

resource "flux_bootstrap_git" "this" {
  version = "v${var.flux_version}"

  path      = "k8s/clusters/${var.env}"
  namespace = local.flux_namespace
}

resource "kind_cluster" "this" {
  name            = var.env
  node_image      = "kindest/node:v${var.k8s_version}"
  kubeconfig_path = pathexpand("~/.kube/kind-photoneo")
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
    }

    node {
      role = "worker"
    }
  }
}

# contains variables necessary to configure deployments running on k8s cluster
resource "kubernetes_config_map_v1" "deployments" {
  metadata {
    name      = "deployments"
    namespace = local.flux_namespace
  }

  data = {
    ingress_class = "ngrok"
    apex_domain   = var.ngrok_domain
  }

  # namespace has to be created first
  depends_on = [flux_bootstrap_git.this]
}

# contains secrets necessary to configure deployments running on k8s cluster
resource "kubernetes_secret_v1" "deployments" {
  metadata {
    name      = "deployments"
    namespace = local.flux_namespace
  }

  data = {
    ngrok_auth_token = local.secrets["ngrok_auth_token"]
    ngrok_api_key    = local.secrets["ngrok_api_key"]
  }

  # namespace has to be created first
  depends_on = [flux_bootstrap_git.this]
}
