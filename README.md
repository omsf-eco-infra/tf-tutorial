# OMSF Intro to OpenTofu/Terraform

This is a tutorial we've developed to help OMSF developers get started with
OpenTofu/Terraform. The context is that we are developing some simple
cloud-based tools to help our community. Since individual OMSF hosted projects
will need to individually deploy we want to make that easy for them to do.
Infrastructure as code (IaC), such as Terraform, is a great way to do that.

This tutorial isn't creating anything particularly interesting; all we're doing
is creating and destroying a simple S3 bucket. We're focusing on using the AWS
provider because that also involves setting up common AWS configurations.

## Tutorial Outline

1. **[Setting up your AWS account]()**: 
2. **[Setting up the AWS CLI for AWS SSO](aws_cli_setup.md)**: We recommend using
   AWS SSO to authenticate your local environment with AWS. This step will help
   you set up the CLI to use SSO.
3. **[Your first OpenTofu deployment](first_deploy.md)**: In this first real
   OpenTofu tutorial, you'll deploy an S3 bucket from a simple Terraform
   configuration.
4. **[Terraform state](terraform_state.md)**: In this one, we'll learn about
   Terraform state and how to use remote state for collaboration. In practice,
   we'll migrate the local Terraform state from the previous step to a remote
   S3 bucket.
5. **[Terraform modules](deploy_module.md)**: Finally, we'll talk about how to
   deploy an existing Terraform module, such as one that OMSF has created.

## Where to go from here

At this point, you should have everything you need to start deploying
pre-prepared modules with OpenTofu! But there's a lot more to learn about
Terraform. A few next steps you might consider:

* **Referring to resources**: We only created a single bucket, but in practice,
  you're creating a set of related resources. For example, you might create an
  IAM Role that has permissions to write to your bucket. Terraform makes it
  very easy to connect those resources.
* **Data sources**: In addition to creating resources, Terraform can
  interrogate existing resources to get information out of them (for example,
  the most recent hash of a Docker image).

