variable "access_key" {
        description = "Access key to AWS console"
}
variable "secret_key" {
        description = "Secret key to AWS console"
}

variable "region" {
        description = "region to deploy resources to"
        default = "us-east-1"
}


variable "instance_name" {
        description = "Name of the instance to be created"
        default = "awsbuilder-demo"
}

variable "instance_type" {
        default = "t2.micro"
}

variable "ubuntu_version" {
        description = "number of instances to be created"
        default = "22.04"
}