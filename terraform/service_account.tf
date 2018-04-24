//service account
resource "google_service_account" "cloudsql-sa" {
  account_id   = "${var.cloudsql_service_account_name}"
  display_name = "CloudSQL service account"
}

//IAM policy - allow to create keys
data "google_iam_policy" "create-keys" {
  binding {
    role = "${var.create_keys_role}"

    members = [
      "serviceAccount:${google_service_account.cloudsql-sa.email}",
    ]
  }
}

//IAM project policy - apply policy to project
resource "google_project_iam_policy" "create-keys-on-project" {
  project     = "${var.project}"
  policy_data = "${data.google_iam_policy.create-keys.policy_data}"
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
    //credentials.json = "${base64decode(google_service_account_key.cloudsql-sa-key.private_key)}"
    //FIXME: find the file where the secret is stored as code , not pre-set variable
    //credentials.json = "${file("${var.cloudsql_db_creds_path}")}"
    credentials.json = "${base64decode(google_service_account_key.cloudsql-sa-key.private_key)}"
  }
}

//IAM policy - allow to connect to cloudSQL
data "google_iam_policy" "cloudsql-client" {
  binding {
    role = "${var.cloudsql_client_role}"

    members = [
      "serviceAccount:${google_service_account.cloudsql-sa.email}",
    ]
  }
}

//IAM  project policy - apply policy to project
resource "google_project_iam_policy" "cloudsql-client-on-project" {
  project     = "${var.project}"
  policy_data = "${data.google_iam_policy.cloudsql-client.policy_data}"
}

//service account to cloudsql secret

