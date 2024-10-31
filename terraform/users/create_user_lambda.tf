resource "aws_lambda_function" "create_user_lambda" {
  filename         = "${abspath(path.module)}/../../lambdas/create_user/${var.create_user_lambda_zip_filename}"
  source_code_hash = filebase64sha256("${abspath(path.module)}/../../lambdas/create_user/${var.create_user_lambda_zip_filename}")
  role             = aws_iam_role.create_user_lambda_role.arn
  function_name    = var.create_user_lambda_function_name
  handler          = "index.handler" ##change sample_project_lambda according to the python file name
  runtime          = "nodejs18.x"
  timeout          = 30

  description = "Lambda to create user and add user to database"

  vpc_config {
    security_group_ids = [aws_security_group.lambda_security_group.id]
    subnet_ids         = tolist(aws_subnet.private_subnets[*].id)
  }

  environment {
    variables = {
      DATABASE_NAME = var.db_name
      DB_USERNAME   = var.db_username
      DB_PASSWORD   = var.db_password
      DB_HOST       = aws_db_instance.mydb.address
      DB_PORT       = var.db_port
    }
  }




  depends_on = [
    aws_iam_role.create_user_lambda_role,
    aws_vpc.main,
    aws_subnet.private_subnets,
    aws_security_group.lambda_security_group,
    aws_db_instance.mydb
  ]
}

resource "aws_iam_role" "create_user_lambda_role" {
  name               = "${var.create_user_lambda_function_name}_role"
  description        = "Lambda execution role for ${var.create_user_lambda_function_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_create_user_lambda_role.json

  inline_policy {
    name   = "create_user_lambda_lambda_role_policy"
    policy = data.aws_iam_policy_document.create_user_lambda_role_permissions.json
  }
}

data "aws_iam_policy_document" "assume_create_user_lambda_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "create_user_lambda_role_permissions" {

  # Permissions required for lambda to execute in VPC
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
    effect    = "Allow"
  }




  #Cloudwatch Logs permission required for Lambda
  statement {
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:ap-southeast-1:${data.aws_caller_identity.current_caller_for_create_user_lambda.account_id}:*"
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogStream"
    ]
    resources = [
      "arn:aws:logs:ap-southeast-1:${data.aws_caller_identity.current_caller_for_create_user_lambda.account_id}:log-group:/aws/lambda/${var.create_user_lambda_function_name}:*"
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:ap-southeast-1:${data.aws_caller_identity.current_caller_for_create_user_lambda.account_id}:log-group:/aws/lambda/${var.create_user_lambda_function_name}:log-stream:*"
    ]
    effect = "Allow"
  }


}
