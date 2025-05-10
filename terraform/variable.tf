variable "aws_region" {
  default = "us-east-1"
}

variable "container_image" {
  description = "Docker image for the SimpleTimeService"
  type        = string
}
