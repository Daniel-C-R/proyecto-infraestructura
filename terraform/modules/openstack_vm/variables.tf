variable "name" {
  type = string
}

variable "image_id" {
  type = string
}

variable "flavor_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "admin_user" {
  type = string
}

variable "public_key" {
  type = string
}

variable "timezone" {
  type = string
}

variable "subject" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "instance_metadata" {
  type    = map(string)
  default = {}
}
