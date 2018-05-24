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

      container {
        image = "${var.gke_drupal_image}"
        name  = "drupal"

        /*
        resources {
          requests {
            cpu    = "1"
            memory = "512Mi"
          }
        }
        */

        liveness_probe {
          http_get {
            port = 80
            path = "/"
          }

          initial_delay_seconds = 480
          timeout_seconds       = 3
        }
        volume_mount {
          name       = "${kubernetes_persistent_volume.vol_1.metadata.0.name}"
          mount_path = "${var.gke_vol_1_mount_path}"
        }
        volume_mount {
          name       = "${kubernetes_persistent_volume.vol_2.metadata.0.name}"
          mount_path = "${var.gke_vol_2_mount_path}"
        }
        volume_mount {
          name       = "${kubernetes_secret.cloudsql-db-credentials.metadata.0.name}"
          mount_path = "/secrets/${kubernetes_secret.cloudsql-db-credentials.metadata.0.name}"
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
            name = "MARIADB_USER"

            //value = "${var.cloudsql_username}"
            //value = ${file("/secrets/${kubernetes_secret.cloudsql-db-credentials.metadata0.name}/username)} 
            value = "${kubernetes_secret.cloudsql-db-credentials.data.username}"
          },
          {
            name = "MARIADB_PASSWORD"

            //value = "${var.master_password}"
            //value = ${file("/secrets/${kubernetes_secret.cloudsql-db-credentials.metadata0.name}/password)} 
            value = "${kubernetes_secret.cloudsql-db-credentials.data.password}"
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
          "-credential_file=/secrets/${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}/credentials.json",
        ]

        port = [
          {
            container_port = 3306
            name           = "mysql"
          },
        ]

        volume_mount {
          name       = "${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}"
          mount_path = "/secrets/${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}"
          read_only  = true
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

    type = "LoadBalancer"

    // not working:
    load_balancer_ip = "${google_compute_address.frontend.0.address}"

    session_affinity = "ClientIP"

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
  }
}

output "lb_ip" {
  value = "${kubernetes_service.cloud-drupal.load_balancer_ingress.0.ip}"
}
