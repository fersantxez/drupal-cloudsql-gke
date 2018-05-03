terraform {
 backend "gcs" {
   bucket  = "bbby-host-terraform"
   prefix  = "/tf/terraform.tfstate"
   project = "bbby-host"
 }
}
