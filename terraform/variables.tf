variable "kind_cluster_name" {
  type        = string
  description = "The name of the cluster."
  default     = "ortelius-in-a-box"
}

variable "kind_cluster_config_path" {
  type        = string
  description = "Cluster's kubeconfig location"
  default     = "~/.kube/config"
}

#variable "ingress_nginx_helm_version" {
#  type        = string
#  description = "The Helm version for the nginx ingress controller."
#  default     = "4.3.0"
#}

variable "ingress_nginx_namespace" {
  type        = string
  description = "The nginx ingress namespace"
  default     = "ingress-nginx"
}

variable "metallb_namespace" {
  type        = string
  description = "The MetalLB loadbalancer namespace"
  default     = "metallb"
}
