resource "oci_core_vcn" "vcn" {
  compartment_id = local.compartment_ocid
  display_name   = format("%s-vcn", var.proj_abrv)
  cidr_block     = var.vcn_cidr
  is_ipv6enabled = var.vcn_is_ipv6enabled
  dns_label      = var.proj_abrv
}

// Restrict 22 to the public CIDR for bastion access only
resource "oci_core_default_security_list" "default_security_list" {
  compartment_id = local.compartment_ocid
  display_name   = "Default Security List"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
  ingress_security_rules {
    protocol    = "6"
    source      = var.vcn_cidr
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id
}

#####################################################################
## Always Free
#####################################################################
resource "oci_core_internet_gateway" "internet_gateway" {
  count          = var.always_free ? 1 : 0
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = format("%s-internet-gateway", var.proj_abrv)
}

resource "oci_core_route_table" "route_table_internet_gw" {
  count          = var.always_free ? 1 : 0
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = format("%s-route-table-internet-gw", var.proj_abrv)
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway[0].id
  }
}

resource "oci_core_subnet" "subnet_public" {
  count                      = var.always_free ? 1 : 0
  compartment_id             = local.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn.id
  display_name               = format("%s-subnet-public", var.proj_abrv)
  cidr_block                 = var.vcn_cidr
  route_table_id             = oci_core_route_table.route_table_internet_gw[0].id
  dhcp_options_id            = oci_core_vcn.vcn.default_dhcp_options_id
  dns_label                  = "publ"
  prohibit_public_ip_on_vnic = false
}

#####################################################################
## Paid Resources
#####################################################################
resource "oci_core_nat_gateway" "nat_gateway" {
  count          = var.always_free ? 0 : 1
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = format("%s-nat-gateway", var.proj_abrv)
  // The NAT gateway is whitelisted to allow runner comms.
  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_core_route_table" "route_table_nat_gw" {
  count          = var.always_free ? 0 : 1
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = format("%s-route-table-nat-gw", var.proj_abrv)
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway[0].id
  }
}

resource "oci_core_subnet" "subnet_private" {
  count                      = var.always_free ? 0: 1
  compartment_id             = local.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn.id
  display_name               = format("%s-subnet-private", var.proj_abrv)
  cidr_block                 = var.vcn_cidr
  route_table_id             = oci_core_route_table.route_table_nat_gw[0].id
  dhcp_options_id            = oci_core_vcn.vcn.default_dhcp_options_id
  dns_label                  = "priv"
  prohibit_public_ip_on_vnic = true
}