# aws configuration
PROFILE=your-cli-profile
BUCKET=your-cli-bucket
REGION=us-east-1

# mcp dependencies
P_DESCRIPTION="strands-agents==0.0.1"
LAYER_STACK=samples-strands-agents-lambda-layer
LAYER_TEMPLATE=sam/layer.yaml
LAYER_OUTPUT=sam/layer_output.yaml
LAYER_PARAMS="ParameterKey=description,ParameterValue=${P_DESCRIPTION}"
O_LAYER_ARN=output-layer-arn

# api gateway stack
P_API_STAGE=dev
P_FN_MEMORY=128
P_FN_TIMEOUT=60
APIGW_STACK=samples-strands-agents-apigw
APIGW_TEMPLATE=sam/template.yaml
APIGW_OUTPUT=sam/template_output.yaml
APIGW_PARAMS="ParameterKey=apiStage,ParameterValue=${P_API_STAGE} ParameterKey=fnMemory,ParameterValue=${P_FN_MEMORY} ParameterKey=fnTimeout,ParameterValue=${P_FN_TIMEOUT} ParameterKey=dependencies,ParameterValue=${O_LAYER_ARN}"
O_FN=output-function-name
O_API_ENDPOINT=output-api-endpoint
