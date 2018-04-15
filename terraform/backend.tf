terraform {
 backend "gcs" {
   bucket  = "cloudlamp-terraform-admin"
   path    = "/fer-tf/terraform.tfstate"
   project = "cloudlamp-terraform-admin"
 }
}
