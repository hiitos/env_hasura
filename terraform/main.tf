# 環境変数の設定(localの.env->docker-composeのenvironment->でここに入る)
variable "gcp_project" {}
variable "billing_id" {}
# tfvars
variable root_password {}

#### プロジェクトの作成 ####
resource "google_project" "gcp_project" {
  name                = var.gcp_project
  project_id          = var.gcp_project
  billing_account     = var.billing_id
  auto_create_network = false
}

#### VPC ####
# VPC プライベートIPの設定
resource "google_compute_network" "private_network" {
  name = "private-network"
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# サーバーレス VPC アクセスコネクタ
resource "google_vpc_access_connector" "vpc_connector" {
  name          = "vpc-connector"
  region        = "asia-northeast1"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.private_network.name
}

#### Cloud SQL ####
# cloud sqlのインスタンスを作成する
resource "google_sql_database_instance" "postgres13_go_dutch_app" {
  # インスタンスID
  name = "postgres13-instance-1"
  # データベースのバージョン
  database_version = "POSTGRES_13"
  # リージョン
  region        = "asia-northeast1"
  root_password = var.root_password

  # データベースに使用する設定
  settings {
    #  インスタンスをいつアクティブにするか
    activation_policy = "ALWAYS"
    # 可用性
    availability_type = "ZONAL"

    # 使用するマシンタイプ
    tier = "db-f1-micro"
    # Cloud sqlのメモリ
    disk_type = "PD_SSD"
    disk_size = 10
    # ストレージ

    # プライベートIPを設定
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
    }
  }
  # depends_onを明記しないとエラーになる
  # ここで、
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# データベース作成
resource "google_sql_database" "database" {
  name     = "app_db"
  instance = google_sql_database_instance.postgres13_go_dutch_app.name
}

#### Cloud run ####
resource "google_cloud_run_service" "defalut" {
  # Cloud runの名前
  name = "cloudrun-srv"
  location = "asia-northeast1"
  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
    metadata {
      # メタデータのキーマップ
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.vpc_connector.name
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      }
    }
  }
}