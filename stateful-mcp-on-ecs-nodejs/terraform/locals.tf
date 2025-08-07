locals {
  project_name             = "stateful-mcp-on-ecs"
  region                   = "us-east-1"
  az1                      = "${local.region}a"
  az2                      = "${local.region}b"
  vpc_cidr                 = "10.0.0.0/16"
  subnet1_cidr             = "10.0.1.0/24"
  subnet2_cidr             = "10.0.2.0/24"
  ecs_task_container_name  = "mcp_server"
  ecs_task_container_image = "public.ecr.aws/your-ecr-alias/stateful-mcp-on-ecs:latest"
  ecs_task_container_port  = 3000
  # r53_zone_name            = "your-zone-name"
}
