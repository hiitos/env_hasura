# 有効にするAPI
locals {
  services = toset([
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "run.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
  ])
}

resource "google_project_service" "service" {
  for_each = local.services
  project  = var.gcp_project
  service  = each.value
}