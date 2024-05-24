resource "openstack_networking_subnet_v2" "first_subnet" {
  network_id  = openstack_networking_network_v2.first_network.id
  cidr        = "10.10.10.0/24"
  ip_version  = 4
  name        = "first_subnet"
  gateway_ip  = "10.10.10.1" #  the gateway IP
  enable_dhcp = true
}

# Associer le réseau externe au routeur existant
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = "2a767570-c326-421e-8f4f-80f46ad07994"
  subnet_id = openstack_networking_subnet_v2.first_subnet.id
}

# Output pour l'adresse IP de la passerelle
output "subnet_gateway_ip" {
  value = openstack_networking_subnet_v2.first_subnet.gateway_ip
}
resource "openstack_networking_network_v2" "first_network" {
  name           = "mon_network"
  admin_state_up = true
}
resource "openstack_networking_port_v2" "port_1" {
  name               = "port_1"
  network_id         = openstack_networking_network_v2.first_network.id
  admin_state_up     = true
 

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.first_subnet.id
    ip_address = "10.10.10.50"
  }
}



resource "openstack_blockstorage_qos_v3" "storage_1" {
  name     = "Storage"
  consumer = "front-end"
  specs = {
    read_iops_sec = "20000" # Adjust as per your requirements
  }
}

resource "openstack_blockstorage_volume_type_v3" "volume_type" {
  name = "Volume" 
}

resource "openstack_blockstorage_qos_association_v3" "association" {
  qos_id         = openstack_blockstorage_qos_v3.storage_1.id
  volume_type_id = openstack_blockstorage_volume_type_v3.volume_type.id
}

data "openstack_blockstorage_quotaset_v3" "first_data" {
  project_id = "00af7d4b048b4e6fbfd8d85fffa9b676"
}

resource "openstack_compute_instance_v2" "instance1" {
  name            = "instance1"
  image_id        = "84eb912a-24ff-4bc8-9af7-072ce60e2c8a"
  flavor_id       = "d1"
  key_pair        = "cle"
 

  user_data = <<-EOF
    #cloud-config
    password: toto
    chpasswd: { expire: False }
    ssh_pwauth: True
  EOF

  network {
    port = openstack_networking_port_v2.port_1.id
  }
}

variable "password" {
  type      = string
  sensitive = true
  default   = "toto"
}

