//sql instance
resource "google_sql_database_instance" "master" {
  name             = "${var.cloudsql_instance}"
  database_version = "${var.cloudsql_db_version}"
  region           = "${var.region}"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "${var.cloudsql_tier}"
  }
}

//output
output "self_link_sql_instance" {
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
  name     = "${var.cloudsql_username}"
  instance = "${google_sql_database_instance.master.name}"

  //host     = "me.com"
  password = "${var.master_password}"
}

//add to kubernetes secret
resource "kubernetes_secret" "cloudsql-db-credentials" {
  metadata {
    name = "cloudsql-db-credentials"
  }

  data {
    username = "${var.cloudsql_username}"
    password = "${var.master_password}"
  }
}
