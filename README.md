## Bitcoin Core version 0.21.0

- Docker Image building withing GitHub Action
- Sysdig vulnerability scanner
- Pushing image to Github Container registry

## Terraform module for ECS Task provisioning
path: `/tf-ecs-fargate`

Put your automation access/secret keys to `tf-ecs-fargate/provider.tf`, initialize and `apply`  

## Terraform module for IAM provisioning
path: `/tf-iam`

Put your automation access/secret keys to `tf-iam/provider.tf`, initialize and `apply`. If you want to set some custom prefix, set `env_prefix` variable, otherwise default `dev01` value will be applied
