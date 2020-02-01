// example_virtual_machines creates a single virtual machine on each individual
// host.
resource "vsphere_virtual_machine" "example_virtual_machines" {
  count            = "${length(var.esxi_hosts)}"
  name             = "${var.virtual_machine_name_prefix}${count.index}"
  resource_pool_id = "${data.vsphere_resource_pool.example_resource_pool.id}"
  host_system_id   = "${data.vsphere_host.example_hosts.*.id[count.index]}"
  datastore_id     = "${vsphere_nas_datastore.example_datastore.id}"

  num_cpus = 2
  memory   = 1024
  guest_id = "${data.vsphere_virtual_machine.example_template.guest_id}"

  network_interface {
    network_id   = "${vsphere_distributed_port_group.example_port_group.id}"
    adapter_type = "${data.vsphere_virtual_machine.example_template.network_interface_types[0]}"
  }

  disk {
    label = "disk0"
    size  = "${data.vsphere_virtual_machine.example_template.disks.0.size}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.example_template.id}"

    customize {
      linux_options {
        host_name = "${var.virtual_machine_name_prefix}${count.index}"
        domain    = "${var.virtual_machine_domain}"
      }

      network_interface {
        ipv4_address = "${cidrhost(var.virtual_machine_network_address, var.virtual_machine_ip_address_start + count.index)}"
        ipv4_netmask = "${element(split("/", var.virtual_machine_network_address), 1)}"
      }

      ipv4_gateway    = "${var.virtual_machine_gateway}"
      dns_suffix_list = ["${var.virtual_machine_domain}"]
      dns_server_list = ["${var.virtual_machine_dns_servers}"]
    }
  }
}
