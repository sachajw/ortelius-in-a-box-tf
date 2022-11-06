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

resource "null_resource" "aws_ecr" {
  triggers = {
    key = uuid()
  }

    provisioner "local-exec" {
      command = <<EOF
      sleep 30
      kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker quay.io/ortelius/ortelius
      kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker ghcr.io/ortelius/keptn-ortelius-service:0.0.2-dev
      EOF
    }
    depends_on = [kind_cluster.default]
}


provider "kubectl" {
  host                   = kind_cluster.default.endpoint
  cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
  client_certificate     = kind_cluster.default.client_certificate
  client_key             = kind_cluster.default.client_key
}

resource "kubectl_manifest" "spekt8" {
  yaml_body =  <<YAML
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
  debug = true
  kubernetes {
    host                   = kind_cluster.default.endpoint
    cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
    client_certificate     = kind_cluster.default.client_certificate
    client_key             = kind_cluster.default.client_key

  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "5.6.2"
  create_namespace = true
  depends_on = [kind_cluster.default]
}

resource "helm_release" "keptn" {
  name = "keptn"

  repository       = "https://ortelius.github.io/keptn-ortelius-service"
  chart            = "keptn"
  namespace        = "keptn"
  version          = "0.0.1"
  create_namespace = true
  timeout          = "300"
  depends_on = [kind_cluster.default]
}
