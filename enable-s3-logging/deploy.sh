#!/bin/bash
set -ux

# 1) CONFIG
# read the configuration file to load variables into this shell script
source config

# 2) 
echo "Checking if the logging stack exist"
if ! aws cloudformation describe-stack-set --stack-set-name $WAF_ENABLE_LOG_STACK_SET | grep 'StackSetName' ; then
        aws cloudformation create-stack-set \
                --stack-set-name $WAF_ENABLE_LOG_STACK_SET \
                --template-body file://s3-logging-on-webacls.yaml \
                --capabilities CAPABILITY_IAM \
                --region 'us-east-1' \
                --permission-model SERVICE_MANAGED \
                --auto-deployment Enabled=true,RetainStacksOnAccountRemoval=false \

        
        aws cloudformation create-stack-instances --stack-set-name $WAF_ENABLE_LOG_STACK_SET \
                --deployment-targets OrganizationalUnitIds=$ORG_UNIT \
                --regions 'us-east-2' 'us-east-1'\
                --operation-preferences MaxConcurrentCount=10

else
        aws cloudformation update-stack-set \
                --stack-set-name $WAF_ENABLE_LOG_STACK_SET \
                --template-body file://s3-logging-on-webacls.yaml \
                --capabilities CAPABILITY_IAM \
                --region 'us-east-1' \
                --permission-model SERVICE_MANAGED \
                --auto-deployment Enabled=true,RetainStacksOnAccountRemoval=false \

        aws cloudformation create-stack-instances --stack-set-name $WAF_ENABLE_LOG_STACK_SET \
                --deployment-targets OrganizationalUnitIds=$ORG_UNIT \
                --regions 'us-east-2' 'us-east-1'\
                --operation-preferences MaxConcurrentCount=10

fi
