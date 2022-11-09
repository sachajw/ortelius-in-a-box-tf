module "istio" {
  source                          = "sepulworld/istio/helm"
  version                         = "0.0.3"
  cluster_name                    = "ortelius-in-a-box"
  create_namespace                = true
  cleanup_on_fail                 = true
  force_update                    = true
  helm_repo_url                   = "https://istio-release.storage.googleapis.com/charts"
  istiod_meshConfig_accessLogFile = "/dev/stdout"
  recreate_pods                   = false
}

resource "helm_release" "istio_base" {
  name  = "istio"
  chart = "base"
  #  cleanup_on_fail = true
}

resource "helm_release" "istio_istiod" {
  name  = "istio"
  chart = "istiod"
  #  cleanup_on_fail = true
}
