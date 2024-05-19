locals {
  set_cluster_name= "Test_Cluster"
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                   = local.set_cluster_name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    test-cluster-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
    }
  }


  enable_cluster_creator_admin_permissions = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  depends_on = [ null_resource.eks_cleanup ]

}

data "aws_eks_cluster" "default" {
  name = module.eks.cluster_name

  depends_on = [ module.eks ]
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
  depends_on = [ module.eks ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
    command     = "aws"
  }
}

resource "null_resource" "eks_cleanup" {
  provisioner "local-exec" {
    command = "kubectl delete -f websitedeployment.yml"
    when = destroy
  }
}