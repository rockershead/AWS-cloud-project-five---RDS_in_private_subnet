# Create the REST API
resource "aws_api_gateway_rest_api" "user_api" {
  name        = "UserAPI"
  description = "API for users"
}

# Create the resource for /users
resource "aws_api_gateway_resource" "user" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_rest_api.user_api.root_resource_id
  path_part   = "users"
}



# Create POST method for /users
resource "aws_api_gateway_method" "create_user" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.user.id
  http_method   = "POST"
  authorization = "NONE"
}

# Create GET method for /users
resource "aws_api_gateway_method" "get_users" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.user.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integrate the POST method with the create Lambda function
resource "aws_api_gateway_integration" "create_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.user_api.id
  resource_id             = aws_api_gateway_resource.user.id
  http_method             = aws_api_gateway_method.create_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_user_lambda.invoke_arn
}

# Integrate the GET method with the get Lambda function
resource "aws_api_gateway_integration" "get_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.user_api.id
  resource_id             = aws_api_gateway_resource.user.id
  http_method             = aws_api_gateway_method.get_users.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_user_lambda.invoke_arn
}

# Grant API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "apigw_lambda_create" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_user_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  #source_arn    = "${aws_api_gateway_rest_api.parking_lots_api.execution_arn}/*/*"
  source_arn = "arn:aws:execute-api:ap-southeast-1:${data.aws_caller_identity.current_caller_for_get_user_lambda.account_id}:${aws_api_gateway_rest_api.user_api.id}/*/POST/users"
}

# Grant API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "apigw_lambda_get" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  #source_arn    = "${aws_api_gateway_rest_api.parking_lots_api.execution_arn}/*/*"
  source_arn = "arn:aws:execute-api:ap-southeast-1:${data.aws_caller_identity.current_caller_for_get_user_lambda.account_id}:${aws_api_gateway_rest_api.user_api.id}/*/GET/users"
}

# Deploy the API
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_integration.create_lambda_integration,
    aws_api_gateway_integration.get_lambda_integration
  ]

}

resource "aws_security_group" "api_gateway_endpoint_security_group" {

  name = "${var.vpc_name}_sg"

  vpc_id = aws_vpc.main.id



  # Allow inbound traffic on port 80 (HTTP)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  # Allow inbound traffic on port 443 (HTTPS)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic"
  }


  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

}

# API Gateway interface Endpoint
resource "aws_vpc_endpoint" "api_gateway_endpoint" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.ap-southeast-1.execute-api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [for subnet in aws_subnet.private_subnets : subnet.id]
  security_group_ids = [aws_security_group.api_gateway_endpoint_security_group.id]
  tags = {
    Name = "${var.vpc_name}_api_gateway_interface_endpoint"
  }
}

# Resource Policy to restrict access to the VPC Endpoint
data "aws_iam_policy_document" "rds_policy_document" {

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["arn:aws:execute-api:ap-southeast-1:${data.aws_caller_identity.current_caller_for_create_user_lambda.account_id}:${aws_api_gateway_rest_api.user_api.id}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.api_gateway_endpoint.id]
    }
  }

}

resource "aws_api_gateway_rest_api_policy" "rds_api_policy" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  policy      = data.aws_iam_policy_document.rds_policy_document.json
}


