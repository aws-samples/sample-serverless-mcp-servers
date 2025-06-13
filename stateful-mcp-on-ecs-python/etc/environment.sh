# aws configuration
PROFILE=your-cli-profile
BUCKET=your-cli-bucket
REGION=us-east-1
ACCOUNTID=your-12-digit-account-id

# infrastructure stack
P_VPC_ID=your-vpc-id
P_HOSTEDZONE_ID=your-hosted-zone-id
P_DOMAINNAME=your-fully-qualified-domain-name
P_CLIENT_INGRESS_CIDR=your-client-ingress-cidr
P_SUBNETIDS_PUBLIC=your-comma-separated-list-of-public-subnet-ids
P_SUBNETIDS_PRIVATE=your-comma-separated-list-of-private-subnet-ids
INFRASTRUCTURE_STACK=example-mcp-ecs-infrastructure
INFRASTRUCTURE_TEMPLATE=sam/infrastructure.yaml
INFRASTRUCTURE_OUTPUT=sam/infrastructure_output.yaml
INFRASTRUCTURE_PARAMS="ParameterKey=vpcId,ParameterValue=${P_VPC_ID} ParameterKey=hostedZoneId,ParameterValue=${P_HOSTEDZONE_ID} ParameterKey=domainName,ParameterValue=${P_DOMAINNAME} ParameterKey=clientIngressCidr,ParameterValue=${P_CLIENT_INGRESS_CIDR} ParameterKey=subnetIds,ParameterValue=${P_SUBNETIDS_PUBLIC}"
O_CERT_ARN=output-certificate-arn
O_ALB_ARN=output-alb-arn
O_ALB_TGROUP=output-alb-target-group-arn
O_SGROUP_ALB=output-alb-security-group-id
O_SGROUP_TASK=output-task-security-group-id
O_ECR_REPO=output-ecr-repository-name

# container setup
C_REPO_BASE=${ACCOUNTID}.dkr.ecr.${REGION}.amazonaws.com
C_REPO_IMAGE=${O_ECR_REPO}
C_VERSION=1
C_TAG=${C_REPO_IMAGE}:${C_VERSION}
C_REPO_URI=${C_REPO_BASE}/${C_REPO_IMAGE}:${C_VERSION}

# ecs stack
P_DESIRED_COUNT=2
P_LOG_GROUP=/aws/ecs/example-mcp
P_EXAMPLE_ENVVAR=your-example-environment-variable
ECS_STACK=example-mcp-ecs-application
ECS_TEMPLATE=sam/ecs.yaml
ECS_OUTPUT=sam/ecs_output.yaml
ECS_PARAMS="ParameterKey=desiredCount,ParameterValue=${P_DESIRED_COUNT} ParameterKey=albArn,ParameterValue=${O_ALB_ARN} ParameterKey=targetGroupArn,ParameterValue=${O_ALB_TGROUP} ParameterKey=taskSGroup,ParameterValue=${O_SGROUP_TASK} ParameterKey=subnetIds,ParameterValue=${P_SUBNETIDS_PRIVATE} ParameterKey=imageUri,ParameterValue=${C_REPO_URI} ParameterKey=logGroup,ParameterValue=${P_LOG_GROUP} ParameterKey=exampleEnvVar,ParameterValue=${P_EXAMPLE_ENVVAR}"

