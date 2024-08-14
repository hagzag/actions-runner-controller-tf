data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.eks_cluster_name
}

resource "aws_iam_role" "actions_runner_role" {
  name = "actions-runner-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:actions-runner-system:actions-runner-controller"
          }
        }
      }
    ]
  })
}

resource "kubernetes_service_account" "actions_runner_sa" {
  metadata {
    name      = "actions-runner-controller"
    namespace = "actions-runner-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.actions_runner_role.arn
    }
  }
  
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "helm_release" "actions_runner_controller" {
  name       = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  namespace  = "actions-runner-system"

  depends_on = [
    kubernetes_secret.controller_manager_secret
  ]

  values = [
    <<EOF
serviceAccount:
  create: false
  name: ${kubernetes_service_account.actions_runner_sa.metadata[0].name}
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.actions_runner_role.arn}

controllerManager:
  existingSecret: "controller-manager"
EOF
  ]
}

resource "aws_iam_policy" "actions_runner_policy" {
  name   = "actions-runner-policy"
  policy = file("${path.module}/policy.json")
}

resource "aws_iam_role_policy_attachment" "actions_runner_attach_policy" {
  role       = aws_iam_role.actions_runner_role.name
  policy_arn = aws_iam_policy.actions_runner_policy.arn
}


# github-token.tf

resource "kubernetes_secret" "controller_manager_secret" {
  metadata {
    name      = "controller-manager"
    namespace = "actions-runner-system"
  }

  data = {
    github_token = base64encode(var.github_token)
  }
}