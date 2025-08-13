variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-2" # Default region for Claude 4 Sonnet
}

variable "agent_name" {
  description = "Name of the Strands agent demo"
  type        = string
  default     = "strands-demo"
}