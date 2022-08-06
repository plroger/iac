terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
#variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
  # dop_v1_1a8b2d9fe3704526f492706cf5dcee63fc1e8d858ad7f9a5ff7d081501f77f52
}

# Create a web server
resource "digitalocean_kubernetes_cluster" "k8s_iniciativa" {
  name   = var.k8s_name
  # "k8s-iniciativa"
  region = var.region
  # "nyc1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.23.9-do.0"
  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

resource "digitalocean_kubernetes_node_pool" "node_premium" {
  cluster_id = digitalocean_kubernetes_cluster.k8s_iniciativa.id

  name       = "premium"
  size       = "s-4vcpu-8gb"
  node_count = 2
}

variable "do_token"{}
variable "k8s_name"{}
variable "region"{}

output "kube_endpoint" {
    value = digitalocean_kubernetes_cluster.k8s_iniciativa.endpoint
}

resource "local_file" "kube_config" {
    content  = digitalocean_kubernetes_cluster.k8s_iniciativa.kube_config.0.raw_config
    filename = "kube_config.yaml"
}
