# Cognito User Pool for API authentication
resource "aws_cognito_user_pool" "documents_pool" {
  name = "documents-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  auto_verified_attributes = ["email"]

  software_token_mfa_configuration {
    enabled = false
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "documents_client" {
  name            = "documents-api-client"
  user_pool_id    = aws_cognito_user_pool.documents_pool.id
  generate_secret = false
  token_validity_units {
    access_token  = "minutes"
    refresh_token = "days"
    id_token      = "minutes"
  }
  access_token_validity  = 15
  refresh_token_validity = 6
  id_token_validity      = 15
}
