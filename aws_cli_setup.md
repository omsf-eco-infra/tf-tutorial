
## Set up the AWS CLI

### Install the AWS CLI

If you haven't already, install the AWS CLI. You can find instructions for
your platform in the [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

### Configure the AWS CLI for SSO login

You'll configure the AWS CLI to use AWS IAM Identity Center (SSO) for authentication by using the `aws configure sso` command. First, you need some information about your AWS IAM Identity Center setup, which you can find in the AWS IAM Identity Center console under "Settings Summary". You'll need:

* The SSO start URL, which is typically in the format
  `https://d-<your-directory-id>.awsapps.com/start/#`.
* The SSO region, which is the AWS region where your IAM Identity Center is
  located.

The "SSO session" refers to all logins with your IAM Identity Center instance
(i.e., within a single AWS Organization).  For example, I have one SSO session
for personal use and another for work. You can additionally have multiple
"profiles" for different AWS accounts or roles. I have 5 profiles for my
personal SSO session, associated with 5 different subaccounts I use for
different projects. I also have 3 different profiles for my work SSO session,
associated with 2 accounts, one of which has 2 different roles. Before running
the `aws configure sso` command, you should also decide on names for your SSO
session and for your profile. These names are only used locally on your
machine, and you can change them later if you want.

The `aws configure sso` command will interactively prompt you for the required
information. See the AWS docs section [Configure your profile with the `aws
configure sso` wizard](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html#cli-configure-sso-configure)
for a detailed walkthrough. Follow that procedure, and check that it has
created the correct configuration in your `~/.aws/config` file.

By default, you need to specify the profile name when running AWS CLI commands,
using the `--profile` flag. I recommend setting the `AWS_DEFAULT_PROFILE`
environment variable, which makes it so you don't need to do that.

### Validate the configuration

To validate that everything is working now, let's log into you AWS account with:

```bash
aws sso login # --profile <your-profile-name>
```

This will open a browser window to log you in, if you are not already logged
in. The terminal will show you a challenge code; once logged in, the browser
should show you the same code. Click "Confirm and continue" in the browser,
then you'll get a new browser page asking if you want to allow botocore to have
access.  Click allow, and you'll be ready to use the CLI.

To see that it worked, run the command:

```bash
aws sts get-caller-identity
```

This will give you the user ID, the AWS account, and the resource ID (ARN) of
the role you've assumed.

NOTE: If you use `sts get-caller-identity` frequently, you way want to give it
a more memorable alias. You can do this by editing a file at `~/.aws/cli/alias`
and adding the following line:

```ini
[toplevel]
whoami = sts get-caller-identity
```

This will allow you to run `aws whoami` to get your caller identity.

## Tricks to make life easier

Here are a couple of things I use to reduce friction when working with AWS:

* I use [direnv](https://direnv.net) to set the `AWS_DEFAULT_PROFILE`
  environment variable automatically when I `cd` into a project directory.
* I have a script called [`launch-aws-console`](https://github.com/dwhswenson/dotfiles/blob/master/scripts/launch-aws-console) which launches the AWS
  console for the current (or specified) SSO profile.
* I use 1Password with passkeys for 2FA, which makes it much faster for me to
  log into AWS securely.
