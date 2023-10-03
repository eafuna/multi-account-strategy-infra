# Terraform Strategy

<!-- 
terraform init -backend-config accounts/VDSS/backend.conf -reconfigure
```
This is the caveat since we need to reconfigure the backend each time on different accounts
```
terraform plan -var-file accounts/VDSS/terraform.tfvars

terraform apply -var-file accounts/VDSS/terraform.tfvars -->
## Directory organization
```
.
├── accounts
│   ├── dmz
│   │   ├── main.tf
│   │   └── ....
│   ├── logging
│   │   ├── main.tf
│   │   └── ....
│   ├── vdms
│   │   ├── main.tf
│   │   └── ....
│   ├── vdss
│   │   ├── main.tf
│   │   └── ....
│   └── workload
│       ├── backup-segment
│       │   ├── main.tf
│       │   └── ....
│       ├── dev
│       │   ├── main.tf
│       │   └── ....
│       ├── pre-prod
│       │   ├── main.tf
│       │   └── ....
│       ├── prod
│       │   ├── main.tf
│       │   └── ....
│       └── uat
│           ├── main.tf
│           └── ....
├── modules
│   └── aws_vpc
│       ├── main.tf
│       └── ....
├── makefile
└── README.md
```
