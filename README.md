# Simple Time Service

Welcome to the **Simple Time Service** project! This project demonstrates the deployment and management of a time-based service using modern cloud-native tooling, Docker, and Infrastructure as Code (IaC) practices.

## Project Overview

This project is a time-based API that serves current time and date information. It is containerized using Docker, deployed with AWS resources using Terraform, and integrated with a CI/CD pipeline for automatic builds and deployments.

## Features

- **Dockerized Application**: The application is containerized using Docker, which ensures portability and easy deployment to various environments.
- **Infrastructure as Code (IaC)**: Using Terraform, all the necessary infrastructure is defined in code, allowing for easy scaling, management, and version control.
- **CI/CD Pipeline**: The entire process, from code push to Docker image deployment to cloud infrastructure, is automated with GitHub Actions.

## Extra Credit Tasks Completed

This project includes the following extra credit tasks:

### 1. **Remote Terraform Backend with S3 and DynamoDB**
   - Configured a **remote Terraform backend** using **AWS S3** for storing state files and **DynamoDB** for state locking. This setup ensures better scalability, team collaboration, and prevents potential conflicts during parallel runs.
   
   #### Details:
   - **S3**: Used to store Terraform state files.
   - **DynamoDB**: Used for state locking to prevent race conditions during parallel execution of Terraform commands.

### 2. **CI/CD Pipeline**
   - Created a simple **CI/CD pipeline** using **GitHub Actions** that:
     - Builds and pushes a Docker image to **Docker Hub**.
     - Applies Terraform to manage cloud infrastructure.
   
   #### Details:
   - **Docker Hub**: Stores the Docker image of the application.
   - **Terraform**: Manages infrastructure deployment on AWS.

### Each folder has its detail README.md files for futer steps

