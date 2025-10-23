resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  namespace        = "ingress-nginx"
  create_namespace = true

  values = [file("${path.module}/../helm-values/nginx-ingress.yaml")]
}



resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  namespace        = "cert-manager"
  create_namespace = true

  values = [file("${path.module}/../helm-values/cert-manager.yaml")]


  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cert_manager_irsa_role.iam_role_arn
  }

  depends_on = [helm_release.nginx_ingress]
}



resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"

  namespace        = "external-dns"
  create_namespace = true

  values = [file("${path.module}/../helm-values/external-dns.yaml")]

  # Dynamic values from Terraform
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_dns_irsa_role.iam_role_arn
  }

  set {
    name  = "domainFilters[0]"
    value = local.domain
  }

  depends_on = [helm_release.nginx_ingress]
}



resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace        = "argocd"
  create_namespace = true

  values = [file("${path.module}/../helm-values/argocd.yaml")]

  depends_on = [
    helm_release.nginx_ingress,
    helm_release.cert_manager,
    helm_release.external_dns
  ]
}



resource "helm_release" "kube_prom_stack" {
  name       = "monitoring-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  create_namespace = true
  namespace        = "monitoring"

  values = [
    file("${path.module}/../helm-values/monitoring.yaml")
  ]

  depends_on = [helm_release.nginx_ingress, helm_release.cert_manager, helm_release.external_dns]
}

