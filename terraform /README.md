## Deployment Instructions

### Prerequisites

- AWS CLI configured (`aws configure`)
- Docker image published to DockerHub
- Terraform installed

### Steps

```bash
cd terraform
terraform init
terraform apply


__Output will include the ALB DNS name — open it in your browser to test.

## 🏆 Extra Credit Options

- Enable remote backend (S3 + DynamoDB)