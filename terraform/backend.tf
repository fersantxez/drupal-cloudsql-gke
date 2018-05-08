terraform {
 backend "gcs" {
   bucket  = "groundcontrol-www-terraform"
   prefix  = "/tf/terraform.tfstate"
   project = "groundcontrol-www"
 }
}
