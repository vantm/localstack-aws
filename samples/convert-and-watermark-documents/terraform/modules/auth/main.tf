resource "aws_cognito_user_pool" "documents_pool" {
  name = var.user_pool_name

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "documents_client" {
  name            = var.user_pool_client_name
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

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls
}
