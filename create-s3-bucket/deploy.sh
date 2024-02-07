#!/bin/bash
set -ux

source config

# 2) Creating WAF account specific buckets in each account
echo "Creating WAF account specific buckets in each account..."

if ! aws cloudformation describe-stack-set --stack-set-name $WAF_CREATE_LOG_BUCKET | grep 'StackSetName' ; then
        aws cloudformation create-stack-set \
                --stack-set-name $WAF_CREATE_LOG_BUCKET \
                --template-body file://create-s3-log-bucket.yaml \
                --capabilities CAPABILITY_IAM \
                --region 'us-east-1' \
                --permission-model SERVICE_MANAGED \
                --auto-deployment Enabled=true,RetainStacksOnAccountRemoval=false \
                --parameters \
                        ParameterKey=pEnvironment,ParameterValue=$ENVIRONMENT

        sleep 5
        aws cloudformation create-stack-instances --stack-set-name $WAF_CREATE_LOG_BUCKET \
                --deployment-targets OrganizationalUnitIds=$ORG_UNIT \
                --regions 'us-east-1' \
                --operation-preferences MaxConcurrentCount=10

else
        aws cloudformation update-stack-set \
                --stack-set-name $WAF_CREATE_LOG_BUCKET \
                --template-body file://create-s3-log-bucket.yaml \
                --capabilities CAPABILITY_IAM \
                --region 'us-east-1' \
                --permission-model SERVICE_MANAGED \
                --auto-deployment Enabled=true,RetainStacksOnAccountRemoval=false \
                --parameters \
                        ParameterKey=pEnvironment,ParameterValue=$ENVIRONMENT

fi