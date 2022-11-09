module "istio" {
  source       = "sepulworld/istio/helm"
  version      = "0.0.3"
  cluster_name = "ortelius-in-a-box"
}

resource "helm_release" "istio_base" {
  name       = "istio"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  #timeout         = 120
  cleanup_on_fail = true
  force_update    = false
  namespace       = "istio-system"
}

resource "helm_release" "istio_istiod" {
  name       = "istio"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  #timeout         = 120
  cleanup_on_fail = true
  force_update    = false
  namespace       = "istio-system"

  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }
}
