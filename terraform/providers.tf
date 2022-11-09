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
      version = "~> 4.38.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
  required_version = "1.3.4"
}

provider "aws" {
  # Configuration options
}
provider "null" {
  # Configuration options
}

provider "time" {
  # Configuration options
}
