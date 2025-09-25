variable "name" {
  type        = string
  description = "define VPC name"
}

variable "cidr_block" {
  type = string
}

variable "azs" {
  type    = list(string)
  default = []
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "public_subnet_tags" {
  type    = map(string)
  default = {}
}
