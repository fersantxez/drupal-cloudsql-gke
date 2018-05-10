terraform {
 backend "gcs" {
   bucket  = "fersanchez-lamptest-terraform"
   prefix  = "/tf/terraform.tfstate"
   project = "fersanchez-lamptest"
 }
}
