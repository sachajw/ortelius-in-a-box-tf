terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.0.15"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.15.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.37.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.0"
    }
  }
  required_version = ">=1.0.0"
  }

provider "null" {
  # Configuration options
}

provider "aws" {
  # Configuration options
  region  = "eu-central-1"
  profile = "gsinonprod"
}

provider "kind" {
}

provider "kubernetes" {
  config_path = pathexpand(var.cluster_config_path)
}

provider "helm" {
  #debug = true
  kubernetes {
    #host                   = kind_cluster.default.endpoint
    #cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
    #client_certificate     = kind_cluster.default.client_certificate
    #client_key             = kind_cluster.default.client_key
    config_path            = pathexpand(var.kind_cluster_config_path)
  }
}
