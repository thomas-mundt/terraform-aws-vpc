variable "cidr_block" {
  description = "The CIDR block for the VPC. For example, '10.0.0.0/16'."
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Specifies whether to enable DNS hostnames in the VPC. Default is true."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Specifies whether to enable DNS support in the VPC. Default is true."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource. For example, {'Environment' = 'production'}."
  type        = map(string)
  default     = {}
}

variable "project" {
  description = "The project name used for resource naming."
  type        = string
}

variable "public_subnets" {
  description = "A map of public subnets with their CIDR blocks and availability zones."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "private_subnets" {
  description = "Map of private subnets with CIDR blocks and availability zones."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "nat_gateway_mapping" {
  description = "Mapping of private subnets to the NAT gateway in their corresponding public subnet."
  type = map(string)
}
