data "github_repository" "this" {
  full_name = "${var.github_org}/${var.github_repo}"
}

resource "flux_bootstrap_git" "this" {
  version = "v${var.flux_version}"

  path      = "k8s/clusters/${var.env}"
  namespace = "flux-system"
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
