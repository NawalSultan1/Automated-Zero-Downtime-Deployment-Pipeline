#!/bin/bash
set -e

if [ -z "$1" ]; then
echo "Error: you must provide a target group environment (i.e. 'blue' or 'green')"
echo "Usage: ./deploy.sh <environments>"
exit 1
fi

TARGET_ENV=$1 # e.g. green/blue

echo " Deploying application to the '$TARGET_ENV' environment "

ANSIBLE_DIR="../ansible"

ansible-playbook -i "$ANSIBLE_DIR/inventory-prod" "$ANSIBLE_DIR/deploy.yml" --limit "$TARGET_ENV"

echo "Switching live traffic to the '$TARGET_ENV' environment"

TERRAFORM_DIR="/mnt/c/Users/Nawal\ Sultan/Desktop/Automated\ Zero-Downtime\ Deployment\ Pipeline/quick-release-pipeline/terraform/modules/environments/prod" 

terraform -chdir="$TERRAFORM_DIR" apply -auto-approve -var="live-environment=$TARGET_ENV"

echo "Success! The '$TARGET_ENV' environment is now live"
