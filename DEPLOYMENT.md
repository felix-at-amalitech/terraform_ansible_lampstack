# Deployment Guide

## 🚀 Pre-Deployment Checklist

### Prerequisites

- [ ] AWS CLI installed and configured
- [ ] Terraform >= 3.0 installed
- [ ] SSH key pair generated (`~/.ssh/lamp_key.pub`)
- [ ] AWS account with sufficient permissions
- [ ] Git repository cloned locally

### AWS Permissions Required

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "rds:*",
                "iam:PassRole",
                "iam:CreateRole",
                "iam:AttachRolePolicy"
            ],
            "Resource": "*"
        }
    ]
}
```

## 🔧 Environment Setup

### 1. Generate SSH Key Pair

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -f ~/.ssh/lamp_key

# Verify key generation
ls -la ~/.ssh/lamp_key*
```

### 2. Configure AWS CLI

```bash
# Configure AWS credentials
aws configure

# Verify configuration
aws sts get-caller-identity
```

### 3. Prepare Terraform Variables

```bash
# Navigate to Terraform directory
cd terraform_ansible_lampstack/Terraform

# Create terraform.tfvars file
cat > terraform.tfvars << EOF
region                  = "eu-west-1"
vpc_cidr               = "10.0.0.0/16"
public_subnet_cidr     = "10.0.1.0/24"
private_subnet_cidr_1  = "10.0.2.0/24"
private_subnet_cidr_2  = "10.0.3.0/24"
az1                    = "eu-west-1a"
az2                    = "eu-west-1b"
db_subnet_group_name   = "lamp-db-subnet-group"
EOF
```

## 📋 Deployment Steps

### Step 1: Initialize Terraform

```bash
# Initialize Terraform working directory
terraform init

# Verify initialization
terraform version
```

### Step 2: Validate Configuration

```bash
# Validate Terraform configuration
terraform validate

# Format Terraform files
terraform fmt -recursive
```

### Step 3: Plan Deployment

```bash
# Create execution plan
terraform plan

# Save plan to file (optional)
terraform plan -out=tfplan
```

### Step 4: Deploy Infrastructure

```bash
# Apply configuration
terraform apply

# Or apply saved plan
terraform apply tfplan
```

### Step 5: Verify Deployment

```bash
# Check outputs
terraform output

# Verify resources in AWS Console
aws ec2 describe-instances --region eu-west-1
aws rds describe-db-instances --region eu-west-1
```

## 🔍 Post-Deployment Verification

### 1. Test Web Application

```bash
# Get public IP from Terraform output
PUBLIC_IP=$(terraform output -raw web_public_ip)

# Test HTTP connectivity
curl -I http://$PUBLIC_IP

# Test application response
curl http://$PUBLIC_IP
```

### 2. Verify Database Connectivity

```bash
# SSH to web server
ssh -i ~/.ssh/lamp_key ec2-user@$PUBLIC_IP

# Check database connection logs
sudo tail -f /var/log/db-connection.log

# Test MySQL connection
mysql -h <RDS_ENDPOINT> -u admin -p
```

### 3. Application Health Checks

```bash
# Check Apache status
sudo systemctl status httpd

# Check PHP configuration
php -v

# Verify application files
ls -la /var/www/html/
```

## 🔧 Configuration Updates

### Updating Application Code

```bash
# Modify web_tier module user_data
# Then apply changes
terraform plan
terraform apply
```

### Scaling Resources

```bash
# Update instance types in variables
# Apply changes
terraform apply
```

### Database Configuration Changes

```bash
# Note: Some changes require recreation
terraform plan
terraform apply
```

## 🚨 Troubleshooting Deployment

### Common Issues and Solutions

#### 1. SSH Key Not Found

```bash
# Error: Key pair not found
# Solution: Verify key exists and path is correct
ls -la ~/.ssh/lamp_key.pub
```

#### 2. Insufficient Permissions

```bash
# Error: Access denied
# Solution: Check AWS credentials and permissions
aws sts get-caller-identity
```

#### 3. Resource Limits Exceeded

```bash
# Error: Limit exceeded
# Solution: Check AWS service limits
aws service-quotas get-service-quota --service-code ec2 --quota-code L-1216C47A
```

#### 4. Database Connection Issues

```bash
# Check security groups
aws ec2 describe-security-groups --group-names lamp-db-sg

# Verify RDS status
aws rds describe-db-instances --db-instance-identifier lamp-db
```

### Debug Commands

```bash
# Terraform debug mode
export TF_LOG=DEBUG
terraform apply

# Check Terraform state
terraform show
terraform state list

# Validate resources
terraform plan -detailed-exitcode
```

## 🔄 Update Procedures

### Infrastructure Updates

1. **Backup Current State**

   ```bash
   cp terraform.tfstate terraform.tfstate.backup
   ```

2. **Plan Changes**

   ```bash
   terraform plan -out=update.tfplan
   ```

3. **Apply Updates**

   ```bash
   terraform apply update.tfplan
   ```

### Application Updates

1. **Modify Code in user_data**
2. **Plan and Apply**

   ```bash
   terraform plan
   terraform apply
   ```

3. **Verify Changes**

   ```bash
   curl http://$PUBLIC_IP
   ```

## 🗑️ Cleanup Procedures

### Complete Cleanup

```bash
# Destroy all resources
terraform destroy

# Confirm cleanup
terraform show
```

### Selective Cleanup

```bash
# Remove specific resources
terraform destroy -target=module.web_tier

# Verify remaining resources
terraform state list
```

## 📊 Monitoring Deployment

### CloudWatch Metrics

- Monitor EC2 instance health
- Track RDS performance
- Set up alarms for critical metrics

### Log Monitoring

```bash
# Monitor deployment logs
tail -f /var/log/user-data.log

# Check application logs
tail -f /var/log/httpd/error_log
```

## 🔐 Security Considerations

### Post-Deployment Security

1. **Change Default Passwords**
2. **Update Security Groups**
3. **Enable CloudTrail**
4. **Configure Backup Policies**

### Security Validation

```bash
# Check security groups
aws ec2 describe-security-groups

# Verify encryption settings
aws rds describe-db-instances --query 'DBInstances[*].StorageEncrypted'
```

## 📈 Performance Optimization

### Post-Deployment Tuning

1. **Monitor Resource Utilization**
2. **Optimize Database Queries**
3. **Configure Caching**
4. **Implement CDN**

### Performance Testing

```bash
# Load testing with curl
for i in {1..100}; do curl -s http://$PUBLIC_IP > /dev/null; done

# Monitor response times
curl -w "@curl-format.txt" -o /dev/null -s http://$PUBLIC_IP
```

## 📝 Deployment Checklist

### Pre-Deployment

- [ ] AWS credentials configured
- [ ] SSH keys generated
- [ ] Terraform variables set
- [ ] Network requirements validated

### During Deployment

- [ ] Terraform init successful
- [ ] Plan review completed
- [ ] Apply executed without errors
- [ ] Outputs captured

### Post-Deployment

- [ ] Application accessible
- [ ] Database connectivity verified
- [ ] Security groups validated
- [ ] Monitoring configured
- [ ] Backup policies set
- [ ] Documentation updated
