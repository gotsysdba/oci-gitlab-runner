data "oci_core_images" "images" {
  compartment_id           = local.compartment_ocid
  operating_system         = local.compute_image
  operating_system_version = local.compute_image_ver
  shape                    = local.compute_shape
  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

resource "oci_core_instance" "core_instance" {
  count               = var.compute_count
  compartment_id      = local.compartment_ocid
  display_name        = format("%s-server-%s", var.proj_abrv, count.index)
  availability_domain = local.availability_domain
  shape               = local.compute_shape
  shape_config {
    ocpus = var.compute_ocpu
    // Memory OCPU * 6GB (min 8GB)
    memory_in_gbs = var.compute_ocpu == 1 ? 8 : var.compute_ocpu * 6
  }
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.images.images[0].id
  }
  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }
  create_vnic_details {
    subnet_id        = var.always_free ? oci_core_subnet.subnet_public[0].id : oci_core_subnet.subnet_private[0].id
    // To use the IG in Always Free, need a public IP
    assign_public_ip = var.always_free ? true: false
  }
  metadata = {
    user_data = "${base64encode(
      templatefile("${path.root}/templates/cloud-config.tftpl",
        {
          runner_url   = var.runner_url
          runner_token = var.runner_token
        }
      )
    )}"
  }
}