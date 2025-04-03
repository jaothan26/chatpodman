module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  cluster_name    = "chatpodman-prod"
  cluster_version = "1.28"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    cpu = {
      instance_types = ["t3.xlarge"]
      min_size       = 1
      max_size       = 3
    }
  }
}
