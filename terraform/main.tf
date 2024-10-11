### NETWORK ###

resource "aws_vpc" "vpc" {
  cidr_block         = var.cidr_block
  enable_dns_support = true

}
resource "aws_subnet" "subnet" {
  availability_zone = var.az
  cidr_block        = aws_vpc.vpc.cidr_block
  vpc_id            = aws_vpc.vpc.id
  depends_on        = [aws_vpc.vpc]
}

### KEYS ###

resource "aws_key_pair" "pubkey" {
  key_name   = var.pubkey_name
  public_key = var.public_key
}

### NETWORK INTERFACES ###

resource "aws_network_interface" "netip" {
  count     = var.vms_count
  subnet_id = aws_subnet.subnet.id
  private_ips = ["${var.vm_ip[count.index]}"]
}

data "template_file" "init_data" {
  count    = var.vms_count
  template = file("${var.init_script[0]}")

  vars = {
    hostname = var.hostnames[count.index],
    domain   = var.domain
  }
}

### VMS ###

resource "aws_instance" "vms" {
  count         = var.vms_count
  ami           = var.vm_image
  instance_type = var.vm_instance_type[count.index]
  key_name      = var.pubkey_name

  user_data = data.template_file.init_data[count.index].rendered

  depends_on = [
    aws_subnet.subnet,
    aws_key_pair.pubkey,
  ]

  tags = {
    Name = "${var.hostnames[count.index]}.${var.domain}",
    Role = "${var.ansible_tags[count.index].Role}",
    Env = "${var.ansible_tags[count.index].Role}"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "disk1"
    volume_type           = var.vm_volume_type
    volume_size           = var.vm_volume_size[count.index]
  }
  network_interface {
    network_interface_id = aws_network_interface.netip[count.index].id
    device_index = 0
  }
}
