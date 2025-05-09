terraform {
  backend "s3" {
    bucket         = "simpletime-bucket-s3"      # Replace with your bucket name
    key            = "simpletime/terraform.tfstate"   # Path to the state file
    region         = "us-east-1"                      # Adjust to your region
    dynamodb_table = "terraform-locks"                # DynamoDB table for locking
    encrypt        = true
  }
}
