resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "${var.agent_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "lambda_artifacts" {
  bucket = aws_s3_bucket.lambda_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Package the lambda code for S3 upload
resource "null_resource" "lambda_code_zip" {
  triggers = {
    requirements_hash = local.lambda_code_hash
  }

  provisioner "local-exec" {
    command = <<-EOT
        set -e
        echo "Creating lambda Zip file based on this hash: ${local.requirements_hash}"

        # Create the zip file directly in the target location
        echo "Creating zip file..."
        cd ${path.module}/lambda_code/
        zip -r "${path.module}/lambda_function.zip" .

        # Cleanup
        echo "Function zip created"
    EOT
  }
}
# Upload Lambda deployment package to S3
resource "aws_s3_object" "lambda_package" {
  bucket = aws_s3_bucket.lambda_artifacts.id
  key    = "lambda_function.zip"
  source = "${path.module}/lambda_code/lambda_function.zip"
  etag   = local.lambda_zip_hash
}