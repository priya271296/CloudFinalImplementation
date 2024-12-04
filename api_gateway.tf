# Declare the AWS region as a variable
variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-west-1"  # Set to your desired region
} 
# Step 1: Create the API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "MyAPI"
  description = "API for my Lambda functions"
}
# Step 2: Create the 'login' resource (path)
resource "aws_api_gateway_resource" "login_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "login"
}
# Step 3: Create the 'register' resource (path)
resource "aws_api_gateway_resource" "register_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "register"
}
# Step 4: Create the POST method for 'login'
resource "aws_api_gateway_method" "login_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.login_resource.id
  http_method   = "POST"
  authorization = "NONE"
}
# Step 5: Create the POST method for 'register'
resource "aws_api_gateway_method" "register_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.register_resource.id
  http_method   = "POST"
  authorization = "NONE"
}
# Step 6: Integrate the Lambda function with the POST method for 'login'
resource "aws_api_gateway_integration" "login_post_integration" {
  rest_api_id              = aws_api_gateway_rest_api.api.id
  resource_id              = aws_api_gateway_resource.login_resource.id
  http_method              = aws_api_gateway_method.login_post_method.http_method
  integration_http_method  = "POST"
  type                     = "AWS_PROXY"
  uri                      = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.login_function.arn}/invocations"
}

# Step 7: Integrate the Lambda function with the POST method for 'register'
resource "aws_api_gateway_integration" "register_post_integration" {
  rest_api_id              = aws_api_gateway_rest_api.api.id
  resource_id              = aws_api_gateway_resource.register_resource.id
  http_method              = aws_api_gateway_method.register_post_method.http_method
  integration_http_method  = "POST"
  type                     = "AWS_PROXY"
  uri                      = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.register_function.arn}/invocations"
}

# Step 8: Create the OPTIONS method for 'login' to handle CORS
resource "aws_api_gateway_method" "login_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.login_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Step 9: Create the OPTIONS method for 'register' to handle CORS
resource "aws_api_gateway_method" "register_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.register_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Step 10: Integration for OPTIONS method (CORS preflight) for 'login'
resource "aws_api_gateway_integration" "login_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.login_resource.id
  http_method             = aws_api_gateway_method.login_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

# Step 11: Integration for OPTIONS method (CORS preflight) for 'register'
resource "aws_api_gateway_integration" "register_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.register_resource.id
  http_method             = aws_api_gateway_method.register_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

# Step 12: Method response for OPTIONS (CORS) for 'login'
resource "aws_api_gateway_method_response" "login_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.login_resource.id
  http_method = aws_api_gateway_method.login_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  
}

# Step 13: Method response for OPTIONS (CORS) for 'register'
resource "aws_api_gateway_method_response" "register_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.register_resource.id
  http_method = aws_api_gateway_method.register_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Step 14: Integration response for OPTIONS (CORS) for 'login'
resource "aws_api_gateway_integration_response" "login_options_integration_response" {
  rest_api_id     = aws_api_gateway_rest_api.api.id
  resource_id     = aws_api_gateway_resource.login_resource.id
  http_method     = aws_api_gateway_method.login_options_method.http_method
  status_code     = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type, Authorization'"
  }
  depends_on = [
    aws_api_gateway_integration.login_options_integration
  ]
}

# Step 15: Integration response for OPTIONS (CORS) for 'register'
resource "aws_api_gateway_integration_response" "register_options_integration_response" {
  rest_api_id     = aws_api_gateway_rest_api.api.id
  resource_id     = aws_api_gateway_resource.register_resource.id
  http_method     = aws_api_gateway_method.register_options_method.http_method
  status_code     = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type, Authorization'"
  }
  depends_on = [
    aws_api_gateway_integration.register_options_integration
  ]
}

# Step 1: Create the 'connrequest' resource (path)
resource "aws_api_gateway_resource" "connrequest_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "connect"
}

# Step 2: Create the POST method for 'connrequest'
resource "aws_api_gateway_method" "connrequest_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.connrequest_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Step 3: Integrate the Lambda function with the POST method for 'connrequest'
resource "aws_api_gateway_integration" "connrequest_post_integration" {
  rest_api_id              = aws_api_gateway_rest_api.api.id
  resource_id              = aws_api_gateway_resource.connrequest_resource.id
  http_method              = aws_api_gateway_method.connrequest_post_method.http_method
  integration_http_method  = "POST"
  type                     = "AWS_PROXY"
  uri                      = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.connrequest_function.arn}/invocations"
}

# Step 4: Create the OPTIONS method for 'connrequest' to handle CORS
resource "aws_api_gateway_method" "connrequest_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.connrequest_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Step 5: Integration for OPTIONS method (CORS preflight) for 'connrequest'
resource "aws_api_gateway_integration" "connrequest_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.connrequest_resource.id
  http_method             = aws_api_gateway_method.connrequest_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

# Step 6: Method response for OPTIONS (CORS) for 'connrequest'
resource "aws_api_gateway_method_response" "connrequest_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.connrequest_resource.id
  http_method = aws_api_gateway_method.connrequest_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Step 7: Integration response for OPTIONS (CORS) for 'connrequest'
resource "aws_api_gateway_integration_response" "connrequest_options_integration_response" {
  rest_api_id     = aws_api_gateway_rest_api.api.id
  resource_id     = aws_api_gateway_resource.connrequest_resource.id
  http_method     = aws_api_gateway_method.connrequest_options_method.http_method
  status_code     = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type, Authorization'"
  }
  depends_on = [
    aws_api_gateway_integration.connrequest_options_integration
  ]
}

# Step 8: Create the 'sharepost' resource (path)
resource "aws_api_gateway_resource" "sharepost_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "sharePost"
}

# Step 9: Create the POST method for 'sharepost'
resource "aws_api_gateway_method" "sharepost_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.sharepost_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Step 10: Integrate the Lambda function with the POST method for 'sharepost'
resource "aws_api_gateway_integration" "sharepost_post_integration" {
  rest_api_id              = aws_api_gateway_rest_api.api.id
  resource_id              = aws_api_gateway_resource.sharepost_resource.id
  http_method              = aws_api_gateway_method.sharepost_post_method.http_method
  integration_http_method  = "POST"
  type                     = "AWS_PROXY"
  uri                      = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.sharepost_function.arn}/invocations"
}

# Step 11: Create the OPTIONS method for 'sharepost' to handle CORS
resource "aws_api_gateway_method" "sharepost_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.sharepost_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Step 12: Integration for OPTIONS method (CORS preflight) for 'sharepost'
resource "aws_api_gateway_integration" "sharepost_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.sharepost_resource.id
  http_method             = aws_api_gateway_method.sharepost_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

# Step 13: Method response for OPTIONS (CORS) for 'sharepost'
resource "aws_api_gateway_method_response" "sharepost_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.sharepost_resource.id
  http_method = aws_api_gateway_method.sharepost_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Step 14: Integration response for OPTIONS (CORS) for 'sharepost'
resource "aws_api_gateway_integration_response" "sharepost_options_integration_response" {
  rest_api_id     = aws_api_gateway_rest_api.api.id
  resource_id     = aws_api_gateway_resource.sharepost_resource.id
  http_method     = aws_api_gateway_method.sharepost_options_method.http_method
  status_code     = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type, Authorization'"
  }
  depends_on = [
    aws_api_gateway_integration.sharepost_options_integration
  ]
}

# DELETE Resource
resource "aws_api_gateway_resource" "delete_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "deletePost"
}

# DELETE Method
resource "aws_api_gateway_method" "delete_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.delete_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# DELETE Integration
resource "aws_api_gateway_integration" "delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.delete_resource.id
  http_method             = aws_api_gateway_method.delete_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.delete_function.arn}/invocations"
}

# CORS OPTIONS Method
resource "aws_api_gateway_method" "delete_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.delete_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# CORS OPTIONS Integration
resource "aws_api_gateway_integration" "delete_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.delete_resource.id
  http_method             = aws_api_gateway_method.delete_options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

# CORS Method Response
resource "aws_api_gateway_method_response" "delete_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.delete_resource.id
  http_method = aws_api_gateway_method.delete_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# CORS Integration Response
resource "aws_api_gateway_integration_response" "delete_options_integration_response" {
  rest_api_id     = aws_api_gateway_rest_api.api.id
  resource_id     = aws_api_gateway_resource.delete_resource.id
  http_method     = aws_api_gateway_method.delete_options_method.http_method
  status_code     = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE, OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type, Authorization'"
  }
  depends_on = [aws_api_gateway_integration.delete_options_integration]
}
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}


resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "test"
  depends_on = [
    aws_api_gateway_integration.login_post_integration,
    aws_api_gateway_integration.register_post_integration,
    aws_api_gateway_integration.login_options_integration,
    aws_api_gateway_integration.register_options_integration,
    aws_api_gateway_integration.connrequest_post_integration,
    aws_api_gateway_integration.connrequest_options_integration,
    aws_api_gateway_integration.sharepost_post_integration,
    aws_api_gateway_integration.sharepost_options_integration,
    aws_api_gateway_integration.delete_integration,
    aws_api_gateway_integration_response.delete_options_integration_response,
    
  ]
}
output "login_api_gateway_url" {
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/test/login"
  description = "The URL for the 'login' API"
}
output "register_api_gateway_url" {
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/test/register"
  description = "The URL for the 'register' API"
}
output "sharepost_api_gateway_url" {
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/test/sharepost"
  description = "The URL for the 'sharepost' API"
}
output "connrequest_api_gateway_url" {
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/test/connect"
  description = "The URL for the 'connrequest' API"
}
output "delete_api_gateway_url" {
  value       = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/test/deletePost"
  description = "The URL for the 'delete' API endpoint"
}




