variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-2"
}

variable "agent_name" {
  description = "Name of the Strands agent demo"
  type        = string
  default     = "strands-demo"
}

variable "model_name" {
  description = "ID of the model to be used for the agent"
  type = string
  default = "us.anthropic.claude-3-5-sonnet-20241022-v2:0"
}