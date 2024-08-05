variable "vpc_prod_cidr" {
  description = "CIDR block for Prod VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_non_prod_cidr" {
  description = "CIDR block for Non-prod VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_mgmt_cidr" {
  description = "CIDR block for Mgmt VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "vpc_prod_private_subnets" {
  description = "Private subnets for Prod VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_prod_public_subnets" {
  description = "Public subnets for Prod VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_non_prod_private_subnets" {
  description = "Private subnets for Non-prod VPC"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "vpc_non_prod_public_subnets" {
  description = "Public subnets for Non-prod VPC"
  type        = list(string)
  default     = ["10.1.101.0/24", "10.1.102.0/24"]
}

variable "vpc_mgmt_private_subnets" {
  description = "Private subnets for Mgmt VPC"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "vpc_mgmt_public_subnets" {
  description = "Public subnets for Mgmt VPC"
  type        = list(string)
  default     = ["10.2.101.0/24", "10.2.102.0/24"]
}

variable "key_name" {
  description = "The key pair name for EC2 instances"
  type        = string
}
