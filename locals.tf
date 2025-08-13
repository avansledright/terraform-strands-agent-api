locals {
  lambda_zip_hash = fileexists("${path.module}/lambda_function.zip") ? filemd5("${path.module}/lambda_function.zip") : ""
  requirements_hash = filemd5("lambda_code/requirements.txt")
  lambda_code_hash = filemd5("lambda_code/lambda_function.py")
  layer_zip_name = "lambda_layer_${local.requirements_hash}.zip"
}