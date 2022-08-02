variable "namespace" {
  type = string
}

variable "vpc" {
  type = any
}

variable key_name {
  type = string
}

variable "sg_pub_id" {
  type = any
}

variable "sg_priv_id" {
  type = any
}

variable "coordinator_instance_type" {
  description = "The project namespace to use for unique resource naming"
  default     = "r5.2xlarge"
  type        = string
}

variable "worker_instance_type" {
  description = "The project namespace to use for unique resource naming"
  default     = "r5.4xlarge"
  type        = string
}

variable "worker_count" {
  description = "The project namespace to use for unique resource naming"
  default     = 1
  type        = number
}