variable "default_aws_region" {
  default = "us-east-2"
}

variable "my_bucket" {
  default = "my-temp-bucket-3856195394"
}

variable "my_layer_file" {
  default = "../layer/ge_layer.zip"
}

variable "layer_key" {
  default = "ge_layer.zip"
}
