# Strands Agent API Gateway

A Terraform infrastructure project that provisions an AWS API Gateway for a Strands agent with supporting Lambda functions and resources.

## Project Structure

```
├── lambda_code/
│   ├── lambda_function.py      # Main Lambda function code
│   └── requirements.txt        # Python dependencies
├── api_gateway.tf                 # API Gateway configuration
├── data.tf                        # Data sources
├── iam.tf                         # IAM roles and policies
├── lambda.tf                      # Lambda function resources
├── locals.tf                      # Local variables
├── logs.tf                        # CloudWatch logs configuration
├── output.tf                      # Output values
├── provider.tf                    # Terraform provider configuration
├── s3.tf                          # S3 bucket resources
└── variables.tf                   # Input variables
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- AWS CLI configured with appropriate credentials
- Python 3.12 (for Lambda function)
- Bash shell (for build script)

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/avansledright/terraform-strands-agent-api.git
   cd terraform-strands-agent-api
   ```

2. **Configure variables**
   Update `variables.tf` or create a `terraform.tfvars` file with your specific values.

3. **Build and deploy**

   Or manually:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Components

### API Gateway
- RESTful API endpoint for the Strands agent
- Configured with proper authentication and CORS
- Integrated with Lambda backend

### Lambda Function
- Python-based function handling agent requests
- Located in `terraform/lambda_code/`
- Automatically packaged and deployed

### Supporting Resources
- **IAM**: Roles and policies for secure access
- **S3**: Storage for deployment artifacts
- **CloudWatch**: Logging
- **Data Sources**: External data references

## Usage

After deployment, the API Gateway will provide endpoints for interacting with your Strands agent. Check the Terraform outputs for the API URL and other important resource identifiers.

## Customization

- Modify `lambda_function.py` to implement your specific agent logic
- Update `requirements.txt` to include additional Python packages
- Adjust resource configurations in the respective `.tf` files
- Use `locals.tf` for environment-specific variables

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Notes

- Review IAM permissions before deploying to production
- Monitor CloudWatch logs for function execution details