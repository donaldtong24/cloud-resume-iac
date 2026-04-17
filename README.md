🚀 AWS Cloud Resume Challenge

A full-stack, serverless resume website built on AWS using Infrastructure as Code (Terraform) and automated through a CI/CD pipeline.

Live Demo: thedonaldtong.com
🏗️ Architecture Overview

The project follows a serverless, highly-available architecture designed for global performance, security, and dynamic functionality.

    Frontend: HTML5, CSS3, and JavaScript hosted on Amazon S3.

    Dynamic Backend: A visitor counter powered by AWS Lambda (Python/Boto3) using Lambda Function URLs for a direct HTTPS endpoint.

    Database: Amazon DynamoDB stores and persists the live visitor count.

    DNS & Routing: Amazon Route 53 manages global traffic for both the apex domain and www subdomain.

    Content Delivery: Amazon CloudFront serves as the CDN to deliver content via edge locations with low latency.

    Security: SSL/TLS certificate managed by AWS Certificate Manager (ACM), enforcing HTTPS globally.

    Infrastructure as Code: Terraform manages the entire AWS lifecycle as a single source of truth.

    CI/CD: GitHub Actions automates infrastructure updates, content synchronization, and CloudFront cache invalidation.

🛠️ Key Technical Features
🌐 Advanced DNS & Domain Management

    Apex & Subdomain Support: Configured Route 53 with Alias records for both thedonaldtong.com and www.thedonaldtong.com, ensuring seamless redirection and a professional user experience.

    High-Performance Routing: Utilized Route 53's internal AWS backbone to route traffic to CloudFront distributions without the latency or cost of standard CNAME records.

    SSL/TLS Integration: Validated a multi-domain ACM certificate using DNS records to provide end-to-end encryption for all site visitors.

⚡ Serverless Visitor Counter (Lean Architecture)

    Lambda Function URLs: Implemented a direct HTTPS endpoint for the Python backend, removing the overhead of API Gateway while maintaining secure communication.

    Atomic Increments: Utilized boto3 to perform atomic updates in DynamoDB, ensuring the visitor count remains accurate even during concurrent page loads.

    Frontend Integration: Used the JavaScript Fetch API to asynchronously retrieve and display the live counter data.

🔐 Security-First Approach

    Origin Access Control (OAC): Secured the S3 bucket to prevent public access; the bucket only accepts requests signed by the CloudFront distribution.

    IAM Least Privilege: Configured a granular IAM execution role for Lambda, restricting database access to a single DynamoDB table and specific actions (GetItem, UpdateItem).

🤖 Automation (CI/CD)

    Automatic Deployments: Every git push triggers a GitHub Action that runs terraform apply, syncs the ./website folder to S3, and invalidates the CloudFront cache.


Key learnings:

    Instead of making your S3 bucket "Public" (the easy but dangerous way), i used Origin Access Control (OAC) to keep it private and only allow the CDN to speak to it.
    
    I recognized that S3 uploads alone were insufficient for real-time updates due to edge caching. I integrated a create-invalidation command into my CI/CD pipeline, ensuring that global users see the latest 
    
    version of the resume within seconds of a deployment

markdown # Cloud Resume Infrastructure ![Architecture Diagram](./assets/ArchitectureDiagram.drawio.png)
