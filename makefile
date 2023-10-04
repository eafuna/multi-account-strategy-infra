#!/usr/bin/account bash

all: info

.SILENT:

.PHONY: info
info:
	echo "USES: \nmake tf-init on=<account> \nmake tf-plan on=<account>" 

.PHONY: clean
clean:
	cd accounts/${on}/ && \
	rm -rf .terraform

.PHONY: tf-init
tf-init:
	cd accounts/${on}/ && \
	terraform init
	
.PHONY: tf-plan
tf-plan:
	cd accounts/${on}/ && \
	echo "\nValidating terraform files.." && \
	terraform fmt --recursive && \
	terraform validate && \
	echo "\nExecuting terraform plan.."  && \
	terraform plan -out=.terraform.plan.${on} && \
	echo "\nGathering gist of changes.."  && \
	terraform show -no-color -json .terraform.plan.${on} | \
		jq -r '.resource_changes[] | {actions: "\(.change.actions | join(","))", name: "\(.change.after.tags.Name)", resource: "\(.address)", after_cidr:"\(.change.after.cidr_block)"}'

