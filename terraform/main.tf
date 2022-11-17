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
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"kubernetes.io/os=linux\"\n"
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

provider "kubectl" {
  host                   = kind_cluster.ortelius.endpoint
  cluster_ca_certificate = kind_cluster.ortelius.cluster_ca_certificate
  client_certificate     = kind_cluster.ortelius.client_certificate
  client_key             = kind_cluster.ortelius.client_key
  load_config_file       = false
}

provider "helm" {
  debug = true
  kubernetes {
    host                   = kind_cluster.ortelius.endpoint
    cluster_ca_certificate = kind_cluster.ortelius.cluster_ca_certificate
    client_certificate     = kind_cluster.ortelius.client_certificate
    client_key             = kind_cluster.ortelius.client_key
    config_path            = pathexpand(var.kind_cluster_config_path)
  }
}

# argocd
resource "helm_release" "argocd" {
  name             = "argocd"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  depends_on       = [kind_cluster.ortelius]

  values = [
    file("argo-cd/values.yaml"),
  ]
}

# keptn-ortelius-service
resource "helm_release" "keptn" {
  name             = "keptn"
  chart            = "keptn-ortelius-service"
  repository       = "https://ortelius.github.io/keptn-ortelius-service"
  namespace        = "keptn"
  create_namespace = true
  depends_on       = [kind_cluster.ortelius]

  values = [file("keptn-ortelius-service/values.yaml")]
}

# arangodb
resource "helm_release" "kube_arangodb" {
  name             = "arangodb"
  chart            = "./arangodb/kube-arangodb"
  namespace        = "arangodb"
  create_namespace = true
  depends_on       = [kind_cluster.ortelius]

  values = [
    file("arangodb/kube-arangodb/values.yaml"),
  ]
}
# ortelius
resource "helm_release" "ortelius" {
  name             = "ortelius"
  chart            = "ortelius"
  repository       = "https://ortelius.github.io/ortelius-charts/"
  namespace        = "ortelius"
  create_namespace = true
  depends_on       = [kind_cluster.ortelius]
  #depends_on       = [null_resource.kind_copy_container_images]

  #values = [file("ortelius/values.yaml")]
}

# nginx ingress
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_helm_version

  namespace        = var.ingress_nginx_namespace
  create_namespace = true

  values = [file("nginx-ingress-values.yaml")]

  depends_on = [kind_cluster.ortelius]
}

resource "null_resource" "wait_for_ingress_nginx" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"
      kubectl wait --namespace ${helm_release.ingress_nginx.namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=180s
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}
