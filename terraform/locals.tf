locals {
  name   = "eks-proj"
  domain = "eks.yasinhirsi.com"
  region = "eu-west-2"

  tags = {
    Environment = "dev"
    Project     = "EKS-2048-GAME"
    Owner       = "YS"
    ManagedBy   = "Terraform" //idk if needed
  }
}
