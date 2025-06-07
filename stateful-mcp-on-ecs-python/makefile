include etc/environment.sh

# infrastructure for ecs application
infrastructure: infrastructure.package infrastructure.deploy
infrastructure.package:
	sam package --profile ${PROFILE} -t ${INFRASTRUCTURE_TEMPLATE} --output-template-file ${INFRASTRUCTURE_OUTPUT} --s3-bucket ${BUCKET} --s3-prefix ${INFRASTRUCTURE_STACK}
infrastructure.deploy:
	sam deploy --profile ${PROFILE} -t ${INFRASTRUCTURE_OUTPUT} --stack-name ${INFRASTRUCTURE_STACK} --parameter-overrides ${INFRASTRUCTURE_PARAMS} --capabilities CAPABILITY_NAMED_IAM

# containerize spring application
podman: podman.build podman.login podman.tag podman.push
podman.build:
	podman build --platform linux/amd64 -f dockerfile -t ${C_TAG} .
podman.login:
	aws ecr --profile ${PROFILE} get-login-password --region ${REGION} | podman login --username AWS --password-stdin ${C_REPO_BASE}
podman.tag:
	podman tag ${C_TAG} ${C_REPO_URI}
podman.push:
	podman push ${C_REPO_URI}
podman.run:
	# -p hostport:containerport
	podman run -p 8000:8000 --env-file etc/environment.docker ${C_TAG}

# ecs cluster and service
ecs: ecs.package ecs.deploy
ecs.package:
	sam package --profile ${PROFILE} -t ${ECS_TEMPLATE} --output-template-file ${ECS_OUTPUT} --s3-bucket ${BUCKET} --s3-prefix ${ECS_STACK}
ecs.deploy:
	sam deploy --profile ${PROFILE} -t ${ECS_OUTPUT} --stack-name ${ECS_STACK} --parameter-overrides ${ECS_PARAMS} --capabilities CAPABILITY_NAMED_IAM

