variable "secret_key" {
  description = "Secret key AWS"
  type = string
  default = "No default value, sensative data"
}

variable "access_key" {
  description = "Access key AWS"
  type = string
  default = "No default value, sensative data"
}

variable "public_key" {
  description = "SSH public key for access to host"
  type = string
  default = "No default value, sensative data"
}

variable "pubkey_name" {
  description = "Name of SSH public key into cloud console"
  type = string
  default = "Infra-key"
}

variable "vm_image" {
  description = "Cloud image ID for create VM"
  type = string
  default = "cmi-DC53AFE9"
}

variable "cidr_block" {
  description = "CIDR block for creating new VPC"
  type = string
  default = "10.55.0.0/16"
}

variable "bucket_name" {
  description = "S3 Bucket name"
  type = string
  default = "Cloud Project Bucket"
}

variable "az" {
  description = "Availability zone"
  type = string
  default = "ru-msk-comp1p"
}

variable "eips_count" {
  description = "Enter the number of Elastic IP addresses to create"
  type = number
  default = 1
}

variable "source_path" {
  description = "Source path to cloud image for upload into S3 bucket"
  type = string
  default = ""
}

variable "object_name" {
  description = "Cloud image object name"
  type = string
  default = ""
}

variable "vms_count" {
  description = "Number of virtual machines to create"
  type = number
  default = 1
}

variable "hostnames" {
  description = "Virtual machine hostname"
  type = list(string)
  default = ["vm01.croc.demo", "vm02.croc.demo"]
}

variable "allow_tcp_ports" {
  description = "List of TCP ports to allow connections from Internet"
  type = list(number)
  default = [22, 80, 443]
}

variable "vm_instance_type" {
  description = "Instance type for a VM"
  type = list(string)
  default = ["c5p.2large"]
}

variable "vm_volume_type" {
  description = "Volume type for VM disks"
  type = string
  default = "st2"
}

variable "domain" {
  description = "VM domain name"
  type = string
  default = "croc.demo"
}


variable "vm_volume_size" {
  description = "Volume size for VM disks"
  type = list(number)
  default = [64]
}

variable "project_name" {
  description = "Project name into cloud"
  type = string
  default = "Cloud Project"
}

variable "vm_ip" {
  description = "List of virtual machine IP addresss"
  type = list(string)
  default = ["10.55.1.10", "10.55.1.11"]
}

variable "public_network" {
  description = "Public network CIDR for access cloud resources"
  type = string
  default = "195.38.23.0/24"
}

variable "image_size" {
  description = "Default cloud image size"
  type = string
  default = 32
}

variable "network_ip" {
  description = "Network for VM"
  type = string
  default = "10.55.1.0/24"
}

variable "init_script" {
  description = "Cloud init script for init virtual machine"
  type = list(string)
  default = [""]
}

variable "ansible_tags" {
  description = "Terraform tags into terraform.state for ansible runner"
  type = list(map(string))
  default = [ { "Role" = "web", "Env" = "dev"}, {"Role" = "db", "Env" = "dev"}]
}
