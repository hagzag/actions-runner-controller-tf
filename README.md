# actions-runner-controller-tf

## terraform module

```sh
AWS_PROFILE='tikal-infra' TF_VAR_github_token=$GITHUB_TOKEN tfp
```

yields:

```sh
module.github_actions_runner.data.aws_caller_identity.current: Reading...
module.github_actions_runner.data.aws_eks_cluster.eks: Reading...
module.github_actions_runner.data.aws_eks_cluster_auth.eks: Reading...
module.github_actions_runner.data.aws_eks_cluster_auth.eks: Read complete after 0s [id=platform-prod]
module.github_actions_runner.data.aws_caller_identity.current: Read complete after 0s [id=ABCXXXABCYY]
module.github_actions_runner.data.aws_eks_cluster.eks: Read complete after 0s [id=platform-prod]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # module.github_actions_runner.aws_iam_policy.actions_runner_policy will be created
  + resource "aws_iam_policy" "actions_runner_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + id               = (known after apply)
      + name             = "actions-runner-policy"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:ListAllMyBuckets",
                          + "s3:ListBucket",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  # module.github_actions_runner.aws_iam_role.actions_runner_role will be created
  + resource "aws_iam_role" "actions_runner_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRoleWithWebIdentity"
                      + Condition = {
                          + StringEquals = {
                              + "oidc.eks.eu-central-1.amazonaws.com/id/DDDD4EB2FFFF2569BBBBABD08888BBFF:sub" = "system:serviceaccount:actions-runner-system:actions-runner-controller"
                            }
                        }
                      + Effect    = "Allow"
                      + Principal = {
                          + Federated = "arn:aws:iam::ABCXXXABCYY:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/DDDD4EB2FFFF2569BBBBABD08888BBFF"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "actions-runner-controller-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)
    }

  # module.github_actions_runner.aws_iam_role_policy_attachment.actions_runner_attach_policy will be created
  + resource "aws_iam_role_policy_attachment" "actions_runner_attach_policy" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "actions-runner-controller-role"
    }

  # module.github_actions_runner.helm_release.actions_runner_controller will be created
  + resource "helm_release" "actions_runner_controller" {
      + atomic                     = false
      + chart                      = "actions-runner-controller"
      + cleanup_on_fail            = false
      + create_namespace           = false
      + dependency_update          = false
      + disable_crd_hooks          = false
      + disable_openapi_validation = false
      + disable_webhooks           = false
      + force_update               = false
      + id                         = (known after apply)
      + lint                       = false
      + manifest                   = (known after apply)
      + max_history                = 0
      + metadata                   = (known after apply)
      + name                       = "actions-runner-controller"
      + namespace                  = "actions-runner-system"
      + pass_credentials           = false
      + recreate_pods              = false
      + render_subchart_notes      = true
      + replace                    = false
      + repository                 = "https://actions-runner-controller.github.io/actions-runner-controller"
      + reset_values               = false
      + reuse_values               = false
      + skip_crds                  = false
      + status                     = "deployed"
      + timeout                    = 300
      + values                     = (known after apply)
      + verify                     = false
      + version                    = "0.23.7"
      + wait                       = true
      + wait_for_jobs              = false
    }

  # module.github_actions_runner.kubernetes_secret.controller_manager_secret will be created
  + resource "kubernetes_secret" "controller_manager_secret" {
      + data                           = (sensitive value)
      + id                             = (known after apply)
      + type                           = "Opaque"
      + wait_for_service_account_token = true

      + metadata {
          + generation       = (known after apply)
          + name             = "controller-manager"
          + namespace        = "actions-runner-system"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }
    }

  # module.github_actions_runner.kubernetes_service_account.actions_runner_sa will be created
  + resource "kubernetes_service_account" "actions_runner_sa" {
      + automount_service_account_token = true
      + default_secret_name             = (known after apply)
      + id                              = (known after apply)

      + metadata {
          + annotations      = (known after apply)
          + generation       = (known after apply)
          + name             = "actions-runner-controller"
          + namespace        = "actions-runner-system"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }
    }

Plan: 6 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"

```