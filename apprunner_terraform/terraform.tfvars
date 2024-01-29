account_id = "864245922788"
codebuild_params = {
      "NAME" = "codebuild-demo-terraform"
      "GIT_REPO" = "https://github.com/eltondobemcontabilidade/apinomes.git"
      "IMAGE" = "aws/codebuild/standard:4.0"
      "TYPE" = "LINUX_CONTAINER"
      "COMPUTE_TYPE" = "BUILD_GENERAL1_SMALL"
      "CRED_TYPE" = "CODEBUILD"
  } 
environment_variables = {
      "AWS_DEFAULT_REGION" = "us-east-1"
      "AWS_ACCOUNT_ID" = "864245922788"
      "IMAGE_REPO_NAME" = "apinomes"
      "IMAGE_TAG" = "latest"
  }