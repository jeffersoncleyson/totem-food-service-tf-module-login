# Input variable definitions

variable "application_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Application environment"
  type        = string
}

variable "owner_team" {
  description = "Owener Application team"
  type        = string
}

variable "cognito_client_id" {
  description = "Cognito Client ID"
  type        = string
}

variable "cognito_client_secret" {
  description = "Cognito Client Secret"
  type        = string
}

variable "cognito_anonymous_user" {
  description = "Cognito Anonymous User"
  type        = string
}

variable "cognito_anonymous_password" {
  description = "Cognito Anonymous User Password"
  type        = string
  sensitive = true
}