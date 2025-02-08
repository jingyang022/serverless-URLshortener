# Create IAM policy to attach to Lambda execution role to allow access to DynamoDB
resource "aws_iam_policy" "yap_lambda_dynamoDB_access" {
  name = "yap-lambda-ddb-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.url-dynamodb-table.arn
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "yap_lambda_dynamoDB_attach" {
  name       = "yap-lambda-dynamoDB-attach"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = aws_iam_policy.yap_lambda_dynamoDB_access.arn
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "yap-lambda-exe-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}