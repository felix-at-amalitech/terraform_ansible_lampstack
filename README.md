# LAMP Stack on AWS with Terraform

A complete 3-tier LAMP (Linux, Apache, MySQL, PHP) stack deployed on AWS using Terraform infrastructure as code.

## 🏗️ Architecture Overview

This project deploys a scalable 3-tier architecture:

- **Web Tier**: EC2 instance in public subnet running Apache and PHP
- **Application Tier**: EC2 instance in private subnet for application logic
- **Database Tier**: RDS MySQL instance in private subnets

## 📋 Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 3.0
- SSH key pair generated (`~/.ssh/lamp_key.pub`)
- AWS account with necessary permissions

## 🚀 Quick Start

1. **Clone and Navigate**

   ```bash
   cd terraform_ansible_lampstack/Terraform
   ```

2. **Initialize Terraform**

   ```bash
   terraform init
   ```

3. **Configure Variables**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Deploy Infrastructure**

   ```bash
   terraform plan
   terraform apply
   ```

5. **Access Application**
   - Get public IP from outputs
   - Visit `http://YOUR_PUBLIC_IP`

## 📁 Project Structure

```
terraform_ansible_lampstack/
├── Terraform/
│   ├── main.tf                 # Root module configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── terraform.tfvars        # Variable values
│   └── modules/
│       ├── vpc/                # VPC and networking
│       ├── web_tier/           # Web server configuration
│       ├── app_tier/           # Application server
│       └── db_tier/            # Database configuration
└── Ansible/                    # Ansible playbooks (optional)
```

## 🔧 Configuration

### Required Variables

| Variable                | Description           | Example                |
| ----------------------- | --------------------- | ---------------------- |
| `region`                | AWS region            | `eu-west-1`            |
| `vpc_cidr`              | VPC CIDR block        | `10.0.0.0/16`          |
| `public_subnet_cidr`    | Public subnet CIDR    | `10.0.1.0/24`          |
| `private_subnet_cidr_1` | Private subnet 1 CIDR | `10.0.2.0/24`          |
| `private_subnet_cidr_2` | Private subnet 2 CIDR | `10.0.3.0/24`          |
| `az1`                   | Availability Zone 1   | `eu-west-1a`           |
| `az2`                   | Availability Zone 2   | `eu-west-1b`           |
| `db_subnet_group_name`  | DB subnet group name  | `lamp-db-subnet-group` |

### terraform.tfvars Example

```hcl
region                  = "eu-west-1"
vpc_cidr               = "10.0.0.0/16"
public_subnet_cidr     = "10.0.1.0/24"
private_subnet_cidr_1  = "10.0.2.0/24"
private_subnet_cidr_2  = "10.0.3.0/24"
az1                    = "eu-west-1a"
az2                    = "eu-west-1b"
db_subnet_group_name   = "lamp-db-subnet-group"
```

## 🏛️ Infrastructure Components

### VPC Module

- **VPC**: Custom VPC with DNS support
- **Subnets**: 1 public, 2 private subnets across AZs
- **Internet Gateway**: For public internet access
- **Route Tables**: Separate routing for public/private subnets

### Web Tier Module

- **EC2 Instance**: Amazon Linux 2 in public subnet
- **Security Group**: HTTP (80) and SSH (22) access
- **User Data**: Automated LAMP stack installation
- **Application**: Healthy Ghanaian Fruits web app

### App Tier Module

- **EC2 Instance**: Amazon Linux 2 in private subnet
- **Security Group**: Port 9000 from web tier, SSH access
- **Purpose**: Application logic processing

### Database Tier Module

- **RDS Instance**: MySQL 5.7 with custom parameter group
- **Security Groups**: MySQL (3306) access from web/app tiers
- **Subnet Group**: Multi-AZ deployment
- **Configuration**: UTF-8 charset for PHP compatibility

## 🔒 Security Features

- **Network Isolation**: Private subnets for app and database
- **Security Groups**: Least privilege access rules
- **Database Security**: No public access, encrypted at rest
- **SSH Access**: Key-based authentication only

## 📊 Application Features

The deployed web application includes:

- **Modern UI/UX**: Responsive design with gradient backgrounds
- **Database Integration**: Dynamic content from MySQL
- **Health Information**: Comprehensive fruit benefits database
- **Mobile Friendly**: Responsive grid layout
- **Performance**: Optimized CSS and minimal JavaScript

## 🔍 Monitoring & Troubleshooting

### Log Locations

- **User Data Logs**: `/var/log/user-data.log`
- **Database Connection**: `/var/log/db-connection.log`
- **PHP Errors**: `/var/log/php_errors.log`
- **Apache Logs**: `/var/log/httpd/`

### Common Issues

1. **500 Internal Server Error**

   - Check PHP error logs
   - Verify database connectivity
   - Ensure proper file permissions

2. **Database Connection Failed**

   - Verify security group rules
   - Check RDS instance status
   - Validate credentials

3. **404 Not Found**
   - Confirm Apache is running
   - Check file locations in `/var/www/html/`

## 🧪 Testing

### Manual Testing

```bash
# Test web server
curl http://YOUR_PUBLIC_IP/

# Test PHP functionality
curl http://YOUR_PUBLIC_IP/basic.php

# SSH to instances
ssh -i ~/.ssh/lamp_key ec2-user@YOUR_PUBLIC_IP
```

### Automated Testing

```bash
# Terraform validation
terraform validate
terraform plan

# Infrastructure testing
terraform show
terraform output
```

## 📈 Scaling Considerations

### Horizontal Scaling

- Add Application Load Balancer
- Deploy multiple web/app instances
- Implement Auto Scaling Groups

### Vertical Scaling

- Upgrade instance types
- Increase RDS instance size
- Add read replicas

## 🔄 Maintenance

### Updates

```bash
# Update infrastructure
terraform plan
terraform apply

# Update application code
# Modify user_data in web_tier module
terraform apply
```

### Backup Strategy

- RDS automated backups enabled
- Consider EBS snapshots for instances
- Application code in version control

## 💰 Cost Optimization

- **Instance Types**: t2.micro for development
- **RDS**: db.t3.micro for small workloads
- **Storage**: GP2 for cost-effective performance
- **Monitoring**: CloudWatch for resource optimization

## 🗑️ Cleanup

```bash
# Destroy all resources
terraform destroy

# Verify cleanup
aws ec2 describe-instances --region YOUR_REGION
aws rds describe-db-instances --region YOUR_REGION
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes with proper documentation
4. Test thoroughly
5. Submit pull request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

For issues and questions:

- Check troubleshooting section
- Review AWS CloudWatch logs
- Verify Terraform state consistency

## 🔗 Useful Links

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [Apache HTTP Server](https://httpd.apache.org/docs/)
- [PHP MySQL Extension](https://www.php.net/manual/en/book.mysqli.php)
