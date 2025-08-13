# Create the lambda layer zip file when requirements.txt changes
resource "null_resource" "lambda_layer_zip" {
  triggers = {
    requirements_hash = local.requirements_hash
  }

  provisioner "local-exec" {
    command = <<-EOT
        set -e
        echo "Creating lambda layer for requirements hash: ${local.requirements_hash}"

        # Create a temporary directory for building the layer
        mkdir -p ${path.module}/lambda_layer/python

        # Install dependencies to the python directory (required structure for layers)
        echo "Installing dependencies..."
        pip install -r lambda_code/requirements.txt -t ${path.module}/lambda_layer/python --python-version 3.12 --platform manylinux2014_aarch64 --only-binary=:all:

        # Create the zip file directly in the target location
        echo "Creating zip file..."
        cd ${path.module}/lambda_layer
        zip -r "${path.module}/lambda_layer.zip" python/

        # Cleanup
        rm -rf ${path.module}/lambda_layer/
        echo "Layer zip created"
    EOT
  }
}

# Upload the layer zip to S3
resource "aws_s3_object" "lambda_layer_package" {
  depends_on = [null_resource.lambda_layer_zip]
  
  bucket = aws_s3_bucket.lambda_artifacts.id
  key    = "lambda_layer.zip"
  source = "${path.module}/lambda_layer/lambda_layer.zip"
  etag   = local.requirements_hash

  lifecycle {
    create_before_destroy = true
  }
}

# Create the Lambda Layer
resource "aws_lambda_layer_version" "python_dependencies" {
  depends_on = [aws_s3_object.lambda_layer_package]
  
  layer_name          = "strands-python-dependencies-layer"
  s3_bucket          = aws_s3_bucket.lambda_artifacts.id
  s3_key             = aws_s3_object.lambda_layer_package.key
  compatible_runtimes = ["python3.12"]
  compatible_architectures = ["arm64"]
  
  description = "Python dependencies layer - updated ${timestamp()}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_function" "strands_demo" {
  s3_bucket     = aws_s3_bucket.lambda_artifacts.id
  s3_key        = aws_s3_object.lambda_package.key
  function_name = var.agent_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 60
  memory_size   = 512
  architectures = ["arm64"] #ARM 64 is required for Strands

  # This ensures Lambda updates when the S3 object changes
  source_code_hash = local.lambda_zip_hash
  layers = [
    aws_lambda_layer_version.python_dependencies.arn
  ]
  environment {
    variables = {
      # Use a different name since AWS_REGION is reserved
      BEDROCK_REGION              = var.aws_region
      BEDROCK_MODEL_ID            = var.model_name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.bedrock_access,
    aws_s3_object.lambda_package
  ]
}