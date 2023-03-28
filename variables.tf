variable "private_key_path" {
  description = "The path to the private key file used for SSH access to the instance."
  type        = string
}

variable "key_name" {
    description = "The name of the key pair to use for SSH access to the instance."
    type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy the instance into."
  type        = string
}

variable "ec2_ami" {
  description = "The AMI to use for the instance."
  type        = string
}

variable "sub_domain_name" {
  description = "The sub domain name to use for the instance, e.g. 'gpt' for 'gpt.example.com'."
  type        = string
}

variable "domain_name" {
  description = "The main domain name to use for the Route53 zone, e.g. 'example.com'."
  type        = string
}
