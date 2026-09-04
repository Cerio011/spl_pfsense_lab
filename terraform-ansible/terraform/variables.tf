variable "aws_region" {
  default = "us-east-2"
}

variable "key_name" {
  description = "Nome do key pair ja existente na AWS"
  type        = string
  default     = "kelly_pair_key"
}

variable "vpc_id" {
  description = "ID da VPC ja existente"
  type        = string
  default     = "vpc-07251c6b6aa1b2396"
}

variable "subnet_id" {
  description = "ID da Subnet ja existente"
  type        = string
  default     = "subnet-0ae7b232939657f56"
}

variable "security_group_id" {
  description = "ID do Security Group ja existente"
  type        = string
  default     = "sg-005ac00ad7c3ed5fe"
}