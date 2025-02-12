#############################################################
# API Gateway for Create URL resources
#############################################################

resource "aws_api_gateway_rest_api" "yap_api" {
  name        = "yap-api"
  description = "Yap API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "newurl" {
  rest_api_id = aws_api_gateway_rest_api.yap_api.id
  parent_id   = aws_api_gateway_rest_api.yap_api.root_resource_id
  path_part   = "newurl"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.yap_api.id
  resource_id   = aws_api_gateway_resource.newurl.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.yap_api.id
  resource_id             = aws_api_gateway_resource.newurl.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda-post-func.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.yap_api.id
  resource_id = aws_api_gateway_resource.newurl.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}


#############################################################
# API Gateway for GET URL resources
#############################################################

resource "aws_api_gateway_resource" "geturl" {
  rest_api_id = aws_api_gateway_rest_api.yap_api.id
  parent_id   = aws_api_gateway_rest_api.yap_api.root_resource_id
  path_part   = "{shortid}"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.yap_api.id
  resource_id   = aws_api_gateway_resource.geturl.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.yap_api.id
  resource_id             = aws_api_gateway_resource.geturl.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda-get-func.invoke_arn
  request_templates = {
    "application/json" = <<EOF
    { 
      "short_id": "$input.params('shortid')" 
    }
    EOF
  }
}

resource "aws_api_gateway_method_response" "response_302" {
  rest_api_id = aws_api_gateway_rest_api.yap_api.id
  resource_id = aws_api_gateway_resource.geturl.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "302"

  response_parameters = {
    "method.response.header.Location" = true
  }
}

resource "aws_api_gateway_integration_response" "get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.yap_api.id
  resource_id = aws_api_gateway_resource.geturl.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = aws_api_gateway_method_response.response_302.status_code

  response_parameters = {
    "method.response.header.Location" = "integration.response.body.location"
  }
  depends_on = [
    aws_api_gateway_integration.get_integration
  ]
}

#############################################################
# API Gateway Deployment
#############################################################

resource "aws_api_gateway_deployment" "api-deployment" {
  depends_on = [aws_api_gateway_integration.post_integration,
                aws_api_gateway_integration.get_integration,
                ]

  rest_api_id = aws_api_gateway_rest_api.yap_api.id
  
   triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.yap_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.api-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.yap_api.id
  stage_name    = "dev"
}