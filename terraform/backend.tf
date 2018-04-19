terraform {
 backend "gcs" {
   bucket  = "groundcontrol-terraform"
   prefix  = "/tf/terraform.tfstate"
   project = "groundcontrol-www"
 }
}
