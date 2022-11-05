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
    kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker 239907433624.dkr.ecr.eu-central-1.amazonaws.com/argocd:2.0.5.803-165841
    kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker 239907433624.dkr.ecr.eu-central-1.amazonaws.com/redis:6.2.4-alpine
    kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker 239907433624.dkr.ecr.eu-central-1.amazonaws.com/dex:v2.27.0
    EOF
  }
  depends_on = [kind_cluster.default]
}

resource "helm_release" "argocd" {
  chart            = "../helm"
  namespace        = "argocd"
  name             = "argocd"
  create_namespace = true
  depends_on       = [helm_release.ingress_nginx]
  timeout          = "600"

  values = [
    file("../helm/values-${local.environment}.yaml"),
    file("configuration/${local.environment}/capabilities.yaml"),
  ]
}

resource "helm_release" "argocdappsofapps" {
  namespace  = "argocd"
  name       = "argocdappsofapps"
  chart      = "../helm-appsofapps"
  depends_on = [helm_release.argocd]

  values = [
    <<EOS
capabilities:%{if length(local.capabilities) == 0} []%{endif}
%{for capability in local.capabilities}- ${capability.name}
%{endfor}
regtestCapabilities:%{if length(local.regtest_capability_names) == 0} []%{endif}
%{for capname in local.regtest_capability_names}- ${capname}
%{endfor}
clusters:
%{for cluster in local.config.clusters}- ${cluster}
%{endfor}
EOS
  ]
}