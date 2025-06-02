include etc/environment.sh

# dependencies
layer: layer.build layer.package layer.deploy
layer.build:
	sam build -t ${LAYER_TEMPLATE} --parameter-overrides ${LAYER_PARAMS} --build-dir build --manifest src/dependencies/requirements.txt --use-container
layer.package:
	sam package -t build/template.yaml --region ${REGION} --output-template-file ${LAYER_OUTPUT} --s3-bucket ${BUCKET} --s3-prefix ${LAYER_STACK}
layer.deploy:
	sam deploy -t ${LAYER_OUTPUT} --region ${REGION} --stack-name ${LAYER_STACK} --parameter-overrides ${LAYER_PARAMS} --capabilities CAPABILITY_NAMED_IAM

# api gateway
apigw: apigw.package apigw.deploy
apigw.package:
	sam package -t ${APIGW_TEMPLATE} --output-template-file ${APIGW_OUTPUT} --s3-bucket ${BUCKET} --s3-prefix ${APIGW_STACK}
apigw.deploy:
	sam deploy -t ${APIGW_OUTPUT} --region ${REGION} --stack-name ${APIGW_STACK} --parameter-overrides ${APIGW_PARAMS} --capabilities CAPABILITY_NAMED_IAM
apigw.delete:
	sam delete --stack-name ${APIGW_STACK}
