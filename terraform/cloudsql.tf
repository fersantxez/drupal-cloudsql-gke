//sql instance
resource "google_sql_database_instance" "master" {
  name             = "${var.cloudsql_instance}"
  database_version = "${cloudsql_db_version}"
  region           = "${var.region}"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "${var.cloudsql_tier}"
  }
}

//output
output "self_link" {
  value = "${google_sql_database_instance.master.self_link}"
}

//Creates a new Google SQL Database on a Google SQL Database Instance
//resource "google_sql_database" "users" {
//  name      = "users-db"
//  instance  = "${google_sql_database_instance.master.name}"
//  charset   = "latin1"
//  collation = "latin1_swedish_ci"
// }

//sql proxy user account
resource "google_sql_user" "users" {
  name     = "${cloudsql_username}"
  instance = "${google_sql_database_instance.master.name}"

  //host     = "me.com"
  password = "${var.cloudsql_password}"
}

//add to kubernetes secret
resource "kubernetes_secret" "cloudsql-db-credentials" {
  metadata {
    name = "cloudsql-db-credentials"
  }

  data {
    username = "${var.cloudsql_username}"
    password = "${var.cloudsql_password}"
  }
}
