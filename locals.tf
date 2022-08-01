locals {
  compartment_ocid = var.compartment_ocid != "" ? var.compartment_ocid : var.tenancy_ocid
  user_ocid        = var.user_ocid != "" ? var.user_ocid : var.current_user_ocid

  compute_image     = "Oracle Linux Cloud Developer"
  compute_image_ver = "8"
  compute_user      = "opc"
  compute_shape     = "VM.Standard.A1.Flex"
}