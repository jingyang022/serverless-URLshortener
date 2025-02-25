#############################################################
# Lambda Function for POST /newurl 
#############################################################

# Define an archive_file datasource that creates the lambda archive
data "archive_file" "lambda-post-file" {
  type = "zip"
  #source_file = "hello.py"
  source_dir  = "${path.module}/create-url"
  output_path = "${path.module}/create-url/lambda_function.zip"
}

resource "aws_lambda_function" "lambda-post-func" {
  function_name = "lambda-post-func"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda-post-file.output_path

  # Environment Variables
  environment {
    variables = {
      DB_NAME = aws_dynamodb_table.url-dynamodb-table.name
      APP_URL    = "https://yap-urlshortener.sctp-sandbox.com"
      MAX_CHAR   = "16"
      MIN_CHAR   = "12"
      REGION_AWS = "ap-southeast-1"
    }
  }
}

# Gives API gateway the permission to access the Lambda function POST.
resource "aws_lambda_permission" "post_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "lambda-post-func"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.yap_api.execution_arn}/*"
}

# aws_cloudwatch_log_group to get the logs of the Lambda execution.
resource "aws_cloudwatch_log_group" "lambda-post-logs" {
  name              = "/aws/lambda/yap-lambda-post"
  retention_in_days = 7
}

#############################################################
# Lambda Function (for GET)
#############################################################

# Define an archive_file datasource that creates the lambda archive
data "archive_file" "lambda-get-file" {
  type = "zip"
  #source_file = "hello.py"
  source_dir  = "${path.module}/retrieve-url"
  output_path = "${path.module}/retrieve-url/lambda_function.zip"
}

resource "aws_lambda_function" "lambda-get-func" {
  function_name = "lambda-get-func"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename      = "${path.module}/retrieve-url/lambda_function.zip"

  # Environment Variables
  environment {
    variables = {
      DB_NAME = aws_dynamodb_table.url-dynamodb-table.name
      REGION_AWS = "ap-southeast-1"
    }
  }
}

# Gives API gateway the permission to access the Lambda function GET.
resource "aws_lambda_permission" "get_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "lambda-get-func"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.yap_api.execution_arn}/*"
}

# aws_cloudwatch_log_group to get the logs of the Lambda execution.
resource "aws_cloudwatch_log_group" "lambda-get-logs" {
  name              = "/aws/lambda/yap-lambda-get"
  retention_in_days = 7
}