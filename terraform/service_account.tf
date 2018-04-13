//$ terraform import google_service_account.my_sa projects/my-project/serviceAccounts/my-sa@my-project.iam.gserviceaccount.com

//service account
resource "google_service_account" "${var.service_account_name}" {
  account_id   = "${var.service_account_name}"
  display_name = "${var.service_account_description}"
}

//iam policy binding
data "google_iam_policy" "cloudsql-proxy" {
  binding {
    role = "${var.service_account_role}"

    members = [
      "serviceAccount:${var.service_account_name}@${var.project_name}.iam.gserviceaccount.com",
    ]
  }
}

//key
resource "google_service_account_key" "${var.service_account_name}" {
  service_account_id = "${var.service_account_name}"
  public_key_type    = "TYPE_X509_PEM_FILE"
}

//add to kubernetes secret
resource "kubernetes_secret" "cloudsql-instance-credentials" {
  metadata {
    name = "cloudsql-instance-credentials"
  }

  data {
    credentials.json = "${base64decode(google_service_account_key.${var.service_account_name}.private_key)}"
  }
}

//output
output "policy_data" {
  value = "${google_compute_instance.nfs_server.policy_data}"
}
