# Serverless Weather Alert Bot on AWS

**Cloud Solutions Capstone Project : Group 7**  
**SRH University Leipzig | 2026**

## Team Members

- Rajdeep Saha : 100005470
- Almaskhan Anwarkhan Kazi : 100007165

Lecturer: Kendrick Bollens

---

## Project Overview

This project is a serverless weather-monitoring system built on AWS and deployed with Terraform.

Every hour, Amazon EventBridge Scheduler invokes an AWS Lambda function. The function requests current weather data for Leipzig from the Open-Meteo API, calculates the heat index, stores the result in Amazon DynamoDB, and compares it with a configurable threshold stored in AWS Secrets Manager.

If the calculated heat index is higher than the threshold, Amazon SNS sends an email alert. Amazon CloudWatch stores execution logs and displays operational metrics on a dashboard.

## Architecture

```text
EventBridge Scheduler
        |
        v
   AWS Lambda  -----> Open-Meteo API
        |
        +-----------> DynamoDB
        |
Secrets Manager ---> Lambda
        |
        +-----------> SNS ---> Email subscriber
        |
        +-----------> CloudWatch Logs, Alarm and Dashboard

IAM LabRole provides the required AWS permissions.
```

## AWS Services Used

| Service | Purpose |
|---|---|
| AWS Lambda | Runs the Python application logic |
| EventBridge Scheduler | Invokes Lambda automatically every hour |
| Open-Meteo API | Supplies current temperature and humidity data |
| Amazon DynamoDB | Stores historical weather records |
| AWS Secrets Manager | Stores the heat-index alert threshold |
| Amazon SNS | Sends email alerts |
| Amazon CloudWatch | Stores logs and displays metrics and alarm status |
| IAM LabRole | Provides permissions in AWS Academy Learner Lab |
| Terraform | Creates and configures the AWS infrastructure |

## Project Structure

```text
weather-alert-bot/
├── lambda/
│   └── lambda_function.py
├── main.tf
├── variables.tf
├── lambda.tf
├── eventbridge.tf
├── dynamodb.tf
├── sns.tf
├── secretsmanager.tf
├── cloudwatch.tf
├── dashboard.tf
├── outputs.tf
├── .terraform.lock.hcl
├── .gitignore
├── AWS-Dashboard.png
├── Cloud-Group-7-Architectural-Diagram.md
└── README.md
```

Generated files such as `.terraform/`, `terraform.tfstate`, `terraform.tfstate.backup`, `tfplan`, `lambda.zip`, and `response.json` are intentionally excluded from the repository.

## Prerequisites

- AWS Academy Learner Lab
- Terraform 1.5 or newer
- AWS CLI
- Git, if cloning the repository

## Deployment

### 1. Clone the repository

```bash
git clone https://github.com/almaskhankazi/serverless-weather-alert-bot-aws.git
cd serverless-weather-alert-bot-aws
```

### 2. Start AWS Learner Lab

Start the Learner Lab and copy the temporary AWS CLI credentials from:

```text
AWS Details -> AWS CLI -> Show
```

### 3. Configure the temporary AWS credentials

Run these commands in PowerShell and replace the placeholder values:

```powershell
$env:AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
$env:AWS_SESSION_TOKEN="YOUR_SESSION_TOKEN"
$env:AWS_DEFAULT_REGION="us-east-1"
$env:AWS_REGION="us-east-1"
```

Verify the connection:

```powershell
aws sts get-caller-identity
```

Do not commit AWS credentials or session tokens to GitHub.

### 4. Configure the alert email

Open `variables.tf` and replace:

```hcl
default = "your-email@example.com"
```

with an email address that can receive the SNS notification.

### 5. Initialize and validate Terraform

```powershell
terraform init
terraform fmt
terraform validate
```

### 6. Review and deploy

```powershell
terraform plan
terraform apply
```

Type `yes` when Terraform asks for confirmation.

### 7. Confirm the SNS subscription

AWS sends a subscription-confirmation email to the configured address. Open the email and click **Confirm subscription**.

## How the Application Works

1. EventBridge Scheduler invokes Lambda every hour.
2. Lambda requests current Leipzig weather data from Open-Meteo.
3. The API returns temperature and relative humidity in JSON format.
4. Lambda converts the temperature from Celsius to Fahrenheit.
5. Lambda calculates the heat index using the NOAA regression formula.
6. Lambda writes the following fields to DynamoDB:
   - location
   - timestamp
   - temperature
   - humidity
   - heat index
7. Lambda reads the alert threshold from Secrets Manager.
8. If the heat index is higher than the threshold, Lambda publishes a message to SNS.
9. SNS delivers the alert to the confirmed email subscriber.
10. CloudWatch records execution logs and operational metrics.

## Manual Lambda Test

The deployed function can be tested directly in the AWS Console:

```text
AWS Lambda -> Functions -> weather-alert-lambda -> Test
```

Use this event:

```json
{}
```

A successful response includes:

- `statusCode: 200`
- location
- timestamp
- temperature
- humidity
- heat index

The manual test is only for immediate verification. In normal operation, EventBridge Scheduler invokes Lambda automatically every hour.

## Alert Demonstration

The default threshold is 90°F.

To demonstrate the email alert:

1. Open `weather-alert-threshold` in AWS Secrets Manager.
2. Temporarily lower the threshold below the current calculated heat index.
3. Invoke Lambda manually or wait for the next scheduled run.
4. Confirm that the SNS email alert arrives.
5. Restore the threshold to 90°F after the demonstration.

## DynamoDB Data Model

| Attribute | Type | Purpose |
|---|---|---|
| `location` | String | Partition key |
| `timestamp` | String | Sort key |
| `temperature` | Number | Temperature in Celsius |
| `humidity` | Number | Relative humidity percentage |
| `heat_index` | Number | Calculated heat index in Fahrenheit |

A different timestamp is generated for each execution, so the table keeps historical weather readings instead of overwriting the previous item.

## Monitoring

The Terraform configuration creates:

- CloudWatch log group: `/aws/lambda/weather-alert-lambda`
- Lambda error alarm: `weather-lambda-errors`
- CloudWatch dashboard: `weather-alert-dashboard`

The dashboard displays:

- Lambda invocations and errors
- Lambda duration
- DynamoDB writes and latency
- SNS messages published and delivered
- Lambda error-alarm status

## Terraform Outputs

After deployment, Terraform displays:

- Lambda function name
- DynamoDB table name
- SNS topic ARN
- CloudWatch dashboard name
- CloudWatch dashboard URL

## Remove AWS Resources

To delete all resources created by this project, run:

```powershell
terraform destroy
