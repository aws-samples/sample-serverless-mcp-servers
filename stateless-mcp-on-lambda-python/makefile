include etc/environment.sh

# dependencies
layer: layer.build layer.package layer.deploy layer.get-arn
layer.build:
	sam build -t ${LAYER_TEMPLATE} --parameter-overrides ${LAYER_PARAMS} --build-dir build --manifest src/dependencies/requirements.txt --use-container --region ${REGION} --profile ${PROFILE}
layer.package:
	sam package -t build/template.yaml --region ${REGION} --output-template-file ${LAYER_OUTPUT} --s3-bucket ${BUCKET} --s3-prefix ${LAYER_STACK} --profile ${PROFILE}
layer.deploy:
	sam deploy -t ${LAYER_OUTPUT} --region ${REGION} --stack-name ${LAYER_STACK} --parameter-overrides ${LAYER_PARAMS} --profile ${PROFILE}
layer.get-arn:
	@echo "Getting layer ARN and updating environment.sh..."
	$(eval LAYER_ARN := $(shell aws cloudformation describe-stacks --stack-name ${LAYER_STACK} --region ${REGION} --profile ${PROFILE} --query 'Stacks[0].Outputs[?OutputKey==`outLayer`].OutputValue' --output text))
	@sed -i 's|^O_LAYER_ARN=.*|O_LAYER_ARN=${LAYER_ARN}|' etc/environment.sh
	@echo "Updated O_LAYER_ARN to: ${LAYER_ARN}"

# api gateway
apigw: apigw.package apigw.deploy
apigw.package:
	sam package -t ${APIGW_TEMPLATE} --output-template-file ${APIGW_OUTPUT} --s3-bucket ${BUCKET} --s3-prefix ${APIGW_STACK} --region ${REGION} --profile ${PROFILE}
apigw.deploy:
	sam deploy -t ${APIGW_OUTPUT} --region ${REGION} --stack-name ${APIGW_STACK} --parameter-overrides ${APIGW_PARAMS} --profile ${PROFILE}
apigw.delete:
	sam delete --stack-name ${APIGW_STACK} --region ${REGION} --profile ${PROFILE}

delete:
	sam delete --stack-name ${APIGW_STACK} --region ${REGION} --profile ${PROFILE}
	sam delete --stack-name ${LAYER_STACK} --region ${REGION} --profile ${PROFILE}
