variable "default_aws_region" {
  default = "us-east-2"
}

variable "my_bucket" {
  default = "{{{YOUR BUCKET NAME GOES HERE}}}"
}

variable "my_layer_file" {
  default = "../layer/ge_layer.zip"
}

variable "layer_key" {
  default = "ge_layer.zip"
}
