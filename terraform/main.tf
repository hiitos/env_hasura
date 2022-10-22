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
# VPC作成
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "vpc_private_network" {
  name = "vpc-private-network"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  mtu                     = 1460
}
# プライベートIPの範囲割りあての設定 グローバルアドレスリソースを指定
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_private_network.id
}
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# # サーバーレス VPC アクセスコネクタ
resource "google_vpc_access_connector" "vpc_connector" {
  name          = "vpc-connector"
  region        = "asia-northeast1"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc_private_network.name
}

#### Cloud SQL ####
# cloud sqlのインスタンスを作成する
resource "google_sql_database_instance" "postgres13_harat_tok_line" {
  # region　と settinsのtierは必須
  # インスタンスID
  name = "postgres13-instance-1"
  # データベースのバージョン
  database_version = "POSTGRES_13"
  # リージョン
  region        = "asia-northeast1"
  root_password = var.root_password

  # depends_onを明記しないとエラーになる
  depends_on = [google_service_networking_connection.private_vpc_connection]

  # データベースに使用する設定
  settings {
    #  インスタンスをいつアクティブにするか
    # activation_policy = "ALWAYS"
    # 可用性
    availability_type = "ZONAL"

    # 使用するマシンタイプ
    tier = "db-f1-micro"
    # Cloud sqlのメモリ # ストレージ
    disk_type = "PD_HDD"
    disk_size = 10

    # プライベートIPを設定
    ip_configuration {
      # インスタンスにIPアドレスを割り当てる必要がある場合はtrue。
      # IPv4アドレスは、第2世代インスタンスでは無効にできない
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_private_network.id
      # require_ssl = true
    }
    backup_configuration {
      enabled = false
    }
  }
  # テスト用なので削除できるように
  deletion_protection = "false"
}

# データベース作成
resource "google_sql_database" "database" {
  name     = "app_db"
  instance = google_sql_database_instance.postgres13_harat_tok_line.name
}

# ユーザーの作成
resource "google_sql_user" "users" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres13_harat_tok_line.name
  password = "postgres"
}

#### Cloud run ####
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service
resource "google_cloud_run_service" "defalut" {
  # Cloud runの名前
  name = "cloudrun-srv"
  location = "asia-northeast1"
  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        env {
          name  = "DB_NAME"
          value = google_sql_database.database.name
        }
        env {
          name  = "DB_USER"
          value = google_sql_user.users.name
        }
        env {
          name  = "DB_PASS"
          value = google_sql_user.users.password
        }
        env {
          name  = "INSTANCE_CONNECTION_NAME"
          value = google_sql_database_instance.postgres13_harat_tok_line.connection_name
        }
        env {
          name  = "DB_PORT"
          value = "5432"
        }
        env {
          name  = "INSTANCE_HOST"
          value = google_sql_database_instance.postgres13_harat_tok_line.private_ip_address
        }
        env {
          name  = "PRIVATE_IP"
          value = "TRUE"
        }
        # env {
        #   name  = "DB_IAM_USER"
        #   value = "${google_service_account.github_actions.name}@${var.project}.iam"
        # }
      }
    }
    metadata {
      # メタデータのキーマップ
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "1000"
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.postgres13_harat_tok_line.connection_name
        "run.googleapis.com/client-name"        = "terraform"
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.vpc_connector.name
        "run.googleapis.com/vpc-access-egress" = "all-traffic"
        # "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.defalut.location
  project     = google_cloud_run_service.defalut.project
  service     = google_cloud_run_service.defalut.name

  policy_data = data.google_iam_policy.noauth.policy_data
}