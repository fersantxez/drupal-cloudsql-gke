//sql instance
resource "google_sql_database_instance" "master" {
  name             = "${var.cloudsql_instance}"
  database_version = "${var.cloudsql_db_version}"
  region           = "${var.region}"

  settings {
    tier = "${var.cloudsql_tier}"

    //ip_configuration  {
    //  authorized_networks = [
    //    {
    //      name = "${google_compute_network.mynetwork.name}"
    //      value = "${var.subnetcidr}"
    //    }
    //  ]
    //}
  }
}

//output
output "self_link_sql_instance" {
  value = "${google_sql_database_instance.master.self_link}"
}

output "connection_name" {
  value = "${google_sql_database_instance.master.connection_name}"
}

//sql proxy user account
resource "google_sql_user" "cloudsql-user" {
  name     = "${var.cloudsql_username}"
  instance = "${google_sql_database_instance.master.name}"

  //host     = "me.com"
  password = "${var.master_password}"
}

output "sql_user" {
  value = "${google_sql_user.cloudsql-user.name}"
}

//add to kubernetes secret - currently unused but backup/reference for future
resource "kubernetes_secret" "cloudsql-db-credentials" {
  metadata {
    name = "cloudsql-db-credentials"
  }

  data {
    username = "${var.cloudsql_username}"
    password = "${var.master_password}"
  }
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
