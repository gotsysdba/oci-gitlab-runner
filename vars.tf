# Copyright © 2020, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

// Basic Hidden
variable "tenancy_ocid" {}
variable "compartment_ocid" {
  default = ""
}
variable "region" {}

// Extra Hidden
variable "user_ocid" {
  default = ""
}

variable "current_user_ocid" {
  default = ""
}

variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}

// General Configuration
variable "proj_abrv" {
  default = "gitlab"
}

variable "always_free" {
  default = true
}

// VCN Configurations Variables
variable "vcn_cidr" {
  description = "10.1.0.0 - 10.1.0.7"
  default     = "10.1.0.0/29"
}

variable "vcn_is_ipv6enabled" {
  default = false
}

// Runner Instances
variable "compute_count" {
  type    = number
  default = 1
}
variable "compute_ocpu" {
  type    = number
  default = 1
}

// Runner Specifics
variable "runner_url" {
  default = "https://gitlab.com/"
}

variable "runner_token" {}
