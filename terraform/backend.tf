terraform {
 backend "gcs" {
   bucket  = "cloudlamp-terraform-admin"
   path    = "/terraform.tfstate"
   project = "cloudlamp-terraform-admin"
 }
}
