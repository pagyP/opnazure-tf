variable "resource_group_name" {
}

variable "location" {

}

variable "tags" {
  type = map(any)

}

# variable "vm_names" {
#   type    = list(string)
#   default = ["vm1", "vm2"]
# }

variable "vm_name" {
  type = string
  validation {
    condition     = length(var.vm_name) <= 15
    error_message = "The VM name must be less than or equal to 15 characters."
  }
}

variable "admin_password" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "image_publisher" {
  type = string
}

variable "image_offer" {
  type = string
}

variable "image_sku" {
  type = string
}

variable "image_version" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "os_disk_caching" {
  type = string
}

variable "data_disk_caching" {
  type    = string
  default = "None"
}

variable "data_disk_size_gb" {
  type    = number
  default = 32
}

variable "data_disk_type" {
  type    = string
  default = "StandardSSD_LRS"
}



variable "enable_accelerated_networking" {
  type    = bool
  default = false
}

variable "enable_ip_forwarding" {
  type    = bool
  default = false
}

variable "trust_subnet_id" {

}

variable "untrust_subnet_id" {

}

variable "os_disk_type" {
  type    = string
  default = "StandardSSD_LRS"
}

variable "time_zone" {
  type    = string
  default = "GMT Standard Time"
}
  