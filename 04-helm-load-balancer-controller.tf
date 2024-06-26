module "aws_load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}


resource "helm_release" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
    type  = "string"
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
    type  = "string"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
  }
}

resource "null_resource" "run_aws_update_kubeconfig" {
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --region ${data.aws_region.default.name} --name ${data.aws_eks_cluster.default.name}"
    interpreter = ["bash", "-c"]
  }

  depends_on = [helm_release.aws_load_balancer_controller]
}

resource "null_resource" "run_kubectl_apply" {
  provisioner "local-exec" {
    command     = "kubectl apply -f websitedeployment.yml"
    interpreter = ["bash", "-c"]
  }

  depends_on = [null_resource.run_aws_update_kubeconfig]
}

