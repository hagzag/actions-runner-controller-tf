provider "aws" {
  region = "eu-central-1"
}

module "github_actions_runner" {
  source = "./module"
  eks_cluster_name = "platform-prod"
  github_token = var.github_token
}

variable "github_token" {
  description = "GitHub Personal Access Token for the actions-runner-controller"
  type        = string
  sensitive   = true
}
