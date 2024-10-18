# BrightPick interview

## Project description

Demonstration of simple web app deployment using IaaC tools, k8s and GitOps approach.

Terraform is used for IaaC management of the whole setup. \
Flux is used to handle GitOps approach. \
kind is used to run k8s cluster locally in Docker. \
ngrok ('globally distributed reverse proxy'), together with their ingress controller used for reachabilty from outer world.

## Dependencies

tooling:
- OpenTofu - to manage Iaac
- Docker - to run k8s cluster locally

external:
- GitHub token with repo push access
- ngrok credentials and domain (get by following ngrok docs [Step 1](https://ngrok.com/docs/using-ngrok-with/k8s/#step-1-get-your-ngrok-authtoken-and-api-key))

## How to setup
If you have any development environment setup tool that supports simple .tool-version format (mise, asdf, ...)
you can use it to init tooling dependencies (only OpenTofu now).

You also have to init some [`variables`](/terraform/terraform.tfvars):

- [`secrets_yaml_path`](/terraform/terraform.tfvars#1) contains (as clear from the name) secrets essential for the setup:

```yaml
github_token: <value> # description in dependencies
ngrok_auth_token: <value> # description in dependencies
ngrok_api_key: <value> # # description in dependencies
```

- [`ngrok_domain`](/terraform/terraform.tfvars#11) for domain described in dependencies

Then, everything you need to do is enter
```bash
cd terraform
tofu apply
```

In a few minutes when everything goes up you should be able to access demo web page at the domain you entered.

What will happen:
1. __[Terraform]__ runs kind cluster on local machine
1. __[Terraform]__ installs Flux to the GitHub repo (manifests) and in the cluster (workloads, CRDs, etc.)
1. __[Terraform]__ creates some 'glue' manifests necessary to have only 1 source of truth for Flux substitute
1. __[Flux]__ deploys ngrok-ingress-controller to handle connection between k8s and outer world
1. __[Flux]__ deploys simple demo app to demonstrate reachability from outside

## Tools choice reasoning

- __Terraform__ - OpenTofu respectively; one of standards for IaaC managing, also a tool I'm strong in thus ideal one for such fast prototyping
- __kind__ - since I tried Talos but their own solution with libvirt and Vagrant in howto doesn't work(!)
  I had to choose something able to deploy fast & simply \
  this minimalistic k8s in Docker distribution is ideal for the purpose; it's important it has Terraform provider support as well
- __ngrok.com__ - I don't have IPv6 address, jump host with public addres or any other method how to access my computer behind NAT this is an ideal,
  'quick & dirty' solution; also it's important it has direct k8s support with ingress controller so the use is so-said instant \
  3rd thing is that nothing is exposed except of essential minimum and the whole traffic is HTTPS-based

## Caveats

- scalability is limited compared to intended VM/Talos solution since the kind cluster needs to be redeployed on each config change (of the cluster)

## Space for improvements

- use SOPS-encrypted file in repo to store secrets instead of reading them from some config file
- Terragrunt and other k8s manifests structure could be used for multiple env supports
