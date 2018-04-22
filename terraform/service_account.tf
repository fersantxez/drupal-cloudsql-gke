//service account
resource "google_service_account" "cloudsql-sa" {
  account_id   = "${var.cloudsql_service_account_name}"
  display_name = "CloudSQL service account"
}

//PART I: create SA key and add key to k8s secret to be used from k8s svcs

//IAM policy - allow to create svc account keys
data "google_iam_policy" "create-keys-policy" {
  binding {
    role = "${var.create_keys_role}"

    members = [
      "serviceAccount:${google_service_account.cloudsql-sa.email}",
    ]
  }
}

//IAM policy binding - allow SA to create svc account keys
resource "google_service_account_iam_binding" "cloudsql-sa-create-keys" {
  service_account_id = "${google_service_account.cloudsql-sa.name}"

  role = "${var.create_keys_role}"

  members = [
    "serviceAccount:${google_service_account.cloudsql-sa.email}",
  ]
}

//create key for SA
resource "google_service_account_key" "cloudsql-sa-key" {
  service_account_id = "${google_service_account.cloudsql-sa.email}"

  //"${google_service_account.cloudsql_sa.name}@${var.project}.iam.gserviceaccount.com"
  public_key_type = "TYPE_X509_PEM_FILE"
}

//add key to kubernetes secret
resource "kubernetes_secret" "cloudsql-instance-credentials" {
  metadata {
    name = "cloudsql-instance-credentials"
  }

  data {
    credentials.json = "${base64decode(google_service_account_key.cloudsql-sa-key.private_key)}"
  }
}

//PART II: Enable the SA to access CloudSQL and add the DB connection to k8s as secret

//IAM policy - allow to access CloudSQL
data "google_iam_policy" "cloudsql-client-policy" {
  binding {
    role = "${var.cloudsql_client_role}"

    members = [
      "serviceAccount:${google_service_account.cloudsql-sa.email}",
    ]
  }
}

//IAM policy binding - allow SA to access CloudSQL
resource "google_service_account_iam_binding" "cloudsql-sa-cloudsql-client" {
  service_account_id = "${google_service_account.cloudsql-sa.name}"

  role = "${var.cloudsql_client_role}"

  members = [
    "serviceAccount:${google_service_account.cloudsql-sa.email}",
  ]
}

resource "kubernetes_config_map" "dbconfig" {
  "metadata" {
    name = "dbconfig"
  }

  data = {
    dbconnection = "${google_sql_database_instance.master.connection_name}"

    //"${var.project}:${var.region}:${google_sql_database_instance.master.name}"
  }
}
