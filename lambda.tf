###
# Cloud Provider
#
provider "aws" {
  region = "us-east-2"
}



###
# All the variables
#
variable "function_name" {
  default = "basic_calculator_terraform_lambda"
}

variable "s3_bucket" {
  default = "astik-anand-bucket"
}

variable "s3_key" {
  default = "basic_calculator_terraform_source/calculator.zip"
}

variable "handler" {
  default = "calculator.lambda_handler"
}

variable "runtime" {
  default = "python3.6"
}



###
# Resource for lambda
#
resource "aws_lambda_function" "calculator_api" {
  # Name of the lambda function
  function_name    = "${var.function_name}"

  # Source code from S3 bucket
  s3_bucket = "${var.s3_bucket}"
  s3_key = "${var.s3_key}"

  # Handler is the entry point for lambda function
  handler = "${var.handler}"

  # Runtime for the lambda
  runtime = "${var.runtime}"

  # Role for executing the lambda
  role = "${aws_iam_role.lambda_exec_role.arn}"
}



###
# IAM role which dictates what other AWS services the Lambda function
# may access.
#
resource "aws_iam_role" "lambda_exec_role" {
  name        = "astik_aws_role"
  path        = "/"
  description = "Allows Lambda Function to call AWS services on our behalf."

assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
}
]
}
EOF
}





###
#  For API Gateway
#


# Creating API resource
resource "aws_api_gateway_resource" "calculator_api_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.calculator_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.calculator_api.root_resource_id}"
  path_part   = "calculate"
}

# Creating POST method in above API resource
resource "aws_api_gateway_method" "calculator_api_resource_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.calculator_api.id}"
  resource_id   = "${aws_api_gateway_resource.calculator_api_resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}


# Integration of created API with created resource using method
resource "aws_api_gateway_integration" "calculator_api_resource_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.calculator_api.id}"
  resource_id = "${aws_api_gateway_resource.calculator_api_resource.id}"
  http_method = "${aws_api_gateway_method.calculator_api_resource_method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.calculator_api.invoke_arn}"
}

# Method Response 
resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.calculator_api.id}"
  resource_id = "${aws_api_gateway_resource.calculator_api_resource.id}"
  http_method = "${aws_api_gateway_method.calculator_api_resource_method.http_method}"
  status_code = "200"
}

# Integration of Staus Code with Method
resource "aws_api_gateway_integration_response" "calculator_api_resource_method_and_statuscode_integration" {
  depends_on = [
    "aws_api_gateway_rest_api.calculator_api",
    "aws_api_gateway_resource.calculator_api_resource",
    "aws_api_gateway_method.calculator_api_resource_method",
    "aws_api_gateway_method_response.200",
    "aws_api_gateway_integration.calculator_api_resource_integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.calculator_api.id}"
  resource_id = "${aws_api_gateway_resource.calculator_api_resource.id}"
  http_method = "${aws_api_gateway_method.calculator_api_resource_method.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
}




###
# Deployment stage for lambda
#
resource "aws_api_gateway_deployment" "calculator_api" {
  depends_on = [
    "aws_api_gateway_integration.calculator_api_resource_integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.calculator_api.id}"
  stage_name  = "test"
}





###
# Permission to access
#
resource "aws_lambda_permission" "calculator-api-permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.calculator_api.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.calculator_api.execution_arn}/*/*"
}
