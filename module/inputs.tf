variable "eks_cluster_name" {
  description = "The name of the existing EKS cluster"
  type        = string
}

variable "github_token" {
  description = "GitHub Personal Access Token for the actions-runner-controller"
  type        = string
  sensitive   = true
}