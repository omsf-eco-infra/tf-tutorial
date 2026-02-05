# Deploying resources with OpenTofu

In a bit of confusion, I'm going to frequently refer to Terraform, but I never
actually mean Terraform. The infrastructure as code language we'll be using is
actually called HCL (Hashicorp Configuration Language), although we'll
frequently refer to it as "Terraform code" or "Terraform files." The tool we'll
use to read, interpret, and deploy the HCL files will be OpenTofu. OpenTofu is
a community-driven fork of Terraform, which split off over concerns about
changes to Terraform's license. Either Terraform or OpenTofu could be used to
deploy the files we're using, but for OMSF we recommend OpenTofu.

## Installing OpenTofu

To install OpenTofu, follow the [instructions for your
OS](https://opentofu.org/docs/intro/install/). I personally use `brew` on a
Mac. Note that if you want to manage this within a Conda environment,
`opentofu` is also available on `conda-forge`.

## Deploying and destroying a bucket on AWS

Let's do your first Terraform deployment! Make sure you're logged into AWS
(e.g., `aws sso login`) and are using the correct AWS profile.

### Your first Terraform configuration

Switch to the `first_bucket` directory, and you'll find a file called `main.tf`
which contains the following code:

```hcl
# versions.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# variables.tf
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

# main.tf
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}

# outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}
```

You'll note that I mention that these are usually in separate files. This isn't
required, but Terraform projects are often organized this way to keep things
clean and manageable. The names `versions.tf`, `variables.tf`, `main.tf`, and
`outputs.tf` are not required, but they are widely used. Terraform will read
all `.tf` files in the directory, so as long as they are in the same directory,
it doesn't matter how you organize them. For this example, it is easier to
copy/paste a single file, and the configuration isn't very complicated.

The `versions.tf` section defines the versions of providers we need. In this
case, we only need the AWS provider. The `variables.tf` section lists the input
variables that users need to provide. We'll talk more about ways of setting
these variables later. The `main.tf` section is the actual resource
configuration. Finally, the `outputs.tf` section defines outputs that we may
want to get from this later. For more information on syntax of the Terraform
code, see our [HCL syntax overview](hcl_syntax_overview.md).

### Deploying your bucket configuration

Now we can start interacting with the `tofu` command line! The basic process is
`init`, `plan`, and `apply`. You'll need to run `tofu init` every time you
change the modules/providers that you are using (and `tofu` will complain if
you try to run `plan` or `apply` without running `init` first).

It is best practice to separate the `plan` and `apply` steps, although
technically you can just run `tofu apply` to both plan and apply in one step.
However, separating them allows you to review the plan before applying it.

Now let's initialize Terraform in this directory. From within the
`first_deploy` directory, run the following command:

```bash
tofu init
```

This will download the necessary provider plugins.

Next, we'll plan our deployment. Run the following command (it will prompt you
to give the bucket name; keep in mind that the bucket name must be globally
unique, so you'll probably want to add some random letters at the end):

```bash
tofu plan -out tfplan
```

The `-out tfplan` means that we write a file called `tfplan` that describes
the plan. Let's take a look at the output from that:

```
OpenTofu used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

OpenTofu will perform the following actions:

  # aws_s3_bucket.my_bucket will be created
  + resource "aws_s3_bucket" "my_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "this-is-the-bucket-name-abc123"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags_all                    = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket_name = "this-is-the-bucket-name-abc123"

────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    tofu apply "tfplan"
```

We can inspect the plan to see if it looks correct. We expect to create 1
resource (an S3 bucket) and no changes to existing resources. This output looks
good, so let's apply it!

```bash
tofu apply tfplan
```

It should tell you that it worked, and show you the values of any outputs. Now,
let's see what the `tofu` says it is maintaining:

```bash
tofu show
```

```text
   # aws_s3_bucket.my_bucket:
resource "aws_s3_bucket" "my_bucket" {
    arn                         = "arn:aws:s3:::this-is-the-bucket-name-abc123"
    bucket                      = "this-is-the-bucket-name-abc123"
    bucket_domain_name          = "this-is-the-bucket-name-abc123.s3.amazonaws.com"
    bucket_regional_domain_name = "this-is-the-bucket-name-abc123.s3.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "this-is-the-bucket-name-abc123"
    object_lock_enabled         = false
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags_all                    = {}

    grant {
        id          = "29db6760386513e643d7b6156d5639045a4759cd4a2108ba9011c3bea302bf80"
        permissions = [
            "FULL_CONTROL",
        ]
        type        = "CanonicalUser"
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }
}


Outputs:

bucket_name = "this-is-the-bucket-name-abc123"
```

We see the information about the bucket, as well as the output we defined.
The bucket information includes things that the plan said would be "known after apply," as well as several parameters where we used default values.

You can also log into the AWS console and verify that the bucket was created, or check using the `aws` CLI command `aws s3 ls`.

Now, let's destroy everything we created (which was just the bucket):

```bash
tofu destroy
```

Destroying needs us to provide the bucket name again, so be sure you type the
exact same bucket name you used when creating it. In the next section, we'll
show ways to use variables to you don't have to manually enter them.

Destroying will also require confirmation. You must type `yes` to confirm.

You can verify that the bucket was destroyed by looking at the output of `tofu
show` or by logging into the AWS console.

Note that with certain objects will only be destroyed (by default) if they are
empty. S3 buckets are one of those, so if you added something to your bucket
before deleting it, you would get an error saying it could not be destroyed.

### Other ways to set variables

In that first example, `tofu` prompted you for the missing variable names.
However, there are several other ways to set variables in Terraform:

* You can set variables on the command line during the plan step: 
  ```bash
  tofu plan -var "bucket_name=my-bucket-name" -output tfplan
  ```

  This is useful for quick tests or one-off deployments where you need to
  override something.
* You can set environment variables that match the variable names, prefixed
  with `TF_VAR_`:

  ```bash
  export TF_VAR_bucket_name=my-bucket-name
  tofu plan -output tfplan
  ```

  This is particularly useful when doing this in CI/CD, where the contents of
  the variables can be set as secrets.

* You can use a tfvars file. Create a file called `terraform.tfvars` with the
  following content:

  ```hcl
  bucket_name = "my-bucket-name"
  ```

  Then you can run `tofu plan` without needing to specify the variable. This
  will also work on any file that ends in `.auto.tfvars`. When I'm deploying
  from my local machine, I often use a `.auto.tfvars` file to set variables.


Try creating and destroying the bucket again, but this time use one of the
other ways of setting variables!
