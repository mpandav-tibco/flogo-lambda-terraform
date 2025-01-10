# Define the AWS provider
provider "aws" {
  region     = "eu-central-1" # Specify the AWS region
  access_key = ""             # Required accessKey token
  secret_key = ""             # Required secretKey token
  token      = ""             # Required security token
  profile    = "xxxx"         # Optional profile name
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "aws-lambda" {
  name = "aws-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "iam_policy_for_lambda"
  description = "IAM policy for Lambda function"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })

}
# Attach a policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.aws-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" # Attach the basic execution role policy
}

# Create a Lambda function
resource "aws_lambda_function" "lambda_function" {
  function_name = "aws-lambda-ecolabel-api"   # Name of the Lambda function
  role          = aws_iam_role.aws-lambda.arn # IAM role for the Lambda function
  handler       = "bootstrap"                 # Handler for the Lambda function
  runtime       = "provided.al2"              # Runtime environment for the Lambda function

  # Path to the deployment package
  filename = "/Users/milindpandav/Downloads/Work/tibco/fkogo/ws/bin/bootstrap.zip"

  # Environment variables for the Lambda function
  environment {
    variables = {
      productId = "1"
    }
  }
}

# Create a CloudWatch log group for the Lambda function
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/aws-lambda-ecolabel-api" # Name of the log group
  retention_in_days = 14                                    # Number of days to retain the logs
}
