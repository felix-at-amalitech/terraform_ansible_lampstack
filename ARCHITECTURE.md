# Architecture Documentation

## 🏗️ System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS VPC (10.0.0.0/16)               │
│                                                             │
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │   Public Subnet     │    │     Private Subnet 1        │ │
│  │   (10.0.1.0/24)     │    │     (10.0.2.0/24)          │ │
│  │                     │    │                             │ │
│  │  ┌───────────────┐  │    │   ┌───────────────────┐     │ │
│  │  │   Web Tier    │  │    │   │   App Tier        │     │ │
│  │  │   (Apache +   │  │    │   │   (Application   │     │ │
│  │  │    PHP)       │  │    │   │    Logic)        │     │ │
│  │  └───────────────┘  │    │   └───────────────────┘     │ │
│  └─────────────────────┘    └─────────────────────────────┘ │
│                                                             │
│                             ┌─────────────────────────────┐ │
│                             │     Private Subnet 2        │ │
│                             │     (10.0.3.0/24)          │ │
│                             │                             │ │
│                             │   ┌───────────────────┐     │ │
│                             │   │   Database Tier   │     │ │
│                             │   │   (RDS MySQL)     │     │ │
│                             │   └───────────────────┘     │ │
│                             └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🌐 Network Architecture

### VPC Configuration

- **CIDR Block**: 10.0.0.0/16
- **DNS Hostnames**: Enabled
- **DNS Resolution**: Enabled
- **Tenancy**: Default

### Subnet Design

| Subnet    | Type    | CIDR        | AZ   | Purpose                  |
| --------- | ------- | ----------- | ---- | ------------------------ |
| Public    | Public  | 10.0.1.0/24 | AZ-1 | Web servers, NAT Gateway |
| Private-1 | Private | 10.0.2.0/24 | AZ-1 | Application servers      |
| Private-2 | Private | 10.0.3.0/24 | AZ-2 | Database (Multi-AZ)      |

### Routing Configuration

- **Public Route Table**: Routes to Internet Gateway
- **Private Route Table**: Internal routing only
- **Internet Gateway**: Provides internet access to public subnet

## 🔒 Security Architecture

### Security Groups

#### Web Security Group

```
Inbound Rules:
- HTTP (80): 0.0.0.0/0
- SSH (22): 0.0.0.0/0

Outbound Rules:
- All Traffic: 0.0.0.0/0
```

#### App Security Group

```
Inbound Rules:
- Port 9000: Web Security Group
- SSH (22): 0.0.0.0/0

Outbound Rules:
- All Traffic: 0.0.0.0/0
```

#### Database Security Group

```
Inbound Rules:
- MySQL (3306): Web Security Group
- MySQL (3306): App Security Group

Outbound Rules:
- None (default deny)
```

## 💾 Data Architecture

### Database Design

- **Engine**: MySQL 8.0
- **Instance Class**: db.t3.micro
- **Storage**: 20GB GP2
- **Multi-AZ**: No (single instance)
- **Backup**: 7-day retention
- **Charset**: UTF-8 (PHP compatible)

### Database Schema

```sql
CREATE DATABASE lampdb2025;

CREATE TABLE healthy_fruits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    benefits TEXT
) CHARACTER SET utf8 COLLATE utf8_general_ci;
```

## 🖥️ Compute Architecture

### Web Tier Specifications

- **Instance Type**: t2.micro
- **AMI**: Amazon Linux 2
- **Storage**: 8GB GP2 EBS
- **Software Stack**:
  - Apache HTTP Server
  - PHP 7.4
  - MySQL Client

### App Tier Specifications

- **Instance Type**: t2.micro
- **AMI**: Amazon Linux 2
- **Storage**: 8GB GP2 EBS
- **Purpose**: Application logic processing

## 🔄 Data Flow

### Request Flow

1. **User Request** → Internet Gateway
2. **Internet Gateway** → Public Subnet (Web Tier)
3. **Web Tier** → Private Subnet (App Tier) [if needed]
4. **Web/App Tier** → Database Tier (RDS)
5. **Response** ← Reverse path

### Database Connection Flow

```
Web Server (PHP) → MySQL Client → RDS Endpoint → MySQL 8.0
```

## 📊 Monitoring Architecture

### CloudWatch Integration

- **EC2 Metrics**: CPU, Memory, Network
- **RDS Metrics**: Connections, CPU, Storage
- **Custom Logs**: Application and error logs

### Log Aggregation

- **System Logs**: `/var/log/messages`
- **Apache Logs**: `/var/log/httpd/`
- **Application Logs**: `/var/log/user-data.log`
- **Database Logs**: CloudWatch Logs

## 🚀 Deployment Architecture

### Infrastructure as Code

- **Tool**: Terraform
- **State Management**: Local state file
- **Module Structure**: Modular design for reusability

### Module Dependencies

```
main.tf
├── vpc (no dependencies)
├── web_tier (depends on: vpc, db_tier)
├── app_tier (depends on: vpc, web_tier, db_tier)
└── db_tier (depends on: vpc, app_tier)
```

## 🔧 Configuration Management

### User Data Scripts

- **Package Installation**: Automated via user_data
- **Service Configuration**: Systemd service management
- **Application Deployment**: Inline PHP code generation

### Parameter Management

- **Database Parameters**: Custom parameter group
- **Application Config**: Environment-specific variables
- **Security Config**: Security group rules

## 📈 Scalability Considerations

### Horizontal Scaling Options

- **Web Tier**: Auto Scaling Group + Load Balancer
- **App Tier**: Multiple instances behind internal LB
- **Database**: Read replicas for read scaling

### Vertical Scaling Options

- **Compute**: Larger instance types
- **Storage**: Increased EBS volume sizes
- **Database**: Higher RDS instance classes

## 🔐 Security Best Practices

### Network Security

- **Principle of Least Privilege**: Minimal required access
- **Defense in Depth**: Multiple security layers
- **Network Segmentation**: Public/private subnet isolation

### Data Security

- **Encryption at Rest**: RDS encryption available
- **Encryption in Transit**: SSL/TLS for database connections
- **Access Control**: Security group restrictions

## 🌍 Multi-Region Considerations

### Current Limitations

- **Single Region**: Deployed in one AWS region
- **Single AZ**: Web and App tiers in single AZ
- **No DR**: No disaster recovery setup

### Future Enhancements

- **Multi-AZ Deployment**: Distribute across AZs
- **Cross-Region Backup**: RDS cross-region snapshots
- **CDN Integration**: CloudFront for global distribution

## 🔍 Troubleshooting Architecture

### Health Checks

- **Web Tier**: HTTP response codes
- **App Tier**: Process monitoring
- **Database**: Connection testing

### Monitoring Points

- **Application Level**: PHP error logs
- **System Level**: OS metrics and logs
- **Network Level**: Security group traffic
- **Database Level**: RDS performance metrics
