#!/bin/bash
set -ux

# 1) CONFIG
# read the configuration file to load variables into this shell script
source config

# 2) Creating firewall manager security policy for Global AWS services (CloudFront)
echo "Checking if the firewall policy CloudFront exists ..."
#For cloudfront
if ! aws cloudformation describe-stack-set --stack-set-name $FMS_CF_POLICY_STACK_SET_NAME | grep 'StackSetName' ; then
        aws cloudformation create-stack-set \
                --stack-set-name $FMS_CF_POLICY_STACK_SET_NAME \
                --template-body file://create-fms-security-policy-cf.yaml \
                --capabilities CAPABILITY_IAM \
                --region 'us-east-1' \
                --permission-model SELF_MANAGED \
                --parameters \
                        ParameterKey=pEnvironment,ParameterValue=$ENVIRONMENT \
                        ParameterKey=pOverrideAction,ParameterValue=$OVERIDEACTION \

        # Added 5 seconds to pause the script to let the stack-set get created
        sleep 5
        
        aws cloudformation create-stack-instances \
                --stack-set-name $FMS_CF_POLICY_STACK_SET_NAME \
                --accounts $FMS_DELEGATED_ADMIN_ACCOUNT_ID \
                --regions 'us-east-1' \
                --operation-preferences MaxConcurrentCount=10

else
        aws cloudformation update-stack-set \
                --stack-set-name $FMS_CF_POLICY_STACK_SET_NAME \
                --template-body file://create-fms-security-policy-cf.yaml \
                --capabilities CAPABILITY_IAM \
                --region 'us-east-1' \
                --permission-model SELF_MANAGED \
                --parameters \
                        ParameterKey=pEnvironment,ParameterValue=$ENVIRONMENT \
                        ParameterKey=pOverrideAction,ParameterValue=$OVERIDEACTION \

fi
# 3) Creating firewall manager security policy for regional services like ALB and APIG
echo "Checking if the firewall policy for regional resources exists ..."
if ! aws cloudformation describe-stack-set --stack-set-name $FMS_REGIONAL_POLICY_STACK_SET_NAME | grep 'StackSetName' ; then
        
        aws cloudformation create-stack-set \
                --stack-set-name $FMS_REGIONAL_POLICY_STACK_SET_NAME \
                --template-body file://create-fms-security-policy-regional.yaml \
                --capabilities CAPABILITY_IAM \
                --region 'us-east-1' \
                --permission-model SELF_MANAGED \
                --parameters \
                        ParameterKey=pEnvironment,ParameterValue=$ENVIRONMENT \
                        ParameterKey=pOverrideAction,ParameterValue=$OVERIDEACTION \

        # Added 5 seconds to pause the script to let the stack-set get created
        sleep 5

        aws cloudformation create-stack-instances \
                --stack-set-name $FMS_REGIONAL_POLICY_STACK_SET_NAME \
                --accounts $FMS_DELEGATED_ADMIN_ACCOUNT_ID \
                --regions 'us-east-1' 'us-east-2' \
                --operation-preferences MaxConcurrentCount=10
else
        aws cloudformation update-stack-set \
                --stack-set-name $FMS_REGIONAL_POLICY_STACK_SET_NAME \
                --template-body file://create-fms-security-policy-regional.yaml \
                --capabilities CAPABILITY_IAM \
                --region 'us-east-1' \
                --permission-model SELF_MANAGED \
                --parameters \
                        ParameterKey=pEnvironment,ParameterValue=$ENVIRONMENT \
                        ParameterKey=pOverrideAction,ParameterValue=$OVERIDEACTION \

fi