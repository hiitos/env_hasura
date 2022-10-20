# GCP 使うよ〜〜
provider "google" {
  project = var.gcp_project
  region  = "asia-northeast1"
  zone    = "asia-northeast-b"
}