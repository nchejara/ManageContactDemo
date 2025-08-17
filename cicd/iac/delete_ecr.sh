#!/bin/bash

# Variables
REGION="us-east-1"       # Change to your AWS region
REPO_NAME="manage_contact_app"  # Change to your ECR repository name

# Delete ECR repository (force delete all images)
aws ecr delete-repository --repository-name "$REPO_NAME" --region "$REGION" --force

if [ $? -eq 0 ]; then
    echo "ECR repository '$REPO_NAME' deleted successfully from region '$REGION'."
else
    echo "Unable to delete ECR repository."
    exit 1
fi