# HCL Syntax Overview

HCL is a language designed to be relatively easy for humans to read and edit.
It is not necessary to fully understand the syntax of HCL to use Terraform.
However, some familiarity will make it easier to modify and extend code examples for your own needs.

## Arguments and Blocks

Arguments assign values to names:

```HCL
name = "my-server"
instance_count = 3
enabled = true
```

Blocks are containers for other content.

```HCL
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t2.micro"
}
```

Blocks have a type, label(s) and a body enclosed in braces.
In the example above `resource` is a type, `"aws_instance"` and `"web"` are labels.
The block type defines how many labels are required.
In this example (when working with the AWS provider) the `resource` type requires two labels.

## Comments

HCL supports a few different ways to format comments in HCL code:

```HCL
# Single line comment

// Also a single line comment

/* Multi-line
   comment block */
```

## Data Types

HCL supports several primitive data types:

```HCL
# Strings
name = "hello"
multiline = <<EOF
This is a
multiline string
EOF

# Numbers
count = 42
price = 19.99

# Booleans
enabled = true
disabled = false

# Null
value = null
```

as well as lists:

```HCL
availability_zones = ["us-west-1a", "us-west-1b"]
ports = [80, 443, 8080]
```

and maps:

```HCL
tags = {
  Environment = "production"
  Owner       = "team-platform"
}
```

This completes a general overview of HCL syntax.
To learn more about the language, the [Terraform Language Documentation](https://developer.hashicorp.com/terraform/language) is a good resource.
