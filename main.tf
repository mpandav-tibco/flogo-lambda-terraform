# Define the AWS provider
provider "aws" {
  region     = "eu-central-1" # Specify the AWS region
  access_key = "ASIARC55DQGX7NCENHI2"
  secret_key = "GpKm+8PzThx0QCE/Nchl/AJWP17S2So7PlXl19mm"
  token      = "IQoJb3JpZ2luX2VjEMb//////////wEaDGV1LWNlbnRyYWwtMSJIMEYCIQDxl1eEp6F0tq4cGYdNhhE7gmEAel1YbSK2uemXEjhqJwIhAN/az95JWy+ytilLxmnfOTEk3RyudzeVmg7nP9ZKBR83KpwCCK///////////wEQABoMMDc1MDIxNjQ4MzAzIgwph2e3pp9zKaGOlKkq8AGq2h/gwWqreFlYowG0SpyXiwacvK6CQ8fUdNsjf8PesSBm/XikfZLELTRNhKWD235NRGaTwbmUjZ3M6WyTQL32jvJbmAUyYIKwXRXCrtE6UBySrkVS48OWQFIayo8g9JWMXiwoeRrY/StOYxxZyr4LBSi6oALtDBhTfi5L+LB0tjHgbejB/l/l3JnGTCue447p1NKAsuNXgay4uZDY1NK+Pq4teJ4NDKZXbZe1sR4JvqY5pSnBvEhIe2h16qgP3IN06BmRLNWVOt8x35+3UIZJ7rriksLcGA8uk0tEWDn4q1qOqdDCjbqgbpVPCB5y1v0w/rmGvAY6nAHjHpCslSysKfr5myF3TebZ+ryebkE9kVf0LWEsr0W6Dq8fTgPbHFTHklDN6yI35KxCj2FV4S2lUe0we6jM7ihYLc30srAKqCHm/Iw5HwX+v7gQlrpu5aAkD/v5dUMpMLfOisVCZ9NvfziiozPxluNVgbOPXTZ9XuBXG4NKeVxXDihtOOVWGCKD4v7r9erKUebvkA/9tV+sl9oESyo="
  profile    = "mpandav"
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
