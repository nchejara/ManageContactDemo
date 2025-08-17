#!/bin/bash

# Variables
REGION="us-east-1"
REPO_NAME="manage_contact_app"

# Create ECR repository
aws ecr create-repository --repository-name "$REPO_NAME" --region "$REGION" --image-scanning-configuration scanOnPush=true --tags Key=Environment,Value=dev Key=Project,Value=GemGem

if [ $? -eq 0 ]; then
    echo "ECR repository '$REPO_NAME' created successfully in region '$REGION'."
else
    echo "Unable to create ECR repository."
    exit 1
fi