resource "kubernetes_replication_controller" "cloud-drupal" {
  metadata {
    name = "${var.gke_service_name}-repl-ctrlr"
  }

  spec {
    selector {
      app = "${var.gke_app_name}"
    }

    replicas = 3

    template {
      volume {
        name = "${kubernetes_persistent_volume.vol_1.metadata.0.name}"

        persistent_volume_claim {
          claim_name = "${kubernetes_persistent_volume_claim.pvc_1.metadata.0.name}"
        }
      }

      volume {
        name = "${kubernetes_persistent_volume.vol_2.metadata.0.name}"

        persistent_volume_claim {
          claim_name = "${kubernetes_persistent_volume_claim.pvc_2.metadata.0.name}"
        }
      }

      volume {
        name = "${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}"

        secret {
          secret_name = "${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}"
        }
      }

      volume {
        name = "${kubernetes_secret.cloudsql-db-credentials.metadata.0.name}"

        secret {
          secret_name = "${kubernetes_secret.cloudsql-db-credentials.metadata.0.name}"
        }
      }

      //volume {
      //  name = "ssl-certs"


      //  secret {
      //   secret_name = "ssl-certs"
      //  }
      //}

      container {
        image = "${var.gke_drupal_image}"
        name  = "drupal"

        port = [
          {
            container_port = 80
            name           = "http"
          },
          {
            container_port = 443
            name           = "https"
          },
        ]

        liveness_probe {
          http_get {
            port = 80
            path = "/usr/login"
          }

          initial_delay_seconds = 120
        }

        readiness_probe {
          http_get {
            port = 80
            path = "/usr/login"
          }

          initial_delay_seconds = 30
        }

        volume_mount {
          name       = "${kubernetes_persistent_volume.vol_1.metadata.0.name}"
          mount_path = "${var.gke_vol_1_mount_path}"
        }

        volume_mount {
          name       = "${kubernetes_persistent_volume.vol_2.metadata.0.name}"
          mount_path = "${var.gke_vol_2_mount_path}"
        }

        env = [
          {
            name  = "MARIADB_HOST"
            value = "127.0.0.1"
          },
          {
            name  = "MARIADB_PORT_NUMBER"
            value = "3306"
          },
          {
            name  = "MARIADB_USER"
            value = "${var.cloudsql_username}"
          },
          {
            name  = "MARIADB_PASSWORD"
            value = "${var.master_password}"
          },
          {
            name  = "DRUPAL_USERNAME"
            value = "${var.drupal_username}"
          },
          {
            name  = "DRUPAL_PASSWORD"
            value = "${var.drupal_password}"
          },
          {
            name  = "DRUPAL_EMAIL"
            value = "${var.drupal_email}"
          },
        ]

        //{
        //  name  = "GOOGLE_APPLICATION_CREDENTIALS"
        //  value = "/secrets/cloudsql/credentials.json"
        //},
      }
      container {
        image = "${var.gke_cloudsql_image}"
        name  = "cloudsql-proxy"

        //**DEBUG: CloudSQL Instance name detected as: groundcontrol-www:us-east4:groundcontrol-sql-3
        //"-instances=${var.project}:${var.region}:${var.cloudsql_instance}=tcp:3306", 
        command = [
          "/cloud_sql_proxy",
          "--dir=/cloudsql",
          "-instances=${google_sql_database_instance.master.connection_name}=tcp:3306",
          "-credential_file=/secrets/cloudsql/credentials.json",
        ]

        //  "-credential_file=/secrets/cloudsql/credentials.json",
        //]

        port = [
          {
            container_port = 3306
            name           = "mysql"
          },
        ]
        volume_mount {
          name       = "${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}"
          mount_path = "/secrets/cloudsql/"
          read_only  = true
        }
        volume_mount {
          name       = "${kubernetes_secret.cloudsql-db-credentials.metadata.0.name}"
          mount_path = "/secrets/db-creds/"
        }
      }
    }
  }
}

resource "kubernetes_service" "cloud-drupal" {
  metadata {
    name = "${var.gke_service_name}"
  }

  spec {
    selector {
      app = "${var.gke_app_name}"
    }

    session_affinity = "ClientIP"

    port {
      port        = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
