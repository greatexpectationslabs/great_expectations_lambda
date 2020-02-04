resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name = "great_expectations"
  filename = "${var.my_layer_file}"
  # s3_bucket = "${var.my_bucket}"
  # s3_key = "${var.layer_key}"

  compatible_runtimes = ["python3.7"]
}
