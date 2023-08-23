variable "avail_zone1" {
    type = string
    default = "eu-central-1a"
}

variable "avail_zone2" {
    type = string
    default = "eu-central-1b"
}

variable "env_prefix" {
    type = string
    default = "test"
}

variable "vpc_cidr_block" {
    type = string
    default = "10.2.0.0/16"
}

variable "pub1_subnet" {
    type = string
    default = "10.2.1.0/24"
}

variable "pub2_subnet" {
    type = string
    default = "10.2.2.0/24"
}
