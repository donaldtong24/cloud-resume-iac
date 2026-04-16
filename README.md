This project is a full-stack serverless web application that hosts my professional resume. It was built as part of the Cloud Resume Challenge to demonstrate proficiency in AWS architecture, security best practices and serverless development.

Website:https://d1q12364j99x2l.cloudfront.net/

Architecture:

    The project follows a "Low-Code/High-Architecture" approach, prioritizing managed services to ensure high availability and minimal operational overhead.

        Frontend: HTML5, CSS3, and JavaScript.

        Storage: AWS S3 (Static Website Hosting).

        Delivery: AWS CloudFront (CDN) for global low-latency access and SSL termination.

        Database: AWS DynamoDB (NoSQL) for storing visitor counts.

        Backend: AWS Lambda (Python) to handle database logic.

        API: AWS API Gateway (HTTP API) acting as the bridge between frontend and backend.

Security Implementations:
    Coming from a Security+ background, I implemented the following hardening measures:

        Origin Access Control (OAC): Restricted S3 bucket access so that the website is only accessible via CloudFront, keeping the bucket itself private.

        Protocol Enforcement: Configured CloudFront to automatically redirect all HTTP traffic to HTTPS (TLS).

        CORS Configuration: Implemented a restricted Cross-Origin Resource Sharing policy on API Gateway to allow requests only from the verified resume domain.

        Principle of Least Privilege: Assigned a scoped IAM Role to the Lambda function, granting only GetItem and UpdateItem permissions to the specific DynamoDB table.

Key Decisions

    Why S3/CloudFront over Amplify? I chose to manually wire S3 and CloudFront to demonstrate a deeper understanding of IAM policies, CDN behaviors, and edge networking, which are critical for an AWS Architect role.

    Why DynamoDB? Chose a NoSQL approach for its pay as you go pricing model and seamless integration with AWS Lambda.

Future plans: 
    Implement CI/CD using GitHub Actions or AWS CodePipeline.

    Infrastructure as Code (IaC) using Terraform or AWS SAM.