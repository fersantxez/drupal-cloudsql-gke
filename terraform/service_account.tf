//service account
resource "google_service_account" "cloudsql-sa" {
  account_id   = "${var.cloudsql_service_account_name}"
  display_name = "Terraform service account"
}

//iam policy binding
data "google_iam_policy" "cloudsql-proxy" {
  binding {
    role = "${var.cloudsql_service_account_role}"

    members = [
      "serviceAccount:${var.cloudsql_service_account_name}@${var.project}.iam.gserviceaccount.com",
    ]
  }
}

//key
resource "google_service_account_key" "cloudsql-sa-key" {
  service_account_id = "${var.cloudsql_service_account_name}@${var.project}.iam.gserviceaccount.com"
  public_key_type    = "TYPE_X509_PEM_FILE"
}

//add to kubernetes secret
resource "kubernetes_secret" "cloudsql-instance-credentials" {
  metadata {
    name = "cloudsql-instance-credentials"
  }

  data {
    credentials.json = "${base64decode(google_service_account_key.cloudsql-sa-key.private_key)}"
  }
}

resource "kubernetes_config_map" "dbconfig" {
  "metadata" {
    name = "dbconfig"
  }

  data = {
    dbconnection = "${var.project}:${var.region}:${google_sql_database_instance.master.name}"
  }
}
