terraform {
 backend "gcs" {
   bucket  = "cloudlamp-terraform-admin"
   prefix  = "/fer-tf/terraform.tfstate"
   project = "cloudlamp-terraform-admin"
 }
}
