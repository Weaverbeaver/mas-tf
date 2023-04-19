terraform {
  required_providers {
    helm       = {}
    kubernetes = {}
    azurerm    = {}
  }
}

provider "kubernetes" {
  config_path = "config"
}

provider "helm" {
  kubernetes {
    config_path = "config"
  }
}

resource "kubernetes_secret" "gf-helm-secrets" {

  metadata {
    name      = "gf-helm-secrets"
    namespace = "grafana4"
  }

  data = {
    GF_DATABASE_TYPE     = var.GF_DATABASE_TYPE
    GF_DATABASE_NAME     = var.GF_DATABASE_NAME
    GF_DATABASE_HOST     = var.GF_DATABASE_HOST
    GF_DATABASE_USER     = var.GF_DATABASE_USER
    GF_DATABASE_PASSWORD = var.GF_DATABASE_PASSWORD
  }
}

resource "helm_release" "mas-api" {
  name       = "mas-api"
  repository = "https://stephent2023.github.io/mas-api-helm/"
  chart      = "mas-api"
  namespace  = "grafana4"

  set {
    name  = "DB_USER"
    value = var.DB_USER
  }

  set {
    name  = "DB_PASS"
    value = var.DB_PASS
  }

  set {
    name  = "DB_NAME"
    value = var.DB_NAME
  }

  set {
    name  = "DB_ENDPOINT"
    value = var.DB_ENDPOINT
  }

  # Does this complete JWT?
  set {
    name  = "oauth_auto_login"
    value = true
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "grafana"
  namespace  = "grafana4"

  set {
    name  = "persistence.enabled"
    value = "false"
  }
  set {
    name  = "grafana.podSecurityContext.enabled"
    value = "false"
  }
  set {
    name  = "grafana.containerSecurityContext.enabled"
    value = "false"
  }
  set {
    name  = "grafana.livenessProbe.enabled"
    value = "false"
  }
  set {
    name  = "grafana.readinessProbe.enabled"
    value = "false"
  }
  set {
    name  = "grafana.extraEnvVarsSecret"
    value = "gf-helm-secrets"
  }
}

#github commit test
