variable "namespace" {
  description = "The project namespace to use for unique resource naming"
  default     = "TRINO-TEST"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-west-2"
  type        = string
}