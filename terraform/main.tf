provider "kind" {}

resource "kind_cluster" "default" {
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

resource "null_resource" "kind_container_image" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker quay.io/ortelius/ortelius
      kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker ghcr.io/ortelius/keptn-ortelius-service:0.0.2-dev
      kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker docker.io/istio/base:1.16-2022-11-02T13-31-52
      kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker elliotxkim/spekt8:latest
      sleep 30
      kubectl patch deployment keptn-keptn-ortelius-service --patch-file keptn-patch-image.yaml -n keptn
      EOF
  }
  depends_on = [kind_cluster.default]
}

provider "kubectl" {
  host                   = kind_cluster.default.endpoint
  cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
  client_certificate     = kind_cluster.default.client_certificate
  client_key             = kind_cluster.default.client_key
  load_config_file       = false
}

resource "kubectl_manifest" "spekt8" {
  yaml_body  = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spekt8
spec:
  selector:
    matchLabels:
      component: spekt8
  replicas: 1
  template:
    metadata:
      labels:
        component: spekt8
    spec:
      containers:
        - name: spekt8
          image: elliotxkim/spekt8
          ports:
            - containerPort: 3000
YAML
  depends_on = [kind_cluster.default]
}
provider "helm" {
  #debug = true
  kubernetes {
    host                   = kind_cluster.default.endpoint
    cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
    client_certificate     = kind_cluster.default.client_certificate
    client_key             = kind_cluster.default.client_key

  }
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  name            = "istio"
  repository      = "https://istio-release.storage.googleapis.com/charts"
  chart           = "base"
  namespace       = "istio-system"
  version         = "istio-1.16.0-beta.2/manifests/charts/base"
  timeout         = 120
  cleanup_on_fail = true
  force_update    = true
  depends_on      = [kind_cluster.default]
}

resource "helm_release" "istio_istiod" {
  name            = "istio"
  repository      = "https://istio-release.storage.googleapis.com/charts"
  chart           = "istiod"
  namespace       = "istio-system"
  version         = "istio-1.16.0-beta.2/manifests/charts/istio-control/istio-discovery"
  timeout         = 120
  cleanup_on_fail = true
  force_update    = true
  depends_on      = [kind_cluster.default]
}

resource "helm_release" "istio_ingress" {
  name            = "istio-ingress"
  chart           = "istio-1.16.0-beta.2/manifests/charts/gateways/istio-ingress"
  timeout         = 120
  cleanup_on_fail = true
  force_update    = true
  namespace       = "istio-system"
}

resource "helm_release" "istio_egress" {
  name            = "istio-egress"
  chart           = "istio-1.16.0-beta.2/manifests/charts/gateways/istio-egress"
  timeout         = 120
  cleanup_on_fail = true
  force_update    = true
  namespace       = "istio-system"
  depends_on      = [kind_cluster.default]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "5.6.2"
  create_namespace = true
  depends_on       = [kind_cluster.default]
}

resource "helm_release" "keptn" {
  name             = "keptn"
  repository       = "https://ortelius.github.io/keptn-ortelius-service"
  chart            = "keptn-ortelius-service"
  namespace        = "keptn"
  version          = "0.0.1"
  create_namespace = true
  timeout          = "300"
  depends_on       = [kind_cluster.default]
}
