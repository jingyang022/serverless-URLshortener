#############################################################
# Lambda Function for POST /newurl 
#############################################################

# Define an archive_file datasource that creates the lambda archive
data "archive_file" "lambda" {
 type        = "zip"
 #source_file = "hello.py"
 source_dir  = "${path.module}/create-url"
 output_path = "${path.module}/create-url/create-url-lambda.zip"
}

resource "aws_lambda_function" "lambda-post" {
 function_name = "yap-lambda-post"
 role          = aws_iam_role.lambda_exec_role.arn
 handler       = "lambda_function.lambda_handler"
 runtime       = "python3.12"
 filename      = "${path.module}/create-url/create-url-lambda.zip"

  # Environment Variables
  environment {
    variables = {
       	DDB_TABLE = aws_dynamodb_table.url-dynamodb-table.name
    }
  }
}

# aws_cloudwatch_log_group to get the logs of the Lambda execution.
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/yap-lambda-post"
  retention_in_days = 7
}