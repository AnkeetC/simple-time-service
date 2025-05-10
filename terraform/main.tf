# Default AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Second AWS Provider with an alias
provider "aws" {
  alias  = "secondary"
  region = var.aws_region
}

# S3 bucket for storing Terraform state
resource "aws_s3_bucket" "terraform_state" {
  provider = aws
  bucket   = "simpletime-bucket-s3"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Server-side encryption configuration for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  provider = aws

  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# VPC + Subnets (Using the aliased provider)
module "vpc" {
  providers = {
    aws = aws.secondary
  }

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "simpletime-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  provider = aws.secondary

  name = "simpletime-cluster"
}

# IAM Role for ECS task
resource "aws_iam_role" "ecs_task_execution" {
  provider = aws.secondary

  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  provider = aws.secondary

  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "simpletime" {
  provider = aws.secondary

  family                   = "simpletime-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "simpletime",
    image     = var.container_image,
    essential = true,
    portMappings = [{
      containerPort = 8080,
      protocol      = "tcp"
    }]
  }])
}

# Security group for ECS service
resource "aws_security_group" "ecs_sg" {
  provider = aws.secondary

  name        = "ecs_sg"
  description = "Allow HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for ALB
resource "aws_security_group" "alb_sg" {
  provider = aws.secondary

  name        = "alb_sg"
  description = "Allow HTTP access to ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer Module
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name               = "simpletime-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]

  providers = {
    aws = aws.secondary
  }
}

# Target Group for ECS Service
resource "aws_lb_target_group" "simpletime" {
  provider = aws.secondary

  name        = "simpletime-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
    port = "8080"
  }
}

# Listener for ALB
resource "aws_lb_listener" "http" {
  provider = aws.secondary

  load_balancer_arn = module.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.simpletime.arn
  }
}

# ECS Service
resource "aws_ecs_service" "simpletime" {
  provider = aws.secondary

  name            = "simpletime-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.simpletime.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.simpletime.arn
    container_name   = "simpletime"
    container_port   = 8080
  }

  depends_on = [module.alb]
}
