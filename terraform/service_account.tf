//service account
resource "google_service_account" "cloudsql-sa" {
  account_id   = "${var.cloudsql_service_account_name}"
  display_name = "CloudSQL service account"
}

//IAM policy - allow to create svc account keys and access cloudsql as client
//data "google_iam_policy" "create-keys-policy" {
//  binding {
//   role = "${var.create_keys_role}"//

//    members = [
//     "serviceAccount:${google_service_account.cloudsql-sa.email}",
//   ]
// }
//}

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

//policy - access cloudsql
//data "google_iam_policy" "sql-client-policy" {
// binding {
//  role = "${var.cloudsql_client_role}"

//    members = [
//    "serviceAccount:${google_service_account.cloudsql-sa.email}"//,
//    ]
//  }
//}

//policy binding - associate  the access cloudSQL permission with SA
resource "google_service_account_iam_binding" "cloudsql-sa-cloudsql-client" {
  service_account_id = "${google_service_account.cloudsql-sa.name}"

  role = "${var.cloudsql_client_role}"

  members = [
    "serviceAccount:${google_service_account.cloudsql-sa.email}",
  ]
}

//service account to cloudsql secret
//add key to kubernetes secret
resource "kubernetes_secret" "cloudsql-instance-credentials" {
  metadata {
    name = "cloudsql-instance-credentials"

    //annotations {
    //  "kubernetes.io/service_account_name" = "${google_service_account.cloudsql-sa.account_id}"
    //}
  }

  data {
    //credentials.json = "${base64decode(google_service_account_key.cloudsql-sa-key.private_key)}"
    //FIXME: find the file where the secret is stored as code , not pre-set variable
    credentials.json = "${file("${var.cloudsql_db_creds_path}")}"
  }

  //type = "kubernetes.io/service-account-token"
}
