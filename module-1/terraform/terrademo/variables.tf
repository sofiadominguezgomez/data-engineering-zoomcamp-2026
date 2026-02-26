variable "project" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "Project Location (Multi-Region)"
  type        = string
  default     = "US"
}

variable "gcs_bucket_name" {
  description = "The prefix for my bucket name"
  type        = string
}