terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

### IAM ###
resource "aws_iam_role" "myroles" {
  name = "myroles"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "build.apprunner.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "myrolespolicy" {
  role       = aws_iam_role.myroles.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_apprunner_auto_scaling_configuration_version" "app_runner" {
  auto_scaling_configuration_name = "app_runner_auto_scaling"
  min_size = 1
  max_size = 5
}

resource "aws_apprunner_service" "app_runner" {
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.app_runner.arn

  service_name = "app_runner_service"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.myroles.arn
    }
    image_repository {
      image_configuration {
        port = "8080"                          
      }

      image_identifier      = "864245922788.dkr.ecr.us-east-1.amazonaws.com/apinomes:latest"
      image_repository_type = "ECR"
    }
  }
}

output "apprunner_service_hello" {
  value = aws_apprunner_service.app_runner
}


# simple codebuild project
resource "aws_codebuild_project" "codebuild_project" {
  name          = var.codebuild_name
  description   = "Codebuild demo with Terraform"
  build_timeout = "120"
  service_role = aws_iam_role.role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type            = "GITHUB"
    location        = lookup(var.codebuild_params, "GIT_REPO")
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  environment {
    image                       = lookup(var.codebuild_params, "IMAGE")
    type                        = lookup(var.codebuild_params, "TYPE")
    compute_type                = lookup(var.codebuild_params, "COMPUTE_TYPE")
    image_pull_credentials_type = lookup(var.codebuild_params, "CRED_TYPE")
    privileged_mode             = true

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status = "DISABLED"
    }
  }
}
