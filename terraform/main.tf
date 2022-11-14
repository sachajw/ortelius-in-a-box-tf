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
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"istio-injection=enabled\"\n"
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

resource "null_resource" "kubectl_ortelius" {
  depends_on = [kind_cluster.ortelius]

  provisioner "local-exec" {
    command = <<EOF
      kubectl create namespace ortelius
      kubectl create secret generic pgcred --from-literal=DBUserName=postgres --from-literal=DBPassword=postgres --from-literal=DBHost=localhost --from-literal=DBPort=5432 --from-literal=DBName=postgres -n ortelius
    EOF
  }
}

resource "time_sleep" "wait_45_seconds" {
  create_duration = "45s"
}

resource "null_resource" "kind_copy_container_images" {
  depends_on = [time_sleep.wait_45_seconds]
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
  debug = true
  kubernetes {
    host                   = kind_cluster.ortelius.endpoint
    cluster_ca_certificate = kind_cluster.ortelius.cluster_ca_certificate
    client_certificate     = kind_cluster.ortelius.client_certificate
    client_key             = kind_cluster.ortelius.client_key
    config_path            = pathexpand(var.kind_cluster_config_path)
  }
}

#resource "helm_release" "terrakube" {
#  name             = "terrakube"
#  chart            = "terrakube"
#  namespace        = "terrakube"
#  create_namespace = true
#  depends_on       = [kind_cluster.ortelius]
#
#  values = [
#    file("terrakube/values.yaml"),
#  ]
#}

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

resource "helm_release" "keptn" {
  name             = "keptn"
  chart            = "keptn-ortelius-service"
  repository       = "https://ortelius.github.io/keptn-ortelius-service"
  namespace        = "keptn"
  create_namespace = true
  depends_on       = [kind_cluster.ortelius]

  values = [
    file("keptn-ortelius-service/values.yaml"),
  ]
}

resource "helm_release" "kube_arangodb" {
  name             = "arangodb"
  chart            = "./arangodb/kube-arangodb"
  namespace        = "arangodb"
  create_namespace = true
  depends_on       = [kind_cluster.ortelius]
  #timeout          = 600

  #  values = [
  #    file("arangodb/kube-arangodb/values.yaml"),
  #  ]
}

#resource "helm_release" "kube_arangodb_ingress_proxy" {
#  name             = "arangodb-ingress-proxy"
#  chart            = "arangodb-ingress-proxy"
#  namespace        = "arangodb"
#  create_namespace = false
#  depends_on       = [helm_release.kube_arangodb]
#  #timeout          = 600
#
#  values = [
#    file("kube-arangodb/chart/arangodb-ingress-proxy/values.yaml"),
#  ]
#}

#resource "helm_release" "ortelius" {
#  name             = "ortelius"
#  chart            = "ortelius"
#  namespace        = "ortelius"
#  create_namespace = false
#  depends_on       = [helm_release.keptn]
#  timeout          = 600
#
#  values = [
#    file("ortelius/values.yaml"),
#  ]
#}

resource "helm_release" "istio_base" {
  name             = "charts"
  chart            = "./istio/base"
  namespace        = "istio-system"
  create_namespace = true
  timeout          = 600
  depends_on       = [kind_cluster.ortelius]

  values = [
    file("istio/base/values.yaml"),
  ]
}

resource "helm_release" "istio_operator_banzaicloud" {
  name             = "banzaicloud"
  chart            = ".istio/istio-operator"
  namespace        = "istio-system"
  create_namespace = false
  timeout          = 600
  depends_on       = [helm_release.istio_base]

  values = [
    file("istio/istio-operator/values.yaml"),
  ]
}

resource "helm_release" "istio_istiod" {
  name             = "istiod"
  chart            = "./istio/istiod"
  namespace        = "istio-system"
  force_update     = true
  create_namespace = false
  timeout          = 600
  depends_on       = [helm_release.istio_base]

  values = [
    file("istio/istiod/values.yaml"),
  ]

  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }
}

resource "helm_release" "istio_gateway" {
  name             = "gateway"
  chart            = "./istio/gateway"
  namespace        = "istio-system"
  create_namespace = false
  depends_on       = [helm_release.istio_istiod]
  #timeout          = 600

  values = [
    file("istio/gateway/values.yaml"),
  ]

}

resource "helm_release" "istio_ingress" {
  name             = "istio-ingressgateway"
  chart            = ".istio/gateway/ingress"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = false
  depends_on       = [helm_release.istio_gateway]
  timeout          = 600

  values = [
    file("istio/gateway/ingress/ingress.yaml"),
  ]
}

resource "helm_release" "istio_egress" {
  name             = "istio-egress"
  chart            = "./istio/gateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = false
  depends_on       = [helm_release.istio_gateway]
  timeout          = 600
}
