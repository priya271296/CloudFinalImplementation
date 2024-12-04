# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
# Attach basic execution role for Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec_role.name
}
resource "aws_lambda_function" "login_function" {
  filename         = "/Users/priyankamutha/Desktop/Cloud_Project/backend/lambda-functions.zip"  # Path to your zip file containing Lambda code
  function_name    = "loginLambdaFunction"  # The name of the Lambda function
  role             = aws_iam_role.lambda_exec_role.arn  # IAM role Lambda will use
  handler          = "login.handler"  # File and function to execute
  runtime          = "nodejs16.x"  # Runtime environment for the function
  memory_size      = 128  # Memory allocation for Lambda
  timeout          = 10   # Timeout in seconds
}
# Lambda function for Register (you will need to implement a register handler in a similar way)
resource "aws_lambda_function" "register_function" {
  filename         = "/Users/priyankamutha/Desktop/Cloud_Project/backend/lambda-functions.zip"  # Path to your register function's zip file
  function_name    = "registerLambdaFunction"  # The name of the Lambda function
  role             = aws_iam_role.lambda_exec_role.arn  # IAM role Lambda will use
  handler          = "register.handler"  # File and function to execute
  runtime          = "nodejs16.x"  # Runtime environment for the function
  memory_size      = 128  # Memory allocation for Lambda
  timeout          = 10   # Timeout in seconds
}
# Permissions for API Gateway to invoke Login Lambda
resource "aws_lambda_permission" "lambda_permission_login" {
  statement_id  = "AllowAPIGatewayInvokeLogin"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.login_function.function_name
}
# Permissions for API Gateway to invoke Register Lambda
resource "aws_lambda_permission" "lambda_permission_register" {
  statement_id  = "AllowAPIGatewayInvokeRegister"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.register_function.function_name
}

# Lambda Function for Connection Request
resource "aws_lambda_function" "connrequest_function" {
  filename         = "/Users/priyankamutha/Desktop/Cloud_Project/backend/connect.zip"  # Path to your zip file containing Lambda code
  function_name    = "connRequestLambdaFunction"  # The name of the Lambda function
  role             = aws_iam_role.lambda_exec_role.arn  # IAM role Lambda will use
  handler          = "connect.handler"  # File and function to execute (e.g., connrequest.js -> handler function)
  runtime          = "nodejs16.x"  # Runtime environment for the function
  memory_size      = 128  # Memory allocation for Lambda
  timeout          = 10   # Timeout in seconds
} 
# Permissions for API Gateway to invoke Connection Request Lambda
resource "aws_lambda_permission" "lambda_permission_connrequest" {
  statement_id  = "AllowAPIGatewayInvokeConnRequest"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.connrequest_function.function_name
}
resource "aws_lambda_function" "sharepost_function" {
  filename         = "/Users/priyankamutha/Desktop/Cloud_Project/backend/sharepost.zip" # Path to the zip file containing the Lambda code
  function_name    = "sharePostLambdaFunction"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "sharepost.handler" # File and handler function
  runtime          = "nodejs16.x"
  memory_size      = 128
  timeout          = 10
}
resource "aws_lambda_permission" "sharepost_permission" {
  statement_id  = "AllowAPIGatewayInvokeSharePost"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.sharepost_function.function_name
}

resource "aws_lambda_function" "delete_function" {
  filename         = "/Users/priyankamutha/Desktop/Cloud_Project/backend/deletePost.zip"
  function_name    = "deleteLambdaFunction"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "deletePost.handler"
  runtime          = "nodejs16.x"
  memory_size      = 128
  timeout          = 10
}

resource "aws_lambda_permission" "delete_permission" {
  statement_id  = "AllowAPIGatewayInvokeDelete"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.delete_function.function_name
}



