variable "namespace" {
  description = "The project namespace to use for unique resource naming"
  default     = "VPC-CLUSTER"
  type        = string
}

variable "coordinator_instance_type" {
  description = "The project namespace to use for unique resource naming"
  default     = "r5.4xlarge"
  type        = string
}

variable "worker_instance_type" {
  description = "The project namespace to use for unique resource naming"
  default     = "r5.2xlarge"
  type        = string
}

variable "worker_count" {
  description = "The project namespace to use for unique resource naming"
  default     = 4
  type        = number
}

variable "region" {
  description = "AWS region"
  default     = "us-west-2"
  type        = string
}