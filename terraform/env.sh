export TF_VAR_name="test-fer"
export TF_VAR_org_id=433637338589
export TF_VAR_billing_account=00183D-07EE2D-3060A0
export TF_ADMIN=cloudlamp-terraform-admin
export TF_CREDS=~/.ssh/terraform-admin.json
export TF_PROJECT=cloudlamp-org
export TF_VAR_project_name=$TF_PROJECT
export TF_VAR_region=us-east4
export TF_VAR_zone=us-east4-c

export TF_VAR_num_instances=3                   #to use in instance group
export TF_VAR_network="default"
export TF_VAR_tag="web"                        #used to group instances and open firewall to them

export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_PROJECT}


