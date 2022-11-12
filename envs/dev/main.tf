locals {
  project_name = "locust-sample"
  env          = "dev"
  region       = "ap-northeast-1"
}

provider "aws" {
  region = local.region
}

terraform {
   backend "s3" {
     bucket = "locust-ecs-testbucket"
     key    = "terraform.tfstate"
     region = "ap-northeast-1"
   }
}
module "ecr" {
  source = "../../modules/ecr"
  project_name = local.project_name
  env = local.env
}

module "ecs" {
  source       = "../../modules/ecs"
  project_name = local.project_name
  env          = local.env
  region          = local.region
  fargate_cpu = 256 // MB
  fargate_memory = 512 // MB
  worker_desired_count = 1
  ecr_repo_url = "${module.ecr.ecr_repository_url}:latest"
}