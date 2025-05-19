locals {
  r53_zone_name            = "your-zone-name" # optional, not used by default
  ecr_alias                = "your-ecr-alias"

  project_name             = "stateless-mcp-on-ecs"
  region                   = "us-east-1"
  az1                      = "${local.region}a"
  az2                      = "${local.region}b"
  vpc_cidr                 = "11.0.0.0/16"
  subnet1_cidr             = "11.0.1.0/24"
  subnet2_cidr             = "11.0.2.0/24"
  ecs_task_container_name  = "mcp_server"
  ecs_task_container_image = "public.ecr.aws/${local.ecr_alias}/stateless-mcp-on-ecs:latest"
  ecs_task_container_port  = 3000
}
