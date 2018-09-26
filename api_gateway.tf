resource "aws_api_gateway_rest_api" "calculator_api" {
  name        = "calculator-api-using-terraform"
  description = "Terraform Serverless Calculator Application"
}



output "base_url" {
  value = "${aws_api_gateway_deployment.calculator_api.invoke_url}"
}
