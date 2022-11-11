provider "kind" {}

resource "kind_cluster" "ortelius" {
  name            = var.kind_cluster_name
  node_image      = "kindest/node:v1.25.3"
  kubeconfig_path = pathexpand(var.kind_cluster_config_path)
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
        listen_address = "0.0.0.0"
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
        listen_address = "0.0.0.0"
      }
    }
    node {
      role = "worker"
    }
  }
}

resource "null_resource" "kubectl" {
  depends_on = [kind_cluster.ortelius]
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      kubectl create namespace ortelius
      kubectl create secret generic pgcred --from-literal=DBUserName=admin --from-literal=DBPassword=admin -n ortelius
      sleep 45
      kubectl patch deployment keptn-keptn-ortelius-service --patch-file keptn-patch-image.yaml -n keptn
    EOF
  }
}

resource "time_sleep" "wait_40_seconds" {
  create_duration = "40s"
}

resource "null_resource" "kind_copy_container_images" {
  depends_on = [time_sleep.wait_40_seconds]
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker quay.io/ortelius/ortelius
      kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker ghcr.io/ortelius/keptn-ortelius-service:0.0.2-dev
      kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker docker.io/istio/base:1.16-2022-11-02T13-31-52
    EOF
  }
}

provider "kubectl" {
  host                   = kind_cluster.ortelius.endpoint
  cluster_ca_certificate = kind_cluster.ortelius.cluster_ca_certificate
  client_certificate     = kind_cluster.ortelius.client_certificate
  client_key             = kind_cluster.ortelius.client_key
  load_config_file       = false
}

provider "helm" {
  #debug = true
  kubernetes {
    host                   = kind_cluster.ortelius.endpoint
    cluster_ca_certificate = kind_cluster.ortelius.cluster_ca_certificate
    client_certificate     = kind_cluster.ortelius.client_certificate
    client_key             = kind_cluster.ortelius.client_key
    config_path            = "~/.kube/config"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "5.6.2"
  create_namespace = true
  depends_on       = [kind_cluster.ortelius]
}

resource "helm_release" "ortelius" {
  name             = "ortelius"
  repository       = "https://ortelius.github.io/ortelius-charts/"
  chart            = "ortelius"
  namespace        = "ortelius"
  force_update     = true
  create_namespace = true
  depends_on       = [kind_cluster.ortelius]
  timeout          = 600
}

resource "helm_release" "keptn" {
  name             = "keptn"
  repository       = "https://ortelius.github.io/keptn-ortelius-service"
  chart            = "keptn-ortelius-service"
  namespace        = "keptn"
  version          = "0.0.1"
  create_namespace = true
  depends_on       = [kind_cluster.ortelius]
}

resource "helm_release" "istio_banzaicloud" {
  name             = "banzaicloud"
  repository       = "https://kubernetes-charts.banzaicloud.com"
  chart            = "istio"
  force_update     = true
  create_namespace = true
  depends_on       = [kind_cluster.ortelius]
  timeout          = 600
}

#resource "time_sleep" "wait_10_seconds" {
#  create_duration = "10s"
#}
