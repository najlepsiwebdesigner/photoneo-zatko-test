secrets_yaml_path = "~/work/photoneo/secrets.yaml"

github_org  = "zatkowich"
github_repo = "photoneo-test"

env = "dev"

# trivy-operator is not supported by 1.31
# https://github.com/aquasecurity/trivy-operator/issues/2251
k8s_version  = "1.30.4"
flux_version = "2.4.0"

ngrok_domain = "fowl-feasible-grossly.ngrok-free.app"
