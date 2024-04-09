data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_core_instance" "wirevpn_ci" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain].name
  compartment_id      = var.compartment_id
  shape               = var.shape
  shape_config {
    ocpus         = var.shape_config_ocpus
    memory_in_gbs = var.shape_config_memory_in_gbs
  }
  create_vnic_details {
    subnet_id        = var.vcn_subnet_id
    assign_public_ip = true
    display_name     = "wirevpn-vnic"
    hostname_label   = "terraguard"
  }
  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled   = true
    is_monitoring_disabled   = true
  }
  source_details {
    source_id   = var.image_tag
    source_type = "image"
  }
  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"
    network_type     = "PARAVIRTUALIZED"
  }

  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }

  metadata = {
    ssh_authorized_keys = var.public_key
  }

  timeouts {
    create = "60m"
  }
}
