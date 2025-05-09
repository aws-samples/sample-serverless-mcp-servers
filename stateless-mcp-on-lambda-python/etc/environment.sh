# aws configuration
PROFILE=your-cli-profile
BUCKET=your-cli-bucket
REGION=us-east-1

# mcp dependencies
P_DESCRIPTION="mcp==1.8.0"
LAYER_STACK=mcp-lambda-layer
LAYER_TEMPLATE=iac/layer.yaml
LAYER_OUTPUT=iac/layer_output.yaml
LAYER_PARAMS="ParameterKey=description,ParameterValue=${P_DESCRIPTION}"
O_LAYER_ARN=your-output-layer-arn

# api gateway and lambdastack
P_API_STAGE=dev
P_FN_MEMORY=128
P_FN_TIMEOUT=15
APIGW_STACK=mcp-apigw
APIGW_TEMPLATE=iac/template.yaml
APIGW_OUTPUT=iac/template_output.yaml
APIGW_PARAMS="ParameterKey=apiStage,ParameterValue=${P_API_STAGE} ParameterKey=fnMemory,ParameterValue=${P_FN_MEMORY} ParameterKey=fnTimeout,ParameterValue=${P_FN_TIMEOUT} ParameterKey=dependencies,ParameterValue=${O_LAYER_ARN}"
