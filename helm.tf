resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  create_namespace  = true
  chart      = "./prometheus"

  values = [
    "${file("./prometheus-values.yaml")}"
  ]
  depends_on = [
     helm_release.nginx
  ]
}

resource "helm_release" "nginx" {
  name       = "ingress-nginx"
  namespace  = "ingress"
  create_namespace  = true
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  values = [
    "${file("./ingress-nginx-values.yaml")}"
  ]

}
