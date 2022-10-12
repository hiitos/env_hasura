# バージョンの設定
terraform {
  # terraform のバージョン指定
  required_version = "1.2.1"
  required_providers {
    # GCPのバージョン指定
    google = {
      source  = "hashicorp/google"
      version = "3.72.0"
    }
  }
}