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

variable "student_user" {
  type = string
}

variable "student_public_keys" {
  type    = list(string)
  default = []
}

variable "private_key_path" {
  type = string
}

variable "instance_metadata" {
  type    = map(string)
  default = {}
}
