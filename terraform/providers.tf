provider "github" {
  owner = var.github_org
  token = trimspace(local.secrets["github_token"])
}

provider "flux" {
  kubernetes = {
    host                   = kind_cluster.this.endpoint
    cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
    client_key             = kind_cluster.this.client_key
    client_certificate     = kind_cluster.this.client_certificate
  }
  git = {
    url    = data.github_repository.this.http_clone_url
    branch = "main"
    http = {
      username = "git" # this can be any string when using a personal access token
      password = trimspace(local.secrets["github_token"])
    }
  }
}

provider "kubernetes" {
  host                   = kind_cluster.this.endpoint
  cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
  client_key             = kind_cluster.this.client_key
  client_certificate     = kind_cluster.this.client_certificate
}
