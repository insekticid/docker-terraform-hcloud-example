init:
	terraform init \
		-reconfigure

plan: 
	terraform plan -refresh=true \
		-out "terraform.tfplan"

apply:
	terraform apply terraform.tfplan

destroy:
	terraform destroy

refresh:
	terraform refresh
